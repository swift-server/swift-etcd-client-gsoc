//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-etcd-client-gsoc open source project
//
// Copyright (c) 2024 Apple Inc. and the swift-etcd-client-gsoc project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of swift-etcd-client-gsoc project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import GRPC
import NIO
import SwiftProtobuf

public final class EtcdClient: @unchecked Sendable {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup
    private var connection: ClientConnection
    private var client: Etcdserverpb_KVNIOClient
    private var watchClient: Etcdserverpb_WatchAsyncClient


    /// Initialize a new ETCD Connection.
    ///
    /// - Parameters:
    ///   - host: The host address of the ETCD server.
    ///   - port: The port number of the ETCD server.
    ///   - eventLoopGroup: The event loop group to use for this connection.
    public init(host: String, port: Int, eventLoopGroup: EventLoopGroup) {
        self.host = host
        self.port = port
        self.group = eventLoopGroup
        self.connection = ClientConnection.insecure(group: self.group)
            .connect(host: host, port: port)
        self.client = Etcdserverpb_KVNIOClient(channel: self.connection)
        self.watchClient = Etcdserverpb_WatchAsyncClient(channel: self.connection)
    }

    /// Sets a value for a specified key in the ETCD server.
    ///
    /// - Parameters:
    ///   - key: The key for which the value is to be set. Parameter is of type Sequence<UInt8>.
    ///   - value: The ETCD value to set for the key. Parameter is of type Sequence<UInt8>.
    public func set(_ key: some Sequence<UInt8>, value: some Sequence<UInt8>) async throws {
        var putRequest = Etcdserverpb_PutRequest()
        putRequest.key = Data(key)
        putRequest.value = Data(value)
        let call = client.put(putRequest)
        _ = try await call.response.get()
    }
    
    /// Sets a value for a specified key in the ETCD server.
    ///
    /// - Parameters:
    ///   - key: The key for which the value is to be set. Parameter is of type String,
    ///   - value: The ETCD value to set for the key. Parameter is of type String.
    public func set(_ key: String, value: String) async throws {
        try await set(key.utf8, value: value.utf8)
    }

    /// Fetch the value for a key from the ETCD server.
    ///
    /// - Parameter key: The key to fetch the value for. Parameter is of type Sequence<UInt8>.
    /// - Returns: A `Value` containing the fetched value, or `nil` if no value was found.
    public func get(_ key: some Sequence<UInt8>) async throws -> Data? {
        var rangeRequest = Etcdserverpb_RangeRequest()
        rangeRequest.key = Data(key)

        let call = client.range(rangeRequest)
        let response = try await call.response.get()
        
        guard let kv = response.kvs.first else {
            return nil
        }
        return kv.value
    }
    
    /// Fetch the value for a key from the ETCD server.
    ///
    /// - Parameter key: The key to fetch the value for. Parameter is of type String.
    /// - Returns: A `Value` containing the fetched value, or `nil` if no value was found.
    public func get(_ key: String) async throws -> Data? {
        return try await get(key.utf8)
    }
    
    /// Delete the value for a key from the ETCD server.
    ///
    /// - Parameter key: The key to delete. Parameter is of type Sequence<UInt8>.
    public func delete(_ key: some Sequence<UInt8>) async throws {
        var deleteRangeRequest = Etcdserverpb_DeleteRangeRequest()
        deleteRangeRequest.key = Data(key)
        let call = client.deleteRange(deleteRangeRequest)
        _ = try await call.response.get()
    }
    
    /// Deletes the value for a key from the ETCD server.
    ///
    /// - Parameter key: The key to delete the value for. Parameter is of type String.
    public func delete(_ key: String) async throws {
        return try await delete(key.utf8)
    }
    
    /// Puts a value for a specified key in the ETCD server. If the key does not exist, a new key, value pair is created.
    ///
    /// - Parameters:
    ///   - key: The key for which the value is to be put. Parameter is of type Sequence<UInt8>.
    ///   - value: The ETCD value to put for the key. Parameter is of type Sequence<UInt8>.
    public func put(_ key: some Sequence<UInt8>, value: some Sequence<UInt8>) async throws {
        try await set(key, value: value)
    }
    
    /// Puts a value for a specified key in the ETCD server.  If the key does not exist, a new key, value pair is created.
    ///
    /// - Parameters:
    ///   - key: The key for which the value is to be put. Parameter is of type String.
    ///   - value: The ETCD value to put for the key. Parameter is of type String.
    public func put(_ key: String, value: String) async throws {
        try await put(key.utf8, value: value.utf8)
    }
    
    /// Watches a specified key in the ETCD server.
    ///
    /// - Parameters:
    ///   - key: The key for which the value is watched. Parameter is of type Sequence<UInt8>.
    ///   - operation: The operation to be run on the WatchAsyncSequence for the key.
    public func watch<Result>(_ key: some Sequence<UInt8>, _ operation: (WatchAsyncSequence) async throws -> Result) async throws -> Result {
        let request = [Etcdserverpb_WatchRequest.with { $0.createRequest.key = Data(key) }]
        let watchAsyncSequence = WatchAsyncSequence(grpcAsyncSequence: watchClient.watch(request))
        return try await operation(watchAsyncSequence)
    }
    
    /// Watches a specified key in the ETCD server.
    ///
    /// - Parameters:
    ///   - key: The key for which the value is watched. Parameter is of type String.
    ///   - operation: The operation to be run on the WatchAsyncSequence for the key.
    public func watch<Result>(_ key: String, _ operation: (WatchAsyncSequence) async throws -> Result) async throws -> Result {
        try await self.watch(key.utf8, operation)
    }
}

public enum EventType {
    case put
    case delete

    init(protoType: Int) {
        switch protoType {
        case 0:
            self = .put
        case 1:
            self = .delete
        default:
            fatalError("Unsupported event type")
        }
    }

    var protoType: Int {
        switch self {
        case .put:
            return 0
        case .delete:
            return 1
        }
    }
}

public struct KeyValue {
    public var key: Data
    public var createRevision: Int64
    public var modRevision: Int64
    public var version: Int64
    public var value: Data
    public var lease: Int64

    init(protoKeyValue: Etcdserverpb_KeyValue) {
        self.key = protoKeyValue.key
        self.createRevision = protoKeyValue.createRevision
        self.modRevision = protoKeyValue.modRevision
        self.version = protoKeyValue.version
        self.value = protoKeyValue.value
        self.lease = protoKeyValue.lease
    }
}


public struct WatchEvent {
    public var kv: KeyValue
    public var prevKV: KeyValue?

    init(protoEvent: Etcdserverpb_Event) {
        self.kv = KeyValue(protoKeyValue: protoEvent.kv)
        if let protoPrevKV = protoEvent.hasPrevKv ? protoEvent.prevKv : nil {
            self.prevKV = KeyValue(protoKeyValue: protoPrevKV)
        } else {
            self.prevKV = nil
        }
    }
}


public struct WatchAsyncSequence: AsyncSequence {
    public typealias Element = [WatchEvent]

    private let grpcAsyncSequence: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>

    init(grpcAsyncSequence: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>) {
        self.grpcAsyncSequence = grpcAsyncSequence
    }

    public func makeAsyncIterator() -> AsyncIterator {
        .init(grpcIterator: self.grpcAsyncSequence.makeAsyncIterator())
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private var grpcIterator: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>.AsyncIterator?

        fileprivate init(grpcIterator: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>.AsyncIterator) {
            self.grpcIterator = grpcIterator
        }

        public mutating func next() async throws -> Element? {
            while true {
                guard let response = try await self.grpcIterator?.next() else {
                    return nil
                }

                if response.created {
                    // We receive this after setting up the watch and need to wait for the next
                    // response that contains an event
                    precondition(response.events.isEmpty, "Expected no watch events on created response")
                    continue
                }

                if response.canceled {
                    // We got cancelled and have to return nil now
                    self.grpcIterator = nil
                    return nil
                }

                let events = response.events.map { WatchEvent(protoEvent: $0) }
                return events
            }
        }
    }
}

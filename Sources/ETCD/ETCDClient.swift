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

public struct KeyValue {
    public let key: Data
    public let value: Data

    init(from internalKV: Etcdserverpb_KeyValue) {
        self.key = internalKV.key
        self.value = internalKV.value
    }
}

public final class EtcdClient: @unchecked Sendable {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup
    private var connection: ClientConnection
    private var client: Etcdserverpb_KVNIOClient

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
    public func get(key: Data, endKey: Data? = nil) async throws -> [KeyValue] {
       var rangeRequest = Etcdserverpb_RangeRequest()
       rangeRequest.key = key
       
       if let endKey = endKey {
           rangeRequest.rangeEnd = endKey
       }

       let call = client.range(rangeRequest)
       let response = try await call.response.get()
       
       return response.kvs.map { KeyValue(from: $0) }
    }
    
    /// Fetch the value for a key from the ETCD server.
    ///
    /// - Parameter key: The key to fetch the value for. Parameter is of type String.
    /// - Returns: A `Value` containing the fetched value, or `nil` if no value was found.
    public func get(key: String, endKey: String? = nil) async throws -> [KeyValue] {
        return try await get(key: Data(key.utf8), endKey: endKey != nil ? Data(endKey!.utf8) : nil)
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

}

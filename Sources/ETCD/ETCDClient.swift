import Foundation
import GRPC
import NIO
import SwiftProtobuf

public final class EtcdClient: @unchecked Sendable {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup
    private var connection: ClientConnection
    private var client: Etcdserverpb_KVNIOClient!

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
    /// - Parameter key: The key to fetch the value for. Parameter is of type Sequence<UInt8>.
    /// - Returns: A `Value` containing the fetched value, or `nil` if no value was found.
    public func get(_ key: String) async throws -> Data? {
        return try await get(key.utf8)
    }
}

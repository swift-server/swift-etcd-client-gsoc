import Foundation
import GRPC
import NIO
import SwiftProtobuf

public final class EtcdClient: Sendable {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup
    private var connection: ClientConnection
    private var client: Etcdserverpb_KVClient!

    public init(host: String, port: Int, eventLoopGroup: EventLoopGroup) {
        self.host = host
        self.port = port
        self.group = eventLoopGroup
        self.connection = ClientConnection.insecure(group: self.group)
            .connect(host: host, port: port)
        self.client = Etcdserverpb_KVClient(channel: self.connection)
    }

    public func set(_ key: String, value: String) async throws {
        var putRequest = Etcdserverpb_PutRequest()
        putRequest.key = Data(key.utf8)
        putRequest.value = Data(value.utf8)

        let call = client.put(putRequest)
        let response = try await call.response.get()
    }

    public func get(_ key: String) async throws -> String? {
        var rangeRequest = Etcdserverpb_RangeRequest()
        rangeRequest.key = Data(key.utf8)

        let call = client.range(rangeRequest)
        let response = await try call.response.get()

        guard let kv = response.kvs.first else {
            return nil
        }
        return String(data: kv.value, encoding: .utf8)
    }
}

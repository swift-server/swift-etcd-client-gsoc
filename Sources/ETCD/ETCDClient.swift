import GRPC
import NIO
import Foundation

final class EtcdClient {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup
    private var connection: ClientConnection
    private var client: Etcdserverpb_KVClient!

    init(host: String, port: Int) {
        self.host = host
        self.port = port
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.connection = ClientConnection.insecure(group: self.group)
            .connect(host: host, port: port)
        self.client = Etcdserverpb_KVClient(channel: self.connection)
    }

    deinit {
        try? self.group.syncShutdownGracefully()
    }

    public func get<Value: EtcdValue>(_ key: String, as valueType: Value.Type = Value.self) async throws -> Value? {
        let request = Etcdserverpb_RangeRequest.with {
            $0.key = key.data(using: .utf8)!
        }
        let response = try await client.range(request).response

        guard let kv = response.kvs.first,
              let value = Value(data: kv.value) else {
            return nil
        }

        return value
    }
}
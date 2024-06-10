import Foundation
import GRPC
import NIO
import SwiftProtobuf


public final class EtcdClient {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup
    private var connection: ClientConnection
    private var client: Etcdserverpb_KVClient!

    public init(host: String, port: Int) {
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

    public func setKey(key: String, value: String) throws {
        var putRequest = Etcdserverpb_PutRequest()
        putRequest.key = Data(key.utf8)
        putRequest.value = Data(value.utf8)

        let call = client.put(putRequest)
        let response = try call.response.wait()
        print("Set key response: \(response)")
    }

    public func getKey(key: String) throws -> String? {
        var rangeRequest = Etcdserverpb_RangeRequest()
        rangeRequest.key = Data(key.utf8)

        let call = client.range(rangeRequest)
        let response = try call.response.wait()

        guard let kv = response.kvs.first else {
            return nil
        }
        return String(data: kv.value, encoding: .utf8)
    }
}
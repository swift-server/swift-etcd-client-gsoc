import ETCD
import NIO
import Dispatch

@main
struct Example {
    static func main() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        do {
            let etcdClient = EtcdClient(host: "localhost", port: 2379, eventLoopGroup: eventLoopGroup)
            etcdClient.watch(key: "foo") { keyValuePairs in
                for (key, value) in keyValuePairs {
                    print("Watch response: Key = \(key), Value = \(value)")
                }
            }
            
            try await etcdClient.set("foo", value: "bar")
            if let value = try await etcdClient.get("foo") {
               if let stringValue = String(data: value, encoding: .utf8) {
                   print("Value is: \(stringValue)")
                   try await etcdClient.delete("foo")
                   print("Key deleted")
                   
                   // Trying to get the value again
                   let deletedValue = try await etcdClient.get("foo")
                   if deletedValue == nil {
                       print("Key not found after deletion")
                   } else {
                       print("Value after deletion: \(deletedValue!)")
                   }
               } else {
                   print("Unable to get value")
               }
            } else {
               print("Key not found")
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                Task {
                    do {
                        try await etcdClient.set("foo", value: "updated_value")
                    } catch {
                        print("Error setting updated value: \(error)")
                    }
                }
            }
            try await eventLoopGroup.next().makePromise(of: Void.self).futureResult.get()
        } catch {
            print("Error: \(error)")
        }
    }
}

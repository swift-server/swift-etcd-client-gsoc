import ETCD
let etcdClient = EtcdClient(host: "localhost", port: 2379)
do {
    try etcdClient.setKey(key: "foo", value: "bar")
    if let value = try etcdClient.getKey(key: "foo") {
        print("Value is: \(value)")
    } else {
        print("Key not found")
    }
} catch {
    print("Error: \(error)")
}
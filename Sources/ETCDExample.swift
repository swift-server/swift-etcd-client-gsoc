struct User: EtcdValue {
    var id: Int
    var name: String

    init?(data: Data) {
        guard let string = String(data: data, encoding: .utf8),
              let components = string.split(separator: ",").map(String.init) as? [String],
              components.count == 2,
              let id = Int(components[0]) else {
            return nil
        }
        self.id = id
        self.name = components[1]
    }

    func toData() -> Data? {
        return "\(id),\(name)".data(using: .utf8)
    }
}

let etcdClient = EtcdClient(host: "localhost", port: 2379)

Task {
    do {
        if let user: User = try await etcdClient.get("user_123", as: User.self) {
            print("Retrieved user: \(user.name)")
        } else {
            print("User not found.")
        }
    } catch {
        print("Error retrieving user: \(error)")
    }
}
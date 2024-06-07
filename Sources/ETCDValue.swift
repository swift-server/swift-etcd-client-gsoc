protocol EtcdValue {
    init?(data: Data)
    func toData() -> Data?
}
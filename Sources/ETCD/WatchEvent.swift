import Foundation

/// Struct representing a watch event in etcd.
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
    
    init(kv: KeyValue, prevKV: KeyValue?) {
        self.kv = kv
        self.prevKV = prevKV
    }
}

/// ETCDValue conformance to several standard Swift types.
import Foundation
import GRPC
import NIO
import NIOCore
import SwiftProtobuf

public protocol ETCDValue {
    var asData: Data { get }
}

extension Int: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension Int8: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension Int16: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension Int32: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension Int64: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension UInt: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension UInt8: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension UInt16: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension UInt32: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension UInt64: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
extension String: ETCDValue {
    public var asData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}

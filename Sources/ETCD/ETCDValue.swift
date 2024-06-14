/// ETCDValue conformance to several standard Swift types.
import Foundation
import GRPC
import NIO
import NIOCore
import SwiftProtobuf

public protocol ETCDValue {}

extension Int: ETCDValue {}
extension Int8: ETCDValue {}
extension Int16: ETCDValue {}
extension Int32: ETCDValue {}
extension Int64: ETCDValue {}
extension UInt: ETCDValue {}
extension UInt8: ETCDValue {}
extension UInt16: ETCDValue {}
extension UInt32: ETCDValue {}
extension UInt64: ETCDValue {}
extension String: ETCDValue {}

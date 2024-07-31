//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-etcd-client-gsoc open source project
//
// Copyright (c) 2024 Apple Inc. and the swift-etcd-client-gsoc project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of swift-etcd-client-gsoc project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

public struct WatchEvent {
    public var keyValue: KeyValue
    public var previousKeyValue: KeyValue?

    init(protoEvent: Etcdserverpb_Event) {
        self.keyValue = KeyValue(protoKeyValue: protoEvent.kv)
        if let protoPrevKV = protoEvent.hasPrevKv ? protoEvent.prevKv : nil {
            self.previousKeyValue = KeyValue(protoKeyValue: protoPrevKV)
        } else {
            self.previousKeyValue = nil
        }
    }
    
    /// Struct representing a watch event in etcd.
    ///
    /// - Parameters:
    ///   - keyValue: keyValue representing a KeyValue to watch.
    ///   - previousKeyValue: previousKeyValue representing a KeyValue that was previously received.
    public init(keyValue: KeyValue, previousKeyValue: KeyValue?) {
        self.keyValue = keyValue
        self.previousKeyValue = previousKeyValue
    }
}

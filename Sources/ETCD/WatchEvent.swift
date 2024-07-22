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

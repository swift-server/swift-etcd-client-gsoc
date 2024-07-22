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

/// Struct representing a key-value pair in etcd server.
public struct KeyValue {
    public var key: Data
    public var createRevision: Int
    public var modRevision: Int
    public var version: Int
    public var value: Data
    public var lease: Int

    init(protoKeyValue: Etcdserverpb_KeyValue) {
        self.key = protoKeyValue.key
        self.createRevision = Int(protoKeyValue.createRevision)
        self.modRevision = Int(protoKeyValue.modRevision)
        self.version = Int(protoKeyValue.version)
        self.value = protoKeyValue.value
        self.lease = Int(protoKeyValue.lease)
    }
    
    init(key: Data, createRevision: Int64, modRevision: Int64, version: Int64, value: Data, lease: Int64) {
        self.key = key
        self.createRevision = Int(createRevision)
        self.modRevision = Int(modRevision)
        self.version = Int(version)
        self.value = value
        self.lease = Int(lease)
    }
}

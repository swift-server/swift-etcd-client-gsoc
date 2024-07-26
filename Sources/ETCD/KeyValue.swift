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
    
    /// Initialize a new KeyValue.
    ///
    /// - Parameters:
    ///   - key: key in bytes. An empty key is not allowed.
    ///   - create_revision: revision of the last creation on the key.
    ///   - mod_revision: revision of the last modification on the key.
    ///   - version: version is the version of the key. A deletion resets the version to zero and any modification of the key increases its version.
    ///   - value: value in bytes.
    ///   - lease: the ID of the lease attached to the key. If lease is 0, then no lease is attached to the key.
    public init(key: Data, createRevision: Int, modRevision: Int, version: Int, value: Data, lease: Int) {
        self.key = key
        self.createRevision = createRevision
        self.modRevision = modRevision
        self.version = version
        self.value = value
        self.lease = lease
    }
}

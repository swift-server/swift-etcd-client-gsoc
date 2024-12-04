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

/// Struct representing a delete range request in etcd server.
public struct DeleteRangeRequest {
    public var key: Data
    public var rangeEnd: Data?
    public var prevKV: Bool = false

    init(protoDeleteRangeRequest: Etcdserverpb_DeleteRangeRequest) {
        self.key = protoDeleteRangeRequest.key
        self.rangeEnd = protoDeleteRangeRequest.rangeEnd.isEmpty ? nil : protoDeleteRangeRequest.rangeEnd
        self.prevKV = protoDeleteRangeRequest.prevKv
    }

    /// Struct representing a deleteRangeRequest in etcd.
    ///
    /// - Parameters:
    ///   - key: key of type Data.
    ///   - rangeEnd: The key range to fetch until.
    ///   - prevKV: when set, return the contents of the deleted key-value pairs.
    public init(key: Data, rangeEnd: Data? = nil, prevKV: Bool = false) {
        self.key = key
        self.rangeEnd = rangeEnd
        self.prevKV = prevKV
    }

    func toProto() -> Etcdserverpb_DeleteRangeRequest {
        var protoDeleteRangeRequest = Etcdserverpb_DeleteRangeRequest()
        protoDeleteRangeRequest.key = self.key
        if let rangeEnd = self.rangeEnd {
            protoDeleteRangeRequest.rangeEnd = rangeEnd
        }
        protoDeleteRangeRequest.prevKv = self.prevKV
        return protoDeleteRangeRequest
    }
}

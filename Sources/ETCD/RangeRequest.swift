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

public struct RangeRequest {
    public enum SortOrder: Int {
        case none = 0
        case ascend = 1
        case descend = 2
    }

    public enum SortTarget: Int {
        case key = 0
        case version = 1
        case create = 2
        case mod = 3
        case value = 4
    }

    public var key: Data
    public var rangeEnd: Data?
    public var limit: Int = 0
    public var revision: Int = 0
    public var sortOrder: SortOrder = .none
    public var sortTarget: SortTarget = .key
    public var serializable: Bool = false
    public var keysOnly: Bool = false
    public var countOnly: Bool = false
    public var minModRevision: Int = 0
    public var maxModRevision: Int = 0
    public var minCreateRevision: Int = 0
    public var maxCreateRevision: Int = 0

    init(protoRangeRequest: Etcdserverpb_RangeRequest) {
        key = protoRangeRequest.key
        rangeEnd = protoRangeRequest.rangeEnd
        limit = Int(protoRangeRequest.limit)
        revision = Int(protoRangeRequest.revision)
        sortOrder = SortOrder(rawValue: protoRangeRequest.sortOrder.rawValue) ?? .none
        sortTarget = SortTarget(rawValue: protoRangeRequest.sortTarget.rawValue) ?? .key
        serializable = protoRangeRequest.serializable
        keysOnly = protoRangeRequest.keysOnly
        countOnly = protoRangeRequest.countOnly
        minModRevision = Int(protoRangeRequest.minModRevision)
        maxModRevision = Int(protoRangeRequest.maxModRevision)
        minCreateRevision = Int(protoRangeRequest.minCreateRevision)
        maxCreateRevision = Int(protoRangeRequest.maxCreateRevision)
    }

    public init(key: Data, rangeEnd: Data? = nil) {
        self.key = key
        self.rangeEnd = rangeEnd
    }

    func toProto() -> Etcdserverpb_RangeRequest {
        var protoRangeRequest = Etcdserverpb_RangeRequest()
        protoRangeRequest.key = key
        protoRangeRequest.rangeEnd = rangeEnd ?? Data()
        protoRangeRequest.limit = Int64(limit)
        protoRangeRequest.revision = Int64(revision)
        protoRangeRequest.sortOrder = Etcdserverpb_RangeRequest.SortOrder(rawValue: sortOrder.rawValue) ?? .none
        protoRangeRequest.sortTarget = Etcdserverpb_RangeRequest.SortTarget(rawValue: sortTarget.rawValue) ?? .key
        protoRangeRequest.serializable = serializable
        protoRangeRequest.keysOnly = keysOnly
        protoRangeRequest.countOnly = countOnly
        protoRangeRequest.minModRevision = Int64(minModRevision)
        protoRangeRequest.maxModRevision = Int64(maxModRevision)
        protoRangeRequest.minCreateRevision = Int64(minCreateRevision)
        protoRangeRequest.maxCreateRevision = Int64(maxCreateRevision)
        return protoRangeRequest
    }
}

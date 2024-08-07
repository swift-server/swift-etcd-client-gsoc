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
        self.key = protoRangeRequest.key
        self.rangeEnd = protoRangeRequest.rangeEnd
        self.limit = Int(protoRangeRequest.limit)
        self.revision = Int(protoRangeRequest.revision)
        self.sortOrder = SortOrder(rawValue: protoRangeRequest.sortOrder.rawValue) ?? .none
        self.sortTarget = SortTarget(rawValue: protoRangeRequest.sortTarget.rawValue) ?? .key
        self.serializable = protoRangeRequest.serializable
        self.keysOnly = protoRangeRequest.keysOnly
        self.countOnly = protoRangeRequest.countOnly
        self.minModRevision = Int(protoRangeRequest.minModRevision)
        self.maxModRevision = Int(protoRangeRequest.maxModRevision)
        self.minCreateRevision = Int(protoRangeRequest.minCreateRevision)
        self.maxCreateRevision = Int(protoRangeRequest.maxCreateRevision)
    }
    
    public init(key: Data, rangeEnd: Data? = nil) {
        self.key = key
        self.rangeEnd = rangeEnd
    }
    
    func toProto() -> Etcdserverpb_RangeRequest {
        var protoRangeRequest = Etcdserverpb_RangeRequest()
        protoRangeRequest.key = self.key
        protoRangeRequest.rangeEnd = self.rangeEnd ?? Data()
        protoRangeRequest.limit = Int64(self.limit)
        protoRangeRequest.revision = Int64(self.revision)
        protoRangeRequest.sortOrder = Etcdserverpb_RangeRequest.SortOrder(rawValue: self.sortOrder.rawValue) ?? .none
        protoRangeRequest.sortTarget = Etcdserverpb_RangeRequest.SortTarget(rawValue: self.sortTarget.rawValue) ?? .key
        protoRangeRequest.serializable = self.serializable
        protoRangeRequest.keysOnly = self.keysOnly
        protoRangeRequest.countOnly = self.countOnly
        protoRangeRequest.minModRevision = Int64(self.minModRevision)
        protoRangeRequest.maxModRevision = Int64(self.maxModRevision)
        protoRangeRequest.minCreateRevision = Int64(self.minCreateRevision)
        protoRangeRequest.maxCreateRevision = Int64(self.maxCreateRevision)
        return protoRangeRequest
    }
}

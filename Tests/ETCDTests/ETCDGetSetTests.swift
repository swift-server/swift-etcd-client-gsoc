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
import XCTest
import NIO
@testable import ETCD

final class EtcdClientTests: XCTestCase {
    var eventLoopGroup: EventLoopGroup!
    var etcdClient: EtcdClient!

    override func setUp() async throws {
        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        etcdClient = EtcdClient(host: "localhost", port: 2379, eventLoopGroup: eventLoopGroup)
    }

    override func tearDown() async throws {
        try await eventLoopGroup.shutdownGracefully()
    }

    func testSetAndGetStringValue() async throws {
        try await etcdClient.set("testKey", value: "testValue")
        let result = try await etcdClient.get("testKey")
        
        XCTAssertNotNil(result)
        XCTAssertEqual(String(data: result!, encoding: .utf8), "testValue")
    }
    
    func testGetNonExistentKey() async throws {
        let result = try await etcdClient.get("nonExistentKey")
        XCTAssertNil(result)
    }
}

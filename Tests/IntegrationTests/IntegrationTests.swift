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

import ETCD
import NIO
import XCTest

final class IntegrationTests: XCTestCase {

    private static let integrationTestEnabled = getBoolEnv("SWIFT_ETCD_CLIENT_INTEGRATION_TEST_ENABLED") ?? false

    override func setUp() async throws {
        try XCTSkipUnless(Self.integrationTestEnabled)
    }

    func testSetAndGetStringValue() async throws {
        let etcdClient = EtcdClient.testClient

        try await etcdClient.set("testKey", value: "testValue")
        let key = "testKey".data(using: .utf8)!
        let rangeRequest = RangeRequest(key: key)
        let result = try await etcdClient.getRange(rangeRequest)

        XCTAssertNotNil(result)
        XCTAssertEqual(String(data: result!, encoding: .utf8), "testValue")
    }

    func testGetNonExistentKey() async throws {
        let etcdClient = EtcdClient.testClient

        let key = "nonExistentKey".data(using: .utf8)!
        let rangeRequest = RangeRequest(key: key)
        let result = try await etcdClient.getRange(rangeRequest)
        XCTAssertNil(result)
    }

    func testDeleteKeyExists() async throws {
        let etcdClient = EtcdClient.testClient

        let key = "testKey"
        let value = "testValue"
        try await etcdClient.set(key, value: value)

        let rangeRequestKey = "testKey".data(using: .utf8)!
        let rangeRequest = RangeRequest(key: rangeRequestKey)
        var fetchedValue = try await etcdClient.getRange(rangeRequest)
        XCTAssertNotNil(fetchedValue)

        let deleteRangeRequest = DeleteRangeRequest(key: rangeRequestKey)
        try await etcdClient.deleteRange(deleteRangeRequest)

        fetchedValue = try await etcdClient.getRange(rangeRequest)
        XCTAssertNil(fetchedValue)
    }

    func testDeleteNonExistentKey() async throws {
        let etcdClient = EtcdClient.testClient

        let key = "testKey".data(using: .utf8)!
        let rangeRequest = RangeRequest(key: key)

        var fetchedValue = try await etcdClient.getRange(rangeRequest)
        XCTAssertNil(fetchedValue)

        let deleteRangeRequest = DeleteRangeRequest(key: key)
        try await etcdClient.deleteRange(deleteRangeRequest)

        fetchedValue = try await etcdClient.getRange(rangeRequest)
        XCTAssertNil(fetchedValue)
    }

    func testUpdateExistingKey() async throws {
        let etcdClient = EtcdClient.testClient

        let key = "testKey"
        let value = "testValue"
        try await etcdClient.set(key, value: value)

        let rangeRequestKey = "testKey".data(using: .utf8)!
        let rangeRequest = RangeRequest(key: rangeRequestKey)
        let fetchedValue = try await etcdClient.getRange(rangeRequest)
        XCTAssertNotNil(fetchedValue)
        XCTAssertEqual(String(data: fetchedValue!, encoding: .utf8), value)

        let updatedValue = "updatedValue"
        try await etcdClient.put(key, value: updatedValue)

        let rangeRequestUpdatedKey = "testKey".data(using: .utf8)!
        let rangeRequestUpdated = RangeRequest(key: rangeRequestUpdatedKey)
        let fetchedUpdatedValue = try await etcdClient.getRange(rangeRequestUpdated)
        XCTAssertNotNil(fetchedUpdatedValue)
        XCTAssertEqual(String(data: fetchedUpdatedValue!, encoding: .utf8), updatedValue)
    }

    func testWatch() async throws {
        let etcdClient = EtcdClient.testClient

        let key = "testKey"
        let value = "testValue".data(using: .utf8)!

        try await etcdClient.put(key, value: "foo")

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await etcdClient.watch(key) { watchAsyncSequence in
                    var iterator = watchAsyncSequence.makeAsyncIterator()
                    let events = try await iterator.next()
                    guard let events = events else {
                        XCTFail("No event received for key: \(key)")
                        return
                    }

                    for event in events {
                        if event.keyValue.key == key.data(using: .utf8) {
                            XCTAssertEqual(event.keyValue.value, value)
                            return
                        }
                    }

                    XCTFail("No matching event received for key: \(key)")
                }
            }

            try await Task.sleep(nanoseconds: 1_000_000_000)
            try await etcdClient.put(key, value: String(data: value, encoding: .utf8)!)
            group.cancelAll()
        }
    }
}

extension EtcdClient {
    fileprivate static let testClient = EtcdClient(
        host: ProcessInfo.processInfo.environment["ETCD_HOST"] ?? "localhost",
        port: getIntEnv("ETCD_PORT") ?? 2379,
        eventLoopGroup: .singletonMultiThreadedEventLoopGroup
    )
}

/// Returns true if `key` is a truthy string, otherwise returns false.
private func getBoolEnv(_ key: String) -> Bool? {
    switch ProcessInfo.processInfo.environment[key]?.lowercased() {
    case .none: return nil
    case "true", "y", "yes", "on", "1": return true
    default: return false
    }
}

private func getIntEnv(_ key: String) -> Int? { ProcessInfo.processInfo.environment[key].flatMap(Int.init(_:)) }

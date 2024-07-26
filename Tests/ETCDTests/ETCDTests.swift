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
import ETCD

final class EtcdClientTests: XCTestCase {
    var eventLoopGroup: EventLoopGroup!
    var etcdClient: EtcdClient!

    override func setUp() async throws {
        eventLoopGroup = MultiThreadedEventLoopGroup.singleton
        etcdClient = EtcdClient(host: "localhost", port: 2379, eventLoopGroup: eventLoopGroup)
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
    
    func testDeleteKeyExists() async throws {
        let key = "testKey"
        let value = "testValue"
        try await etcdClient.set(key, value: value)
        
        var fetchedValue = try await etcdClient.get(key)
        XCTAssertNotNil(fetchedValue)
        
        try await etcdClient.delete(key)
        
        fetchedValue = try await etcdClient.get(key)
        XCTAssertNil(fetchedValue)
    }
        
    func testDeleteNonExistentKey() async throws {
        let key = "testKey"
        
        var fetchedValue = try await etcdClient.get(key)
        XCTAssertNil(fetchedValue)
        
        try await etcdClient.delete(key)
        
        fetchedValue = try await etcdClient.get(key)
        XCTAssertNil(fetchedValue)
    }
    
    func testUpdateExistingKey() async throws {
        let key = "testKey"
        let value = "testValue"
        try await etcdClient.set(key, value: value)
        
        let fetchedValue = try await etcdClient.get(key)
        XCTAssertNotNil(fetchedValue)
        XCTAssertEqual(String(data: fetchedValue!, encoding: .utf8), value)
        
        let updatedValue = "updatedValue"
        try await etcdClient.put(key, value: updatedValue)
        
        let fetchedUpdatedValue = try await etcdClient.get(key)
        XCTAssertNotNil(fetchedUpdatedValue)
        XCTAssertEqual(String(data: fetchedUpdatedValue!, encoding: .utf8), updatedValue)
    }
    
    func testWatch() async throws {
        let key = "testKey"
        let value = "testValue".data(using: .utf8)!

        try await etcdClient.put(key, value: "foo")

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.etcdClient.watch(key) { watchAsyncSequence in
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

            group.addTask {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }

            group.addTask {
                try await self.etcdClient.put(key, value: String(data: value, encoding: .utf8)!)
            }

            for try await _ in group {}
        }
    }
}

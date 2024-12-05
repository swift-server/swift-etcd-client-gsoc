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

import Dispatch
import ETCD
import NIO

@main
struct Example {
    static func main() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup.singleton
        do {
            let etcdClient = EtcdClient(host: "localhost", port: 2379, eventLoopGroup: eventLoopGroup)
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        try await etcdClient.watch("foo") { sequence in
                            var iterator = sequence.makeAsyncIterator()
                            while let event = try await iterator.next() {
                                print(event)
                            }
                        }
                    } catch {
                        print("Error watching key: \(error)")
                    }
                }
                // Sleeping for a second to let the watch above setup
                try await Task.sleep(for: .seconds(1))

                try await etcdClient.set("foo", value: "bar")
                let key = "foo".data(using: .utf8)!
                let rangeRequest = RangeRequest(key: key)
                if let value = try await etcdClient.getRange(rangeRequest) {
                    if let stringValue = String(data: value, encoding: .utf8) {
                        print("Value is: \(stringValue)")
                        let deleteRangeRequest = DeleteRangeRequest(key: key)
                        try await etcdClient.deleteRange(deleteRangeRequest)
                        print("Key deleted")

                        // Trying to get the value again
                        let deletedValue = try await etcdClient.getRange(rangeRequest)
                        if deletedValue == nil {
                            print("Key not found after deletion")
                        } else {
                            print("Value after deletion: \(deletedValue!)")
                        }
                    } else {
                        print("Unable to get value")
                    }
                } else {
                    print("Key not found")
                }
                try await Task.sleep(for: .seconds(2))
                do {
                    try await etcdClient.set("foo", value: "updated_value")
                } catch {
                    print("Error setting updated value: \(error)")
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

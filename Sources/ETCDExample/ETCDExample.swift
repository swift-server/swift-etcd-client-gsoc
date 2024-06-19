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

@main
struct Example {
    static func main() async throws {
        do {
            let etcdClient = EtcdClient(host: "localhost", port: 2379, eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
            try await etcdClient.set("foo", value: "bar")
            if let value = try await etcdClient.get("foo") {
                if let stringValue = String(data: value, encoding: .utf8) {
                    print("Value is: \(stringValue)")
                } else {
                    print("Unable to get value")
                }
            } else {
                print("Key not found")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

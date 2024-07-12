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
import Dispatch

@main
struct Example {
    static func main() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        do {
            let etcdClient = EtcdClient(host: "localhost", port: 2379, eventLoopGroup: eventLoopGroup)
            Task {
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
            
            try await etcdClient.set("foo", value: "bar")
            if let value = try await etcdClient.get("foo") {
               if let stringValue = String(data: value, encoding: .utf8) {
                   print("Value is: \(stringValue)")
                   try await etcdClient.delete("foo")
                   print("Key deleted")
                   
                   // Trying to get the value again
                   let deletedValue = try await etcdClient.get("foo")
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
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                Task {
                    do {
                        try await etcdClient.set("foo", value: "updated_value")
                    } catch {
                        print("Error setting updated value: \(error)")
                    }
                }
            }
            try await eventLoopGroup.next().makePromise(of: Void.self).futureResult.get()
        } catch {
            print("Error: \(error)")
        }
    }
}

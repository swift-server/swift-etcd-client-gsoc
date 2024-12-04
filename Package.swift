// swift-tools-version: 5.7
//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-etcd-client-gsoc open source project
//
// Copyright (c) 2023 Apple Inc. and the swift-etcd-client-gsoc project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of swift-etcd-client-gsoc project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "swift-etcd-client-gsoc",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(
            name: "ETCD",
            targets: ["ETCD"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.56.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.14.0"),
    ],
    targets: [
        .target(
            name: "ETCD",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]
        ),
        .testTarget(
            name: "ETCDTests",
            dependencies: ["ETCD"]
        ),
        .executableTarget(
            name: "ETCDExample",
            dependencies: ["ETCD"]
        ),
    ]
)

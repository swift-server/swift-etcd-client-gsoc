# Swift-etcd-client-0001: Swift-etcd get API

## Overview

- Proposal: Swift-etcd-client-0001
- Author(s): [Ayushi Tiwari](https://github.com/ayushi2103)
- Mentor(s): [Franz Busch](https://github.com/FranzBusch)

## Introduction

This proposal outlines the API design for a get function interacting with etcd.

See also: https://forums.swift.org/t/gsoc-2024-swift-etcd-a-native-client-for-seamless-integration-with-etcd-servers/71615.

## Motivation

The Swift client for etcd is a critical interface for developers interacting with etcd's distributed key-value store. It is essential that the API:

- Uses natural Swift idioms.
- Provides a consistent and intuitive approach to get operation.
- Integrates seamlessly with grpc-swift for secure and reliable communication.

## Detailed Design

The API provides methods for interacting with etcd's key-value store, covering the following operation:

- Get: Unary RPC 
    - retrieves the value associated with a given key from the etcd server

### Key-Value Operations

- A final class providing a base implementation for key-value operations and key range queries and bulk deletions.

```swift
/// Protocol defining the requirements for types used as values in etcdClient
protocol EtcdValue {
    /// Initializes the value from a Data object
    init?(data: Data)
    
    /// Converts the value to a Data object
    func toData() -> Data?
}

/// Class providing a base implementation for key-value get operation with etcd
final class EtcdClient {
    /// Method to get value for a key from etcd
    public func get<Value: etcdValue>(_ key: String, as valueType: Value.Type = Value.self) async throws -> Value?  { }
}
```

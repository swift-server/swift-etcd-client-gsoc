# Swift-etcd-client-0001: Swift-etcd API

## Overview

- Proposal: Swift-etcd-client-0001
- Author(s): [Ayushi Tiwari](https://github.com/ayushi2103)
- Mentor(s): [Franz Busch](https://github.com/FranzBusch)

## Introduction

This proposal outlines the API design for a Swift client interacting with etcd, providing authentication, key-value operations, watch mechanisms, and lease management.

See also: https://forums.swift.org/t/gsoc-2024-swift-etcd-a-native-client-for-seamless-integration-with-etcd-servers/71615.

## Motivation

The Swift client for etcd is a critical interface for developers interacting with etcd's distributed key-value store. It is essential that the API:

- Uses natural Swift idioms.
- Provides a consistent and intuitive approach to common operations such as authentication, key-value management, watch operations, and lease management.
- Integrates seamlessly with grpc-swift for secure and reliable communication, leveraging features like TLS and metadata headers.
- Provides efficient key range queries and bulk deletions to optimize performance and reduce overhead.

## Detailed Design

The proposed API supports various etcd operations through well-defined methods. The API provides methods for interacting with etcd's key-value store, covering the following operations:

- Get: Unary RPC 
    - retrieves the value associated with a given key from the etcd server
- Put: Unary RPC 
    - stores a key-value pair in the etcd server
- Delete: Unary RPC  
    - removes a key and its associated value from the etcd server
- Range Queries: Server streaming RPC
    - retrieves multiple key-value pairs within a specified key range, returns multiple key-value pairs in response to a single request
- Bulk Deletion: Server streaming RPC 
    - deletes multiple keys within a specified key range in a single operation
- Watch Operations: Bidirectional RPC
    - allows clients to receive updates from the server when changes occur

The primary focus of this API design is to provide developers with a comprehensive and intuitive interface for interacting with etcd's key-value store, while also ensuring flexibility and scalability for various use cases.

### Authentication with etcd

- Authentication service will conform to a gRPC service with the following definition:

```protobuf
service AuthService {
    rpc Authenticate(AuthRequest) returns (AuthResponse);
}

message AuthRequest {
    string username = 1;
    string password = 2;
}

message AuthResponse {
    bool success = 1;
    string token = 2;
}
```
The authentication function in Swift takes takes an AuthRequest and returns an AuthResponse.

```swift
func authenticate(request: AuthRequest, session: Etcd_AuthenticateSession) throws -> AuthResponse {}
```

### Token-Based Authentication

- Upon successful authentication, a token will be generated and returned in the AuthResponse.
- This token will be passed via a metadata header in all subsequent etcd-specific requests.

### Client Configuration

- The client will have configuration options for TLS and authentication.

#### TLS Configuration

- TLS can be disabled or enabled based on client preference.
- Example for client configuration:

```swift
struct ClientConfiguration {
    struct TLS {
        var disabled: Self
        var enabled: Self
    }
}
```
#### Authentication Configuration

- Authentication can be performed with username/password or without authentication.
- Example for client configuration:

```swift
struct ClientConfiguration {
    struct Authentication {
        var none: Self
        func usernamePassword(String, String) -> Self
    }
}
```
### Key-Value Operations

- An abstract base class providing a base implementation for key-value operations and key range queries and bulk deletions.

```swift
/// Abstract class providing a base implementation for key-value operations with etcd
class BaseEtcdClient {
    /// Method to get value for a key from etcd
    func getValue(forKey key: String) -> String? {
        /// Implementation to retrieve value from etcd
        return nil
    }
    
    /// Method to store value for a key in etcd
    func storeValue(_ value: String, forKey key: String) {
        /// Implementation to store value in etcd
    }
    
    /// Method to delete value for a key from etcd
    func deleteValue(forKey key: String) {
        /// Implementation to delete value from etcd
    }
    
    /// Method to get values in a specified key range from etcd
    func getValuesInRange(startKey: String, endKey: String) -> [String: String] {
        /// Implementation to retrieve values within the specified key range from etcd
        return [:]
    }
    
    /// Method to delete keys in a specified key range from etcd
    func deleteKeysInRange(startKey: String, endKey: String) {
        /// Implementation to delete keys within the specified key range from etcd
    }
    
    /// Method to send a range request to etcd (to be implemented by subclasses)
    func sendRangeRequest(_ request: URLRequest) -> Data? {
        /// Implementation to send HTTP request for range operations to etcd
        return nil 
    }
}
```
### Watch Operations

- Input parameters include keys or key ranges to monitor.

```swift
struct EtcdWatchClient {
    // Establishes a watch on a specific key
    func watch(key: String, onUpdate: @escaping (String?) -> Void) -> EtcdWatchHandle
    // Cancels an active watch operation
    func cancelWatch(handle: EtcdWatchHandle)
}

// Protocol for managing watch handles
struct EtcdWatchHandle {
    // Cancels the watch operation associated with this handle
    func cancel()
}
```

### Lease Management

- Lease management in etcd allows for the control and expiration of keys based on time-to-live (TTL) values.

```swift
/// Lease ID
typealias LeaseID = Int
```

```swift
/// Lease Expiry
struct LeaseManager {
    /// Store lease IDs and their expiry times
    private var leaseExpiryTimes: [LeaseID: Date] = [:]
    
    /// Register a lease with its expiry time
    func registerLease(leaseID: LeaseID, expiryTime: Date) {
        leaseExpiryTimes[leaseID] = expiryTime
    }
    
    /// Check if a lease has expired
    func isLeaseExpired(leaseID: LeaseID) -> Bool {
        guard let expiryTime = leaseExpiryTimes[leaseID] else {
            return false
        }
        return expiryTime < Date()
    }
    
    /// Remove a lease from the list of active leases
    func removeLease(leaseID: LeaseID) {
        leaseExpiryTimes.removeValue(forKey: leaseID)
    }
}
```
```swift
/// Lease Management Implementation
struct EtcdLeaseClient {
    /// Implementation of lease creation
    func createLease(ttl: Int) -> LeaseID {
        /// Implementation to create a lease with the specified TTL
        let leaseID = // Generate a unique lease ID
        let expiryTime = Date().addingTimeInterval(TimeInterval(ttl))
        leaseManager.registerLease(leaseID: leaseID, expiryTime: expiryTime)
        return leaseID
    }
    
    /// Implementation of lease revocation
    func revokeLease(leaseID: LeaseID) {
        /// Implementation to revoke the lease associated with the given lease ID
        leaseManager.removeLease(leaseID: leaseID)
    }
    
    /// Implementation of lease renewal
    func renewLease(leaseID: LeaseID) {
        /// Implementation to renew the lease associated with the given lease ID
        // /Update the expiry time of the lease
        let expiryTime = Date().addingTimeInterval(TimeInterval(ttl))
        leaseManager.registerLease(leaseID: leaseID, expiryTime: expiryTime)
    }
}
```
## Example

```swift
import SwiftEtcd

/// Initialize etcd client
let etcd = EtcdClient()

/// Define key and value
let key = "/example/key"
let value = "exampleValue"

/// Store a key-value pair in etcd
do {
    try etcd.put(key: key, value: value)
    print("Key-value pair stored successfully.")
} catch {
    print("Error storing key-value pair: \(error)")
}

/// Retrieve the value for a key from etcd
do {
    let retrievedValue = try etcd.get(key: key)
    print("Retrieved value: \(retrievedValue)")
} catch {
    print("Error retrieving value for key: \(error)")
}

/// Delete a key from etcd
do {
    try etcd.delete(key: key)
    print("Key deleted successfully.")
} catch {
    print("Error deleting key: \(error)")
}

```

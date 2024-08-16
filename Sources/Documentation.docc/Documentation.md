# swift-etcd-client-gsoc

A Swift package for interacting with etcd, providing client functionalities such as setting, getting, deleting key-value pairs, and watching keys.

## Overview

This package includes the following key components:

- **EtcdClient:** A client for interacting with an etcd server.
- **KeyValue:** A struct representing a key-value pair in the etcd server.
- **RangeRequest:** A struct for fetching a range of key-value pairs from the etcd server.
- **DeleteRangeRequest:** A struct for deleting a range of key-value pairs from the etcd server.
- **WatchAsyncSequence:** A struct for handling asynchronous sequences of watch events.
- **WatchEvent:** A struct representing an event in the etcd watch mechanism.

## Components

### EtcdClient

`EtcdClient` is the primary interface for interacting with the etcd server. It allows you to set, get, delete, and watch key-value pairs.

#### Initialization

```swift
public init(host: String, port: Int, eventLoopGroup: EventLoopGroup)
```
* host The host address of the etcd server.
* port: The port number of the etcd server.
* eventLoopGroup: The event loop group to use for this connection.

#### Methods
* set(_:value:) - Sets a value for a specified key.
* getRange(_:) - Fetches a range from the etcd server.
* deleteRange(_:) - Deletes the value for a range from the etcd server.
* put(_:value:) - Puts a value for a specified key, creating a new key-value pair if it doesn't exist.
* watch(::): - Watches a specified key for changes.

### KeyValue

`KeyValue` represents a key-value pair in the etcd server.

#### Initialization

```swift
public init(key: Data, createRevision: Int, modRevision: Int, version: Int, value: Data, lease: Int)
```
* key: The key in bytes.
* createRevision: Revision of the last creation on the key.
* modRevision: Revision of the last modification on the key.
* version: The version of the key.
* value: The value in bytes.
* lease: The ID of the lease attached to the key.


### RangeRequest

`RangeRequest` is used to fetch a range of key-value pairs from the etcd server.

#### Initialization

```swift
public init(key: Data, rangeEnd: Data? = nil)
```
* key: The key to start the range fetch.
* rangeEnd: The key to end the range fetch.


### DeleteRangeRequest

`DeleteRangeRequest` is used to delete a range of key-value pairs from the etcd server.

#### Initialization

```swift
public init(key: Data, rangeEnd: Data? = nil, prevKV: Bool = false)
```
* key: The key of the range to delete.
* rangeEnd: The key to end the range deletion.
* prevKV: When set, return the contents of the deleted key-value pairs.

### WatchAsyncSequence

`WatchAsyncSequence` handles asynchronous sequences of watch events from the etcd server.

### WatchEvent

`WatchEvent` represents an event in the etcd watch mechanism.

```swift
public init(keyValue: KeyValue, previousKeyValue: KeyValue?)
```
* keyValue: The current key-value pair associated with the event.
* previousKeyValue: The previous key-value pair before the event occurred.

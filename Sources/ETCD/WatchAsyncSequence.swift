import GRPC

public struct WatchAsyncSequence: AsyncSequence {
    public typealias Element = [WatchEvent]

    private let grpcAsyncSequence: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>

    init(grpcAsyncSequence: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>) {
        self.grpcAsyncSequence = grpcAsyncSequence
    }

    public func makeAsyncIterator() -> AsyncIterator {
        .init(grpcIterator: self.grpcAsyncSequence.makeAsyncIterator())
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private var grpcIterator: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>.AsyncIterator?

        fileprivate init(grpcIterator: GRPCAsyncResponseStream<Etcdserverpb_WatchResponse>.AsyncIterator) {
            self.grpcIterator = grpcIterator
        }

        public mutating func next() async throws -> Element? {
            while let response = try await self.grpcIterator?.next() {
                if response.created {
                    // We receive this after setting up the watch and need to wait for the next
                    // response that contains an event
                    precondition(response.events.isEmpty, "Expected no watch events on created response")
                    continue
                }

                if response.canceled {
                    // We got cancelled and have to return nil now
                    self.grpcIterator = nil
                    return nil
                }

                let events = response.events.map { WatchEvent(protoEvent: $0) }
                return events
            }
            return nil;
        }
    }
}

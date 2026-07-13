import Foundation

public struct DeliveryReceipt: Equatable, Sendable {
    public let serverID: String

    public init(serverID: String) {
        self.serverID = serverID
    }
}

public enum TransportError: Error, Equatable {
    case deterministicFailure
}

public protocol MessageTransport: Sendable {
    func send(_ message: Message, isRetry: Bool) async throws -> DeliveryReceipt
}

public struct MockMessageTransport: MessageTransport {
    private let delayNanoseconds: UInt64

    public init(delayNanoseconds: UInt64 = 700_000_000) {
        self.delayNanoseconds = delayNanoseconds
    }

    public func send(_ message: Message, isRetry: Bool) async throws -> DeliveryReceipt {
        try await Task.sleep(nanoseconds: delayNanoseconds)

        if message.text == "/fail", !isRetry {
            throw TransportError.deterministicFailure
        }

        return DeliveryReceipt(serverID: "srv-\(message.id.short.lowercased())")
    }
}

@MainActor
public final class DeliveryCoordinator {
    private let repository: MessageRepository
    private let transport: any MessageTransport
    private let record: (String) -> Void

    public init(
        repository: MessageRepository,
        transport: any MessageTransport,
        record: @escaping (String) -> Void = { _ in }
    ) {
        self.repository = repository
        self.transport = transport
        self.record = record
    }

    public func deliver(
        messageID: UUID,
        isRetry: Bool = false,
        stateDidChange: @MainActor () -> Void = {}
    ) async {
        guard let message = repository.message(id: messageID) else { return }

        repository.markSending(id: messageID)
        record("Transport start id=\(messageID.short) retry=\(isRetry)")
        stateDidChange()

        do {
            let receipt = try await transport.send(message, isRetry: isRetry)
            record("Transport success id=\(messageID.short)")
            repository.markSent(id: messageID, serverID: receipt.serverID)
        } catch {
            record("Transport failure id=\(messageID.short) error=\(error)")
            repository.markFailed(id: messageID)
        }

        stateDidChange()
    }
}


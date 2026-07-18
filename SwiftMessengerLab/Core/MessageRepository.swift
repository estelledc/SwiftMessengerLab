import Foundation

@MainActor
public final class MessageRepository {
    private var snapshotValue: InboxSnapshot
    private let record: (String) -> Void

    public init(snapshot: InboxSnapshot, record: @escaping (String) -> Void = { _ in }) {
        snapshotValue = snapshot
        self.record = record
    }

    public var conversations: [Conversation] {
        snapshotValue.conversations
    }

    public var snapshot: InboxSnapshot {
        snapshotValue
    }

    public func conversation(id: UUID) -> Conversation? {
        snapshotValue.conversations.first { $0.id == id }
    }

    public func messages(conversationID: UUID) -> [Message] {
        snapshotValue.messages
            .filter { $0.conversationID == conversationID }
            .sorted { $0.createdAt < $1.createdAt }
    }

    public func message(id: UUID) -> Message? {
        snapshotValue.messages.first { $0.id == id }
    }

    @discardableResult
    public func enqueueOutgoing(
        text: String,
        conversationID: UUID,
        id: UUID = UUID(),
        date: Date = Date()
    ) -> Message {
        let message = Message(
            id: id,
            conversationID: conversationID,
            author: .me,
            text: text,
            createdAt: date,
            deliveryState: .queued
        )
        snapshotValue.messages.append(message)
        updateConversationPreview(conversationID: conversationID, text: text)
        record("Repository enqueue id=\(id.short) state=queued")
        return message
    }

    public func markSending(id: UUID) {
        mutateMessage(id: id) {
            $0.deliveryState = .sending
            $0.serverID = nil
        }
        record("Repository update id=\(id.short) state=sending")
    }

    public func markSent(id: UUID, serverID: String) {
        mutateMessage(id: id) {
            $0.deliveryState = .sent
            $0.serverID = serverID
        }
        record("Repository update id=\(id.short) state=sent serverID=\(serverID)")
    }

    public func markFailed(id: UUID) {
        mutateMessage(id: id) {
            $0.deliveryState = .failed
            $0.serverID = nil
        }
        record("Repository update id=\(id.short) state=failed")
    }

    public func markConversationRead(id: UUID) {
        guard let index = snapshotValue.conversations.firstIndex(where: { $0.id == id }) else { return }
        snapshotValue.conversations[index].unreadCount = 0
        record("Repository conversation id=\(id.short) unread=0")
    }

    public func reset(to snapshot: InboxSnapshot) {
        snapshotValue = snapshot
        record(
            "Repository reset conversations=\(snapshot.conversations.count) "
                + "messages=\(snapshot.messages.count)"
        )
    }

    @discardableResult
    public func recoverInterruptedOutgoingMessages() -> [UUID] {
        var recoveredIDs: [UUID] = []

        for index in snapshotValue.messages.indices {
            let message = snapshotValue.messages[index]
            guard
                message.author == .me,
                message.deliveryState == .queued || message.deliveryState == .sending
            else { continue }

            snapshotValue.messages[index].deliveryState = .failed
            snapshotValue.messages[index].serverID = nil
            recoveredIDs.append(message.id)
            record(
                "Repository recover id=\(message.id.short) "
                    + "from=\(message.deliveryState.rawValue) state=failed"
            )
        }

        return recoveredIDs
    }

    private func mutateMessage(id: UUID, mutation: (inout Message) -> Void) {
        guard let index = snapshotValue.messages.firstIndex(where: { $0.id == id }) else { return }
        mutation(&snapshotValue.messages[index])
    }

    private func updateConversationPreview(conversationID: UUID, text: String) {
        guard let index = snapshotValue.conversations.firstIndex(where: { $0.id == conversationID }) else { return }
        snapshotValue.conversations[index].lastMessagePreview = text
    }
}

public extension UUID {
    var short: String {
        String(uuidString.prefix(8))
    }
}

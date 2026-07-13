import Foundation

public enum MessageAuthor: String, Codable, Hashable, Sendable {
    case me
    case teammate
}

public enum DeliveryState: String, Codable, Hashable, Sendable {
    case received
    case queued
    case sending
    case sent
    case failed

    public var displayText: String {
        switch self {
        case .received: return "received"
        case .queued: return "queued"
        case .sending: return "sending"
        case .sent: return "sent"
        case .failed: return "failed · tap to retry"
        }
    }
}

public struct Conversation: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var lastMessagePreview: String
    public var unreadCount: Int

    public init(id: UUID, title: String, lastMessagePreview: String, unreadCount: Int) {
        self.id = id
        self.title = title
        self.lastMessagePreview = lastMessagePreview
        self.unreadCount = unreadCount
    }
}

public struct Message: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let conversationID: UUID
    public let author: MessageAuthor
    public let text: String
    public let createdAt: Date
    public var deliveryState: DeliveryState
    public var serverID: String?

    public init(
        id: UUID,
        conversationID: UUID,
        author: MessageAuthor,
        text: String,
        createdAt: Date,
        deliveryState: DeliveryState,
        serverID: String? = nil
    ) {
        self.id = id
        self.conversationID = conversationID
        self.author = author
        self.text = text
        self.createdAt = createdAt
        self.deliveryState = deliveryState
        self.serverID = serverID
    }
}

public struct InboxSnapshot: Codable, Equatable, Sendable {
    public var conversations: [Conversation]
    public var messages: [Message]

    public init(conversations: [Conversation], messages: [Message]) {
        self.conversations = conversations
        self.messages = messages
    }
}

public enum SampleInbox {
    public static let designID = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    public static let iosID = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    public static let lunchID = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!

    public static let snapshot = InboxSnapshot(
        conversations: [
            Conversation(
                id: designID,
                title: "Design Study Group",
                lastMessagePreview: "Try the deterministic failure path.",
                unreadCount: 2
            ),
            Conversation(
                id: iosID,
                title: "iOS Learning Lab",
                lastMessagePreview: "What owns the message state?",
                unreadCount: 0
            ),
            Conversation(
                id: lunchID,
                title: "Weekend Hike",
                lastMessagePreview: "Meet at the south gate at 09:00.",
                unreadCount: 1
            )
        ],
        messages: [
            Message(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
                conversationID: designID,
                author: .teammate,
                text: "Send /fail to observe retry without a real server.",
                createdAt: Date(timeIntervalSince1970: 1_786_000_000),
                deliveryState: .received
            ),
            Message(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000002")!,
                conversationID: iosID,
                author: .teammate,
                text: "Predict the state order before tapping Send.",
                createdAt: Date(timeIntervalSince1970: 1_786_000_100),
                deliveryState: .received
            ),
            Message(
                id: UUID(uuidString: "20000000-0000-0000-0000-000000000003")!,
                conversationID: lunchID,
                author: .teammate,
                text: "The sample data is fictional and stored locally.",
                createdAt: Date(timeIntervalSince1970: 1_786_000_200),
                deliveryState: .received
            )
        ]
    )
}


import Foundation

public enum InboxCacheBootstrapSource: String, Codable, Equatable, Sendable {
    case cached
    case seededMissingCache
    case repairedInvalidCache
}

public struct InboxCacheBootstrapResult: Codable, Equatable, Sendable {
    public let snapshot: InboxSnapshot
    public let source: InboxCacheBootstrapSource

    public init(snapshot: InboxSnapshot, source: InboxCacheBootstrapSource) {
        self.snapshot = snapshot
        self.source = source
    }
}

public struct JSONInboxCache: Sendable {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> InboxSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(InboxSnapshot.self, from: data)
    }

    /// Produces a durable startup snapshot.
    /// Missing caches are seeded; invalid caches are atomically replaced with the supplied seed.
    public func loadOrRepair(seed: InboxSnapshot) throws -> InboxCacheBootstrapResult {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            try save(seed)
            return InboxCacheBootstrapResult(snapshot: seed, source: .seededMissingCache)
        }

        do {
            guard let snapshot = try load() else {
                try save(seed)
                return InboxCacheBootstrapResult(snapshot: seed, source: .seededMissingCache)
            }
            return InboxCacheBootstrapResult(snapshot: snapshot, source: .cached)
        } catch {
            try save(seed)
            return InboxCacheBootstrapResult(snapshot: seed, source: .repairedInvalidCache)
        }
    }

    public func save(_ snapshot: InboxSnapshot) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
    }
}

import Foundation

@MainActor
final class AppEnvironment {
    let log: LabLogStore
    let cache: JSONInboxCache
    let repository: MessageRepository
    let delivery: DeliveryCoordinator

    private init(
        log: LabLogStore,
        cache: JSONInboxCache,
        repository: MessageRepository,
        delivery: DeliveryCoordinator
    ) {
        self.log = log
        self.cache = cache
        self.repository = repository
        self.delivery = delivery
    }

    static func makeDefault() -> AppEnvironment {
        let log = LabLogStore.shared
        let fileURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SwiftMessengerLab", isDirectory: true)
            .appendingPathComponent("inbox.json")
        let cache = JSONInboxCache(fileURL: fileURL)

        if ProcessInfo.processInfo.arguments.contains("--reset-cache") {
            try? FileManager.default.removeItem(at: fileURL)
            log.record(.cache, "Cache reset by launch argument")
        }

        let initialSnapshot: InboxSnapshot
        do {
            if let cached = try cache.load() {
                initialSnapshot = cached
                log.record(.cache, "Cache load success messages=\(cached.messages.count)")
            } else {
                initialSnapshot = SampleInbox.snapshot
                log.record(.cache, "Cache empty -> use public sample data")
            }
        } catch {
            initialSnapshot = SampleInbox.snapshot
            log.record(.cache, "Cache load failed -> fallback to sample error=\(error)")
        }

        let repository = MessageRepository(snapshot: initialSnapshot) { message in
            log.record(.repository, message)
        }
        let delivery = DeliveryCoordinator(
            repository: repository,
            transport: MockMessageTransport()
        ) { message in
            log.record(.transport, message)
        }

        return AppEnvironment(
            log: log,
            cache: cache,
            repository: repository,
            delivery: delivery
        )
    }

    func persist() {
        do {
            try cache.save(repository.snapshot)
            log.record(.cache, "Cache save messages=\(repository.snapshot.messages.count)")
        } catch {
            log.record(.cache, "Cache save failed error=\(error)")
        }
    }
}

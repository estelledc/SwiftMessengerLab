import Foundation

enum LabLogCategory: String, CaseIterable {
    case lifecycle = "Lifecycle"
    case ui = "UI"
    case repository = "Repository"
    case transport = "Transport"
    case cache = "Cache"
    case learning = "Learning"
}

struct LabLogEvent: Identifiable {
    let id = UUID()
    let date: Date
    let category: LabLogCategory
    let message: String
}

@MainActor
final class LabLogStore {
    static let shared = LabLogStore()

    private(set) var events: [LabLogEvent] = []

    private init() {}

    func record(_ category: LabLogCategory, _ message: String) {
        let event = LabLogEvent(date: Date(), category: category, message: message)
        events.append(event)
        print("[\(category.rawValue)] \(message)")
    }

    func clear() {
        events.removeAll()
        print("[UI] Logs cleared")
    }
}

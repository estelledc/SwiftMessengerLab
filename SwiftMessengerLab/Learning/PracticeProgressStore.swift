import Foundation

@MainActor
final class PracticeProgressStore {
    static let shared = PracticeProgressStore()

    private let defaults: UserDefaults
    private let key = "learning.practice-progress.v2"
    private let legacyKey = "learning.practice-progress.v1"
    private(set) var progress: PracticeProgress

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PracticeProgress.self, from: data) {
            progress = decoded
        } else if let data = defaults.data(forKey: legacyKey),
                  var decoded = try? JSONDecoder().decode(PracticeProgress.self, from: data) {
            decoded.migrateLegacyExperimentIDs(LearningCatalog.legacyExperimentMapping)
            progress = decoded
            if let migratedData = try? JSONEncoder().encode(decoded) {
                defaults.set(migratedData, forKey: key)
            }
        } else {
            progress = PracticeProgress()
        }

        if ProcessInfo.processInfo.arguments.contains("--reset-learning-progress") {
            resetLearningProgress()
        }
    }

    func recordOperation(experimentID: String) {
        progress.recordOperation(experimentID: experimentID)
        save()
    }

    func recordAnswers(lessonID: Int) {
        progress.recordAnswers(lessonID: lessonID)
        save()
    }

    func resetLearningProgress() {
        progress = PracticeProgress()
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: legacyKey)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: key)
    }
}

import Foundation

public enum SwiftTypeKind: String, CaseIterable, Codable, Sendable {
    case `class`
    case `struct`
    case `enum`
    case `protocol`
}

public enum PropertyAccess: String, Codable, Sendable {
    case readWrite = "get / set"
    case getOnly = "get-only"
}

/// A finite whitelist of renderers. Metadata can select a renderer, but cannot mutate arbitrary objects.
public enum ExperimentControl: String, CaseIterable, Codable, Sendable {
    case valueStepper
    case propertyObserver
    case text
    case valueReference
    case stateMachine
    case ownership
    case foundation
    case concurrency
    case navigation
    case viewAppearance
    case button
    case textInput
    case collection
    case dictionary
    case repository
}

/// Whether an entry executes the named target or only reuses a nearby interaction model.
public enum ExperimentEvidenceKind: String, CaseIterable, Codable, Sendable {
    case directWorkload
    case relatedObservation
}

public struct PropertyLesson: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let type: String
    public let access: PropertyAccess
    public let defaultValue: String
    public let mutableRange: String
    public let observationQuestion: String

    public init(
        name: String,
        type: String,
        access: PropertyAccess,
        defaultValue: String,
        mutableRange: String,
        observationQuestion: String
    ) {
        id = name
        self.name = name
        self.type = type
        self.access = access
        self.defaultValue = defaultValue
        self.mutableRange = mutableRange
        self.observationQuestion = observationQuestion
    }
}

public struct MethodLesson: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let signature: String
    public let input: String
    public let output: String
    public let sideEffect: String
    public let triggeredBy: String
    public let recommendedBreakpoint: String

    public init(
        signature: String,
        input: String,
        output: String,
        sideEffect: String,
        triggeredBy: String,
        recommendedBreakpoint: String
    ) {
        id = signature
        self.signature = signature
        self.input = input
        self.output = output
        self.sideEffect = sideEffect
        self.triggeredBy = triggeredBy
        self.recommendedBreakpoint = recommendedBreakpoint
    }
}

public struct TypeMetadata: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let kind: SwiftTypeKind
    public let module: String
    public let inheritance: [String]
    public let conformances: [String]
    public let relatedTypeIDs: [String]
    public let purpose: String
    public let analogy: String
    public let createdBy: String
    public let ownedBy: String
    public let releasedWhen: String
    public let properties: [PropertyLesson]
    public let methods: [MethodLesson]
    public let experimentID: String

    public init(
        id: String,
        name: String,
        kind: SwiftTypeKind,
        module: String,
        inheritance: [String] = [],
        conformances: [String] = [],
        relatedTypeIDs: [String] = [],
        purpose: String,
        analogy: String,
        createdBy: String,
        ownedBy: String,
        releasedWhen: String,
        properties: [PropertyLesson],
        methods: [MethodLesson],
        experimentID: String
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.module = module
        self.inheritance = inheritance
        self.conformances = conformances
        self.relatedTypeIDs = relatedTypeIDs
        self.purpose = purpose
        self.analogy = analogy
        self.createdBy = createdBy
        self.ownedBy = ownedBy
        self.releasedWhen = releasedWhen
        self.properties = properties
        self.methods = methods
        self.experimentID = experimentID
    }
}

/// Grammar and language mechanisms are not forced into class/struct/enum/protocol cards.
public struct LanguageConcept: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let analogy: String
    public let definition: String
    public let minimalExample: String
    public let experimentID: String
    public let retrievalQuestion: String

    public init(
        id: String,
        name: String,
        analogy: String,
        definition: String,
        minimalExample: String,
        experimentID: String,
        retrievalQuestion: String
    ) {
        self.id = id
        self.name = name
        self.analogy = analogy
        self.definition = definition
        self.minimalExample = minimalExample
        self.experimentID = experimentID
        self.retrievalQuestion = retrievalQuestion
    }
}

public struct ExperimentSourceCue: Codable, Equatable, Sendable {
    public let file: String
    public let symbol: String

    public init(file: String, symbol: String) {
        self.file = file
        self.symbol = symbol
    }

    public var displayText: String {
        "\(file) · \(symbol)"
    }
}

/// Metadata shared by the App and docs.
/// The App renders goal/source/action/docs; expected results and LLDB details stay in docs.
public struct ExperimentConsoleDescriptor: Codable, Equatable, Sendable {
    public let goal: String
    public let sourceCue: ExperimentSourceCue
    public let xcodeAction: String
    public let expectedResult: String
    public let docsPath: String

    public init(
        goal: String,
        sourceCue: ExperimentSourceCue,
        xcodeAction: String,
        expectedResult: String,
        docsPath: String
    ) {
        self.goal = goal
        self.sourceCue = sourceCue
        self.xcodeAction = xcodeAction
        self.expectedResult = expectedResult
        self.docsPath = docsPath
    }
}

public struct LearningExperiment: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let targetTypeID: String?
    public let targetConceptID: String?
    public let title: String
    public let control: ExperimentControl
    public let evidenceKind: ExperimentEvidenceKind
    public let evidenceToken: String?
    public let targetEvidence: String
    public let console: ExperimentConsoleDescriptor
    public let compilerSample: String?

    public init(
        id: String,
        targetTypeID: String? = nil,
        targetConceptID: String? = nil,
        title: String,
        control: ExperimentControl,
        evidenceKind: ExperimentEvidenceKind,
        evidenceToken: String?,
        targetEvidence: String,
        console: ExperimentConsoleDescriptor,
        compilerSample: String? = nil
    ) {
        self.id = id
        self.targetTypeID = targetTypeID
        self.targetConceptID = targetConceptID
        self.title = title
        self.control = control
        self.evidenceKind = evidenceKind
        self.evidenceToken = evidenceToken
        self.targetEvidence = targetEvidence
        self.console = console
        self.compilerSample = compilerSample
    }


    public var recordsOperationEvidence: Bool {
        evidenceKind == .directWorkload && evidenceToken != nil
    }
}

public struct DictionaryWorkloadResult: Equatable, Sendable {
    public let previousQueuedCount: Int?
    public let removedQueuedCount: Int?
    public let sentCount: Int
    public let failedCount: Int
    public let sortedKeys: [String]

    public init(
        previousQueuedCount: Int?,
        removedQueuedCount: Int?,
        sentCount: Int,
        failedCount: Int,
        sortedKeys: [String]
    ) {
        self.previousQueuedCount = previousQueuedCount
        self.removedQueuedCount = removedQueuedCount
        self.sentCount = sentCount
        self.failedCount = failedCount
        self.sortedKeys = sortedKeys
    }
}

/// A deterministic key/value workload shared by the App and Core tests.
public enum DictionaryEvidenceWorkload {
    public static func run() -> DictionaryWorkloadResult {
        var stateCounts = ["queued": 1, "sent": 1]
        let previousQueuedCount = stateCounts.updateValue(2, forKey: "queued")
        stateCounts["sent", default: 0] += 1
        stateCounts.merge(["failed": 1], uniquingKeysWith: +)
        let removedQueuedCount = stateCounts.removeValue(forKey: "queued")

        return DictionaryWorkloadResult(
            previousQueuedCount: previousQueuedCount,
            removedQueuedCount: removedQueuedCount,
            sentCount: stateCounts["sent"] ?? 0,
            failedCount: stateCounts["failed"] ?? 0,
            sortedKeys: stateCounts.keys.sorted()
        )
    }
}

public enum FoundationRoundTripError: Error, Equatable {
    case missingSnapshotAfterSave
}

public struct FoundationRoundTripResult: Equatable, Sendable {
    public let probeID: UUID
    public let completedAt: Date
    public let fileURL: URL
    public let byteCount: Int
    public let restoredSnapshot: InboxSnapshot

    public init(
        probeID: UUID,
        completedAt: Date,
        fileURL: URL,
        byteCount: Int,
        restoredSnapshot: InboxSnapshot
    ) {
        self.probeID = probeID
        self.completedAt = completedAt
        self.fileURL = fileURL
        self.byteCount = byteCount
        self.restoredSnapshot = restoredSnapshot
    }
}

/// Owns one temporary JSON fixture. Reset and deinit both remove the owned directory.
public final class FoundationRoundTripProbe {
    public let probeID: UUID
    public let directoryURL: URL
    public let fileURL: URL

    public init(
        rootDirectory: URL = FileManager.default.temporaryDirectory,
        probeID: UUID = UUID()
    ) {
        self.probeID = probeID
        directoryURL = rootDirectory.appendingPathComponent(
            "swiftmessengerlab-foundation-probe-\(probeID.uuidString)",
            isDirectory: true
        )
        fileURL = directoryURL.appendingPathComponent("inbox.json")
    }

    public var fixtureExists: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    @discardableResult
    public func run(snapshot: InboxSnapshot) throws -> FoundationRoundTripResult {
        reset()
        let cache = JSONInboxCache(fileURL: fileURL)
        try cache.save(snapshot)
        let data = try Data(contentsOf: fileURL)
        guard let restoredSnapshot = try cache.load() else {
            throw FoundationRoundTripError.missingSnapshotAfterSave
        }
        return FoundationRoundTripResult(
            probeID: probeID,
            completedAt: Date(),
            fileURL: fileURL,
            byteCount: data.count,
            restoredSnapshot: restoredSnapshot
        )
    }

    public func reset() {
        try? FileManager.default.removeItem(at: directoryURL)
    }

    deinit {
        reset()
    }
}

public struct LessonDefinition: Identifiable, Codable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let durationMinutes: ClosedRange<Int>
    public let prerequisites: [Int]
    public let coreAbility: String
    public let typeIDs: [String]
    public let conceptIDs: [String]
    public let primaryExperimentID: String
    public let misconceptions: [String]
    public let retrievalQuestions: [String]
    public let nextStep: String
}

public struct PracticeProgress: Codable, Equatable, Sendable {
    public private(set) var operatedExperimentIDs: Set<String>
    public private(set) var answeredLessonIDs: Set<Int>

    public init(
        operatedExperimentIDs: Set<String> = [],
        answeredLessonIDs: Set<Int> = []
    ) {
        self.operatedExperimentIDs = operatedExperimentIDs
        self.answeredLessonIDs = answeredLessonIDs
    }

    @discardableResult
    public mutating func recordOperation(experimentID: String) -> Bool {
        guard ExperimentCatalog.experiment(id: experimentID)?.recordsOperationEvidence == true else {
            return false
        }
        operatedExperimentIDs.insert(experimentID)
        return true
    }

    public mutating func recordAnswers(lessonID: Int) {
        answeredLessonIDs.insert(lessonID)
    }

    public mutating func migrateLegacyExperimentIDs(_ mapping: [String: String]) {
        for legacyID in operatedExperimentIDs {
            if let currentID = mapping[legacyID],
               ExperimentCatalog.experiment(id: currentID)?.recordsOperationEvidence == true {
                operatedExperimentIDs.insert(currentID)
            }
        }
    }

    public func hasOperated(_ experimentID: String) -> Bool {
        ExperimentCatalog.experiment(id: experimentID)?.recordsOperationEvidence == true
            && operatedExperimentIDs.contains(experimentID)
    }

    public func hasAnswered(_ lessonID: Int) -> Bool {
        answeredLessonIDs.contains(lessonID)
    }
}

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

public struct LearningExperiment: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let targetTypeID: String?
    public let targetConceptID: String?
    public let title: String
    public let control: ExperimentControl
    public let predictionPrompt: String
    public let appInstructions: String
    public let observationPrompt: String
    public let resetExpectation: String
    public let lldbCommand: String
    public let sourceFile: String
    public let sourceChange: String
    public let compilerSample: String?

    public init(
        id: String,
        targetTypeID: String? = nil,
        targetConceptID: String? = nil,
        title: String,
        control: ExperimentControl,
        predictionPrompt: String,
        appInstructions: String,
        observationPrompt: String,
        resetExpectation: String,
        lldbCommand: String,
        sourceFile: String,
        sourceChange: String,
        compilerSample: String? = nil
    ) {
        self.id = id
        self.targetTypeID = targetTypeID
        self.targetConceptID = targetConceptID
        self.title = title
        self.control = control
        self.predictionPrompt = predictionPrompt
        self.appInstructions = appInstructions
        self.observationPrompt = observationPrompt
        self.resetExpectation = resetExpectation
        self.lldbCommand = lldbCommand
        self.sourceFile = sourceFile
        self.sourceChange = sourceChange
        self.compilerSample = compilerSample
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

    public mutating func recordOperation(experimentID: String) {
        operatedExperimentIDs.insert(experimentID)
    }

    public mutating func recordAnswers(lessonID: Int) {
        answeredLessonIDs.insert(lessonID)
    }

    public mutating func migrateLegacyExperimentIDs(_ mapping: [String: String]) {
        for legacyID in operatedExperimentIDs {
            if let currentID = mapping[legacyID] {
                operatedExperimentIDs.insert(currentID)
            }
        }
    }

    public func hasOperated(_ experimentID: String) -> Bool {
        operatedExperimentIDs.contains(experimentID)
    }

    public func hasAnswered(_ lessonID: Int) -> Bool {
        answeredLessonIDs.contains(lessonID)
    }
}

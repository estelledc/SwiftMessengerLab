import Foundation

public struct PublishedTypeCatalogDocument: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let source: String
    public let cards: [PublishedTypeCard]
}

public struct PublishedTypeCard: Codable, Equatable, Sendable {
    public let metadata: TypeMetadata
    public let lessons: [PublishedLessonReference]
    public let experiment: PublishedExperimentReference
}

public struct PublishedLessonReference: Codable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let coreAbility: String
}

public struct PublishedExperimentReference: Codable, Equatable, Sendable {
    public let id: String
    public let control: ExperimentControl
    public let sourceFile: String
    public let compilerSample: String?
}

/// The deterministic, public projection consumed by the GitHub Pages type explorer.
/// Full experiment instructions remain in the app because the website cannot execute App, LLDB, or source edits.
public enum PublishedTypeCatalog {
    public static let document: PublishedTypeCatalogDocument = {
        let cards = TypeCatalog.all.map { metadata -> PublishedTypeCard in
            guard let experiment = ExperimentCatalog.experiment(id: metadata.experimentID) else {
                preconditionFailure("Missing experiment for published type \(metadata.id)")
            }

            let lessons = LearningCatalog.lessons
                .filter { $0.typeIDs.contains(metadata.id) }
                .map {
                    PublishedLessonReference(
                        id: $0.id,
                        title: $0.title,
                        coreAbility: $0.coreAbility
                    )
                }

            return PublishedTypeCard(
                metadata: metadata,
                lessons: lessons,
                experiment: PublishedExperimentReference(
                    id: experiment.id,
                    control: experiment.control,
                    sourceFile: experiment.sourceFile,
                    compilerSample: experiment.compilerSample
                )
            )
        }

        return PublishedTypeCatalogDocument(
            schemaVersion: 1,
            source: "SwiftMessengerLab/Core/LearningCatalog.swift",
            cards: cards
        )
    }()
}

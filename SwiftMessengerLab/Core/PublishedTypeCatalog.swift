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
    public let sourceSymbol: String
    public let xcodeAction: String
    public let docsPath: String
    public let compilerSample: String?
}

/// The deterministic, public projection consumed by the GitHub Pages type explorer.
/// The App and website share only the compact console contract. Full instructions live in docs.
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
                    sourceFile: experiment.console.sourceCue.file,
                    sourceSymbol: experiment.console.sourceCue.symbol,
                    xcodeAction: experiment.console.xcodeAction,
                    docsPath: experiment.console.docsPath,
                    compilerSample: experiment.compilerSample
                )
            )
        }

        return PublishedTypeCatalogDocument(
            schemaVersion: 2,
            source: "SwiftMessengerLab/Core/LearningCatalog.swift",
            cards: cards
        )
    }()
}

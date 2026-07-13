import Foundation
import Testing
@testable import SwiftMessengerCore

@MainActor
struct SwiftMessengerCoreTests {
    @Test
    func successfulDeliveryKeepsIdentityAndAddsServerID() async {
        let repository = MessageRepository(snapshot: SampleInbox.snapshot)
        let message = repository.enqueueOutgoing(
            text: "hello",
            conversationID: SampleInbox.iosID,
            id: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!
        )
        let coordinator = DeliveryCoordinator(
            repository: repository,
            transport: MockMessageTransport(delayNanoseconds: 0)
        )

        await coordinator.deliver(messageID: message.id)

        let delivered = repository.message(id: message.id)
        #expect(delivered?.id == message.id)
        #expect(delivered?.deliveryState == .sent)
        #expect(delivered?.serverID == "srv-30000000")
    }

    @Test
    func deterministicFailureCanRetryWithoutDuplicatingMessage() async {
        let repository = MessageRepository(snapshot: SampleInbox.snapshot)
        let message = repository.enqueueOutgoing(
            text: "/fail",
            conversationID: SampleInbox.designID,
            id: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!
        )
        let coordinator = DeliveryCoordinator(
            repository: repository,
            transport: MockMessageTransport(delayNanoseconds: 0)
        )

        await coordinator.deliver(messageID: message.id)
        #expect(repository.message(id: message.id)?.deliveryState == .failed)

        await coordinator.deliver(messageID: message.id, isRetry: true)
        #expect(repository.message(id: message.id)?.deliveryState == .sent)
        #expect(repository.messages(conversationID: SampleInbox.designID).filter { $0.id == message.id }.count == 1)
    }

    @Test
    func cacheRoundTripPreservesSnapshot() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let cache = JSONInboxCache(fileURL: directory.appendingPathComponent("inbox.json"))

        try cache.save(SampleInbox.snapshot)
        let restored = try cache.load()

        #expect(restored == SampleInbox.snapshot)
        try? FileManager.default.removeItem(at: directory)
    }

    @Test
    func learningCatalogHasTwentyRetrievalFirstLessons() {
        let lessons = LearningCatalog.lessons

        #expect(lessons.count == 20)
        #expect(Set(lessons.map(\.id)) == Set(1...20))
        #expect(lessons.allSatisfy { $0.durationMinutes == 30...45 })
        #expect(lessons[0].typeIDs.isEmpty)
        #expect(!lessons[0].conceptIDs.isEmpty)
        #expect(lessons.dropFirst().allSatisfy { !$0.typeIDs.isEmpty })
        #expect(lessons.allSatisfy { $0.retrievalQuestions.count == 3 })
        #expect(lessons.allSatisfy { ExperimentCatalog.byID[$0.primaryExperimentID] != nil })
    }

    @Test
    func typeCatalogHasFiftyTwoUniqueAccurateCardsAndResolvableRelations() throws {
        let types = TypeCatalog.all
        let ids = Set(types.map(\.id))

        #expect(types.count == 52)
        #expect(ids.count == 52)
        #expect(types.allSatisfy { SwiftTypeKind.allCases.contains($0.kind) })
        #expect(types.flatMap(\.relatedTypeIDs).allSatisfy(ids.contains))
        #expect(LearningCatalog.lessons.flatMap(\.typeIDs).allSatisfy(ids.contains))
        #expect(TypeCatalog.type(id: "UIView")?.kind == .class)
        #expect(TypeCatalog.type(id: "Array")?.kind == .struct)
        #expect(TypeCatalog.type(id: "DeliveryState")?.kind == .enum)
        #expect(TypeCatalog.type(id: "MessageTransport")?.kind == .protocol)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let publishedData = try Data(
            contentsOf: repositoryRoot.appendingPathComponent("docs/assets/type-catalog.json")
        )
        let published = try JSONDecoder().decode(PublishedTypeCatalogDocument.self, from: publishedData)
        #expect(published == PublishedTypeCatalog.document)
    }

    @Test
    func everyTypeAndConceptHasAThreeLayerExperiment() {
        for metadata in TypeCatalog.all {
            #expect(!metadata.purpose.isEmpty)
            #expect(!metadata.analogy.isEmpty)
            #expect(!metadata.methods.isEmpty)
            #expect(metadata.properties.allSatisfy { !$0.observationQuestion.isEmpty })
            #expect(metadata.methods.allSatisfy { !$0.recommendedBreakpoint.isEmpty })

            let experiment = ExperimentCatalog.experiment(id: metadata.experimentID)
            #expect(experiment?.targetTypeID == metadata.id)
            #expect(experiment?.targetConceptID == nil)
            #expect(!(experiment?.appInstructions.isEmpty ?? true))
            #expect(!(experiment?.lldbCommand.isEmpty ?? true))
            #expect(!(experiment?.sourceFile.isEmpty ?? true))
            #expect(!(experiment?.sourceChange.isEmpty ?? true))
        }

        for concept in LanguageConceptCatalog.all {
            let experiment = ExperimentCatalog.experiment(id: concept.experimentID)
            #expect(experiment?.targetConceptID == concept.id)
            #expect(!(concept.minimalExample.isEmpty))
        }
    }

    @Test
    func lessonPrerequisitesExistAndContainNoCycle() {
        let lessons = Dictionary(uniqueKeysWithValues: LearningCatalog.lessons.map { ($0.id, $0) })
        #expect(lessons.values.flatMap(\.prerequisites).allSatisfy { lessons[$0] != nil })

        enum VisitState { case visiting, visited }
        var states: [Int: VisitState] = [:]
        func visit(_ id: Int) -> Bool {
            if states[id] == .visiting { return false }
            if states[id] == .visited { return true }
            states[id] = .visiting
            guard let lesson = lessons[id], lesson.prerequisites.allSatisfy(visit) else { return false }
            states[id] = .visited
            return true
        }

        #expect(lessons.keys.allSatisfy(visit))
    }

    @Test
    func practiceProgressNeverClaimsMasteryOrMutatesMessengerData() {
        var progress = PracticeProgress()
        let originalSnapshot = SampleInbox.snapshot
        progress.recordOperation(experimentID: "type.UIView")

        #expect(progress.hasOperated("type.UIView"))
        #expect(!progress.hasAnswered(11))
        #expect(SampleInbox.snapshot == originalSnapshot)

        progress.recordAnswers(lessonID: 11)
        #expect(progress.hasAnswered(11))
        #expect(SampleInbox.snapshot == originalSnapshot)
    }

    @Test
    func legacyProgressMapsLessonExperimentsWithoutLosingAnswers() {
        var progress = PracticeProgress(
            operatedExperimentIDs: ["lesson-1", "lesson-11", "unknown-old-id"],
            answeredLessonIDs: [1, 11]
        )

        progress.migrateLegacyExperimentIDs(LearningCatalog.legacyExperimentMapping)

        #expect(progress.hasOperated("concept.let-var"))
        #expect(progress.hasOperated("type.UIView"))
        #expect(progress.hasOperated("unknown-old-id"))
        #expect(progress.hasAnswered(1))
        #expect(progress.hasAnswered(11))
    }
}

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
    var observedStates: [DeliveryState] = [.queued]

    await coordinator.deliver(messageID: message.id) {
      if let state = repository.message(id: message.id)?.deliveryState {
        observedStates.append(state)
      }
    }
    #expect(repository.message(id: message.id)?.deliveryState == .failed)
    #expect(observedStates == [.queued, .sending, .failed])

    await coordinator.deliver(messageID: message.id, isRetry: true) {
      if let state = repository.message(id: message.id)?.deliveryState {
        observedStates.append(state)
      }
    }
    #expect(repository.message(id: message.id)?.deliveryState == .sent)
    #expect(observedStates == [.queued, .sending, .failed, .sending, .sent])
    #expect(
      repository.messages(conversationID: SampleInbox.designID).filter { $0.id == message.id }.count
        == 1)
  }

  @Test
  func interruptedOutgoingMessagesRecoverAsRetryableWithoutChangingIdentity() {
    let queuedID = UUID(uuidString: "30000000-0000-0000-0000-000000000003")!
    let sendingID = UUID(uuidString: "30000000-0000-0000-0000-000000000004")!
    var snapshot = SampleInbox.snapshot
    snapshot.messages.append(
      Message(
        id: queuedID,
        conversationID: SampleInbox.designID,
        author: .me,
        text: "queued before termination",
        createdAt: Date(timeIntervalSince1970: 1_786_000_300),
        deliveryState: .queued
      )
    )
    snapshot.messages.append(
      Message(
        id: sendingID,
        conversationID: SampleInbox.designID,
        author: .me,
        text: "sending before termination",
        createdAt: Date(timeIntervalSince1970: 1_786_000_400),
        deliveryState: .sending
      )
    )
    let repository = MessageRepository(snapshot: snapshot)
    let originalCount = repository.snapshot.messages.count

    let recoveredIDs = repository.recoverInterruptedOutgoingMessages()

    #expect(recoveredIDs == [queuedID, sendingID])
    #expect(repository.message(id: queuedID)?.deliveryState == .failed)
    #expect(repository.message(id: sendingID)?.deliveryState == .failed)
    #expect(repository.snapshot.messages.count == originalCount)
    #expect(repository.recoverInterruptedOutgoingMessages().isEmpty)
    #expect(repository.message(id: SampleInbox.snapshot.messages[0].id)?.deliveryState == .received)
  }

  @Test
  func messengerResetRestoresExactlyThePublicSample() {
    let repository = MessageRepository(snapshot: SampleInbox.snapshot)
    _ = repository.enqueueOutgoing(
      text: "temporary message",
      conversationID: SampleInbox.designID,
      id: UUID(uuidString: "30000000-0000-0000-0000-000000000005")!
    )
    #expect(repository.snapshot != SampleInbox.snapshot)

    repository.reset(to: SampleInbox.snapshot)

    #expect(repository.snapshot == SampleInbox.snapshot)
    repository.reset(to: SampleInbox.snapshot)
    #expect(repository.snapshot == SampleInbox.snapshot)
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
  func foundationProbeResetAndDeinitDeleteOwnedFixture() throws {
    let root = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    var probe: FoundationRoundTripProbe? = FoundationRoundTripProbe(
      rootDirectory: root,
      probeID: UUID(uuidString: "61000000-0000-0000-0000-000000000001")!
    )
    let directoryURL = try #require(probe?.directoryURL)
    let fileURL = try #require(probe?.fileURL)

    let firstResult = try #require(probe).run(snapshot: SampleInbox.snapshot)
    #expect(firstResult.restoredSnapshot == SampleInbox.snapshot)
    #expect(firstResult.byteCount > 0)
    #expect(FileManager.default.fileExists(atPath: fileURL.path))

    probe?.reset()
    #expect(!FileManager.default.fileExists(atPath: directoryURL.path))

    _ = try #require(probe).run(snapshot: SampleInbox.snapshot)
    #expect(FileManager.default.fileExists(atPath: fileURL.path))
    probe = nil
    #expect(!FileManager.default.fileExists(atPath: directoryURL.path))
    try? FileManager.default.removeItem(at: root)
  }

  @Test
  func dictionaryWorkloadExecutesKeySpecificMutationAPIs() {
    let result = DictionaryEvidenceWorkload.run()

    #expect(result.previousQueuedCount == 1)
    #expect(result.removedQueuedCount == 2)
    #expect(result.sentCount == 2)
    #expect(result.failedCount == 1)
    #expect(result.sortedKeys == ["failed", "sent"])
  }

  @Test
  func repositoryEnqueueWorkloadAppendsQueuedMessageAndUpdatesPreview() {
    let repository = MessageRepository(snapshot: SampleInbox.snapshot)
    let beforeCount = repository.snapshot.messages.count
    let id = UUID(uuidString: "61000000-0000-0000-0000-000000000002")!

    let message = repository.enqueueOutgoing(
      text: "repository target evidence",
      conversationID: SampleInbox.designID,
      id: id,
      date: Date(timeIntervalSince1970: 1_786_001_100)
    )

    #expect(repository.snapshot.messages.count == beforeCount + 1)
    #expect(message.id == id)
    #expect(message.deliveryState == .queued)
    #expect(repository.message(id: id) == message)
    #expect(repository.conversation(id: SampleInbox.designID)?.lastMessagePreview == message.text)
  }

  @Test
  func messageTransportWorkloadDispatchesThroughProtocolExistential() async throws {
    let transport: any MessageTransport = MockMessageTransport(delayNanoseconds: 0)
    let message = Message(
      id: UUID(uuidString: "61000000-0000-0000-0000-000000000003")!,
      conversationID: SampleInbox.designID,
      author: .me,
      text: "transport target evidence",
      createdAt: Date(timeIntervalSince1970: 1_786_001_200),
      deliveryState: .sending
    )

    let receipt = try await transport.send(message, isRetry: false)

    #expect(receipt.serverID == "srv-61000000")
  }

  @Test
  func missingCacheIsSeededAndInvalidCacheIsRepairedDurably() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let fileURL = directory.appendingPathComponent("inbox.json")
    let cache = JSONInboxCache(fileURL: fileURL)

    let seeded = try cache.loadOrRepair(seed: SampleInbox.snapshot)
    #expect(seeded.source == .seededMissingCache)
    #expect(seeded.snapshot == SampleInbox.snapshot)
    #expect(try cache.load() == SampleInbox.snapshot)

    try Data("{not-valid-json".utf8).write(to: fileURL, options: .atomic)
    let repaired = try cache.loadOrRepair(seed: SampleInbox.snapshot)
    #expect(repaired.source == .repairedInvalidCache)
    #expect(repaired.snapshot == SampleInbox.snapshot)
    #expect(try cache.load() == SampleInbox.snapshot)

    let cached = try cache.loadOrRepair(seed: InboxSnapshot(conversations: [], messages: []))
    #expect(cached.source == .cached)
    #expect(cached.snapshot == SampleInbox.snapshot)
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
  func everyTypeAndConceptHasACompactConsoleExperiment() {
    #expect(ExperimentCatalog.all.count == 70)
    #expect(Set(ExperimentCatalog.all.map(\.id)).count == 70)

    let typeIDs = Set(TypeCatalog.all.map(\.id))
    let conceptIDs = Set(LanguageConceptCatalog.all.map(\.id))
    #expect(ExperimentCatalog.directTypeIDs.isSubset(of: typeIDs))
    #expect(ExperimentCatalog.directConceptIDs.isSubset(of: conceptIDs))
    #expect(ExperimentCatalog.directTypeIDs.count == 37)
    #expect(ExperimentCatalog.directConceptIDs.count == 14)

    let direct = ExperimentCatalog.all.filter { $0.evidenceKind == .directWorkload }
    let related = ExperimentCatalog.all.filter { $0.evidenceKind == .relatedObservation }
    #expect(direct.count == 51)
    #expect(related.count == 19)
    #expect(Set(direct.compactMap(\.evidenceToken)).count == direct.count)
    #expect(
      direct.allSatisfy {
        $0.evidenceToken == "target-evidence:\($0.id)"
          && $0.recordsOperationEvidence
          && $0.title.hasSuffix(" Experiment")
      })
    #expect(
      related.allSatisfy {
        $0.evidenceToken == nil
          && !$0.recordsOperationEvidence
          && $0.title.hasSuffix(" Related Observation")
          && $0.targetEvidence.contains("不写入“已操作”证据")
      })

    for metadata in TypeCatalog.all {
      #expect(!metadata.purpose.isEmpty)
      #expect(!metadata.analogy.isEmpty)
      #expect(!metadata.methods.isEmpty)
      #expect(metadata.properties.allSatisfy { !$0.observationQuestion.isEmpty })
      #expect(metadata.methods.allSatisfy { !$0.recommendedBreakpoint.isEmpty })

      let experiment = ExperimentCatalog.experiment(id: metadata.experimentID)
      #expect(experiment?.targetTypeID == metadata.id)
      #expect(experiment?.targetConceptID == nil)
      #expect(!(experiment?.console.goal.isEmpty ?? true))
      #expect(!(experiment?.console.sourceCue.file.isEmpty ?? true))
      #expect(!(experiment?.console.sourceCue.symbol.isEmpty ?? true))
      #expect(!(experiment?.console.xcodeAction.isEmpty ?? true))
      #expect(!(experiment?.console.expectedResult.isEmpty ?? true))
      #expect(experiment?.console.docsPath == "docs/experiment-cards.md")
    }

    for concept in LanguageConceptCatalog.all {
      let experiment = ExperimentCatalog.experiment(id: concept.experimentID)
      #expect(experiment?.targetConceptID == concept.id)
      #expect(!(concept.minimalExample.isEmpty))
      #expect(experiment?.console.docsPath == "docs/experiment-cards.md")
    }

    let expectedConceptControls: [String: ExperimentControl] = [
      "let-var": .valueStepper,
      "type-inference": .valueStepper,
      "stored-computed": .propertyObserver,
      "lazy-didset": .propertyObserver,
      "init-self-access": .text,
      "value-reference": .valueReference,
      "switch-exhaustiveness": .stateMachine,
      "delegate-closure-arc": .ownership,
      "codable": .foundation,
      "async-await-throws": .concurrency,
      "responder-scene-chain": .navigation,
      "auto-layout": .viewAppearance,
      "view-controller-lifecycle": .navigation,
      "target-action": .button,
      "first-responder": .textInput,
      "reuse": .collection,
      "stable-identity": .collection,
      "dependency-injection": .concurrency,
    ]
    #expect(expectedConceptControls.count == 18)
    #expect(
      expectedConceptControls.allSatisfy { id, control in
        ExperimentCatalog.experiment(id: "concept.\(id)")?.control == control
      })
    #expect(
      ExperimentCatalog.all.allSatisfy {
        !$0.console.sourceCue.symbol.hasPrefix("configure")
      })
    #expect(ExperimentCatalog.experiment(id: "type.Array")?.control == .collection)
    #expect(ExperimentCatalog.experiment(id: "type.Set")?.control == .collection)
    #expect(ExperimentCatalog.experiment(id: "type.Dictionary")?.control == .dictionary)
    #expect(ExperimentCatalog.experiment(id: "type.MessageRepository")?.control == .repository)
    #expect(ExperimentCatalog.experiment(id: "type.MessageTransport")?.control == .concurrency)
    #expect(
      ExperimentCatalog.experiment(id: "type.PropertyBox")?.console.sourceCue.symbol
        == "incrementPropertyProbe()"
    )
    #expect(
      ExperimentCatalog.experiment(id: "concept.value-reference")?.console.sourceCue.symbol
        == "mutateValueReferenceProbes()"
    )
    #expect(
      ExperimentCatalog.experiment(id: "type.MessageDraft")?.console.sourceCue.symbol
        == "applyTextProbe()"
    )
    #expect(
      ExperimentCatalog.experiment(id: "type.DeliveryState")?.console.sourceCue.symbol
        == "advanceDeliveryState()"
    )
    #expect(
      ExperimentCatalog.experiment(id: "type.Dictionary")?.console.sourceCue.symbol
        == "runDictionaryWorkload()"
    )
    #expect(
      ExperimentCatalog.experiment(id: "type.MessageRepository")?.console.sourceCue.symbol
        == "enqueueOutgoing(text:conversationID:id:date:)"
    )
    #expect(
      ExperimentCatalog.experiment(id: "type.MessageTransport")?.console.sourceCue.symbol
        == "send(_:isRetry:)"
    )
    #expect(
      ExperimentCatalog.experiment(id: "type.JSONInboxCache")?.console.sourceCue.symbol
        == "runFoundationRoundTrip()"
    )
  }

  @Test
  func everyClickableExperimentPointsToSearchableSourceAndOneXcodeAction() throws {
    let root = repositoryRoot()

    for experiment in ExperimentCatalog.all {
      let descriptor = experiment.console
      let sourceURL = root.appendingPathComponent(descriptor.sourceCue.file)
      let source = try String(contentsOf: sourceURL, encoding: .utf8)
      let symbolName =
        descriptor.sourceCue.symbol.split(separator: "(").first.map(String.init) ?? ""

      #expect(FileManager.default.fileExists(atPath: sourceURL.path))
      #expect(!symbolName.isEmpty)
      #expect(source.contains("\(symbolName)("))
      #expect(!descriptor.xcodeAction.contains("\n"))
      #expect(!descriptor.xcodeAction.contains("expr "))
      #expect(!descriptor.xcodeAction.contains("po "))
      #expect(
        FileManager.default.fileExists(
          atPath: root.appendingPathComponent(descriptor.docsPath).path
        ))
    }

    let consoleUI = try String(
      contentsOf: root.appendingPathComponent(
        "SwiftMessengerLab/Learning/ExperimentConsoleUI.swift"
      ),
      encoding: .utf8
    )
    #expect(!consoleUI.contains("descriptor.expectedResult"))
    #expect(!consoleUI.contains("configuration.subtitle"))
    #expect(!consoleUI.contains("console-result"))

    let catalogUI = try String(
      contentsOf: root.appendingPathComponent(
        "SwiftMessengerLab/Learning/LearningCatalogViewController.swift"
      ),
      encoding: .utf8
    )
    #expect(!catalogUI.contains("subtitleCell"))
    #expect(!catalogUI.contains("secondaryText"))
    #expect(!catalogUI.contains("titleForHeaderInSection"))
    #expect(!catalogUI.contains("titleForFooterInSection"))
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
    let recordedDirect = progress.recordOperation(experimentID: "type.UIView")
    let recordedRelated = progress.recordOperation(experimentID: "type.UIApplication")
    let recordedUnknown = progress.recordOperation(experimentID: "type.DoesNotExist")

    #expect(recordedDirect)
    #expect(!recordedRelated)
    #expect(!recordedUnknown)
    #expect(progress.hasOperated("type.UIView"))
    #expect(!progress.hasOperated("type.UIApplication"))
    #expect(!progress.operatedExperimentIDs.contains("type.UIApplication"))
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

    #expect(!progress.hasOperated("concept.let-var"))
    #expect(progress.hasOperated("type.UIView"))
    #expect(!progress.hasOperated("unknown-old-id"))
    #expect(progress.hasAnswered(1))
    #expect(progress.hasAnswered(11))
  }

  private func repositoryRoot() -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }
}

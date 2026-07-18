import XCTest

final class SwiftMessengerLabUITests: XCTestCase {
  private var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["--reset-cache", "--reset-learning-progress"]
    app.launch()
  }

  func testSuccessfulSendThenFailureAndRetry() throws {
    app.staticTexts["Design Study Group"].tap()

    let input = app.textFields["message-input"]
    let send = app.buttons["send-button"]
    XCTAssertTrue(input.waitForExistence(timeout: 2))

    input.tap()
    input.typeText("hello")
    send.tap()
    XCTAssertTrue(
      app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "sent · id")).firstMatch
        .waitForExistence(timeout: 3)
    )

    input.tap()
    input.typeText("/fail")
    send.tap()

    let failed = app.cells["failed-message"]
    XCTAssertTrue(failed.waitForExistence(timeout: 3))
    failed.tap()

    XCTAssertTrue(
      app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "sent · id")).element(
        boundBy: 1
      )
      .waitForExistence(timeout: 3)
    )
    XCTAssertEqual(
      app.staticTexts.matching(NSPredicate(format: "label == %@", "/fail")).count,
      1
    )
  }

  func testGuideIsACompactConsoleAndCanResetMessengerData() throws {
    app.staticTexts["Design Study Group"].tap()
    let input = app.textFields["message-input"]
    XCTAssertTrue(input.waitForExistence(timeout: 2))
    input.tap()
    input.typeText("temporary reset message")
    app.buttons["send-button"].tap()
    XCTAssertTrue(app.staticTexts["temporary reset message"].waitForExistence(timeout: 2))
    app.navigationBars["Design Study Group"].buttons.element(boundBy: 0).tap()

    app.buttons["Guide"].tap()
    XCTAssertTrue(app.buttons["guide-open-message-lab"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.buttons["guide-view-logs"].exists)
    XCTAssertTrue(app.buttons["guide-reset-messenger"].exists)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-goal").count, 1)
    XCTAssertTrue(app.staticTexts["console-source-cue"].label.contains("ChatViewController.swift"))
    XCTAssertTrue(app.staticTexts["console-source-cue"].label.contains("submit(text:)"))
    XCTAssertTrue(app.staticTexts["console-xcode-action"].label.contains("设置断点"))
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-docs-path").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-result").count, 0)
    XCTAssertEqual(app.textViews.count, 0)

    app.buttons["guide-reset-messenger"].tap()
    XCTAssertTrue(app.alerts["Reset Messenger Data?"].waitForExistence(timeout: 2))
    app.alerts.buttons["Reset"].tap()
    XCTAssertTrue(app.staticTexts["guide-result"].label.contains("public sample"))

    app.buttons["guide-open-message-lab"].tap()
    XCTAssertTrue(
      app.staticTexts["Send /fail to observe retry without a real server."]
        .waitForExistence(timeout: 2)
    )
    XCTAssertFalse(app.staticTexts["temporary reset message"].exists)
  }

  func testUIViewWhitelistChangesAndReset() throws {
    openExperiment(lesson: 11)

    let status = app.staticTexts["view-state-status"]
    XCTAssertTrue(status.waitForExistence(timeout: 2))
    XCTAssertTrue(status.label.contains("alpha = 1.00"))

    let experimentScroll = app.scrollViews.firstMatch
    let slider = app.sliders["alpha-slider"]
    scrollUntilHittable(slider, in: experimentScroll)
    slider.adjust(toNormalizedSliderPosition: 0.3)
    let orange = app.segmentedControls["color-control"].buttons["Orange"]
    scrollUntilHittable(orange, in: experimentScroll)
    orange.tap()
    let hidden = app.switches["hidden-switch"]
    scrollUntilHittable(hidden, in: experimentScroll)
    hidden.tap()
    XCTAssertTrue(status.label.contains("color = 1"))
    XCTAssertTrue(status.label.contains("isHidden = true"))

    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: experimentScroll)
    reset.tap()
    XCTAssertTrue(status.label.contains("alpha = 1.00"))
    XCTAssertTrue(status.label.contains("color = 0"))
    XCTAssertTrue(status.label.contains("isHidden = false"))
  }

  func testDisabledButtonDoesNotFireAction() throws {
    openExperiment(lesson: 16)

    let button = app.buttons["action-button"]
    let count = app.staticTexts["action-count"]
    button.tap()
    XCTAssertEqual(count.label, "action count = 1")

    app.switches["button-enabled-switch"].tap()
    XCTAssertFalse(button.isEnabled)
    button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    XCTAssertEqual(count.label, "action count = 1")
  }

  func testOwnershipRendererReleasesWeakReference() throws {
    openTypeEntry(lesson: 6, typeID: "CaptureOwner")

    let status = app.staticTexts["ownership-status"]
    XCTAssertTrue(status.waitForExistence(timeout: 2))
    app.buttons["ownership-create"].tap()
    XCTAssertTrue(status.label.contains("weak alive = true"))
    app.buttons["ownership-release"].tap()
    XCTAssertTrue(status.label.contains("weak nil = true"))

    app.buttons["ownership-create"].tap()
    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: app.scrollViews.firstMatch)
    reset.tap()
    XCTAssertTrue(app.staticTexts["ownership-status"].label.contains("owner = nil"))
    XCTAssertTrue(app.staticTexts["ownership-status"].label.contains("weak = nil"))
  }

  func testPropertyBoxRendererUsesRealComputedLazyAndDidSetState() throws {
    openExperiment(lesson: 2)

    let status = app.staticTexts["property-status"]
    XCTAssertTrue(status.waitForExistence(timeout: 2))
    XCTAssertTrue(status.label.contains("stored = 1 · doubled = 2"))
    XCTAssertTrue(status.label.contains("didSet = 0 · lazy = not read"))

    let increment = app.buttons["property-increment"]
    XCTAssertTrue(increment.waitForExistence(timeout: 2))
    increment.tap()
    XCTAssertTrue(
      status.label.contains("stored = 2 · doubled = 4"),
      "Unexpected PropertyBox status: \(status.label)"
    )
    XCTAssertTrue(
      status.label.contains("didSet = 1"),
      "Unexpected PropertyBox status: \(status.label)"
    )

    app.buttons["property-read-lazy"].tap()
    XCTAssertTrue(status.label.contains("lazy = created from stored=2"))
    increment.tap()
    XCTAssertTrue(status.label.contains("stored = 3 · doubled = 6"))
    XCTAssertTrue(status.label.contains("lazy = created from stored=2"))

    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: app.scrollViews.firstMatch)
    reset.tap()
    XCTAssertTrue(app.staticTexts["property-status"].label.contains("stored = 1 · doubled = 2"))
    XCTAssertTrue(app.staticTexts["property-status"].label.contains("didSet = 0 · lazy = not read"))
  }

  func testValueAndReferenceRendererShowsCopyVersusAlias() throws {
    openExperiment(lesson: 4)

    let status = app.staticTexts["value-reference-status"]
    XCTAssertTrue(status.waitForExistence(timeout: 2))
    XCTAssertTrue(status.label.contains("struct original = 1 · copy = 1"))
    XCTAssertTrue(status.label.contains("class original = 1 · alias = 1"))
    XCTAssertTrue(status.label.contains("same class instance = true"))

    app.buttons["value-reference-mutate"].tap()
    XCTAssertTrue(status.label.contains("struct original = 1 · copy = 2"))
    XCTAssertTrue(status.label.contains("class original = 2 · alias = 2"))

    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: app.scrollViews.firstMatch)
    reset.tap()
    XCTAssertTrue(
      app.staticTexts["value-reference-status"].label.contains("struct original = 1 · copy = 1"))
    XCTAssertTrue(
      app.staticTexts["value-reference-status"].label.contains("class original = 1 · alias = 1"))
  }

  func testDeliveryStateRendererCyclesRealEnumAndResets() throws {
    openExperiment(lesson: 5)

    let status = app.staticTexts["experiment-status"]
    let advance = app.buttons["state-advance"]
    XCTAssertEqual(status.label, "state = sending")
    advance.tap()
    XCTAssertEqual(status.label, "state = sent")
    advance.tap()
    XCTAssertEqual(status.label, "state = failed")
    advance.tap()
    XCTAssertEqual(status.label, "state = sending")

    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: app.scrollViews.firstMatch)
    reset.tap()
    XCTAssertEqual(app.staticTexts["experiment-status"].label, "state = sending")
  }

  func testFoundationRendererRoundTripsRealJSONCache() throws {
    openExperiment(lesson: 8)

    let status = app.staticTexts["foundation-status"]
    XCTAssertTrue(status.waitForExistence(timeout: 2))
    app.buttons["foundation-run"].tap()
    XCTAssertTrue(status.label.contains("inbox.json"))
    XCTAssertTrue(status.label.contains("messages = 3"))
    XCTAssertTrue(app.staticTexts["experiment-log"].label.contains("target-evidence:type.UUID"))

    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: app.scrollViews.firstMatch)
    reset.tap()
    XCTAssertEqual(app.staticTexts["foundation-status"].label, "No cache probe has run.")
  }

  func testConcurrencyRendererRunsDeterministicTransport() throws {
    openExperiment(lesson: 9)

    let status = app.staticTexts["concurrency-status"]
    XCTAssertTrue(status.waitForExistence(timeout: 2))
    app.buttons["concurrency-run"].tap()
    let scroll = app.scrollViews.firstMatch
    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: scroll)
    reset.tap()

    let resetStatus = app.staticTexts["concurrency-status"]
    XCTAssertEqual(resetStatus.label, "state = idle")
    let staleCompletion = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "label CONTAINS %@", "state = sent"),
      object: resetStatus
    )
    staleCompletion.isInverted = true
    XCTAssertEqual(XCTWaiter.wait(for: [staleCompletion], timeout: 0.4), .completed)

    let runAgain = app.buttons["concurrency-run"]
    scrollUntilHittable(runAgain, in: app.scrollViews.firstMatch)
    runAgain.tap()
    XCTAssertTrue(
      app.staticTexts.matching(
        NSPredicate(format: "label CONTAINS %@", "state = sent · srv-50000000")
      )
      .firstMatch.waitForExistence(timeout: 2)
    )
  }

  func testTextFieldDelegateAndFirstResponderLogOrder() throws {
    openExperiment(lesson: 17)

    let field = app.textFields["input-field"]
    field.tap()
    field.typeText("A\n")

    let log = app.staticTexts["experiment-log"]
    XCTAssertTrue(log.waitForExistence(timeout: 2))
    XCTAssertTrue(log.label.contains("1 delegate shouldChange"))
    XCTAssertTrue(log.label.contains("2 UIControl editingChanged"))
    XCTAssertTrue(log.label.contains("3 delegate shouldReturn"))
    XCTAssertTrue(log.label.contains("4 resignFirstResponder"))
  }

  func testNavigationPushPopKeepsProbeIdentityUntilPop() throws {
    openExperiment(lesson: 14)

    app.buttons["push-probe"].tap()
    let probe = app.staticTexts["probe-screen"]
    XCTAssertTrue(probe.waitForExistence(timeout: 2))
    XCTAssertTrue(probe.label.contains("Probe object"))
    app.navigationBars.buttons.element(boundBy: 0).tap()

    let log = app.staticTexts["experiment-log"]
    XCTAssertTrue(log.waitForExistence(timeout: 2))
    XCTAssertTrue(log.label.contains("returned from probe · same id"))
    XCTAssertTrue(log.label.contains("probe viewDidLoad"))
    XCTAssertTrue(log.label.contains("probe viewDidDisappear"))
    XCTAssertTrue(log.label.contains("probe deinit"))
  }

  func testCollectionRefreshPreservesStableUniqueIDs() throws {
    openExperiment(lesson: 19)

    let status = app.staticTexts["collection-status"]
    XCTAssertEqual(status.label, "items = 3 · unique ids = 3")
    app.buttons["collection-refresh"].tap()
    XCTAssertEqual(status.label, "items = 3 · unique ids = 3")
    app.buttons["collection-add"].tap()
    XCTAssertEqual(status.label, "items = 4 · unique ids = 4")
    app.buttons["experiment-reset"].tap()
    XCTAssertEqual(status.label, "items = 3 · unique ids = 3")
  }

  func testTypeSearchFindsCardByAPIAndOpensItsExperiment() throws {
    app.tabBars.buttons["Learn"].tap()

    let firstLesson = app.cells["lesson-1"]
    XCTAssertTrue(firstLesson.waitForExistence(timeout: 2))
    XCTAssertFalse(firstLesson.label.contains("已操作"))
    XCTAssertFalse(firstLesson.label.contains("已回答"))

    let search = app.searchFields["type-search"]
    XCTAssertTrue(search.waitForExistence(timeout: 2))
    search.tap()
    search.typeText("append")

    let stringResult = app.cells["type-search-result-String"]
    XCTAssertTrue(stringResult.waitForExistence(timeout: 2))
    let resultLabels = stringResult.descendants(matching: .staticText)
    XCTAssertEqual(resultLabels.count, 1)
    XCTAssertEqual(resultLabels.element(boundBy: 0).label, "String")
    stringResult.tap()
    XCTAssertTrue(app.navigationBars["String Experiment"].waitForExistence(timeout: 2))
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-goal").count, 1)
    XCTAssertTrue(app.staticTexts["console-source-cue"].label.contains("applyTextProbe()"))
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-xcode-action").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-docs-path").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-result").count, 0)
    let field = app.textFields["text-value-field"]
    XCTAssertTrue(field.waitForExistence(timeout: 2))
    field.tap()
    field.typeText("X")
    app.buttons["text-apply"].tap()
    XCTAssertTrue(app.staticTexts["experiment-status"].label.contains("count = 13"))
    XCTAssertTrue(app.staticTexts["experiment-status"].label.contains("isSendable = true"))

    let reset = app.buttons["experiment-reset"]
    scrollUntilHittable(reset, in: app.scrollViews.firstMatch)
    reset.tap()
    XCTAssertEqual(app.textFields["text-value-field"].value as? String, "Hello, Swift")
  }

  func testLessonExposesDistinctArrayAndDictionaryTypeCards() throws {
    app.tabBars.buttons["Learn"].tap()
    let lesson = app.cells["lesson-7"]
    scrollUntilHittable(lesson, in: app.tables.firstMatch)
    lesson.tap()

    let array = app.buttons["type-card-Array"]
    scrollUntilHittable(array, in: app.scrollViews.firstMatch)
    XCTAssertEqual(array.label, "Array Experiment")
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-goal").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-source-cue").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-xcode-action").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-docs-path").count, 1)
    XCTAssertEqual(app.staticTexts.matching(identifier: "console-result").count, 0)
    array.tap()
    XCTAssertTrue(app.navigationBars["Array Experiment"].waitForExistence(timeout: 2))
    app.navigationBars.buttons.element(boundBy: 0).tap()

    let dictionary = app.buttons["type-card-Dictionary"]
    scrollUntilHittable(dictionary, in: app.scrollViews.firstMatch)
    XCTAssertEqual(dictionary.label, "Dictionary Experiment")
    dictionary.tap()
    XCTAssertTrue(app.navigationBars["Dictionary Experiment"].waitForExistence(timeout: 2))

    app.buttons["dictionary-run"].tap()
    let status = app.staticTexts["dictionary-status"]
    XCTAssertTrue(status.label.contains("sent = 2 · failed = 1"))
    XCTAssertTrue(status.label.contains("keys = failed, sent"))
    XCTAssertTrue(
      app.staticTexts["experiment-log"].label.contains("target-evidence:type.Dictionary")
    )
  }

  func testMessageRepositoryEntryExecutesEnqueueOutgoing() throws {
    openExperiment(lesson: 20)

    XCTAssertTrue(app.navigationBars["MessageRepository Experiment"].waitForExistence(timeout: 2))
    app.buttons["repository-run"].tap()
    let status = app.staticTexts["repository-status"]
    XCTAssertTrue(status.label.contains("messages = 3 -> 4"))
    XCTAssertTrue(status.label.contains("state = queued"))
    XCTAssertTrue(status.label.contains("preview = repository evidence 4"))
    XCTAssertTrue(
      app.staticTexts["experiment-log"].label.contains(
        "target-evidence:type.MessageRepository"
      )
    )
  }

  func testMessageTransportEntryDispatchesThroughProtocolWorkload() throws {
    openExperiment(lesson: 6)

    XCTAssertTrue(app.navigationBars["MessageTransport Experiment"].waitForExistence(timeout: 2))
    app.buttons["concurrency-run"].tap()
    XCTAssertTrue(
      app.staticTexts.matching(
        NSPredicate(format: "label CONTAINS %@", "state = sent · srv-50000000")
      ).firstMatch.waitForExistence(timeout: 2)
    )
    XCTAssertTrue(
      app.staticTexts["experiment-log"].label.contains("target-evidence:type.MessageTransport")
    )
  }

  func testRelatedObservationNeverEmitsTargetEvidenceToken() throws {
    openTypeEntry(lesson: 10, typeID: "UIApplication")

    XCTAssertTrue(app.navigationBars["UIApplication Related Observation"].waitForExistence(timeout: 2))
    app.buttons["push-probe"].tap()
    XCTAssertTrue(app.staticTexts["probe-screen"].waitForExistence(timeout: 2))
    app.navigationBars.buttons.element(boundBy: 0).tap()
    let log = app.staticTexts["experiment-log"]
    XCTAssertTrue(log.label.contains("related-observation:type.UIApplication"))
    XCTAssertTrue(log.label.contains("no operated evidence"))
    XCTAssertFalse(log.label.contains("target-evidence:type.UIApplication"))
  }

  func testResetLearningProgressDoesNotDeleteMessengerMessage() throws {
    app.staticTexts["Design Study Group"].tap()
    let input = app.textFields["message-input"]
    input.tap()
    input.typeText("persists across learning reset")
    app.buttons["send-button"].tap()
    XCTAssertTrue(app.staticTexts["persists across learning reset"].waitForExistence(timeout: 3))

    app.tabBars.buttons["Learn"].tap()
    app.buttons["reset-learning-progress"].tap()
    XCTAssertTrue(app.alerts["Reset Learning Progress?"].waitForExistence(timeout: 2))
    app.alerts.buttons["Reset"].tap()

    app.tabBars.buttons["Messenger"].tap()
    XCTAssertTrue(app.staticTexts["persists across learning reset"].waitForExistence(timeout: 2))
  }

  private func openExperiment(lesson: Int) {
    app.tabBars.buttons["Learn"].tap()
    let catalog = app.tables["learning-catalog"]
    XCTAssertTrue(catalog.waitForExistence(timeout: 5))
    let cell = app.cells["lesson-\(lesson)"]
    scrollUntilHittable(cell, in: catalog)
    cell.tap()

    let open = app.buttons["open-experiment"]
    scrollUntilHittable(open, in: app.scrollViews.firstMatch)
    open.tap()
  }

  private func openTypeEntry(lesson: Int, typeID: String) {
    app.tabBars.buttons["Learn"].tap()
    let catalog = app.tables["learning-catalog"]
    XCTAssertTrue(catalog.waitForExistence(timeout: 5))
    let cell = app.cells["lesson-\(lesson)"]
    scrollUntilHittable(cell, in: catalog)
    cell.tap()

    let entry = app.buttons["type-card-\(typeID)"]
    scrollUntilHittable(entry, in: app.scrollViews.firstMatch)
    entry.tap()
  }

  private func scrollUntilHittable(_ element: XCUIElement, in scrollView: XCUIElement) {
    if !element.isHittable {
      scrollView.swipeDown()
      scrollView.swipeDown()
    }
    var attempts = 0
    while !element.isHittable && attempts < 20 {
      scrollView.swipeUp()
      attempts += 1
    }
    XCTAssertTrue(element.isHittable)
  }
}

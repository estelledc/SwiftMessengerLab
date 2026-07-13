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
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "sent · id")).element(boundBy: 1)
                .waitForExistence(timeout: 3)
        )
        XCTAssertEqual(
            app.staticTexts.matching(NSPredicate(format: "label == %@", "/fail")).count,
            1
        )
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

        let search = app.searchFields["type-search"]
        XCTAssertTrue(search.waitForExistence(timeout: 2))
        search.tap()
        search.typeText("append")

        let stringResult = app.cells["type-search-result-String"]
        XCTAssertTrue(stringResult.waitForExistence(timeout: 2))
        stringResult.tap()
        XCTAssertTrue(app.staticTexts["Swift.String"].waitForExistence(timeout: 2))

        let open = app.buttons["open-type-experiment"]
        scrollUntilHittable(open, in: app.scrollViews.firstMatch)
        open.tap()
        XCTAssertTrue(app.textFields["text-value-field"].waitForExistence(timeout: 2))
    }

    func testLessonExposesDistinctArrayAndDictionaryTypeCards() throws {
        app.tabBars.buttons["Learn"].tap()
        let lesson = app.cells["lesson-7"]
        scrollUntilHittable(lesson, in: app.tables.firstMatch)
        lesson.tap()

        let array = app.buttons["type-card-Array"]
        scrollUntilHittable(array, in: app.scrollViews.firstMatch)
        array.tap()
        XCTAssertTrue(app.staticTexts["Swift.Array"].waitForExistence(timeout: 2))
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let dictionary = app.buttons["type-card-Dictionary"]
        scrollUntilHittable(dictionary, in: app.scrollViews.firstMatch)
        dictionary.tap()
        XCTAssertTrue(app.staticTexts["Swift.Dictionary"].waitForExistence(timeout: 2))
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
        let cell = app.cells["lesson-\(lesson)"]
        scrollUntilHittable(cell, in: app.tables.firstMatch)
        cell.tap()

        let open = app.buttons["open-experiment"]
        scrollUntilHittable(open, in: app.scrollViews.firstMatch)
        open.tap()
    }

    private func scrollUntilHittable(_ element: XCUIElement, in scrollView: XCUIElement) {
        var attempts = 0
        while !element.isHittable && attempts < 20 {
            scrollView.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(element.isHittable)
    }
}

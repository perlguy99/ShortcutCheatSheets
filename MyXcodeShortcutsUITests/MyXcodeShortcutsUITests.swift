//
//  MyXcodeShortcutsUITests.swift
//  MyXcodeShortcutsUITests
//
//  Created by Brent Michalski on 4/1/24.
//

import XCTest

final class MyXcodeShortcutsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    /// Diagnostic test: drives the real UI to the Browse Library sheet and screenshots it at
    /// several points, to actually see what renders instead of just reasoning about the code.
    func testBrowseLibrarySheetShowsContent() throws {
        let app = XCUIApplication()
        app.launch()

        let collectionsTab = app.tabBars.buttons["Collections"]
        XCTAssertTrue(collectionsTab.waitForExistence(timeout: 5), "Collections tab button not found")
        collectionsTab.tap()

        let browseButton = app.buttons["Browse Library"]
        XCTAssertTrue(browseButton.waitForExistence(timeout: 5), "Browse Library toolbar button not found")
        browseButton.tap()

        // Screenshot immediately after tapping, before the fetch could possibly complete -
        // this is exactly the frame that used to render blank.
        let immediateAttachment = XCTAttachment(screenshot: app.screenshot())
        immediateAttachment.name = "01-immediately-after-tap"
        immediateAttachment.lifetime = .keepAlways
        add(immediateAttachment)

        // Then wait for either the real list or an error to actually appear.
        let finderRow = app.staticTexts["Finder Shortcuts"]
        let errorText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Couldn'")).firstMatch
        let appeared = finderRow.waitForExistence(timeout: 15) || errorText.waitForExistence(timeout: 1)

        let finalAttachment = XCTAttachment(screenshot: app.screenshot())
        finalAttachment.name = "02-after-wait"
        finalAttachment.lifetime = .keepAlways
        add(finalAttachment)

        XCTAssertTrue(appeared, "Neither the library list nor an error message ever appeared")
        XCTAssertTrue(finderRow.exists, "Expected to see 'Finder Shortcuts' in the real hosted library list")
    }
}

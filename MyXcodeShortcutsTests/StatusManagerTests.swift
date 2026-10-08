//
//  StatusManagerTests.swift
//  MyXcodeShortcutsTests
//

import XCTest
@testable import ShortcutCheatsheets

/// Uses a dedicated `UserDefaults` suite per test, cleared in setUp/tearDown, instead of
/// touching real `UserDefaults.standard` — keeps these tests isolated and order-independent.
final class StatusManagerTests: XCTestCase {

    private var userDefaults: UserDefaults!
    private var statusManager: StatusManager!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        statusManager = StatusManager(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        statusManager = nil
        super.tearDown()
    }

    func testDefaultsWhenStoreIsEmpty() {
        XCTAssertEqual(statusManager.currentStatus, .none)
        XCTAssertEqual(statusManager.pdfTitle, Constants.defaultTitle)
        XCTAssertEqual(statusManager.separator, Constants.defaultSeparator)
        XCTAssertEqual(statusManager.showSymbols, Constants.defaultShowSymbols)
        XCTAssertEqual(statusManager.activeShortcutAppID, "")
    }

    func testLoadsExistingValuesFromStore() {
        userDefaults.set(Status.favorite.rawValue, forKey: Constants.Keys.statusInt)
        userDefaults.set("Sample PDF", forKey: Constants.Keys.pdfTitle)
        userDefaults.set("-", forKey: Constants.Keys.separator)
        userDefaults.set(false, forKey: Constants.Keys.showSymbols)

        let manager = StatusManager(userDefaults: userDefaults)

        XCTAssertEqual(manager.currentStatus, .favorite)
        XCTAssertEqual(manager.pdfTitle, "Sample PDF")
        XCTAssertEqual(manager.separator, "-")
        XCTAssertFalse(manager.showSymbols)
    }

    func testSettingCurrentStatusPersists() {
        statusManager.currentStatus = .hidden
        XCTAssertEqual(userDefaults.integer(forKey: Constants.Keys.statusInt), Status.hidden.rawValue)
    }

    func testSettingPdfTitlePersists() {
        statusManager.pdfTitle = "Updated PDF Title"
        XCTAssertEqual(userDefaults.string(forKey: Constants.Keys.pdfTitle), "Updated PDF Title")
    }

    func testSettingSeparatorPersists() {
        statusManager.separator = "|"
        XCTAssertEqual(userDefaults.string(forKey: Constants.Keys.separator), "|")
    }

    func testSettingShowSymbolsPersists() {
        statusManager.showSymbols = false
        XCTAssertFalse(userDefaults.bool(forKey: Constants.Keys.showSymbols))
    }

    func testSettingActiveShortcutAppIDPersists() {
        let sampleID = UUID().uuidString
        statusManager.activeShortcutAppID = sampleID
        XCTAssertEqual(userDefaults.string(forKey: Constants.Keys.activeShortcutAppID), sampleID)
    }

    func testToggleStatusCyclesThroughAllCases() {
        XCTAssertEqual(statusManager.currentStatus, .none)

        statusManager.toggleStatus()
        XCTAssertEqual(statusManager.currentStatus, .favorite)

        statusManager.toggleStatus()
        XCTAssertEqual(statusManager.currentStatus, .hidden)

        statusManager.toggleStatus()
        XCTAssertEqual(statusManager.currentStatus, .none)
    }
}

//
//  ShortcutFilterTests.swift
//  MyXcodeShortcutsTests
//
//  Created by Brent Michalski on 4/19/24.
//

import XCTest
import SwiftUI
import SwiftData

@testable import ShortcutCheatsheets

final class ShortcutFilterTests: XCTestCase {
    var statusInt = 0

    var testShortcuts: [Shortcut] = {
       [
        Shortcut(keyCombo: "abc1", details: "abc1", status: .favorite, category: nil),
        Shortcut(keyCombo: "abc2", details: "abc2", status: .favorite, category: nil),
        Shortcut(keyCombo: "abc3", details: "abc3", status: .hidden, category: nil),
        Shortcut(keyCombo: "abc4", details: "abc4", status: .hidden, category: nil),
        Shortcut(keyCombo: "abc5", details: "abc5", status: .none, category: nil),
        Shortcut(keyCombo: "abc6", details: "abc6", status: .none, category: nil),
       ]
    }()
    
    func testShortcutStatusThing_none() {
        let statusInt = 0
        XCTAssertTrue(testShortcuts[0].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[1].matchesStatus(statusInt))
        XCTAssertFalse(testShortcuts[2].matchesStatus(statusInt))
        XCTAssertFalse(testShortcuts[3].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[4].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[5].matchesStatus(statusInt))
    }
    
    func testShortcutStatusThing_favorite() {
        let statusInt = 1
        XCTAssertTrue(testShortcuts[0].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[1].matchesStatus(statusInt))
        XCTAssertFalse(testShortcuts[2].matchesStatus(statusInt))
        XCTAssertFalse(testShortcuts[3].matchesStatus(statusInt))
        XCTAssertFalse(testShortcuts[4].matchesStatus(statusInt))
        XCTAssertFalse(testShortcuts[5].matchesStatus(statusInt))
    }

    func testShortcutStatusThing_hidden() {
        let statusInt = 2
        XCTAssertTrue(testShortcuts[0].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[1].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[2].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[3].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[4].matchesStatus(statusInt))
        XCTAssertTrue(testShortcuts[5].matchesStatus(statusInt))
    }
}

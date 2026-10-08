//
//  ShortcutImporterTests.swift
//  MyXcodeShortcutsTests
//
//  Covers the JSON-import seam added for in-app collection import: the pure decode step
//  (no SwiftData) and the SwiftData-touching build step that creates a ShortcutApp plus its
//  Category/Shortcut rows.
//

import XCTest
import SwiftData

@testable import ShortcutCheatsheets

final class ShortcutImporterTests: XCTestCase {

    private let validJSON = """
    {
        "categories": [
            {
                "name": "File",
                "shortcuts": [
                    { "keyCombo": "cmd n", "details": "New" },
                    { "keyCombo": "cmd o", "details": "Open" }
                ]
            },
            {
                "name": "Edit",
                "shortcuts": [
                    { "keyCombo": "cmd z", "details": "Undo" }
                ]
            }
        ]
    }
    """.data(using: .utf8)!

    // MARK: - decodeCategories (pure)

    func testDecodeValidJSONReturnsCategoriesAndShortcuts() throws {
        let categories = try ShortcutImporter.decodeCategories(from: validJSON)

        XCTAssertEqual(categories.count, 2)
        XCTAssertEqual(categories[0].name, "File")
        XCTAssertEqual(categories[0].shortcuts?.count, 2)
        XCTAssertEqual(categories[0].shortcuts?[0].keyCombo, "cmd n")
        XCTAssertEqual(categories[0].shortcuts?[0].details, "New")
        XCTAssertEqual(categories[1].name, "Edit")
        XCTAssertEqual(categories[1].shortcuts?.count, 1)
    }

    func testDecodeMalformedJSONThrowsInvalidJSON() {
        let garbage = "not json at all { [".data(using: .utf8)!

        XCTAssertThrowsError(try ShortcutImporter.decodeCategories(from: garbage)) { error in
            XCTAssertEqual(error as? ShortcutImportError, .invalidJSON)
        }
    }

    func testDecodeWrongShapeJSONThrowsInvalidJSON() {
        let wrongShape = #"{"foo": "bar"}"#.data(using: .utf8)!

        XCTAssertThrowsError(try ShortcutImporter.decodeCategories(from: wrongShape)) { error in
            XCTAssertEqual(error as? ShortcutImportError, .invalidJSON)
        }
    }

    func testDecodeEmptyCategoriesThrowsNoCategories() {
        let empty = #"{"categories": []}"#.data(using: .utf8)!

        XCTAssertThrowsError(try ShortcutImporter.decodeCategories(from: empty)) { error in
            XCTAssertEqual(error as? ShortcutImportError, .noCategories)
        }
    }

    // MARK: - importCollection (SwiftData)

    @MainActor
    func testImportCollectionCreatesShortcutAppCategoriesAndShortcuts() throws {
        let schema = Schema([ShortcutApp.self, Category.self, Shortcut.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let newApp = try ShortcutImporter.importCollection(named: "Finder Shortcuts", from: validJSON, into: context)

        XCTAssertEqual(newApp.name, "Finder Shortcuts")
        XCTAssertEqual(newApp.categories.count, 2)

        let fetchedApps = try context.fetch(FetchDescriptor<ShortcutApp>())
        XCTAssertEqual(fetchedApps.count, 1)
        XCTAssertEqual(fetchedApps.first?.id, newApp.id)

        let fetchedCategories = try context.fetch(FetchDescriptor<ShortcutCheatsheets.Category>())
        XCTAssertEqual(fetchedCategories.count, 2)
        for category in fetchedCategories {
            XCTAssertEqual(category.shortcutApp?.id, newApp.id)
        }

        let fileCategory = fetchedCategories.first { $0.name == "File" }
        XCTAssertEqual(fileCategory?.shortcuts.count, 2)
        XCTAssertTrue(fileCategory?.shortcuts.contains { $0.keyCombo == "cmd n" && $0.details == "New" } ?? false)
        XCTAssertEqual(fileCategory?.shortcuts.first?.status, Status.none)

        let editCategory = fetchedCategories.first { $0.name == "Edit" }
        XCTAssertEqual(editCategory?.shortcuts.count, 1)
    }

    /// Integration test using a real file captured from `swift run ShortcutExtractor
    /// com.apple.finder` (checked in as RealExporterOutput_Finder.json), not a hand-written
    /// fixture - proves the actual end-to-end pipeline advanced users rely on (Mac exporter ->
    /// JSON -> Collections tab import) still works against genuine exporter output, not just
    /// JSON shaped the way this test file's author assumes the exporter produces.
    @MainActor
    func testImportCollectionAcceptsRealMacExporterOutput() throws {
        let fixtureURL = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "RealExporterOutput_Finder", withExtension: "json"),
            "RealExporterOutput_Finder.json fixture is missing from the test bundle"
        )
        let data = try Data(contentsOf: fixtureURL)

        let schema = Schema([ShortcutApp.self, Category.self, Shortcut.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let newApp = try ShortcutImporter.importCollection(named: "Finder Shortcuts", from: data, into: context)

        XCTAssertEqual(newApp.name, "Finder Shortcuts")
        XCTAssertGreaterThan(newApp.categories.count, 0, "Real exporter output should produce at least one category")

        let totalShortcuts = newApp.categories.reduce(0) { $0 + $1.shortcuts.count }
        XCTAssertGreaterThan(totalShortcuts, 0, "Real exporter output should produce at least one shortcut")

        for category in newApp.categories {
            XCTAssertFalse(category.name.isEmpty)
            for shortcut in category.shortcuts {
                XCTAssertFalse(shortcut.keyCombo.isEmpty, "Every real shortcut should have a non-empty key combo")
            }
        }
    }

    @MainActor
    func testImportCollectionThrowsAndInsertsNothingOnMalformedJSON() throws {
        let schema = Schema([ShortcutApp.self, Category.self, Shortcut.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let garbage = "not json".data(using: .utf8)!

        XCTAssertThrowsError(try ShortcutImporter.importCollection(named: "Broken", from: garbage, into: context))

        let fetchedApps = try context.fetch(FetchDescriptor<ShortcutApp>())
        XCTAssertTrue(fetchedApps.isEmpty)
    }
}

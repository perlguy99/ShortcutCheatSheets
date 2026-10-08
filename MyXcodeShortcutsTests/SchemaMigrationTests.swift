//
//  SchemaMigrationTests.swift
//  MyXcodeShortcutsTests
//
//  Proves the SchemaV1 -> SchemaV2 migration actually preserves real on-disk data (the
//  pre-ShortcutApp shape migrating to the current one), not just that the migration plan
//  compiles. Writes with the old schema, reopens the same store file with the current
//  schema + migration plan, and checks the data survived and the new relationship works.
//

import XCTest
import SwiftData

@testable import ShortcutCheatsheets

final class SchemaMigrationTests: XCTestCase {

    private var storeURL: URL!

    override func setUpWithError() throws {
        storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("store")
    }

    override func tearDownWithError() throws {
        for suffix in ["", "-wal", "-shm"] {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + suffix))
        }
    }

    @MainActor
    func testV1DataSurvivesMigrationToV2() throws {
        // Write a category + shortcut using the frozen pre-ShortcutApp schema.
        do {
            let schema = Schema(versionedSchema: SchemaV1.self)
            let config = ModelConfiguration(schema: schema, url: storeURL)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext

            let category = SchemaV1.Category(name: "Xcode")
            let shortcut = SchemaV1.Shortcut(keyCombo: "cmd b", details: "Build", category: category)
            category.shortcuts.append(shortcut)
            context.insert(category)
            try context.save()
        }

        // Reopen the same file with the current schema + migration plan.
        let schema = Schema(versionedSchema: CurrentSchema.self)
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(for: schema, migrationPlan: MigrationPlan.self, configurations: [config])
        let context = container.mainContext

        let categories = try context.fetch(FetchDescriptor<ShortcutCheatsheets.Category>())
        XCTAssertEqual(categories.count, 1)
        let category = try XCTUnwrap(categories.first)
        XCTAssertEqual(category.name, "Xcode")
        XCTAssertEqual(category.shortcuts.count, 1)
        XCTAssertEqual(category.shortcuts.first?.keyCombo, "cmd b")
        XCTAssertEqual(category.shortcuts.first?.details, "Build")

        // The new relationship (didn't exist pre-migration) should be usable post-migration.
        XCTAssertNil(category.shortcutApp)
        let app = ShortcutApp(name: "Migrated Collection")
        context.insert(app)
        category.shortcutApp = app
        try context.save()
        XCTAssertEqual(category.shortcutApp?.name, "Migrated Collection")
    }

    @MainActor
    func testV2DataSurvivesMigrationToV3() throws {
        // Write a category + shortcut using the frozen pre-`order` schema.
        do {
            let schema = Schema(versionedSchema: SchemaV2.self)
            let config = ModelConfiguration(schema: schema, url: storeURL)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext

            let app = SchemaV2.ShortcutApp(name: "Xcode Shortcuts")
            context.insert(app)
            let category = SchemaV2.Category(name: "Xcode")
            category.shortcutApp = app
            let shortcut = SchemaV2.Shortcut(keyCombo: "cmd b", details: "Build", category: category)
            category.shortcuts.append(shortcut)
            context.insert(category)
            try context.save()
        }

        // Reopen the same file with the current schema + migration plan.
        let schema = Schema(versionedSchema: CurrentSchema.self)
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(for: schema, migrationPlan: MigrationPlan.self, configurations: [config])
        let context = container.mainContext

        let categories = try context.fetch(FetchDescriptor<ShortcutCheatsheets.Category>())
        XCTAssertEqual(categories.count, 1)
        let category = try XCTUnwrap(categories.first)
        XCTAssertEqual(category.name, "Xcode")
        XCTAssertEqual(category.shortcutApp?.name, "Xcode Shortcuts")
        XCTAssertEqual(category.shortcuts.count, 1)
        XCTAssertEqual(category.shortcuts.first?.keyCombo, "cmd b")

        // The new `order` field (didn't exist pre-migration) defaults to 0 and is usable.
        XCTAssertEqual(category.order, 0)
        XCTAssertEqual(category.shortcuts.first?.order, 0)
        category.order = 3
        try context.save()
        XCTAssertEqual(category.order, 3)
    }
}

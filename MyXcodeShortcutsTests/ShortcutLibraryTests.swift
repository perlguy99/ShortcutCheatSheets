//
//  ShortcutLibraryTests.swift
//  MyXcodeShortcutsTests
//
//  Covers the pure manifest-decode step (no network) for the hosted shortcut library. Live
//  network behavior against the real GitHub-hosted manifest is verified manually, not here.
//

import XCTest

@testable import ShortcutCheatsheets

final class ShortcutLibraryTests: XCTestCase {

    private let validManifestJSON = """
    {
        "version": 1,
        "collections": [
            { "id": "xcode", "name": "Xcode Shortcuts", "file": "xcode.json" },
            { "id": "finder", "name": "Finder Shortcuts", "file": "finder.json" }
        ]
    }
    """.data(using: .utf8)!

    func testDecodeValidManifestReturnsCollections() throws {
        let manifest = try ShortcutLibrary.decodeManifest(from: validManifestJSON)

        XCTAssertEqual(manifest.version, 1)
        XCTAssertEqual(manifest.collections.count, 2)
        XCTAssertEqual(manifest.collections[0].id, "xcode")
        XCTAssertEqual(manifest.collections[0].name, "Xcode Shortcuts")
        XCTAssertEqual(manifest.collections[0].file, "xcode.json")
    }

    func testDecodeMalformedJSONThrowsInvalidManifest() {
        let garbage = "not json at all { [".data(using: .utf8)!

        XCTAssertThrowsError(try ShortcutLibrary.decodeManifest(from: garbage)) { error in
            XCTAssertEqual(error as? ShortcutLibraryError, .invalidManifest)
        }
    }

    func testDecodeEmptyCollectionsStillDecodes() throws {
        let empty = #"{"version": 1, "collections": []}"#.data(using: .utf8)!

        let manifest = try ShortcutLibrary.decodeManifest(from: empty)
        XCTAssertEqual(manifest.collections.count, 0)
    }
}

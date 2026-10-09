//
//  ShortcutLibrary.swift
//  MyXcodeShortcuts
//
//  Fetches the hosted shortcut library from GitHub (perlguy99/ShortcutCheatSheets's library/
//  folder - raw file URLs, no server, new collections just need a git push). The manifest lists
//  what's available; each entry's own JSON is handed to the existing ShortcutImporter, so there's
//  no duplicate decoding logic between the manual-file-picker import flow and this one.
//
//  This is the app's first real networking code. BrowseLibraryView (the only caller) is a View,
//  so its methods are implicitly @MainActor-isolated the same way every other view's already are
//  - a Task{} inside it suspends off-MainActor during `await fetch(...)` and resumes back on
//  MainActor automatically, so calling ShortcutImporter.importCollection right after needs no
//  explicit MainActor.run.
//

import Foundation

struct LibraryEntry: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let file: String
}

struct LibraryManifest: Codable, Sendable {
    let version: Int
    let collections: [LibraryEntry]
}

enum ShortcutLibraryError: LocalizedError, Equatable {
    case invalidManifest
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidManifest:
            return "Couldn't read the shortcut library's listing. Try again in a moment."
        case .requestFailed(let statusCode):
            return "Couldn't reach the shortcut library (error \(statusCode)). Check your connection and try again."
        }
    }
}

enum ShortcutLibrary {
    private static let baseURL = URL(string: "https://raw.githubusercontent.com/perlguy99/ShortcutCheatSheets/main/library/")!

    static func decodeManifest(from data: Data) throws -> LibraryManifest {
        do {
            return try JSONDecoder().decode(LibraryManifest.self, from: data)
        } catch {
            throw ShortcutLibraryError.invalidManifest
        }
    }

    static func fetchManifest() async throws -> LibraryManifest {
        let data = try await fetch(baseURL.appending(path: "manifest.json"))
        return try decodeManifest(from: data)
    }

    static func fetchCollectionData(for entry: LibraryEntry) async throws -> Data {
        try await fetch(baseURL.appending(path: entry.file))
    }

    private static func fetch(_ url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw ShortcutLibraryError.requestFailed(statusCode: statusCode)
        }
        return data
    }
}

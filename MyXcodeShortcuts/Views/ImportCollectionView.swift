//
//  ImportCollectionView.swift
//  MyXcodeShortcuts
//
//  "New Collection" flow: user names a collection, then picks a .json file produced by the
//  ShortcutExtractor CLI tool. On success, a new ShortcutApp (plus its Category/Shortcut rows)
//  is created via ShortcutImporter and handed back through `onImported`.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Called after a collection is successfully imported, so the presenter can e.g. make it
    /// the active collection.
    var onImported: (ShortcutApp) -> Void

    @State private var collectionName: String = ""
    @State private var isPickingFile = false
    @State private var errorMessage: String?

    private var trimmedName: String {
        collectionName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Form {
            Section {
                Text("Collections are built from a JSON file exported by the free Mac companion app, which reads an app's real menu bar and turns its shortcuts into a file you can import here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Link(destination: URL(string: "https://github.com/perlguy99/ShortcutCheatSheets/blob/main/README.md")!) {
                    HStack {
                        Text("Full instructions")
                            .font(.footnote)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.footnote)
                    }
                }
            }

            Section(header: Text("Collection Name")) {
                TextField("e.g. Finder Shortcuts", text: $collectionName)
                    .textFieldStyle(.roundedBorder)
            }

            Section(header: Text("Shortcuts JSON")) {
                Button("Choose JSON File...") {
                    isPickingFile = true
                }
                .disabled(trimmedName.isEmpty)

                if trimmedName.isEmpty {
                    Text("Enter a name above before picking a file.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("New Collection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [.json]) { result in
            handle(result)
        }
    }

    private func handle(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let data = try readData(from: url)
            let newApp = try ShortcutImporter.importCollection(named: trimmedName, from: data, into: modelContext)
            errorMessage = nil
            onImported(newApp)
            dismiss()
        } catch let error as ShortcutImportError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Couldn't read that file: \(error.localizedDescription)"
        }
    }

    private func readData(from url: URL) throws -> Data {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { url.stopAccessingSecurityScopedResource() }
        }
        return try Data(contentsOf: url)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ShortcutApp.self, Category.self, Shortcut.self, configurations: config)

        return NavigationStack {
            ImportCollectionView(onImported: { _ in })
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create a model container")
    }
}

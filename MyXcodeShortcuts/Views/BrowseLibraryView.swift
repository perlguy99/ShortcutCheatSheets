//
//  BrowseLibraryView.swift
//  MyXcodeShortcuts
//
//  Lets the user pick a collection from the hosted shortcut library (see ShortcutLibrary.swift)
//  instead of running the Mac exporter themselves. Fetches live every time this sheet is
//  presented - no caching for v1, CollectionsView builds a fresh instance each time anyway.
//

import SwiftUI
import SwiftData

struct BrowseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \ShortcutApp.name) private var shortcutApps: [ShortcutApp]

    /// Called after a collection is successfully imported, same contract ImportCollectionView
    /// already uses, so CollectionsView can wire both into the same select()/onSelect() chain.
    var onImported: (ShortcutApp) -> Void

    @State private var manifest: LibraryManifest?
    // Starts true (not false) so the spinner is visible from the very first frame, before
    // .task even gets a chance to run - otherwise none of the three body branches match on
    // that first render and the sheet shows nothing at all with zero indication anything's
    // happening, which is exactly the bug this is fixing.
    @State private var isLoadingManifest = true
    @State private var errorMessage: String?
    @State private var importingEntryID: String?

    private func alreadyImported(_ entry: LibraryEntry) -> Bool {
        shortcutApps.contains { $0.name == entry.name }
    }

    var body: some View {
        Group {
            if isLoadingManifest {
                ProgressView("Loading library...")
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadManifest() }
                    }
                }
                .padding()
            } else if let manifest {
                List(manifest.collections) { entry in
                    row(for: entry)
                }
            }
        }
        .navigationTitle("Browse Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .task {
            await loadManifest()
        }
    }

    private func row(for entry: LibraryEntry) -> some View {
        let isImported = alreadyImported(entry)

        return Button {
            importEntry(entry)
        } label: {
            HStack {
                Text(entry.name)
                Spacer()
                if importingEntryID == entry.id {
                    ProgressView()
                } else if isImported {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(.primary)
        .disabled(isImported || importingEntryID != nil)
    }

    private func loadManifest() async {
        isLoadingManifest = true
        errorMessage = nil
        do {
            manifest = try await ShortcutLibrary.fetchManifest()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingManifest = false
    }

    private func importEntry(_ entry: LibraryEntry) {
        importingEntryID = entry.id
        Task {
            do {
                let data = try await ShortcutLibrary.fetchCollectionData(for: entry)
                let newApp = try ShortcutImporter.importCollection(named: entry.name, from: data, into: modelContext)
                onImported(newApp)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                importingEntryID = nil
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ShortcutApp.self, Category.self, Shortcut.self, configurations: config)

        return NavigationStack {
            BrowseLibraryView(onImported: { _ in })
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create a model container")
    }
}

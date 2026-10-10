//
//  ContentView.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/1/24.
//

import SwiftUI
import SwiftData
import PDFKit

@MainActor
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StatusManager.self) private var statusManager
    
    @State private var navigationPath = NavigationPath()
    @State private var isGeneratingPDF = false

    @Query private var categories: [Category]
    @Query(sort: \ShortcutApp.name) private var shortcutApps: [ShortcutApp]

    /// The collection currently selected as active (see CollectionsView). Falls back to the
    /// first available `ShortcutApp` when nothing has been explicitly chosen yet.
    private var activeShortcutApp: ShortcutApp? {
        if let uuid = UUID(uuidString: statusManager.activeShortcutAppID),
           let match = shortcutApps.first(where: { $0.id == uuid }) {
            return match
        }
        return shortcutApps.first
    }

    private var visibleCategories: [Category] {
        guard let activeShortcutApp else { return categories }
        return categories.filter { $0.shortcutApp?.id == activeShortcutApp.id }
    }

    var body: some View {
        return NavigationStack(path: $navigationPath) {

            VStack(alignment: .leading, spacing: 2) {
                // The system nav title (large OR inline) truncates long names with an
                // ellipsis on a real device and has no public API to force wrapping -
                // confirmed both ways now, large title isn't actually any different from
                // inline here despite rendering on its own line. So the real collection
                // name is drawn here instead, as a perfectly ordinary SwiftUI Text in the
                // content area, which wraps by default with full control - no system
                // chrome involved, no undocumented behavior to fight.
                Text(activeShortcutApp?.name ?? "Shortcut Cheat Sheets")
                    .font(.largeTitle.bold())
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)

                Text(statusManager.currentStatus.headingValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                CategoryListView(activeShortcutAppID: activeShortcutApp?.id)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            filtertoolbarItem()
                            EditButton()
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            printToolbarItem()
                            addItemToolbarItem()
                        }
                    }
            }
            // The nav bar's own title is now just a short, static, never-truncating
            // label - the real collection name lives in the content area above, where
            // it can actually wrap. Kept for VoiceOver/back-button purposes.
            .navigationTitle("Shortcuts")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Shortcut.self) { shortcut in
                EditShortcutView(navigationPath: $navigationPath, shortcut: shortcut)
            }
            .navigationDestination(for: Category.self) { category in
                EditCategoryView(category: category)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .categorySelection(let shortcut):
                    CategorySelectionView(shortcut: shortcut, activeShortcutApp: activeShortcutApp)
                case .pdfPreview(let data):
                    PDFPreviewView(data: data, statusManager: statusManager)
                case .help:
                    HelpView()
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newShortcut = Shortcut(keyCombo: "", details: "")
            modelContext.insert(newShortcut)
            try? modelContext.save()
            navigationPath.append(newShortcut)
        }
    }
    
    private func filtertoolbarItem() -> some View {
        Button {
            withAnimation {
                statusManager.toggleStatus()
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title2)
                .foregroundStyle(ThemeManager.filterButtonColor(for: statusManager.currentStatus))
        }
        .accessibilityLabel(statusManager.currentStatus.headingValue)
    }
    
    private func printToolbarItem() -> some View {
        Button(action: printPDF) {
            if isGeneratingPDF {
                ProgressView()
            } else {
                Label("Print", systemImage: "printer")
            }
        }
        .disabled(visibleCategories.isEmpty || isGeneratingPDF)
    }

    private func printPDF() {
        // Flip the state first and defer the actual (synchronous, can take a
        // moment on a large collection) generation to the next run loop turn,
        // so SwiftUI gets a chance to actually paint the spinner before the
        // blocking work starts - otherwise the button would just sit there
        // looking unresponsive with no feedback that a tap registered at all.
        isGeneratingPDF = true
        DispatchQueue.main.async {
            let viewModel = PDFViewModel(categories: visibleCategories, statusManager: statusManager)
            viewModel.generatePDF()
            isGeneratingPDF = false
            if let data = viewModel.pdfData {
                navigationPath.append(Route.pdfPreview(data))
            }
        }
    }

    private func addItemToolbarItem() -> some View {
        Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
        }
    }
}

#Preview {
    let statusManager = StatusManager()
    statusManager.showSymbols = true
    
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, configurations: config)
        
        let previewHelper = PreviewHelper(container: container)
        previewHelper.loadSampleData()
        
        return ContentView()
            .preferredColorScheme(.light)
            .modelContainer(container)
            .environment(statusManager)
    } catch {
        return Text("Failed to create a model container")
    }
}

#Preview {
    let statusManager = StatusManager()
    statusManager.showSymbols = true
    
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, configurations: config)
        
        let previewHelper = PreviewHelper(container: container)
        previewHelper.loadSampleData()
        
        return ContentView()
            .preferredColorScheme(.dark)
            .modelContainer(container)
            .environment(statusManager)
    } catch {
        return Text("Failed to create a model container")
    }
}

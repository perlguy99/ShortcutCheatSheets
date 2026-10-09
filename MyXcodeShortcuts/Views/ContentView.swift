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

            VStack {
                Text(statusManager.currentStatus.headingValue)
                    .font(.caption)

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
            .navigationTitle(activeShortcutApp?.name ?? "Shortcut Cheat Sheets")
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
            Label("Print", systemImage: "printer")
        }
        .disabled(visibleCategories.isEmpty)
    }

    private func printPDF() {
        let viewModel = PDFViewModel(categories: visibleCategories, statusManager: statusManager)
        viewModel.generatePDF()
        if let data = viewModel.pdfData {
            navigationPath.append(Route.pdfPreview(data))
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

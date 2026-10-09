//
//  CategorySelectionView.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/15/24.
//

import SwiftUI
import SwiftData

struct CategorySelectionView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var shortcut: Shortcut
    /// The collection this shortcut belongs to - passed in so new categories get tagged to it
    /// (an untagged Category is invisible everywhere else in the app, since every other list is
    /// filtered to the active collection) and so this picker/delete only ever touches categories
    /// from the same collection, not every collection in the database.
    var activeShortcutApp: ShortcutApp?
    @Query private var categories: [Category]
    @State private var tempCategoryName: String = ""

    private var visibleCategories: [Category] {
        categories.filter { $0.shortcutApp?.id == activeShortcutApp?.id }
    }

    var body: some View {
        Form {
            TextField(textFieldPlaceholder, text: $tempCategoryName)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 20)

            categoryListOrMessage

            Spacer()
        }
        .navigationTitle("Categories")
        .onSubmit(handleSubmit)
    }

    private var textFieldPlaceholder: String {
        visibleCategories.isEmpty ? "Category Name" : "Or, Enter New Category"
    }

    private var categoryListOrMessage: some View {
        Group {
            if visibleCategories.isEmpty {
                Text("No categories yet!").italic()
            } else {
                categoryList
            }
        }
    }

    private var categoryList: some View {
        List {
            ForEach(visibleCategories) { category in
                Button {
                    setCategoryAndDismiss(category)
                } label: {
                    CategoryRow(category: category)
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteCategories)
        }
    }

    private func handleSubmit() {
        if tempCategoryName.isNotEmpty {
            insertNewCategoryAndStoreInShortcut()
        }
        dismiss()
    }

    func deleteCategories(_ offsets: IndexSet) {
        let toDelete = visibleCategories
        offsets.forEach { modelContext.delete(toDelete[$0]) }
        try? modelContext.save()
    }

    func insertNewCategoryAndStoreInShortcut() {
        let newCategory = Category(name: tempCategoryName)
        newCategory.shortcutApp = activeShortcutApp
        modelContext.insert(newCategory)
        newCategory.shortcuts.append(shortcut)
        shortcut.category = newCategory
        try? modelContext.save()
    }
    
    func setCategoryAndDismiss(_ category: Category) {
        shortcut.category = category
        dismiss()
    }
}


#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, configurations: config)
        
        let previewHelper = PreviewHelper(container: container)
        previewHelper.loadSampleData()
        
        let sampleCategories = [
            Category(name: "Category1"),
            Category(name: "Category2"),
            Category(name: "Category3"),
            Category(name: "Category4")
        ]
        
        for category in sampleCategories {
            container.mainContext.insert(category)
        }
        
        return CategorySelectionView(shortcut: previewHelper.previewShortcut, activeShortcutApp: nil)
            .modelContainer(container)
    } catch {
        return Text("Failed to create a model container")
    }
    
}

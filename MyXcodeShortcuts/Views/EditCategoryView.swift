//
//  EditCategoryView.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/5/24.
//

import SwiftUI
import SwiftData

struct EditCategoryView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(StatusManager.self) private var statusManager
    
    @Query private var categories: [Category]
    @Bindable var category: Category

    /// Other categories in the same collection as `category` - scoped so a multi-collection
    /// setup doesn't mix in categories (and their shortcut counts) from unrelated collections.
    private var siblingCategories: [Category] {
        categories.filter { $0.shortcutApp?.id == category.shortcutApp?.id }
    }

    var body: some View {
        Form {
            Section("Category Name") {
                VStack {
                    TextField("Category Name", text: $category.name)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(ThemeManager.borderColor(for: statusManager.currentStatus), lineWidth: 2)
                        )
                        .padding(.bottom, 20)
                 
                    List {
                        ForEach(siblingCategories) { category in
                            Divider()
                            
                            HStack {
                                Text(category.name)
                                Spacer()
                                Text("\(category.shortcuts.count)")
                                    .font(.caption)
                                    .foregroundStyle(.appSecondary)
                            }
                            .padding([.leading, .trailing])
                            
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            try? modelContext.save()
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, configurations: config)
        
        let previewHelper = PreviewHelper(container: container)
        previewHelper.loadSampleData()
        
        return EditCategoryView(category: previewHelper.previewCategory)
            .modelContainer(container)
            .environment(StatusManager())
    } catch {
        return Text("Failed to create a model container")
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, configurations: config)

        let previewHelper = PreviewHelper(container: container)
        previewHelper.loadSampleData()

        return EditCategoryView(category: previewHelper.previewCategory)
            .preferredColorScheme(.dark)
            .modelContainer(container)
            .environment(StatusManager())
    } catch {
        return Text("Failed to create a model container")
    }
}

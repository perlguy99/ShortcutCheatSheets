//
//  MyXcodeShortcutsApp.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/1/24.
//

import SwiftUI
import SwiftData

@main
@MainActor
struct MyXcodeShortcutsApp: App {
    @State var isActive: Bool = false
    @State private var statusManager = StatusManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: CurrentSchema.self)

        #if targetEnvironment(simulator)
        let isStoredInMemoryOnly = true
        #else
        let isStoredInMemoryOnly = false
        #endif

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)

        do {
            return try ModelContainer(for: schema, migrationPlan: MigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    func checkSeed() {
        let seed = SeedData(modelContext: sharedModelContainer.mainContext)
        seed.loadSeedData()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(isActive: $isActive)
                .modelContainer(sharedModelContainer)
                .environment(statusManager)
                .task {
                    checkSeed()
                }
        }
    }
}

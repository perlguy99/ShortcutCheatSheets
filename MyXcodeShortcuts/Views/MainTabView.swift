//
//  MainTabView.swift
//  MyXcodeShortcuts
//
//  Root tab bar shown after the splash screen. Each tab owns its own NavigationStack so
//  Shortcuts/Collections/Settings keep independent navigation history, replacing the old
//  single-stack layout where Settings and Collections were reached via unlabeled toolbar icons.
//

import SwiftUI

struct MainTabView: View {
    enum Tab {
        case shortcuts, collections, settings
    }

    @State private var selectedTab: Tab = .shortcuts

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(Tab.shortcuts)

            NavigationStack {
                CollectionsView(onSelect: { selectedTab = .shortcuts })
            }
            .tabItem {
                Label("Collections", systemImage: "square.stack.3d.up")
            }
            .tag(Tab.collections)

            NavigationStack {
                SettingsView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .help:
                            HelpView()
                        case .categorySelection, .pdfPreview:
                            EmptyView()
                        }
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(Tab.settings)
        }
    }
}

#Preview {
    MainTabView()
}

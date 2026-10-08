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
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            NavigationStack {
                CollectionsView()
            }
            .tabItem {
                Label("Collections", systemImage: "square.stack.3d.up")
            }

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
        }
    }
}

#Preview {
    MainTabView()
}

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import ShortcutScraping

struct ContentView: View {
    @State private var runningApps: [NSRunningApplication] = []
    @State private var selectedBundleID: String?
    @State private var statusMessage = "Pick an app, then extract its shortcuts."
    @State private var lastResult: CategoriesOut?
    @State private var isExtracting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shortcut Cheat Sheets Exporter")
                .font(.title2)
                .bold()

            Picker("App", selection: $selectedBundleID) {
                Text("Select an app…").tag(String?.none)
                ForEach(runningApps, id: \.bundleIdentifier) { app in
                    Text(app.localizedName ?? app.bundleIdentifier ?? "Unknown")
                        .tag(app.bundleIdentifier)
                }
            }
            .pickerStyle(.menu)

            Text("Don't see your app? Open it, then tap Refresh App List.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Button("Extract Shortcuts") {
                    extract()
                }
                .disabled(selectedBundleID == nil || isExtracting)

                Button("Save As…") {
                    save()
                }
                .disabled(lastResult == nil)

                Spacer()

                Button("Refresh App List") {
                    loadRunningApps()
                }
            }

            Text(statusMessage)
                .font(.callout)
                .foregroundStyle(.secondary)

            if let lastResult {
                List(lastResult.categories, id: \.name) { category in
                    Text("\(category.name) — \(category.shortcuts.count) shortcuts")
                }
                .frame(minHeight: 200)
            }
        }
        .padding(24)
        .frame(minWidth: 480, minHeight: 420)
        .onAppear {
            loadRunningApps()
            if ShortcutScraper.isAccessibilityTrusted() == false {
                statusMessage = "Accessibility permission needed — enable this app in System Settings > Privacy & Security (also called Device Control and Data Access on some macOS versions) > Accessibility."
            }
        }
    }

    private func loadRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    private func extract() {
        guard let selectedBundleID else { return }
        isExtracting = true
        defer { isExtracting = false }
        do {
            let result = try ShortcutScraper.extractShortcuts(bundleIdentifier: selectedBundleID)
            lastResult = result
            statusMessage = "Extracted \(result.categories.count) categories."
        } catch {
            lastResult = nil
            statusMessage = error.localizedDescription
        }
    }

    private func save() {
        guard let lastResult else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "shortcuts.json"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let data = try ShortcutScraper.encode(lastResult)
            try data.write(to: url)
            statusMessage = "Saved to \(url.path)"
        } catch {
            statusMessage = "Save failed: \(error.localizedDescription)"
        }
    }
}

//
//  HelpView.swift
//  MyXcodeShortcuts
//
//  Created by Brent Michalski on 4/21/24.
//

import SwiftUI
import AVFoundation

struct HelpView: View {
    @State private var easterEggPlayer: AVAudioPlayer?

    var body: some View {
        helpView
        .navigationTitle("Quick Help")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var helpView: some View {
        List {
            Section(header: Text("First Time Running")) {
                let footnote = Text("It isn't 100% complete, but it is a good start").font(.footnote).italic()
                Text("Upon first load, the app is pre-populated with default data from Apple's Xcode documentation\n\(footnote)")

                Text("Users can then add or customize the shortcuts")
            }

            Section(header: Text("Main View")) {
                Text("★ Tap on an existing Shortcut to edit it")
                Text("★ Tap a Shortcut's star to mark it a favorite; swipe left on a Shortcut to hide or unhide it")
            }

            Section {
                let footnote = Text("It is still very basic sorting").font(.footnote).italic()
                Text("Tap to select the sort order\n\(footnote)")
            } header: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Sorting")
                }
            }

            Section {
                let filterFootnote = Text("(none, favorite, hidden)").font(.footnote).italic()
                Text("Tap to toggle between\n\(filterFootnote)")

                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.blue)
                    let none = Text("(none)").bold()
                    let not = Text("Not").font(.footnote).italic().underline().bold()
                    let hidden = Text(" showing hidden").font(.footnote).italic()
                    Text("\(none) - No filter applied\n\(not)\(hidden)")
                }
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.yellow)
                    let favorites = Text("(favorites)").bold()
                    Text("\(favorites) - Only showing Favorites")
                }
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.red)
                    let hidden = Text("(hidden)").bold()
                    Text("\(hidden) - Showing hidden")
                }

                Text("Tip: want your own custom cheat sheet for an app? Swipe left to hide every shortcut you don't care about, make sure the filter is set to \(Text("(none)").bold()), then print from the Shortcuts tab - hidden shortcuts are automatically left out of the PDF.")
                    .padding(.top, 4)
            } header: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("Filtering")
                }
            }

            Section {
                Text("Tap to add a new Shortcut")
            } header: {
                HStack {
                    Image(systemName: "plus")
                    Text("Adding")
                }
            }

            Section {
                Text("Tap to go to the Settings")
                Text("In Settings you can\n\t☞ Customize the PDF title\n\t☞ Choose to show symbols or not\n\t☞ Set a custom key separator")
            } header: {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }


            Section {
                Text("Tap to switch which app's shortcuts you're viewing, or to import a new collection")
                Text("Need shortcuts for an app that isn't listed?\n\t☞ Use the free Mac companion app to export them from that app's real menu bar")
                Link(destination: URL(string: "https://github.com/perlguy99/ShortcutCheatSheets/blob/main/README.md")!) {
                    HStack {
                        Text("☞ Full step-by-step instructions")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            } header: {
                HStack {
                    Image(systemName: "square.stack.3d.up")
                    Text("Collections")
                }
            }

            Section {
                Text("Can't get shortcuts for an app the ways above, or just don't want to deal with the Mac exporter yourself? Email me and I'll see what I can do.")
                Text("For free apps this is usually pretty easy. For paid apps I may need to own a copy myself to export from it - reach out anyway, since some developers are happy to provide a free copy when asked for something like this.")
                Link(destination: URL(string: "mailto:shortcuts@perlguy.net")!) {
                    HStack {
                        Text("☞ shortcuts@perlguy.net")
                        Spacer()
                        Image(systemName: "envelope")
                    }
                }
            } header: {
                HStack {
                    Image(systemName: "envelope.badge")
                    Text("Don't See Your App?")
                }
            }

            Section {
                Text("I just wanted to make sure I gave credit to Ray Wenderlich at https://kodeco.com for the tutorial that inspired this app.")
            } header: {
                HStack {
                    Image(systemName: "hands.and.sparkles.fill")
                    Text("Thank You!")
                }
            }

            Section {
                Button {
                    playDangerSound()
                } label: {
                    HStack {
                        Spacer()
                        Text("Copyright © 2026, Brent Danger Michalski")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.clear)
        }
    }

    private func playDangerSound() {
        guard let url = Bundle.main.url(forResource: "dangers_my_middle_name", withExtension: "mp3") else { return }
        do {
            easterEggPlayer = try AVAudioPlayer(contentsOf: url)
            easterEggPlayer?.play()
        } catch {
            print("Failed to play Easter egg sound: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HelpView()
}

#Preview {
    HelpView()
        .preferredColorScheme(.dark)
}

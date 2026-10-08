# Shortcut Cheat Sheets

An iOS app that turns a keyboard-shortcut reference into a browsable, printable cheat sheet. Comes pre-loaded with a built-in collection, and supports importing collections for other apps via a companion Mac tool.

## Adding shortcuts for an app that isn't built in

If the app you want shortcuts for isn't already in your collections list, use the Mac exporter tool to generate a JSON file from that app's actual live menu bar, then import it into the phone app. No coding required.

### Step 1 — Install the Mac exporter

1. Download the latest `ShortcutCheatSheetsExporter.zip` from the [Releases page](https://github.com/perlguy99/ShortcutCheatSheets/releases).
2. Unzip it and drag **Shortcut Cheat Sheets Exporter.app** into your `/Applications` folder.
3. Launch it. Since it's downloaded from the internet rather than the Mac App Store, macOS will ask "Are you sure you want to open it?" — click **Open**. (It's signed with a real Apple Developer ID and notarized by Apple, so this is the normal prompt, not a security warning.)

### Step 2 — Grant Accessibility permission

The exporter reads another app's menu bar, which macOS only allows with explicit permission.

1. On first launch, the exporter will tell you it needs Accessibility access.
2. Open **System Settings** → **Privacy & Security** → **Accessibility** (on some macOS versions this section is labeled **Device Control and Data Access** instead — same place, different name).
3. Find **Shortcut Cheat Sheets Exporter** in the list and turn it on. If it's not listed yet, quit and relaunch the exporter after opening this settings pane.

### Step 3 — Export an app's shortcuts

1. Open the app you want shortcuts for (e.g. Safari, BBEdit, Terminal) and leave it running.
2. Switch to the exporter. Click the **App** picker at the top and select it from the list of running apps.
   - Don't see it? Click **Refresh App List**.
3. Click **Extract Shortcuts**. The window will show a list of categories (one per menu, like File/Edit/View) with a shortcut count for each.
4. Click **Save As…**, give the file a name (e.g. `safari_shortcuts.json`), and save it somewhere easy to find, like your Desktop.

**Advanced / scriptable alternative:** the exporter is also available as a command-line tool, useful for exporting several apps in a row without clicking through the UI each time:

```
cd tools/ShortcutExtractor
swift run ShortcutExtractor com.apple.Safari --output ~/Desktop/safari_shortcuts.json
```

The first argument is the target app's bundle identifier, not its display name. To find one, run `osascript -e 'id of app "Safari"'` in Terminal. The CLI tool needs the same Accessibility permission as the GUI exporter — grant it to your terminal app (Terminal.app, iTerm, etc.) rather than the exporter in that case, since the terminal is what's actually running the code.

Either way, the output is plain JSON shaped like this:

```json
{
  "categories": [
    {
      "name": "File",
      "shortcuts": [
        { "keyCombo": "Cmd N", "details": "New Window" },
        { "keyCombo": "Cmd O", "details": "Open…" }
      ]
    }
  ]
}
```

If you ever want to hand-write or edit a shortcuts file instead of exporting one, matching this shape is all that's required — the import step below doesn't care how the file was produced.

### Step 4 — Get the file onto your phone

Transfer is manual, on purpose — the phone app is always the source of truth for your collections, so nothing auto-syncs from the Mac. Use whichever's easiest:

- AirDrop the `.json` file from your Mac to your iPhone.
- Save it to iCloud Drive / Files on your Mac, then open the Files app on your phone.
- Email it to yourself and save the attachment.

However it arrives, make sure it ends up somewhere the iOS Files app can see it (iCloud Drive, "On My iPhone," etc.).

### Step 5 — Import it into the app

1. Open Shortcut Cheat Sheets and tap the **Collections** tab.
2. Tap the **+** button in the top right.
3. Enter a name for the new collection (e.g. "Safari Shortcuts").
4. Tap **Choose JSON File...** and pick the file you transferred in Step 4.
5. The new collection appears in your Collections list and is automatically made active — switch to the **Shortcuts** tab to see it.

### Troubleshooting

- **"That file doesn't look like a shortcuts export"** — the file isn't valid JSON, or isn't shaped like the example above. Re-export it, or check for a typo if you hand-edited it.
- **"That file doesn't contain any categories to import"** — the file parsed fine but had zero categories (e.g. you exported an app with no menu bar shortcuts, or it was empty).
- **Exporter shows "Accessibility permission needed" even after granting it** — quit and relaunch the exporter; macOS sometimes needs the app to restart after a permission change.
- **An app doesn't show up in the exporter's picker** — only apps with a normal Dock/menu-bar presence are listed (background-only processes and some system apps are filtered out on purpose). Make sure the app is actually running and in the foreground menu bar, then click Refresh App List.

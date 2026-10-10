# App Store Release Kit — v1.0.1

Everything here is ready to paste into App Store Connect. Character counts are
validated against Apple's limits. This is the first real App Store submission
for this app — no App Store Connect record exists yet (see [[shortcut-cheat-sheets-app]]
in the vault), so this kit covers the full first-listing set, not just a What's
New update.

Starting point was Brent's own draft description, rewritten for App Store
conversion: leads with a direct benefit instead of a rhetorical question,
breaks into scannable sections, and closes on the $0.99 one-time price as a
reason to buy rather than an afterthought.

---

## 1. Metadata

### App Name — 21/30 ✅
```
Shortcut Cheat Sheets
```
Unchanged — matches the app's icon, splash screen, and existing branding work.
Not touched here, just confirmed it fits.

### Subtitle — 29/30 ✅
```
Keyboard Hotkeys & Printables
```
Second-strongest ranking field. Shares no words with the title (duplicates
waste search budget — Apple combines terms across fields automatically). Adds
`keyboard`, `hotkeys`, `printables`.

### Keywords — 96/100 ✅
```
hotkeys,xcode,finder,terminal,mac,reference,productivity,developer,print,pdf,power user,memorize
```
No spaces after commas (reclaims characters). No repeats of any word already
in the title or subtitle. Covers the apps already in the hosted library
(Xcode, Finder, Terminal) plus the core use-case terms a searcher would
actually type.

### Promotional Text — 157/170 ✅
```
Stop hunting for shortcuts. Build a custom, printable cheat sheet from our growing app library, or pull shortcuts from any Mac app with the free helper tool.
```
The only field updatable **without** submitting a new build — good place to
mention a newly-added app in the library any time, without a release.

### Description — 1,412/4,000 ✅

Only the first ~3 lines show before "more", so the hook does the work. Not
indexed for search — written purely for conversion.

```
Stop memorizing keyboard shortcuts — build a custom cheat sheet for every app you use, and keep it right where you can see it.

YOUR SHORTCUTS, YOUR WAY
Pull shortcuts for your favorite apps straight from our constantly growing hosted library — no typing, no digging through menus, just import and go. Don't see an app you use yet? Install the free Mac helper app and pull shortcuts from any app on your Mac in seconds.

ONLY THE ONES YOU ACTUALLY USE
Star your favorites and filter the list down to just those. Swipe to hide the shortcuts you'll never touch. When you print, only what you kept makes the page — a cheat sheet built around how you actually work, not a generic list of everything an app can do.

PRINT IT, TAPE IT UP, STOP LOOKING THINGS UP
One tap turns your filtered list into a clean, ready-to-print PDF. Tape it next to your monitor, slide it under your keyboard, or keep it open on your iPad while you work. However you reference it, the shortcuts you actually need are finally one glance away instead of a web search.

A LIBRARY THAT KEEPS GROWING
New apps get added to the hosted library regularly, so the list of shortcuts you can import without lifting a finger just keeps getting longer.

ONE-TIME 99¢. THAT'S IT.
No subscription. No ads. No account. Pay once, own it, and start saving real time every single day you're at your keyboard.

Questions or app requests: shortcuts@perlguy.net
```

---

## 2. Not done yet

- No App Store Connect record created for this bundle ID — from-scratch setup
  whenever Brent is ready to actually submit.
- Screenshots not produced or audited.
- Privacy policy / support URL not confirmed live for App Store Connect's
  required fields (the in-app `PrivacyInfo.xcprivacy` is current as of the
  2026-10-09 pre-App-Store review, but App Store Connect's listing-level
  Privacy Policy URL is a separate requirement, not yet checked).
- No app preview video — optional, worth considering once screenshots exist.

## 3. Release Checklist

- [x] Version bumped to **1.0.1** (`MARKETING_VERSION`, all app-target configs)
- [x] Build verified clean — real `xcodebuild`, confirmed `CFBundleShortVersionString` = 1.0.1 in the built app
- [ ] Create the App Store Connect app record for this bundle ID
- [ ] Produce and upload screenshots
- [ ] Paste in subtitle, keywords, promotional text, description from above
- [ ] Confirm Privacy Policy / Support URLs
- [ ] Archive and upload a build via Xcode Cloud
- [ ] Submit for review
- [ ] Tag the release: `git tag v1.0.1 && git push --tags`

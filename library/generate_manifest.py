#!/usr/bin/env python3
"""
Regenerates manifest.json from whatever *.json files are sitting in this folder.

Workflow: export a new app's shortcuts, drop the JSON file in this folder
(named like "finder.json"), run this script, commit + push. Never hand-edit
manifest.json directly - it's fully derived from the files present.
"""

import json
import pathlib

# Known capitalization exceptions - .title() gets these wrong (e.g. "bbedit"
# -> "Bbedit"). Add to this as new oddly-capitalized apps get exported.
NAME_OVERRIDES = {
    "bbedit": "BBEdit",
    "vscode": "VS Code",
}

LIBRARY_DIR = pathlib.Path(__file__).parent
MANIFEST_PATH = LIBRARY_DIR / "manifest.json"


def display_name(stem: str) -> str:
    base = NAME_OVERRIDES.get(stem, stem.title())
    return f"{base} Shortcuts"


def main() -> None:
    entries = []
    for path in sorted(LIBRARY_DIR.glob("*.json")):
        if path.name == "manifest.json":
            continue
        stem = path.stem
        entries.append({
            "id": stem,
            "name": display_name(stem),
            "file": path.name,
        })

    manifest = {
        "version": 1,
        "collections": entries,
    }

    with MANIFEST_PATH.open("w") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")

    print(f"Wrote {len(entries)} collections to {MANIFEST_PATH.name}")


if __name__ == "__main__":
    main()

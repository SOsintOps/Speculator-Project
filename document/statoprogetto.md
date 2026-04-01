# Project Status: Instructions for AI

This document describes the current state of the **Speculator Project** and
provides operational instructions for an AI continuing the work.
Read it entirely before proposing any changes.

---

## What this project is

A Bash script (`speculator_install.sh`) that configures a Debian 13 "Trixie"
(amd64) VM as a complete OSINT environment. It installs tools, browsers,
launcher scripts and customises the GNOME desktop.
Inspired by *OSINT Techniques, 11th Edition* by Michael Bazzell.

Key files:
- `speculator_install.sh`: main installation script (v8.0)
- `scripts/user.sh`: Zenity GUI script for running OSINT tools against a target
- `document/CHANGELOG.md`: full history of changes
- `document/FAQ.md`: frequently asked questions
- `document/speculatores.md`: historical background on the project name

---

## Current state: PHASE A complete

Phase A (structural rewrite) is **complete**. The script is stable, tested in
dry-run mode, and ready for testing on a real VM.

### What has been done (v8.0)

- Sudo-safe user detection (`REAL_USER` / `REAL_HOME` via `SUDO_USER`)
- XDG-compliant directories (`~/.local/share/speculator/`, `~/.config/speculator/`)
- Dry-run mode (`--dry-run`) via bash function shadowing
- Full tee logging to file
- Installation tracking (`_INSTALL_OK` / `_INSTALL_FAIL` arrays)
- `install_py_tool_from_git()` helper with per-tool isolated venvs
- `run_as_user()`, `tracked()`, `_download_asset()` helpers
- Debian detection with version warning for non-Trixie systems
- IntelTechniques credentials externalised as env vars
- GNOME guards: version check, D-Bus session, `pgrep gnome-shell`
- 14+ critical bug fixes (see CHANGELOG.md for full list)
- `.gitignore` properly configured

---

## Phases still to complete

### PHASE B: Custom launcher scripts (HIGH PRIORITY)

**Problem**: the project currently downloads launcher scripts
(`api.sh`, `domain.sh`, `user.sh`, etc.) directly from
`inteltechniques.com/osintvm` using book credentials.
This creates a dependency on an external site and credentials not everyone
has. The original scripts may change or become unavailable.

**Goal**: create independent versions of each launcher script in
`scripts/` that replace the IntelTechniques downloads.

**Files to create**:
```
scripts/
  api.sh        - API tools (Shodan, Censys, etc.)
  domain.sh     - domain tools (Amass, Sublist3r, theHarvester, etc.)
  framework.sh  - OSINT frameworks (Recon-ng, SpiderFoot, Sn0int)
  image.sh      - image tools (ExifTool, MAT2, etc.)
  metadata.sh   - metadata tools (Carbon14, Metagoofil, etc.)
  update.sh     - update all tools via pipx / git pull
  user.sh       - already present, but needs fixes (see Phase E)
  video.sh      - video tools (yt-dlp, streamlink, gallery-dl)
```

Each script must:
- Use Zenity for the GUI (consistent with `scripts/user.sh`)
- Save output to `~/Desktop/evidences/{target}/`
- Follow the same coding style as the existing `scripts/user.sh`

---

### PHASE C: Normalised JSON output (MEDIUM PRIORITY)

**Goal**: add structured JSON output to every OSINT tool call so results
can be inserted into a database.

**Target schema** (one JSON file per execution):
```json
{
  "timestamp": "2026-04-01T12:00:00Z",
  "target": "example@email.com",
  "target_type": "email",
  "tool": "holehe",
  "results": [ ... ],
  "raw_output_file": "path/to/raw.txt"
}
```

**Where to apply**: in the Phase B scripts, add a parser that transforms each
tool's text output into the above format and writes it to
`~/Desktop/evidences/{target}/{tool}-{timestamp}.json`.

---

### PHASE D: Phone number category in `scripts/user.sh` (MEDIUM PRIORITY)

**Goal**: add detection and handling of phone numbers as an input type,
alongside email / hash / username.

**Tools to integrate**:
- `phoneinfoga` (already installed via Go in `speculator_install.sh`)
- `ignorant` (already installed via pipx)

**Changes to `scripts/user.sh`**:
1. Add a phone number detection pattern in `classify_input()`:
   ```bash
   # International format: +39 333 1234567 or 00393331234567
   if [[ "$value" =~ ^\+?[0-9]{7,15}$ ]]; then echo "phone"; return; fi
   ```
2. Add `run_phone_tools()` and `run_all_phone_tools()` functions
3. Add the `"phone"` case to the `main()` switch

---

### PHASE E: Bug fixes in `scripts/user.sh` (HIGH PRIORITY)

The file `scripts/user.sh` contains three known bugs:

#### Bug 1: Recursion in `main()` (CRITICAL)
```bash
# CURRENT (causes stack overflow on long sessions):
if [ "$?" -eq 0 ]; then
    main   # ← recursive call!
fi
```
```bash
# CORRECT: use a while loop
main() {
    while true; do
        # ... current logic ...
        zenity --question ... || break
    done
}
```

#### Bug 2: Wrong maigret path (CRITICAL)
```bash
# CURRENT (venv does not exist; maigret is installed via pipx):
source ~/Downloads/Programs/maigret/maigretEnvironment/bin/activate
maigret ...
deactivate
```
```bash
# CORRECT: call the pipx binary directly
"$HOME/.local/bin/maigret" -a -T "$inputValue" --folderoutput="$sessionDir"
```

#### Bug 3: Wrong Eyes path (MINOR)
```bash
# CURRENT:
pushd ~/Downloads/Programs/eyes/Eyes

# CORRECT (repo is cloned as "Eyes", not "eyes/Eyes"):
pushd ~/Downloads/Programs/Eyes
```

---

## Rules to follow during development

1. **Do not edit** `document/CHANGELOG.md` mid-phase. Update it only at the
   end of each phase with a new `## [8.x]` block.
2. **Do not create files in the project root.** Use `scripts/` for scripts
   and `document/` for documentation.
3. **Keep the `tracked()` / `mark_ok()` / `mark_fail()` pattern** for any new
   tool added to `speculator_install.sh`.
4. **Target OS**: Debian 13 "Trixie" amd64. Do not introduce dependencies
   unavailable in the official Debian 13 repos or via pipx / go / flatpak.
5. **Zenity** is the UI framework for all scripts in `scripts/`.
6. **Evidence output** always goes to `~/Desktop/evidences/{target}/`.
7. **Always read a file in full** before modifying it.
8. **Never hardcode user paths.** Use `$HOME` or XDG variables.

---

## Open questions / pending decisions

- **Language for Phase B scripts**: create separate multilingual versions
  (IT/EN/RU/ZH) or a single script with runtime language selection?
- **Database backend for Phase C**: SQLite, flat JSON files, or something
  else? Decide before implementing parsers.
- **Argos**: evaluated (modular Python OSINT tool) but not integrated. Out of scope for now.

---

## How to test

```bash
# Full simulation on any OS (including Windows Git Bash)
sudo ./speculator_install.sh --dry-run

# Test on a real Debian 13 VM
sudo ./speculator_install.sh

# Override credentials
INTEL_USER=xxx INTEL_PASS=yyy sudo ./speculator_install.sh
```

Logs available at: `~/.local/share/speculator/logs/`

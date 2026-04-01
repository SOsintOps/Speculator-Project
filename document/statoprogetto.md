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
- `scripts/user.sh`: Zenity GUI script for running OSINT tools against a target (v2.0.0)
- `document/CHANGELOG.md`: full history of changes
- `document/FAQ.md`: frequently asked questions
- `document/speculatores.md`: historical background on the project name
- `tests/test_speculator_install.sh`: automated test suite (24 tests)

---

## Current state: PHASE A and PHASE E complete

Phase A (structural rewrite) and Phase E (user.sh bug fixes) are both **complete**.

### What has been done (v8.0 + Phase E)

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
- `scripts/user.sh` v2.0.0: all Phase E bugs fixed (see below)
- `tests/test_speculator_install.sh`: 24 automated tests, all passing

### Phase E fixes applied to `scripts/user.sh` (v2.0.0, commit 6345832)

1. **Recursion in `main()`**: replaced with `while true` loop — no more stack overflow
2. **Maigret path**: removed venv activation, calls `maigret` directly (installed via pipx); added `-P` flag for PDF output
3. **Eyes path**: corrected from `~/Downloads/Programs/eyes/Eyes` to `"$HOME/Downloads/Programs/Eyes"` — Speculator installs Eyes directly to `~/Downloads/Programs/Eyes` (not `eyes/Eyes`)
4. **pushd error handling**: all 6 `pushd` calls now have `|| { zenity --error ...; return 1; }` guard
5. **`~` → `$HOME`**: 12 substitutions throughout the file
6. **BDFR flag**: `--all-comments` → `--allcomments` (correct flag per book v11)
7. **EVIDENCE_DIR**: changed to `$HOME/Desktop/evidence` (no trailing 's')
8. **Empty REQUIRED_TOOLS entry**: removed blank line in array
9. **h8mail config path**: normalised to `"$HOME/Downloads/h8mail_config.ini"`

### Important CLI facts (confirmed from OSINT Techniques book v11, 2025)

| Tool | Correct CLI syntax |
|---|---|
| holehe | `holehe email@example.com > output.txt` (stdout redirect) |
| socialscan | `socialscan email --json output.txt` (file path is argument to `--json`) |
| sherlock | `sherlock user --csv -o output.csv` |
| maigret | `maigret -a -P -T user --folderoutput=dir/` |
| whatsmyname | `python3 whatsmyname.py -u user` |
| bdfr | `bdfr archive dir/ --user user --submitted` + `--allcomments` |
| h8mail | `h8mail -t email -c ~/Downloads/h8mail_config.ini` |
| nth / sth | `nth --text hash` / `sth --text hash` |
| blackbird | `python3 blackbird.py -u user --pdf` |
| ghunt | `ghunt email address` |
| Eyes | Installed at `~/Downloads/Programs/Eyes/` (capital E, no parent dir) |
| Maigret | Installed via pipx → binary at `~/.local/bin/maigret` or in PATH |

---

## Phases still to complete

### PHASE B: Custom launcher scripts (HIGH PRIORITY)

**Problem**: the project currently downloads launcher scripts from `inteltechniques.com/osintvm` using book credentials. This creates an external dependency. The goal is to create independent versions in `scripts/`.

**Files to create** (all must use Zenity GUI, save output to `~/Desktop/evidence/{target}/`):

#### `scripts/domain.sh` — domain investigation
CLI syntax from book v11:
```bash
cd ~/Downloads/Programs/Amass && ./amass intel -o ~/Desktop/evidence/$target/amass.txt -active -ip -whois -d $target
cd ~/Downloads/Programs/Sublist3r && python3 sublist3r.py -d $target -o ~/Desktop/evidence/$target/sublist3r.txt
cd ~/Downloads/Programs/theHarvester && python3 theHarvester.py -d $target -f ~/Desktop/evidence/$target/harvester.json -b duckduckgo
cd ~/Downloads/Programs/Photon && python3 photon.py -u $target -l 3 -t 100
httrack / webhttrack  # GUI-based
```

#### `scripts/video.sh` — video download and processing
```bash
yt-dlp "URL"
yt-dlp "URL" --write-comments --write-subs --sub-langs all --write-description
yt-dlp "URL" -x --audio-format mp3
streamlink URL best -o output.ts
gallery-dl URL
```

#### `scripts/image.sh` — image tools
```bash
exiftool file.jpg
exiftool * -csv > ~/Desktop/evidence/$target/exif.csv
mat2 file.pdf
xeuledoc $url
cd ~/Downloads/Programs/sherloq/gui && python3 sherloq.py  # GUI
```

#### `scripts/metadata.sh` — metadata analysis
```bash
cd ~/Downloads/Programs/Carbon14 && source Carbon14Environment/bin/activate && python3 carbon14.py $url && deactivate
cd ~/Downloads/Programs/metagoofil && python3 metagoofil.py -d $target -t pdf
mediainfo file
```

#### `scripts/api.sh` — API frameworks
```bash
cd ~/Downloads/Programs/spiderfoot && source spiderfootEnvironment/bin/activate && python3 sf.py -l 127.0.0.1:5001  # opens browser
cd ~/Downloads/Programs/recon-ng && source recon-ngEnvironment/bin/activate && ./recon-ng
shodan search "query"   # via pipx
censys search "query"   # via pipx
```

#### `scripts/instagram.sh` — Instagram OSINT
```bash
instaloader --login=USERNAME TARGET_PROFILE
toutatis -u USERNAME -s SESSION_ID
cd ~/Downloads/Programs/Osintgram && source OsintgramEnvironment/bin/activate && python3 -m osintgram TARGET
```

#### `scripts/reddit.sh` — Reddit OSINT
```bash
bdfr archive ~/Desktop/evidence/$target/BDFR/ --user $target --submitted
bdfr archive ~/Desktop/evidence/$target/BDFR/ --user $target --allcomments
redditsfinder $target
cd ~/Downloads/Programs/DownloaderForReddit && source DownloaderForRedditEnvironment/bin/activate && python3 main.py
```

#### `scripts/archives.sh` — web archives
```bash
waybackpy --url $target --known_urls > output.txt
internetarchive search "$target"
cd ~/Downloads/archivebox && archivebox add $url
```

#### `scripts/update.sh` — update all tools
```bash
pipx upgrade-all
for d in ~/Downloads/Programs/*/; do
  [ -d "$d/.git" ] && git -C "$d" pull || true
done
```

Each script must:
- Use Zenity for the GUI (consistent with `scripts/user.sh`)
- Save output to `~/Desktop/evidence/{target}/`
- Follow the same coding style as `scripts/user.sh` v2.0.0
- Use `$HOME` instead of `~`
- Have `pushd` error handling

---

### PHASE C: Normalised JSON output (MEDIUM PRIORITY)

**Goal**: add structured JSON output to every OSINT tool call.

**Target schema**:
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

**Where to apply**: in the Phase B scripts, add a parser that transforms each tool's text output into the above format and writes to `~/Desktop/evidence/{target}/{tool}-{timestamp}.json`.

---

### PHASE D: Phone number category in `scripts/user.sh` (MEDIUM PRIORITY)

**Goal**: add detection and handling of phone numbers as an input type.

**Tools available** (already installed via pipx in `speculator_install.sh`):
- `ignorant` — installed via pipx
- `PhoneNumber-OSINT` (GitHub: spider863644/PhoneNumber-OSINT) — identified from Cyber Detective TG

**Changes to `scripts/user.sh`**:
1. Add phone number detection in `classify_input()`:
   ```bash
   if [[ "$value" =~ ^\+?[0-9]{7,15}$ ]]; then echo "phone"; return; fi
   ```
2. Add `run_phone_tools()` and `run_all_phone_tools()` functions
3. Add `"phone"` case to the `main()` while loop

---

## Additional tools identified for future phases

These tools were found in the swarm analysis (Cyber Detective TG 3393 msgs, OSINTops TG 3552 msgs, Deep Dive PDF, OSINT book v11). Not yet integrated.

### High priority
- **Turboholehe** — enhanced holehe: generates email variants from name+surname, CSV output
- **Mailcat** (`python mailcat.py username`) — finds email addresses by username
- **sn0int** — lightweight alternative to Recon-ng with integrated package manager
- **Nuclei** + OSINT templates — extracts email, links, Bitcoin addresses, nicknames from web
- **Bellingcat OSM Search** (github.com/bellingcat/osm-search) — geolocation via OpenStreetMap
- **Aleph / OCCRP** (aleph.occrp.org) — one of the largest leaked documents databases
- **PhoneNumber-OSINT** (github.com/spider863644/PhoneNumber-OSINT) — CLI phone OSINT

### Medium priority
- **Terra** (`python3 terra.py username`) — username recon, extracts phone from follower bios
- **Profil3r** — finds accounts and breached emails for a person
- **Zeeschuimer** (Firefox addon) — native scraping of Instagram, Twitter, LinkedIn, TikTok
- **EagleEye** (`python eagleeye.py --image path`) — reverse image + target localisation
- **Spyse CLI** (github.com/spyse-com/cli) — domain/IP/organization lookup
- **Maryam** — OSINT framework with modules for email, social, domains (similar to Recon-ng)
- **Instagram Location Search** (github.com/bellingcat/instagram-location-search) — extract Instagram locations by GPS coordinates

### Deprecated / broken
- **Twint** — broken since Twitter API v2 (2022), do not integrate

---

## Pending decisions

- **Language for Phase B scripts**: single script with runtime language selection (IT/EN/RU/ZH) or separate files per language?
- **Database backend for Phase C**: SQLite, flat JSON files, or something else?

---

## Rules to follow during development

1. **Do not edit** `document/CHANGELOG.md` mid-phase. Update it only at the end of each phase with a new `## [8.x]` block.
2. **Do not create files in the project root.** Use `scripts/` for scripts and `document/` for documentation.
3. **Keep the `tracked()` / `mark_ok()` / `mark_fail()` pattern** for any new tool added to `speculator_install.sh`.
4. **Target OS**: Debian 13 "Trixie" amd64. Do not introduce dependencies unavailable in official Debian 13 repos or via pipx / go / flatpak.
5. **Zenity** is the UI framework for all scripts in `scripts/`.
6. **Evidence output** always goes to `~/Desktop/evidence/{target}/` (no trailing 's').
7. **Always read a file in full** before modifying it.
8. **Never hardcode user paths.** Use `$HOME` or XDG variables. Never use `~` in scripts.
9. **All pushd calls** must have `|| { zenity --error ...; return 1; }` error handling.

---

## How to test

```bash
# Syntax check all scripts
bash -n speculator_install.sh
bash -n scripts/user.sh

# Full automated test suite
bash tests/test_speculator_install.sh

# Full simulation on any OS (including Windows Git Bash)
sudo ./speculator_install.sh --dry-run

# Override credentials
INTEL_USER=xxx INTEL_PASS=yyy sudo ./speculator_install.sh
```

Logs available at: `~/.local/share/speculator/logs/`

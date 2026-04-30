# Changelog: Speculator Project

All notable changes to this project will be documented in this file.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

---

## [0.9.0] - 2026-04-30

### Hub-and-spoke architecture complete, Maigret Enhanced web UI, 21 bug fixes

#### Added
- **8 Phase B spoke scripts** (`domain.sh`, `instagram.sh`, `reddit.sh`, `video.sh`,
  `archives.sh`, `image.sh`, `frameworks.sh`, `update.sh`): all manifest-driven via
  `common.sh` + `config/tools.conf`. Each follows hub-and-spoke pattern with Zenity GUI.
- **8 desktop shortcuts** for all new spoke scripts in `shortcuts/`.
- **Maigret Enhanced web UI** (`scripts/maigret-enhanced/`): FastAPI server with SSE
  real-time progress, D3.js force-directed graph (drag/zoom/fullscreen), multi-target
  tabs, tag cloud filtering, profile table with sort/filter/star, export to
  CSV/JSON/TXT/PDF/HTML, live hit flash notifications, investigation notes.
- **Icon generation prompts** (`documents/icon-prompts.md`): 11 Gemini prompts for
  coherent Elementary noir-style icon set (never showing full faces).
- **`tests/test_refactor.sh`**: 87 automated tests covering manifest loading,
  classify_input (14 cases incl. phone), function availability, no-duplication checks.

#### Changed
- **`scripts/user.sh`** (v0.4.1.0 -> v0.5.0): refactored from 718 to 119 lines.
  Sources `common.sh`, all tool execution via `run_category()`. Keeps `classify_input()`
  (with phone regex), `resolve_unknown_category()`, `main()`.
- **`scripts/lib/common.sh`** (v0.1.0 -> v0.2.0): concurrency hardening:
  `_session_log()` uses `flock` for atomic writes; `run_repo_python_tool()` uses
  subshell+cd instead of pushd/popd (race-safe); `run_category()` gains parallel
  execution support. `log_step` info/skip cases now display `$extra` parameter.

#### Fixed — 21 bugs found and corrected via agent-driven code review
- **scanner.py**: double "done" event (`finish()` + `finally` both sent done, could
  mask errors). Fixed: `finish()` is now a no-op, only `finally` sends done.
- **scanner.py**: file handle leaks in `get_db()` and `generate_export()`. Fixed: use
  `with` statements.
- **server.py**: broken JSON from unescaped error message in SSE stream. Fixed: use
  `json.dumps()`.
- **server.py**: keepalive `{}` caused NaN in client progress display. Fixed: send SSE
  comment (`: keepalive`).
- **server.py**: `import json` inside loop. Fixed: moved to module top.
- **server.py**: no username validation (header injection risk). Fixed: 1-64 char,
  alphanumeric + `._-` only.
- **app.js**: XSS via innerHTML in 4 locations (renderProfiles, addTargetTab,
  showLiveHit, renderTagsHeatmap). Fixed: DOM API with createElement/textContent.
- **app.js**: tag heatmap filter searched site/url but not tags. Fixed: added tag check.
- **app.js**: no `res.ok` checks on fetch responses. Fixed: error handling added.
- **app.js**: SSE `onerror` called `fetchResults` unconditionally. Fixed: `done` flag
  prevents double fetch.
- **frameworks.sh**: empty `session_dir` caused broken output paths at `/`. Fixed:
  calls `create_session_dir`.
- **frameworks.sh**: showed raw IDs instead of display names. Fixed: uses `_MF_NAME`.
- **frameworks.sh**: no availability check before launch. Fixed: `tool_available` check.
- **6 spoke scripts**: duplicate empty `print_summary` (already called by
  `run_category`). Fixed: removed redundant calls.
- **update.sh**: pipx error detection never reported failures. Fixed: captures exit code.
- **update.sh**: git pull detection broken (subshell echo uncaptured). Fixed: uses
  `git -C` with HEAD comparison.
- **common.sh**: `log_step` "info" and "skip" ignored `$extra` parameter. Fixed: now
  displayed on screen.
- **common.sh**: `run_manifest_tool` word splitting broke file paths with spaces.
  Fixed: split command template before substituting placeholder values, then expand
  each array element individually.
- **Mr.Holmes**: disabled in `tools.conf` — fully interactive TUI with no CLI flags.
  The `-u` and `--all` flags were non-existent; tool only works via `input()` prompts.
- **`speculator_install.sh`**: added `scripts/lib/` and `scripts/maigret-enhanced/`
  copy. Added `spiderfoot.png -> speculator-framework.png` to `_ICON_MAP`. Fixed
  `_GNOME_FAVS`: replaced stale `speculator-metadata` and `speculator-api` with
  `speculator-instagram` and `speculator-frameworks`.

---

## [0.8.9] - 2026-04-29

### SpiderFoot removed, Maigret web UI, Firefox policies, project restructure

#### Removed
- **SpiderFoot**: removed entirely after 5 failed lxml fix attempts across v0.8.6-v0.8.8.
  All references removed from installer, scripts, config and shortcuts.
- **8 Phase B launcher scripts** (`api.sh`, `archives.sh`, `domain.sh`, `image.sh`,
  `instagram.sh`, `metadata.sh`, `reddit.sh`, `video.sh`): removed pending full rewrite.
- **`shortcuts/usernames.desktop`**: stale file with hardcoded `/home/osint/` paths.
- **`tests/test_speculator_install.sh`**: removed.

#### Added
- **Maigret web UI** (`scripts/maigret-web.sh`): native pipx launch on port 5001.
  Symlinks `/tmp/maigret_reports` into `~/Downloads/evidence/maigret/reports/`.
  Desktop shortcut and GNOME taskbar entry added.
- **Firefox ESR enterprise policies** (`config/policies.json`): 16 privacy policies, 12 extensions (uBlock Origin,
  CanvasBlocker, ClearURLs, Multi-Account Containers, Exif Viewer, Wayback Machine,
  GPS Detect, Search by Image, Nimbus Screenshot, Resurrect Pages, Link Gopher,
  Mitaka), 34 OSINT bookmarks organised in 8 themed folders plus 3 top-level
  dashboard links (AML Toolbox, Nixintel, Terrorism Research).
- **`config/tools.conf`**: pipe-delimited tool manifest (57 tools).
- **`scripts/lib/common.sh`** (v0.1.0): shared library for all launcher scripts.
  Manifest loading, Zenity checklist builder, run_tool/run_repo_python_tool with
  semantic error detection, session logging, and generic `run_category()` flow.
- **OSINT report templates** (`templates/`): Cherry Tree master template, executive
  reports, case directory structure, scratch notes.
- **GitHub community files**: `CONTRIBUTING.md`, `SECURITY.md`, issue templates
  (bug report, feature request).
- **Speculator mascot** (`media/speculator.png`): Scribblenauts-style character in
  README Overview section.

#### Changed
- **`document/` renamed to `documents/`** for English consistency. All references updated.
- **README.md**: rewritten with badges, Argos lineage, quick install one-liner,
  inline tool lists (A-Z), 59 tools across 8 categories.
- **License**: switched from Unlicense to MIT (copyright SOsintOps 2026).
- **Disclaimer**: explicit non-affiliation with Michael Bazzell and IntelTechniques.
- **Commit history**: reworded v0.8.5 commit to remove IntelTechniques references.

#### Fixed — `speculator_install.sh`
- **`_REPO_DIR` undefined at Phase 2**: variable was defined at Phase 4 (line 624)
  but used at Phase 2 for Firefox policies. Moved to global scope (line 55).
- **Firefox policies.json permission denied**: added `sudo` prefix to `mkdir`,
  `cp` and `chmod` for `/usr/lib/firefox-esr/distribution/`.
- **Version banner stale**: runtime banner said `v0.8.2`, updated to `v0.8.9`.
- **`local` outside function**: removed invalid `local` keyword in Firefox policy block.
- **Version bumped to 0.8.9**.
- **56/56 components installed** (verified on VM, 2026-04-29): zero failures.

---

## [0.8.8] - 2026-04-08

### 5 new name checkers, Investigo, SpiderFoot lxml fix v4

#### Added — `speculator_install.sh`
- **Naminter**, **Social-Analyzer**, **Aliens Eye**, **Enola**, **Stalkie**: five new
  username/name checker tools added via `install_py_tool_from_git`.
- **Investigo**: username checker added via Go install.

#### Fixed — `speculator_install.sh`
- **SpiderFoot lxml fix v4**: force system-site-packages in venv, echo override for
  lxml import. Still failed; led to full removal in v0.8.9.
- **Version bumped to 0.8.8**.

---

## [0.8.7] - 2026-04-08

### SpiderFoot lxml fix v3, user.sh session log enrichment

#### Fixed — `speculator_install.sh`
- **SpiderFoot lxml fix v3**: removed lxml from requirements.txt entirely, installed
  all other deps first, then force-reinstalled `lxml>=5.0.0` separately. Fix v2
  (constraint file) failed due to transitive dependency conflict.

#### Changed — `scripts/user.sh` (v0.4.1.0)
- **Session log enrichment**: now records selected tools, exact command, stdout and
  stderr per tool. Previously only status markers were written.
- **Version bumped to 0.8.7**.

---

## [0.8.6] - 2026-04-07

### Installer bug fixes, user.sh v0.4.0.0

#### Fixed — `speculator_install.sh`
- **h8mail**: `h8mail -g` now runs from `$REAL_HOME` so config lands at correct path.
- **Profil3r**: fallback to `pip install -e .` when `setup.py` present but no
  `requirements.txt`.
- **Turbolehe**: removed from `PIPX_PACKAGES`; installed via git clone from
  `github.com/purrsec/Turbolehe`.
- **SpiderFoot lxml fix v2**: python3 rewrites requirements.txt (handles CRLF);
  pip constraint file pins `lxml>=5.0.0` in venv.

#### Added — `speculator_install.sh`
- **evince** added to `PACKAGES` (PDF reader).

#### Changed — `scripts/user.sh` (v0.4.0.0)
- Replaced Gum/whiptail with `zenity --list --checklist` (flat multi-select with
  Status column).
- `export PATH` includes `~/.local/bin` (fixes Missing Tools false positive from
  desktop launcher).
- Mr.Holmes entry point corrected: `Holmes.py` to `MrHolmes.py`.
- **Version bumped to 0.8.6**.

---

## [0.8.5] - 2026-04-07

### Evidence shortcut in dock; language support fixes

#### Added — `speculator_install.sh`
- **Evidence dock shortcut**: `shortcuts/evidence.desktop` installed as
  `speculator-evidence.desktop`. Appears in the dock between Nautilus and Terminal.
  Opens `~/Downloads/evidence` via `xdg-open`. Uses `evidence.png` from `media/icons/`.

#### Fixed — `speculator_install.sh`
- **System default locale**: `update-locale LANG=en_GB.UTF-8 LC_MESSAGES=en_GB.UTF-8`
  added after package installation. `locales-all` installs all locale definitions
  but never sets the system default; without this the VM boots with the installer's
  inherited locale rather than British English.
- **Chinese input method**: added `ibus` and `ibus-gtk3` to PACKAGES explicitly.
  `ibus-pinyin` was already listed but depends on `ibus`; without the base package
  GNOME cannot load the input method engine. Added `fonts-noto-cjk` for
  comprehensive CJK font coverage alongside `fonts-wqy-zenhei`.

#### Changed — `speculator_install.sh`
- **Version bumped to 0.8.5**.

---

## [0.8.4] - 2026-04-07

### Architecture: self-contained installer; XDG-compliant directory layout; shortcuts system

#### Changed — `speculator_install.sh`
- **Version bumped to 0.8.4**.
- **`PROGRAMS_DIR` moved to XDG location**: changed from `$HOME/Downloads/Programs`
  to `$HOME/.local/share/speculator/programs`. All git-cloned tools now install into
  the same XDG subtree as scripts, icons and config. A Nautilus bookmark named
  "Speculator" is added to `~/.config/gtk-3.0/bookmarks` for easy access.
- **Installer is now fully self-contained**: all scripts, desktop shortcuts and icons
  are sourced from the repository. No external download is required at install time.
- **Scripts installed from repo**: all `scripts/*.sh` files are now copied from the
  local repository to `$SCRIPTS_DIR` at install time.
- **Icons installed from repo**: `media/icons/` assets are copied to `$ICONS_DIR`
  with the `speculator-` naming convention (e.g. `user.png` → `speculator-user.png`).
- **Shortcuts installed from repo**: all `shortcuts/*.desktop` templates are installed
  as `speculator-<name>.desktop` with `__HOME__` substituted for the actual home path.
- **`_GNOME_FAVS` updated**: `speculator-framework.desktop` and
  `speculator-search.desktop` removed (no local replacements yet).

#### Changed — `scripts/` (all Phase B scripts)
- **`PROGRAMS_DIR` variable added** to `user.sh`, `api.sh`, `domain.sh`,
  `instagram.sh`, `metadata.sh`. All hardcoded `$HOME/Downloads/Programs/` paths
  replaced with `$PROGRAMS_DIR/`. Scripts without venv paths (`archives.sh`,
  `video.sh`, `reddit.sh`, `image.sh`) required no changes.

#### Added — `shortcuts/user.desktop`
- New shortcut template for `user.sh`. Display name: **Person**. Uses `__HOME__`
  placeholder substituted at install time. `Terminal=false` (Zenity GUI).
  Replaces `shortcuts/usernames.desktop` (which had hardcoded `/home/osint/` paths).

#### Added — `documents/FAQ.md`
- New entry: *"Why does Firefox take a long time to start the first time after
  installation?"* — clarifies that the delay is normal on first launch.

---

## [0.8.3] - 2026-04-06

### Phase B launcher scripts added; version numbering moved to 0.x pre-release scheme

#### Added
- **Phase B scripts** (all at version 0.1.0): eight Zenity GUI launcher scripts added
  to `scripts/`: `domain.sh`, `video.sh`, `image.sh`, `metadata.sh`, `api.sh`,
  `instagram.sh`, `reddit.sh`, `archives.sh`. Each writes output to
  `$HOME/Downloads/evidence/{target}/`.
- **`media/icons/`**: desktop icon assets committed.
- **`shortcuts/`**: legacy `.desktop` reference files committed.

#### Changed
- **Version numbering**: all version strings moved to `0.x` pre-release scheme.
  Versioned releases begin at `1.0.0`. Mapping: `v8.x → 0.8.x`, `v2.x.y → 0.2.x.y`,
  `v1.0.0 (Phase B) → 0.1.0`.

---

## [0.8.2] - 2026-04-05

### Installer fixes and user.sh 0.2.0.3

#### Fixed — `speculator_install.sh`
- **Wallpaper path**: corrected from `wallpapers/speculator1.jpg` to
  `media/wallpapers/speculator1.jpg`; wallpaper was silently skipped and
  desktop fell back to the solid colour `rgb(66, 81, 100)`.
- **Taskbar (GNOME 47 incompatibility)**: replaced `gnome-shell-extension-dash-to-dock`
  with `gnome-shell-extension-dash-to-panel`. `dash-to-dock` is incompatible with
  GNOME 47 (Debian Trixie) and caused the top panel to disappear entirely.
  Phase 5 now disables `dash-to-dock`, enables `dash-to-panel`, and configures a
  bottom panel at height 36px.
- **`zenity` missing from PACKAGES**: added to the Desktop / utilities group.
  `user.sh` requires Zenity; it was not being installed by the script.
- **`user.sh` local copy**: Phase 4 now copies `scripts/user.sh` from the repo to
  `$SCRIPTS_DIR`, ensuring the repo version is always used.

#### Added — `speculator_install.sh`
- **`turboholehe`**: added to `PIPX_PACKAGES`.
- **`mailcat`**: added via `install_py_tool_from_git`.
- **`Profil3r`**: added via `install_py_tool_from_git`.

#### Fixed — `scripts/user.sh` (0.2.0.3)
- **`blackbird` removed from `REQUIRED_TOOLS`**: Blackbird is a Python script,
  not a PATH binary. `command -v blackbird` always failed, causing the script
  to exit at startup. Blackbird presence is now verified via `pushd` at call time.
- **`h8mail` config path**: corrected from `$HOME/Downloads/h8mail_config.ini`
  to `$HOME/h8mail_config.ini` (where the installer generates it via `h8mail -g`).
- **`h8mail -q username` flag removed**: `-q` is not a valid h8mail flag. Removed
  from both `run_all_username_tools` and the `Username-H8Mail` menu case.
- **Eyes output message**: `run_all_email_tools` now shows a Zenity info dialog
  after Eyes completes, informing the user that output is in the Eyes directory
  (Eyes does not support a custom output path).
- **Turboholehe input**: Turboholehe takes a name+surname, not an email address.
  The menu option now opens a separate Zenity entry asking for first and last name.
  Removed from `run_all_email_tools` (no name context available there).
- **Wayland compatibility**: added `GDK_BACKEND=x11` guard for Wayland sessions.
- **Zenity bootstrap guard**: `check_required_tools` now checks for Zenity itself
  first via `echo >&2` before attempting to use it for error dialogs.

#### Added — `scripts/user.sh` (0.2.0.3)
- **Mr.Holmes**: added to username tools menu and `run_all_username_tools`.
  Runs `python3 Holmes.py -u <username> --all` from `$HOME/Downloads/Programs/Mr.Holmes`;
  output saved to `$sessionDir/$inputValue-MrHolmes.txt`.
- **Turboholehe**: added to email tools menu (asks for name+surname separately).

---

## [0.8.1] - 2026-04-04

### Multiple fixes and additions

#### Added
- **WireTapper** (`git:WireTapper`): wireless/cellular network OSINT tool; requires
  API keys for Wigle.net, wpa-sec, OpenCellID, and Shodan; installed via `install_py_tool_from_git`
  with `WireTapper.txt` requirements.
- **TLDSweep** (`git:TLDSweep`): domain TLD sweep and monitoring tool; pure Python
  stdlib, no requirements file; simple git clone install.
- **Evidence directory**: `$HOME/Downloads/evidence/` created during Phase 4; Desktop
  symlink `$HOME/Desktop/evidence → $HOME/Downloads/evidence` added for easy access.
- **Wallpaper support**: `wallpapers/speculator1.jpg` copied to `$HOME/Pictures/` and
  set via `gsettings picture-uri` with `picture-options 'zoom'`; falls back to solid
  colour if file not present.

#### Fixed
- **phoneinfoga**: replaced `go install github.com/sundowndev/phoneinfoga/v2@latest`
  (fails on Python 3.13 / missing `client/dist/*` assets) with precompiled binary
  download from GitHub Releases (`phoneinfoga_Linux_x86_64.tar.gz`). Binary installed
  to `$HOME/.local/bin/`. Tracking label changed to `bin:phoneinfoga`.
- **recon-ng**: requirements file argument corrected from `"requirements.txt"` back to
  `"REQUIREMENTS"` (the actual filename in the lanmaster53/recon-ng repo).
- **VirtualBox Guest Additions**: removed apt install attempt. Replaced with a
  `lsmod | grep vboxguest` check that marks `vbox:guest-additions` OK if already
  present, or prints manual install instructions and continues without failing.
- **Installation log path**: `LOG_DIR` changed from `~/.local/share/speculator/logs/`
  to `~/Downloads/`; install log and results file now written directly to Downloads.

#### Changed
- **`scripts/user.sh`** (renamed from `users.sh`):
  - Added missing `#!/usr/bin/env bash` shebang.
  - `EVIDENCE_DIR` updated from `$HOME/Desktop/evidence` to `$HOME/Downloads/evidence`.
- **Dock position**: changed from `LEFT` to `RIGHT` via `gsettings dash-to-dock dock-position`.
- **GNOME debloat**: `apt purge` block added in Phase 6. Removed: all GNOME games,
  `gnome-music`, `rhythmbox`, `cheese`, `gnome-weather`, `gnome-clocks`, `gnome-calendar`,
  `gnome-contacts`, `epiphany-browser`, `shotwell`, `gnome-software`.
  Kept: `evolution`, `totem`, `gnome-maps`, `simple-scan`.

---

## [0.8.0] - 2026-04-01

### Structural rewrite of `speculator_install.sh` (v7.3 → v8.0)

#### Added
- **Dry-run mode** (`--dry-run` / `--help` flags): dangerous commands are
  intercepted and printed via bash function shadowing. Allows safe simulation
  of the full install on any OS including Windows Git Bash.
- **Sudo-safe user detection**: `REAL_USER` / `REAL_HOME` resolved via
  `SUDO_USER` + `getent passwd` so all user-space files land in the correct
  home directory even when the script is run as root.
- **XDG-compliant directory layout**:
  - `~/.local/share/speculator/logs/`: install logs
  - `~/.local/share/speculator/scripts/`: launcher scripts
  - `~/.local/share/icons/speculator/`: icons
  - `~/.config/speculator/`: tool configs (e.g. h8mail)
- **Full tee logging** to `$LOG_DIR/install_YYYY-MM-DD_HH-MM-SS.log`;
  machine-readable results written to a separate `install_results_*.txt`.
- **Installation tracking**: `_INSTALL_OK` / `_INSTALL_FAIL` bash arrays +
  `mark_ok()` / `mark_fail()` / `tracked()` helpers; summary table printed
  at the end of every run.
- **`install_py_tool_from_git()`** helper: clones a repo, locates the
  requirements file (up to 3 levels deep), creates an isolated venv per tool,
  installs deps without activating the venv. SpiderFoot `lxml` patch included.
- **`run_as_user()`** helper: runs a command as `$REAL_USER` via `sudo -u`
  when invoked as root; runs it directly otherwise.
- **`sq` / `gpg` fallback** for sn0int keyring dearmoring.
- **Go tools**: `subfinder`, `httpx`, `nuclei`, `phoneinfoga` added alongside
  `amass`.
- **pipx tools added**: `ignorant`, `shodan`, `fierce`, `censys`.
- **archivebox native deps** pre-installed via `apt` before `pipx install`.
- **GNOME version guard**: entire Phase 5 skipped if GNOME < 40.
- **`gnome-extensions enable` session guard**: runs only if `gnome-shell`
  process is detected; logs info message otherwise.
- **`gsettings` session guard**: all `gsettings` calls wrapped in
  `DBUS_SESSION_BUS_ADDRESS` / `DISPLAY` / `WAYLAND_DISPLAY` check.
- **PATH deduplication marker** in `~/.profile`:
  `# speculator-project: Go and pipx PATH` prevents duplicate entries on
  repeated runs.
- **`pgrep` availability guard** in Firefox wait loop with `sleep 3` fallback.
- **Firefox profile detection via `profiles.ini`** (more reliable than glob),
  with glob fallback.
- **`.gitignore`** created: excludes AI tooling (`.claude/`, `.claude-flow/`,
  `.mcp.json`, `CLAUDE.md`), `pdf/`, `**/*.pdf`, `start.ps1`,
  `*.log`, `.claude/settings.local.json`, stray root artefacts.

#### Fixed
- `local` keyword used outside a function in the results block → removed.
- `uv sync --project path` wrong syntax → `uv --project <path> sync`.
- Double `run_as_user` on curl pipe → `run_as_user bash -c "curl … | sh"`.
- `RESULT_FILE` written inside `exec > >(tee …)` block causing double redirect
  → moved outside the `{ }` block.
- `manpages-ru` removed (package does not exist in Debian repos).
- Firefox template: `[ -f file ]` → `[ -f file ] && [ -s file ]` to catch
  empty downloads.
- Firefox termination wait: `sleep 3` (fragile) → 10-iteration pgrep loop.
- `source ~/.cargo/env` called as root → guarded with `[ "$(id -u)" -ne 0 ]`.
- `grep -oP` (non-POSIX) → `grep -o '[0-9]*'` for minimal Debian installs.
- `$SCHEMA_ARG` unquoted variable → `SCHEMA_ARGS=()` array with conditional
  `--schemadir` element.
- `hash -r` added after bulk `apt install` so newly installed binaries
  (e.g. `sq`) are visible to subsequent commands.
- Multiline gsettings favourites string → single-line `_GNOME_FAVS` variable.
- `gtk-update-icon-cache` → added `-f -t` flags.
- **recon-ng**: `install_py_tool_from_git … "REQUIREMENTS"` →
  `"requirements.txt"` (matching the actual filename in the repo).

#### Changed
- Script version bumped from 7.3 to 8.0.
- Target OS explicitly Debian 13 "Trixie" (amd64); script warns and continues
  on other Debian versions.
- Stray root artefact files (`Cloning`, `Configuring`, `Debian`, `Downloading`,
  `Installing`) removed from the repository.

---

## [7.3] - (pre-rewrite baseline)

Original script. Single-user hardcoded paths, no tracking, no dry-run.
Targeted earlier Debian versions. No structured changelog maintained.

---

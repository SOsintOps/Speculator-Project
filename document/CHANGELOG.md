# Changelog: Speculator Project

All notable changes to this project will be documented in this file.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

---

## [8.0] - 2026-04-01

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
- **`_download_asset()`** helper (Phase 4): downloads IntelTechniques assets,
  validates size and MIME type, removes files that are empty or HTML error
  pages (wrong credentials detection).
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
- Intel Techniques credentials externalised to env vars
  `INTEL_USER` / `INTEL_PASS` (defaults preserved for backwards compatibility).
- Stray root artefact files (`Cloning`, `Configuring`, `Debian`, `Downloading`,
  `Installing`) removed from the repository.

---

## [7.3] - (pre-rewrite baseline)

Original script. Single-user hardcoded paths, no tracking, no dry-run.
Targeted earlier Debian versions. No structured changelog maintained.

---

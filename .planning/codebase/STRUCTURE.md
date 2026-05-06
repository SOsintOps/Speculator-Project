# Codebase Structure

**Analysis Date:** 2026-05-06

## Directory Layout

```
Speculator-Project/
├── .github/                    # GitHub configuration
│   └── ISSUE_TEMPLATE/         # Issue templates for bug reports, features
├── .planning/                  # GSD execution planning (generated)
│   └── codebase/               # Codebase analysis documents
├── config/                     # Configuration files
│   └── tools.conf              # Single source of truth: tool manifest (pipe-delimited)
├── documents/                  # Project documentation
│   ├── CHANGELOG.md            # Version history
│   ├── FAQ.md                  # Frequently asked questions
│   ├── icon-prompts.md         # Icon design prompts
│   └── speculatores.md         # Project etymology/naming
├── media/                      # Project assets
│   └── icons/                  # Icon PNG files
├── scripts/                    # Launcher and tool orchestration scripts
│   ├── user.sh                 # Hub launcher (person-tracking: email, username, etc.)
│   ├── domain.sh               # Spoke: domain/infrastructure investigation
│   ├── instagram.sh            # Spoke: Instagram account enumeration
│   ├── reddit.sh               # Spoke: Reddit user archive
│   ├── video.sh                # Spoke: video download/metadata
│   ├── archives.sh             # Spoke: web archive lookups
│   ├── image.sh                # Spoke: image metadata extraction
│   ├── frameworks.sh           # Spoke: framework tools (Recon-NG, sn0int, etc.)
│   ├── maigret-web.sh          # Spoke: Maigret web interface
│   ├── update.sh               # Spoke: tool update management
│   └── lib/
│       └── common.sh           # Shared library: tool execution, UI, logging, manifest parsing
├── shortcuts/                  # Desktop application shortcuts
│   ├── user.desktop            # user.sh entry point
│   ├── domain.desktop          # domain.sh entry point
│   ├── instagram.desktop       # instagram.sh entry point
│   ├── reddit.desktop          # reddit.sh entry point
│   ├── video.desktop           # video.sh entry point
│   ├── archives.desktop        # archives.sh entry point
│   ├── image.desktop           # image.sh entry point
│   ├── frameworks.desktop      # frameworks.sh entry point
│   ├── maigret.desktop         # maigret-web.sh entry point
│   ├── update.desktop          # update.sh entry point
│   ├── evidence.desktop        # Open evidence folder
│   └── maigret.desktop         # Legacy duplicate (intentional?)
├── templates/                  # Not yet used
├── tests/                      # Test suite
│   └── test_refactor.sh        # Test framework for installer refactoring
├── todo/                       # Internal tracking
│   └── todo.md                 # Task list
├── speculator_install.sh       # Main installer (1498 lines)
├── README.md                   # Project overview
├── PROJECT_STATUS.md           # Session state tracking (not committed)
├── CONTRIBUTING.md             # Contribution guidelines
├── SECURITY.md                 # Security policy
├── LICENSE                     # Project license
├── CLAUDE.md                   # Claude AI configuration and conventions
└── .gitignore                  # Git exclusions
```

## Directory Purposes

**`.planning/codebase/`:**
- Purpose: Generated codebase analysis documents (ARCHITECTURE.md, STRUCTURE.md, etc.)
- Contains: Markdown analysis files created by GSD mapping tools
- Key files: (created by mapper)
- Committed: Yes

**`config/`:**
- Purpose: Configuration data and tool metadata
- Contains: Pipe-delimited tool manifest
- Key files: `config/tools.conf` (60+ tool definitions)
- Committed: Yes

**`documents/`:**
- Purpose: User-facing and developer documentation
- Contains: Changelog, FAQ, design notes
- Key files: `documents/CHANGELOG.md`, `documents/FAQ.md`
- Committed: Yes

**`media/`:**
- Purpose: Project assets (icons, images)
- Contains: PNG icon files for desktop shortcuts
- Key files: Icon assets
- Committed: Yes

**`scripts/`:**
- Purpose: Launcher scripts and tool orchestration logic
- Contains: Hub router, spoke launchers, shared library
- Key files: `scripts/user.sh` (hub), `scripts/lib/common.sh` (shared library), spoke scripts
- Committed: Yes

**`scripts/lib/`:**
- Purpose: Shared library for all launcher scripts
- Contains: Tool execution, manifest parsing, UI helpers, session logging, error detection
- Key files: `scripts/lib/common.sh` (19KB, sourced by all launchers)
- Committed: Yes

**`shortcuts/`:**
- Purpose: Desktop application entry points
- Contains: .desktop files for GNOME/X11 application menus
- Key files: `*.desktop` files (copied to `~/.local/share/applications/` at install)
- Committed: Yes

**`tests/`:**
- Purpose: Test framework and test cases
- Contains: Bash test suite for installer validation
- Key files: `tests/test_refactor.sh`
- Committed: Yes

**`todo/`:**
- Purpose: Internal task tracking (development notes)
- Contains: markdown task list
- Key files: `todo/todo.md`
- Committed: Yes

## Key File Locations

**Entry Points:**
- `scripts/user.sh` - Hub launcher (person-tracking searches)
- `scripts/domain.sh`, `scripts/instagram.sh`, etc. - Spoke launchers
- `speculator_install.sh` - System bootstrap and tool installation
- `shortcuts/*.desktop` - Desktop menu shortcuts (installed to `~/.local/share/applications/`)

**Configuration:**
- `config/tools.conf` - Tool manifest (pipe-delimited, 60+ tools)
- `CLAUDE.md` - Claude AI configuration, architecture notes, behavioral rules
- `PROJECT_STATUS.md` - Session status (not committed, created at start of each session)

**Core Logic:**
- `scripts/lib/common.sh` - Shared library for all launchers (tool execution, UI, logging, manifest parsing)
- `scripts/user.sh:classify_input()` - Input classification logic (email, username, phone, hash, fullname)
- `scripts/lib/common.sh:run_category()` - Generic category handler
- `scripts/lib/common.sh:run_manifest_tool()` - Single tool executor

**Testing:**
- `tests/test_refactor.sh` - Bash test framework

**Documentation:**
- `README.md` - Project overview
- `CONTRIBUTING.md` - Contribution guidelines
- `SECURITY.md` - Security policy and responsible disclosure
- `documents/CHANGELOG.md` - Version history
- `documents/FAQ.md` - Frequently asked questions

## Naming Conventions

**Files:**
- Launcher scripts: `{category}.sh` (e.g., `user.sh`, `domain.sh`, `instagram.sh`)
- Shared library: `lib/{name}.sh` in `scripts/lib/`
- Configuration: `{name}.conf` in `config/`
- Desktop shortcuts: `{tool}.desktop` in `shortcuts/`
- Documentation: Descriptive `.md` filenames in `documents/`

**Directories:**
- Tool storage: `$HOME/.local/share/speculator/programs/{tool_name}/`
- Evidence output: `$HOME/Downloads/evidence/{target}/`
- Config: `$HOME/.config/speculator/`
- Desktop shortcuts: `$HOME/.local/share/applications/`
- Session logs: `$HOME/Downloads/evidence/{target}/logs/session-{timestamp}.log`

**Functions (Bash):**
- Prefix with category or layer: `run_tool()`, `run_category()`, `load_manifest()`, `classify_input()`, `create_session_dir()`, `zenity_checklist()`
- Private/internal: Prefix with `_`: `_session_log()`, `_save_error_log()`, `_check_semantic_errors()`, `_progress()`
- UI output: `print_*` prefix: `print_banner()`, `print_section_header()`, `print_summary()`
- Logging: `log_*` prefix: `log_step()`, `log_result()`

**Variables (Bash):**
- Global paths: `UPPERCASE` (e.g., `PROGRAMS_DIR`, `EVIDENCE_DIR`, `SCRIPTS_DIR`)
- Associative arrays (manifest): `_MF_*` prefix (e.g., `_MF_NAME`, `_MF_CMD`, `_MF_VENV`)
- ANSI colors: `C_*` prefix (e.g., `C_CYAN`, `C_RED`, `C_GREEN`)
- Session state: `SESSION_*` prefix (e.g., `SESSION_LOG_FILE`, `SESSION_LOG_DIR`)
- Tool tracking: `TOOL_*` prefix (e.g., `TOOL_STATUS`, `TOOL_DURATION`)

**Tool IDs (in tools.conf):**
- Lowercase, hyphenated: `holehe`, `sherlock`, `socialscan-email`, `bdfr-submitted`, `exiftool-single`, `exiftool-batch`
- Format: `{tool_name}` or `{tool_name}-{variant}` (for tools with multiple modes)

## Where to Add New Code

**New Investigation Type (e.g., "social networks"):**
1. Create launcher script: `scripts/social.sh` (copy from `scripts/domain.sh` template, change category name)
2. Add tools to manifest: Add lines to `config/tools.conf` with `category=social`
3. Create desktop shortcut: `shortcuts/social.desktop` (copy from `shortcuts/domain.desktop`)
4. Source common.sh at top: `source "$SCRIPT_DIR/lib/common.sh"`
5. Implement main() with input dialog, classification if needed, call `run_category("social", ...)`

**New Tool in Existing Category:**
1. Add one line to `config/tools.conf` with correct category (name, id, category, check_type, check_value, command_template, output_ext, needs_venv, venv_name)
2. No code changes needed — manifest is single source of truth
3. Tool automatically available in next launcher run (Zenity checklist populated by `load_manifest()`)

**Shared Helper Function:**
1. Add to `scripts/lib/common.sh`
2. Follow naming convention: `function_name()` (lowercase)
3. Add documentation comment above function explaining purpose and parameters
4. Ensure all paths use `$HOME`, not `~`

**Installer Enhancement:**
1. Edit `speculator_install.sh` directly
2. Wrap in phase (PHASE 1: System, PHASE 2: Dependencies, etc.)
3. Use `tracked "label" command` for install tracking
4. Use `run_as_user` for user-context operations
5. Add to `.planning/codebase/STRUCTURE.md` where files are created

**New Desktop Shortcut:**
1. Create file: `shortcuts/{tool}.desktop`
2. Template:
   ```ini
   [Desktop Entry]
   Type=Application
   Name=Tool Name
   Exec=bash /path/to/scripts/tool.sh
   Icon=speculator
   Terminal=false
   ```

## Special Directories

**Tool Installation:**
- Location: `$HOME/.local/share/speculator/programs/`
- Generated: Yes (during `speculator_install.sh`)
- Committed: No (user-specific, changes at runtime)
- Contents: Tool repositories (cloned via git), virtualenvs

**Evidence Output:**
- Location: `$HOME/Downloads/evidence/{target}/`
- Generated: Yes (each launcher session)
- Committed: No (user data)
- Structure: `{target}/` → `{tool_id}.{ext}`, `logs/session-*.log`

**Configuration:**
- Location: `$HOME/.config/speculator/`
- Generated: Yes (during install)
- Committed: No (user-specific)
- Purpose: Store API keys, tool-specific configs (tool responsibility, not installer)

**Desktop Shortcuts:**
- Location: `~/.local/share/applications/`
- Generated: Yes (copied from `shortcuts/` during install)
- Committed: No (copied from source)
- Purpose: GNOME/X11 application menu integration

**Logs (Installation):**
- Location: `$HOME/Downloads/install_YYYY-MM-DD_HH-MM-SS.log`
- Generated: Yes (during `speculator_install.sh`)
- Committed: No (installation artifacts)
- Purpose: Track what was installed, failures, debugging

## File Organization by Type

**Launcher Scripts** (10 files):
- `scripts/user.sh` - Hub router (person-tracking categories)
- `scripts/{category}.sh` - Spoke launchers (domain, instagram, reddit, video, archives, image, frameworks, maigret-web, update)
- Each sources `scripts/lib/common.sh` at top
- Each implements `main()` with Zenity dialogs and `run_category()` call

**Shared Library** (1 file):
- `scripts/lib/common.sh` - Sourced by all launchers
- Defines: `run_tool()`, `run_category()`, `run_manifest_tool()`, UI primitives, manifest parsing, session logging
- ~500 lines, modular functions

**Configuration** (1 file):
- `config/tools.conf` - Pipe-delimited manifest
- 60+ tool entries, 9 fields per entry
- Updated manually when adding tools, never generated

**Installer** (1 file):
- `speculator_install.sh` - System bootstrap (~1500 lines)
- Single entry point, runs once during setup
- Phases: System prep, dependencies, tool installation, venv creation, desktop shortcuts, configuration

**Documentation** (multiple):
- `README.md` - Project overview
- `CONTRIBUTING.md` - Development guidelines
- `SECURITY.md` - Responsible disclosure
- `CLAUDE.md` - AI config and architecture notes
- `documents/CHANGELOG.md` - Version history
- `documents/FAQ.md` - FAQs

**Tests** (1 file):
- `tests/test_refactor.sh` - Bash test framework for installer validation

**Desktop Integration** (11 files):
- `shortcuts/{tool}.desktop` - GNOME/X11 menu entries

---

*Structure analysis: 2026-05-06*

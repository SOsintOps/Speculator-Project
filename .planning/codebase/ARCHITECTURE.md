# Architecture

**Analysis Date:** 2026-05-06

## System Overview

This is a Bash-based OSINT environment installer and launcher system. The architecture follows a **hub-and-spoke launcher pattern** where a central dispatcher (`user.sh`) routes different investigation types to dedicated spoke scripts and an internal manifest-driven tool executor.

```text
┌─────────────────────────────────────────────────────────────┐
│                    OSINT LAUNCHERS                           │
│                 (User-facing tools)                          │
├──────────────────┬──────────────────┬───────────────────────┤
│   user.sh        │  domain.sh       │  instagram.sh         │
│  (hub router)    │  reddit.sh       │  image.sh             │
│  `scripts/       │  video.sh        │  frameworks.sh        │
│   user.sh`       │  archives.sh     │  update.sh            │
│                  │  maigret-web.sh  │  `scripts/*.sh`       │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         └──────────────────┴─────────────────────┘
                      │
         ┌────────────▼────────────┐
         │   Shared Library Layer  │
         │   `scripts/lib/         │
         │    common.sh`           │
         │                         │
         │ - run_tool()            │
         │ - run_category()        │
         │ - load_manifest()       │
         │ - Zenity UI helpers     │
         │ - Error detection       │
         │ - Session logging       │
         └────────────┬────────────┘
                      │
         ┌────────────▼────────────┐
         │   Configuration Layer   │
         │   `config/tools.conf`   │
         │                         │
         │ Pipe-delimited manifest │
         │ of 60+ OSINT tools      │
         │ (install method, cmd    │
         │  template, metadata)    │
         └────────────┬────────────┘
                      │
         ┌────────────▼────────────┐
         │  Tool Storage & Output  │
         │                         │
         │ Programs:               │
         │ ~/.local/share/         │
         │  speculator/programs/   │
         │                         │
         │ Evidence:               │
         │ ~/Downloads/evidence/   │
         │  {target}/             │
         │                         │
         │ Config:                 │
         │ ~/.config/speculator/   │
         └─────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| **Hub Launcher** | Accept user input, classify it, dispatch to appropriate spoke or internal handler | `scripts/user.sh` |
| **Spoke Launchers** | Domain-specific input handling, tool selection, result display | `scripts/domain.sh`, `scripts/instagram.sh`, etc. |
| **Shared Library** | Tool execution, session management, error detection, UI rendering, manifest parsing | `scripts/lib/common.sh` |
| **Tool Manifest** | Single source of truth for tool metadata (name, check method, command template, venv) | `config/tools.conf` |
| **Installer** | Bootstrap Debian system, install tools via apt/pipx/go/git, set up XDG directories | `speculator_install.sh` |
| **Desktop Shortcuts** | GUI entry points installed to `~/.local/share/applications/` | `shortcuts/*.desktop` |

## Pattern Overview

**Overall:** Hub-and-spoke launcher architecture with manifest-driven tool execution.

**Key Characteristics:**
- Single central dispatcher (`user.sh`) for five person-tracking categories (email, username, fullname, phone, hash)
- Nine spoke scripts for specialized investigation types (domain, social media, video, archives, frameworks, etc.)
- All tool metadata centralized in pipe-delimited `config/tools.conf`
- Tool execution abstracted via `run_tool()` and `run_manifest_tool()` in shared library
- Zenity for all GUI interaction (modal dialogs, checklists, text input)
- Session-based evidence collection with per-target logs and semantic error detection
- Support for both sequential and parallel tool execution

## Layers

**Launcher Layer (User Interface):**
- Purpose: Accept investigation input and dispatch to appropriate tools
- Location: `scripts/user.sh` (hub), `scripts/domain.sh`, `scripts/instagram.sh`, `scripts/reddit.sh`, `scripts/video.sh`, `scripts/archives.sh`, `scripts/image.sh`, `scripts/frameworks.sh`, `scripts/update.sh`, `scripts/maigret-web.sh` (spokes)
- Contains: Input validation, classification logic, category routing, Zenity dialogs
- Depends on: `scripts/lib/common.sh` for tool execution and UI helpers
- Used by: Desktop shortcuts, direct shell invocation, user GUI

**Execution Layer (Tool Orchestration):**
- Purpose: Manage tool lifecycle, capture output, detect errors, log results
- Location: `scripts/lib/common.sh`
- Contains: `run_tool()`, `run_manifest_tool()`, `run_category()`, error detection patterns, session logging
- Depends on: `config/tools.conf` for manifest data, external OSINT tools
- Used by: All launcher scripts (hub and spokes)

**Configuration Layer (Tool Metadata):**
- Purpose: Maintain single source of truth for all tool metadata
- Location: `config/tools.conf`
- Contains: 60+ tool definitions with install method, command templates, venv requirements, output format
- Depends on: None (read-only data)
- Used by: `load_manifest()` in common.sh during launcher startup

**Installation Layer (System Bootstrap):**
- Purpose: Prepare Debian system with all required tools and dependencies
- Location: `speculator_install.sh`
- Contains: apt package installation, pipx/go/git tool installation, venv setup, directory creation, ownership correction
- Depends on: System utilities (apt, git, python3, go, pipx), internet connectivity
- Used by: Initial setup only (not at runtime)

## Data Flow

### Primary Request Path (Person-Tracking via user.sh)

1. User runs `user.sh` or clicks user.desktop shortcut → `scripts/user.sh:main()` (`scripts/user.sh:78`)
2. Display banner and check required tools → `print_banner()`, `check_required_tools()` (`scripts/lib/common.sh:59`, `scripts/lib/common.sh:297`)
3. Zenity entry dialog for input → `zenity --entry` (`scripts/user.sh:86`)
4. Classify input (email, username, phone, hash, fullname, or unknown) → `classify_input()` (`scripts/user.sh:31`)
5. If unknown, prompt user for category via dialog → `resolve_unknown_category()` (`scripts/user.sh:53`)
6. Dispatch to category handler → `run_category($category, $input, ...)` (`scripts/user.sh:102-116`)
7. In `run_category()`: create session dir, load manifest, display Zenity checklist → `create_session_dir()`, `load_manifest()`, `zenity_checklist()` (`scripts/lib/common.sh:315`, `scripts/lib/common.sh:343`, `scripts/lib/common.sh:369`)
8. For each selected tool: expand template, execute, capture output, detect errors → `run_manifest_tool()` → `run_tool()` (`scripts/lib/common.sh:391`, `scripts/lib/common.sh:172`)
9. Results saved to `~/Downloads/evidence/{target}/` with session log → `SESSION_LOG_FILE` (`scripts/lib/common.sh:320`)
10. Display summary → `print_summary()` (`scripts/lib/common.sh:107`)

### Domain/Infrastructure Investigation Flow (domain.sh as example)

1. User runs `domain.sh` → `scripts/domain.sh:main()` (`scripts/domain.sh:17`)
2. Display banner, check required tools (amass, subfinder) → `print_banner()`, `check_required_tools()` (`scripts/domain.sh:18-19`)
3. Zenity entry dialog for domain input → `zenity --entry` (`scripts/domain.sh:25`)
4. Route to internal handler → `run_category("domain", ...)` (`scripts/domain.sh:33`)
5. Same execution flow as person-tracking: load manifest, select tools, execute in sequence/parallel, save results

### Parallel vs Sequential Execution

When multiple tools selected in `run_category()` (`scripts/lib/common.sh:489`):
- **Sequential (default):** Tools run one by one, results displayed in real time
- **Parallel (if enabled):** Tools launched as background jobs, status tracked via temp files (`$status_dir/*.status`), collected after all complete

Both modes:
- Log each tool's exit code, semantic error patterns, duration
- Save stdout/stderr to session log
- Open result files in default handler (e.g., PDF viewer, text editor)

### State Management

**Session State:**
- Per-target log directory: `$HOME/Downloads/evidence/{target}/logs/`
- Per-session log file: `session-{timestamp}.log`
- Per-tool output: `{target}-{tool_id}.{extension}`

**Tool Availability Tracking:**
- `MISSING_TOOLS=()` array built at startup via `check_required_tools()`
- `TOOL_STATUS[label]` and `TOOL_DURATION[label]` associative arrays updated after each tool execution

**Manifest Data:**
- Loaded into associative arrays per category: `_MF_NAME`, `_MF_CHECK_TYPE`, `_MF_CHECK_VAL`, `_MF_CMD`, `_MF_OUTPUT_EXT`, `_MF_VENV`, `_MF_VENV_NAME`
- Arrays cleared at start of each `load_manifest()` call

## Key Abstractions

**Tool Execution Abstraction (`run_tool`):**
- Purpose: Unified command execution with output capture, exit code tracking, error detection
- Examples: `scripts/lib/common.sh:172`
- Pattern: Wraps subprocess in temp files for stdout/stderr, checks both exit code and semantic error patterns (regex matching for "error:", "connection refused", etc.)

**Manifest-Driven Tool Discovery (`load_manifest`):**
- Purpose: Parse pipe-delimited config and populate tool metadata arrays
- Examples: `scripts/lib/common.sh:343`, read from `config/tools.conf`
- Pattern: Single pass through file, skip comments/blanks, group by category

**Category Router (`run_category`):**
- Purpose: Generic end-to-end workflow for any tool category (person-tracking or domain-specific)
- Examples: `scripts/lib/common.sh:489`
- Pattern: Accept category string, load manifest, display Zenity checklist, dispatch to tool executor, aggregate results

**Placeholder Template System (`run_manifest_tool`):**
- Purpose: Substitute {target}, {outfile}, {outdir}, {programs_dir}, {session_id} in command templates
- Examples: `scripts/lib/common.sh:391`
- Pattern: Split template into array before substitution (safe word splitting), expand placeholders element-wise, prompt for undefined placeholders via Zenity

## Entry Points

**User-Facing Launchers:**
- `scripts/user.sh` - Hub router for person-tracking searches (email, username, fullname, phone, hash)
- `scripts/domain.sh` - Domain/subdomain/infrastructure reconnaissance
- `scripts/instagram.sh` - Instagram account enumeration
- `scripts/reddit.sh` - Reddit user archive
- `scripts/video.sh` - Video download and metadata extraction
- `scripts/archives.sh` - Web archive lookups (Wayback Machine, Internet Archive)
- `scripts/image.sh` - Image metadata extraction
- `scripts/frameworks.sh` - Framework tools (Recon-NG, sn0int, changedetection.io)
- `scripts/maigret-web.sh` - Maigret web interface launcher
- `scripts/update.sh` - Tool update management

**System Bootstrap:**
- `speculator_install.sh` - Main installer (requires sudo, runs once at system setup)

**Desktop Integration:**
- `.desktop` files in `shortcuts/` installed to `~/.local/share/applications/`
- Allows GUI desktop menu or activity launcher access

## Architectural Constraints

- **Bash-only:** No Python, Node.js, or compiled dependencies beyond system packages
- **Debian target:** Scripts use Debian-specific paths and package manager (apt)
- **Single-user:** Designed for per-user home directory installation (`~/.local/`, `~/.config/`)
- **GUI-dependent:** Zenity required for all dialogs; will fail gracefully in headless environments
- **Manifest-driven:** All tool definitions centralized in `config/tools.conf`; adding new tool requires single-line entry, not code changes
- **File-based state:** No database; all output files and logs use filesystem paths
- **Tool isolation:** Each Git-sourced tool gets its own venv in `$PROGRAMS_DIR/{tool}/`)
- **No global state:** Launcher scripts are stateless; all context passed as function arguments or stored in session directories

## Error Handling

**Strategy:** Defensive programming with graceful degradation. Missing tools don't block session; errors logged and reported.

**Patterns:**
- `run_tool()` checks both exit code and semantic error patterns (grep-based detection of common error strings)
- `_check_semantic_errors()` searches stdout/stderr for patterns like "error:", "traceback", "connection refused"
- Tool availability verified before execution via `tool_available()` (checks `command -v` or directory existence)
- Failing tools marked as skipped/failed in `TOOL_STATUS[]`, reported in summary but don't halt other tools
- All errors logged to session-specific error log files (`SESSION_LOG_DIR/{tool_name}-error.log`)
- Zenity warnings for missing tools at launcher startup (continues with reduced functionality)

## Cross-Cutting Concerns

**Logging:** Session-based logging via `_session_log()` to `SESSION_LOG_FILE`. Uses `flock` for thread-safe writes. Captures start/end times, tool names, exit codes, command lines, semantic error patterns.

**Validation:** Input classification in `user.sh` (email regex, phone regex, hash length/charset detection). Placeholder validation in `run_manifest_tool()` (prompts for undefined {placeholders} via Zenity). Safe filename generation via character whitelist.

**Authentication:** Some tools (e.g., Instagram, Reddit tools) may require user credentials/API keys. This is tool-specific; Speculator treats these as runtime requirements (user provides via env var or tool config, not installer responsibility).

**User Detection:** `speculator_install.sh` detects real user when run via sudo, maintains correct ownership of installed files in user home directory (`SUDO_USER` variable handling at `speculator_install.sh:36-42`).

---

*Architecture analysis: 2026-05-06*

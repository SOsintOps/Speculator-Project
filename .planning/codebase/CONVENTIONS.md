# Coding Conventions

**Analysis Date:** 2026-05-06

## Naming Patterns

**Files:**
- Launcher scripts: lowercase with underscores (`user.sh`, `domain.sh`, `instagram.sh`)
- Library files: lowercase with underscores in `scripts/lib/` (`common.sh`)
- Installation script: lowercase with underscores (`speculator_install.sh`)
- Test files: match pattern `test_*.sh`

**Functions:**
- Private functions: leading underscore (`_session_log`, `_check_semantic_errors`, `_line`, `_avail`)
- Public functions: bare lowercase with underscores (`run_tool`, `print_banner`, `classify_input`)
- Main entry point: `main()` function at end of script

**Variables:**
- Module-scope variables: UPPERCASE with leading underscore for internal state (`_COMMON_SH_LOADED`, `_MF_IDS`, `_REPO_DIR`)
- Public configuration: UPPERCASE (`EVIDENCE_DIR`, `PROGRAMS_DIR`, `SCRIPT_NAME`, `SCRIPT_VERSION`)
- Local function variables: lowercase with underscores (`local inputValue`, `local session_dir`)
- Loop counters: simple lowercase (`i`, `j`, `cur`)
- Associative arrays: lowercase with underscores, UPPERCASE for keys (`declare -A TOOL_STATUS=()`, `TOOL_STATUS[$label]="ok"`)

**Types (declarations):**
- Arrays: declared with `declare -a` prefix; use indexed arrays when order matters
- Associative arrays: declared with `declare -A` for key-value storage
- Colour constants: UPPERCASE (`C_CYAN`, `C_RED`, `COL_EMAIL`)

## Code Style

**Formatting:**
- Indentation: 2 spaces (universal across all scripts)
- Line length: no hard limit enforced, but kept under 100 characters where practical
- Shebang: `#!/usr/bin/env bash` (portable across platforms)
- Command substitution: `$(...)` style (modern, preferred over backticks)

**Linting:**
- No `.shellcheckrc` or `.shfmt` config present; scripts follow conventions organically
- Syntax validation: run `bash -n <script>` before commit
- Error mode: `set -uo pipefail` in all launcher scripts (fails on undefined variables, pipe failures)
- Installation script `speculator_install.sh` uses `set` (no `-e` to allow graceful failure tracking)

**Line continuations:**
- Use backslash for multi-line statements within functions
- Use pipes (`|`) to continue long command chains
- Array initialisation: spread across multiple lines with one element per line when >3 items

## Import Organization

**Order:**
1. Shebang line (`#!/usr/bin/env bash`)
2. Comment header (description, version, usage)
3. Safety options (`set -uo pipefail` or `set` with overrides)
4. Variable assignments (SCRIPT_NAME, SCRIPT_VERSION, etc.)
5. Source directives (`source "$SCRIPT_DIR/lib/common.sh"`)
6. Function definitions (grouped by logical area)
7. Main entry point (`main { ... }; main`)

**Path Aliases:**
- All paths use `$HOME` (never `~`)
- All paths use absolute references derived from script location: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Config directory: `config/tools.conf` (tool manifest, pipe-delimited)
- Evidence output: always routed to `$HOME/Downloads/evidence/{target}/`
- Tool installation: `$HOME/.local/share/speculator/programs/`
- Scripts install to: `$HOME/.local/share/speculator/scripts/`

## Error Handling

**Patterns:**

1. **Directory navigation with error checks** — Use `cd` with explicit failure handling:
   ```bash
   cd "$repo_dir" || { log_step "$label" "fail" " (cd failed)"; exit 1; }
   ```

2. **Command substitution with fallback** — Use `||` to provide fallback values:
   ```bash
   local tool_name; tool_name=$(basename "$repo_url" .git)
   REAL_GOPATH=$(run_as_user go env GOPATH 2>/dev/null || echo "$REAL_HOME/go")
   ```

3. **Exit code capture** — Capture before any other commands:
   ```bash
   "$@" >"$out" 2>"$err" || rc=$?
   ```

4. **Conditional execution** — Use `&&` for dependent operations:
   ```bash
   if ! run_as_user git clone "$repo_url" "$tool_dir"; then
     echo "WARNING: Failed to clone $tool_name. Skipping."
     return 0
   fi
   ```

5. **Non-fatal failures** — Use `|| true` to suppress error status in dry-run or warnings:
   ```bash
   mark_fail "git:$tool_name"
   return 0  # Don't abort; continue with next tool
   ```

6. **Temporary files** — Always use mktemp with cleanup:
   ```bash
   out="$(mktemp /tmp/osint_out_XXXXXX)"
   rm -f "$out" "$err"  # at end of function
   ```

7. **Array operations with safety** — Check length before accessing:
   ```bash
   [ ${#missing_list[@]} -eq 0 ] && return
   ```

## Logging

**Framework:** printf-based (no external logger)

**Patterns:**
- Session log: append-only to `$SESSION_LOG_FILE` with file lock (`flock -x 9`)
- Exit codes: captured and recorded in session log with timestamps
- Tool output: split into stdout/stderr, both logged separately
- Error detection: semantic pattern matching (see `SEMANTIC_ERROR_PATTERNS` in `common.sh`)

**Levels (via log_step):**
- `run` — Tool started
- `ok` — Tool completed successfully
- `skip` — Tool not available, skipped
- `fail` — Tool failed (exit code or semantic error)
- `info` — Informational message

Example call:
```bash
log_step "Tool Name" "ok" "  (15s)"
```

## Comments

**When to Comment:**
- Section headers: use `###############################################################################` (88 chars)
- Function purposes: one-line description before function declaration
- Complex logic: explain WHY, not WHAT
- Non-obvious decisions: e.g., why we use `${:-}` parameter expansion
- Bug workarounds: reference issue if applicable

**JSDoc/TSDoc:**
Not used. Bash has no standard doc convention in this project. Comments are free-form prose.

**Header format (in scripts/launchers):**
```bash
#!/usr/bin/env bash
################################################################################
## Script Title — Brief Description
## Version X.Y.Z - Key changes or architecture note
## [Optional additional context]
################################################################################
```

## Function Design

**Size:** Under 50 lines preferred; over 100 lines indicates the function is doing too much.

**Parameters:**
- Use positional parameters with descriptive local assignments:
  ```bash
  run_tool() {
    local label="$1" outfile="$2"; shift 2
  ```
- Shift early when multiple parameters consumed by recursive calls
- Check parameter count at function start if strict validation needed

**Return Values:**
- Return 0 for success, 1 for failure
- Use exit codes for critical failures (exit 1 in subshells)
- Return early on precondition failures rather than nesting

**Example structure:**
```bash
run_tool() {
  local label="$1" outfile="$2"; shift 2
  [ -z "$label" ] && return 1           # Early return on missing args
  
  local out err rc=0                     # Local state initialisation
  out="$(mktemp /tmp/osint_out_XXXXXX)"
  err="$(mktemp /tmp/osint_err_XXXXXX)"
  
  # Main logic
  if [ condition ]; then
    operation1
    operation2
  else
    operation3
  fi
  
  # Cleanup
  rm -f "$out" "$err"
  return $rc
}
```

## Module Design

**Exports:**
- Functions: prefix with `_` if internal to file, no prefix if meant to be sourced
- Variables: UPPERCASE for public config, lowercase for file-local state
- Guard against double-sourcing: use module-load flag at top of library:
  ```bash
  [[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
  _COMMON_SH_LOADED=1
  ```

**Barrel Files:**
Not used. `scripts/lib/common.sh` is monolithic (~560 lines).

**Common.sh structure:**
1. Load guard + guard variable assignment
2. Environment setup (PATH, backend, globals)
3. ANSI colour palette (grouped by category)
4. Session logging primitives
5. Terminal output primitives (banner, headers, progress, etc.)
6. Semantic error detection
7. Tool execution (`run_tool`, `run_repo_python_tool`)
8. Tool availability checks
9. Session directory creation
10. Manifest loading (tools.conf parsing)
11. Zenity UI integration
12. Category runner (`run_category` — hub-and-spoke dispatcher)

## Architecture Patterns

**Hub-and-spoke launcher architecture:**
- **Hub:** `scripts/user.sh` — handles person-tracking categories (email, username, hash, phone, fullname)
- **Spokes:** category-specific scripts (`domain.sh`, `instagram.sh`, `video.sh`, etc.)
- All spokes follow identical structure: Zenity input loop → `run_category()` call
- Each spoke is 30-40 lines; logic centralised in `common.sh`

**Manifest-driven tool execution:**
- Tool metadata lives in `config/tools.conf` (pipe-delimited format)
- `load_manifest(category)` populates associative arrays (`_MF_NAME`, `_MF_CMD`, etc.)
- Template substitution replaces `{target}`, `{outfile}`, `{outdir}`, `{programs_dir}`, `$HOME` in command strings
- Single `run_category()` function handles tool selection, parallel/serial execution, and result reporting

**Dry-run simulation:**
- `speculator_install.sh` uses function override pattern: redefine `sudo`, `apt`, etc. to print instead of execute
- Dry-run allows syntax/logic validation without system changes
- Read-only operations (checks, version detection) run normally even in dry-run mode

---

*Convention analysis: 2026-05-06*

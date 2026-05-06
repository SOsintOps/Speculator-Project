# Testing Patterns

**Analysis Date:** 2026-05-06

## Test Framework

**Runner:**
- **Framework:** Bash (native shell; no external test framework)
- **Config:** None — test logic embedded in scripts
- **Test file:** `/mnt/h/github/Speculator-Project/tests/test_refactor.sh`

**Assertion Library:**
- Custom function `_test()` (defined in test script)
- Simple equality comparison: `[ "$expected" = "$actual" ]`
- Pass/fail counts tracked in variables (`PASS`, `FAIL`, `TOTAL`)

**Run Commands:**
```bash
bash tests/test_refactor.sh              # Run all tests
bash tests/test_refactor.sh              # No watch mode (single run only)
```

Syntax validation (always run before commit):
```bash
bash -n speculator_install.sh
bash -n scripts/user.sh
bash -n scripts/lib/common.sh
```

Dry-run simulation (functional test of installer):
```bash
sudo ./speculator_install.sh --dry-run
```

## Test File Organization

**Location:** `tests/` directory at project root

**Naming:** `test_refactor.sh` (matches `test_*.sh` pattern)

**Structure:**
```
tests/
├── test_refactor.sh    # Integration test for common.sh + user.sh refactor
```

Currently, only one test file exists. It exercises the core library after a refactoring effort.

## Test Structure

**Suite Organization:**

From `tests/test_refactor.sh`:

```bash
#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0; FAIL=0; TOTAL=0

_test() {
  local name="$1" expected="$2" actual="$3"
  ((TOTAL++))
  if [ "$expected" = "$actual" ]; then
    printf "  \033[32m✔\033[0m  %s\n" "$name"
    ((PASS++))
  else
    printf "  \033[31m✖\033[0m  %s\n" "$name"
    printf "       expected: '%s'\n" "$expected"
    printf "       actual:   '%s'\n" "$actual"
    ((FAIL++))
  fi
}

# Tests grouped by functionality section (echo "── N. [Section Name] ──")
# Each section tests related functionality
```

**Patterns:**

1. **Setup** — source libraries and initialise state:
   ```bash
   SCRIPT_NAME="TEST"
   SCRIPT_VERSION="0.0.0"
   VERBOSE=false
   source "$SCRIPT_DIR/scripts/lib/common.sh" 2>/dev/null
   ```

2. **Extract functions** — use `sed` to extract function definitions for unit testing:
   ```bash
   eval "$(sed -n '/^advanced_hash_detection/,/^}/p' "$SCRIPT_DIR/scripts/user.sh")"
   eval "$(sed -n '/^classify_input/,/^}/p' "$SCRIPT_DIR/scripts/user.sh")"
   ```

3. **Assertion pattern** — call `_test()` with name, expected, and actual:
   ```bash
   _test "email: user@example.com" "email" "$(classify_input "user@example.com")"
   _test "username: johndoe123" "username" "$(classify_input "johndoe123")"
   ```

4. **Validation checks** — test function existence and return status:
   ```bash
   _test "run_tool exists" "true" "$(declare -f run_tool >/dev/null 2>&1 && echo true || echo false)"
   ```

5. **Grep-based checks** — verify code patterns without execution:
   ```bash
   _test "user.sh has no run_tool()" "0" "$(grep -c '^run_tool()' "$user_sh")"
   _test "user.sh sources common.sh" "1" "$(grep -c '^source.*common.sh' "$user_sh")"
   ```

## Mocking

**Framework:** None — manual by function override or conditional execution

**Patterns:**

1. **Function override for dry-run** — redefine critical commands:
   ```bash
   if [ "$DRY_RUN" = "true" ]; then
     run_as_user() { echo "  [DRY-RUN | user:${REAL_USER}] $*"; }
     sudo() { echo "  [DRY-RUN | sudo] $*"; }
     apt() { echo "  [DRY-RUN | apt] $*"; }
   fi
   ```

2. **Environment variables for test conditions** — use flags to skip real operations:
   ```bash
   if [ ! -d "$tool_dir" ]; then
     if ! run_as_user git clone "$repo_url" "$tool_dir"; then
       echo "WARNING: Failed to clone $tool_name. Skipping."
       return 0
     fi
   fi
   ```

3. **No test doubles** — tests run against actual source files, not mocks. The library is sourced directly.

**What to Mock:**
- System commands in dry-run mode (`sudo`, package managers, network calls)
- File I/O when testing logic (not actual file creation)
- External tools when testing availability checks

**What NOT to Mock:**
- Shell builtins (for/while/if/etc.)
- Pure logic (string matching, array operations)
- Library-internal function calls (test the whole chain)

## Fixtures and Factories

**Test Data:**

Fixed test inputs are embedded in test assertions:
```bash
_test "email: user@example.com" "email" "$(classify_input "user@example.com")"
_test "hash MD5: 32 hex chars" "hash" "$(classify_input "d41d8cd98f00b204e9800998ecf8427e")"
_test "phone: +393331234567" "phone" "$(classify_input "+393331234567")"
```

**Location:**
- Input data: hardcoded in test assertions
- Expected outputs: hardcoded in assertions
- Tool manifest: sourced from actual `config/tools.conf`

## Coverage

**Requirements:** No formal coverage target enforced

**Current scope (test_refactor.sh):**
- Library sourcing and guard variables
- Input classification function (`classify_input`)
- Manifest loading (`load_manifest`)
- Function availability checks (all exported functions exist)
- Code quality checks (no duplication after refactor)
- Line count validation (modules stay under size limits)

**Untested areas:**
- Interactive Zenity dialogs (require X11 session)
- Tool execution (`run_tool` with real commands)
- Parallel execution (`run_category` with multiple tools)
- Error detection (semantic pattern matching)
- Session logging to files
- Network operations (OSINT tool invocations)

These are covered by manual dry-run testing and functional QA with real tools installed.

**View Coverage:**
No automated coverage reports. Manual inspection by line:
```bash
grep -n "TODO\|FIXME\|XXX" scripts/lib/common.sh scripts/*.sh
```

## Test Types

**Unit Tests:**
- **Scope:** Individual function logic (e.g., `classify_input()` with various inputs)
- **Approach:** Extract function via `sed`, call with known inputs, assert output
- **Examples:**
  - Email/username/hash/phone pattern matching
  - Manifest loading and array population
  - Function existence checks via `declare -f`

**Integration Tests:**
- **Scope:** Library sourcing, function availability after source, module coupling
- **Approach:** Source library with various SCRIPT_NAME/SCRIPT_VERSION values, verify state
- **Examples:**
  - Common.sh sources without error in test environment
  - EVIDENCE_DIR and PROGRAMS_DIR are correctly set
  - All exported functions exist and are callable

**E2E Tests:**
- **Framework:** Dry-run simulation of installer
- **Command:** `sudo ./speculator_install.sh --dry-run`
- **Scope:** Entire installation flow without applying system changes
- **Coverage:**
  - Phase 1: system checks, Debian detection, path setup
  - Phase 2-6: tool installation simulation, script copying, config application
  - Output: log file with all simulated commands, results summary

## Common Patterns

**Async Testing:**
Not used. Bash tests are synchronous. Parallel tool execution (in `run_category`) is tested by:
1. Spawning tools in background: `command & pids+=($!)`
2. Waiting on all PIDs: `for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done`
3. Checking result files written by subshells
4. Verifying status file creation and content

Example from `common.sh`:
```bash
for id in "${selected[@]}"; do
  (
    run_manifest_tool "$id" "$target" "$session_dir"
    echo "$?|${TOOL_STATUS[$name]:-unknown}|${TOOL_DURATION[$name]:-0}" > "$sf"
  ) &
  pids+=($!)
done

for pid in "${pids[@]}"; do
  wait "$pid" 2>/dev/null || true
done
```

**Error Testing:**
- Exit code capture: `"$@" >"$out" 2>"$err" || rc=$?`
- Semantic error detection: regex patterns in `SEMANTIC_ERROR_PATTERNS` array
- Failure logging: errors recorded in session log file with context

Pattern test:
```bash
local sem_pat
if sem_pat=$(_check_semantic_errors "$out" "$err"); then
  log_step "$label" "fail" "  (semantic: '${sem_pat}', ${duration}s)"
  # ... log and cleanup
fi
```

## Test Execution Checklist

Before submitting changes:

1. **Syntax validation:**
   ```bash
   bash -n speculator_install.sh
   bash -n scripts/*.sh
   bash -n scripts/lib/common.sh
   ```

2. **Unit + integration tests:**
   ```bash
   bash tests/test_refactor.sh
   ```
   Expected output: `✔ NNN passed   ✖ 0 failed   (total: NNN)`

3. **Dry-run functional test (if modifying installer):**
   ```bash
   sudo ./speculator_install.sh --dry-run
   ```
   Expected: log file in `$HOME/Downloads/` with all commands printed, no actual changes

4. **Manual smoke test (if adding new spoke):**
   - Launch script with `-v` flag
   - Verify Zenity dialogs appear
   - Verify session log created in `$HOME/Downloads/evidence/`
   - Verify tool selection and execution flow (can cancel at any point)

---

*Testing analysis: 2026-05-06*

# Architecture Research

**Domain:** Bash installer and launcher testing integration
**Researched:** 2026-05-06
**Confidence:** HIGH (based on direct codebase reading + verified bats-core documentation)

## Standard Architecture

### System Overview

The existing production system has four layers. The test system adds two new layers that sit alongside (not inside) the production code.

```
┌─────────────────────────────────────────────────────────────────┐
│                     STATIC ANALYSIS LAYER                        │
│  shellcheck on all .sh files — runs in CI, no VM required        │
│  bash -n syntax check — zero dependencies                        │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                     UNIT TEST LAYER (repo-local)                  │
│  tests/test_refactor.sh — existing, plain bash, no deps          │
│  tests/test_manifest.sh — new, plain bash, validates tools.conf  │
│  tests/test_common.sh   — new, bats or plain bash                │
│  tests/test_classify.sh — new, tests classify_input() edge cases │
│                                                                   │
│  These tests: source common.sh, parse tools.conf, call           │
│  classify_input(). No Zenity. No OSINT tools. No network.        │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 │ (no automatic bridge — manual trigger)
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                   PRODUCTION LAUNCHER LAYER                       │
├──────────────────────────────────────────────────────────────────┤
│  user.sh (hub)                                                    │
│    - classify_input()           from scripts/user.sh             │
│    - resolve_unknown_category() from scripts/user.sh             │
│    - run_category()             delegated to common.sh           │
├──────────────────────────────────────────────────────────────────┤
│  spoke scripts (domain.sh, instagram.sh, etc.)                   │
│    - Each sources common.sh directly                             │
│    - Each calls run_category() with its own category string      │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                   SHARED LIBRARY LAYER                            │
│  scripts/lib/common.sh                                            │
│    - run_tool(), run_manifest_tool(), run_category()             │
│    - load_manifest(), zenity_checklist()                         │
│    - session logging, error detection, tool availability         │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                   CONFIGURATION LAYER                             │
│  config/tools.conf — pipe-delimited, 57 tools, 12 categories     │
│  Single source of truth for all tool metadata                    │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                   VM VERIFICATION LAYER                           │
│  Manual procedure run on a clean Debian 13 Trixie VM             │
│  speculator_install.sh end-to-end                                │
│  Post-install tool availability check (command -v / dir exists)  │
│  user.sh manual walk-through for all 5 person-tracking categories│
│  maigret-web.sh: launch, verify port 5001 responds               │
│                                                                   │
│  Output: pass/fail count recorded in PROJECT.md (Validated list) │
└─────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Test Coupling |
|-----------|----------------|---------------|
| `tests/test_refactor.sh` | Verify source chain, classify_input(), manifest loading, no-duplication guards, line count | Pure bash, sources common.sh + parses user.sh via sed/eval |
| `tests/test_manifest.sh` (new) | Validate tools.conf integrity for all 12 categories: field count, no blank required fields, valid check_types | Pure bash, reads tools.conf with awk/IFS parsing |
| `scripts/lib/common.sh` | All shared functions; the primary testable unit | Sourceable in test context with Zenity calls guarded |
| `scripts/user.sh` | Hub routing + classify_input(); functions extracted and tested independently | classify_input() has no side effects; safe to test headlessly |
| `config/tools.conf` | Tool metadata; verifiable without running tools | Schema validation via field-count and enum checks |
| `speculator_install.sh` | System bootstrap; not unit-testable; verified by VM run only | VM layer only |

## Recommended Project Structure

The existing layout is correct. The test additions fit within it without new directories.

```
tests/
  test_refactor.sh         # existing — source + classify + manifest + dedup
  test_manifest.sh         # NEW — full tools.conf integrity for all 12 categories
  test_common.sh           # NEW — run_tool() edge cases, session dir creation
  test_classify.sh         # NEW — extended classify_input() coverage (edge cases)
  helpers/
    mock_zenity.sh         # NEW — stub zenity to prevent GUI popups during tests
    fixtures/
      tools_minimal.conf   # NEW — minimal valid tools.conf subset for isolated tests
```

### Structure Rationale

- **tests/ at repo root:** Matches existing `tests/test_refactor.sh` location; no new top-level directory needed.
- **tests/helpers/:** Keeps stubs and fixtures separate from test files; avoids polluting the tests/ root with utility scripts that are not tests themselves.
- **No bats-core dependency:** The existing test suite uses plain bash. Stick with plain bash unless bats-core is explicitly installed on the VM. Adding a framework dependency to a pure-Bash project creates a bootstrap problem: the test runner needs to be installed before tests run.
- **VM verification is a manual procedure, not a test file:** There is no Bash-testable equivalent for "does apt install succeed on a clean system". Document the procedure; record results in PROJECT.md.

## Architectural Patterns

### Pattern 1: Source-and-Call Testing

**What:** Source common.sh (and functions extracted from user.sh via sed/eval) in a plain Bash test script. Call functions directly and assert return values or variable states.

**When to use:** For all pure-logic functions — classify_input(), load_manifest(), tool_available(), _check_semantic_errors(), create_session_dir().

**Trade-offs:** Fast (milliseconds), no external dependencies, runs in CI or on any machine without the VM. Cannot test anything that calls Zenity or executes OSINT tools.

**Example:**
```bash
source "$SCRIPT_DIR/scripts/lib/common.sh"
load_manifest "email"
[[ ${#_MF_IDS[@]} -eq 8 ]] && echo "PASS" || echo "FAIL: expected 8, got ${#_MF_IDS[@]}"
```

### Pattern 2: PATH Stub (Zenity Guard)

**What:** Create a mock `zenity` script that exits 1 or prints a predictable string to stdout. Prepend its directory to PATH before sourcing scripts. Remove it after each test.

**When to use:** Any test that sources a script which calls Zenity at module load time, or when testing functions that conditionally call Zenity.

**Trade-offs:** Keeps tests headless. Does not test actual Zenity UX. Required for any test that must call run_category() or zenity_checklist() without a display.

**Example:**
```bash
mkdir -p /tmp/test_stubs
echo '#!/usr/bin/env bash' > /tmp/test_stubs/zenity
echo 'exit 1' >> /tmp/test_stubs/zenity
chmod +x /tmp/test_stubs/zenity
export PATH="/tmp/test_stubs:$PATH"
# ... run test ...
rm -rf /tmp/test_stubs
```

### Pattern 3: Schema Validation via Field Parsing

**What:** Parse tools.conf with IFS='|' read and count fields per line. Assert each line has exactly 9 fields. Assert check_type is one of {binary, repo, pipx, go}. Assert no required fields are blank.

**When to use:** For the manifest integrity test layer. Catches malformed entries before VM deployment.

**Trade-offs:** Runs entirely offline, zero dependencies, catches the most common error (adding a tool with wrong field count or typo in check_type). Does not verify tools are actually installed.

**Example:**
```bash
while IFS='|' read -r name id cat check_type check_val cmd output_ext venv venv_name; do
  [[ "$name" =~ ^# || -z "$name" ]] && continue
  local fields=9
  # assert no blank required fields in positions 1-7
done < "$TOOLS_CONF"
```

## Data Flow

### Test Execution Flow

```
Developer runs: bash tests/test_refactor.sh
                      |
                      v
         source scripts/lib/common.sh
                      |
                      v
         eval classify_input() from user.sh
                      |
                      v
         load_manifest("email") -> _MF_IDS, _MF_NAME arrays
                      |
                      v
         _test() assertions -> PASS/FAIL counters
                      |
                      v
         exit 0 (all pass) or exit 1 (any fail)
```

### VM Verification Flow

```
Clean Debian 13 Trixie VM
         |
         v
sudo ./speculator_install.sh   (30-60 mins)
         |
         v
Post-install: iterate tools.conf, run check_type assertion per tool
  binary: command -v <check_value>
  repo:   [ -d $PROGRAMS_DIR/<check_value> ]
         |
         v
Manual: launch user.sh, run each of 5 categories with test input
Manual: launch maigret-web.sh, curl http://localhost:5001
         |
         v
Record results in PROJECT.md (count ok / failed / skipped)
```

### How Repo Tests and VM Verification Relate

Repo-level automated tests and VM verification are **complementary layers with no overlap**. They test different things and cannot substitute for each other.

| Question | Answered by |
|----------|-------------|
| Does classify_input() handle edge cases? | Repo unit tests |
| Does tools.conf have the right field count for all 57 entries? | Repo manifest test |
| Does common.sh source cleanly? | Repo unit tests |
| Does apt install holehe successfully on Trixie? | VM verification only |
| Does run_category("email", ...) produce output files? | VM verification only |
| Does maigret-web serve the UI? | VM verification only |

This separation is intentional. The repo tests give fast, repeatable confidence in the logic layer. The VM test gives confidence in the system layer. Running repo tests first reduces debugging time on the VM by eliminating logic errors before the expensive VM run.

### State Management in Tests

Tests must not share state. Each test group should:

1. Reset manifest arrays before calling load_manifest(): the function already does this internally.
2. Unset PATH stubs after each test block that creates them.
3. Use temporary directories (`mktemp -d`) for any session_dir created in tests; clean up in a trap.
4. Set SESSION_LOG_FILE="" before tests that call run_tool() to prevent writes to real paths.

## Scaling Considerations

This is a single-user VM tool. "Scaling" means adding more test coverage as new spoke scripts are built, not handling concurrent users.

| Milestone | Testing Additions Needed |
|-----------|--------------------------|
| Current (user.sh + common.sh) | test_refactor.sh (existing) + test_manifest.sh (all 12 categories) |
| Next (domain.sh + other spokes) | One test file per spoke covering its input classification and manifest loading |
| Future (JSON output normalisation) | Schema validation tests for output format |

## Anti-Patterns

### Anti-Pattern 1: Testing Tool Execution in Repo Tests

**What people do:** Write a test that calls run_category() or run_tool() with a real OSINT tool.

**Why it is wrong:** run_tool() executes the actual tool binary. On a developer machine without the VM setup, all tools are missing. Tests fail for environmental reasons, not code reasons. This erodes confidence in the test suite.

**Do this instead:** Test run_tool() with a controlled substitute command (e.g., `echo "test output"`) that is guaranteed to be present on any machine. Test the function's behaviour (exit code tracking, session log writes, TOOL_STATUS update) not the tool itself.

### Anti-Pattern 2: Merging VM Verification Into Automated Tests

**What people do:** Write a test script that calls `command -v holehe` and counts installed tools, then run it in CI or as part of the test suite.

**Why it is wrong:** Tool availability is environment-dependent. On a developer laptop without the VM, every tool check fails. The test suite becomes meaningless outside the VM context. CI would always fail.

**Do this instead:** Keep tool availability checks as a separate post-install verification procedure. Run it manually on the VM after `speculator_install.sh` completes. Record results in PROJECT.md. Do not run it in automated CI.

### Anti-Pattern 3: Calling source user.sh Directly

**What people do:** Write `source scripts/user.sh` in a test to get access to classify_input().

**Why it is wrong:** user.sh ends with `main` — it calls `main()` at load time. Sourcing it triggers the full interactive loop including Zenity dialogs. The test process hangs.

**Do this instead:** Extract functions via sed/eval as test_refactor.sh already does, or restructure user.sh so that `main` is only called when the script is run directly (guard with `[[ "${BASH_SOURCE[0]}" == "$0" ]]`). The guard pattern is the cleaner long-term fix and should be applied to user.sh as part of this milestone.

### Anti-Pattern 4: One Monolithic Test File

**What people do:** Add all new tests to test_refactor.sh, growing it to 500+ lines.

**Why it is wrong:** Manifest integrity tests (57 tools, 12 categories) produce many assertions. Mixing them with logic unit tests makes failure output hard to read and the file hard to maintain.

**Do this instead:** Keep test files under 200 lines each. One file per concern: refactor verification, manifest integrity, common.sh functions, classify_input() edge cases.

## Integration Points

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| test files to common.sh | `source` call | Guard with `_COMMON_SH_LOADED` already present; safe to source multiple times |
| test files to tools.conf | Direct file read via `TOOLS_CONF` variable | Variable is set by common.sh after source; always available post-source |
| test files to user.sh functions | sed/eval extraction | Fragile; prefer `[[ "${BASH_SOURCE[0]}" == "$0" ]]` guard in user.sh as long-term fix |
| test files to Zenity | PATH stub (mock_zenity.sh) | Required for any test that exercises GUI code paths |
| VM verification to installer | Manual SSH or console run | No programmatic bridge; results recorded by hand |

### Build Order Implications

The dependency graph determines what must exist before each test file can be written:

1. `test_refactor.sh` — exists, tests common.sh + user.sh classify functions. No new prerequisites.
2. `tests/helpers/mock_zenity.sh` — must be created first; unblocks any test that calls code touching Zenity.
3. `test_manifest.sh` — depends only on tools.conf existing. Can be built independently of mock_zenity.sh.
4. `test_common.sh` — depends on mock_zenity.sh for session/run_tool tests. Depends on test_manifest.sh passing (manifest must be valid before testing load_manifest deeply).
5. `test_classify.sh` — depends only on user.sh classify_input() being extractable. No other prerequisites.
6. VM verification procedure — depends on test_refactor.sh and test_manifest.sh passing, confirming logic layer is sound before the expensive VM run.

Recommended build sequence for the milestone:

```
1. Add [[ "${BASH_SOURCE[0]}" == "$0" ]] guard to user.sh   (unblocks cleaner sourcing)
2. Create tests/helpers/mock_zenity.sh                       (unblocks GUI-adjacent tests)
3. Write tests/test_manifest.sh                              (covers all 12 categories)
4. Write tests/test_classify.sh                              (extend edge case coverage)
5. Write tests/test_common.sh                                (run_tool, session dir, errors)
6. Run full test suite locally                               (all tests pass on dev machine)
7. Execute VM verification procedure                         (confirms system layer)
8. Record VM results in PROJECT.md                          (closes the milestone)
```

## Sources

- bats-core documentation: https://bats-core.readthedocs.io/en/stable/writing-tests.html
- bats-mock library: https://github.com/buildkite-plugins/bats-mock
- Bash testing patterns: https://advancedweb.hu/unit-testing-bash-scripts/
- SerDigital64 bash testing strategy: https://serdigital64.github.io/post/bash/testing-bash-scripts/
- Codebase: direct reading of scripts/lib/common.sh, scripts/user.sh, tests/test_refactor.sh, config/tools.conf, .planning/codebase/ARCHITECTURE.md

---
*Architecture research for: Speculator OSINT VM installer testing integration*
*Researched: 2026-05-06*

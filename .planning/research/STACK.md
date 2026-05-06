# Stack Research

**Domain:** Bash script testing and OSINT tool installation verification
**Researched:** 2026-05-06
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| bats-core | 1.11.1 (Debian Trixie apt) | Test runner for Bash scripts | TAP-compliant, native Bash, no runtime dependencies outside the shell; the de-facto standard for Bash unit and integration testing since replacing the unmaintained sstephenson fork |
| ShellCheck | 0.10.0 (Debian Trixie apt) | Static analysis and linting of Bash scripts | Catches SC2 class bugs (unquoted variables, incorrect exit code checks, array misuse) before runtime; zero false-positive profile on modern Bash 4; integrates directly into `bash -n` workflow already used in this project |
| bash -n | built-in (Bash 5.x on Debian 13) | Syntax check without execution | Zero-cost first gate; catches parse errors before any tool runs; already mandated in CLAUDE.md |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| bats-support | 0.3.0 (Debian Trixie apt) | Foundation helpers for bats-assert and bats-file | Always required as a dependency when using bats-assert or bats-file |
| bats-assert | 2.1.0 (Debian Trixie apt) | Assertion helpers: `assert_output`, `assert_success`, `assert_failure`, `assert_line` | Every bats test file that checks command output or exit codes; replaces the hand-rolled `_test()` pattern in test_refactor.sh |
| bats-file | 0.4.0 (Debian Trixie apt) | Filesystem assertions: `assert_file_exists`, `assert_dir_exists` | Tests that verify installer outputs (evidence dirs, log files, tool install dirs under `$PROGRAMS_DIR`) |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `bash -n` | Syntax-only parse check | Run as first step before any test; catches mismatched `do/done`, `if/fi`, bad substitutions |
| ShellCheck | Static analysis | Run with `--shell=bash`; suppress SC1090/SC1091 for dynamic `source` calls that use variables; use `# shellcheck disable=SC1090` inline only where path is intentionally dynamic |
| bats (TAP runner) | Execute `.bats` test files, report pass/fail with TAP output | Use `--tap` flag in CI; use default pretty output locally; `--jobs N` for parallel execution when test count grows |

## Installation

```bash
# All available in Debian 13 Trixie official repos — no external sources required
sudo apt install -y bats bats-support bats-assert bats-file shellcheck
```

Note: `apt install bats` on Trixie installs 1.11.1, which is the maintained bats-core fork.
The old sstephenson/bats (pre-1.0) is not available in Trixie repos.
Helper libraries install to `/usr/share/bats/` and are loaded in tests with:
```bash
load '/usr/share/bats/bats-support/load'
load '/usr/share/bats/bats-assert/load'
load '/usr/share/bats/bats-file/load'
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| bats-core 1.11.1 via apt | bats-core 1.13.0 via git clone | Only if `--abort` flag (fail-fast) or `--negative-filter` from 1.13.0 are specifically needed; apt version is simpler and keeps the project free of git submodule dependencies |
| ShellCheck via apt | ShellCheck via GitHub Actions or Docker | Only in a CI pipeline where Debian apt is not available; locally apt is sufficient |
| bats-assert via apt | Hand-rolled `_test()` function (current approach in test_refactor.sh) | Never for new test files; the hand-rolled function works but lacks `assert_output --partial`, `refute_output`, and `assert_line`; extend existing test_refactor.sh only if migrating to bats is deferred |
| bats-file via apt | Manual `[ -f ]` checks inside bats tests | Acceptable for simple single-file checks; use bats-file when asserting directory trees or multiple filesystem outputs from the installer |
| ShellSpec | ShellSpec for BDD-style tests | If the team wants Given/When/Then syntax; overkill for this project's scope; bats is sufficient and simpler |
| Bach Framework | Bach for pure unit tests with no side effects | If mocking external commands becomes necessary; Bach treats all PATH commands as mocks by default; relevant only if testing installer logic that calls `apt`, `git clone`, `pipx install` without actually running them |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| sstephenson/bats (original, unmaintained) | Last commit 2017; no maintenance; pre-1.0 API; not in Trixie repos | bats-core via `sudo apt install bats` |
| `which` for command existence checks in tests | Not POSIX; behaves differently across distributions; can return exit 0 for aliases that do not exist as binaries | `command -v toolname` in test assertions |
| pytest or Python test frameworks | Introduces a Python runtime dependency into a pure-Bash project; violates the project constraint of no Python frameworks for launcher testing | bats-core |
| Node.js/Jest | No Node.js runtime in this project; violates project constraints | bats-core |
| Running tests directly against the production VM without a clean snapshot | Tests become non-repeatable; a failed tool install is indistinguishable from a test environment issue | Snapshot the VM before the full installer test run; restore snapshot between full end-to-end runs |

## Stack Patterns by Variant

**For unit tests (no VM, no network, no tools installed) — like the current test_refactor.sh:**
- Use bats-core with bats-assert
- Source `common.sh` directly inside the bats `setup()` function
- Mock Zenity by overriding it in PATH: `zenity() { echo "mock"; }` exported before the tested function runs
- Test `classify_input`, `load_manifest`, function availability, line-count constraints

**For post-install verification on a live VM (tools actually installed):**
- Use bats-core with bats-assert and bats-file
- Tests check `command -v toolname` returns 0
- Tests check `$PROGRAMS_DIR/toolname` directory exists for repo-based tools
- Tests check pipx-installed tools appear in `$HOME/.local/bin`
- Do not assert tool output correctness — only assert availability and invocability with `--help` or `--version`

**For installer smoke test (full speculator_install.sh run on clean VM):**
- Run `bash -n speculator_install.sh` first as a syntax gate
- Run `sudo ./speculator_install.sh --dry-run` if that flag exists, otherwise run directly on a fresh VM snapshot
- After install completes, run `bash tests/test_post_install.bats` to assert 57 tools are reachable
- Check exit code of installer; non-zero = fail immediately

**For maigret-web.sh verification:**
- bats test launches the script with a mock target, waits with a `sleep` or `until curl` loop, asserts HTTP 200 on port 5001
- Teardown kills the background process

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| bats 1.11.1 | bats-assert 2.1.0, bats-support 0.3.0, bats-file 0.4.0 | All from Trixie apt; confirmed compatible in Debian packaging |
| ShellCheck 0.10.0 | Bash 5.x (Debian 13 default) | `--shell=bash` flag required; 0.10.0 added several new checks vs 0.9.x |
| bats-core `load` path | `/usr/share/bats/` on Debian apt install | Different from git-clone install which uses relative paths; use absolute paths in load statements |

## Sources

- https://github.com/bats-core/bats-core/releases — confirmed v1.13.0 is latest upstream; v1.11.1 is in Trixie apt (HIGH confidence)
- https://packages.debian.org/trixie/bats — confirmed bats 1.11.1-1 in Trixie (HIGH confidence)
- https://packages.debian.org/testing/devel/bats-assert — bats-assert 2.1.0-3, bats-file 0.4.0-1, bats-support 0.3.0-4 in Trixie (HIGH confidence)
- https://packages.debian.org/trixie/shellcheck — ShellCheck 0.10.0-1 in Trixie (HIGH confidence)
- https://bats-core.readthedocs.io/en/stable/installation.html — apt install method and load path (MEDIUM confidence; path confirmed via Debian packaging)
- https://github.com/bats-core/bats-assert/releases — v2.2.4 is latest upstream; Trixie ships 2.1.0 (HIGH confidence)
- https://github.com/tracelabs/tlosint-vm — TraceLabs OSINT VM has no automated test suite; manual VM testing is the industry norm for OSINT distributions (MEDIUM confidence)
- https://github.com/SOsintOps/Argos — Argos OSINT VM also has no formal test suite; relies on clean-VM manual testing (MEDIUM confidence)

---
*Stack research for: Bash testing and OSINT tool installation verification*
*Researched: 2026-05-06*

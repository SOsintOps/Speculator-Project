# Project Research Summary

**Project:** Speculator — Debian 13 OSINT VM Installer and Launcher
**Domain:** Bash installer testing, post-install verification, hub-and-spoke launcher architecture
**Researched:** 2026-05-06
**Confidence:** HIGH

## Executive Summary

The Speculator Project is a pure-Bash OSINT environment installer and launcher for Debian 13 Trixie. It installs 57 tools across 12 categories and exposes them through a hub-and-spoke GUI launcher built on Zenity. The current milestone requires closing four open gaps: expanding automated test coverage from 5 to all 12 categories, verifying the installer end-to-end on a clean VM, confirming maigret-web.sh launches correctly, and finalising user.sh as the template for spoke scripts.

No comparable OSINT VM installer (TraceLabs OSINT VM, OSINTLAB, Argos) has an automated test suite. The Speculator approach is already ahead of the field; the work is coverage depth, not framework adoption.

The recommended approach is a layered test strategy that keeps repo-level automated tests strictly separate from VM-level verification. Repo tests (plain Bash, no external dependencies) cover logic: manifest integrity, function routing, classify_input edge cases, and common.sh sourcing. VM tests cover system reality: tool availability, venv existence, Go PATH resolution, and the installer exit summary.

## Key Findings

### Stack

All required tools are available in Debian 13 Trixie official repositories. The existing pure-Bash `_test()` helper in test_refactor.sh is sufficient for the current milestone.

- **bats-core 1.11.1** available via apt on Trixie; adopt only if parallel test execution becomes a real need
- **ShellCheck 0.10.0** available via apt; run as pre-test static analysis gate on every .sh file
- **bats-assert 2.1.0, bats-support 0.3.0, bats-file 0.4.0** all in Trixie apt if bats is adopted
- No OSINT distribution has an automated test suite; Speculator is already ahead

### Table Stakes Features

- Manifest completeness for all 12 categories with expected tool counts
- Binary/PATH check per tool using `command -v` for binary/pipx/go check types
- Repo directory existence check for all `check_type=repo` tools
- Venv existence check for all `needs_venv=yes` tools
- maigret-web.sh: port 5001 binds and process terminates cleanly
- Structured test runner: `bash tests/run_all.sh` aggregates all test files
- Script syntax validation (`bash -n`) for all .sh files

### Critical Pitfalls

1. **Binary present but tool broken** -- `command -v` passes while venv is corrupted. Add a second tier: run every tool with `--help` or `--version` and assert exit 0.
2. **Zenity blocks all headless tests** -- Any test exercising `run_category` hangs without a display. Add `SPECULATOR_HEADLESS=1` guard to common.sh before any test exercises these paths.
3. **`tracked()` masks install failures** -- Installer exits 0 regardless of individual tool failures. Add a machine-readable `install_failures.txt`.
4. **Go tools absent from PATH** -- `common.sh` exports `$HOME/.local/bin` but not `$HOME/go/bin`. Six Go tools are invisible in fresh terminal sessions.
5. **API-key tools produce empty output counted as passing** -- h8mail, ghunt, toutatis exit 0 with zero-byte output when no credentials configured.

### Architecture Approach

Six components in the test architecture:

1. `tests/test_refactor.sh` (existing) -- source chain, classify_input(), manifest loading, dedup guards
2. `tests/test_manifest.sh` (new) -- tools.conf field integrity for all 12 categories
3. `tests/test_common.sh` (new) -- run_tool() edge cases, session dir creation, error handling
4. `tests/test_classify.sh` (new) -- extended classify_input() edge case coverage
5. `tests/helpers/mock_zenity.sh` (new) -- PATH stub preventing Zenity from blocking headless tests
6. VM verification procedure (manual) -- installer end-to-end, tool availability, maigret-web.sh port check

## Implications for Roadmap

### Suggested Phases (6)

1. **Unblock Headless Testing** -- Zenity PATH stub and BASH_SOURCE guard; hard prerequisites for all other test work
2. **Manifest and Classification Tests** -- pure-logic, no environmental dependencies, closes the 5-of-12 category gap
3. **Common Library Tests** -- run_tool() and session management once the Zenity stub is in place
4. **Test Runner and Syntax Gate** -- `run_all.sh` and `bash -n` formalise the suite as a repeatable pre-VM check
5. **VM Installer Validation** -- system-layer validation after logic layer is confirmed clean
6. **user.sh Finalisation** -- spoke template annotation and idempotency procedure documentation

### Phase Ordering Rationale

- Phase 1 before everything: Zenity and BASH_SOURCE guards are hard blockers
- Phases 2-3 before Phase 5: logic errors discovered on VM take far longer to diagnose
- Phase 4 after test files exist: a runner with no test files has no value
- Phase 5 after Phase 4: run full automated suite locally before committing VM time
- Phase 6 last: delivers spoke template for future work but does not block VM validation

### Research Flags

Phases needing deeper research during planning: Phase 5 (post-install checklist for 57 tools), Phase 6 (spoke template contract)

Standard patterns, skip research: Phases 1, 2, 3, 4

## Gaps to Address

- `install_failures.txt` does not yet exist in the installer
- `needs_credentials` field absent from tools.conf
- theHarvester uses `.venv` not `theHarvesterEnvironment` (naming anomaly)
- `$HOME/go/bin` missing from PATH export in common.sh
- maigret-web.sh port conflict handling not yet documented

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages confirmed in Debian Trixie official repos |
| Features | HIGH | Derived from direct codebase reading |
| Architecture | HIGH | Based on codebase reading plus verified bats-core documentation |
| Pitfalls | HIGH | Derived from direct inspection of installer, tools.conf, common.sh |

---
*Research completed: 2026-05-06*
*Ready for roadmap: yes*

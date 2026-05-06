# Roadmap: Speculator Project

## Overview

This milestone closes five open gaps in the Speculator project: unblocking headless test execution, expanding automated test coverage from 5 to all 12 tool categories, verifying common.sh functions under test, formalising a repeatable test runner, and confirming the installer and launcher work end-to-end on a clean Debian 13 Trixie VM.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Headless Unblock** - Add BASH_SOURCE guard, Zenity PATH stub, and Go PATH export so tests can run without a display
- [ ] **Phase 2: Manifest and Classification Tests** - ShellCheck gate plus tests covering all 12 manifest categories and classify_input edge cases
- [ ] **Phase 3: Common Library Tests** - Automated tests for run_tool(), session directory creation, and error handling in common.sh
- [ ] **Phase 4: Test Runner and Syntax Gate** - run_all.sh aggregates all test files; bash -n validates every script before execution
- [ ] **Phase 5: VM Validation** - End-to-end installer run, 57-tool availability check, maigret-web.sh port test, and user.sh category walkthrough on clean VM

## Phase Details

### Phase 1: Headless Unblock
**Goal**: Automated tests can run in a headless environment without Zenity blocking execution and without Go tools being invisible
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03
**Success Criteria** (what must be TRUE):
  1. Sourcing user.sh in a test script does not trigger main() execution
  2. Running a test that calls run_category() does not hang waiting for a display
  3. Go tools (amass, subfinder, etc.) resolve via `command -v` in a fresh terminal session after common.sh is sourced
**Plans**: TBD

### Phase 2: Manifest and Classification Tests
**Goal**: The test suite catches manifest gaps and input routing errors across all 12 tool categories, with ShellCheck running as a static gate before any tests execute
**Depends on**: Phase 1
**Requirements**: INFRA-04, TEST-01, TEST-02
**Success Criteria** (what must be TRUE):
  1. ShellCheck runs on every .sh file and blocks test execution if any warning is found
  2. tests/test_manifest.sh asserts expected tool counts for all 12 categories and fails clearly if a category is missing or underpopulated
  3. tests/test_classify.sh covers phone/hash disambiguation, boundary inputs, and all five classify_input() return values
  4. A new tool added to tools.conf with a wrong field count causes test_manifest.sh to fail with a named error
**Plans**: TBD

### Phase 3: Common Library Tests
**Goal**: run_tool(), session directory creation, and error paths in common.sh are covered by automated tests that run without a display
**Depends on**: Phase 1
**Requirements**: TEST-03
**Success Criteria** (what must be TRUE):
  1. tests/test_common.sh verifies that run_tool() routes a known tool entry to the correct execution path
  2. tests/test_common.sh confirms session directories are created under $HOME/Downloads/evidence/{target}/
  3. tests/test_common.sh detects and reports a non-zero exit from a tool invocation
**Plans**: TBD

### Phase 4: Test Runner and Syntax Gate
**Goal**: A single entry point runs the full test suite and syntax-checks every script; a developer can verify the entire repo with one command
**Depends on**: Phase 3
**Requirements**: TEST-04, TEST-05
**Success Criteria** (what must be TRUE):
  1. `bash tests/run_all.sh` executes all test files and prints a pass/fail summary with per-file counts
  2. run_all.sh exits non-zero if any individual test file reports a failure
  3. `bash -n` validation runs on every .sh file before any test executes, and a script with a syntax error causes the entire run to abort with a named file and line number
**Plans**: TBD

### Phase 5: VM Validation
**Goal**: The installer, launcher, and web tool all work correctly on a clean Debian 13 Trixie VM with zero manual intervention after running speculator_install.sh
**Depends on**: Phase 4
**Requirements**: VM-01, VM-02, VM-03, VM-04
**Success Criteria** (what must be TRUE):
  1. speculator_install.sh runs to completion on a clean VM with exit code 0 and no error lines in the install log
  2. A post-install availability check confirms all 57 tools are reachable via their declared check_type (binary, pipx, go, or repo directory)
  3. maigret-web.sh starts without error, port 5001 binds, and the web UI loads in Firefox ESR
  4. user.sh accepts a test target and completes a run for all five person-tracking categories (email, username, fullname, hash, phone) without hanging or crashing
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Headless Unblock | 0/TBD | Not started | - |
| 2. Manifest and Classification Tests | 0/TBD | Not started | - |
| 3. Common Library Tests | 0/TBD | Not started | - |
| 4. Test Runner and Syntax Gate | 0/TBD | Not started | - |
| 5. VM Validation | 0/TBD | Not started | - |

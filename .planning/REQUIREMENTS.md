# Requirements: Speculator Project

**Defined:** 2026-05-06
**Core Value:** The installer runs end-to-end on a clean Debian 13 VM, every tool works, and the launcher scripts let an analyst run any OSINT tool against a target with zero manual setup.

## v1 Requirements

Requirements for this milestone. Each maps to roadmap phases.

### Testing Infrastructure

- [ ] **INFRA-01**: user.sh has BASH_SOURCE guard so functions can be sourced without executing main()
- [ ] **INFRA-02**: tests/helpers/mock_zenity.sh stub prevents Zenity from blocking headless test runs
- [ ] **INFRA-03**: common.sh exports $HOME/go/bin in PATH (fixes 6 Go tools invisible in fresh sessions)
- [ ] **INFRA-04**: ShellCheck runs on all .sh files as pre-test static analysis gate

### Automated Tests

- [ ] **TEST-01**: Manifest integrity tests cover all 12 categories with expected tool counts
- [ ] **TEST-02**: classify_input() tested with extended edge cases (phone/hash disambiguation, boundary inputs)
- [ ] **TEST-03**: common.sh functions tested (run_tool, session dir creation, error detection)
- [ ] **TEST-04**: tests/run_all.sh entry point aggregates all test files with pass/fail summary
- [ ] **TEST-05**: bash -n syntax validation runs on every .sh file before tests execute

### VM Verification

- [ ] **VM-01**: speculator_install.sh runs end-to-end on clean Debian 13 Trixie VM
- [ ] **VM-02**: Post-install availability check confirms all 57 tools are present and accessible
- [ ] **VM-03**: maigret-web.sh launches, port 5001 binds, web UI is accessible in browser
- [ ] **VM-04**: user.sh tested on VM with all 5 person-tracking categories (email, username, fullname, hash, phone)

## v2 Requirements

Deferred to future milestones. Tracked but not in current roadmap.

### Spoke Scripts

- **SPOKE-01**: domain.sh sources common.sh and uses run_category() for domain tools
- **SPOKE-02**: instagram.sh sources common.sh and uses run_category() for Instagram tools
- **SPOKE-03**: reddit.sh sources common.sh and uses run_category() for Reddit tools
- **SPOKE-04**: video.sh sources common.sh and uses run_category() for video tools
- **SPOKE-05**: archives.sh sources common.sh and uses run_category() for archive tools
- **SPOKE-06**: image.sh sources common.sh and uses run_category() for image/metadata tools
- **SPOKE-07**: frameworks.sh sources common.sh and uses run_category() for framework tools
- **SPOKE-08**: update.sh manages tool updates (pipx upgrade-all, git pull)

### Quality Improvements

- **QUAL-01**: Machine-readable install_failures.txt written by installer
- **QUAL-02**: needs_credentials annotation in tools.conf for API-key-dependent tools
- **QUAL-03**: Venv sentinel checks (binary + --help/--version assert exit 0)
- **QUAL-04**: user.sh extension-point annotations for spoke developers
- **QUAL-05**: Idempotency procedure documented and verified on VM snapshot

### JSON Output (Phase C)

- **JSON-01**: Per-tool normalised JSON output schema
- **JSON-02**: Parser in each spoke script transforms tool output to structured JSON

## Out of Scope

| Feature | Reason |
|---------|--------|
| bats-core adoption | Adds dependency to a zero-dependency test suite; plain Bash _test() helper is sufficient |
| Parallel test execution | Not needed at current test count; revisit when suite exceeds 100 tests |
| Per-category test file split | Single test files are readable at current size |
| Live tool execution against real targets in tests | Flaky, network-dependent, privacy risk |
| Zenity mocking via Xvfb | Adds heavy dependency for minimal gain; PATH stub is sufficient |
| Multi-language support for launchers | Pending architectural decision |
| New tools from TODO list | Separate milestone |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| INFRA-01 | Phase TBD | Pending |
| INFRA-02 | Phase TBD | Pending |
| INFRA-03 | Phase TBD | Pending |
| INFRA-04 | Phase TBD | Pending |
| TEST-01 | Phase TBD | Pending |
| TEST-02 | Phase TBD | Pending |
| TEST-03 | Phase TBD | Pending |
| TEST-04 | Phase TBD | Pending |
| TEST-05 | Phase TBD | Pending |
| VM-01 | Phase TBD | Pending |
| VM-02 | Phase TBD | Pending |
| VM-03 | Phase TBD | Pending |
| VM-04 | Phase TBD | Pending |

**Coverage:**
- v1 requirements: 13 total
- Mapped to phases: 0
- Unmapped: 13

---
*Requirements defined: 2026-05-06*
*Last updated: 2026-05-06 after initial definition*

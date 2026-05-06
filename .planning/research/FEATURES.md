# Feature Research

**Domain:** Bash installer testing and verification system for OSINT VM
**Researched:** 2026-05-06
**Confidence:** HIGH (code base read directly; testing patterns verified against bats-core docs and community sources)

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features that must exist or the test suite is not credible. Missing any of these means an analyst cannot trust a passing test run.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Binary/binary-on-PATH check per tool | Every installer test starts here: is the tool reachable at all? | LOW | Use `command -v` for binary/pipx/go tools; already used in tools.conf `check_type` field |
| Repo directory existence check per tool | Confirms git-clone step completed for repo-type tools | LOW | Check `$PROGRAMS_DIR/{check_value}` for each `check_type=repo` entry in tools.conf |
| venv existence check per repo tool | Confirms Python venv was created inside the repo directory | LOW | Check `$PROGRAMS_DIR/{venv_name}/bin/python` exists for tools where `needs_venv=yes` |
| Manifest completeness: all 57 entries present | tools.conf is the single source of truth; test must verify nothing was dropped | LOW | Count entries per category; compare against known totals already in test_refactor.sh |
| Manifest field integrity for all 12 categories | Each tool entry must have non-empty name, id, category, check_type, check_value, command | LOW | Extend existing section 4 in test_refactor.sh to cover all categories, not just email |
| Exit code assertions on tool execution | A tool that crashes on first run is broken; test must capture this | MEDIUM | Use `run` pattern from bats-core or `$?` capture; mock the target input to avoid network calls |
| Output file or directory created after dry-run | Confirms command_template expansion works correctly | MEDIUM | Use a synthetic target (e.g. `test@example.com`) against a tool with `--help` or offline mode |
| Failure summary with pass/fail counts | Without a summary, a multi-test run gives no clear signal | LOW | Already in test_refactor.sh; must carry forward to all new test files |
| Non-zero exit code on any failure | CI and human operators need a reliable signal | LOW | Already in test_refactor.sh (`[ "$FAIL" -eq 0 ] && exit 0 || exit 1`) |
| Script syntax validation for all Bash files | Catches parse errors before any execution | LOW | `bash -n` on every .sh file; include in pre-test phase |
| maigret-web.sh: web server starts and binds port 5001 | Confirms the web launcher works; the web UI is the entire point of that script | MEDIUM | Check `curl -s http://localhost:5001` returns non-empty; kill process after test |
| Evidence directory created per target | The output path `$HOME/Downloads/evidence/{target}/` must be created before tools write to it | LOW | Verify `mkdir -p` behaviour in run_category; test with a synthetic target |
| common.sh loads without error in all sourcing contexts | Every spoke script sources common.sh; if it breaks on edge cases, all launchers break | LOW | Already tested for user.sh; verify the same for maigret-web.sh |

### Differentiators (Competitive Advantage)

Features that go beyond basic verification and give the test suite lasting value as the project scales to 12 spoke scripts.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Category-by-category test file structure | One test file per category (test_email.sh, test_username.sh, etc.) mirrors the hub-and-spoke architecture; failures isolate immediately | LOW | Keep test_refactor.sh for structural/unit tests; add per-category files for manifest + availability |
| Offline smoke test mode | Runs all tool availability checks without network access; safe for air-gapped VM post-install | LOW | `command -v`, `[ -d ]`, `[ -f ]` checks require no network; flag or separate test file |
| Idempotency assertion for installer | Re-running speculator_install.sh on an already-configured VM must not break existing tool venvs or overwrite configs | MEDIUM | Run installer twice on VM snapshot; diff tool states before and after second run |
| maigret-web.sh report directory assertion | Confirms Maigret writes its output to the expected path, not a default working directory | LOW | Check `$HOME/Downloads/evidence/{target}/` after a test scan |
| Tool count regression guard | If tools.conf gains or loses an entry, a test immediately flags it; prevents silent manifest drift | LOW | Hard-code expected counts per category; already done for 5 categories in test_refactor.sh, extend to all 12 |
| user.sh category dispatch test | Verify that each of the 5 input types (email, username, fullname, hash, phone) routes to the correct manifest category via classify_input | LOW | Already partially in test_refactor.sh section 2; extend to cover boundary cases |
| Structured test runner script | A single `bash tests/run_all.sh` entry point runs all test files in order and aggregates pass/fail | LOW | Iterate over `tests/test_*.sh`; print per-file and total summary |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Live tool execution against real targets in tests | "Let's make sure Sherlock actually finds accounts" | Requires network, external services, real targets; flaky, slow, and a privacy risk in a test context | Test tool availability (binary exists, venv activates, `--help` exits 0) not tool results |
| Mocking Zenity in tests | "Tests should simulate the full GUI flow" | Zenity requires a display; mocking it adds complexity (Xvfb or X11 forwarding) for minimal gain | Test the non-GUI logic (classify_input, load_manifest, run_category) which is what can actually fail |
| BATS framework adoption | "bats-core is the standard" | Adds a dependency (git submodule or apt install) to a project that deliberately has zero external test dependencies; current pure-Bash approach works and needs no install step | Stay with pure-Bash test_*.sh files using the existing `_test()` helper; add bats only if parallel test execution becomes a real need |
| Automated VM provisioning in CI (Vagrant/Docker) | "Run tests on every push" | This is a Debian 13 VirtualBox VM; Docker cannot replicate VirtualBox guest additions, Zenity, or the full Debian 13 environment | Manual VM test with snapshot revert is sufficient for this project's scale; document the manual test procedure clearly |
| Output content validation (parse tool results) | "Verify Holehe returned at least one result for a known email" | Tool output formats change upstream; content depends on external service availability; brittle and unmaintainable | Validate that the output file was created and is non-empty, not what it contains |
| Per-tool unit tests with mocked commands | "Mock every system call" | Pure-Bash mocking is fragile; maintaining mocks for 57 tools is higher cost than value at this project scale | Test the manifest loading and command template expansion; trust that a tool which passes binary + venv checks will run |

---

## Feature Dependencies

```
Manifest completeness check (all 12 categories)
    requires: Manifest field integrity check (all 12 categories)
        requires: load_manifest() tested and working

Binary/PATH check per tool
    requires: tools.conf parsed correctly (check_type, check_value fields)

venv existence check
    requires: repo directory existence check
        requires: PROGRAMS_DIR path resolved correctly

maigret-web.sh port binding test
    requires: maigret binary available (pipx check)
        requires: Binary/PATH check for maigret

Structured test runner (run_all.sh)
    requires: Individual test files (test_refactor.sh, test_manifest.sh, test_availability.sh)

Evidence directory creation test
    requires: run_category() tested (common.sh)

Idempotency assertion
    requires: VM snapshot capability (manual prerequisite, not code)

user.sh category dispatch test
    requires: classify_input() tested (already done)
        enhances: maigret-web.sh integration (maigret is a username-category tool)
```

### Dependency Notes

- **Manifest field integrity requires load_manifest():** The parser must work before you can assert field contents. Section 3 and 4 of test_refactor.sh establish this correctly; extend rather than rewrite.
- **Binary check requires correct check_type field:** If a tool has the wrong check_type (e.g. `binary` instead of `pipx`), the check passes vacuously. The manifest field integrity check is therefore a prerequisite for trusting binary checks.
- **venv check requires repo directory:** A venv inside a missing repo directory cannot exist. Check repo first, fail fast.
- **Idempotency assertion requires a VM snapshot:** This is an infrastructure dependency, not a code dependency. Document the manual procedure: restore snapshot, run installer, snapshot again, run installer again, diff.
- **run_all.sh enhances all individual tests:** It does not change what they test, but it provides the single entry point needed for a post-install verification pass on the VM.

---

## MVP Definition

### Launch With (this milestone)

Minimum required for the milestone goal: "test installer + test tools on VM + expand automated tests + verify maigret-web + finalise user.sh."

- [ ] Manifest completeness: extend load_manifest tests to all 12 categories with expected counts
- [ ] Binary/PATH check for all 57 tools: one assertion per tool, grouped by check_type
- [ ] Repo directory existence check for all `check_type=repo` tools
- [ ] venv existence check for all `needs_venv=yes` tools
- [ ] maigret-web.sh: port 5001 binds and process terminates cleanly after test
- [ ] Evidence directory creation verified via run_category() synthetic call
- [ ] Structured test runner: `bash tests/run_all.sh` aggregates all test files
- [ ] Script syntax validation (`bash -n`) for all .sh files as pre-test step

### Add After Validation (v1.x)

Add once core tests are green and the VM pass is confirmed.

- [ ] Idempotency test procedure documented and manually verified on VM snapshot
- [ ] user.sh finalised as template: annotated with comments marking extension points for spoke scripts
- [ ] Per-category test files (test_email.sh, test_username.sh, etc.) if total test count makes test_refactor.sh too large

### Future Consideration (v2+)

Defer until spoke scripts are being built.

- [ ] Per-spoke-script availability tests (domain.sh, instagram.sh, etc.) once those scripts exist
- [ ] Offline mode flag for test runner to skip network-dependent checks
- [ ] Test coverage for normalised JSON output (Phase C milestone)

---

## Feature Prioritisation Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Manifest completeness: all 12 categories | HIGH | LOW | P1 |
| Binary/PATH check for all 57 tools | HIGH | LOW | P1 |
| Repo directory existence check | HIGH | LOW | P1 |
| venv existence check | HIGH | LOW | P1 |
| maigret-web.sh port binding test | HIGH | MEDIUM | P1 |
| Evidence directory creation test | MEDIUM | LOW | P1 |
| Structured test runner (run_all.sh) | MEDIUM | LOW | P1 |
| Script syntax validation (bash -n) | MEDIUM | LOW | P1 |
| Idempotency assertion (VM snapshot) | MEDIUM | MEDIUM | P2 |
| user.sh finalised as spoke template | MEDIUM | LOW | P2 |
| Per-category test file split | LOW | LOW | P3 |
| Live tool execution against real targets | LOW | HIGH | do not build |

**Priority key:**
- P1: Required for milestone completion
- P2: Strengthens the milestone, add if time allows
- P3: Nice to have, next milestone

---

## Comparable Projects Analysed

| Feature | OSINTLAB (Purpl3-Dev) | Travis-CI-style Bash test | Speculator approach |
|---------|----------------------|--------------------------|---------------------|
| Tool availability check | None (installs and hopes) | `command -v` per tool | tools.conf check_type field drives the check |
| Manifest-driven tests | None | N/A | load_manifest() + category counts |
| venv verification | None | Not applicable | needs_venv + venv_name fields |
| Test isolation | None | setup/teardown | Synthetic target, no network |
| Test runner | None | bats-core | Pure Bash `_test()` helper |
| GUI dependency in tests | N/A | N/A | Deliberately excluded; test logic only |

OSINTLAB and similar OSINT installer scripts have no test suites at all. The Speculator test approach is already ahead of the field. The gap is coverage depth: test_refactor.sh covers 5 of 12 categories and structural checks only. The milestone closes that gap.

---

## Sources

- [bats-core writing tests documentation](https://bats-core.readthedocs.io/en/stable/writing-tests.html) — MEDIUM confidence (official docs, version-current)
- [bats-core GitHub repository](https://github.com/bats-core/bats-core) — MEDIUM confidence (reference only; not adopting bats)
- [How to write idempotent Bash scripts](https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/) — MEDIUM confidence (community, 2019, patterns still valid)
- [smoke.sh minimal smoke testing framework](https://github.com/asm89/smoke.sh) — LOW confidence (reference pattern only)
- [OSINTLAB installer](https://github.com/Purpl3-Dev/OSINTLAB) — MEDIUM confidence (comparable project, directly examined)
- [pipx idempotency issue](https://github.com/pypa/pipx/issues/1538) — MEDIUM confidence (confirms pipx reinstall behaviour)
- Project source files read directly: `tests/test_refactor.sh`, `config/tools.conf`, `.planning/PROJECT.md`, `CLAUDE.md`

---
*Feature research for: Bash installer testing and verification, OSINT VM (Speculator Project)*
*Researched: 2026-05-06*

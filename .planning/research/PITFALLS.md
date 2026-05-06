# Pitfalls Research

**Domain:** Bash installer and test suite for an OSINT VM toolset (Debian 13, Zenity GUI, 57+ tools)
**Researched:** 2026-05-06
**Confidence:** HIGH — derived from direct project file inspection, confirmed against community sources

---

## Critical Pitfalls

### Pitfall 1: Confusing "binary present on PATH" with "tool actually works"

**What goes wrong:**
A test calls `command -v sherlock` and reports PASS. The binary exists, but the pipx-managed venv is corrupted, or the wrong Python version was linked during a system upgrade. The launcher then produces empty output or a traceback at runtime. The test suite shows 57/57 green and the tools are broken.

**Why it happens:**
`check_type = pipx` in `tools.conf` maps directly to `command -v`. That verifies the shim exists in `~/.local/bin`, not that it executes. The same gap exists for `check_type = repo` tools where the directory exists but the venv inside is missing or broken.

**How to avoid:**
Add a second verification tier. For each tool, run it with a no-op or `--version` / `--help` flag immediately after the install step. Record the exit code. A tool passes the install check only if the binary both exists AND exits 0 on a safe flag. In the test suite, add smoke tests that call `holehe --help 2>&1 | head -1` and assert a non-empty, non-error first line.

**Warning signs:**
- `mark_ok` fires for a tool but the output file is zero bytes on the first real run.
- `pip` succeeded but the venv dir is present with no `bin/python` inside.
- A go tool shim is on PATH but `stalkie --version` returns 127 after a Go toolchain update.

**Phase to address:**
VM installer validation phase. Add a post-install verification pass that runs every tool with `--help` or `--version` and records results separately from the install pass.

---

### Pitfall 2: Zenity blocking all test runs that import common.sh

**What goes wrong:**
`common.sh` imports Zenity helpers. Any test that sources `common.sh` in a headless environment (no `$DISPLAY`, no Wayland socket) will hang or error the moment any code path hits `zenity`. This is already documented in the milestone context but the consequences run deeper than they appear: even tests that never call `zenity_checklist` directly may trigger it if `run_category` is exercised.

**Why it happens:**
Zenity requires a live GTK display session. There is no `ZENITY_MOCK` or `--headless` flag in the upstream binary. The current test suite avoids this by only sourcing `common.sh` and not calling `run_category` end-to-end, but any future test that exercises the full launcher path will block without a stub.

**How to avoid:**
Define a `SPECULATOR_HEADLESS=1` environment variable. In `common.sh`, wrap every `zenity` call: `${SPECULATOR_HEADLESS:-0} = 1` and substitute `echo` for display calls and return a hardcoded empty string or a preset value for input calls. Tests set this variable at the top. The variable must be documented at the head of `common.sh` so spoke script authors know it exists.

**Warning signs:**
- A new test hangs with no output for more than 5 seconds.
- Adding a test for `run_category email` causes the entire suite to freeze.
- CI (if introduced later) fails silently with a timeout rather than a test failure.

**Phase to address:**
Test suite expansion phase. The headless stub must be added to `common.sh` before any test exercises `run_category` or `zenity_checklist` end-to-end.

---

### Pitfall 3: Silent success from `tracked()` masking real install failures

**What goes wrong:**
The `tracked()` function in `speculator_install.sh` calls `mark_fail` but then returns 0 (success) from the install step. The install log shows `FAIL: git:Profil3r` but the overall script continues and exits 0. A downstream test that checks the script's exit code passes. Manual inspection of the log is required to discover failures — it does not surface automatically in a test.

**Why it happens:**
The design is intentional: individual tool failures are non-fatal. The installer keeps going so one broken upstream does not abort 56 other installs. But this means the test suite cannot assert `exit 0 = success`. It must parse `_INSTALL_FAIL` or the log file instead.

**How to avoid:**
The installer should write a machine-readable summary at the end: a single file listing every `_INSTALL_FAIL` entry, one per line, at a predictable path (e.g. `$LOG_DIR/install_failures.txt`). Tests assert that file is either absent or empty for a clean install. This decouples "installer ran to completion" from "every tool installed successfully" — both are needed.

**Warning signs:**
- The VM test report says "56/56 OK" but the install log contains `FAIL:` lines.
- A test script checks `$?` from running the installer and sees 0, concluding success.
- A spoke script fails at runtime because a tool's venv was never created, but nothing flagged this during install.

**Phase to address:**
VM installer validation phase. Add a post-run assertion step that counts lines in `_INSTALL_FAIL` and fails the test if the count exceeds an accepted threshold.

---

### Pitfall 4: Upstream repo changes breaking install silently at next clean run

**What goes wrong:**
A git-cloned tool renames its main Python file, removes its `requirements.txt`, or changes its CLI flags between installs. The installer's `install_py_tool_from_git` clones the repo and either finds no requirements file (marks fail) or installs stale deps. The tool directory exists, so on a re-run the clone step is skipped entirely (`[ ! -d "$tool_dir" ]` is false). The venv is never updated.

**Why it happens:**
The installer caches by directory presence only. There is no hash-check, tag pin, or commit lock. Any `git clone` without `--branch` or `--depth 1` at a specific tag pulls `HEAD` of the default branch. Repos like `Turbolehe`, `Aliens_eye`, or `Carbon14` have no maintained releases.

**How to avoid:**
For tools that have caused problems before (see `tools.conf` notes on SpiderFoot, Mr.Holmes), pin a git commit hash or tag in the installer. Use `git clone --branch <tag>` where a stable tag exists. For tools with no tags, document the last known-good commit in a comment next to the install call. Add a `--update` flag to the installer that runs `git pull` in existing repos.

**Warning signs:**
- A tool's `requirements.txt` disappears from its repo.
- `pip install` inside `install_py_tool_from_git` succeeds but installs zero packages.
- A tool works on the current VM but fails on a fresh clone after 60 days.

**Phase to address:**
VM installer validation phase (initial), then spoke script phase when each new spoke is written and adds new git-cloned tools.

---

### Pitfall 5: API-key-dependent tools produce empty output, counted as passing

**What goes wrong:**
`h8mail`, `ghunt`, and `toutatis` exit 0 even when no API key or session token is configured. They produce an empty output file or a file containing only a header. A post-install smoke test that checks "exit code 0 and file is non-empty" will pass, but the tool has done nothing useful. This is indistinguishable from a real result without inspecting file content.

**Why it happens:**
These tools are designed for interactive use where the analyst provides credentials. They do not fail with a non-zero exit when credentials are absent; they run, find nothing, and exit cleanly. The test suite has no way to provide real credentials without committing secrets.

**How to avoid:**
Categorise all tools in `tools.conf` with a `needs_credentials` flag (or a comment). Tests for these tools assert only that the binary exists and exits 0 on `--help`. They do not assert on output content. Document this split explicitly: "binary availability" tests vs "runtime output" tests. Never promote a zero-byte output file to a passing result.

**Warning signs:**
- `ghunt email test@example.com` exits 0 and writes `0 bytes`.
- A test checks `[ -s "$outfile" ]` and fails because the file is empty, even though the tool is installed correctly.
- The launcher shows a "completed" message to the analyst but the output file contains only tool headers.

**Phase to address:**
Test suite expansion phase. Add explicit skip annotations for credential-dependent tools. Document in `tools.conf` which tools require runtime credentials.

---

### Pitfall 6: Go tools absent from PATH after installer runs as a different user context

**What goes wrong:**
The installer runs as root via `sudo`, but uses `run_as_user` to install Go tools as `$REAL_USER`. Go binaries land in `$REAL_HOME/go/bin`. The `common.sh` sets `PATH="$HOME/.local/bin:$PATH"` but does not include `$HOME/go/bin`. When the launcher is opened in a fresh terminal session, Go tools (enola, stalkie, amass, subfinder, httpx, nuclei, phoneinfoga) are not found.

**Why it happens:**
Go's install convention puts binaries in `~/go/bin` by default. The installer runs `go install` correctly, but `common.sh` and the user's `.bashrc` may not include this path. `command -v enola` returns non-zero, the manifest check fails, and the tool is shown as unavailable in the Zenity checklist.

**How to avoid:**
Add `$HOME/go/bin` to the `PATH` export in `common.sh` alongside `~/.local/bin`. The installer should also append it to the user's `.bashrc` if not already present. Verify this with a post-install check: `command -v enola` in a clean login shell (not the installer's subshell).

**Warning signs:**
- Go tools pass the install step but show as unavailable in the launcher.
- `enola --version` works inside the installer but not in a new terminal.
- The manifest `check_type = go` check fails despite the binary existing in `~/go/bin`.

**Phase to address:**
VM installer validation phase. The PATH export in `common.sh` is a one-line fix; verify it during the VM test by opening a fresh terminal and running `command -v amass`.

---

### Pitfall 7: Re-running the installer on a partially failed VM produces inconsistent state

**What goes wrong:**
The installer skips cloning if a repo directory exists (`[ ! -d "$tool_dir" ]`). If the first run cloned the repo but failed before creating the venv, a re-run will skip the clone, check for the venv, find it absent, and attempt to create it — but the requirements file may now be in the wrong path after the repo partially changed. The tool ends up in a state where the directory exists, the venv does not, and `check_type = repo` passes anyway because it only checks for the directory.

**Why it happens:**
The `check_value` for repo tools in `tools.conf` is the repo directory name. `tool_available()` in `common.sh` tests `[ -d "$PROGRAMS_DIR/$check_value" ]`. This passes as soon as the `git clone` completes, regardless of venv status.

**How to avoid:**
Change the manifest check for venv-dependent tools to test `[ -x "$PROGRAMS_DIR/$tool/$venvName/bin/python" ]` rather than just directory existence. Update `tool_available()` in `common.sh` to accept an optional second argument for a venv path check. Alternatively, add a sentinel file (e.g. `.install_ok`) written by the installer only after the venv is created successfully.

**Warning signs:**
- The launcher shows a venv tool as available but running it produces "no module named X".
- Re-running the installer on the same VM reports fewer failures than the first run, but some tools still fail at runtime.
- `[ -d PROGRAMS_DIR/Eyes ]` is true but `PROGRAMS_DIR/Eyes/EyesEnvironment/bin/python` does not exist.

**Phase to address:**
VM installer validation phase and test suite expansion phase. The sentinel file or venv path check must be in place before the test suite reports tool availability.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| `command -v` as the only install check | Fast, simple | Misses broken venvs and missing PATH entries | Never for venv-based tools; acceptable for system binaries only |
| No commit hash pinning in git clones | Always pulls latest features | Breaks on upstream rename or API change | Never for tools with a history of churn (Mr.Holmes, SpiderFoot pattern) |
| Skipping re-clone if directory exists | Prevents re-downloading on re-runs | Hides partial install failures | Acceptable only if paired with a venv sentinel check |
| Single log file, not machine-readable | Simple for humans | Cannot be parsed by tests without fragile grep | Acceptable for MVP; must be replaced before CI is added |
| Zenity calls not stubbed in tests | No extra code in common.sh | Entire test suite cannot run headless | Never; stub must be added before test suite expands |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| h8mail config file | Assuming `$HOME/h8mail_config.ini` exists after install | Installer must create a template config; test checks the file is present |
| GHunt OAuth session | Running ghunt in tests without a valid session token | Tests call `ghunt --help` only; document that runtime test requires a real session |
| Toutatis Instagram session | Passing `{session_id}` placeholder literally | The launcher must prompt for the session ID via Zenity before running the command |
| BDFR Reddit API | Running bdfr without a Reddit account token | bdfr exits 0 but writes an empty archive; test checks binary only, not output |
| Maigret web mode port 5001 | Assuming port is free | Test should check `ss -ltn | grep 5001` before starting and kill stale process |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Running all 57 tools in a single test pass | Test suite takes 30+ minutes; network timeouts cause random failures | Split tests into: (a) offline unit tests, (b) install verification, (c) optional runtime smoke tests | Immediately if network is slow or a tool hangs |
| No timeout on individual tool runs during testing | One hanging tool (e.g. Maigret without `--timeout`) blocks the entire suite | Set `timeout 30` prefix on every tool call in the test harness | First time a tool blocks on a dead upstream API |
| Amass running unconstrained in a VM test | Amass can run for hours on active mode; the test never finishes | Use `amass intel -d example.com -timeout 5` or mock the call | Any test that calls amass without a timeout |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Writing API keys to `$HOME/h8mail_config.ini` without noting it in `.gitignore` | Credentials committed to repo if analyst uses the project dir as working dir | Add `h8mail_config.ini` to `.gitignore`; installer creates the file with placeholder values only |
| Logging tool output that contains PII to `$HOME/Downloads/install_*.log` | Evidence directory may be shared or backed up inadvertently | Install log should record tool names and exit codes only, not command output containing target data |
| Session tokens for GHunt/Toutatis passed as CLI arguments | Tokens visible in `ps aux` output | Require tokens via environment variable or a config file, not inline in the command template |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Tool marked "available" in Zenity checklist but fails silently at runtime | Analyst thinks a tool ran; output file is empty or missing | Show a warning in the Zenity summary when the output file is zero bytes after a tool completes |
| No indication that a tool needs credentials before it is selected | Analyst runs h8mail, sees empty output, does not know why | Mark credential-dependent tools in the Zenity checklist with a suffix: "H8Mail (API key required)" |
| Mr.Holmes disabled but still visible in manifest comments | A new spoke author reads the manifest, tries to re-enable it, breaks automation | Add a `disabled` check_type to `tools.conf` that causes the parser to skip the entry without removing it from the file |

---

## "Looks Done But Isn't" Checklist

- [ ] **Tool availability check:** Directory exists but venv python is absent. Verify `[ -x $PROGRAMS_DIR/$tool/$venv/bin/python ]`, not just `[ -d $PROGRAMS_DIR/$tool ]`.
- [ ] **Go tools on PATH:** `go install` succeeded but `$HOME/go/bin` is not in `$PATH` in a fresh login shell. Verify by opening a new terminal and running `command -v amass`.
- [ ] **Credential-dependent tools produce output:** `ghunt`, `h8mail`, `toutatis` exit 0 with empty files. Verify the config/session file exists before calling the tool, not after.
- [ ] **Maigret web mode reachable:** The process starts but the web UI is on port 5001. Verify with `curl -s -o /dev/null -w "%{http_code}" http://localhost:5001` returning 200.
- [ ] **theHarvester's `.venv` vs the standard `*Environment` pattern:** It uses a `.venv` directory inside the repo, not `theHarvesterEnvironment`. Verify the correct path in any test that checks venv existence.
- [ ] **Installer log contains zero FAIL lines:** The script exits 0 regardless. Verify by grepping the log for `^FAIL:` and asserting zero matches.

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Broken venv for a single tool | LOW | Delete the tool's `*Environment` directory, re-run installer; it will skip the clone and recreate the venv |
| Go tool missing from PATH | LOW | Add `export PATH="$HOME/go/bin:$PATH"` to `.bashrc`; source it; verify |
| Upstream repo renamed or deleted | MEDIUM | Update the clone URL in `speculator_install.sh`; re-run installer; update `check_value` in `tools.conf` if the directory name changed |
| Zenity hang in CI/headless test | LOW | Kill the test process; add `SPECULATOR_HEADLESS=1` guard to `common.sh`; re-run |
| Partial install state after a failed run | MEDIUM | Delete the specific tool's directory from `PROGRAMS_DIR`; re-run installer; verify venv sentinel |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Binary present but tool broken | VM installer validation | Post-install smoke test: every tool exits 0 on `--help` or `--version` |
| Zenity blocks headless tests | Test suite expansion | All tests in `tests/` pass with `SPECULATOR_HEADLESS=1` and no display |
| tracked() masks failures | VM installer validation | `install_failures.txt` is empty after a clean Debian 13 run |
| Upstream repo drift | VM installer validation (initial) + each spoke phase | Installer pinned to a known-good tag or commit for each git-cloned tool |
| API-key tools false-positive | Test suite expansion | Credential-dependent tools annotated in `tools.conf`; tests skip output assertions for them |
| Go tools not on PATH | VM installer validation | Fresh terminal `command -v amass` returns a path under `$HOME/go/bin` |
| Partial install broken state | VM installer validation | Venv sentinel file present for every `needs_venv = yes` tool after install |

---

## Sources

- Direct inspection: `/mnt/h/github/Speculator-Project/speculator_install.sh`, `config/tools.conf`, `tests/test_refactor.sh`, `scripts/lib/common.sh`, `.planning/PROJECT.md`
- [Bach Unit Testing Framework — mocking strategy for bash](https://bach.sh/)
- [ShellSpec — skip/annotation features](https://shellspec.info/)
- [golang/go issue #64977 — $HOME/go/bin not added to PATH on install](https://github.com/golang/go/issues/64977)
- [golang/go issue #30268 — GOPATH/bin not on PATH](https://github.com/golang/go/issues/30268)
- [pypa/pipx issue #1538 — idempotent install](https://github.com/pypa/pipx/issues/1538)
- [How to write idempotent Bash scripts — Hacker News discussion](https://news.ycombinator.com/item?id=20375197)
- [script-dialog — headless fallback for GUI shell scripts](https://github.com/lunarcloud/script-dialog)
- [IBM APAR PM11421 — install script exits 0 on failure](https://www.ibm.com/support/pages/apar/PM11421)
- Milestone context: known issues with Mr.Holmes, SpiderFoot, GHunt, h8mail, toutatis, GOTOOLCHAIN

---
*Pitfalls research for: Bash OSINT VM installer and test suite (Speculator Project)*
*Researched: 2026-05-06*

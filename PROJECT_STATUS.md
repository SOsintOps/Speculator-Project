## Objective

Maintain and update the Speculator Project: a Bash-based installer that configures Debian 13 "Trixie" virtual machines for OSINT workflows. Current focus is on keeping tool lists, documentation and install scripts up to date for 2026.

## Modified Files

- `tests/test_speculator_install.sh` (new file — automated test suite, 24 tests)
- `.git/config` (local: `core.eol=lf`, `core.autocrlf=false` — enforces LF checkout on WSL/Windows)

## Logical State

- Completed:
  - Main install script `speculator_install.sh` updated for 2026 (commit d8b946f)
  - VirtualBox Guest Additions support updated
  - README.md reflects Debian 13 "Trixie" as the target OS
  - FAQ and documentation pages updated
  - `scripts/user.sh` v1.0.1 includes Maigret virtual environment fix
  - `scripts/user.sh` line endings normalised to LF (was CRLF, broke `bash -n` syntax check)
  - `core.eol=lf` set in local git config to prevent CRLF re-introduction on WSL/Windows checkouts
  - Automated test suite at `tests/test_speculator_install.sh`: 24 tests, all passing

- Open bugs / incomplete:
  - `start.ps1` (Windows launcher) not reviewed
  - No CI pipeline — tests must be run manually

## Next Action

Commit the new test file:
```bash
git add tests/test_speculator_install.sh
git commit -m "Add automated test suite for install script (24 tests)"
```

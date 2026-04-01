## Objective

Maintain and update the Speculator Project: a Bash-based installer that configures Debian 13 "Trixie" virtual machines for OSINT workflows. Current focus is on keeping tool lists, documentation and install scripts up to date for 2026.

## Modified Files

No files modified in this session.

Unstaged changes present from previous sessions (line-ending normalisation only, no functional changes):
- README.md
- document/FAQ.md
- document/speculatores.md
- scripts/user.sh
- LICENSE

## Logical State

- Completed:
  - Main install script `speculator_install.sh` updated for 2026 (commit d8b946f)
  - VirtualBox Guest Additions support updated
  - README.md reflects Debian 13 "Trixie" as the target OS
  - FAQ and documentation pages updated
  - `scripts/user.sh` v1.0.1 includes Maigret virtual environment fix

- Open bugs / incomplete:
  - Line-ending inconsistency (CRLF vs LF) across README.md, FAQ.md, speculatores.md, user.sh — not committed
  - No automated tests for the install script
  - `start.ps1` (Windows launcher) not reviewed this session

## Next Action

Review and commit the line-ending changes if intentional:
```bash
git add README.md document/FAQ.md document/speculatores.md scripts/user.sh LICENSE
git commit -m "Normalise line endings to LF"
```
Or revert them if unintended:
```bash
git checkout -- README.md document/FAQ.md document/speculatores.md scripts/user.sh LICENSE
```

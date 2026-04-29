# Contributing to the Speculator Project

Thank you for your interest in contributing. This document explains how to report issues, suggest features and submit code changes.

## Reporting Bugs

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md) when opening a new issue. Include your Debian version, Speculator version and the relevant section of the install log (`~/Downloads/install_*.log`).

## Suggesting Features

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md). Describe the OSINT use case and link to any relevant tool repositories or documentation.

## Submitting Pull Requests

1. Fork the repository and clone your fork.
2. Create a feature branch from `main` (e.g. `feature/add-tool-xyz`).
3. Make your changes. Keep each commit focused on a single logical change.
4. Run `bash -n` on every modified `.sh` file to verify syntax.
5. Test on a Debian 13 "Trixie" amd64 system if possible.
6. Push your branch and open a pull request with a clear description of what you changed and why.

## Coding Standards

This is a pure Bash project. No Node.js, no Python frameworks, no external build systems.

- All paths must use `$HOME`, never `~`.
- All `pushd` calls must include error handling.
- Evidence output goes to `$HOME/Downloads/evidence/{target}/`.
- Tools install to `$HOME/.local/share/speculator/programs/`.
- Zenity is the GUI framework for all launcher scripts.
- Keep individual files under 500 lines.
- Validate user input at system boundaries (Zenity dialogs, CLI arguments).
- Target OS is Debian 13 "Trixie" amd64. Do not introduce dependencies unavailable in official Debian 13 repos or via pipx, Go or Flatpak.

## File Organisation

- `/scripts/` for launcher scripts; `/scripts/lib/` for shared libraries.
- `/config/` for configuration files.
- `/tests/` for test files.
- `/documents/` for project documentation.
- `/media/icons/` for icon files.
- `/shortcuts/` for `.desktop` files.

## Files That Must Not Be Committed

The following files are local tooling configuration and must never be pushed to the repository:

- `.claude/` directory
- `CLAUDE.md`
- `.mcp.json`
- `PROJECT_STATUS.md`
- `.env` or any file containing secrets or credentials

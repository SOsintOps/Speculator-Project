# Speculator Project

## What This Is

A Bash installer and launcher system that configures a Debian 13 "Trixie" VM as a complete OSINT environment. It installs 57+ tools, configures browsers, sets up a hub-and-spoke launcher architecture with Zenity GUI, and organises evidence output per target. Inspired by *OSINT Techniques, 11th Edition* by Michael Bazzell.

## Core Value

The installer runs end-to-end on a clean Debian 13 VM, every tool works, and the launcher scripts let an analyst run any OSINT tool against a target with zero manual setup.

## Requirements

### Validated

- ✓ Installer (`speculator_install.sh` v0.8.9) installs 56/56 tools on Debian 13 Trixie -- existing
- ✓ Shared library (`scripts/lib/common.sh` v0.1.0) provides run_tool, run_category, manifest loading, session logging, Zenity helpers -- existing
- ✓ Hub launcher (`scripts/user.sh` v0.5.0) sources common.sh, handles 5 person-tracking categories via manifest-driven run_category() -- existing
- ✓ Tool manifest (`config/tools.conf` v1.0.0) with 57 entries across 12 categories -- existing
- ✓ Maigret web launcher (`scripts/maigret-web.sh` v0.2.0) runs native Maigret on port 5001 -- existing
- ✓ Firefox ESR enterprise policies (12 extensions, 34 bookmarks in 8 folders) -- existing
- ✓ Desktop shortcuts with __HOME__ substitution -- existing
- ✓ Automated refactor tests (`tests/test_refactor.sh`) covering source, classify_input, manifest loading, function availability, code deduplication -- existing

### Active

- [ ] Full installer test on clean Debian 13 VM (speculator_install.sh end-to-end)
- [ ] user.sh verified on VM with all 5 categories (email, username, fullname, hash, phone)
- [ ] maigret-web.sh verified on VM (launch, web UI accessible, reports directory)
- [ ] Expanded automated test suite covering manifest integrity for all 12 categories
- [ ] user.sh finalised as definitive template for future spoke scripts

### Out of Scope

- Spoke scripts (domain.sh, instagram.sh, reddit.sh, video.sh, archives.sh, image.sh, frameworks.sh, update.sh) -- next milestone
- Normalised JSON output (Phase C) -- future milestone
- Phone number category expansion (Phase D tools beyond ignorant + phoneinfoga) -- future milestone
- New tools from TODO list (Maryam, sterraxcyl, Terra, HostHunter, etc.) -- future milestone
- Multi-language support for launcher scripts -- pending decision

## Context

- Target OS: Debian 13 "Trixie" amd64, VirtualBox VM
- Pure Bash project; no Node.js, Python frameworks, or package.json
- Hub-and-spoke architecture: user.sh is the hub, spoke scripts handle specialised investigation types
- All tool metadata centralised in pipe-delimited config/tools.conf
- Shared code in scripts/lib/common.sh, sourced by all launchers
- Zenity is the UI framework for all GUI interaction
- Evidence output to $HOME/Downloads/evidence/{target}/
- Tools install to $HOME/.local/share/speculator/programs/
- Previous VM test (2026-04-29): 56/56 OK, zero failures
- Mr.Holmes disabled in manifest (fully interactive TUI, cannot be automated)

## Constraints

- **OS**: Debian 13 Trixie amd64 only; no dependencies outside official repos, pipx, go, or flatpak
- **Shell**: Pure Bash 4+; no Python/Node runtime dependencies for launcher scripts
- **GUI**: Zenity required; headless environments not supported
- **Paths**: All paths use $HOME, never ~; all pushd calls require error handling
- **Isolation**: Git-cloned tools get their own venv in $PROGRAMS_DIR/{tool}/
- **Security**: No hardcoded credentials, no .env files committed

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| XDG-compliant PROGRAMS_DIR ($HOME/.local/share/speculator/programs) | Consistent with scripts/, icons/, config/ already in .local/share/speculator/ | ✓ Good |
| No IntelTechniques downloads | Removes external credential dependency; we control all content | ✓ Good |
| Manifest-driven tool execution (tools.conf) | Single source of truth; adding a tool = one line, not code changes | ✓ Good |
| Hub-and-spoke launcher architecture | user.sh handles person-tracking internally; specialised investigation types dispatch to spoke scripts | ✓ Good |
| Zenity for all GUI | Consistent UX across all launchers; available on Debian desktop | ✓ Good |
| SpiderFoot removed entirely | Persistent lxml conflict that could not be resolved | ✓ Good |
| Mr.Holmes disabled in manifest | Fully interactive TUI, no CLI flags, cannot be automated | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? Move to Out of Scope with reason
2. Requirements validated? Move to Validated with phase reference
3. New requirements emerged? Add to Active
4. Decisions to log? Add to Key Decisions
5. "What This Is" still accurate? Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check: still the right priority?
3. Audit Out of Scope: reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-06 after initialization*

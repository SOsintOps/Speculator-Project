# External Integrations

**Analysis Date:** 2026-05-06

## APIs & External Services

**Email Reconnaissance:**
- h8mail - Email breach database lookups
  - SDK/Client: `h8mail` (pipx)
  - Auth: `~/h8mail_config.ini` (user-provided API keys for leak-lookup services)

**Internet Archive:**
- Wayback Machine - Web snapshot retrieval
  - SDK/Client: `waybackpy`, `waybackpack` (pipx)
  - Auth: None (public API)
- Archive.org - Archive search
  - SDK/Client: `internetarchive` (pipx, command: `ia`)
  - Auth: None (public API)

**OSINT Data Aggregation:**
- Shodan - Network device search
  - SDK/Client: `shodan` (pipx)
  - Auth: `SHODAN_API_KEY` (environment variable)
- Censys - Certificate and IP search
  - SDK/Client: `censys` (pipx)
  - Auth: Censys API credentials (config)
- SecurityTrails - DNS/domain intelligence
  - SDK/Client: Browser-only (not automated in this stack)
  - Auth: API key (manual, in Firefox bookmarks)

**Domain/Subdomain Intelligence:**
- crt.sh - Certificate transparency search (HTTP API)
  - SDK/Client: `theHarvester`, `amass` (query certificate logs)
  - Auth: None (public API)
- VirusTotal - Domain/IP reputation
  - SDK/Client: Browser-only (reference bookmarks)
  - Auth: API key (manual)

**Social Media APIs:**
- Instagram (private API via scraping)
  - SDK/Client: `instaloader`, `toutatis`, `osintgram` (HTTP session-based)
  - Auth: Instagram session ID (optional, user-provided via Zenity dialog)
- Reddit (public API)
  - SDK/Client: `bdfr` (PRAW library)
  - Auth: None (public thread/user data)
- Twitter/X (deprecated API access)
  - SDK/Client: Browser-only (reference bookmarks)
  - Auth: None (public tweets in Firefox)

**Username Search Aggregation:**
- WhatsMyName - Multi-platform database
  - SDK/Client: `whatsmyname` (Git repo, local database)
  - Auth: None (offline, local database)
- Namechk - Username availability
  - SDK/Client: Browser-only (Firefox bookmarks)
  - Auth: None (public check)

**Hash/Credential Lookups:**
- HaveIBeenPwned - Breach database
  - SDK/Client: Browser-only (reference bookmarks)
  - Auth: None (public queries via Ctrl+F or API, not automated)

**Video Platform APIs:**
- YouTube (rate-limited public API)
  - SDK/Client: `yt-dlp` (HTTP scraping, not OAuth)
  - Auth: None (public video metadata)
- Generic streaming services
  - SDK/Client: `streamlink` (HTTP stream extraction)
  - Auth: None (public streams where available)

**Geolocation & Mapping:**
- Google Maps (via Google Earth Pro)
  - SDK/Client: Google Earth Pro (standalone app)
  - Auth: None (installed locally)
- Overpass Turbo (OpenStreetMap API)
  - SDK/Client: Browser-only (reference bookmarks)
  - Auth: None (public API)

## Data Storage

**Databases:**
- None. All tools are stateless CLI utilities.
- Query results stored as flat files (txt, csv, json, pdf, directories)
- Evidence organized by target: `~/Downloads/evidence/{target}/{tool}/`

**File Storage:**
- Local filesystem only
  - `~/.local/share/speculator/programs/` - Tool installations
  - `~/.config/speculator/` - Tool configurations
  - `~/Downloads/evidence/` - Evidence output
  - `~/h8mail_config.ini` - h8mail breach database config (user-provided)

**Caching:**
- Tool-specific caching (e.g., yt-dlp cache in `~/.cache/yt-dlp/`)
- No centralized caching layer
- `changedetection.io` maintains local SQLite DB for watched URLs (web UI at `http://127.0.0.1:5000`)

## Authentication & Identity

**Auth Provider:**
- None centralized. Each tool manages its own credentials independently.

**Authentication Approaches:**

| Tool | Auth Method | Storage |
|------|-------------|---------|
| h8mail | API keys in config file | `~/h8mail_config.ini` |
| Shodan | API key (env var or config) | Environment variable or config |
| Censys | Username/API key (config) | Tool config directory |
| Instagram tools | Session ID (optional) | Zenity dialog input or browser session |
| Reddit (BDFR) | Public API (no auth) | None |
| yt-dlp | None (public metadata) | None |
| Google Earth Pro | Local installation auth | Built-in, no key needed |

**Credential Storage:**
- No passwords stored in codebase
- User provides credentials via Zenity dialogs at runtime
- Config files (h8mail, censys) are user-created in home directory
- Environment variables loaded from user shell profile

## Monitoring & Observability

**Error Tracking:**
- None (no remote error reporting)

**Logging:**
- Installation: `~/Downloads/install_YYYY-MM-DD_HH-MM-SS.log`
- Per-session: Tool execution logged by individual scripts (via Zenity capture)
- Session logs stored per evidence target: `~/Downloads/evidence/{target}/session.log`

## CI/CD & Deployment

**Hosting:**
- None. This is a standalone installer for local VMs.
- Distribution: GitHub repository (single bash script + config files)

**CI Pipeline:**
- None. Deployment is manual via `sudo ./speculator_install.sh`

**Deployment Target:**
- Local VirtualBox VM running Debian 13 "Trixie"

## Environment Configuration

**Required Environment Variables:**

| Variable | Purpose | Default |
|----------|---------|---------|
| `SUDO_USER` | Non-root user (auto-detected by installer) | Current user |
| `HOME` | User home directory (auto-detected) | `getent passwd` |
| `GOPATH` | Go workspace (auto-detected from `go env GOPATH`) | `~/go` |
| `SHODAN_API_KEY` | Shodan API authentication | User-provided (optional) |
| `CENSYS_UID` / `CENSYS_SECRET` | Censys API auth | User-provided (optional) |

**Optional Configuration:**
- `XDG_SESSION_TYPE` - Wayland detection (auto-set to X11 fallback if wayland)
- `VERBOSE` - Debug mode (set by launcher scripts if requested)

**Secrets Location:**
- `~/.local/bin/` - No secrets (tool binaries only)
- `~/.config/speculator/` - User config (h8mail_config.ini if copied)
- Environment variables - Shell profile (user-managed)
- No `.env` file used (Debian/Bash convention — env vars via shell profile)

## Webhooks & Callbacks

**Incoming:**
- None. All tools are pull-only (query APIs, scrape URLs).

**Outgoing:**
- changedetection.io web UI - Listens on `http://127.0.0.1:5000` (no external webhooks)
- Maigret web UI - Listens on `http://127.0.0.1:5001` (local dashboard only)

## Browser Integration

**Firefox ESR Configuration:**
- Enterprise policies deployed via `config/policies.json` → `/usr/lib/firefox-esr/distribution/policies.json`
- Managed bookmarks (organized toolbox):
  - AML Toolbox
  - Nixintel OSINT resource list
  - Terrorism research dashboard
  - Person investigation tools (WhatsMyName, Namechk, HaveIBeenPwned, Epieos, IntelX)
  - Domain/Infrastructure tools (Shodan, Censys, crt.sh, VirusTotal, urlscan.io, etc.)
  - Image/Media search (Google Images, TinEye, Yandex)
  - Geolocation (SunCalc, Overpass Turbo)
  - Archives (Wayback Machine, CachedView, Archive.org)
  - Social Media (Facebook, X, Instagram, LinkedIn, Reddit, Telegram)
  - Local tools (Maigret Web at `http://127.0.0.1:5001`, Changedetection at `http://127.0.0.1:5000`)
  - Resources (OSINT Framework, Bellingcat Toolkit)

**Firefox Extensions (auto-installed via policies):**
- uBlock Origin - Ad/tracker blocking
- CanvasBlocker - Canvas fingerprinting protection
- ClearURLs - URL parameter cleaning
- Multi-Account Containers - Isolated browsing contexts
- EXIF Viewer - Image metadata inspection
- Wayback Machine - Internet Archive integration
- GPS Detect - Geolocation tracking detection
- Search by Image - Reverse image search
- Nimbus Screenshot - Screenshot capture
- Resurrect Pages - Dead link recovery
- Link Gopher - Link extraction
- Mitaka - OSINT pivot tool

**Firefox Privacy Hardening (via policies):**
- Telemetry disabled
- Pocket/Firefox Accounts disabled
- Form history disabled
- Password reveal protection
- WebRTC (peerconnection) disabled
- Geolocation disabled
- Battery API disabled
- DOM notifications disabled
- DNS prefetch disabled
- Safe browsing disabled (local phishing protection only)
- Fingerprinting resistance enabled
- Tracking protection (strict mode)
- Social tracking blocking enabled
- Cache/cookies/history/sessions sanitized on shutdown

## External Repositories

**Git Repositories (cloned on install):**
| Tool | URL | Environment |
|------|-----|-------------|
| blackbird | https://github.com/p1ngul1n0/blackbird | Python venv |
| WhatsMyName-Python | https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python | Python venv |
| Eyes | https://github.com/N0rz3/Eyes | Python venv |
| Osintgram | https://github.com/Datalux/Osintgram | Python venv |
| Photon | https://github.com/s0md3v/Photon | Python venv |
| Sublist3r | https://github.com/aboul3la/Sublist3r | Python venv |
| Carbon14 | https://github.com/Lazza/Carbon14 | Python venv |
| metagoofil | https://github.com/opsdisk/metagoofil | Python venv |
| recon-ng | https://github.com/lanmaster53/recon-ng | Python venv (REQUIREMENTS) |
| mailcat | https://github.com/sharsil/mailcat | Python venv |
| Profil3r | https://github.com/Greyjedix/Profil3r | Python venv |
| Aliens_eye | https://github.com/arxhr007/Aliens_eye | Python venv |
| theHarvester | https://github.com/laramies/theHarvester | uv project (`.venv`) |

**APT Repositories (signed):**
| Package | Repository | Signing Key |
|---------|-----------|-------------|
| brave-browser | https://brave-browser-apt-release.s3.brave.com | `/usr/share/keyrings/brave-browser-archive-keyring.gpg` |
| sn0int | https://apt.vulns.sexy | `/etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg` (kpcyrd.pgp) |

**Flatpak Repository:**
- Flathub - org.torproject.torbrowser-launcher

---

*Integration audit: 2026-05-06*

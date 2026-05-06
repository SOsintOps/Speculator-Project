# Technology Stack

**Analysis Date:** 2026-05-06

## Languages

**Primary:**
- Bash - v4+ (Shell scripting for all automation, installation, and tool launchers)
- Python - 3.x (Tools and frameworks, managed via venv/pipx/uv)

**Secondary:**
- JSON - Configuration (Firefox policies, tool manifest)

## Runtime

**Environment:**
- Debian 13 "Trixie" amd64 (target OS, required)
- Bash shell environment
- Python 3 virtual environments (venv)

**Package Managers:**
- apt - System package manager (Debian official repos)
- pipx - Python application isolation (`~/.local/bin`)
- go - Go package manager (binaries to `~/go/bin`)
- uv - Python project manager (used for theHarvester)
- flatpak - Application containerization (Tor Browser)

## Frameworks & Tools

**Build/Install:**
- Git - Source control, cloning tools from GitHub
- curl/wget - Download utilities
- gpg/sq - Cryptographic key management (repo verification)

**Runtime Environments:**
- Python venv - Virtual environment isolation for tools
- GNOME/X11 - Desktop environment (Wayland + X11 fallback)

**UI Framework:**
- Zenity - GTK dialog framework for GUI prompts and selection dialogs in launcher scripts (`scripts/user.sh`, `scripts/domain.sh`, etc.)

## Key Dependencies

**System Libraries (Debian packages):**
- build-essential - C/C++ compiler toolchain
- python3-dev - Python development headers
- libxml2-dev, libxslt1-dev, zlib1g-dev - XML/compression libraries (archivebox dependencies)
- ripgrep, wget, curl, chromium, nodejs, npm - Archivebox runtime dependencies
- gnupg - GPG tools for key verification
- exiftool - EXIF metadata extraction
- mediainfo - Media file analysis
- mat2 - Metadata removal tool
- chromium - Browser engine (archivebox)
- nodejs/npm - JavaScript runtime (archivebox)

**Python-based OSINT Tools (via pipx):**
- holehe - Email enumeration
- socialscan - Email/username scanning
- ghunt - Google Account OSINT
- h8mail - Email breach lookup
- sherlock-project - Username enumeration
- maigret - Username search (multi-platform)
- yt-dlp - Video downloading
- streamlink - Stream capture
- bdfr - Reddit backup
- waybackpy, waybackpack - Internet Archive tools
- gallery-dl - Image gallery downloader
- instaloader - Instagram scraper
- toutatis - Instagram OSINT
- xeuledoc - Metadata analyzer
- internetarchive - Archive.org client (ia)
- archivebox - Website archiving
- changedetection.io - Change monitoring web UI
- search-that-hash, name-that-hash - Hash lookup
- ignorant - Phone number lookup
- shodan - Network search API client
- fierce - DNS enumeration
- censys - Certificate search API client
- naminter - Username search
- social-analyzer - Multi-platform username search (999+ sites)

**Python Tools from Git (isolated venvs):**
- blackbird - Username enumeration (PDF output)
- WhatsMyName-Python - Multi-site username search
- Eyes - Email OSINT
- Osintgram - Instagram OSINT
- Photon - Web crawler/scraper
- Sublist3r - Subdomain enumeration
- Carbon14 - Image forensics dating
- metagoofil - Document metadata search
- recon-ng - Modular OSINT framework
- mailcat - Email OSINT
- Profil3r - Email profiling
- Aliens_eye - 841-site username search
- theHarvester - Email/subdomain harvester (uv project)

**Go-based Tools:**
- amass - Subdomain enumeration
- subfinder - Subdomain discovery
- httpx - HTTP probing
- nuclei - Template-based scanning
- enola - Username hunter
- stalkie - Username search
- investigo - Username search (via `investigo` go module)

**APT Repository Tools:**
- sn0int - Framework for OSINT automation
- brave-browser - Privacy-focused browser
- firefox-esr - ESR Firefox with enterprise policies
- google-earth-pro - Geolocation tool (downloaded .deb)

**Flatpak Applications:**
- org.torproject.torbrowser-launcher - Tor Browser isolation

## Configuration

**Environment:**
- XDG Base Directory standard (`~/.local/share`, `~/.config`, `~/.local/bin`)
- SUDO_USER detection for running as non-root
- GOPATH auto-detection (default `~/go`)
- PATH injection: `~/.local/bin:~/go/bin:$PATH`

**Build Configuration Files:**
- `config/tools.conf` - Pipe-delimited manifest of all 50+ OSINT tools (name, id, category, check type, command template, output extension, venv config)
- `config/policies.json` - Firefox ESR enterprise policies (privacy hardening, extensions, bookmarks)
- `scripts/lib/common.sh` - Shared library (logging, Zenity integration, tool manifest parsing)

**Installation Phases:**
1. System preparation (apt update, prerequisite checks, VirtualBox Guest Additions)
2. Core applications (Firefox ESR policies, Brave, Tor Browser Flatpak, Google Earth Pro)
3. OSINT tools (pipx packages, git-cloned Python tools, sn0int APT, theHarvester via uv, Go binaries)
4. Launcher scripts and desktop shortcuts (Zenity-based GUI launchers)

## Platform Requirements

**Development/Installation:**
- Debian 13 "Trixie" (amd64) — exact target OS
- Bookworm (12.x) — supported with warnings
- Other Debian versions — will error and exit
- Non-Debian systems — rejected at startup
- sudo access (required for system package installation)
- ~5-10 GB disk space (tools + virtual environments)
- Internet connectivity (GitHub clones, apt repos, pipx downloads)

**Production/Runtime:**
- Debian 13 "Trixie" amd64 VM (VirtualBox assumed)
- VirtualBox Guest Additions (prerequisite, manually installed before script)
- GNOME Desktop Environment or compatible X11 window manager
- Minimum 2GB RAM, 20GB disk (recommended 4GB+ RAM for tool concurrency)

## Deployment

**Installation Method:**
```bash
sudo ./speculator_install.sh              # Full installation
sudo ./speculator_install.sh --dry-run    # Simulation without changes
```

**Installation Output:**
- Install log: `~/Downloads/install_YYYY-MM-DD_HH-MM-SS.log`
- Programs directory: `~/.local/share/speculator/programs/`
- Scripts directory: `~/.local/share/speculator/scripts/`
- Desktop shortcuts: `~/.local/share/applications/`
- Config directory: `~/.config/speculator/`

**Tool Management:**
- Tools checked against manifest in `config/tools.conf`
- Tool availability verified via: binary check, git repo existence, pipx/go command check
- Tools invoked from launcher scripts in `scripts/` with Zenity UI
- Evidence output: `~/Downloads/evidence/{target}/{tool}/`

---

*Stack analysis: 2026-05-06*

# Speculator Project

![Version](https://img.shields.io/badge/version-0.10.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![OS](https://img.shields.io/badge/OS-Debian%2013%20Trixie-red)
![Shell](https://img.shields.io/badge/shell-bash-yellow)
[![CI](https://github.com/SOsintOps/Speculator-Project/actions/workflows/ci.yml/badge.svg)](https://github.com/SOsintOps/Speculator-Project/actions/workflows/ci.yml)

## Overview

<img align="left" width="142" height="248" src="media/speculator.png">

The Speculator Project turns a Debian 13 "Trixie" virtual machine into an Open Source Intelligence (OSINT) workstation. One Bash script installs the tools, configures the browsers and the GNOME desktop, and adds Zenity launchers that run the tools against a target and keep the results in one evidence folder per target.

It is the sister project of [Argos](https://github.com/SOsintOps/Argos): Argos targets Ubuntu, Speculator targets Debian.

### The Speculatores

We took our name from the Speculatores, the scouts and spies of the Roman legions. They operated in silence, collected what mattered and reported back. [Read more](documents/speculatores.md).

<br clear="left">

## Features

  - **Tool installation**: username, email, phone, domain, social media, video, archive, metadata and framework tools, each in its own environment.
  - **Launchers**: a main menu (**Speculator** in the application menu) and one launcher per investigation type. You type the target, tick the tools, and every result lands in `~/Downloads/evidence/<target>/`, with a session log of the commands and their output in `logs/`.
  - **In-browser OSINT dashboard**: installs [Exploratores](https://github.com/SOsintOps/Exploratores) in `~/Documents/Exploratores` and opens it as the Firefox ESR start page (local file, no web server).
  - **Browsers**: Firefox ESR with enterprise policies (privacy settings, OSINT extensions and bookmarks), Brave and Tor Browser.
  - **Report templates**: case cover sheet, full and executive reports, subject profile, event assessment, threat notice, OSINT policy, research log and case notebook, in `~/Documents/Speculator/templates`.
  - **Resilient installation**: the installer carries on when a single tool fails and lists every failure in a summary at the end.

## System Requirements

  - **Operating system**: **Debian 13 "Trixie" (amd64)** with the GNOME desktop.
  - **Virtualisation**: a dedicated virtual machine is recommended (VirtualBox is assumed). Install the VirtualBox Guest Additions yourself before running the script; the installer only checks for them.
  - **Disk space**: at least **50 GB**.
  - **RAM**: at least **4 GB**.
  - **Permissions**: a user with sudo rights.
  - **Internet connection**: needed to download the tools.

## Installation

```bash
sudo apt install -y git
git clone https://github.com/SOsintOps/Speculator-Project.git
cd Speculator-Project
sudo ./speculator_install.sh
```

The installer logs everything to `~/Downloads/install_<date>.log` and writes a results file next to it. Reboot when it finishes. To see what it would do without changing anything, run `sudo ./speculator_install.sh --dry-run`.

> **Status:** the installer was last run end to end on Debian 13.5 (see the [changelog](documents/CHANGELOG.md)). The GNOME desktop settings are only applied in a real desktop session; please report problems in the issues.

## Usage

Open **Speculator** from the application menu and choose an investigation:

| Investigation | Input | Tools |
|---|---|---|
| Person | email, username, full name, phone number, hash or share link (detected automatically) | see *Person* below |
| Domain | domain name | Amass, Subfinder, HTTPX, Nuclei, Sublist3r, theHarvester, Photon, Metagoofil, TLDSweep, Fierce |
| Instagram | username | Instaloader, Toutatis, Osintgram |
| Reddit | username | BDFR (submissions and comments) |
| Video | URL | yt-dlp, Streamlink, Gallery-dl |
| Archives | URL or domain | WaybackPy, Waybackpack, Internet Archive CLI, ArchiveBox |
| Image and metadata | file or folder | ExifTool, MAT2, Xeuledoc, Carbon14, MediaInfo |
| Frameworks | none: they open in the terminal | Recon-ng, Sn0int, Changedetection.io, Maigret Web, Mr.Holmes |
| Update tools | none | updates the pipx, Go and Git tools |

Each investigation also has its own entry in the application menu. Launch a script with `-v` (for example `~/.local/share/speculator/scripts/user.sh -v`) to see the live output of every tool in the terminal.

Frameworks are interactive, so they run in a terminal window: Recon-ng and Sn0int open their consoles, Changedetection.io serves its web interface on `http://127.0.0.1:5000`, Maigret Web on `http://127.0.0.1:5001`, and Mr.Holmes shows its own menus.

See the [FAQ](documents/FAQ.md) for common questions.

## Tools Included

### Person (email, username, full name, phone, hash, share link)

[Aliens Eye](https://github.com/arxhr007/Aliens_eye) -
[BDFR](https://github.com/aliparlakci/bulk-downloader-for-reddit) -
[Blackbird](https://github.com/p1ngul1n0/blackbird) -
[Enola](https://github.com/TheYahya/enola) -
[Eyes](https://github.com/N0rz3/Eyes) -
[GHunt](https://github.com/mxrch/GHunt) -
[h8mail](https://github.com/khast3x/h8mail) -
[Holehe](https://github.com/megadose/holehe) -
[Ignorant](https://github.com/megadose/ignorant) -
[Investigo](https://github.com/tdh8316/Investigo) (command line only) -
[Maigret](https://github.com/SOsintOps/maigret) (SOsintOps fork) -
[Mailcat](https://github.com/sharsil/mailcat) -
[Name-That-Hash](https://github.com/HashPals/Name-That-Hash) -
[Naminter](https://github.com/sifrfrederik/naminter) -
[PhoneInfoga](https://github.com/sundowndev/phoneinfoga) -
[Profil3r](https://github.com/Greyjedix/Profil3r) -
[Search-That-Hash](https://github.com/HashPals/Search-That-Hash) -
[ShareTrace](https://github.com/hondling/sharetrace) -
[Sherlock](https://github.com/sherlock-project/sherlock) -
[Social-Analyzer](https://github.com/qeeqbox/social-analyzer) -
[SocialScan](https://github.com/iojw/socialscan) -
[Stalkie](https://github.com/ashendilantha/stalkie) -
[Turbolehe](https://github.com/purrsec/Turbolehe) -
[WhatsMyName](https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python)

### Social media

[Instaloader](https://github.com/instaloader/instaloader) -
[Osintgram](https://github.com/Datalux/Osintgram) -
[Toutatis](https://github.com/megadose/toutatis)

### Domain and web

[Amass](https://github.com/owasp-amass/amass) -
[Censys CLI](https://github.com/censys/censys-python) (command line only) -
[Fierce](https://github.com/mschwager/fierce) -
[HTTPX](https://github.com/projectdiscovery/httpx) -
[HTTrack](https://www.httrack.com/) (command line and WebHTTrack) -
[Metagoofil](https://github.com/opsdisk/metagoofil) -
[Nuclei](https://github.com/projectdiscovery/nuclei) -
[Photon](https://github.com/s0md3v/Photon) -
[Shodan CLI](https://github.com/achillean/shodan-python) (command line only) -
[Subfinder](https://github.com/projectdiscovery/subfinder) -
[Sublist3r](https://github.com/aboul3la/Sublist3r) -
[theHarvester](https://github.com/laramies/theHarvester) -
[TLDSweep](https://github.com/DarkWebInformer/TLDSweep) -
[WireTapper](https://github.com/h9zdev/WireTapper) (command line only, needs API keys)

### Metadata and images

[Carbon14](https://github.com/Lazza/Carbon14) -
[ExifTool](https://exiftool.org/) -
[MAT2](https://0xacab.org/jvoisin/mat2) -
[MediaInfo](https://mediaarea.net/en/MediaInfo) -
[Xeuledoc](https://github.com/Malfrats/xeuledoc)

### Frameworks

[Changedetection.io](https://github.com/dgtlmoon/changedetection.io) -
[Maigret Web](scripts/maigret-enhanced) (web interface for Maigret, included in this repository) -
[Mr.Holmes](https://github.com/Lucksi/Mr.Holmes) -
[Recon-ng](https://github.com/lanmaster53/recon-ng) -
[Sn0int](https://github.com/kpcyrd/sn0int)

### Video and media

[Gallery-dl](https://github.com/mikf/gallery-dl) -
[Streamlink](https://github.com/streamlink/streamlink) -
[yt-dlp](https://github.com/yt-dlp/yt-dlp)

### Archives

[ArchiveBox](https://github.com/ArchiveBox/ArchiveBox) -
[Internet Archive CLI](https://github.com/jjjake/internetarchive) -
[WaybackPy](https://github.com/akamhy/waybackpy) -
[Waybackpack](https://github.com/jsvine/waybackpack)

### Browsers

Firefox ESR (configured for OSINT, start page [Exploratores](https://github.com/SOsintOps/Exploratores)) -
[Brave](https://brave.com/) -
[Tor Browser](https://www.torproject.org/) (installed with the Flathub `torbrowser-launcher`)

### Other utilities

BleachBit - FFmpeg - Google Earth Pro - Kazam - VLC

## Documentation

  - [FAQ](documents/FAQ.md): common questions and answers
  - [Changelog](documents/CHANGELOG.md): version history
  - [The Speculatores](documents/speculatores.md): historical background
  - [Contributing](CONTRIBUTING.md): how to report bugs, suggest features and run the tests
  - [Security](SECURITY.md): how to report a vulnerability

## Development and tests

```bash
bash tests/run_all.sh
```

The suite runs without a display or any OSINT tool: it checks the syntax of every script, runs ShellCheck (errors only) and then the tests in `tests/`, with Zenity replaced by a stub. The same command runs in CI on every push.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting bugs, suggesting features and submitting pull requests.

## License

This project is licensed under the [MIT License](LICENSE). The licences of the media files and the few third-party files are listed in [media/CREDITS.md](media/CREDITS.md). The tools that the installer downloads keep their own licences.

## Disclaimer

The Speculator Project draws on techniques described in *OSINT Techniques, 11th Edition* by Michael Bazzell. This project is not affiliated with, endorsed by, or connected to Michael Bazzell or IntelTechniques in any way.

This script is provided "as-is" without any warranties. It is intended solely for educational and testing purposes. Please use it responsibly and at your own risk.

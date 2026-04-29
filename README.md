# Speculator Project

![Version](https://img.shields.io/badge/version-0.8.8-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![OS](https://img.shields.io/badge/OS-Debian%2013%20Trixie-red)
![Shell](https://img.shields.io/badge/shell-bash-yellow)

## Overview

The Speculator Project is the successor to [Argos](https://github.com/SOsintOps/Argos), building on the techniques and lessons learned during its development. It provides a Bash script designed to customise Debian-based virtual machines for Open Source Intelligence (OSINT) activities. Its goal is to create a secure and standardised environment for intelligence gathering.

### The Speculatores

The term "Speculatores" refers to Roman scouts and intelligence officers who played a crucial role in gathering important information during military operations. For more information on the historical background of the Speculatores, visit [this page](https://github.com/SOsintOps/Speculator-Project/blob/main/documents/speculatores.md).

## Features

  - **Comprehensive Tool Installation**: Offers a variety of tools for analysing usernames, social media, metadata, domains and more.
  - **Browser Setup**: Configures Firefox, Brave and Tor browsers to support secure research.
  - **Desktop Customisation**: Configures the GNOME desktop environment for OSINT workflows.
  - **Resilient Installation**: The script is designed to continue even if a single tool fails to install, ensuring the most complete setup possible.

## System Requirements

  - **Operating System**: **Debian 13 "Trixie" (amd64)**.
  - **Virtualisation**: **VirtualBox** (recommended). The script installs VirtualBox Guest Additions automatically.
  - **Disk Space**: Minimum **50 GB** recommended.
  - **RAM**: Minimum **4 GB** recommended.
  - **Permissions**: Sudo privileges are required.
  - **Internet Connection**: Needed to download and configure tools.

## Installation

Quick install (single command):

```bash
git clone https://github.com/SOsintOps/speculator-project.git && cd speculator-project && sudo ./speculator_install.sh
```

Or step by step:

1.  Clone the repository:
    ```bash
    git clone https://github.com/SOsintOps/speculator-project.git
    cd speculator-project
    ```
2.  Run the script with superuser privileges:
    ```bash
    sudo ./speculator_install.sh
    ```

## Usage

After installation and a system reboot, the tools and environment are ready for use. The script configures browsers, installs essential OSINT tools and prepares the system for secure investigations. Refer to the tool documentation for specific usage instructions, or consult the [FAQ page](https://github.com/SOsintOps/Speculator-Project/blob/main/documents/FAQ.md) for common queries.

## Tools Included

### Person Investigation (email, username, phone, fullname)

[Aliens Eye](https://github.com/arxhr007/Aliens_eye) -
[BDFR](https://github.com/aliparlakci/bulk-downloader-for-reddit) -
[Blackbird](https://github.com/p1ngul1n0/blackbird) -
[Enola](https://github.com/TheYahya/enola) -
[Eyes](https://github.com/N0rz3/Eyes) -
[GHunt](https://github.com/mxrch/GHunt) -
[h8mail](https://github.com/khast3x/h8mail) -
[Holehe](https://github.com/megadose/holehe) -
[Ignorant](https://github.com/megadose/ignorant) -
[Maigret](https://github.com/soxoj/maigret) -
[Mailcat](https://github.com/sharsil/mailcat) -
[Mr.Holmes](https://github.com/Lucksi/Mr.Holmes) -
[Naminter](https://github.com/sifrfrederik/naminter) -
[Osintgram](https://github.com/Datalux/Osintgram) -
[PhoneInfoga](https://github.com/sundowndev/phoneinfoga) -
[Profil3r](https://github.com/Greyjedix/Profil3r) -
[Sherlock](https://github.com/sherlock-project/sherlock) -
[Social-Analyzer](https://github.com/qeeqbox/social-analyzer) -
[SocialScan](https://github.com/iojw/socialscan) -
[Stalkie](https://github.com/n0thhhing/stalkie) -
[Turbolehe](https://github.com/purrsec/Turbolehe) -
[WhatsMyName](https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python)

### Domain and Web Tools

[Amass](https://github.com/owasp-amass/amass) -
[Fierce](https://github.com/mschwager/fierce) -
[HTTPX](https://github.com/projectdiscovery/httpx) -
[Metagoofil](https://github.com/opsdisk/metagoofil) -
[Nuclei](https://github.com/projectdiscovery/nuclei) -
[Photon](https://github.com/s0md3v/Photon) -
[Subfinder](https://github.com/projectdiscovery/subfinder) -
[Sublist3r](https://github.com/aboul3la/Sublist3r) -
[theHarvester](https://github.com/laramies/theHarvester) -
[TLDSweep](https://github.com/TLDSweep/TLDSweep)

### Metadata and Image Tools

[Carbon14](https://github.com/Lazza/Carbon14) -
[ExifTool](https://exiftool.org/) -
[MAT2](https://0xacab.org/jvoisin/mat2) -
MediaInfo -
[Xeuledoc](https://github.com/AnalystTool/xeuledoc)

### Frameworks

[Changedetection.io](https://github.com/dgtlmoon/changedetection.io) -
[Maigret Web](https://github.com/soxoj/maigret) -
[Recon-ng](https://github.com/lanmaster53/recon-ng) -
[Sn0int](https://github.com/kpcyrd/sn0int)

### Video and Media

[Gallery-dl](https://github.com/mikf/gallery-dl) -
[Streamlink](https://github.com/streamlink/streamlink) -
[yt-dlp](https://github.com/yt-dlp/yt-dlp)

### Archives

[ArchiveBox](https://github.com/ArchiveBox/ArchiveBox) -
[Internet Archive CLI](https://github.com/jjjake/internetarchive) -
[WaybackPy](https://github.com/akamhy/waybackpy) -
[Waybackpack](https://github.com/jsvine/waybackpack)

### Browsers

Brave - Firefox (configured for OSINT) - Tor

### Additional Utilities

BleachBit - FFmpeg - Google Earth Pro - Kazam - VLC Media Player -
[WireTapper](https://github.com/waffl3ss/WireTapper)

## Documentation

  - [FAQ](documents/FAQ.md): common questions and answers
  - [Changelog](documents/CHANGELOG.md): version history
  - [The Speculatores](documents/speculatores.md): historical background

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting bugs, suggesting features and submitting pull requests.

## License

This project is licensed under the [MIT License](LICENSE).

## Disclaimer

The Speculator Project draws on techniques described in *OSINT Techniques, 11th Edition* by Michael Bazzell. This project is not affiliated with, endorsed by, or connected to Michael Bazzell or IntelTechniques in any way.

This script is provided "as-is" without any warranties. It is intended solely for educational and testing purposes. Please use it responsibly and at your own risk.

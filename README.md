# Speculator Project

![Version](https://img.shields.io/badge/version-0.8.8-blue)
![License](https://img.shields.io/badge/license-Unlicense-green)
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

  - [Blackbird](https://github.com/p1ngul1n0/blackbird)
  - [BDFR (Bulk Downloader for Reddit)](https://github.com/aliparlakci/bulk-downloader-for-reddit)
  - [Eyes](https://github.com/N0rz3/Eyes)
  - [GHunt](https://github.com/mxrch/GHunt)
  - [Holehe](https://github.com/megadose/holehe)
  - [Maigret](https://github.com/soxoj/maigret)
  - [Sherlock](https://github.com/sherlock-project/sherlock)
  - [SocialScan](https://github.com/iojw/socialscan)
  - [WhatsMyName](https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python)
  - [h8mail](https://github.com/khast3x/h8mail)
  - [Osintgram](https://github.com/Datalux/Osintgram)
  - [Mr.Holmes](https://github.com/Lucksi/Mr.Holmes)
  - [Mailcat](https://github.com/sharsil/mailcat)
  - [Profil3r](https://github.com/Greyjedix/Profil3r)
  - [Turbolehe](https://github.com/purrsec/Turbolehe)
  - [Naminter](https://github.com/sifrfrederik/naminter)
  - [Social-Analyzer](https://github.com/qeeqbox/social-analyzer)
  - [Aliens Eye](https://github.com/arxhr007/Aliens_eye)
  - [Enola](https://github.com/TheYahya/enola)
  - [Stalkie](https://github.com/n0thhhing/stalkie)
  - [Ignorant](https://github.com/megadose/ignorant)
  - [PhoneInfoga](https://github.com/sundowndev/phoneinfoga)

### Domain and Web Tools

  - [Amass](https://github.com/owasp-amass/amass)
  - [Photon](https://github.com/s0md3v/Photon)
  - [Sublist3r](https://github.com/aboul3la/Sublist3r)
  - [theHarvester](https://github.com/laramies/theHarvester)
  - [Subfinder](https://github.com/projectdiscovery/subfinder)
  - [HTTPX](https://github.com/projectdiscovery/httpx)
  - [Nuclei](https://github.com/projectdiscovery/nuclei)
  - [Fierce](https://github.com/mschwager/fierce)
  - [TLDSweep](https://github.com/TLDSweep/TLDSweep)
  - [Metagoofil](https://github.com/opsdisk/metagoofil)

### Metadata and Image Tools

  - [Carbon14](https://github.com/Lazza/Carbon14)
  - [ExifTool](https://exiftool.org/)
  - [MAT2](https://0xacab.org/jvoisin/mat2)
  - [Xeuledoc](https://github.com/AnalystTool/xeuledoc)
  - MediaInfo

### Frameworks

  - [Recon-ng](https://github.com/lanmaster53/recon-ng)
  - [Sn0int](https://github.com/kpcyrd/sn0int)
  - [Maigret Web](https://github.com/soxoj/maigret) (web UI on port 5001)
  - [Changedetection.io](https://github.com/dgtlmoon/changedetection.io)

### Video and Media

  - [yt-dlp](https://github.com/yt-dlp/yt-dlp)
  - [Streamlink](https://github.com/streamlink/streamlink)
  - [Gallery-dl](https://github.com/mikf/gallery-dl)

### Archives

  - [ArchiveBox](https://github.com/ArchiveBox/ArchiveBox)
  - [WaybackPy](https://github.com/akamhy/waybackpy)
  - [Waybackpack](https://github.com/jsvine/waybackpack)
  - [Internet Archive CLI](https://github.com/jjjake/internetarchive)

### Browsers

  - Firefox (configured for OSINT)
  - Brave
  - Tor

### Additional Utilities

  - BleachBit
  - FFmpeg
  - Google Earth Pro
  - Kazam
  - VLC Media Player
  - [WireTapper](https://github.com/waffl3ss/WireTapper)

## Documentation

  - [FAQ](documents/FAQ.md): common questions and answers
  - [Changelog](documents/CHANGELOG.md): version history
  - [The Speculatores](documents/speculatores.md): historical background

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting bugs, suggesting features and submitting pull requests.

## License

This project is released into the public domain under the [Unlicense](LICENSE).

## Disclaimer

The Speculator Project is inspired by the techniques outlined in the book *OSINT Techniques, 11th Edition* by Michael Bazzell.

This script is provided "as-is" without any warranties. It is intended solely for educational and testing purposes. Please use it responsibly and at your own risk.

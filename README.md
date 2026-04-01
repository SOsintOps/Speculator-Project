# Speculator Project

## Overview

The Speculator Project is inspired by the techniques outlined in the book [OSINT Techniques, 11th Edition](https://inteltechniques.com/book1.html) by Michael Bazzell. It demonstrates how to adapt these methods and tools to meet individual needs.

This project provides a Bash script designed to customise Debian-based virtual machines specifically for Open Source Intelligence (OSINT) activities. Its goal is to create a secure and standardised environment for intelligence gathering.

### The Speculatores

The term "Speculatores" refers to Roman scouts and intelligence officers who played a crucial role in gathering important information during military operations. For more information on the historical background of the Speculatores, visit [this page](https://github.com/SOsintOps/Speculator-Project/blob/main/document/speculatores.md).

## Features

  - **Comprehensive Tool Installation**: Offers a variety of tools for analyzing usernames, social media, metadata, domains, and more.
  - **Browser Setup**: Configures Firefox, Brave, and Tor browsers to enhance secure research.
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

1.  Clone the repository:
    ```bash
    git clone https://github.com/SOsintOps/speculator-project.git
    cd speculator-project
    ```
2.  Make the script executable:
    ```bash
    chmod +x speculator_install.sh
    ```
3.  Run the script with superuser privileges:
    ```bash
    sudo ./speculator_install.sh
    ```

## Usage

After installation and a system reboot, the tools and environment are ready for use. The script configures browsers, installs essential OSINT tools, and prepares the system for secure investigations. Refer to the tool documentation for specific usage instructions, or consult the [FAQ page](https://github.com/SOsintOps/Speculator-Project/blob/main/document/FAQ.md) for common queries.

## Tools Included

### Social Media and Username Tools

  - [Blackbird](https://github.com/p1ngul1n0/blackbird)
  - **[BDFR (Bulk Downloader for Reddit)](https://github.com/aliparlakci/bulk-downloader-for-reddit)**
  - [Eyes](https://github.com/N0rz3/Eyes)
  - [GHunt](https://github.com/mxrch/GHunt)
  - [Holehe](https://github.com/megadose/holehe)
  - [Maigret](https://github.com/soxoj/maigret)
  - [Sherlock](https://github.com/sherlock-project/sherlock)
  - [SocialScan](https://github.com/iojw/socialscan)
  - [WhatsMyName](https://github.com/WebBreacher/WhatsMyName)
  - [h8mail](https://github.com/khast3x/h8mail)
  - [Osintgram](https://github.com/Datalux/Osintgram)

### Domain and Web Tools

  - [Amass](https://github.com/OWASP/Amass)
  - [HTTrack](https://www.httrack.com/) & **WebHTTrack**
  - [Photon](https://github.com/s0md3v/Photon)
  - [Sublist3r](https://github.com/aboul3la/Sublist3r)
  - [theHarvester](https://github.com/laramies/theHarvester)

### Metadata Tools

  - [Carbon14](https://github.com/Lazza/Carbon14)
  - [ExifTool](https://exiftool.org/)
  - [MAT2](https://0xacab.org/jvoisin/mat2)
  - [Metagoofil](https://github.com/opsdisk/metagoofil)
  
### Frameworks

  - [Mr.Holmes](https://github.com/Lucksi/Mr.Holmes)
  - [Recon-ng](https://github.com/lanmaster53/recon-ng)
  - [Sn0int](https://github.com/kpcyrd/sn0int)
  - [Spiderfoot](https://github.com/smicallef/spiderfoot)

### Browsers

  - Firefox (customised for OSINT)
  - Brave
  - Tor

### Additional Tools & Utilities

  - [ArchiveBox](https://github.com/ArchiveBox/ArchiveBox)
  - [BleachBit](https://www.bleachbit.org/)
  - [Changedetection.io](https://github.com/dgtlmoon/changedetection.io)
  - **FFmpeg**
  - [Gallery-dl](https://github.com/mikf/gallery-dl)
  - **Google Earth Pro**
  - [Instaloader](https://github.com/instaloader/instaloader)
  - [Internet Archive Command-Line Interface](https://github.com/jjjake/internetarchive)
  - **Kazam**
  - **MediaInfo GUI**
  - [Name-That-Hash](https://github.com/HashPals/Name-That-Hash)
  - [Search-That-Hash](https://github.com/HashPals/Search-That-Hash)
  - **Streamlink**
  - [Toutatis](https://github.com/megadose/toutatis)
  - **VLC Media Player**
  - [WaybackPy](https://github.com/akamhy/waybackpy)
  - [Waybackpack](https://github.com/jsvine/waybackpack)
  - [xeuledoc](https://github.com/AnalystTool/xeuledoc)
  - **yt-dlp**

## Contribution

Open an issue or submit a pull request. All contributions are welcome.

## License

This project is currently being reviewed for proper licensing. Use it at your own risk.

## Disclaimer

This script is provided "as-is" without any warranties. It is intended solely for educational and testing purposes. Please use it responsibly and at your own risk.

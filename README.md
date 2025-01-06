# Speculator Project

## Overview

The Speculator Project is inspired by the techniques outlined in the book [OSINT Techniques, 11th Edition](https://inteltechniques.com/book1.html) by Michael Bazzell. It demonstrates how to adapt these methods and tools to meet individual needs. For detailed information, please refer to *OSINT Techniques*. 

This project provides a Bash script designed to customize Debian-based virtual machines specifically for Open Source Intelligence (OSINT) activities. Its goal is to create a secure and standardized environment for intelligence gathering.

### The Speculatores

The term "Speculatores" refers to Roman scouts and intelligence officers who played a crucial role in gathering important information during military operations. For more information on the historical background of the Speculatores, visit [this page](https://github.com/SOsintOps/Speculator-Project/blob/main/document/speculatores.md).

## Features

- **Comprehensive Tool Installation**: Offers a variety of tools for analyzing usernames, social media, metadata, domains, and more.
- **Browser Setup**: Configures Firefox, Brave, and Tor browsers to enhance secure research.
- **Desktop Customization**: Optimizes the GNOME desktop environment specifically for Open Source Intelligence (OSINT) workflows.
- **Modular Configuration**: Tools are organized into sections for easier comprehension and customization.

## System Requirements

- **Operating System**: Debian 12 (stable).
- **Permissions**: Sudo privileges are required.
- **Internet Connection**: Needed to download and configure tools.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/speculator-project.git
   cd speculator-project
   ```
2. Make the script executable:
   ```bash
   chmod +x speculator_install.sh
   ```
3. Run the script:
   ```bash
   ./speculator_install.sh
   ```

## Usage

After installation, the tools and environment are immediately ready for use. The script configures browsers, installs essential OSINT tools, and prepares the system for secure investigations.

## Getting Started

Once the setup is complete, begin your OSINT investigations by exploring the pre-installed tools. Each tool is configured to run optimally in the provided environment. Refer to the tool documentation for specific usage instructions, or consult the [FAQ page](https://github.com/SOsintOps/Speculator-Project/blob/main/document/FAQ.md) for common queries and troubleshooting tips.

## Tools Included

### Social Media and Username Tools

- [Blackbird](https://github.com/p1ngul1n0/blackbird)
- [Eyes](https://github.com/N0rz3/Eyes)
- [GHunt](https://github.com/mxrch/GHunt)
- [Holehe](https://github.com/megadose/holehe)
- [Maigret](https://github.com/soxoj/maigret)
- [Sherlock](https://github.com/sherlock-project/sherlock)
- [SocialScan](https://github.com/iojw/socialscan)
- [WhatsMyName](https://github.com/WebBreacher/WhatsMyName)
- [h8mail](https://github.com/khast3x/h8mail)

### Domain and Web Tools

- [Amass](https://github.com/OWASP/Amass)
- [EyeWitness](https://github.com/FortyNorthSecurity/EyeWitness)
- [HTTrack](https://www.httrack.com/)
- [Photon](https://github.com/s0md3v/Photon)
- [Sublist3r](https://github.com/aboul3la/Sublist3r)
- [theHarvester](https://github.com/laramies/theHarvester)

### Metadata Tools

- [Carbon14](https://github.com/Lazza/Carbon14)
- [ExifTool](https://exiftool.org/)
- [MAT2](https://0xacab.org/jvoisin/mat2)
- [Metagoofil](https://github.com/opsdisk/metagoofil)
- [Sherloq](https://github.com/GuidoBartoli/sherloq)

### Frameworks

- [Recon-ng](https://github.com/lanmaster53/recon-ng)
- [Sn0int](https://github.com/kpcyrd/sn0int)
- [Spiderfoot](https://github.com/smicallef/spiderfoot)

### Additional Tools

- [ArchiveBox](https://github.com/ArchiveBox/ArchiveBox)
- [Changedetection.io](https://github.com/dgtlmoon/changedetection.io)
- [Gallery-dl](https://github.com/mikf/gallery-dl)
- [Instaloader](https://github.com/instaloader/instaloader)
- [Internet Archive Command-Line Interface](https://github.com/jjjake/internetarchive)
- [Name-That-Hash](https://github.com/HashPals/Name-That-Hash)
- [Osintgram](https://github.com/Datalux/Osintgram)
- [Ripme](https://github.com/RipMeApp/ripme)
- [Search-That-Hash](https://github.com/HashPals/Search-That-Hash)
- [Toutatis](https://github.com/megadose/toutatis)
- [WaybackPy](https://github.com/akamhy/waybackpy)
- [Waybackpack](https://github.com/jsvine/waybackpack)
- [xeuledoc](https://github.com/AnalystTool/xeuledoc)

### Browsers

- Firefox (preconfigured for OSINT)
- Brave
- Tor

## Contribution

For frequently asked questions, visit our [FAQ page](https://github.com/SOsintOps/Speculator-Project/blob/main/document/FAQ.md).

We’d love to hear from you! Your ideas and contributions can make a real difference. Don’t hesitate to open issues or submit pull requests to help us enhance the project together!

## License

This project is currently being reviewed for proper licensing. Use it at your own risk.

## Disclaimer

This script is provided "as-is" without any warranties. It is intended solely for development and testing purposes. Please use it responsibly and at your own risk.


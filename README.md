# Speculator Project

## Overview
The **Speculator Project** is inspired by the methods described in the book *OSINT Techniques, 11th Edition* by Michael Bazzell. It does not aim to replace the virtual machine developed by the author but rather demonstrates how to adapt the techniques and tools described in the book to suit individual needs. For detailed information about the tools and methodologies, please refer to *OSINT Techniques*.
The **Speculator Project** provides a Bash script to customize Debian-based virtual machines, specifically designed for Open Source Intelligence (OSINT) activities. This project aims to create a secure, standardized environment for intelligence gathering by automating the installation and configuration of OSINT tools.

## Features
- **Comprehensive Tool Installation**: Includes a variety of tools for usernames, social media, metadata, domain analysis, and more.
- **Browser Setup**: Configures Firefox, Brave, and Tor browsers for secure research.
- **Desktop Customization**: Optimizes the GNOME desktop environment for OSINT workflows.
- **Modular Configuration**: Tools are grouped into sections for easy understanding and modular customization.

## System Requirements
- **Operating System**: Debian 12 (stable).
- **Permissions**: Sudo privileges are required.
- **Internet Connection**: Needed for downloading and configuring tools.

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
Once installed, the tools and environment are ready for immediate use. The script configures browsers, installs essential OSINT tools, and prepares the system for secure investigations.

## Tools Included
### Social Media and Username Tools
- [Sherlock](https://github.com/sherlock-project/sherlock)
- [Blackbird](https://github.com/p1ngul1n0/blackbird)
- [Maigret](https://github.com/soxoj/maigret)
- [WhatsMyName](https://github.com/WebBreacher/WhatsMyName)
- [SocialScan](https://github.com/iojw/socialscan)
- [Eyes](https://github.com/N0rz3/Eyes)
- [GHunt](https://github.com/mxrch/GHunt)
- [h8mail](https://github.com/khast3x/h8mail)
- [Holehe](https://github.com/megadose/holehe)

### Domain and Web Tools
- [EyeWitness](https://github.com/FortyNorthSecurity/EyeWitness)
- [HTTrack](https://www.httrack.com/)
- [Amass](https://github.com/OWASP/Amass)
- [Photon](https://github.com/s0md3v/Photon)
- [Sublist3r](https://github.com/aboul3la/Sublist3r)
- [theHarvester](https://github.com/laramies/theHarvester)

### Metadata Tools
- [ExifTool](https://exiftool.org/)
- [Carbon14](https://github.com/Lazza/Carbon14)
- [Metagoofil](https://github.com/opsdisk/metagoofil)
- [MAT2](https://0xacab.org/jvoisin/mat2)
- [Sherloq](https://github.com/GuidoBartoli/sherloq)

### Frameworks
- [Spiderfoot](https://github.com/smicallef/spiderfoot)
- [Recon-ng](https://github.com/lanmaster53/recon-ng)
- [Sn0int](https://github.com/kpcyrd/sn0int)



### Additional Tools
- [WaybackPy](https://github.com/akamhy/waybackpy)
- [Waybackpack](https://github.com/jsvine/waybackpack)
- [Changedetection.io](https://github.com/dgtlmoon/changedetection.io)
- [ArchiveBox](https://github.com/ArchiveBox/ArchiveBox)
- [Gallery-dl](https://github.com/mikf/gallery-dl)
- [Ripme](https://github.com/RipMeApp/ripme)
- [Instaloader](https://github.com/instaloader/instaloader)
- [Toutatis](https://github.com/megadose/toutatis)
- [Osintgram](https://github.com/Datalux/Osintgram)
- [Internet Archive Command-Line Interface](https://github.com/jjjake/internetarchive)
- [Search-That-Hash](https://github.com/HashPals/Search-That-Hash)
- [Name-That-Hash](https://github.com/HashPals/Name-That-Hash)
- [xeuledoc](https://github.com/AnalystTool/xeuledoc)



### Browsers
- Firefox (customised for OSINT)
- Brave
- Tor

## Contribution
Contributions are welcome! Feel free to open issues or submit pull requests to enhance the project.

## License
Use it at your own risk.

## Disclaimer
This script is provided "as-is" without any warranties. It is a development version intended for testing purposes only. Use it responsibly and at your own risk.


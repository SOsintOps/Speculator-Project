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
- Sherlock
- Blackbird
- Maigret
- WhatsMyName

### Domain and Web Tools
- EyeWitness
- HTTrack
- Amass
- Photon

### Metadata Tools
- ExifTool
- Carbon14
- Metagoofil
- MAT2

### Frameworks
- Spiderfoot
- Recon-ng
- Sn0int

### Browsers
- Firefox (preconfigured for OSINT)
- Brave
- Tor

## Contribution
Contributions are welcome! Feel free to open issues or submit pull requests to enhance the project.

## License
This project is under investigation for appropriate licensing. Use it at your own risk.

## Disclaimer
This script is provided "as-is" without any warranties. It is a development version intended for testing purposes only. Use it responsibly and at your own risk.


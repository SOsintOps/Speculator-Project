#!/bin/bash

# Speculator Install Script
# Version: 0.0.25
# Last Update: 20250106
#
# Version History:
# 0.0.25 (20250106) - Converted Python tools to Docker containers, simplified logging
# 0.0.24 (20250106) - Added complete installation logging on Desktop
# 0.0.23 (20250106) - Added installation logging
# 0.0.22 (20250106) - fixing maigret
# 0.0.21 (20250105) - fixing rm amass
# 0.0.2 (20250104) - Reorganized script in sections
# 0.0.1 (20250103) - Initial version based on OSINT VM install script
#
# Description:
# **** Speculator Project ****
# This project, based on the Michael Bazzell's book, provides a script for customizing Debian virtual machines,
# specifically designed for OSINT (Open Source Intelligence) activities.
# The script installs and configures a comprehensive suite of OSINT tools 
# for information gathering and analysis.
#
# Author: Speculator Project Team
#
#
# License: Under Investigation
# This is a development version - use at your own risk
#
# Dependencies:
# - Debian 12 (stable)
# - Internet connection
# - Sudo privileges
#
# Usage: 
# script -t 2>timingYYMMDD.log typescriptYYMMDD.log
# ./speculator.sh

#############################################
# SECTION 0: DOCKER SETUP
#############################################

# Install Docker
if ! command -v docker &> /dev/null; then
    sudo apt update && sudo apt install -y docker.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
fi

# Create Docker network for OSINT tools
docker network create osint-network 2>/dev/null || true

# Create shared volume for OSINT data
docker volume create osint-data 2>/dev/null || true

# Function to build and setup Docker tool
build_docker_tool() {
    local tool_name=$1
    local git_url=$2
    local entrypoint=$3
    local extra_packages=${4:-""}
    
    cd ~/Downloads/Programs || return 1
    
    if [ ! -d "$tool_name" ]; then
        git clone "$git_url" "$tool_name"
    fi
    
    cd "$tool_name" || return 1
    
    # Create Dockerfile
    cat > Dockerfile << EOF
FROM python:3.11-slim

# Add non-root user
RUN useradd -m -r -u 1000 osint

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    git \\
    $extra_packages \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set ownership to non-root user
RUN chown -R osint:osint /app

# Switch to non-root user
USER osint

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \\
    CMD python -c "import sys; sys.exit(0)"

ENTRYPOINT $entrypoint
EOF
    
    # Build image
    docker build -t "$tool_name" .
    
    # Create wrapper script
    mkdir -p ~/Documents/scripts
    cat > ~/Documents/scripts/"$tool_name".sh << EOF
#!/bin/bash
docker run --rm \\
    --network osint-network \\
    -v "\$(pwd):/app/output" \\
    -v osint-data:/app/data \\
    $tool_name "\$@"
EOF
    
    chmod +x ~/Documents/scripts/"$tool_name".sh
}

#############################################
# SECTION 1: INITIAL SETUP
#############################################

# Create essential directories
mkdir -p ~/Desktop/evidences
mkdir -p ~/Downloads/Programs

# Basic system update and essential packages
sudo apt update
sudo apt install -y curl wget git python3-pip python3-venv pipx

#############################################
# SECTION 2: OSINT TOOLS INSTALLATION
#############################################

# Build Python-based OSINT tools in Docker
build_docker_tool "blackbird" "https://github.com/p1ngul1n0/blackbird" '["python", "blackbird.py"]'
build_docker_tool "maigret" "https://github.com/soxoj/maigret" '["python", "-m", "maigret"]'
build_docker_tool "whatsmyname" "https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python.git" '["python", "wmn.py"]'
build_docker_tool "osintgram" "https://github.com/Datalux/Osintgram.git" '["python", "main.py"]'
build_docker_tool "photon" "https://github.com/s0md3v/Photon.git" '["python", "photon.py"]'
build_docker_tool "spiderfoot" "https://github.com/smicallef/spiderfoot.git" '["python", "sf.py"]'
build_docker_tool "reconng" "https://github.com/lanmaster53/recon-ng.git" '["python", "recon-ng"]'
build_docker_tool "theHarvester" "https://github.com/laramies/theHarvester.git" '["python", "theHarvester.py"]'
build_docker_tool "sherlock" "https://github.com/sherlock-project/sherlock.git" '["python", "-m", "sherlock"]'

# Install additional tools via pipx
tools=(
    "socialscan"
    "holehe"
    "ghunt"
    "h8mail"
    "search-that-hash"
    "name-that-hash"
    "gallery-dl"
    "yt-dlp"
    "streamlink"
    "waybackpy"
    "xeuledoc"
)

for tool in "${tools[@]}"; do
    pipx install "$tool"
done

#############################################
# SECTION 3: AMASS AND DOMAIN TOOLS
#############################################

# Amass installation via Docker
docker pull caffix/amass
cat > ~/Documents/scripts/amass.sh << 'EOF'
#!/bin/bash
docker run --rm -v "$HOME/.config/amass:/.config/amass" -v "$(pwd):/output" caffix/amass "$@"
EOF
chmod +x ~/Documents/scripts/amass.sh

# Domain tools installation
sudo apt install -y httrack webhttrack libimage-exiftool-perl

# EyeWitness setup
cd ~/Downloads/Programs
git clone https://github.com/ChrisTruncer/EyeWitness.git
cd EyeWitness/Python/setup
sudo ./setup.sh
wget https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux-aarch64.tar.gz
tar -xvzf geckodriver*
chmod +x geckodriver
sudo mv geckodriver /usr/local/bin

#############################################
# SECTION 4: FORENSICS AND METADATA TOOLS
#############################################

# Forensics tools installation
sudo apt install -y mediainfo-gui mat2 python3-testresources subversion

# Build forensics tools in Docker
build_docker_tool "metagoofil" "https://github.com/opsdisk/metagoofil.git" '["python", "metagoofil.py"]'
build_docker_tool "sherloq" "https://github.com/GuidoBartoli/sherloq.git" '["python", "gui/sherloq.py"]' "qt5-default"
build_docker_tool "carbon14" "https://github.com/Lazza/Carbon14" '["python", "carbon14.py"]'

#############################################
# SECTION 5: ADDITIONAL FRAMEWORKS
#############################################

# Mr.Holmes installation
cd ~/Downloads/Programs
git clone https://github.com/Lucksi/Mr.Holmes

# Sn0int installation
sudo apt install -y sq
curl -sSf https://apt.vulns.sexy/kpcyrd.pgp | sq dearmor | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg
echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list
sudo apt update && sudo apt install -y sn0int

#############################################
# SECTION 6: BROWSER AND MEDIA TOOLS
#############################################

# Install browsers and media tools
sudo apt install -y brave-browser flatpak vlc ffmpeg mediainfo-gui mat2 bleachbit kazam

# Setup Tor Browser
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.torproject.torbrowser-launcher -y

# Firefox Configuration
cd ~/Desktop 
firefox &
sleep 10
pkill -f firefox
curl -O https://inteltechniques.com/data/osintvm/ff-template.zip  
unzip ff-template.zip -d ~/.mozilla/firefox/
cd ~/.mozilla/firefox/ff-template/
cp -R * ~/.mozilla/firefox/*.default-esr*
cd ~/Desktop && rm ff-template.zip

#############################################
# SECTION 7: SETUP AND CONFIGURATION
#############################################

# Download and setup scripts from inteltechniques
cd ~/Documents/scripts

script_files=(
    "api.sh"
    "domain.sh"
    "framework.sh"
    "image.sh"
    "metadata.sh"
    "update.sh"
    "user.sh"
    "video.sh"
)

for script in "${script_files[@]}"; do
    curl -O "https://tuvm:311@inteltechniques.com/osintvm/$script"
    chmod +x "$script"
done

# Download desktop files and icons
desktop_files=(
    "api.desktop"
    "domain.desktop"
    "framework.desktop"
    "image.desktop"
    "metadata.desktop"
    "search.desktop"
    "update.desktop"
    "user.desktop"
    "video.desktop"
)

icons=(
    "api.png"
    "domain.png"
    "framework.png"
    "image.png"
    "metadata.png"
    "search.png"
    "update.png"
    "user.png"
    "video.png"
)

for file in "${desktop_files[@]}" "${icons[@]}"; do
    curl -O "https://tuvm:311@inteltechniques.com/osintvm/$file"
done

# Move desktop files
sudo mv *.desktop /usr/share/applications/

# Google Earth installation
wget http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
sudo apt install -y ./google-earth-stable_current_amd64.deb
sudo rm google-earth-stable_current_amd64.deb

# Configure Gnome desktop
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.torproject.torbrowser-launcher.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.gedit.desktop', 'update.desktop', 'search.desktop', 'video.desktop', 'user.desktop', 'image.desktop', 'domain.desktop', 'metadata.desktop', 'framework.desktop', 'api.desktop', 'google-earth-pro.desktop', 'kazam.desktop', 'org.gnome.Settings.desktop']"

# Create cleanup script for Docker
cat > ~/Documents/scripts/cleanup-docker.sh << 'EOF'
#!/bin/bash
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker image prune -af
docker volume prune -f
EOF
chmod +x ~/Documents/scripts/cleanup-docker.sh

# Create update script
cat > ~/Documents/scripts/update-tools.sh << 'EOF'
#!/bin/bash
cd ~/Downloads/Programs
for tool_dir in */; do
    if [ -d "$tool_dir/.git" ]; then
        echo "Updating $tool_dir..."
        (cd "$tool_dir" && git pull && docker build -t "${tool_dir%/}" .)
    fi
done
EOF
chmod +x ~/Documents/scripts/update-tools.sh

# Final update and upgrade
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

echo
echo "Installation complete! Please log out and log back in for Docker permissions to take effect."
echo "After logging back in, run the command 'exit' to save the installation log."
echo

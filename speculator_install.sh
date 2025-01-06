#!/bin/bash

# Speculator Install Script
# Version: 0.0.24
# Last Update: 20250106
#
# Version History:
# 0.0.24 (20250106) - Added complete installation logging on Desktop
# 0.0.23 (20250106) - Added installation logging
# 0.0.22 (20250106) - fixing maigret
# 0.0.21 (20250105) - fixing rm amass
# 0.0.2 (20250104) - Reorganized script in sections
# 0.0.1 (20250103) - Initial version based on OSINT VM install script

#############################################
# SECTION 0: LOGGING SETUP
#############################################

# Setup logging directory and files
LOG_DIR="$HOME/Desktop/install_logs"
mkdir -p "$LOG_DIR"
INSTALL_LOG="$LOG_DIR/speculator_install_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="$LOG_DIR/speculator_error_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$INSTALL_LOG"
}

log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $1" | tee -a "$ERROR_LOG"
}

log_section() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ========== $1 ==========" | tee -a "$INSTALL_LOG"
}

# Start logging
log_message "Starting Speculator installation script"
log_message "Version: 0.0.24"
log_message "Date: $(date)"

#############################################
# SECTION 1: INITIAL SETUP
#############################################

log_section "INITIAL SETUP"

# Create essential directories
log_message "Creating essential directories..."
mkdir -p ~/Desktop/evidences || log_error "Failed to create evidences directory"

# Basic system updates and Python setup
log_message "Starting system updates and Python setup..."
if sudo apt update; then
    log_message "APT update completed successfully"
else
    log_error "APT update failed"
fi

if sudo apt install python3-pip -y; then
    log_message "Python3-pip installed successfully"
else
    log_error "Python3-pip installation failed"
fi

log_message "Removing EXTERNALLY-MANAGED file..."
cd /usr/lib/python3.11 || log_error "Failed to change directory to python3.11"
sudo rm EXTERNALLY-MANAGED || log_error "Failed to remove EXTERNALLY-MANAGED"

if pip3 install gnome-extensions-cli; then
    log_message "gnome-extensions-cli installed successfully"
else
    log_error "gnome-extensions-cli installation failed"
fi

tput reset && source ~/.profile
#############################################
# SECTION 2: BROWSER SETUP 
#############################################

log_section "BROWSER SETUP"

# Firefox Configuration
log_message "Starting Firefox configuration..."
cd ~/Desktop || log_error "Failed to change directory to Desktop"
firefox & 
sleep 10
if pkill -f firefox; then
    log_message "Firefox initial setup completed"
else
    log_error "Firefox initial setup failed"
fi

log_message "Downloading Firefox template..."
if curl -O https://inteltechniques.com/data/osintvm/ff-template.zip; then
    log_message "Firefox template downloaded successfully"
else
    log_error "Failed to download Firefox template"
fi

log_message "Extracting Firefox template..."
if unzip ff-template.zip -d ~/.mozilla/firefox/; then
    log_message "Firefox template extracted successfully"
else
    log_error "Failed to extract Firefox template"
fi

log_message "Configuring Firefox profile..."
cd ~/.mozilla/firefox/ff-template/ || log_error "Failed to change directory to Firefox template"
if cp -R * ~/.mozilla/firefox/*.default-esr*; then
    log_message "Firefox profile configured successfully"
else
    log_error "Failed to configure Firefox profile"
fi

cd ~/Desktop && rm ff-template.zip
log_message "Firefox template cleanup completed"

# Brave Browser Installation
log_section "BRAVE BROWSER INSTALLATION"

log_message "Starting Brave browser installation..."
if sudo apt update; then
    log_message "APT update successful"
else
    log_error "APT update failed before Brave installation"
fi

log_message "Adding Brave browser keyring..."
if sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
    log_message "Brave keyring added successfully"
else
    log_error "Failed to add Brave keyring"
fi

log_message "Adding Brave repository..."
if echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list; then
    log_message "Brave repository added successfully"
else
    log_error "Failed to add Brave repository"
fi

if sudo apt update && sudo apt install brave-browser -y; then
    log_message "Brave browser installed successfully"
else
    log_error "Failed to install Brave browser"
fi

# Tor Browser Installation
log_section "TOR BROWSER INSTALLATION"

log_message "Installing Flatpak..."
if sudo apt install flatpak -y; then
    log_message "Flatpak installed successfully"
else
    log_error "Failed to install Flatpak"
fi

log_message "Adding Flathub repository..."
if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
    log_message "Flathub repository added successfully"
else
    log_error "Failed to add Flathub repository"
fi

log_message "Installing Tor Browser..."
if flatpak install flathub org.torproject.torbrowser-launcher -y; then
    log_message "Tor Browser installed successfully"
else
    log_error "Failed to install Tor Browser"
fi

if flatpak run org.torproject.torbrowser-launcher; then
    log_message "Tor Browser launcher executed successfully"
else
    log_error "Failed to execute Tor Browser launcher"
fi
#############################################
# SECTION 3: BASE TOOLS INSTALLATION
#############################################

log_section "BASE TOOLS INSTALLATION"

# Media tools installation
log_message "Installing VLC..."
if sudo apt install vlc -y; then
   log_message "VLC installed successfully"
else
   log_error "Failed to install VLC"
fi

log_message "Installing FFmpeg..."
if sudo apt install ffmpeg -y; then
   log_message "FFmpeg installed successfully"
else
   log_error "Failed to install FFmpeg"
fi

# Python environment setup
log_message "Setting up Python environment..."
if sudo apt install python3-venv -y; then
   log_message "Python virtual environment package installed successfully"
else
   log_error "Failed to install Python virtual environment package"
fi

if sudo apt install pipx -y; then
   log_message "Pipx installed successfully"
else
   log_error "Failed to install pipx"
fi

# Git installation
log_message "Installing Git..."
if sudo apt install git -y; then
   log_message "Git installed successfully"
else
   log_error "Failed to install Git"
fi

# Media download tools
log_message "Installing media download tools..."
if pipx install yt-dlp; then
   log_message "yt-dlp installed successfully"
else
   log_error "Failed to install yt-dlp"
fi

if pipx ensurepath; then
   log_message "Pipx path ensured successfully"
else
   log_error "Failed to ensure pipx path"
fi

if pipx install streamlink; then
   log_message "Streamlink installed successfully"
else
   log_error "Failed to install streamlink"
fi

tput reset && source ~/.profile
log_message "Environment refreshed"

# Cleanup
log_message "Cleaning up Tor Browser..."
if flatpak kill org.torproject.torbrowser-launcher; then
   log_message "Tor Browser cleanup successful"
else
   log_error "Failed to cleanup Tor Browser"
fi

#############################################
# SECTION 4: OSINT TOOLS - USERNAME & SOCIAL
#############################################

log_section "OSINT TOOLS - USERNAME & SOCIAL"

# Basic username tools installation
log_message "Installing Sherlock..."
if pipx install sherlock-project; then
   log_message "Sherlock installed successfully"
else
   log_error "Failed to install Sherlock"
fi

log_message "Installing socialscan..."
if pipx install socialscan; then
   log_message "Socialscan installed successfully"
else
   log_error "Failed to install socialscan"
fi

# Blackbird installation and setup
log_message "Setting up Blackbird..."
mkdir -p ~/Downloads/Programs || log_error "Failed to create Programs directory"
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"

if git clone https://github.com/p1ngul1n0/blackbird; then
   log_message "Blackbird repository cloned successfully"
   cd blackbird || log_error "Failed to change to blackbird directory"
   if python3 -m venv blackbirdEnvironment; then
       log_message "Blackbird virtual environment created successfully"
       source blackbirdEnvironment/bin/activate
       if sudo pip install -r requirements.txt; then
           log_message "Blackbird requirements installed successfully"
       else
           log_error "Failed to install Blackbird requirements"
       fi
       deactivate
       log_message "Blackbird virtual environment deactivated"
   else
       log_error "Failed to create Blackbird virtual environment"
   fi
else
   log_error "Failed to clone Blackbird repository"
fi

# Maigret installation and setup
log_message "Setting up Maigret..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/soxoj/maigret; then
   log_message "Maigret repository cloned successfully"
   cd maigret || log_error "Failed to change to maigret directory"
   if python3 -m venv maigretEnvironment; then
       log_message "Maigret virtual environment created successfully"
       source maigretEnvironment/bin/activate
       if pip install --upgrade pip; then
           log_message "Pip upgraded successfully in Maigret environment"
           if pip install urllib3>=1.26 && pip install .; then
               log_message "Maigret and dependencies installed successfully"
           else
               log_error "Failed to install Maigret dependencies"
           fi
       else
           log_error "Failed to upgrade pip in Maigret environment"
       fi
       deactivate
       log_message "Maigret virtual environment deactivated"
   else
       log_error "Failed to create Maigret virtual environment"
   fi
else
   log_error "Failed to clone Maigret repository"
fi

# WhatsMyName installation and setup
log_message "Setting up WhatsMyName..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python.git; then
   log_message "WhatsMyName repository cloned successfully"
   cd WhatsMyName-Python || log_error "Failed to change to WhatsMyName-Python directory"
   if python3 -m venv wmnpythonEnvironment; then
       log_message "WhatsMyName virtual environment created successfully"
       source wmnpythonEnvironment/bin/activate
       if sudo pip3 install -r requirements.txt; then
           log_message "WhatsMyName requirements installed successfully"
       else
           log_error "Failed to install WhatsMyName requirements"
       fi
       deactivate
       log_message "WhatsMyName virtual environment deactivated"
   else
       log_error "Failed to create WhatsMyName virtual environment"
   fi
else
   log_error "Failed to clone WhatsMyName repository"
fi
#############################################
# SECTION 5: OSINT TOOLS - MEDIA & DOWNLOAD
#############################################

log_section "OSINT TOOLS - MEDIA & DOWNLOAD"

# Gallery download tools
log_message "Installing gallery-dl..."
if pipx install gallery-dl; then
   log_message "gallery-dl installed successfully"
else
   log_error "Failed to install gallery-dl"
fi

# Java and Ripme setup
log_message "Setting up Java and Ripme..."
cd ~/Downloads || log_error "Failed to change to Downloads directory"

log_message "Installing wget..."
if sudo apt install wget; then
   log_message "wget installed successfully"
else
   log_error "Failed to install wget"
fi

log_message "Installing Java..."
if sudo apt install default-jre -y; then
   log_message "Java installed successfully"
else
   log_error "Failed to install Java"
fi

log_message "Downloading Ripme..."
if wget https://github.com/ripmeapp/ripme/releases/latest/download/ripme.jar; then
   log_message "Ripme downloaded successfully"
   if chmod +x ripme.jar; then
       log_message "Ripme permissions set successfully"
   else
       log_error "Failed to set Ripme permissions"
   fi
else
   log_error "Failed to download Ripme"
fi

# Instagram tools installation
log_message "Installing Instagram tools..."
if pipx install instaloader; then
   log_message "Instaloader installed successfully"
else
   log_error "Failed to install instaloader"
fi

if pipx install toutatis; then
   log_message "Toutatis installed successfully"
else
   log_error "Failed to install toutatis"
fi

# Osintgram setup
log_message "Setting up Osintgram..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/Datalux/Osintgram.git; then
   log_message "Osintgram repository cloned successfully"
   cd Osintgram || log_error "Failed to change to Osintgram directory"
   if python3 -m venv OsintgramEnvironment; then
       log_message "Osintgram virtual environment created successfully"
       source OsintgramEnvironment/bin/activate
       if sudo pip install -r requirements.txt; then
           log_message "Osintgram requirements installed successfully"
       else
           log_error "Failed to install Osintgram requirements"
       fi
       deactivate
       log_message "Osintgram virtual environment deactivated"
   else
       log_error "Failed to create Osintgram virtual environment"
   fi
else
   log_error "Failed to clone Osintgram repository"
fi

#############################################
# SECTION 6: OSINT TOOLS - DOMAIN & WEB
#############################################

log_section "OSINT TOOLS - DOMAIN & WEB"

# EyeWitness installation and setup
log_message "Setting up EyeWitness..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/ChrisTruncer/EyeWitness.git; then
   log_message "EyeWitness repository cloned successfully"
   cd EyeWitness/Python/setup || log_error "Failed to change to EyeWitness setup directory"
   if sudo ./setup.sh; then
       log_message "EyeWitness setup completed successfully"
   else
       log_error "Failed to run EyeWitness setup script"
   fi

   log_message "Setting up geckodriver..."
   if wget https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux-aarch64.tar.gz; then
       log_message "geckodriver downloaded successfully"
       if tar -xvzf geckodriver* && chmod +x geckodriver && sudo mv geckodriver /usr/local/bin; then
           log_message "geckodriver installed successfully"
       else
           log_error "Failed to install geckodriver"
       fi
   else
       log_error "Failed to download geckodriver"
   fi
else
   log_error "Failed to clone EyeWitness repository"
fi

# HTTrack installation
log_message "Installing HTTrack..."
if sudo apt install httrack -y; then
   log_message "HTTrack installed successfully"
else
   log_error "Failed to install HTTrack"
fi

if sudo apt install webhttrack -y; then
   log_message "WebHTTrack installed successfully"
else
   log_error "Failed to install WebHTTrack"
fi

# Wayback tools
log_message "Installing Wayback tools..."
if pipx install waybackpy; then
   log_message "waybackpy installed successfully"
else
   log_error "Failed to install waybackpy"
fi

if pipx install waybackpack; then
   log_message "waybackpack installed successfully"
else
   log_error "Failed to install waybackpack"
fi

# Amass installation
log_message "Installing Amass..."
cd ~/Downloads || log_error "Failed to change to Downloads directory"
ver=$(dpkg --print-architecture)
log_message "Detected architecture: $ver"

if wget "https://github.com/owasp-amass/amass/releases/latest/download/amass_Linux_$ver.zip"; then
   log_message "Amass downloaded successfully"
   mkdir -p ~/Downloads/Programs/Amass || log_error "Failed to create Amass directory"
   if unzip "amass_Linux_$ver.zip" -d ~/Downloads/Programs/Amass/; then
       log_message "Amass extracted successfully"
       cd Programs/Amass/amass_Linux_"$ver"/ || log_error "Failed to change to Amass directory"
       mv * ~/Downloads/Programs/Amass
       rm -r ~/Downloads/Programs/Amass/amass_Linux_"$ver"/
       rm "/home/osint/Downloads/amass_Linux_$ver.zip"
       log_message "Amass installation completed"
   else
       log_error "Failed to extract Amass"
   fi
else
   log_error "Failed to download Amass"
fi
#############################################
# SECTION 7: OSINT TOOLS - METADATA & FORENSICS
#############################################

log_section "OSINT TOOLS - METADATA & FORENSICS"

# Carbon14 installation
log_message "Setting up Carbon14..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/Lazza/Carbon14; then
   log_message "Carbon14 repository cloned successfully"
   cd Carbon14 || log_error "Failed to change to Carbon14 directory"
   if python3 -m venv Carbon14Environment; then
       log_message "Carbon14 virtual environment created successfully"
       source Carbon14Environment/bin/activate
       if sudo pip install -r requirements.txt; then
           log_message "Carbon14 requirements installed successfully"
       else
           log_error "Failed to install Carbon14 requirements"
       fi
       deactivate
       log_message "Carbon14 virtual environment deactivated"
   else
       log_error "Failed to create Carbon14 virtual environment"
   fi
else
   log_error "Failed to clone Carbon14 repository"
fi

# Change detection and archiving tools
log_message "Installing change detection and archiving tools..."
if pipx install changedetection.io; then
   log_message "changedetection.io installed successfully"
else
   log_error "Failed to install changedetection.io"
fi

if pipx install archivebox; then
   log_message "archivebox installed successfully"
else
   log_error "Failed to install archivebox"
fi

# Metadata tools installation
log_message "Installing metadata tools..."
if sudo apt install libimage-exiftool-perl -y; then
   log_message "ExifTool installed successfully"
else
   log_error "Failed to install ExifTool"
fi

log_message "Setting up metagoofil..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/opsdisk/metagoofil.git; then
   log_message "metagoofil repository cloned successfully"
   cd metagoofil || log_error "Failed to change to metagoofil directory"
   if python3 -m venv metagoofilEnvironment; then
       log_message "metagoofil virtual environment created successfully"
       source metagoofilEnvironment/local/bin/activate
       if sudo pip install -r requirements.txt; then
           log_message "metagoofil requirements installed successfully"
       else
           log_error "Failed to install metagoofil requirements"
       fi
       deactivate
       log_message "metagoofil virtual environment deactivated"
   else
       log_error "Failed to create metagoofil virtual environment"
   fi
else
   log_error "Failed to clone metagoofil repository"
fi

# Additional forensics tools
log_message "Installing additional forensics tools..."
if sudo apt install mediainfo-gui -y; then
   log_message "mediainfo-gui installed successfully"
else
   log_error "Failed to install mediainfo-gui"
fi

if sudo apt install mat2 -y; then
   log_message "mat2 installed successfully"
else
   log_error "Failed to install mat2"
fi

if pipx install xeuledoc; then
   log_message "xeuledoc installed successfully"
else
   log_error "Failed to install xeuledoc"
fi

# Sherloq installation
log_message "Setting up Sherloq..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if sudo apt install python3-testresources subversion -y; then
   log_message "Sherloq dependencies installed successfully"
else
   log_error "Failed to install Sherloq dependencies"
fi

if git clone https://github.com/GuidoBartoli/sherloq.git; then
   log_message "Sherloq repository cloned successfully"
   cd sherloq/gui || log_error "Failed to change to sherloq gui directory"
   if python3 -m venv sherloqEnvironment; then
       log_message "Sherloq virtual environment created successfully"
       source sherloqEnvironment/bin/activate
       if sudo pip install -r requirements.txt; then
           log_message "Sherloq requirements installed successfully"
       else
           log_error "Failed to install Sherloq requirements"
       fi
       deactivate
       log_message "Sherloq virtual environment deactivated"
   else
       log_error "Failed to create Sherloq virtual environment"
   fi
else
   log_error "Failed to clone Sherloq repository"
fi

#############################################
# SECTION 8: FRAMEWORK TOOLS
#############################################

log_section "FRAMEWORK TOOLS"

# Spiderfoot installation
log_message "Setting up Spiderfoot..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/smicallef/spiderfoot.git; then
   log_message "Spiderfoot repository cloned successfully"
   cd spiderfoot || log_error "Failed to change to spiderfoot directory"
   if python3 -m venv spiderfootEnvironment; then
       log_message "Spiderfoot virtual environment created successfully"
       source spiderfootEnvironment/bin/activate
       if sudo pip install -r requirements.txt; then
           log_message "Spiderfoot requirements installed successfully"
       else
           log_error "Failed to install Spiderfoot requirements"
       fi
       deactivate
       log_message "Spiderfoot virtual environment deactivated"
   else
       log_error "Failed to create Spiderfoot virtual environment"
   fi
else
   log_error "Failed to clone Spiderfoot repository"
fi

# Recon-ng installation
log_message "Setting up Recon-ng..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/lanmaster53/recon-ng.git; then
   log_message "Recon-ng repository cloned successfully"
   cd recon-ng || log_error "Failed to change to recon-ng directory"
   if python3 -m venv recon-ngEnvironment; then
       log_message "Recon-ng virtual environment created successfully"
       source recon-ngEnvironment/bin/activate
       if sudo pip install -r REQUIREMENTS; then
           log_message "Recon-ng requirements installed successfully"
       else
           log_error "Failed to install Recon-ng requirements"
       fi
       deactivate
       log_message "Recon-ng virtual environment deactivated"
   else
       log_error "Failed to create Recon-ng virtual environment"
   fi
else
   log_error "Failed to clone Recon-ng repository"
fi

# Mr.Holmes installation
log_message "Setting up Mr.Holmes..."
cd ~/Downloads/Programs || log_error "Failed to change to Programs directory"
if git clone https://github.com/Lucksi/Mr.Holmes; then
   log_message "Mr.Holmes repository cloned successfully"
else
   log_error "Failed to clone Mr.Holmes repository"
fi

# Sn0int installation
log_message "Installing Sn0int..."
if sudo apt install sq -y; then
   log_message "sq installed successfully"
else
   log_error "Failed to install sq"
fi

if curl -sSf https://apt.vulns.sexy/kpcyrd.pgp | sq dearmor | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg; then
   log_message "Sn0int repository key added successfully"
else
   log_error "Failed to add Sn0int repository key"
fi

if echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list; then
   log_message "Sn0int repository added successfully"
else
   log_error "Failed to add Sn0int repository"
fi

if sudo apt update && sudo apt install sn0int -y; then
   log_message "Sn0int installed successfully"
else
   log_error "Failed to install Sn0int"
fi

# Additional tools
log_message "Installing additional framework tools..."
if pipx install internetarchive; then
   log_message "internetarchive installed successfully"
else
   log_error "Failed to install internetarchive"
fi
#############################################
# SECTION 9: FINAL SETUP
#############################################

log_section "FINAL SETUP"

# Additional utilities installation
log_message "Installing additional utilities..."
if sudo apt install kazam -y; then
   log_message "Kazam installed successfully"
else
   log_error "Failed to install Kazam"
fi

if sudo apt install bleachbit -y; then
   log_message "Bleachbit installed successfully"
else
   log_error "Failed to install Bleachbit"
fi

# Google Earth installation
log_message "Installing Google Earth..."
if wget http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb; then
   log_message "Google Earth package downloaded successfully"
   if sudo apt install -y ./google-earth-stable_current_amd64.deb; then
       log_message "Google Earth installed successfully"
       sudo rm google-earth-stable_current_amd64.deb
       log_message "Google Earth installation files cleaned up"
   else
       log_error "Failed to install Google Earth"
   fi
else
   log_error "Failed to download Google Earth"
fi

# Final system updates and cleanup
log_section "SYSTEM UPDATES AND CLEANUP"

log_message "Performing final system updates..."
if sudo apt update; then
   log_message "APT update successful"
else
   log_error "Failed to update APT"
fi

if sudo apt upgrade -y; then
   log_message "System upgrade successful"
else
   log_error "Failed to upgrade system"
fi

if sudo apt update --fix-missing; then
   log_message "Fixed missing packages"
else
   log_error "Failed to fix missing packages"
fi

if sudo apt --fix-broken install; then
   log_message "Fixed broken installations"
else
   log_error "Failed to fix broken installations"
fi

if sudo apt autoremove -y; then
   log_message "Removed unused packages"
else
   log_error "Failed to remove unused packages"
fi

# Script downloads and setup
log_section "SCRIPT SETUP"

log_message "Setting up scripts directory..."
mkdir -p ~/Documents/scripts || log_error "Failed to create scripts directory"
cd ~/Documents/scripts || log_error "Failed to change to scripts directory"

log_message "Downloading OSINT scripts..."
SCRIPTS=(
   "api.sh"
   "domain.sh"
   "framework.sh"
   "image.sh"
   "metadata.sh"
   "update.sh"
   "user.sh"
   "video.sh"
)

for script in "${SCRIPTS[@]}"; do
   if curl -O "https://tuvm:311@inteltechniques.com/osintvm/$script"; then
       log_message "$script downloaded successfully"
       chmod +x "$script"
       log_message "Set execute permissions for $script"
   else
       log_error "Failed to download $script"
   fi
done

# Download desktop files and icons
log_message "Downloading desktop files and icons..."
DESKTOP_FILES=(
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

ICONS=(
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

for file in "${DESKTOP_FILES[@]}" "${ICONS[@]}"; do
   if curl -O "https://tuvm:311@inteltechniques.com/osintvm/$file"; then
       log_message "$file downloaded successfully"
   else
       log_error "Failed to download $file"
   fi
done

# Move desktop files to applications directory
log_message "Moving desktop files to applications directory..."
if sudo mv *.desktop /usr/share/applications/; then
   log_message "Desktop files moved successfully"
else
   log_error "Failed to move desktop files"
fi

# Final desktop configuration
log_section "FINAL DESKTOP CONFIGURATION"

log_message "Configuring desktop favorites..."
gsettings set org.gnome.shell favorite-apps []
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.torproject.torbrowser-launcher.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'update.desktop', 'search.desktop', 'video.desktop', 'user.desktop', 'image.desktop', 'domain.desktop', 'metadata.desktop', 'framework.desktop', 'api.desktop', 'google-earth-pro.desktop', 'kazam.desktop', 'org.gnome.Settings.desktop']"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32

log_message "Installation completed at $(date)"
echo
read -rsp $'Installation complete! Please reboot.\nPress any key to continue...\n'
echo

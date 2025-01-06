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

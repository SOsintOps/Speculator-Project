#!/bin/bash

# Speculator Install Script
# Version: 0.0.23
# Last Update: 20250106
#
# Version History:
# 0.0.22 (20250106) - apt curl e gnome customizing moved to the end of the file
# 0.0.22 (20250106) - fixing maigret
# 0.0.21 (20250105) - fixing rm amass
# 0.0.2 (20250104) - Reorganized script in sections
# 0.0.1 (20250103) - Initial version based on OSINT VM install script
#
# Description:
# **** Speculator Project ****
# This project provides a script for customizing Debian virtual machines,
# specifically designed for cybercrime investigation and OSINT activities.
# The script installs and configures a suite of OSINT tools and utilities
# for digital forensics and intelligence gathering.
#
# Author: Speculator Project Team
# Based on the Michael Bazzell's book
#
# License: Under Investigation - All rights reserved
# This is a development version - use at your own risk
#
# Dependencies:
# - Debian 12 (stable)
# - Internet connection
# - Sudo privileges
#
# Usage: ./speculator.sh

#############################################
# SECTION 1: INITIAL SETUP
#############################################

# Create essential directories
mkdir -p ~/Desktop/evidences

# Basic system updates and Python setup
sudo apt update
sudo apt install python3-pip curl -y
cd /usr/lib/python3.11
sudo rm EXTERNALLY-MANAGED
pip3 install gnome-extensions-cli
tput reset && source ~/.profile



#############################################
# SECTION 2: BROWSER SETUP 
#############################################

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

# Brave Browser Installation
sudo apt update
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y

# Tor Browser Installation
sudo apt install flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.torproject.torbrowser-launcher -y
flatpak run org.torproject.torbrowser-launcher

#############################################
# SECTION 3: BASE TOOLS INSTALLATION
#############################################

# Media tools installation
sudo apt install vlc -y
sudo apt install ffmpeg -y

# Python environment setup
sudo apt install python3-venv -y
sudo apt install pipx -y

# Git installation
sudo apt install git -y

# Media download tools
pipx install yt-dlp
pipx ensurepath
pipx install streamlink
tput reset && source ~/.profile

# Cleanup previous installations
flatpak kill org.torproject.torbrowser-launcher

#############################################
# SECTION 4: OSINT TOOLS - USERNAME & SOCIAL
#############################################

# Basic username tools installation
pipx install sherlock-project
pipx install socialscan

# Blackbird installation and setup
mkdir ~/Downloads/Programs
cd ~/Downloads/Programs
git clone https://github.com/p1ngul1n0/blackbird
cd blackbird
python3 -m venv blackbirdEnvironment
source blackbirdEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

# Maigret installation and setup
cd ~/Downloads/Programs
git clone https://github.com/soxoj/maigret
cd maigret
python3 -m venv maigretEnvironment
source maigretEnvironment/bin/activate
pip install --upgrade pip
pip install urllib3>=1.26
pip install .
deactivate

# WhatsMyName installation and setup
cd ~/Downloads/Programs
git clone https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python.git
cd WhatsMyName-Python
python3 -m venv wmnpythonEnvironment
source wmnpythonEnvironment/bin/activate
sudo pip3 install -r requirements.txt
deactivate

# Additional social tools
pipx install bdfr
pipx install holehe

# Eyes installation and setup
mkdir ~/Downloads/Programs/eyes
cd ~/Downloads/Programs/eyes
git clone https://github.com/N0rz3/Eyes.git
cd Eyes
python3 -m venv eyesEnvironment
source eyesEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

# Additional tools
pipx install ghunt
pipx install h8mail
tput reset && source ~/.profile

# H8mail configuration
cd ~/Downloads
h8mail -g
sed -i 's/\;leak\-lookup\_pub/leak\-lookup\_pub/g' h8mail_config.ini

# Hash tools
pipx install search-that-hash
pipx install name-that-hash
#############################################
# SECTION 5: OSINT TOOLS - MEDIA & DOWNLOAD
#############################################

# Gallery download tools
pipx install gallery-dl

# Java and Ripme setup
cd ~/Downloads
sudo apt install wget
sudo apt install default-jre -y
wget https://github.com/ripmeapp/ripme/releases/latest/download/ripme.jar
chmod +x ripme.jar

# Instagram tools installation
pipx install instaloader
pipx install toutatis

# Osintgram setup
cd ~/Downloads/Programs
git clone https://github.com/Datalux/Osintgram.git
cd Osintgram
python3 -m venv OsintgramEnvironment
source OsintgramEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

#############################################
# SECTION 6: OSINT TOOLS - DOMAIN & WEB
#############################################

# EyeWitness installation and setup
cd ~/Downloads/Programs
git clone https://github.com/ChrisTruncer/EyeWitness.git
cd EyeWitness/Python/setup
sudo ./setup.sh
wget https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux-aarch64.tar.gz
tar -xvzf geckodriver*
chmod +x geckodriver
sudo mv geckodriver /usr/local/bin

# HTTrack installation
sudo apt install httrack -y
sudo apt install webhttrack -y

# Wayback tools
pipx install waybackpy
pipx install waybackpack

# Amass installation
cd ~/Downloads
ver=$(dpkg --print-architecture)
wget https://github.com/owasp-amass/amass/releases/latest/download/amass_Linux_"$ver".zip
mkdir ~/Downloads/Programs/Amass
unzip amass_Linux_"$ver".zip -d ~/Downloads/Programs/Amass/
cd Programs/Amass/amass_Linux_"$ver"/
mv * ~/Downloads/Programs/Amass
rm -r ~/Downloads/Programs/Amass/amass_Linux_"$ver"/
rm '/home/osint/Downloads/amass_Linux_amd64.zip' 

# Photon installation
cd ~/Downloads/Programs
git clone https://github.com/s0md3v/Photon.git
cd Photon
python3 -m venv PhotonEnvironment
source PhotonEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

# Sublist3r installation
cd ~/Downloads/Programs
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
python3 -m venv Sublist3rEnvironment
source Sublist3rEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

# theHarvester installation
cd ~/Downloads/Programs
git clone https://github.com/laramies/theHarvester.git
cd theHarvester
python3 -m venv theHarvesterEnvironment
source theHarvesterEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

#############################################
# SECTION 7: OSINT TOOLS - METADATA & FORENSICS
#############################################

# Carbon14 installation
cd ~/Downloads/Programs
git clone https://github.com/Lazza/Carbon14
cd Carbon14
python3 -m venv Carbon14Environment
source Carbon14Environment/bin/activate
sudo pip install -r requirements.txt
deactivate

# Change detection and archiving tools
pipx install changedetection.io
pipx install archivebox

# Metadata tools installation
sudo apt install libimage-exiftool-perl -y
cd ~/Downloads/Programs
git clone https://github.com/opsdisk/metagoofil.git
cd metagoofil
python3 -m venv metagoofilEnvironment
source metagoofilEnvironment/local/bin/activate
sudo pip install -r requirements.txt
deactivate

# Additional forensics tools
sudo apt install mediainfo-gui -y
sudo apt install mat2 -y
pipx install xeuledoc

# Sherloq installation
cd ~/Downloads/Programs
sudo apt install python3-testresources subversion -y
git clone https://github.com/GuidoBartoli/sherloq.git
cd sherloq/gui
python3 -m venv sherloqEnvironment
source sherloqEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

#############################################
# SECTION 8: FRAMEWORK TOOLS
#############################################

# Spiderfoot installation
cd ~/Downloads/Programs
git clone https://github.com/smicallef/spiderfoot.git
cd spiderfoot
python3 -m venv spiderfootEnvironment
source spiderfootEnvironment/bin/activate
sudo pip install -r requirements.txt
deactivate

# Recon-ng installation
cd ~/Downloads/Programs
git clone https://github.com/lanmaster53/recon-ng.git
cd recon-ng
python3 -m venv recon-ngEnvironment
source recon-ngEnvironment/bin/activate
sudo pip install -r REQUIREMENTS
deactivate

# Mr.Holmes installation
cd ~/Downloads/Programs
git clone https://github.com/Lucksi/Mr.Holmes

# Sn0int installation
cd ~/Downloads/Programs
sudo apt install sq -y
curl -sSf https://apt.vulns.sexy/kpcyrd.pgp | sq dearmor | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg
echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list
sudo apt update && sudo apt install sn0int -y

# Additional tools
pipx install internetarchive

#############################################
# SECTION 9: FINAL SETUP
#############################################

# Additional utilities installation
sudo apt install kazam -y
sudo apt install bleachbit -y

# Google Earth installation
wget http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
sudo apt install -y ./google-earth-stable_current_amd64.deb
sudo rm google-earth-stable_current_amd64.deb

# Final system updates and cleanup
sudo apt update
sudo apt upgrade -y
sudo apt update --fix-missing
sudo apt --fix-broken install
sudo apt autoremove -y

# Script downloads and setup
mkdir ~/Documents/scripts
cd ~/Documents/scripts
curl -O https://tuvm:311@inteltechniques.com/osintvm/api.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/domain.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/framework.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/image.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/metadata.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/update.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/user.sh
curl -O https://tuvm:311@inteltechniques.com/osintvm/video.sh

# Set execute permissions
chmod +x api.sh
chmod +x domain.sh
chmod +x framework.sh
chmod +x image.sh
chmod +x metadata.sh
chmod +x update.sh
chmod +x user.sh
chmod +x video.sh

# Download desktop files and icons
curl -O https://tuvm:311@inteltechniques.com/osintvm/api.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/domain.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/framework.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/image.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/metadata.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/search.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/update.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/user.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/video.desktop
curl -O https://tuvm:311@inteltechniques.com/osintvm/api.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/domain.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/framework.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/image.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/metadata.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/search.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/update.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/user.png
curl -O https://tuvm:311@inteltechniques.com/osintvm/video.png

# Move desktop files to applications directory
sudo mv *.desktop /usr/share/applications/

# Final desktop configuration

# Gnome desktop configuration
gnome-extensions-cli install dash-to-dock@micxgx.gmail.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock intellihide false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock extend-height true
gnome-extensions-cli install 2087

# Desktop cleanup and preferences
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# gsettings set org.gnome.desktop.background picture-uri '' # disabilitate per ora
# gsettings set org.gnome.desktop.background picture-uri-dark '' # disabilitate per ora
# gsettings set org.gnome.desktop.background primary-color 'rgb(66, 81, 100)' # disabilitate per ora
gsettings set org.gnome.desktop.notifications show-banners false
gsettings set org.gnome.desktop.session idle-delay 0
sudo systemctl mask suspend.target
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
gsettings set org.gnome.mutter center-new-windows true
sudo apt install -y curl

gsettings set org.gnome.shell favorite-apps []
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.torproject.torbrowser-launcher.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'update.desktop', 'search.desktop', 'video.desktop', 'user.desktop', 'image.desktop', 'domain.desktop', 'metadata.desktop', 'framework.desktop', 'api.desktop', 'google-earth-pro.desktop', 'kazam.desktop', 'org.gnome.Settings.desktop']"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32

# Completion message
echo
read -rsp $'Complete! Please reboot. \n'
echo

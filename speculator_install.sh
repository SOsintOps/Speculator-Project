#!/usr/bin/env bash

# ###############################################################
# # SPECULATOR PROJECT - OSINT VM INSTALLATION SCRIPT
# # Version: 7.1 (Giada - Stable Release)
# # Description: Stable version with EyeWitness and Sherloq removed
# #              for improved compatibility and stability.
# ###############################################################


# --- SCRIPT CONFIGURATION ---
PROGRAMS_DIR="$HOME/Downloads/Programs"
LOG_FILE="$HOME/Downloads/install_log_$(date +%Y-%m-%d_%H-%M-%S).log"


# --- HELPER FUNCTIONS ---

# Installa tool Python da repository Git, gestendo venv e patch
install_py_tool_from_git() {
    local repo_url=$1
    local tool_name=$(basename "$repo_url" .git)
    local req_file_path=${2:-requirements.txt}

    echo "--> Installing $tool_name..."
    cd "$PROGRAMS_DIR" || return 1
    if [ ! -d "$tool_name" ]; then
        git clone "$repo_url" || return 1
    else
        echo "$tool_name directory already exists, skipping clone."
    fi
    cd "$tool_name" || return 1

    local full_req_path
    full_req_path=$(find . -name "$(basename "$req_file_path")" -print -quit)

    if [ -z "$full_req_path" ]; then
        echo "WARNING: Requirements file not found for $tool_name. Skipping pip install."
        return
    fi

    # Applica patch specifiche prima di installare le dipendenze
    if [ "$tool_name" == "spiderfoot" ]; then
        echo "Applying patch for SpiderFoot: removing lxml from requirements..."
        sed -i "/lxml/d" "$full_req_path"
    fi

    python3 -m venv --system-site-packages "${tool_name}Environment"
    source "${tool_name}Environment/bin/activate"

    pip install -r "$full_req_path" || echo "WARNING: Failed to install requirements for $tool_name."

    deactivate
}

# --- MAIN EXECUTION BLOCK ---
exec > >(tee -a "$LOG_FILE") 2>&1

{
    echo "#################################################################"
    echo "# SPECULATOR PROJECT - OSINT VM INSTALLATION SCRIPT             #"
    echo "# Version: 7.1 (Giada - Stable Release)                         #"
    echo "# Full log will be saved to: $LOG_FILE                          #"
    echo "#################################################################"

    mkdir -p "$PROGRAMS_DIR"

    # ###############################################################
    # PHASE 1: SYSTEM PREPARATION
    # ###############################################################
    echo "--- PHASE 1: System Preparation and Dependencies ---"

    sudo apt update

    echo "--> Installing packages, one by one for maximum resilience..."
    PACKAGES=(
        gnupg curl git gpg pipx flatpak unzip build-essential pkg-config libsodium-dev golang-go sq
        locales-all fonts-noto-core
        firefox-esr-l10n-it libreoffice-l10n-it manpages-it
        firefox-esr-l10n-ru libreoffice-l10n-ru manpages-ru
        firefox-esr-l10n-zh-cn libreoffice-l10n-zh-cn manpages-zh fonts-wqy-zenhei ibus-pinyin
        python3-venv python3-pip python3-testresources subversion vlc ffmpeg
        default-jre httrack webhttrack libimage-exiftool-perl mediainfo-gui mat2
        kazam bleachbit gnome-shell-extensions gnome-shell-extension-manager
        gnome-shell-extension-dash-to-dock python3-lxml libxml2-dev libxslt1-dev
        libxcb-cursor0 docker.io
    )
    for pkg in "${PACKAGES[@]}"; do
        sudo apt install -y "$pkg" || echo "WARNING: Failed to install '$pkg', continuing..."
    done

    pipx ensurepath || true
    export PATH="$HOME/.local/bin:$PATH"

    # ###############################################################
    # PHASE 2: CORE APPLICATIONS INSTALLATION
    # ###############################################################
    echo "--- PHASE 2: Core Applications Installation ---"

    echo "--> Configuring Firefox ESR..."
    if ! pgrep -f firefox-esr >/dev/null; then
      firefox-esr &
      sleep 15
      pkill -f firefox-esr
    fi
    cd "$HOME"
    curl -O https://inteltechniques.com/data/osintvm/ff-template.zip
    unzip -o ff-template.zip -d ~/.mozilla/firefox/
    PROFILE_DIR=$(find ~/.mozilla/firefox/ -maxdepth 1 -type d -name "*.default-esr*")
    [ -n "$PROFILE_DIR" ] && cp -R ~/.mozilla/firefox/ff-template/* "$PROFILE_DIR/"
    rm -rf ~/.mozilla/firefox/ff-template ff-template.zip

    echo "--> Installing Brave Browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser || true

    echo "--> Installing Tor Browser..."
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    flatpak install --user flathub org.torproject.torbrowser-launcher -y || true

    echo "--> Installing Google Earth..."
    cd "$HOME/Downloads"
    wget -q http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
    sudo apt install -y ./google-earth-stable_current_amd64.deb || true

    # ###############################################################
    # PHASE 3: OSINT TOOLS INSTALLATION
    # ###############################################################
    echo "--- PHASE 3: OSINT Tools Installation ---"

    echo "--> Installing tools via PIPX..."
    PIPX_PACKAGES=(
        yt-dlp streamlink socialscan bdfr holehe ghunt h8mail
        search-that-hash name-that-hash gallery-dl instaloader toutatis
        waybackpy waybackpack changedetection.io archivebox xeuledoc
        internetarchive maigret sherlock-project
    )
    for pkg in "${PIPX_PACKAGES[@]}"; do
        pipx install "$pkg" || true
    done

    echo "--> Installing Python tools from Git..."
    install_py_tool_from_git "https://github.com/p1ngul1n0/blackbird"
    install_py_tool_from_git "https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python"
    install_py_tool_from_git "https://github.com/N0rz3/Eyes"
    install_py_tool_from_git "https://github.com/Datalux/Osintgram"
    install_py_tool_from_git "https://github.com/s0md3v/Photon"
    install_py_tool_from_git "https://github.com/aboul3la/Sublist3r"
    install_py_tool_from_git "https://github.com/Lazza/Carbon14"
    install_py_tool_from_git "https://github.com/opsdisk/metagoofil"
    install_py_tool_from_git "https://github.com/smicallef/spiderfoot"
    install_py_tool_from_git "https://github.com/lanmaster53/recon-ng" "REQUIREMENTS"

    echo "--> Handling tools with special configurations..."
    cd "$HOME/Downloads"
    "$HOME/.local/bin/h8mail" -g || true
    [ -f "$HOME/h8mail_config.ini" ] && sed -i 's/\;leak\-lookup\_pub/leak\-lookup\_pub/g' "$HOME/h8mail_config.ini" || true

    echo "--> Installing sn0int (official APT method)..."
    curl -sSLf https://apt.vulns.sexy/kpcyrd.pgp | sq packet dearmor | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null
    echo "deb http://apt.vulns.sexy stable main" | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list > /dev/null
    sudo apt update
    sudo apt install -y sn0int || true

    echo "--> Installing theHarvester (official method)..."
    if ! command -v uv >/dev/null 2>&1; then
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    export PATH="$HOME/.local/bin:$PATH"
    cd "$PROGRAMS_DIR"
    if [ ! -d "theHarvester" ]; then
        git clone https://github.com/laramies/theHarvester.git
    fi
    cd theHarvester
    "$HOME/.local/bin/uv" sync || echo "WARNING: 'uv sync' failed for theHarvester."

    echo "--> Installing Amass (via Go)..."
    go install -v github.com/owasp-amass/amass/v4/...@master || echo "WARNING: Failed to install Amass."
    export PATH=$(go env GOPATH)/bin:$PATH

    cd "$PROGRAMS_DIR"
    if [ ! -d "Mr.Holmes" ]; then
        git clone https://github.com/Lucksi/Mr.Holmes
    fi

    # ###############################################################
    # PHASE 4: CUSTOM SCRIPTS AND LAUNCHERS INTEGRATION
    # ###############################################################
    echo "--- PHASE 4: Custom Scripts and Launchers Integration ---"
    
    mkdir -p "$HOME/Documents/scripts"
    cd "$HOME/Documents/scripts"
    URLS=(
        "api.sh" "domain.sh" "framework.sh" "image.sh" "metadata.sh" "update.sh" "user.sh" "video.sh"
        "api.desktop" "domain.desktop" "framework.desktop" "image.desktop" "metadata.desktop" "search.desktop" "update.desktop" "user.desktop" "video.desktop"
        "api.png" "domain.png" "framework.png" "image.png" "metadata.png" "search.png" "update.png" "user.png" "video.png"
    )
    for FILE in "${URLS[@]}"; do
        curl -sO "https://tuvm:311@inteltechniques.com/osintvm/$FILE" || echo "WARNING: Download of $FILE failed."
    done

    chmod +x *.sh || true
    sudo mv *.desktop /usr/share/applications/ 2>/dev/null || true

    # ###############################################################
    # PHASE 5: GNOME DESKTOP ENVIRONMENT CUSTOMIZATION
    # ###############################################################
    echo "--- PHASE 5: GNOME Desktop Environment Customization ---"

    echo "--> Applying system settings..."
    gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark' || true
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close" || true
    gsettings set org.gnome.desktop.notifications show-banners false || true
    gsettings set org.gnome.desktop.session idle-delay 0 || true
    gsettings set org.gnome.desktop.screensaver lock-enabled false || true
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true || true
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true || true
    gsettings set org.gnome.mutter center-new-windows true || true
    sudo systemctl mask suspend.target || true

    echo "--> Configuring dash-to-dock..."
    echo "NOTA: I seguenti errori relativi a 'gnome-extensions' sono previsti e possono essere ignorati. L'estensione verrà attivata e configurata correttamente dopo il riavvio del sistema."
    gnome-extensions enable dash-to-dock@micxgx.gmail.com || true
    SCHEMA="org.gnome.shell.extensions.dash-to-dock"
    gsettings set $SCHEMA dock-position 'LEFT' || true
    gsettings set $SCHEMA dash-max-icon-size 32 || true
    gsettings set $SCHEMA dock-fixed true || true
    gsettings set $SCHEMA autohide false || true
    gsettings set $SCHEMA intellihide false || true
    gsettings set $SCHEMA extend-height true || true

    echo "--> Configuring favorite applications..."
    FAVORITES="['firefox-esr.desktop', 'org.torproject.torbrowser-launcher.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'update.desktop', 'search.desktop', 'video.desktop', 'user.desktop', 'image.desktop', 'domain.desktop', 'metadata.desktop', 'framework.desktop', 'api.desktop', 'google-earth-pro.desktop', 'kazam.desktop', 'org.gnome.Settings.desktop']"
    gsettings set org.gnome.shell favorite-apps "$FAVORITES" || true

    # ###############################################################
    # PHASE 6: FINAL CLEANUP
    # ###############################################################
    echo "--- PHASE 6: Finalizing and Cleaning Up ---"

    sudo apt upgrade -y
    sudo apt --fix-broken install -y
    sudo apt autoremove -y

    echo "--> Removing temporary files..."
    rm -f "$HOME/Downloads/google-earth-stable_current_amd64.deb"
    rm -f "$HOME/ff-template.zip"

    # ###############################################################
    # COMPLETION
    # ###############################################################
    echo
    echo "--- INSTALLATION COMPLETE! ---"
    echo "Any errors have been logged but did not stop the script."
    echo "A system reboot is highly recommended to apply all changes."
    echo
    echo "Log file saved to: $LOG_FILE"

}

exit 0
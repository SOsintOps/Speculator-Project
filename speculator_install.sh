#!/usr/bin/env bash

# ###############################################################
# # SPECULATOR PROJECT - OSINT VM INSTALLATION SCRIPT
# # Version: 7.3 (Giada - Reverted Graphics/Launchers)
# # Description: Ripristinata la gestione grafica e dei launcher
# #              come dallo script originale.
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
    echo "# Version: 7.3 (Giada - Reverted Graphics/Launchers)            #"
    echo "#################################################################"
    echo "# Full log will be saved to:                                    #"
	echo " $LOG_FILE                          "
	echo " "
    mkdir -p "$PROGRAMS_DIR"

    # ###############################################################
    # PHASE 1: SYSTEM PREPARATION
    # ###############################################################
    echo "--- PHASE 1: System Preparation and Dependencies ---"

    sudo apt update

    echo "--> Installing packages, one by one for maximum resilience..."
    # NOTA: gnome-shell-extensions, gnome-shell-extension-manager, gnome-shell-extension-dash-to-dock
    # sono installati qui, ma la loro configurazione avverrà dopo tramite i comandi originali.
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

    # Aggiungi chiave Google per repository Earth per evitare warning apt
    echo "--> Adding Google GPG key for Earth repository..."
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/google-linux-signing-key.gpg > /dev/null

    pipx ensurepath || true
    export PATH="$HOME/.local/bin:$PATH"

    # ###############################################################
    # PHASE 2: CORE APPLICATIONS INSTALLATION
    # ###############################################################
    echo "--- PHASE 2: Core Applications Installation ---"

    echo "--> Configuring Firefox ESR (using original method)..."
    # L'originale chiudeva Firefox, scaricava il template, lo scompattava e copiava i file.
    # Assicurati che Firefox non sia in esecuzione
    pkill -f firefox-esr || true
    sleep 5 # Dà tempo a Firefox di chiudersi
    cd "$HOME"
    curl -O https://inteltechniques.com/data/osintvm/ff-template.zip || echo "WARNING: Failed to download Firefox template."
    if [ -f "ff-template.zip" ]; then
      unzip -o ff-template.zip -d ~/.mozilla/firefox/ || echo "WARNING: Failed to unzip Firefox template."
      PROFILE_DIR=$(find ~/.mozilla/firefox/ -maxdepth 1 -type d -name "*.default-esr*")
      if [ -n "$PROFILE_DIR" ] && [ -d "$HOME/.mozilla/firefox/ff-template" ]; then
          cp -R "$HOME/.mozilla/firefox/ff-template/"* "$PROFILE_DIR/" || echo "WARNING: Failed to copy Firefox profile files."
      else
          echo "WARNING: Firefox profile directory not found or template dir missing."
      fi
      rm -rf "$HOME/.mozilla/firefox/ff-template" "$HOME/ff-template.zip"
    fi

    echo "--> Installing Brave Browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser || true

    echo "--> Installing Tor Browser..."
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    flatpak install --user flathub org.torproject.torbrowser-launcher -y || true
    # L'originale eseguiva 'flatpak run org.torproject.torbrowser-launcher' qui.
    # Potrebbe essere necessario per la prima configurazione, ma causa interattività.
    # Lo commentiamo per mantenere lo script non interattivo.
    # flatpak run org.torproject.torbrowser-launcher

    echo "--> Installing Google Earth..."
    cd "$HOME/Downloads"
    # Assicurati che wget non sia silenziato per vedere errori
    wget http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
    sudo apt install -y ./google-earth-stable_current_amd64.deb || true
    # La rimozione del .deb avverrà nella fase di cleanup

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
    install_py_tool_from_git "https://github.com/smicallef/spiderfoot" # Ricorda che fallisce per lxml
    install_py_tool_from_git "https://github.com/lanmaster53/recon-ng" "REQUIREMENTS"

    echo "--> Handling tools with special configurations..."
    # Configurazione h8mail
    cd "$HOME/Downloads"
    "$HOME/.local/bin/h8mail" -g || true
    [ -f "$HOME/h8mail_config.ini" ] && sed -i 's/\;leak\-lookup\_pub/leak\-lookup\_pub/g' "$HOME/h8mail_config.ini" || true

    # Installazione sn0int
    echo "--> Installing sn0int (official APT method)..."
    curl -sSLf https://apt.vulns.sexy/kpcyrd.pgp | sq packet dearmor | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null
    echo "deb http://apt.vulns.sexy stable main" | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list > /dev/null
    sudo apt update
    sudo apt install -y sn0int || true

    # Installazione theHarvester
    echo "--> Installing theHarvester (official method)..."
    if ! command -v uv >/dev/null 2>&1; then
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    export PATH="$HOME/.local/bin:$PATH"
    source "$HOME/.cargo/env" # Assicurati che uv sia nel PATH della sessione corrente
    cd "$PROGRAMS_DIR"
    if [ ! -d "theHarvester" ]; then
        git clone https://github.com/laramies/theHarvester.git || true
    fi
    cd theHarvester || echo "WARNING: theHarvester directory not found."
    "$HOME/.local/bin/uv" sync || echo "WARNING: 'uv sync' failed for theHarvester."

    # Installazione Amass
    echo "--> Installing Amass (via Go)..."
    go install -v github.com/owasp-amass/amass/v4/...@master || echo "WARNING: Failed to install Amass."
    export PATH=$(go env GOPATH)/bin:$PATH
    source "$HOME/.profile" # Assicura che GOPATH/bin sia nel PATH

    # Clonazione Mr.Holmes (senza installazione dipendenze per ora)
    cd "$PROGRAMS_DIR"
    if [ ! -d "Mr.Holmes" ]; then
        git clone https://github.com/Lucksi/Mr.Holmes || true
    fi

    # ###############################################################
    # PHASE 4a: ORIGINAL SCRIPTS/LAUNCHERS SETUP
    # ###############################################################
    echo "--- PHASE 4a: Original Scripts and Launchers Integration ---"
    # Questa sezione replica i comandi dello script originale per script, icone, e launchers

    mkdir -p ~/Documents/scripts
    cd ~/Documents/scripts || echo "WARNING: Could not cd into ~/Documents/scripts"

    # Scarica script, launchers, e icone
    curl -O https://tuvm:311@inteltechniques.com/osintvm/api.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/domain.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/framework.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/image.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/metadata.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/update.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/user.sh || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/video.sh || true
    chmod +x *.sh || true

    curl -O https://tuvm:311@inteltechniques.com/osintvm/api.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/domain.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/framework.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/image.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/metadata.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/search.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/update.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/user.desktop || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/video.desktop || true

    curl -O https://tuvm:311@inteltechniques.com/osintvm/api.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/domain.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/framework.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/image.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/metadata.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/search.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/update.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/user.png || true
    curl -O https://tuvm:311@inteltechniques.com/osintvm/video.png || true

    # Sposta i file .desktop nella posizione di sistema
    sudo mv *.desktop /usr/share/applications/ || true

    # Imposta le applicazioni preferite (questo sovrascrive quelle predefinite)
    gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.torproject.torbrowser-launcher.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'update.desktop', 'search.desktop', 'video.desktop', 'user.desktop', 'image.desktop', 'domain.desktop', 'metadata.desktop', 'framework.desktop', 'api.desktop', 'google-earth-pro.desktop', 'kazam.desktop', 'org.gnome.Settings.desktop']" || true

    # ###############################################################
    # PHASE 5a: APPLY ORIGINAL GNOME LOOK AND FEEL
    # ###############################################################
    echo "--- PHASE 5a: Apply Original GNOME Look and Feel ---"
    # Questa sezione replica le impostazioni gsettings e dash-to-dock dello script originale

    # Installa gnome-extensions-cli se mancante (anche se dovrebbe essere già stato installato)
    # Lo script originale lo faceva con pip3 globale dopo aver rimosso EXTERNALLY-MANAGED,
    # qui usiamo apt che è più pulito per Debian 13+.
    sudo apt install -y gnome-extensions-cli || true
    tput reset && source "$HOME/.profile" || true # Ricarica profilo come nell'originale

    # Configurazione Dash-to-Dock (metodo originale, usa gnome-extensions-cli e gsettings con schema locale)
    # Nota: L'installazione potrebbe fallire se già presente, ignoriamo l'errore.
    # gnome-extensions-cli install dash-to-dock@micxgx.gmail.com || true # Già installato da apt
    gnome-extensions enable dash-to-dock@micxgx.gmail.com || echo "WARNING: Failed to enable dash-to-dock (expected on first run)."
    # Usa il percorso dello schema locale come nell'originale, potrebbe non essere necessario con l'installazione apt
    SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/"
    if [ -d "$SCHEMA_DIR" ]; then
        SCHEMA_PATH_ARG="--schemadir $SCHEMA_DIR"
    else
        # Fallback allo schema di sistema se quello locale non esiste (installazione apt)
        SCHEMA_PATH_ARG=""
        echo "INFO: Using system schema for dash-to-dock as local schema dir not found."
    fi
    SCHEMA_DOCK="org.gnome.shell.extensions.dash-to-dock"
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK autohide false || true
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK autohide-in-fullscreen false || true
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK intellihide false || true
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK dash-max-icon-size 32 || true
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK dock-fixed true || true
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK dock-position 'LEFT' || true
    gsettings $SCHEMA_PATH_ARG set $SCHEMA_DOCK extend-height true || true
    # L'originale installava anche l'estensione n. 2087, che potrebbe essere "user themes" o altro. Lo omettiamo per ora.
    # gnome-extensions-cli install 2087 || true

    # Rimuovi eventuali file .desktop dal Desktop
    rm -f "$HOME/Desktop/*.desktop" || true

    # Impostazioni GNOME originali
    gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark' || true
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close" || true
    gsettings set org.gnome.desktop.background picture-uri '' || true
    gsettings set org.gnome.desktop.background picture-uri-dark '' || true
    gsettings set org.gnome.desktop.background primary-color 'rgb(66, 81, 100)' || true
    gsettings set org.gnome.desktop.notifications show-banners false || true
    gsettings set org.gnome.desktop.session idle-delay 0 || true
    sudo systemctl mask suspend.target || true
    gsettings set org.gnome.desktop.screensaver lock-enabled false || true
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true || true
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true || true
    gsettings set org.gnome.mutter center-new-windows true || true

    # ###############################################################
    # PHASE 6: FINAL CLEANUP
    # ###############################################################
    echo "--- PHASE 6: Finalizing and Cleaning Up ---"

    sudo apt update
    sudo apt upgrade -y
    sudo apt --fix-broken install -y
    sudo apt autoremove -y

    echo "--> Removing temporary files..."
    rm -f "$HOME/Downloads/google-earth-stable_current_amd64.deb"
    # ff-template.zip già rimosso nella fase 2

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
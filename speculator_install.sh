#!/usr/bin/env bash

# ###############################################################
# # SPECULATOR PROJECT - OSINT VM INSTALLATION SCRIPT
# # Version: 8.0 (Phase A - Structural Fixes)
# # Target:  Debian 13 "Trixie" (amd64)
# # Language Support: Italian, English, Russian, Chinese
# ###############################################################
#
# USAGE:
#   sudo ./speculator_install.sh              # Normal installation
#   sudo ./speculator_install.sh --dry-run    # Simulate without installing
#   INTEL_USER=x INTEL_PASS=y sudo ./speculator_install.sh
# ###############################################################


# ---------------------------------------------------------------
# ARGUMENT PARSING
# ---------------------------------------------------------------
DRY_RUN=false
for _arg in "$@"; do
    case "$_arg" in
        --dry-run) DRY_RUN=true ;;
        --help|-h)
            echo "Usage: sudo $0 [--dry-run]"
            echo "  --dry-run   Simulate installation without making any changes."
            exit 0
            ;;
    esac
done


# ---------------------------------------------------------------
# INTEL TECHNIQUES CREDENTIALS
# Provided with "OSINT Techniques" book by Michael Bazzell.
# Override at runtime:
#   INTEL_USER=xxx INTEL_PASS=yyy sudo ./speculator_install.sh
# ---------------------------------------------------------------
INTEL_USER="${INTEL_USER:-tuvm}"
INTEL_PASS="${INTEL_PASS:-311}"


# ---------------------------------------------------------------
# USER DETECTION (sudo-safe)
# When invoked via sudo, target the invoking user, not root.
# ---------------------------------------------------------------
if [ -n "${SUDO_USER:-}" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="${USER:-$(id -un)}"
    REAL_HOME="${HOME:-$(getent passwd "$(id -un)" | cut -d: -f6)}"
fi


# ---------------------------------------------------------------
# XDG-COMPLIANT DIRECTORY STRUCTURE
# ---------------------------------------------------------------
PROGRAMS_DIR="$REAL_HOME/Downloads/Programs"
LOG_DIR="$REAL_HOME/.local/share/speculator/logs"
SCRIPTS_DIR="$REAL_HOME/.local/share/speculator/scripts"
ICONS_DIR="$REAL_HOME/.local/share/icons/speculator"
DESKTOP_DIR="$REAL_HOME/.local/share/applications"
CONFIG_DIR="$REAL_HOME/.config/speculator"
LOG_FILE="$LOG_DIR/install_$(date +%Y-%m-%d_%H-%M-%S).log"


# ---------------------------------------------------------------
# DRY-RUN MODE
# When --dry-run is active, dangerous commands are intercepted and
# printed instead of executed. Safe read-only operations run normally
# so logic flow can be validated.
# ---------------------------------------------------------------
if [ "$DRY_RUN" = "true" ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  DRY-RUN MODE — No changes will be made to the system   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""

    # Override run_as_user: print the command instead of running it
    run_as_user() { echo "  [DRY-RUN | user:${REAL_USER}] $*"; }

    # Override sudo: print system-level commands
    sudo() { echo "  [DRY-RUN | sudo] $*"; }

    # Override pipx, git, go, flatpak, wget, curl (for download side-effects)
    pipx()     { echo "  [DRY-RUN | pipx] $*"; }
    git()      { echo "  [DRY-RUN | git] $*"; }
    go()       { echo "  [DRY-RUN | go] $*"; }
    flatpak()  { echo "  [DRY-RUN | flatpak] $*"; }
    wget()     { echo "  [DRY-RUN | wget] $*"; }
    curl()     { echo "  [DRY-RUN | curl] $*"; }
    gsettings(){ echo "  [DRY-RUN | gsettings] $*"; }
    systemctl(){ echo "  [DRY-RUN | systemctl] $*"; }
    pkill()    { echo "  [DRY-RUN | pkill] $*"; }
    chown()    { echo "  [DRY-RUN | chown] $*"; }
    cp()       { echo "  [DRY-RUN | cp] $*"; }
    mkdir()    { echo "  [DRY-RUN | mkdir] $*"; }

    # mark_ok/mark_fail still work normally — tracking is always active
    # gnome-shell/pgrep run normally so version detection can be tested
fi


# ---------------------------------------------------------------
# DEBIAN DETECTION
# Exits immediately if the system is not Debian-based.
# ---------------------------------------------------------------
check_debian() {
    if [ ! -f /etc/debian_version ]; then
        if [ "$DRY_RUN" = "true" ]; then
            echo "[DRY-RUN] WARNING: /etc/debian_version not found."
            echo "[DRY-RUN] On a real run this would abort. Continuing simulation..."
            return 0
        fi
        echo ""
        echo "##################################################################"
        echo "# ERROR: Non-Debian system detected.                            #"
        echo "# The Speculator Project is designed exclusively for Debian.    #"
        echo "# Please install on Debian 13 'Trixie' (amd64).                #"
        echo "##################################################################"
        echo ""
        exit 1
    fi

    local debian_version
    debian_version=$(cat /etc/debian_version)
    echo "--> Debian detected: $debian_version"

    # Warn if not Trixie (13.x), but continue — allows bookworm (12.x) users to try
    if [[ "$debian_version" != 13* ]] && [[ "$debian_version" != "trixie"* ]]; then
        echo ""
        echo "WARNING: This script targets Debian 13 'Trixie'."
        echo "WARNING: Detected version: $debian_version"
        echo "WARNING: Some packages may not be available. Proceeding in 5s..."
        echo ""
        [ "$DRY_RUN" = "false" ] && sleep 5
    fi
}


# ---------------------------------------------------------------
# HELPER: Run a command as the real (non-root) user
# ---------------------------------------------------------------
run_as_user() {
    if [ "$(id -u)" -eq 0 ] && [ "$REAL_USER" != "root" ]; then
        sudo -u "$REAL_USER" -- "$@"
    else
        "$@"
    fi
}


# ---------------------------------------------------------------
# INSTALLATION TRACKING
# Records which components installed successfully and which failed.
# ---------------------------------------------------------------
_INSTALL_OK=()
_INSTALL_FAIL=()

mark_ok()   { _INSTALL_OK+=("$1"); }
mark_fail() { _INSTALL_FAIL+=("$1"); echo "FAIL: $1"; }

# Run a command and record result under a given label.
# Usage: tracked "label" command [args...]
tracked() {
    local label="$1"; shift
    if "$@" 2>&1; then
        mark_ok "$label"
    else
        mark_fail "$label"
    fi
}


# ---------------------------------------------------------------
# HELPER: Install a Python tool from a Git repository
# Uses a dedicated venv per tool; does NOT require venv activation
# ---------------------------------------------------------------
install_py_tool_from_git() {
    local repo_url="$1"
    local req_filename="${2:-requirements.txt}"
    local tool_name
    tool_name=$(basename "$repo_url" .git)
    local tool_dir="$PROGRAMS_DIR/$tool_name"
    local venv_dir="$tool_dir/${tool_name}Environment"

    echo "--> Installing $tool_name..."

    if [ ! -d "$tool_dir" ]; then
        if ! run_as_user git clone "$repo_url" "$tool_dir"; then
            echo "WARNING: Failed to clone $tool_name. Skipping."
            mark_fail "git:$tool_name"
            return 0
        fi
    else
        echo "    $tool_name already cloned, skipping clone."
    fi

    # Locate requirements file (up to 3 levels deep)
    local full_req_path
    full_req_path=$(find "$tool_dir" -maxdepth 3 -name "$req_filename" -print -quit 2>/dev/null)

    if [ -z "$full_req_path" ]; then
        echo "WARNING: '$req_filename' not found in $tool_name. Skipping pip install."
        mark_fail "git:$tool_name"
        return 0
    fi

    # Apply known patches before installing
    if [ "$tool_name" = "spiderfoot" ]; then
        echo "    Patch: removing lxml from SpiderFoot requirements..."
        sed -i "/lxml/d" "$full_req_path" || true
    fi

    # Create venv and install dependencies (no activation needed — use venv pip directly)
    if ! run_as_user python3 -m venv --system-site-packages "$venv_dir"; then
        echo "WARNING: Failed to create venv for $tool_name."
        mark_fail "git:$tool_name"
        return 0
    fi

    if run_as_user "$venv_dir/bin/pip" install --quiet -r "$full_req_path"; then
        mark_ok "git:$tool_name"
    else
        echo "WARNING: pip install failed for $tool_name (non-fatal)."
        mark_fail "git:$tool_name"
    fi
}


# ===============================================================
# PRE-FLIGHT CHECKS
# ===============================================================
check_debian

# Create all required directories before redirecting output
# In dry-run the log dir must still exist for tee to work
command mkdir -p "$LOG_DIR" "$PROGRAMS_DIR" "$SCRIPTS_DIR" "$ICONS_DIR" "$DESKTOP_DIR" "$CONFIG_DIR"

# Fix ownership if directories were created as root
if [ "$(id -u)" -eq 0 ] && [ "$REAL_USER" != "root" ]; then
    chown -R "$REAL_USER:$REAL_USER" \
        "$REAL_HOME/.local" \
        "$REAL_HOME/.config" \
        "$PROGRAMS_DIR" 2>/dev/null || true
fi

# Start logging — everything below is captured to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

{
    echo "#################################################################"
    echo "# SPECULATOR PROJECT - OSINT VM INSTALLATION SCRIPT v8.0       #"
    echo "# Target: Debian 13 Trixie (amd64)                             #"
    echo "#################################################################"
    echo "# Real user : $REAL_USER"
    echo "# Home      : $REAL_HOME"
    echo "# Programs  : $PROGRAMS_DIR"
    echo "# Log       : $LOG_FILE"
    echo "#################################################################"
    echo ""


    # ###############################################################
    # PHASE 1: SYSTEM PREPARATION
    # ###############################################################
    echo "--- PHASE 1: System Preparation and Dependencies ---"

    sudo apt update

    echo "--> Installing system packages (one-by-one for resilience)..."
    PACKAGES=(
        # Core build tools
        gnupg curl wget git pipx flatpak unzip build-essential
        pkg-config libsodium-dev golang-go
        # Locale and fonts (IT + RU + ZH + EN base)
        locales-all fonts-noto-core
        # Italian
        firefox-esr-l10n-it libreoffice-l10n-it manpages-it
        # Russian (manpages-ru not available in Debian repos)
        firefox-esr-l10n-ru libreoffice-l10n-ru
        # Chinese Simplified
        firefox-esr-l10n-zh-cn libreoffice-l10n-zh-cn
        fonts-wqy-zenhei ibus-pinyin
        # Python
        python3-venv python3-pip python3-testresources python3-lxml
        libxml2-dev libxslt1-dev
        # Multimedia
        vlc ffmpeg
        # OSINT system tools
        default-jre httrack webhttrack libimage-exiftool-perl
        mediainfo-gui mat2 subversion
        # Desktop / utilities
        kazam bleachbit libxcb-cursor0 docker.io
        # GNOME extensions
        gnome-shell-extensions gnome-shell-extension-manager
        gnome-shell-extension-dash-to-dock
    )
    for pkg in "${PACKAGES[@]}"; do
        sudo apt install -y "$pkg" || echo "WARNING: Failed to install '$pkg', continuing..."
    done

    # sq (sequoia-sq) — used for GPG key dearmoring; fall back to gpg if unavailable
    sudo apt install -y sq || echo "INFO: 'sq' not available; sn0int install will use gpg --dearmor fallback."

    # Refresh shell's command hash table so newly installed binaries are found
    hash -r 2>/dev/null || true

    # Ensure pipx tools and Go binaries are accessible
    run_as_user pipx ensurepath || true
    REAL_GOPATH=$(run_as_user go env GOPATH 2>/dev/null || echo "$REAL_HOME/go")
    export PATH="$REAL_HOME/.local/bin:$REAL_GOPATH/bin:$PATH"


    # ###############################################################
    # PHASE 2: CORE APPLICATIONS
    # ###############################################################
    echo "--- PHASE 2: Core Applications ---"

    # -- Firefox ESR: profile template --
    echo "--> Configuring Firefox ESR..."
    pkill -f firefox-esr || true
    # Wait up to 10s for Firefox to fully terminate before touching its profile
    # pgrep may not be installed on minimal Debian images
    if command -v pgrep >/dev/null 2>&1; then
        for _i in {1..10}; do
            pgrep -f firefox-esr >/dev/null || break
            sleep 1
        done
    else
        sleep 3
    fi
    run_as_user curl -fsSL -o "$REAL_HOME/ff-template.zip" \
        "https://inteltechniques.com/data/osintvm/ff-template.zip" \
        || echo "WARNING: Firefox template download failed."
    # Check both existence AND non-empty size to catch failed downloads
    if [ -f "$REAL_HOME/ff-template.zip" ] && [ -s "$REAL_HOME/ff-template.zip" ]; then
        run_as_user unzip -o "$REAL_HOME/ff-template.zip" \
            -d "$REAL_HOME/.mozilla/firefox/" || echo "WARNING: Firefox template unzip failed."
        # Find the default profile via profiles.ini (more reliable than glob)
        PROFILE_DIR=""
        _PROFILES_INI="$REAL_HOME/.mozilla/firefox/profiles.ini"
        if [ -f "$_PROFILES_INI" ]; then
            _DEFAULT_PROFILE=$(awk -F= '/^\[/{sect=$0} /^Default=1/{in_default=1} in_default && /^Path=/{print $2; exit}' "$_PROFILES_INI" || true)
            [ -n "$_DEFAULT_PROFILE" ] && PROFILE_DIR="$REAL_HOME/.mozilla/firefox/$_DEFAULT_PROFILE"
        fi
        # Fallback to glob if profiles.ini approach failed
        if [ -z "$PROFILE_DIR" ] || [ ! -d "$PROFILE_DIR" ]; then
            PROFILE_DIR=$(find "$REAL_HOME/.mozilla/firefox/" -maxdepth 1 -type d \
                -name "*.default-esr*" 2>/dev/null | head -1)
        fi
        if [ -n "$PROFILE_DIR" ] && [ -d "$REAL_HOME/.mozilla/firefox/ff-template" ]; then
            cp -R "$REAL_HOME/.mozilla/firefox/ff-template/"* "$PROFILE_DIR/" \
                || echo "WARNING: Firefox profile copy failed."
        fi
        rm -rf "$REAL_HOME/.mozilla/firefox/ff-template" "$REAL_HOME/ff-template.zip"
    fi

    # -- Brave Browser --
    echo "--> Installing Brave Browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    if sudo apt install -y brave-browser; then
        mark_ok "app:brave-browser"
    else
        echo "WARNING: Brave Browser install failed."
        mark_fail "app:brave-browser"
    fi

    # -- Tor Browser (Flatpak) --
    echo "--> Installing Tor Browser..."
    run_as_user flatpak remote-add --user --if-not-exists flathub \
        "https://dl.flathub.org/repo/flathub.flatpakrepo" || true
    if run_as_user flatpak install --user flathub org.torproject.torbrowser-launcher -y; then
        mark_ok "app:tor-browser"
    else
        echo "WARNING: Tor Browser install failed."
        mark_fail "app:tor-browser"
    fi

    # -- Google Earth Pro --
    echo "--> Installing Google Earth Pro..."
    curl -fsSL "https://dl.google.com/linux/linux_signing_key.pub" \
        | gpg --dearmor \
        | sudo tee /etc/apt/trusted.gpg.d/google-linux-signing-key.gpg > /dev/null
    run_as_user wget -q -O "$REAL_HOME/Downloads/google-earth-stable_current_amd64.deb" \
        "https://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb" \
        || echo "WARNING: Google Earth download failed."
    if [ -f "$REAL_HOME/Downloads/google-earth-stable_current_amd64.deb" ]; then
        if sudo apt install -y "$REAL_HOME/Downloads/google-earth-stable_current_amd64.deb"; then
            mark_ok "app:google-earth-pro"
        else
            echo "WARNING: Google Earth install failed."
            mark_fail "app:google-earth-pro"
        fi
    else
        mark_fail "app:google-earth-pro"
    fi


    # ###############################################################
    # PHASE 3: OSINT TOOLS
    # ###############################################################
    echo "--- PHASE 3: OSINT Tools ---"

    # -- 3a. pipx tools --
    echo "--> Installing tools via pipx..."
    # archivebox requires native deps that must be present before the pipx install
    echo "    Pre-installing archivebox native dependencies..."
    sudo apt install -y python3-dev libxml2-dev libxslt1-dev zlib1g-dev \
        ripgrep wget curl chromium nodejs npm || true

    PIPX_PACKAGES=(
        yt-dlp
        streamlink
        socialscan
        bdfr
        holehe
        ghunt
        h8mail
        search-that-hash
        name-that-hash
        gallery-dl
        instaloader
        toutatis
        waybackpy
        waybackpack
        "changedetection.io"
        archivebox
        xeuledoc
        internetarchive
        maigret
        sherlock-project
        ignorant
        shodan
        fierce
        censys
    )
    for pkg in "${PIPX_PACKAGES[@]}"; do
        if run_as_user pipx install "$pkg"; then
            mark_ok "pipx:$pkg"
        else
            echo "WARNING: pipx install failed for '$pkg'"
            mark_fail "pipx:$pkg"
        fi
    done

    # Refresh PATH after pipx installs
    export PATH="$REAL_HOME/.local/bin:$PATH"

    # -- 3b. Python tools from Git (isolated venvs) --
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
    install_py_tool_from_git "https://github.com/lanmaster53/recon-ng" "requirements.txt"

    # -- 3c. h8mail configuration --
    echo "--> Configuring h8mail..."
    run_as_user "$REAL_HOME/.local/bin/h8mail" -g || true
    H8MAIL_CONFIG="$REAL_HOME/h8mail_config.ini"
    if [ -f "$H8MAIL_CONFIG" ]; then
        sed -i 's/\;leak\-lookup\_pub/leak\-lookup\_pub/g' "$H8MAIL_CONFIG" || true
        cp "$H8MAIL_CONFIG" "$CONFIG_DIR/h8mail_config.ini" || true
    fi

    # -- 3d. sn0int (signed APT repo, with sq/gpg fallback) --
    echo "--> Installing sn0int..."
    if command -v sq >/dev/null 2>&1; then
        curl -sSLf "https://apt.vulns.sexy/kpcyrd.pgp" | sq packet dearmor \
            | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null
    else
        curl -sSLf "https://apt.vulns.sexy/kpcyrd.pgp" | gpg --dearmor \
            | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null
    fi
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg] https://apt.vulns.sexy stable main" \
        | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list > /dev/null
    sudo apt update
    if sudo apt install -y sn0int; then
        mark_ok "apt:sn0int"
    else
        echo "WARNING: sn0int install failed."
        mark_fail "apt:sn0int"
    fi

    # -- 3e. theHarvester (via uv) --
    echo "--> Installing theHarvester..."
    # Check for uv binary directly — 'command -v' does not work well inside run_as_user
    if [ ! -f "$REAL_HOME/.local/bin/uv" ]; then
        # Run curl+pipe inside a single sudo call to avoid pipe/stdin issues
        run_as_user bash -c "curl -LsSf 'https://astral.sh/uv/install.sh' | sh"
        export PATH="$REAL_HOME/.local/bin:$PATH"
    fi
    # Source cargo env only if present AND we are not root (avoids env pollution as root)
    if [ "$(id -u)" -ne 0 ] && [ -f "$REAL_HOME/.cargo/env" ]; then
        source "$REAL_HOME/.cargo/env" || true
    fi
    if [ ! -d "$PROGRAMS_DIR/theHarvester" ]; then
        run_as_user git clone "https://github.com/laramies/theHarvester.git" \
            "$PROGRAMS_DIR/theHarvester" || echo "WARNING: theHarvester clone failed."
    fi
    if [ -d "$PROGRAMS_DIR/theHarvester" ]; then
        # 'uv --project <path> sync' is the correct syntax (--project is a global flag)
        if run_as_user "$REAL_HOME/.local/bin/uv" --project "$PROGRAMS_DIR/theHarvester" sync; then
            mark_ok "git:theHarvester"
        else
            echo "WARNING: 'uv sync' failed for theHarvester."
            mark_fail "git:theHarvester"
        fi
    else
        mark_fail "git:theHarvester"
    fi

    # -- 3f. Go-based tools --
    echo "--> Installing Go-based tools..."
    # Run go installs as the real user so binaries land in their GOPATH
    tracked "go:amass"       run_as_user go install -v "github.com/owasp-amass/amass/v4/...@latest"
    tracked "go:subfinder"   run_as_user go install -v "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    tracked "go:httpx"       run_as_user go install -v "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    tracked "go:nuclei"      run_as_user go install -v "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    tracked "go:phoneinfoga" run_as_user go install -v "github.com/sundowndev/phoneinfoga/v2@latest"

    # Ensure Go binaries are in PATH for subsequent commands
    REAL_GOPATH=$(run_as_user go env GOPATH 2>/dev/null || echo "$REAL_HOME/go")
    export PATH="$REAL_GOPATH/bin:$PATH"
    # Persist GOPATH in user's profile (marker prevents duplicate entries)
    _PROFILE_MARKER="# speculator-project: Go and pipx PATH"
    if ! grep -qF "$_PROFILE_MARKER" "$REAL_HOME/.profile" 2>/dev/null; then
        printf '\n%s\nexport PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"\n' \
            "$_PROFILE_MARKER" >> "$REAL_HOME/.profile"
    fi

    # -- 3g. Mr.Holmes (git clone, no deps to install) --
    echo "--> Cloning Mr.Holmes..."
    if [ ! -d "$PROGRAMS_DIR/Mr.Holmes" ]; then
        if run_as_user git clone "https://github.com/Lucksi/Mr.Holmes" "$PROGRAMS_DIR/Mr.Holmes"; then
            mark_ok "git:Mr.Holmes"
        else
            echo "WARNING: Mr.Holmes clone failed."
            mark_fail "git:Mr.Holmes"
        fi
    else
        mark_ok "git:Mr.Holmes"
    fi


    # ###############################################################
    # PHASE 4: LAUNCHERS AND SCRIPTS
    # (Downloaded from IntelTechniques; custom versions will replace
    #  these in a future release.)
    # ###############################################################
    echo "--- PHASE 4: Scripts and Launchers ---"

    INTEL_BASE="https://${INTEL_USER}:${INTEL_PASS}@inteltechniques.com/osintvm"
    SCRIPT_NAMES=(api domain framework image metadata update user video)

    # Helper: download and validate — removes file if empty or HTML error page
    _download_asset() {
        local dest="$1" url="$2"
        run_as_user curl -fsSL --retry 3 -o "$dest" "$url" || true
        if [ -f "$dest" ]; then
            if [ ! -s "$dest" ]; then
                echo "WARNING: Downloaded file is empty: $dest (removing)"
                rm -f "$dest"
            elif head -c 15 "$dest" 2>/dev/null | grep -qi "<!DOCTYPE\|<html"; then
                echo "WARNING: $dest looks like an HTML page (wrong credentials?). Removing."
                rm -f "$dest"
            fi
        fi
    }

    echo "--> Downloading IntelTechniques scripts, desktop files, and icons..."
    for name in "${SCRIPT_NAMES[@]}"; do
        _download_asset "$SCRIPTS_DIR/${name}.sh"      "${INTEL_BASE}/${name}.sh"
        [ -f "$SCRIPTS_DIR/${name}.sh" ] \
            || echo "WARNING: Failed to download ${name}.sh"
        _download_asset "$DESKTOP_DIR/speculator-${name}.desktop" \
            "${INTEL_BASE}/${name}.desktop"
        _download_asset "$ICONS_DIR/speculator-${name}.png" \
            "${INTEL_BASE}/${name}.png"
    done

    # search has a desktop/icon but no standalone .sh
    _download_asset "$DESKTOP_DIR/speculator-search.desktop" "${INTEL_BASE}/search.desktop"
    _download_asset "$ICONS_DIR/speculator-search.png"       "${INTEL_BASE}/search.png"

    chmod +x "$SCRIPTS_DIR/"*.sh 2>/dev/null || true

    # Install desktop files system-wide so GNOME picks them up
    sudo cp "$DESKTOP_DIR"/speculator-*.desktop /usr/share/applications/ 2>/dev/null || true
    sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true

    # Set GNOME dock favourites (best-effort; may fail outside a GUI session)
    _GNOME_FAVS="['firefox-esr.desktop', 'org.torproject.torbrowser-launcher.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'speculator-update.desktop', 'speculator-search.desktop', 'speculator-video.desktop', 'speculator-user.desktop', 'speculator-image.desktop', 'speculator-domain.desktop', 'speculator-metadata.desktop', 'speculator-framework.desktop', 'speculator-api.desktop', 'google-earth-pro.desktop', 'kazam.desktop', 'org.gnome.Settings.desktop']"
    run_as_user gsettings set org.gnome.shell favorite-apps "$_GNOME_FAVS" \
        || echo "INFO: Could not set GNOME favorites (expected if outside a GUI session)."


    # ###############################################################
    # PHASE 5: GNOME LOOK AND FEEL
    # (Skipped automatically if GNOME 40+ is not detected)
    # ###############################################################
    echo "--- PHASE 5: GNOME Look and Feel ---"

    # Use POSIX grep -o (no -P flag) for compatibility with minimal Debian installs
    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -o '[0-9]*' | head -1 || echo "0")
    if [ "$GNOME_VERSION" -ge 40 ]; then
        echo "--> GNOME $GNOME_VERSION detected. Applying configuration..."

        sudo apt install -y gnome-extensions-cli || true

        # gnome-extensions enable requires a running gnome-shell session
        if command -v pgrep >/dev/null 2>&1 && pgrep -x gnome-shell >/dev/null 2>&1; then
            run_as_user gnome-extensions enable "dash-to-dock@micxgx.gmail.com" \
                || echo "WARNING: Could not enable dash-to-dock extension."
        else
            echo "INFO: gnome-shell not running; dash-to-dock will be enabled on next login."
        fi

        SCHEMA_DOCK="org.gnome.shell.extensions.dash-to-dock"
        LOCAL_SCHEMA="$REAL_HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/"
        # Use an array to safely handle paths with spaces and avoid word splitting
        SCHEMA_ARGS=()
        [ -d "$LOCAL_SCHEMA" ] && SCHEMA_ARGS=(--schemadir "$LOCAL_SCHEMA")

        # gsettings requires a D-Bus session; skip silently if not in a GUI session
        if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ] || [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK autohide false || true
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK autohide-in-fullscreen false || true
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK intellihide false || true
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK dash-max-icon-size 32 || true
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK dock-fixed true || true
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK dock-position 'LEFT' || true
            run_as_user gsettings "${SCHEMA_ARGS[@]}" set $SCHEMA_DOCK extend-height true || true

            run_as_user gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark' || true
            run_as_user gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close" || true
            run_as_user gsettings set org.gnome.desktop.background picture-uri '' || true
            run_as_user gsettings set org.gnome.desktop.background picture-uri-dark '' || true
            run_as_user gsettings set org.gnome.desktop.background primary-color 'rgb(66, 81, 100)' || true
            run_as_user gsettings set org.gnome.desktop.notifications show-banners false || true
            run_as_user gsettings set org.gnome.desktop.session idle-delay 0 || true
            run_as_user gsettings set org.gnome.desktop.screensaver lock-enabled false || true
            run_as_user gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true || true
            run_as_user gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true || true
            run_as_user gsettings set org.gnome.mutter center-new-windows true || true
        else
            echo "INFO: No D-Bus/display session detected. gsettings will be applied on first login."
        fi
        sudo systemctl mask suspend.target || true

        rm -f "$REAL_HOME/Desktop/"*.desktop 2>/dev/null || true
    else
        echo "INFO: GNOME 40+ not detected (found: $GNOME_VERSION). Skipping GNOME configuration."
    fi


    # ###############################################################
    # PHASE 6: FINAL CLEANUP
    # ###############################################################
    echo "--- PHASE 6: Finalizing and Cleaning Up ---"

    sudo apt update
    sudo apt upgrade -y
    sudo apt --fix-broken install -y
    sudo apt autoremove -y

    rm -f "$REAL_HOME/Downloads/google-earth-stable_current_amd64.deb" 2>/dev/null || true

    # Restore ownership of user directories in case root wrote to them
    if [ "$(id -u)" -eq 0 ] && [ "$REAL_USER" != "root" ]; then
        chown -R "$REAL_USER:$REAL_USER" \
            "$REAL_HOME/.local" \
            "$REAL_HOME/.config" \
            "$PROGRAMS_DIR" 2>/dev/null || true
    fi


    # ###############################################################
    # COMPLETION SUMMARY
    # ###############################################################
    echo ""
    echo "###############################################################"
    echo "# INSTALLATION COMPLETE                                       #"
    echo "###############################################################"
    echo "# User     : $REAL_USER"
    echo "# Programs : $PROGRAMS_DIR"
    echo "# Scripts  : $SCRIPTS_DIR"
    echo "# Log      : $LOG_FILE"
    echo "#"
    echo "# A system REBOOT is strongly recommended."
    echo "###############################################################"
    echo ""

    # --- Structured results report ---
    # NOTE: 'local' is invalid outside functions in bash — use plain assignments
    ok_count=${#_INSTALL_OK[@]}
    fail_count=${#_INSTALL_FAIL[@]}
    total=$(( ok_count + fail_count ))

    echo "┌─────────────────────────────────────────────────────────────┐"
    printf  "│  RESULTS: %d/%d components installed successfully           │\n" \
        "$ok_count" "$total"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [ "$ok_count" -gt 0 ]; then
        echo "│  OK  ✓"
        for item in "${_INSTALL_OK[@]}"; do
            printf "│      %-54s│\n" "$item"
        done
    fi

    if [ "$fail_count" -gt 0 ]; then
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│  FAILED  ✗  (review log for details)"
        for item in "${_INSTALL_FAIL[@]}"; do
            printf "│      %-54s│\n" "$item"
        done
    else
        echo "│  No failures detected.                                      │"
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
    echo "Full log: $LOG_FILE"
    echo ""

}

# Write machine-readable results file OUTSIDE the tee'd block to avoid
# double-redirect conflicts with 'exec > >(tee ...)'
RESULT_FILE="$LOG_DIR/install_results_$(date +%Y-%m-%d_%H-%M-%S).txt"
{
    echo "ok_count=$ok_count"
    echo "fail_count=$fail_count"
    echo "total=$total"
    echo ""
    echo "[ok]"
    for item in "${_INSTALL_OK[@]}";   do echo "$item"; done
    echo ""
    echo "[failed]"
    for item in "${_INSTALL_FAIL[@]}"; do echo "$item"; done
} > "$RESULT_FILE"
echo "Results file: $RESULT_FILE"

exit 0

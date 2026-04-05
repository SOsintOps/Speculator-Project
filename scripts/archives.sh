#!/usr/bin/env bash
# archives.sh — Zenity GUI launcher for web archive tools
# Version: 0.1.0 | Phase B
# Part of the Speculator Project OSINT environment
# Target OS: Debian 13 "Trixie" amd64

set -uo pipefail
[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

# ---------------------------------------------------------------------------
# run_waybackpy
# Lists all known URLs in the Wayback Machine for the given URL.
# ---------------------------------------------------------------------------
run_waybackpy() {
    local url="$1"
    local target="$2"
    local sessionDir="$HOME/Downloads/evidence/$target"

    if [ ! -x "$HOME/.local/bin/waybackpy" ]; then
        zenity --error \
            --title="Archive Tools" \
            --text="waybackpy not found at \$HOME/.local/bin/waybackpy.\nInstall it with: pipx install waybackpy" \
            2> >(grep -v 'GtkDialog' >&2)
        return
    fi

    mkdir -p "$sessionDir"

    zenity --info \
        --title="Archive Tools" \
        --text="Running waybackpy for: $url\nOutput: $sessionDir/waybackpy-urls.txt" \
        2> >(grep -v 'GtkDialog' >&2)

    "$HOME/.local/bin/waybackpy" --url "$url" --known_urls 2>&1 \
        | tee "$sessionDir/waybackpy-urls.txt"

    xdg-open "$sessionDir/waybackpy-urls.txt" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_ia
# Searches the Internet Archive for items matching the given URL/query.
# ---------------------------------------------------------------------------
run_ia() {
    local url="$1"
    local target="$2"
    local sessionDir="$HOME/Downloads/evidence/$target"

    if [ ! -x "$HOME/.local/bin/ia" ]; then
        zenity --error \
            --title="Archive Tools" \
            --text="internetarchive (ia) not found at \$HOME/.local/bin/ia.\nInstall it with: pipx install internetarchive" \
            2> >(grep -v 'GtkDialog' >&2)
        return
    fi

    mkdir -p "$sessionDir"

    zenity --info \
        --title="Archive Tools" \
        --text="Running ia search for: $url\nOutput: $sessionDir/ia-search.txt" \
        2> >(grep -v 'GtkDialog' >&2)

    "$HOME/.local/bin/ia" search "$url" 2>&1 \
        | tee "$sessionDir/ia-search.txt"

    xdg-open "$sessionDir/ia-search.txt" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_archivebox
# Adds the given URL to the local archivebox archive.
# ---------------------------------------------------------------------------
run_archivebox() {
    local url="$1"
    local archiveDir="$HOME/Downloads/archivebox"

    if [ ! -x "$HOME/.local/bin/archivebox" ]; then
        zenity --error \
            --title="Archive Tools" \
            --text="archivebox not found at \$HOME/.local/bin/archivebox.\nInstall it with: pipx install archivebox" \
            2> >(grep -v 'GtkDialog' >&2)
        return
    fi

    mkdir -p "$archiveDir"

    (cd "$archiveDir" && "$HOME/.local/bin/archivebox" add "$url" 2>&1 \
        | tee -a "$archiveDir/add.log")

    zenity --info \
        --title="Archive Tools" \
        --text="archivebox: URL added to archive at $archiveDir/" \
        2> >(grep -v 'GtkDialog' >&2)

    xdg-open "$archiveDir/" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
    while true; do
        # Prompt for URL
        local url
        url=$(zenity --entry \
            --title="Archive Tools" \
            --text="Enter URL:" \
            2> >(grep -v 'GtkDialog' >&2))

        local zenity_exit=$?
        if [ $zenity_exit -ne 0 ] || [ -z "$url" ]; then
            return
        fi

        # Extract hostname as target (sanitise)
        local target
        target=$(echo "$url" | sed 's|.*://||;s|/.*||')

        # Show tool menu
        local choice
        choice=$(zenity --list \
            --title="Archive Tools" \
            --text="Choose a tool to run against: $url" \
            --column="Tool" \
            "waybackpy — list known Wayback Machine URLs" \
            "internetarchive (ia) — search Internet Archive" \
            "archivebox — add URL to local archive" \
            2> >(grep -v 'GtkDialog' >&2))

        if [ -z "$choice" ]; then
            return
        fi

        case "$choice" in
            "waybackpy — list known Wayback Machine URLs")
                run_waybackpy "$url" "$target"
                ;;
            "internetarchive (ia) — search Internet Archive")
                run_ia "$url" "$target"
                ;;
            "archivebox — add URL to local archive")
                run_archivebox "$url"
                ;;
        esac

        # Ask to run another
        zenity --question \
            --title="Archive Tools" \
            --text="Run another?" \
            2> >(grep -v 'GtkDialog' >&2) || return
    done
}

main

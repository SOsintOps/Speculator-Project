#!/usr/bin/env bash
# image.sh — Zenity GUI launcher for image metadata and OSINT tools
# Version : 0.1.0
# Phase   : B
# Project : Speculator OSINT VM (Debian 13)
# Tools   : exiftool (apt), mat2 (apt), xeuledoc (pipx)

set -uo pipefail
[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

# ---------------------------------------------------------------------------
# Helper: suppress GtkDialog noise from zenity
# Usage: zenity_quiet [zenity args...]
# ---------------------------------------------------------------------------
zenity_quiet() {
    zenity "$@" 2> >(grep -v 'GtkDialog' >&2)
}

# ---------------------------------------------------------------------------
# Tool: exiftool — single file
# ---------------------------------------------------------------------------
run_exiftool_single() {
    if ! command -v exiftool >/dev/null 2>&1; then
        zenity_quiet --error --title="exiftool not found" \
            --text="exiftool is not installed.\nInstall it with: sudo apt install libimage-exiftool-perl"
        return
    fi

    local file
    file=$(zenity_quiet --file-selection --title="exiftool — select a file") || return

    if [[ -z "$file" ]]; then
        zenity_quiet --error --title="No file selected" --text="No file was selected."
        return
    fi

    local target
    target=$(basename "$file" | sed 's/\.[^.]*$//')

    local sessionDir="$HOME/Downloads/evidence/$target"
    mkdir -p "$sessionDir"

    exiftool "$file" | tee "$sessionDir/exif-single.txt"

    xdg-open "$sessionDir/exif-single.txt" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# Tool: exiftool — batch CSV (folder)
# ---------------------------------------------------------------------------
run_exiftool_batch() {
    if ! command -v exiftool >/dev/null 2>&1; then
        zenity_quiet --error --title="exiftool not found" \
            --text="exiftool is not installed.\nInstall it with: sudo apt install libimage-exiftool-perl"
        return
    fi

    local folder
    folder=$(zenity_quiet --file-selection --directory --title="exiftool — select a folder") || return

    if [[ -z "$folder" ]]; then
        zenity_quiet --error --title="No folder selected" --text="No folder was selected."
        return
    fi

    local target
    target=$(basename "$folder")

    local sessionDir="$HOME/Downloads/evidence/$target"
    mkdir -p "$sessionDir"

    exiftool -r "$folder" -csv > "$sessionDir/exif-batch.csv"

    xdg-open "$sessionDir/exif-batch.csv" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# Tool: mat2 — remove metadata
# ---------------------------------------------------------------------------
run_mat2() {
    if ! command -v mat2 >/dev/null 2>&1; then
        zenity_quiet --error --title="mat2 not found" \
            --text="mat2 is not installed.\nInstall it with: sudo apt install mat2"
        return
    fi

    local file
    file=$(zenity_quiet --file-selection --title="mat2 — select a file to clean") || return

    if [[ -z "$file" ]]; then
        zenity_quiet --error --title="No file selected" --text="No file was selected."
        return
    fi

    mat2 "$file"

    zenity_quiet --info --title="mat2 complete" \
        --text="mat2 completed. Cleaned file saved next to the original (filename.cleaned.ext)."
}

# ---------------------------------------------------------------------------
# Tool: xeuledoc — Google Docs OSINT
# ---------------------------------------------------------------------------
run_xeuledoc() {
    local xeuledoc_bin="$HOME/.local/bin/xeuledoc"

    if [[ ! -x "$xeuledoc_bin" ]]; then
        zenity_quiet --error --title="xeuledoc not found" \
            --text="xeuledoc is not installed or not executable at $HOME/.local/bin/xeuledoc.\nInstall it with: pipx install xeuledoc"
        return
    fi

    local url
    url=$(zenity_quiet --entry --title="xeuledoc — Google Docs OSINT" \
        --text="Enter the Google Doc URL:") || return

    if [[ -z "$url" ]]; then
        zenity_quiet --error --title="No URL entered" --text="No URL was entered."
        return
    fi

    local target="gdoc_$(date +%Y%m%d_%H%M)"
    local sessionDir="$HOME/Downloads/evidence/$target"
    mkdir -p "$sessionDir"

    "$xeuledoc_bin" "$url" 2>&1 | tee "$sessionDir/xeuledoc.txt"

    xdg-open "$sessionDir/xeuledoc.txt" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
main() {
    while true; do
        local choice
        choice=$(zenity_quiet --list \
            --title="Image Metadata and OSINT Tools" \
            --text="Select a tool to run:" \
            --column="Tool" \
            "exiftool — single file" \
            "exiftool — batch CSV (folder)" \
            "mat2 — remove metadata" \
            "xeuledoc — Google Docs OSINT") || break

        case "$choice" in
            "exiftool — single file")
                run_exiftool_single
                ;;
            "exiftool — batch CSV (folder)")
                run_exiftool_batch
                ;;
            "mat2 — remove metadata")
                run_mat2
                ;;
            "xeuledoc — Google Docs OSINT")
                run_xeuledoc
                ;;
            *)
                break
                ;;
        esac

        zenity_quiet --question \
            --title="Continue?" \
            --text="Run another tool?" \
            --ok-label="Yes" \
            --cancel-label="No" || break
    done
}

main

#!/usr/bin/env bash
# metadata.sh — Zenity GUI launcher for metadata extraction tools
# Version: 0.1.0 | Phase B
# Tools: Carbon14, metagoofil, metagoofil + exiftool, mediainfo

set -uo pipefail
[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

PROGRAMS_DIR="$HOME/.local/share/speculator/programs"

# ---------------------------------------------------------------------------
# run_carbon14
# ---------------------------------------------------------------------------
run_carbon14() {
    local VENV="$PROGRAMS_DIR/Carbon14/Carbon14Environment"
    local SCRIPT_DIR="$PROGRAMS_DIR/Carbon14"

    if [ ! -f "$VENV/bin/python" ]; then
        zenity --error \
            --title="Carbon14 — missing venv" \
            --text="Carbon14 venv not found at:\n$VENV" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local url
    url=$(zenity --entry \
        --title="Carbon14 — page age estimation" \
        --text="Enter the URL to analyse:" \
        2> >(grep -v 'GtkDialog' >&2)) || return 1

    [ -z "$url" ] && return 1

    local target
    target=$(echo "$url" | sed 's|.*://||;s|/.*||')

    local sessionDir="$HOME/Downloads/evidence/$target"
    mkdir -p "$sessionDir"

    pushd "$SCRIPT_DIR" >/dev/null 2>&1 || {
        zenity --error \
            --title="Carbon14 — directory error" \
            --text="Dir not found: $SCRIPT_DIR" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    }

    "$VENV/bin/python" carbon14.py "$url" 2>&1 | tee "$sessionDir/carbon14.txt"

    popd >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# run_metagoofil
# ---------------------------------------------------------------------------
run_metagoofil() {
    local VENV="$PROGRAMS_DIR/metagoofil/metagoofilEnvironment"
    local SCRIPT_DIR="$PROGRAMS_DIR/metagoofil"
    local fqdnregex='\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b'

    if [ ! -f "$VENV/bin/python" ]; then
        zenity --error \
            --title="metagoofil — missing venv" \
            --text="metagoofil venv not found at:\n$VENV" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local target
    target=$(zenity --entry \
        --title="metagoofil — document harvesting" \
        --text="Enter the target domain (e.g. example.com):" \
        2> >(grep -v 'GtkDialog' >&2)) || return 1

    [ -z "$target" ] && return 1

    if ! echo "$target" | grep -Pq "$fqdnregex"; then
        zenity --error \
            --title="metagoofil — invalid domain" \
            --text="'$target' is not a valid domain name." \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local sessionDir="$HOME/Downloads/evidence/$target/metagoofil"
    mkdir -p "$sessionDir"

    pushd "$SCRIPT_DIR" >/dev/null 2>&1 || {
        zenity --error \
            --title="metagoofil — directory error" \
            --text="Dir not found: $SCRIPT_DIR" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    }

    "$VENV/bin/python" metagoofil.py \
        -d "$target" \
        -w \
        -t pdf,doc,xls,ppt,docx,xlsx,pptx \
        -o "$sessionDir"

    popd >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# run_metagoofil_exiftool
# ---------------------------------------------------------------------------
run_metagoofil_exiftool() {
    local VENV="$PROGRAMS_DIR/metagoofil/metagoofilEnvironment"
    local SCRIPT_DIR="$PROGRAMS_DIR/metagoofil"
    local fqdnregex='\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b'

    if [ ! -f "$VENV/bin/python" ]; then
        zenity --error \
            --title="metagoofil — missing venv" \
            --text="metagoofil venv not found at:\n$VENV" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    if ! command -v exiftool >/dev/null 2>&1; then
        zenity --error \
            --title="exiftool — not found" \
            --text="exiftool is not installed or not in PATH." \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local target
    target=$(zenity --entry \
        --title="metagoofil + exiftool — harvest and analyse" \
        --text="Enter the target domain (e.g. example.com):" \
        2> >(grep -v 'GtkDialog' >&2)) || return 1

    [ -z "$target" ] && return 1

    if ! echo "$target" | grep -Pq "$fqdnregex"; then
        zenity --error \
            --title="metagoofil — invalid domain" \
            --text="'$target' is not a valid domain name." \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local sessionDir="$HOME/Downloads/evidence/$target/metagoofil"
    mkdir -p "$sessionDir"

    pushd "$SCRIPT_DIR" >/dev/null 2>&1 || {
        zenity --error \
            --title="metagoofil — directory error" \
            --text="Dir not found: $SCRIPT_DIR" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    }

    "$VENV/bin/python" metagoofil.py \
        -d "$target" \
        -w \
        -t pdf,doc,xls,ppt,docx,xlsx,pptx \
        -o "$sessionDir"

    popd >/dev/null 2>&1

    exiftool -r "$sessionDir" -csv \
        > "$HOME/Downloads/evidence/$target/exif-metagoofil.csv"

    xdg-open "$HOME/Downloads/evidence/$target/exif-metagoofil.csv" \
        >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_mediainfo
# ---------------------------------------------------------------------------
run_mediainfo() {
    if ! command -v mediainfo >/dev/null 2>&1; then
        zenity --error \
            --title="mediainfo — not found" \
            --text="mediainfo is not installed or not in PATH." \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local file
    file=$(zenity --file-selection \
        --title="mediainfo — select a file" \
        2> >(grep -v 'GtkDialog' >&2)) || return 1

    [ -z "$file" ] && return 1

    local basename_noext
    basename_noext=$(basename "$file")
    basename_noext="${basename_noext%.*}"

    local target="$basename_noext"
    local sessionDir="$HOME/Downloads/evidence/$target"
    mkdir -p "$sessionDir"

    mediainfo "$file" | tee "$sessionDir/mediainfo.txt"

    xdg-open "$sessionDir/mediainfo.txt" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
    while true; do
        local choice
        choice=$(zenity --list \
            --title="Metadata tools" \
            --text="Select a tool to run:" \
            --column="Tool" \
            "Carbon14 — page age estimation" \
            "metagoofil — document harvesting" \
            "metagoofil + exiftool — harvest and analyse" \
            "mediainfo — file information" \
            2> >(grep -v 'GtkDialog' >&2)) || return 0

        case "$choice" in
            "Carbon14 — page age estimation")
                run_carbon14
                ;;
            "metagoofil — document harvesting")
                run_metagoofil
                ;;
            "metagoofil + exiftool — harvest and analyse")
                run_metagoofil_exiftool
                ;;
            "mediainfo — file information")
                run_mediainfo
                ;;
        esac

        zenity --question \
            --title="Metadata tools" \
            --text="Run another tool?" \
            2> >(grep -v 'GtkDialog' >&2) || return 0
    done
}

main

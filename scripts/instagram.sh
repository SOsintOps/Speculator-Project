#!/usr/bin/env bash
# instagram.sh — Zenity GUI launcher for Instagram OSINT tools
# Version: 0.1.0
# Phase: B
# Project: Speculator Project
# Description: Provides a graphical menu to run Instaloader, Toutatis and
#              Osintgram against a target Instagram username.

set -uo pipefail
[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

# ---------------------------------------------------------------------------
# Tool binaries and paths
# ---------------------------------------------------------------------------
INSTALOADER_BIN="$HOME/.local/bin/instaloader"
TOUTATIS_BIN="$HOME/.local/bin/toutatis"
PROGRAMS_DIR="$HOME/.local/share/speculator/programs"
OSINTGRAM_VENV="$PROGRAMS_DIR/Osintgram/OsintgramEnvironment"
OSINTGRAM_DIR="$PROGRAMS_DIR/Osintgram"

# ---------------------------------------------------------------------------
# run_instaloader — download a public Instagram profile
# Note: Instaloader writes files to a subfolder named after the username
# inside the current working directory, so we cd to sessionDir first.
# ---------------------------------------------------------------------------
run_instaloader() {
    local target="$1"
    local sessionDir="$HOME/Downloads/evidence/$target/instaloader/"

    if [ ! -x "$INSTALOADER_BIN" ]; then
        zenity --error \
            --title="Instaloader — not found" \
            --text="Instaloader binary not found at:\n$INSTALOADER_BIN\n\nInstall it with: pipx install instaloader" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    mkdir -p "$sessionDir"

    pushd "$sessionDir" >/dev/null 2>&1 || {
        zenity --error \
            --title="Directory error" \
            --text="Dir not found: $sessionDir" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    }

    "$INSTALOADER_BIN" "$target" 2>&1 \
        | zenity --progress \
            --pulsate \
            --no-cancel \
            --auto-close \
            --title="Instaloader" \
            --text="Downloading profile: $target" \
            2> >(grep -v 'GtkDialog' >&2)

    popd >/dev/null 2>&1

    xdg-open "$sessionDir" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_toutatis — retrieve profile metadata using a session ID
# ---------------------------------------------------------------------------
run_toutatis() {
    local target="$1"
    local sessionDir="$HOME/Downloads/evidence/$target/"

    if [ ! -x "$TOUTATIS_BIN" ]; then
        zenity --error \
            --title="Toutatis — not found" \
            --text="Toutatis binary not found at:\n$TOUTATIS_BIN\n\nInstall it with: pipx install toutatis" \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    local session
    session=$(zenity --entry \
        --title="Toutatis" \
        --text="Enter your Instagram Session ID:" \
        2> >(grep -v 'GtkDialog' >&2))

    if [ -z "$session" ]; then
        zenity --error \
            --title="Toutatis — session ID required" \
            --text="No session ID provided. Toutatis requires a valid Instagram session ID." \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    mkdir -p "$sessionDir"

    "$TOUTATIS_BIN" -u "$target" -s "$session" 2>&1 \
        | tee "$sessionDir/toutatis.txt"

    xdg-open "$sessionDir/toutatis.txt" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_osintgram — launch the interactive Osintgram CLI in a new terminal
# ---------------------------------------------------------------------------
run_osintgram() {
    local target="$1"

    if [ ! -d "$OSINTGRAM_VENV" ]; then
        zenity --error \
            --title="Osintgram — not found" \
            --text="Osintgram venv not found at:\n$OSINTGRAM_VENV\n\nVerify the installation path." \
            2> >(grep -v 'GtkDialog' >&2)
        return 1
    fi

    x-terminal-emulator -e bash -c \
        "cd \"$OSINTGRAM_DIR\" && \"$OSINTGRAM_VENV/bin/python\" -m osintgram \"$target\""

    zenity --info \
        --title="Osintgram" \
        --text="Osintgram launched in a new terminal for target: $target" \
        2> >(grep -v 'GtkDialog' >&2)
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
    while true; do
        # Prompt for target username
        local target
        target=$(zenity --entry \
            --title="Instagram OSINT" \
            --text="Enter Instagram username:" \
            2> >(grep -v 'GtkDialog' >&2))

        # Exit if user cancels the username prompt
        if [ $? -ne 0 ] || [ -z "$target" ]; then
            return 0
        fi

        # Show tool menu
        local choice
        choice=$(zenity --list \
            --title="Instagram OSINT — $target" \
            --text="Select a tool to run against: $target" \
            --column="Tool" \
            "Instaloader — download profile" \
            "Toutatis — profile metadata (requires session ID)" \
            "Osintgram — interactive OSINT (requires login)" \
            2> >(grep -v 'GtkDialog' >&2))

        # If user cancels the menu, ask for another run
        if [ $? -ne 0 ] || [ -z "$choice" ]; then
            zenity --question \
                --title="Instagram OSINT" \
                --text="Run another tool?" \
                2> >(grep -v 'GtkDialog' >&2) || return 0
            continue
        fi

        # Dispatch to the selected tool
        case "$choice" in
            "Instaloader — download profile")
                run_instaloader "$target"
                ;;
            "Toutatis — profile metadata (requires session ID)")
                run_toutatis "$target"
                ;;
            "Osintgram — interactive OSINT (requires login)")
                run_osintgram "$target"
                ;;
        esac

        # Ask whether to run another tool
        zenity --question \
            --title="Instagram OSINT" \
            --text="Run another?" \
            2> >(grep -v 'GtkDialog' >&2) || return 0
    done
}

main

#!/usr/bin/env bash
# =============================================================================
# reddit.sh — Zenity GUI launcher for Reddit OSINT tools
# Version   : 0.1.0
# Phase     : B
# Project   : Speculator Project
# =============================================================================

set -uo pipefail
[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

# ---------------------------------------------------------------------------
# run_bdfr_submissions
# ---------------------------------------------------------------------------
run_bdfr_submissions() {
    local target="$1"
    local sessionDir="$HOME/Downloads/evidence/$target/BDFR/"

    if [ ! -x "$HOME/.local/bin/bdfr" ]; then
        zenity --error \
            --title="Reddit OSINT" \
            --text="bdfr not found at \$HOME/.local/bin/bdfr. Install it with pipx." \
            2> >(grep -v 'GtkDialog' >&2)
        return
    fi

    mkdir -p "$sessionDir"

    "$HOME/.local/bin/bdfr" archive "$sessionDir" --user "$target" --submitted

    xdg-open "$sessionDir" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_bdfr_comments
# ---------------------------------------------------------------------------
run_bdfr_comments() {
    local target="$1"
    local sessionDir="$HOME/Downloads/evidence/$target/BDFR/"

    if [ ! -x "$HOME/.local/bin/bdfr" ]; then
        zenity --error \
            --title="Reddit OSINT" \
            --text="bdfr not found at \$HOME/.local/bin/bdfr. Install it with pipx." \
            2> >(grep -v 'GtkDialog' >&2)
        return
    fi

    mkdir -p "$sessionDir"

    "$HOME/.local/bin/bdfr" archive "$sessionDir" --user "$target" --allcomments

    xdg-open "$sessionDir" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# run_bdfr_both
# ---------------------------------------------------------------------------
run_bdfr_both() {
    local target="$1"
    local sessionDir="$HOME/Downloads/evidence/$target/BDFR/"

    if [ ! -x "$HOME/.local/bin/bdfr" ]; then
        zenity --error \
            --title="Reddit OSINT" \
            --text="bdfr not found at \$HOME/.local/bin/bdfr. Install it with pipx." \
            2> >(grep -v 'GtkDialog' >&2)
        return
    fi

    mkdir -p "$sessionDir"

    "$HOME/.local/bin/bdfr" archive "$sessionDir" --user "$target" --submitted
    "$HOME/.local/bin/bdfr" archive "$sessionDir" --user "$target" --allcomments

    zenity --info \
        --title="Reddit OSINT" \
        --text="BDFR archive complete. Files in: $sessionDir" \
        2> >(grep -v 'GtkDialog' >&2)

    xdg-open "$sessionDir" >/dev/null 2>&1 &
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
    while true; do
        # Prompt for username
        local target
        target=$(zenity --entry \
            --title="Reddit OSINT" \
            --text="Enter Reddit username:" \
            2> >(grep -v 'GtkDialog' >&2)) || break

        if [ -z "$target" ]; then
            zenity --error \
                --title="Reddit OSINT" \
                --text="No username entered. Please try again." \
                2> >(grep -v 'GtkDialog' >&2)
            continue
        fi

        # Tool selection
        local choice
        choice=$(zenity --list \
            --title="Reddit OSINT" \
            --text="Target: $target\n\nSelect a tool:" \
            --column="Tool" \
            "BDFR — archive submissions" \
            "BDFR — archive comments" \
            "BDFR — archive both (submissions + comments)" \
            2> >(grep -v 'GtkDialog' >&2)) || break

        case "$choice" in
            "BDFR — archive submissions")
                run_bdfr_submissions "$target"
                ;;
            "BDFR — archive comments")
                run_bdfr_comments "$target"
                ;;
            "BDFR — archive both (submissions + comments)")
                run_bdfr_both "$target"
                ;;
            *)
                ;;
        esac

        # Ask to run another tool
        zenity --question \
            --title="Reddit OSINT" \
            --text="Run another tool?" \
            2> >(grep -v 'GtkDialog' >&2) || break
    done
}

main "$@"

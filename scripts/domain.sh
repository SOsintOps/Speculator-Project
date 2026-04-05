#!/usr/bin/env bash
################################################################################
## Domain OSINT Launcher
## Version 0.1.0 - Phase B: Zenity GUI for domain reconnaissance tools
## Tools: Amass, Sublist3r, theHarvester, Photon, httrack
################################################################################

set -uo pipefail

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

EVIDENCE_DIR="$HOME/Downloads/evidence"

###############################################################################
# Ensure base evidence directory exists
###############################################################################
ensure_base_dir() {
  if [ ! -d "$EVIDENCE_DIR" ]; then
    mkdir -p "$EVIDENCE_DIR"
  fi
}

###############################################################################
# Create session directory for the target domain
###############################################################################
create_session_dir() {
  local target="$1"
  local sessionDir="$EVIDENCE_DIR/$target"
  mkdir -p "$sessionDir"
  echo "$sessionDir"
}

###############################################################################
# Validate domain with regex
###############################################################################
validate_domain() {
  local target="$1"
  if [[ "$target" =~ \b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b ]]; then
    return 0
  fi
  return 1
}

###############################################################################
# Amass
###############################################################################
run_amass() {
  local target="$1"
  local sessionDir="$2"

  if [ ! -x "$HOME/go/bin/amass" ]; then
    zenity --error \
      --text="Amass binary not found at $HOME/go/bin/amass. Install it with: go install github.com/owasp-amass/amass/v4/...@latest" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  "$HOME/go/bin/amass" enum -src -brute -d "$target" -o "$sessionDir/amass.txt"
}

###############################################################################
# Sublist3r
###############################################################################
run_sublist3r() {
  local target="$1"
  local sessionDir="$2"
  local VENV="$HOME/Downloads/Programs/Sublist3r/Sublist3rEnvironment"

  if [ ! -x "$VENV/bin/python" ]; then
    zenity --error \
      --text="Sublist3r venv not found at $VENV. Please install Sublist3r first." \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  pushd "$HOME/Downloads/Programs/Sublist3r" >/dev/null 2>&1 || {
    zenity --error --text="Dir not found: $HOME/Downloads/Programs/Sublist3r" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  }
  "$VENV/bin/python" sublist3r.py -d "$target" -o "$sessionDir/sublist3r.txt"
  popd >/dev/null 2>&1
}

###############################################################################
# theHarvester
###############################################################################
run_theharvester() {
  local target="$1"
  local sessionDir="$2"
  local VENV="$HOME/Downloads/Programs/theHarvester/.venv"

  if [ ! -x "$VENV/bin/python" ]; then
    zenity --error \
      --text="theHarvester venv not found at $VENV. Please install theHarvester first." \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  pushd "$HOME/Downloads/Programs/theHarvester" >/dev/null 2>&1 || {
    zenity --error --text="Dir not found: $HOME/Downloads/Programs/theHarvester" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  }
  "$VENV/bin/python" theHarvester.py -d "$target" -f "$sessionDir/harvester.json" -b duckduckgo
  popd >/dev/null 2>&1
}

###############################################################################
# Photon
###############################################################################
run_photon() {
  local target="$1"
  local sessionDir="$2"
  local VENV="$HOME/Downloads/Programs/Photon/PhotonEnvironment"

  if [ ! -x "$VENV/bin/python" ]; then
    zenity --error \
      --text="Photon venv not found at $VENV. Please install Photon first." \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  pushd "$HOME/Downloads/Programs/Photon" >/dev/null 2>&1 || {
    zenity --error --text="Dir not found: $HOME/Downloads/Programs/Photon" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  }
  mkdir -p "$sessionDir/photon/"
  "$VENV/bin/python" photon.py -u "$target" -l 3 -t 100 -o "$sessionDir/photon/"
  popd >/dev/null 2>&1
}

###############################################################################
# httrack (GUI)
###############################################################################
run_httrack() {
  local target="$1"

  if ! command -v webhttrack &>/dev/null; then
    zenity --error \
      --text="webhttrack is not installed. Install it with: sudo apt install webhttrack" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  webhttrack &
  zenity --info \
    --text="webhttrack has been launched. Configure your crawl for $target in the browser interface." \
    2> >(grep -v 'GtkDialog' >&2)
}

###############################################################################
# RUN ALL (sequential, skips httrack)
###############################################################################
run_all() {
  local target="$1"
  local sessionDir="$2"

  run_amass       "$target" "$sessionDir"
  run_sublist3r   "$target" "$sessionDir"
  run_theharvester "$target" "$sessionDir"
  run_photon      "$target" "$sessionDir"

  zenity --info \
    --text="All domain tools have finished.\nResults are in: $sessionDir" \
    2> >(grep -v 'GtkDialog' >&2)
}

###############################################################################
# Main
###############################################################################
main() {
  ensure_base_dir

  while true; do
    local target
    target=$(zenity --entry \
      --title="Domain OSINT" \
      --text="Enter target domain (e.g. example.com):" \
      --width=420 \
      2> >(grep -v 'GtkDialog' >&2)) || break

    if [ -z "${target:-}" ]; then
      break
    fi

    if ! validate_domain "$target"; then
      zenity --error \
        --text="Invalid domain: '$target'\nPlease enter a valid domain name (e.g. example.com)." \
        2> >(grep -v 'GtkDialog' >&2)
      continue
    fi

    local sessionDir
    sessionDir="$(create_session_dir "$target")"

    local choice
    choice=$(zenity --list \
      --title="Domain Tools — $target" \
      --column="Tool" \
      "Amass" \
      "Sublist3r" \
      "theHarvester" \
      "Photon" \
      "httrack (GUI)" \
      "RUN ALL" \
      --height=360 --width=320 \
      2> >(grep -v 'GtkDialog' >&2)) || {
        zenity --question \
          --title="Repeat?" \
          --text="Do you want to run another query?" \
          --ok-label="Yes" \
          --cancel-label="No" \
          2> >(grep -v 'GtkDialog' >&2) || break
        continue
      }

    case "$choice" in
      "Amass")
        run_amass "$target" "$sessionDir"
        xdg-open "$sessionDir" >/dev/null 2>&1 &
        ;;
      "Sublist3r")
        run_sublist3r "$target" "$sessionDir"
        xdg-open "$sessionDir" >/dev/null 2>&1 &
        ;;
      "theHarvester")
        run_theharvester "$target" "$sessionDir"
        xdg-open "$sessionDir" >/dev/null 2>&1 &
        ;;
      "Photon")
        run_photon "$target" "$sessionDir"
        xdg-open "$sessionDir" >/dev/null 2>&1 &
        ;;
      "httrack (GUI)")
        run_httrack "$target"
        ;;
      "RUN ALL")
        run_all "$target" "$sessionDir"
        xdg-open "$sessionDir" >/dev/null 2>&1 &
        ;;
    esac

    zenity --question \
      --title="Repeat?" \
      --text="Do you want to run another query?" \
      --ok-label="Yes" \
      --cancel-label="No" \
      2> >(grep -v 'GtkDialog' >&2) || break
  done
}

main

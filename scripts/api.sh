#!/usr/bin/env bash
################################################################################
## API OSINT Launcher
## Version 0.1.0 - Phase B: Zenity GUI for API-based OSINT tools
## Tools: SpiderFoot, recon-ng, Shodan CLI, Censys CLI
################################################################################

set -uo pipefail

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

EVIDENCE_DIR="$HOME/Downloads/evidence"
PROGRAMS_DIR="$HOME/.local/share/speculator/programs"

###############################################################################
# Ensure base evidence directory exists
###############################################################################
ensure_base_dir() {
  if [ ! -d "$EVIDENCE_DIR" ]; then
    mkdir -p "$EVIDENCE_DIR"
  fi
}

###############################################################################
# SpiderFoot (venv)
###############################################################################
run_spiderfoot() {
  local VENV="$PROGRAMS_DIR/spiderfoot/spiderfootEnvironment"
  local SF_PY="$PROGRAMS_DIR/spiderfoot/sf.py"

  if [ ! -x "$VENV/bin/python" ]; then
    zenity --error \
      --text="SpiderFoot venv not found at $VENV. Please install SpiderFoot first." \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  if [ ! -f "$SF_PY" ]; then
    zenity --error \
      --text="SpiderFoot script not found at $SF_PY. Please install SpiderFoot first." \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  if pgrep -f "spiderfoot -l" >/dev/null 2>&1; then
    zenity --info \
      --text="SpiderFoot is already running at http://127.0.0.1:5001" \
      2> >(grep -v 'GtkDialog' >&2)
    xdg-open "http://127.0.0.1:5001" >/dev/null 2>&1
    return 0
  fi

  "$VENV/bin/python" "$SF_PY" -l 127.0.0.1:5001 &
  sleep 5
  xdg-open "http://127.0.0.1:5001" >/dev/null 2>&1
  zenity --info \
    --text="SpiderFoot started at http://127.0.0.1:5001" \
    2> >(grep -v 'GtkDialog' >&2)
}

###############################################################################
# recon-ng (venv, interactive terminal)
###############################################################################
run_recon_ng() {
  local VENV="$PROGRAMS_DIR/recon-ng/recon-ngEnvironment"

  if [ ! -x "$VENV/bin/python" ]; then
    zenity --error \
      --text="recon-ng venv not found at $VENV. Please install recon-ng first." \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  x-terminal-emulator -e bash -c "cd \"$PROGRAMS_DIR/recon-ng\" && \"$VENV/bin/python\" recon-ng"
  zenity --info \
    --text="recon-ng launched in a new terminal." \
    2> >(grep -v 'GtkDialog' >&2)
}

###############################################################################
# Shodan CLI
###############################################################################
run_shodan() {
  local SHODAN_BIN="$HOME/.local/bin/shodan"

  if [ ! -x "$SHODAN_BIN" ]; then
    zenity --error \
      --text="Shodan CLI not found at $SHODAN_BIN. Install it with: pipx install shodan" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  local query
  query=$(zenity --entry \
    --title="Shodan Search" \
    --text="Enter Shodan search query:" \
    --width=420 \
    2> >(grep -v 'GtkDialog' >&2)) || return 0

  if [ -z "${query:-}" ]; then
    return 0
  fi

  local sessionDir="$EVIDENCE_DIR/shodan_$(date +%Y%m%d_%H%M)"
  mkdir -p "$sessionDir"

  "$SHODAN_BIN" search "$query" 2>&1 | tee "$sessionDir/shodan.txt"
  xdg-open "$sessionDir/shodan.txt" >/dev/null 2>&1 &
}

###############################################################################
# Censys CLI
###############################################################################
run_censys() {
  local CENSYS_BIN="$HOME/.local/bin/censys"

  if [ ! -x "$CENSYS_BIN" ]; then
    zenity --error \
      --text="Censys CLI not found at $CENSYS_BIN. Install it with: pipx install censys" \
      2> >(grep -v 'GtkDialog' >&2)
    return 1
  fi

  local query
  query=$(zenity --entry \
    --title="Censys Search" \
    --text="Enter Censys search query:" \
    --width=420 \
    2> >(grep -v 'GtkDialog' >&2)) || return 0

  if [ -z "${query:-}" ]; then
    return 0
  fi

  local sessionDir="$EVIDENCE_DIR/censys_$(date +%Y%m%d_%H%M)"
  mkdir -p "$sessionDir"

  "$CENSYS_BIN" search "$query" 2>&1 | tee "$sessionDir/censys.txt"
  xdg-open "$sessionDir/censys.txt" >/dev/null 2>&1 &
}

###############################################################################
# Main
###############################################################################
main() {
  ensure_base_dir

  while true; do
    local choice
    choice=$(zenity --list \
      --title="API OSINT Tools" \
      --column="Tool" \
      "SpiderFoot — web recon framework" \
      "recon-ng — recon framework" \
      "Shodan — search query" \
      "Censys — search query" \
      --height=280 --width=380 \
      2> >(grep -v 'GtkDialog' >&2)) || break

    case "$choice" in
      "SpiderFoot — web recon framework")
        run_spiderfoot
        ;;
      "recon-ng — recon framework")
        run_recon_ng
        ;;
      "Shodan — search query")
        run_shodan
        ;;
      "Censys — search query")
        run_censys
        ;;
    esac

    zenity --question \
      --title="Repeat?" \
      --text="Run another?" \
      --ok-label="Yes" \
      --cancel-label="No" \
      2> >(grep -v 'GtkDialog' >&2) || break
  done
}

main

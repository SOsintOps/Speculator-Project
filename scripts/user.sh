#!/usr/bin/env bash
################################################################################
## OSINT Unified Input Script
## Version 0.4.1.0 - Session log: record selected tools, full cmd, stdout+stderr
## Version 0.4.0.0 - Replace Gum/whiptail with Zenity checklist; single flat
##                   list per category with multi-select (no scroll menus).
##                   Preserved from v0.3.4.0: run_tool(), session log, semantic
##                   error detection, fullname category, venv support for
##                   repo-based Python tools, progress bar, ANSI terminal output.
## Version 0.3.4.0 - Fix Python repo-based tools with dedicated venv; improved
##                   semantic detection; more robust quoting.
## Version 0.2.0.3 - PROGRAMS_DIR; all hardcoded paths replaced.
################################################################################

set -uo pipefail
[ "${XDG_SESSION_TYPE:-}" = "wayland" ] && export GDK_BACKEND=x11

# pipx and user-installed binaries
export PATH="$HOME/.local/bin:$PATH"

EVIDENCE_DIR="$HOME/Downloads/evidence"
PROGRAMS_DIR="$HOME/.local/share/speculator/programs"
SCRIPT_VERSION="0.4.1.0"

VERBOSE=false
[[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]] && VERBOSE=true

# ── ANSI palette ─────────────────────────────────────────────────────────────
RESET="\033[0m"; BOLD="\033[1m"; DIM="\033[2m"
C_CYAN="\033[38;5;39m";   C_YELLOW="\033[38;5;220m"; C_GREEN="\033[38;5;82m"
C_RED="\033[38;5;196m";   C_ORANGE="\033[38;5;214m"; C_PURPLE="\033[38;5;135m"
C_GRAY="\033[38;5;245m";  C_DGRAY="\033[38;5;238m";  C_BLUE="\033[38;5;75m"
COL_EMAIL="$C_CYAN"; COL_HASH="$C_YELLOW"; COL_USER="$C_GREEN"; COL_NAME="$C_BLUE"

###############################################################################
# Session log
###############################################################################
SESSION_LOG_FILE=""
SESSION_LOG_DIR=""
declare -A TOOL_STATUS=()
declare -A TOOL_DURATION=()

_session_log() {
  [ -z "$SESSION_LOG_FILE" ] && return
  printf "[%s] %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$*" >> "$SESSION_LOG_FILE"
}

###############################################################################
# Terminal output primitives
###############################################################################
_line() {
  local char="$1" len="${2:-62}" col="${3:-$C_DGRAY}"
  printf "${col}"; printf '%*s' "$len" '' | tr ' ' "$char"; printf "${RESET}\n"
}

print_banner() {
  clear; echo ""
  _line "═" 62 "$C_PURPLE"
  printf "${C_PURPLE}${BOLD}  %-46s${RESET}${C_DGRAY}%s${RESET}\n" \
    "OSINT UNIFIED TOOL  v${SCRIPT_VERSION}" "$(date +'%d/%m/%Y %H:%M')"
  printf "${C_GRAY}  %-58s${RESET}\n" "email · username · fullname · hash"
  $VERBOSE && printf "  ${C_ORANGE}${BOLD}VERBOSE MODE${RESET}${C_GRAY} — live output active${RESET}\n"
  _line "═" 62 "$C_PURPLE"; echo ""
}

print_section_header() {
  local title="$1" sub="$2" col="${3:-$C_PURPLE}"
  echo ""; _line "─" 62 "$col"
  printf "${col}${BOLD}  %-58s${RESET}\n" "$title"
  printf "${C_GRAY}  %-58s${RESET}\n" "$sub"
  _line "─" 62 "$col"; echo ""
}

log_step() {
  local name="$1" stato="$2" extra="${3:-}"
  case "$stato" in
    run)  printf "  ${C_CYAN}◌${RESET}  ${BOLD}%-22s${RESET} ${C_CYAN}running...${RESET}\n" "$name" ;;
    ok)   printf "  ${C_GREEN}✔${RESET}  ${BOLD}%-22s${RESET} ${C_GREEN}done${RESET}${C_GRAY}%s${RESET}\n" \
            "$name" "$extra" ;;
    skip) printf "  ${C_ORANGE}⊘${RESET}  ${BOLD}%-22s${RESET} ${C_ORANGE}not available — skipped${RESET}\n" "$name" ;;
    fail) printf "  ${C_RED}✖${RESET}  ${BOLD}%-22s${RESET} ${C_RED}error%s${RESET}\n" "$name" "$extra" ;;
    info) printf "  ${C_GRAY}ℹ${RESET}  ${C_GRAY}%s${RESET}\n" "$name" ;;
  esac
  _session_log "[$stato] $name $extra"
}

log_result() {
  printf "  ${C_DGRAY}    └─ %s${RESET}\n" "$1"
  _session_log "  output: $1"
}

status_bar() {
  echo ""; _line "─" 62 "$C_DGRAY"
  printf "${C_GRAY}${DIM}  %-58s${RESET}\n" "$1"
  _line "─" 62 "$C_DGRAY"; echo ""
}

pause_ok() {
  echo ""; printf "  ${C_GREEN}${BOLD}►${RESET}  ${C_GRAY}(press ENTER to continue)${RESET} "
  read -r _
}

print_summary() {
  local ok=0 fail=0 skip=0
  echo ""; _line "═" 62 "$C_PURPLE"
  printf "${C_PURPLE}${BOLD}  SUMMARY${RESET}\n"; _line "─" 62 "$C_DGRAY"
  for label in "${!TOOL_STATUS[@]}"; do
    local st="${TOOL_STATUS[$label]}" dur="${TOOL_DURATION[$label]:-}"
    local dur_str=""; [ -n "$dur" ] && dur_str="  ${C_DGRAY}(${dur}s)${RESET}"
    case "$st" in
      ok)   printf "  ${C_GREEN}✔${RESET}  %-26s%b\n" "$label" "$dur_str"; ((ok++)) ;;
      fail) printf "  ${C_RED}✖${RESET}  %-26s%b\n"   "$label" "$dur_str"; ((fail++)) ;;
      skip) printf "  ${C_ORANGE}⊘${RESET}  %-26s\n"  "$label"; ((skip++)) ;;
    esac
  done
  _line "─" 62 "$C_DGRAY"
  printf "  ${C_GREEN}✔ %d ok${RESET}   ${C_RED}✖ %d errors${RESET}   ${C_ORANGE}⊘ %d skipped${RESET}\n" \
    "$ok" "$fail" "$skip"
  _line "═" 62 "$C_PURPLE"; echo ""
  TOOL_STATUS=(); TOOL_DURATION=()
}

_progress() {
  local cur="$1" tot="$2" label="$3"
  local filled=$(( cur * 20 / tot )) empty=$(( 20 - cur * 20 / tot ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty;  i++)); do bar+="░"; done
  printf "\n  ${C_PURPLE}[%s]${RESET} ${C_GRAY}%d/%d${RESET}  ${BOLD}%s${RESET}\n\n" \
    "$bar" "$cur" "$tot" "$label"
}

###############################################################################
# run_tool — execute command, capture output, detect errors
###############################################################################
SEMANTIC_ERROR_PATTERNS=(
  "traceback" "exception" "error:" "fatal:" "errno" "failed to"
  "connection refused" "connection timed out" "unauthorized" "forbidden"
  "invalid api" "api key" "no such file" "permission denied"
  "segmentation fault" "module not found" "modulenotfounderror"
  "attributeerror" "nameerror" "syntaxerror"
  "no targets found in user input" "quitting"
)

_check_semantic_errors() {
  local combined; combined=$(cat "$1" "$2" 2>/dev/null)
  for pattern in "${SEMANTIC_ERROR_PATTERNS[@]}"; do
    echo "$combined" | grep -iq "$pattern" && { echo "$pattern"; return 0; }
  done
  return 1
}

_save_error_log() {
  local label="$1" rc="$2" out="$3" err="$4"
  [ -z "$SESSION_LOG_DIR" ] && return
  local lf="$SESSION_LOG_DIR/${label// /_}-error.log"
  { echo "=== $label === $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Exit code: $rc"
    echo "--- stdout ---"; cat "$out"  2>/dev/null
    echo "--- stderr ---"; cat "$err"  2>/dev/null
  } >> "$lf"
  printf "  ${C_GRAY}    ℹ error log: %s${RESET}\n" "$lf"
}

run_tool() {
  local label="$1" outfile="$2"; shift 2
  local out; out="$(mktemp /tmp/osint_out_XXXXXX)"
  local err; err="$(mktemp /tmp/osint_err_XXXXXX)"
  local rc=0 t_start t_end duration

  log_step "$label" "run"
  _session_log "[START] $label | $(date +'%H:%M:%S') | cmd: $*"
  t_start=$(date +%s)

  if $VERBOSE; then
    printf "  ${C_DGRAY}  ┌─────────────── live output ──────────────────${RESET}\n"
    if [ "$outfile" = "-" ]; then
      "$@" 2>&1 | while IFS= read -r l; do
        printf "  ${C_DGRAY}  │${RESET} %s\n" "$l"; echo "$l" >> "$out"
      done; rc=${PIPESTATUS[0]}
    else
      "$@" 2>&1 | tee "$outfile" | while IFS= read -r l; do
        printf "  ${C_DGRAY}  │${RESET} %s\n" "$l"; echo "$l" >> "$out"
      done; rc=${PIPESTATUS[0]}
    fi
    printf "  ${C_DGRAY}  └──────────────────────────────────────────────${RESET}\n"
  else
    if [ "$outfile" = "-" ]; then
      "$@" >"$out" 2>"$err" || rc=$?
    else
      "$@" >"$outfile" 2>"$err" || rc=$?
      cp "$outfile" "$out" 2>/dev/null || true
    fi
  fi

  t_end=$(date +%s); duration=$(( t_end - t_start ))

  # Write tool output to session log
  if [ -n "${SESSION_LOG_FILE:-}" ]; then
    [ -s "$out" ] && { printf "  [stdout]\n" >> "$SESSION_LOG_FILE"; cat "$out" >> "$SESSION_LOG_FILE"; printf "\n" >> "$SESSION_LOG_FILE"; }
    [ -s "$err" ] && { printf "  [stderr]\n" >> "$SESSION_LOG_FILE"; cat "$err" >> "$SESSION_LOG_FILE"; printf "\n" >> "$SESSION_LOG_FILE"; }
  fi

  if [ $rc -ne 0 ]; then
    TOOL_STATUS["$label"]="fail"; TOOL_DURATION["$label"]="$duration"
    log_step "$label" "fail" "  (exit $rc, ${duration}s)"
    if [ -s "$err" ]; then
      printf "  ${C_RED}    ┌─ stderr ──────────────────────────────────${RESET}\n"
      head -10 "$err" | while IFS= read -r l; do
        printf "  ${C_RED}    │${RESET} %s\n" "$l"
      done
      printf "  ${C_RED}    └──────────────────────────────────────────${RESET}\n"
    fi
    _save_error_log "$label" "$rc" "$out" "$err"
    rm -f "$out" "$err"; return 1
  fi

  local sem_pat
  if sem_pat=$(_check_semantic_errors "$out" "$err"); then
    TOOL_STATUS["$label"]="fail"; TOOL_DURATION["$label"]="$duration"
    log_step "$label" "fail" "  (semantic: '${sem_pat}', ${duration}s)"
    printf "  ${C_RED}    ┌─ semantic error ───────────────────────────${RESET}\n"
    grep -i "$sem_pat" "$out" "$err" 2>/dev/null | head -5 | \
      while IFS= read -r l; do printf "  ${C_RED}    │${RESET} %s\n" "$l"; done
    printf "  ${C_RED}    └──────────────────────────────────────────${RESET}\n"
    _save_error_log "$label" "0(semantic:$sem_pat)" "$out" "$err"
    rm -f "$out" "$err"; return 1
  fi

  TOOL_STATUS["$label"]="ok"; TOOL_DURATION["$label"]="$duration"
  log_step "$label" "ok" "  (${duration}s)"
  if [ -s "$err" ]; then
    printf "  ${C_ORANGE}    ┌─ warnings ─────────────────────────────────${RESET}\n"
    head -5 "$err" | while IFS= read -r l; do
      printf "  ${C_ORANGE}    │${RESET}${C_GRAY} %s${RESET}\n" "$l"
    done
    printf "  ${C_ORANGE}    └──────────────────────────────────────────${RESET}\n"
  fi
  rm -f "$out" "$err"; return 0
}

###############################################################################
# repo_venv_python / run_repo_python_tool
###############################################################################
repo_venv_python() {
  local d="$1" base; base="$(basename "$d")"
  for c in "$d/${base}Environment/bin/python" "$d/venv/bin/python" "$d/.venv/bin/python"; do
    [ -x "$c" ] && { echo "$c"; return 0; }
  done
  return 1
}

run_repo_python_tool() {
  local label="$1" repo_dir="$2" script="$3" outfile="$4"; shift 4
  if [ ! -d "$repo_dir" ]; then
    log_step "$label" "skip"; TOOL_STATUS["$label"]="skip"; return 1
  fi
  local pybin="python3"
  repo_venv_python "$repo_dir" >/dev/null 2>&1 && pybin="$(repo_venv_python "$repo_dir")"
  pushd "$repo_dir" >/dev/null 2>&1 || return 1
  run_tool "$label" "$outfile" "$pybin" "$script" "$@"
  local rc=$?; popd >/dev/null 2>&1 || true; return $rc
}

###############################################################################
# Required tools / graceful degradation
###############################################################################
REQUIRED_TOOLS=(holehe socialscan python3 ghunt h8mail nth sth sherlock bdfr maigret)
MISSING_TOOLS=()

tool_available() {
  local t="$1"
  for m in "${MISSING_TOOLS[@]:-}"; do [ "$m" = "$t" ] && return 1; done
  command -v "$t" &>/dev/null
}

warn_unavailable() { log_step "$1" "skip"; TOOL_STATUS["$1"]="skip"; }

# Returns "ready" or "not installed" for use in the zenity checklist Status column.
_avail() {
  local val="$1" type="${2:-cmd}"
  case "$type" in
    dir)  [ -d "$val" ]  && echo "ready" || echo "not installed" ;;
    file) [ -f "$val" ]  && echo "ready" || echo "not installed" ;;
    *)    tool_available "$val" && echo "ready" || echo "not installed" ;;
  esac
}

check_required_tools() {
  local missing_list=()
  for t in "${REQUIRED_TOOLS[@]}"; do
    command -v "$t" &>/dev/null || { MISSING_TOOLS+=("$t"); missing_list+=("  • $t"); }
  done
  [ ${#missing_list[@]} -eq 0 ] && return
  local msg="The following tools are not installed or not in PATH:\n\n"
  msg+="$(printf '%s\n' "${missing_list[@]}")"
  msg+="\n\nThe script will continue with reduced functionality."
  zenity --warning --title="Missing Tools" --text="$msg" --width=440 2>/dev/null
}

###############################################################################
# Utility
###############################################################################
ensure_base_dir() { [ ! -d "$EVIDENCE_DIR" ] && mkdir -p "$EVIDENCE_DIR"; }

create_session_dir() {
  local target="$1" d="$EVIDENCE_DIR/$1"
  [ ! -d "$d" ] && mkdir -p "$d"
  SESSION_LOG_DIR="$d/logs"
  [ ! -d "$SESSION_LOG_DIR" ] && mkdir -p "$SESSION_LOG_DIR"
  local ts; ts="$(date +'%Y%m%d-%H%M%S')"
  SESSION_LOG_FILE="$SESSION_LOG_DIR/session-${ts}.log"
  { echo "════════════════════════════════════════"
    echo " OSINT UNIFIED TOOL v${SCRIPT_VERSION}"
    echo " Session: $(date +'%Y-%m-%d %H:%M:%S')"
    echo " Target:  $target"
    echo "════════════════════════════════════════"
  } > "$SESSION_LOG_FILE"
  echo "$d"
}

###############################################################################
# Input classification
###############################################################################
advanced_hash_detection() {
  tool_available "nth" || return 1
  nth --text "$1" 2>/dev/null | grep -iq "Possible Hashes"
}

classify_input() {
  local v="$1"
  [[ "$v" =~ ^[^@]+@[^@]+\.[^@]+$ ]] && { echo "email"; return; }
  if advanced_hash_detection "$v"; then echo "hash"; return; fi
  local len=${#v}
  if [[ "$v" =~ ^[A-Fa-f0-9]+$ ]] && \
     { [ "$len" -eq 32 ] || [ "$len" -eq 40 ] || \
       [ "$len" -eq 64 ] || [ "$len" -eq 128 ]; }; then
    echo "hash"; return
  fi
  if [[ "$v" =~ [[:space:]] ]]; then
    local valid=true; local -a toks
    IFS=' ' read -ra toks <<< "$v"
    for t in "${toks[@]}"; do [[ "$t" =~ ^[[:alpha:]-]+$ ]] || { valid=false; break; }; done
    $valid && [ ${#toks[@]} -ge 2 ] && { echo "fullname"; return; }
    echo "unknown"; return
  fi
  [[ "$v" =~ ^[a-zA-Z0-9_.\-]+$ ]] && { echo "username"; return; }
  echo "unknown"
}

resolve_unknown_category() {
  local choice
  choice=$(zenity --list \
    --title="Input classification" \
    --text="Could not classify: $1\n\nSelect the correct category:" \
    --column="Category" --column="Use for" \
    "Username"  "Social profile search" \
    "Fullname"  "Name-based search (Turbolehe)" \
    "Email"     "Email tools" \
    "Hash"      "Hash identification and cracking" \
    --width=420 --height=290 2>/dev/null) || return 1
  case "$choice" in
    "Username") echo "username" ;;
    "Fullname") echo "fullname" ;;
    "Email")    echo "email" ;;
    "Hash")     echo "hash" ;;
    *)          echo "cancel" ;;
  esac
}

###############################################################################
# Email tools
###############################################################################
run_email_tools() {
  local inputValue="$1"
  ensure_base_dir
  local sessionDir; sessionDir="$(create_session_dir "$inputValue")"
  print_section_header "EMAIL TOOLS" "Target: $inputValue" "$COL_EMAIL"

  local sel
  sel=$(zenity --list --checklist \
    --title="Email Tools — $inputValue" \
    --text="Select tools to run:" \
    --column="Run" --column="Tool" --column="Status" \
    FALSE "Holehe"     "$(_avail holehe)" \
    FALSE "Turbolehe"  "$(_avail "$PROGRAMS_DIR/Turbolehe/turbolehe.py" file)" \
    FALSE "SocialScan" "$(_avail socialscan)" \
    FALSE "Eyes"       "$(_avail "$PROGRAMS_DIR/Eyes" dir)" \
    FALSE "GHunt"      "$(_avail ghunt)" \
    FALSE "H8Mail"     "$(_avail h8mail)" \
    --separator=":" --width=480 --height=350 2>/dev/null) || return

  [ -z "$sel" ] && return
  TOOL_STATUS=(); TOOL_DURATION=()
  IFS=':' read -ra selected <<< "$sel"
  _session_log "Selected: ${selected[*]}"
  local total=${#selected[@]} cur=0

  for tool in "${selected[@]}"; do
    ((cur++)); _progress $cur $total "$tool"
    case "$tool" in
      "Holehe")
        if tool_available "holehe"; then
          run_tool "Holehe" "$sessionDir/$inputValue-Holehe.txt" \
            holehe "$inputValue" && {
            log_result "$sessionDir/$inputValue-Holehe.txt"
            xdg-open "$sessionDir/$inputValue-Holehe.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "holehe"; fi ;;
      "Turbolehe")
        if [ -f "$PROGRAMS_DIR/Turbolehe/turbolehe.py" ]; then
          local tname
          tname=$(zenity --entry --title="Turbolehe" \
            --text="Enter first and last name (e.g. John Smith):" \
            --width=400 2>/dev/null) || continue
          [ -z "$tname" ] && continue
          local safe="${tname// /_}"
          run_repo_python_tool "Turbolehe" "$PROGRAMS_DIR/Turbolehe" "turbolehe.py" \
            "$sessionDir/${safe}-Turbolehe.txt" $tname && {
            log_result "$sessionDir/${safe}-Turbolehe.txt"
            xdg-open "$sessionDir/${safe}-Turbolehe.txt" >/dev/null 2>&1 &
          }
        else
          log_step "Turbolehe" "skip"; TOOL_STATUS["Turbolehe"]="skip"
        fi ;;
      "SocialScan")
        if tool_available "socialscan"; then
          run_tool "SocialScan" "$sessionDir/$inputValue-socialscan.txt" \
            socialscan "$inputValue" --json "$sessionDir/$inputValue-socialscan.txt" && {
            log_result "$sessionDir/$inputValue-socialscan.txt"
            xdg-open "$sessionDir/$inputValue-socialscan.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "socialscan"; fi ;;
      "Eyes")
        if [ -d "$PROGRAMS_DIR/Eyes" ]; then
          run_repo_python_tool "Eyes" "$PROGRAMS_DIR/Eyes" "eyes.py" "-" "$inputValue" && \
            log_result "$PROGRAMS_DIR/Eyes"
        else
          log_step "Eyes" "skip"; TOOL_STATUS["Eyes"]="skip"
        fi ;;
      "GHunt")
        if tool_available "ghunt"; then
          run_tool "GHunt" "$sessionDir/$inputValue-GHunt.txt" \
            ghunt email "$inputValue" && {
            log_result "$sessionDir/$inputValue-GHunt.txt"
            xdg-open "$sessionDir/$inputValue-GHunt.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "ghunt"; fi ;;
      "H8Mail")
        if tool_available "h8mail"; then
          run_tool "H8Mail" "-" h8mail -t "$inputValue" \
            -c "$HOME/h8mail_config.ini" -o "$sessionDir/$inputValue-H8Mail.txt" && {
            log_result "$sessionDir/$inputValue-H8Mail.txt"
            xdg-open "$sessionDir/$inputValue-H8Mail.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "h8mail"; fi ;;
    esac
  done
  status_bar "Done → $sessionDir"; print_summary; pause_ok
}

###############################################################################
# Hash tools
###############################################################################
run_hash_tools() {
  local inputValue="$1"
  ensure_base_dir
  local sessionDir; sessionDir="$(create_session_dir "$inputValue")"
  print_section_header "HASH TOOLS" "Hash: $inputValue" "$COL_HASH"

  local sel
  sel=$(zenity --list --checklist \
    --title="Hash Tools — $inputValue" \
    --text="Select tools to run:" \
    --column="Run" --column="Tool" --column="Status" \
    FALSE "NameThatHash"   "$(_avail nth)" \
    FALSE "SearchThatHash" "$(_avail sth)" \
    --separator=":" --width=440 --height=230 2>/dev/null) || return

  [ -z "$sel" ] && return
  TOOL_STATUS=(); TOOL_DURATION=()
  IFS=':' read -ra selected <<< "$sel"
  _session_log "Selected: ${selected[*]}"
  local total=${#selected[@]} cur=0

  for tool in "${selected[@]}"; do
    ((cur++)); _progress $cur $total "$tool"
    case "$tool" in
      "NameThatHash")
        if tool_available "nth"; then
          run_tool "NameThatHash" "-" \
            bash -c 'nth --text "$1" | tee "$2"' _ \
            "$inputValue" "$sessionDir/$inputValue-nth.txt" && {
            log_result "$sessionDir/$inputValue-nth.txt"
            xdg-open "$sessionDir/$inputValue-nth.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "nth"; fi ;;
      "SearchThatHash")
        if tool_available "sth"; then
          run_tool "SearchThatHash" "-" \
            bash -c 'sth --text "$1" | tee "$2"' _ \
            "$inputValue" "$sessionDir/$inputValue-sth.txt" && {
            log_result "$sessionDir/$inputValue-sth.txt"
            xdg-open "$sessionDir/$inputValue-sth.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "sth"; fi ;;
    esac
  done
  status_bar "Done → $sessionDir"; print_summary; pause_ok
}

###############################################################################
# Fullname tools
###############################################################################
run_fullname_tools() {
  local inputValue="$1"
  ensure_base_dir
  local safe="${inputValue// /_}"
  local sessionDir; sessionDir="$(create_session_dir "$safe")"
  print_section_header "FULLNAME TOOLS" "Target: $inputValue" "$COL_NAME"

  local sel
  sel=$(zenity --list --checklist \
    --title="Fullname Tools — $inputValue" \
    --text="Select tools to run:" \
    --column="Run" --column="Tool" --column="Status" \
    FALSE "Turbolehe" "$(_avail "$PROGRAMS_DIR/Turbolehe/turbolehe.py" file)" \
    --separator=":" --width=440 --height=200 2>/dev/null) || return

  [ -z "$sel" ] && return
  TOOL_STATUS=(); TOOL_DURATION=()
  IFS=':' read -ra selected <<< "$sel"
  _session_log "Selected: ${selected[*]}"
  local total=${#selected[@]} cur=0

  for tool in "${selected[@]}"; do
    ((cur++)); _progress $cur $total "$tool"
    case "$tool" in
      "Turbolehe")
        if [ -f "$PROGRAMS_DIR/Turbolehe/turbolehe.py" ]; then
          run_repo_python_tool "Turbolehe" "$PROGRAMS_DIR/Turbolehe" "turbolehe.py" \
            "$sessionDir/$safe-Turbolehe.txt" $inputValue && {
            log_result "$sessionDir/$safe-Turbolehe.txt"
            xdg-open "$sessionDir/$safe-Turbolehe.txt" >/dev/null 2>&1 &
          }
        else
          log_step "Turbolehe" "skip"; TOOL_STATUS["Turbolehe"]="skip"
        fi ;;
    esac
  done
  status_bar "Done → $sessionDir"; print_summary; pause_ok
}

###############################################################################
# Username tools
###############################################################################
run_username_tools() {
  local inputValue="$1"
  ensure_base_dir
  local sessionDir; sessionDir="$(create_session_dir "$inputValue")"
  print_section_header "USERNAME TOOLS" "Target: $inputValue" "$COL_USER"

  local sel
  sel=$(zenity --list --checklist \
    --title="Username Tools — $inputValue" \
    --text="Select tools to run:" \
    --column="Run" --column="Tool" --column="Status" \
    FALSE "Sherlock"    "$(_avail sherlock)" \
    FALSE "SocialScan"  "$(_avail socialscan)" \
    FALSE "Blackbird"   "$(_avail "$PROGRAMS_DIR/blackbird" dir)" \
    FALSE "Maigret"     "$(_avail maigret)" \
    FALSE "Mr.Holmes"   "$(_avail "$PROGRAMS_DIR/Mr.Holmes" dir)" \
    FALSE "WhatsMyName" "$(_avail "$PROGRAMS_DIR/WhatsMyName-Python" dir)" \
    FALSE "BDFR"        "$(_avail bdfr)" \
    FALSE "H8Mail"      "$(_avail h8mail)" \
    --separator=":" --width=480 --height=410 2>/dev/null) || return

  [ -z "$sel" ] && return
  TOOL_STATUS=(); TOOL_DURATION=()
  IFS=':' read -ra selected <<< "$sel"
  _session_log "Selected: ${selected[*]}"
  local total=${#selected[@]} cur=0

  for tool in "${selected[@]}"; do
    ((cur++)); _progress $cur $total "$tool"
    case "$tool" in
      "Sherlock")
        if tool_available "sherlock"; then
          run_tool "Sherlock" "$sessionDir/Sherlock-$inputValue.csv" \
            sherlock "$inputValue" --csv -o "$sessionDir/Sherlock-$inputValue.csv" && {
            log_result "$sessionDir/Sherlock-$inputValue.csv"
            xdg-open "$sessionDir/Sherlock-$inputValue.csv" >/dev/null 2>&1 &
          }
        else warn_unavailable "sherlock"; fi ;;
      "SocialScan")
        if tool_available "socialscan"; then
          run_tool "SocialScan" "$sessionDir/$inputValue-socialscan.txt" \
            socialscan "$inputValue" --json "$sessionDir/$inputValue-socialscan.txt" && {
            log_result "$sessionDir/$inputValue-socialscan.txt"
            xdg-open "$sessionDir/$inputValue-socialscan.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "socialscan"; fi ;;
      "Blackbird")
        if [ -d "$PROGRAMS_DIR/blackbird" ]; then
          run_repo_python_tool "Blackbird" "$PROGRAMS_DIR/blackbird" "blackbird.py" "-" \
            -u "$inputValue" --pdf && {
            mv -f "$PROGRAMS_DIR/blackbird/results"/* "$sessionDir" 2>/dev/null || true
            log_result "$sessionDir"
          }
        else
          log_step "Blackbird" "skip"; TOOL_STATUS["Blackbird"]="skip"
        fi ;;
      "Maigret")
        if tool_available "maigret"; then
          run_tool "Maigret" "-" \
            maigret -a -P -T "$inputValue" --folderoutput="$sessionDir" && \
            log_result "$sessionDir"
        else warn_unavailable "maigret"; fi ;;
      "Mr.Holmes")
        if [ -d "$PROGRAMS_DIR/Mr.Holmes" ]; then
          run_repo_python_tool "Mr.Holmes" "$PROGRAMS_DIR/Mr.Holmes" "MrHolmes.py" \
            "$sessionDir/$inputValue-MrHolmes.txt" -u "$inputValue" --all && {
            log_result "$sessionDir/$inputValue-MrHolmes.txt"
            xdg-open "$sessionDir/$inputValue-MrHolmes.txt" >/dev/null 2>&1 &
          }
        else
          log_step "Mr.Holmes" "skip"; TOOL_STATUS["Mr.Holmes"]="skip"
        fi ;;
      "WhatsMyName")
        if [ -d "$PROGRAMS_DIR/WhatsMyName-Python" ]; then
          run_repo_python_tool "WhatsMyName" "$PROGRAMS_DIR/WhatsMyName-Python" \
            "whatsmyname.py" "$sessionDir/$inputValue-WhatsMyName.txt" -u "$inputValue" && {
            log_result "$sessionDir/$inputValue-WhatsMyName.txt"
            xdg-open "$sessionDir/$inputValue-WhatsMyName.txt" >/dev/null 2>&1 &
          }
        else
          log_step "WhatsMyName" "skip"; TOOL_STATUS["WhatsMyName"]="skip"
        fi ;;
      "BDFR")
        if tool_available "bdfr"; then
          mkdir -p "$sessionDir/BDFR"
          run_tool "BDFR submitted" "-" \
            bdfr archive "$sessionDir/BDFR" --user "$inputValue" --submitted
          run_tool "BDFR comments" "-" \
            bdfr archive "$sessionDir/BDFR" --user "$inputValue" --allcomments && {
            log_result "$sessionDir/BDFR"
            xdg-open "$sessionDir/BDFR" >/dev/null 2>&1 &
          }
        else warn_unavailable "bdfr"; fi ;;
      "H8Mail")
        if tool_available "h8mail"; then
          run_tool "H8Mail" "-" h8mail -t "$inputValue" \
            -c "$HOME/h8mail_config.ini" -o "$sessionDir/$inputValue-H8Mail.txt" && {
            log_result "$sessionDir/$inputValue-H8Mail.txt"
            xdg-open "$sessionDir/$inputValue-H8Mail.txt" >/dev/null 2>&1 &
          }
        else warn_unavailable "h8mail"; fi ;;
    esac
  done
  status_bar "Done → $sessionDir"; print_summary; pause_ok
}

###############################################################################
# Main
###############################################################################
main() {
  print_banner
  check_required_tools
  ensure_base_dir

  while true; do
    print_banner
    local inputValue
    inputValue=$(zenity --entry \
      --title="OSINT Unified Tool v${SCRIPT_VERSION}" \
      --text="Enter username, email, full name or hash:\n(launch with -v for live output)" \
      --width=460 2>/dev/null) || break
    [ -z "${inputValue:-}" ] && break

    local category; category=$(classify_input "$inputValue")
    if [ "$category" = "unknown" ]; then
      category=$(resolve_unknown_category "$inputValue") || continue
      [ "$category" = "cancel" ] && continue
    fi

    _session_log "Input: '$inputValue' → category: $category"

    case "$category" in
      "email")
        printf "\n  ${COL_EMAIL}${BOLD}▶  EMAIL${RESET}  ${C_GRAY}%s${RESET}\n" "$inputValue"
        run_email_tools "$inputValue" ;;
      "hash")
        printf "\n  ${COL_HASH}${BOLD}▶  HASH${RESET}  ${C_GRAY}%s${RESET}\n" "$inputValue"
        run_hash_tools "$inputValue" ;;
      "fullname")
        printf "\n  ${COL_NAME}${BOLD}▶  FULLNAME${RESET}  ${C_GRAY}%s${RESET}\n" "$inputValue"
        run_fullname_tools "$inputValue" ;;
      "username")
        printf "\n  ${COL_USER}${BOLD}▶  USERNAME${RESET}  ${C_GRAY}%s${RESET}\n" "$inputValue"
        run_username_tools "$inputValue" ;;
    esac

    zenity --question \
      --title="New query?" --text="Run another search?" \
      --ok-label="Yes" --cancel-label="No" 2>/dev/null || break
  done

  [ -n "$SESSION_LOG_FILE" ] && {
    _session_log "Session ended: $(date +'%Y-%m-%d %H:%M:%S')"
    printf "\n  ${C_GRAY}ℹ  Session log: %s${RESET}\n" "$SESSION_LOG_FILE"
  }
  echo ""; _line "═" 62 "$C_PURPLE"
  printf "${C_PURPLE}${BOLD}  Session ended.${RESET}\n"
  _line "═" 62 "$C_PURPLE"; echo ""
}

main

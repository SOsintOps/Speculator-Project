#!/usr/bin/env bash
################################################################################
## Update All OSINT Tools
## Version 0.1.0 - Updates pipx packages and git repos
################################################################################

set -uo pipefail

SCRIPT_NAME="OSINT TOOL UPDATER"
SCRIPT_VERSION="0.1.0"
VERBOSE=false
[[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]] && VERBOSE=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
  print_banner "update all installed OSINT tools"
  ensure_base_dir

  local updated=0 failed=0 skipped=0

  # 1. Update pipx packages
  _line "-" 62 "$C_CYAN"
  printf "${C_CYAN}${BOLD}  Updating pipx packages...${RESET}\n"
  _line "-" 62 "$C_CYAN"
  if command -v pipx &>/dev/null; then
    if pipx upgrade-all 2>&1 | tee /dev/stderr | grep -q "upgraded"; then
      log_step "pipx upgrade-all" "ok"
      ((updated++))
    else
      log_step "pipx upgrade-all" "ok" " (already up to date)"
    fi
  else
    log_step "pipx" "skip"
    ((skipped++))
  fi

  # 2. Update Go binaries
  echo ""
  _line "-" 62 "$C_CYAN"
  printf "${C_CYAN}${BOLD}  Updating Go binaries...${RESET}\n"
  _line "-" 62 "$C_CYAN"
  if command -v go &>/dev/null; then
    local go_tools=("amass" "subfinder" "httpx" "nuclei" "enola" "stalkie" "phoneinfoga")
    for tool in "${go_tools[@]}"; do
      if command -v "$tool" &>/dev/null; then
        log_step "$tool" "info" "go install -u (skipped — manual update recommended)"
        ((skipped++))
      fi
    done
  else
    log_step "go" "skip"
    ((skipped++))
  fi

  # 3. Update git repos
  echo ""
  _line "-" 62 "$C_CYAN"
  printf "${C_CYAN}${BOLD}  Updating git repositories...${RESET}\n"
  _line "-" 62 "$C_CYAN"
  if [ -d "$PROGRAMS_DIR" ]; then
    local dir
    for dir in "$PROGRAMS_DIR"/*/; do
      [ ! -d "$dir/.git" ] && continue
      local name; name=$(basename "$dir")
      (
        cd "$dir" || exit 1
        local before; before=$(git rev-parse HEAD 2>/dev/null)
        git pull --ff-only 2>&1 | tail -1
        local after; after=$(git rev-parse HEAD 2>/dev/null)
        if [ "$before" != "$after" ]; then
          echo "UPDATED"
        fi
      )
      local rc=$?
      if [ $rc -eq 0 ]; then
        log_step "$name" "ok"
        ((updated++))
      else
        log_step "$name" "fail"
        ((failed++))
      fi
    done
  else
    log_step "PROGRAMS_DIR" "skip" " (not found: $PROGRAMS_DIR)"
    ((skipped++))
  fi

  # Summary
  echo ""
  _line "=" 62 "$C_PURPLE"
  printf "${C_PURPLE}${BOLD}  UPDATE SUMMARY${RESET}\n"
  _line "-" 62 "$C_DGRAY"
  printf "  ${C_GREEN}Updated: %d${RESET}  ${C_RED}Failed: %d${RESET}  ${C_ORANGE}Skipped: %d${RESET}\n" \
    "$updated" "$failed" "$skipped"
  _line "=" 62 "$C_PURPLE"
  echo ""
}

main

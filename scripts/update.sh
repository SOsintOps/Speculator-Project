#!/usr/bin/env bash
################################################################################
## Update All OSINT Tools
## Version 0.2.0 - Updates pipx packages, Go binaries and git repos
################################################################################

set -uo pipefail

SCRIPT_NAME="OSINT TOOL UPDATER"
SCRIPT_VERSION="0.2.0"
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
    local pipx_out
    if pipx_out=$(pipx upgrade-all 2>&1); then
      if echo "$pipx_out" | grep -q "upgraded"; then
        log_step "pipx upgrade-all" "ok" " (packages upgraded)"
        ((updated++))
      else
        log_step "pipx upgrade-all" "ok" " (already up to date)"
      fi
    else
      log_step "pipx upgrade-all" "fail" " (exit code $?)"
      ((failed++))
    fi
    $VERBOSE && echo "$pipx_out"
  else
    log_step "pipx" "skip"
    ((skipped++))
  fi

  # 2. Update Go binaries (same module paths as speculator_install.sh)
  echo ""
  _line "-" 62 "$C_CYAN"
  printf "${C_CYAN}${BOLD}  Updating Go binaries...${RESET}
"
  _line "-" 62 "$C_CYAN"
  if command -v go &>/dev/null; then
    local -a go_modules=(
      "amass|github.com/owasp-amass/amass/v4/...@latest"
      "subfinder|github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
      "httpx|github.com/projectdiscovery/httpx/cmd/httpx@latest"
      "nuclei|github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
      "enola|github.com/theyahya/enola/cmd/enola@latest"
      "stalkie|github.com/ashendilantha/stalkie@latest"
      "investigo|github.com/tdh8316/Investigo/cmd/investigo@latest"
    )
    local entry tool module go_out
    for entry in "${go_modules[@]}"; do
      tool="${entry%%|*}"; module="${entry#*|}"
      if ! command -v "$tool" &>/dev/null; then
        log_step "$tool" "skip" " (not installed)"
        ((skipped++)); continue
      fi
      if go_out=$(GOTOOLCHAIN=auto go install "$module" 2>&1); then
        log_step "$tool" "ok" " (latest)"
        ((updated++))
      else
        log_step "$tool" "fail" " (go install failed)"
        ((failed++))
      fi
      $VERBOSE && echo "$go_out"
    done
  else
    log_step "go" "skip" " (not installed)"
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
      local before after pull_out
      before=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
      if pull_out=$(git -C "$dir" pull --ff-only 2>&1); then
        after=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
        if [ "$before" != "$after" ]; then
          log_step "$name" "ok" " (updated)"
          ((updated++))
        else
          log_step "$name" "ok" " (already up to date)"
        fi
      else
        log_step "$name" "fail" " (git pull failed)"
        ((failed++))
      fi
      $VERBOSE && echo "$pull_out"
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

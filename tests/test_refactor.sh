#!/usr/bin/env bash
###############################################################################
## test_refactor.sh — Verify user.sh + common.sh refactor
## Runs without Zenity, OSINT tools, or network access.
###############################################################################

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0; FAIL=0; TOTAL=0

_test() {
  local name="$1" expected="$2" actual="$3"
  ((TOTAL++))
  if [ "$expected" = "$actual" ]; then
    printf "  \033[32m✔\033[0m  %s\n" "$name"
    ((PASS++))
  else
    printf "  \033[31m✖\033[0m  %s\n" "$name"
    printf "       expected: '%s'\n" "$expected"
    printf "       actual:   '%s'\n" "$actual"
    ((FAIL++))
  fi
}

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Refactor Tests — user.sh + common.sh"
echo "═══════════════════════════════════════════════════"
echo ""

###############################################################################
echo "── 1. Source common.sh ──"
###############################################################################

SCRIPT_NAME="TEST"
SCRIPT_VERSION="0.0.0"
VERBOSE=false
source "$SCRIPT_DIR/scripts/lib/common.sh" 2>/dev/null
_test "common.sh sources without error" "0" "$?"
_test "_COMMON_SH_LOADED is set" "1" "${_COMMON_SH_LOADED:-0}"
_test "EVIDENCE_DIR defined" "$HOME/Downloads/evidence" "$EVIDENCE_DIR"
_test "PROGRAMS_DIR defined" "$HOME/.local/share/speculator/programs" "$PROGRAMS_DIR"
_test "TOOLS_CONF points to existing file" "true" "$([ -f "$TOOLS_CONF" ] && echo true || echo false)"

###############################################################################
echo ""
echo "── 2. classify_input() ──"
###############################################################################

# Source user.sh functions (skip main)
# We extract classify_input and advanced_hash_detection only
eval "$(sed -n '/^advanced_hash_detection/,/^}/p' "$SCRIPT_DIR/scripts/user.sh")"
eval "$(sed -n '/^classify_input/,/^}/p' "$SCRIPT_DIR/scripts/user.sh")"

_test "email: user@example.com" "email" "$(classify_input "user@example.com")"
_test "email: test.name+tag@domain.co.uk" "email" "$(classify_input "test.name+tag@domain.co.uk")"
_test "username: johndoe123" "username" "$(classify_input "johndoe123")"
_test "username: john_doe" "username" "$(classify_input "john_doe")"
_test "username: john.doe" "username" "$(classify_input "john.doe")"
_test "fullname: John Smith" "fullname" "$(classify_input "John Smith")"
_test "fullname: Marco De Rossi" "fullname" "$(classify_input "Marco De Rossi")"
_test "hash MD5: 32 hex chars" "hash" "$(classify_input "d41d8cd98f00b204e9800998ecf8427e")"
_test "hash SHA1: 40 hex chars" "hash" "$(classify_input "da39a3ee5e6b4b0d3255bfef95601890afd80709")"
_test "hash SHA256: 64 hex chars" "hash" "$(classify_input "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")"
_test "phone: +393331234567" "phone" "$(classify_input "+393331234567")"
_test "phone: 3331234567" "phone" "$(classify_input "3331234567")"
_test "phone: +14155552671" "phone" "$(classify_input "+14155552671")"
_test "not phone (too short): 12345" "username" "$(classify_input "12345")"

###############################################################################
echo ""
echo "── 3. load_manifest() ──"
###############################################################################

load_manifest "email"
_test "email category loads tools" "true" "$([ ${#_MF_IDS[@]} -gt 0 ] && echo true || echo false)"
_test "email has holehe" "Holehe" "${_MF_NAME[holehe]:-missing}"
_test "email has ghunt" "GHunt" "${_MF_NAME[ghunt]:-missing}"
_test "email has h8mail" "H8Mail" "${_MF_NAME[h8mail]:-missing}"
_test "email has eyes" "Eyes" "${_MF_NAME[eyes]:-missing}"
_test "email has mailcat" "Mailcat" "${_MF_NAME[mailcat]:-missing}"
_test "email has profil3r" "Profil3r" "${_MF_NAME[profil3r]:-missing}"
email_count=${#_MF_IDS[@]}
_test "email tool count = 8" "8" "$email_count"

load_manifest "username"
_test "username category loads tools" "true" "$([ ${#_MF_IDS[@]} -gt 0 ] && echo true || echo false)"
_test "username has sherlock" "Sherlock" "${_MF_NAME[sherlock]:-missing}"
_test "username has maigret" "Maigret" "${_MF_NAME[maigret]:-missing}"
_test "username has enola" "Enola" "${_MF_NAME[enola]:-missing}"
_test "username has stalkie" "Stalkie" "${_MF_NAME[stalkie]:-missing}"
_test "username has naminter" "Naminter" "${_MF_NAME[naminter]:-missing}"
username_count=${#_MF_IDS[@]}
_test "username tool count = 11" "11" "$username_count"

load_manifest "fullname"
fullname_count=${#_MF_IDS[@]}
_test "fullname tool count = 1" "1" "$fullname_count"
_test "fullname has turbolehe" "Turbolehe" "${_MF_NAME[turbolehe-fullname]:-missing}"

load_manifest "hash"
hash_count=${#_MF_IDS[@]}
_test "hash tool count = 2" "2" "$hash_count"

load_manifest "phone"
phone_count=${#_MF_IDS[@]}
_test "phone tool count = 2" "2" "$phone_count"
_test "phone has ignorant" "Ignorant" "${_MF_NAME[ignorant]:-missing}"
_test "phone has phoneinfoga" "PhoneInfoga" "${_MF_NAME[phoneinfoga]:-missing}"

load_manifest "domain"
domain_count=${#_MF_IDS[@]}
_test "domain tool count = 10" "10" "$domain_count"

load_manifest "frameworks"
fw_count=${#_MF_IDS[@]}
_test "frameworks tool count = 4" "4" "$fw_count"

###############################################################################
echo ""
echo "── 4. Manifest field integrity ──"
###############################################################################

load_manifest "email"
for id in "${_MF_IDS[@]}"; do
  _test "email/$id has check_type" "true" "$([ -n "${_MF_CHECK_TYPE[$id]:-}" ] && echo true || echo false)"
  _test "email/$id has check_val" "true" "$([ -n "${_MF_CHECK_VAL[$id]:-}" ] && echo true || echo false)"
  _test "email/$id has cmd" "true" "$([ -n "${_MF_CMD[$id]:-}" ] && echo true || echo false)"
done

###############################################################################
echo ""
echo "── 5. Function availability after source ──"
###############################################################################

_test "run_tool exists" "true" "$(declare -f run_tool >/dev/null 2>&1 && echo true || echo false)"
_test "run_repo_python_tool exists" "true" "$(declare -f run_repo_python_tool >/dev/null 2>&1 && echo true || echo false)"
_test "run_category exists" "true" "$(declare -f run_category >/dev/null 2>&1 && echo true || echo false)"
_test "run_manifest_tool exists" "true" "$(declare -f run_manifest_tool >/dev/null 2>&1 && echo true || echo false)"
_test "load_manifest exists" "true" "$(declare -f load_manifest >/dev/null 2>&1 && echo true || echo false)"
_test "zenity_checklist exists" "true" "$(declare -f zenity_checklist >/dev/null 2>&1 && echo true || echo false)"
_test "print_banner exists" "true" "$(declare -f print_banner >/dev/null 2>&1 && echo true || echo false)"
_test "print_summary exists" "true" "$(declare -f print_summary >/dev/null 2>&1 && echo true || echo false)"
_test "_session_log exists" "true" "$(declare -f _session_log >/dev/null 2>&1 && echo true || echo false)"
_test "tool_available exists" "true" "$(declare -f tool_available >/dev/null 2>&1 && echo true || echo false)"

###############################################################################
echo ""
echo "── 6. No duplicated code ──"
###############################################################################

# user.sh should NOT define these functions (they come from common.sh)
user_sh="$SCRIPT_DIR/scripts/user.sh"
_test "user.sh has no run_tool()" "0" "$(grep -c '^run_tool()' "$user_sh")"
_test "user.sh has no run_repo_python_tool()" "0" "$(grep -c '^run_repo_python_tool()' "$user_sh")"
_test "user.sh has no ANSI palette block" "0" "$(grep -c 'C_CYAN=' "$user_sh")"
_test "user.sh has no run_email_tools()" "0" "$(grep -c 'run_email_tools' "$user_sh")"
_test "user.sh has no run_username_tools()" "0" "$(grep -c 'run_username_tools' "$user_sh")"
_test "user.sh has no run_hash_tools()" "0" "$(grep -c 'run_hash_tools' "$user_sh")"
_test "user.sh has no run_fullname_tools()" "0" "$(grep -c 'run_fullname_tools' "$user_sh")"
_test "user.sh sources common.sh" "1" "$(grep -c '^source.*common.sh' "$user_sh")"
_test "user.sh uses run_category" "true" "$(grep -q 'run_category' "$user_sh" && echo true || echo false)"

###############################################################################
echo ""
echo "── 7. Line count reduction ──"
###############################################################################

user_lines=$(wc -l < "$user_sh")
common_lines=$(wc -l < "$SCRIPT_DIR/scripts/lib/common.sh")
_test "user.sh under 150 lines" "true" "$([ "$user_lines" -lt 150 ] && echo true || echo false)"
_test "common.sh under 600 lines" "true" "$([ "$common_lines" -lt 600 ] && echo true || echo false)"

###############################################################################
# Summary
###############################################################################
echo ""
echo "═══════════════════════════════════════════════════"
printf "  \033[32m✔ %d passed\033[0m   \033[31m✖ %d failed\033[0m   (total: %d)\n" \
  "$PASS" "$FAIL" "$TOTAL"
echo "═══════════════════════════════════════════════════"
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1

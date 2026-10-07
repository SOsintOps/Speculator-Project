#!/usr/bin/env bash
###############################################################################
## test_common.sh — scripts/lib/common.sh and the launchers, run headless.
## Fake tools and a fake manifest live in a temporary HOME; zenity is mocked.
###############################################################################

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tests/helpers/assert.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
mkdir -p "$HOME" "$TMP/bin"
export PATH="$TMP/bin:$PATH"

SCRIPT_NAME="TEST"; SCRIPT_VERSION="0.0.0"; VERBOSE=false
source "$ROOT/scripts/lib/common.sh"
source "$ROOT/tests/helpers/mock_zenity.sh"
xdg-open() { :; }
clear() { :; }

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Common Library Tests — scripts/lib/common.sh"
echo "═══════════════════════════════════════════════════"

_section "1. Paths"
_test "PATH has \$HOME/.local/bin" "true" "$(_true grep -q "$HOME/.local/bin" <<< "$PATH")"
_test "PATH has \$HOME/go/bin" "true" "$(_true grep -q "$HOME/go/bin" <<< "$PATH")"
_test "evidence lives in the (test) home" "$HOME/Downloads/evidence" "$EVIDENCE_DIR"

_section "2. safe_name"
_test "spaces become underscores" "John_Smith" "$(safe_name "John Smith")"
_test "email kept" "a.b+c@x.org" "$(safe_name "a.b+c@x.org")"
_test "URL loses slashes and colons" "httpsvm.tiktok.comZMabc" "$(safe_name "https://vm.tiktok.com/ZMabc/")"
_test "path traversal removed" "....etcpasswd" "$(safe_name "../../etc/passwd")"

_section "3. Session directory and log"
create_session_dir "alice" >/dev/null
_test "SESSION_DIR set in the caller" "$EVIDENCE_DIR/alice" "$SESSION_DIR"
_test "session folder exists" "true" "$(_true test -d "$SESSION_DIR/logs")"
_test "SESSION_LOG_FILE set in the caller" "true" "$(_true test -f "$SESSION_LOG_FILE")"
_session_log "marker-123"
_test "session log receives entries" "true" "$(_true grep -q marker-123 "$SESSION_LOG_FILE")"

_section "4. run_tool"
out="$TMP/out.txt"
run_tool "Echo" "$out" echo hello >/dev/null
_test "success: output file written" "hello" "$(cat "$out")"
_test "success: status ok" "ok" "${TOOL_STATUS[Echo]}"
run_tool "Fails" "$out" false >/dev/null
_test "exit code 1: status fail" "fail" "${TOOL_STATUS[Fails]}"
_test "exit code 1: error log saved" "true" "$(_true test -f "$SESSION_LOG_DIR/Fails-error.log")"
run_tool "Trace" "$out" bash -c 'echo "Traceback (most recent call last)"' >/dev/null
_test "semantic error: status fail" "fail" "${TOOL_STATUS[Trace]}"
run_tool "Stdout" "-" echo captured >/dev/null
_test "outfile '-': output goes to the session log" "true" "$(_true grep -q captured "$SESSION_LOG_FILE")"

_section "5. Manifest tools"
cat > "$TMP/bin/fakeosint" <<'EOF'
#!/usr/bin/env bash
echo "fake result for $1"
EOF
chmod +x "$TMP/bin/fakeosint"
mkdir -p "$PROGRAMS_DIR/FakeRepo/FakeRepoEnvironment/bin"
cat > "$PROGRAMS_DIR/FakeRepo/FakeRepoEnvironment/bin/python" <<'EOF'
#!/usr/bin/env bash
echo "venv python in $(pwd) with $*"
EOF
chmod +x "$PROGRAMS_DIR/FakeRepo/FakeRepoEnvironment/bin/python"
TOOLS_CONF="$TMP/tools.conf"
cat > "$TOOLS_CONF" <<'EOF'
# test manifest
Fake Binary|fakebin|testcat|binary|fakeosint|fakeosint {target} > {outfile}|txt|no|
Fake Repo|fakerepo|testcat|repo|FakeRepo|python3 tool.py -u {target} > {outfile}|txt|yes|FakeRepoEnvironment
Missing|missing|testcat|binary|not-a-real-tool|not-a-real-tool {target}|txt|no|
EOF
load_manifest "testcat"
_test "load_manifest reads the category" "3" "${#_MF_IDS[@]}"
_test "ready: binary on PATH" "true" "$(_true manifest_tool_ready fakebin)"
_test "ready: repo directory" "true" "$(_true manifest_tool_ready fakerepo)"
_test "not ready: missing binary" "false" "$(_true manifest_tool_ready missing)"

create_session_dir "bob" >/dev/null
run_manifest_tool fakebin "bob smith" "$SESSION_DIR" >/dev/null
_test "binary tool writes {outfile}" "fake result for bob smith" "$(cat "$SESSION_DIR/bob_smith-fakebin.txt" 2>/dev/null)"
run_manifest_tool fakerepo "bob" "$SESSION_DIR" >/dev/null
_test "repo tool runs with its venv, in its folder" \
  "venv python in $PROGRAMS_DIR/FakeRepo with tool.py -u bob" "$(cat "$SESSION_DIR/bob-fakerepo.txt" 2>/dev/null)"
run_manifest_tool missing "bob" "$SESSION_DIR" >/dev/null
_test "missing tool is skipped" "skip" "${TOOL_STATUS[Missing]}"

_section "6. run_category with mocked dialogs"
zenity_answers "fakebin"
run_category "testcat" "carol" "TEST TOOLS" "" </dev/null >/dev/null
_test "checklist shown" "--list" "$(zenity_calls | head -n 1)"
_test "selected tool ran" "fake result for carol" "$(cat "$EVIDENCE_DIR/carol/carol-fakebin.txt" 2>/dev/null)"
_test "selection recorded in the session log" "true" \
  "$(_true grep -q "Selected: fakebin" "$EVIDENCE_DIR"/carol/logs/session-*.log)"
zenity_answers "<cancel>"
run_category "testcat" "dave" "TEST TOOLS" "" </dev/null >/dev/null
_test "cancel runs nothing" "false" "$(_true ls "$EVIDENCE_DIR"/dave/dave-*)"

_section "7. Launcher scripts can be sourced"
SCRIPT_DIR="$ROOT/scripts"
zenity_answers
source "$ROOT/scripts/user.sh" </dev/null >/dev/null
_test "sourcing user.sh opens no dialog" "" "$(zenity_calls)"
_test "user.sh: share link classified" "sharelink" "$(classify_input "https://pin.it/abc")"
zenity_answers "domain"
_test "user.sh: main menu returns the chosen id" "domain" "$(main_menu)"
source "$ROOT/scripts/frameworks.sh" </dev/null >/dev/null
_test "sourcing frameworks.sh opens no dialog" "" "$(zenity_calls | grep -v -- --list)"
TOOLS_CONF="$TMP/fw.conf"
echo 'Fake FW|fakefw|frameworks|repo|FakeRepo|python3 fw.py --interactive|dir|yes|FakeRepoEnvironment' > "$TOOLS_CONF"
load_manifest "frameworks"
_test "framework runs in the foreground with its venv" \
  "venv python in $PROGRAMS_DIR/FakeRepo with fw.py --interactive" "$(launch_framework fakefw | tail -n 1)"

_test_summary

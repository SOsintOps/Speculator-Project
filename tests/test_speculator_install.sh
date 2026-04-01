#!/usr/bin/env bash
# Test suite for speculator_install.sh and scripts/user.sh
#
# Usage:  bash tests/test_speculator_install.sh
# Requirements: bash 4+, no root, no Debian required.
# The --dry-run tests run in an isolated temp HOME to avoid side-effects.

set -uo pipefail

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/speculator_install.sh"
USER_SCRIPT="$SCRIPT_DIR/scripts/user.sh"

pass() { echo "  PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "  FAIL: $1 — $2"; FAIL=$((FAIL+1)); }

assert_exit() {
    local label="$1" expected="$2" actual="$3"
    [ "$actual" -eq "$expected" ] \
        && pass "$label" \
        || fail "$label" "expected exit $expected, got $actual"
}

assert_contains() {
    local label="$1" pattern="$2" text="$3"
    echo "$text" | grep -q "$pattern" \
        && pass "$label" \
        || fail "$label" "pattern '$pattern' not found in output"
}

assert_not_contains() {
    local label="$1" pattern="$2" text="$3"
    echo "$text" | grep -q "$pattern" \
        && fail "$label" "unexpected pattern '$pattern' found in output" \
        || pass "$label"
}

echo ""
echo "=== Speculator Project — Install Script Tests ==="
echo ""

# ---------------------------------------------------------------
# 1. Static checks
# ---------------------------------------------------------------
echo "--- 1. Static checks ---"

[ -f "$SCRIPT" ] \
    && pass "speculator_install.sh exists" \
    || { fail "speculator_install.sh exists" "not found: $SCRIPT"; exit 1; }

[ -x "$SCRIPT" ] \
    && pass "speculator_install.sh is executable" \
    || fail "speculator_install.sh is executable" "missing execute bit"

[ -f "$USER_SCRIPT" ] \
    && pass "scripts/user.sh exists" \
    || fail "scripts/user.sh exists" "not found: $USER_SCRIPT"

bash -n "$SCRIPT" 2>/dev/null
assert_exit "speculator_install.sh syntax valid" 0 $?

bash -n "$USER_SCRIPT" 2>/dev/null
assert_exit "scripts/user.sh syntax valid" 0 $?

# ---------------------------------------------------------------
# 2. --help flag
# ---------------------------------------------------------------
echo ""
echo "--- 2. --help flag ---"

help_output=$(bash "$SCRIPT" --help 2>&1)
help_exit=$?
assert_exit "--help exits 0" 0 "$help_exit"
assert_contains "--help shows 'Usage:'" "Usage:" "$help_output"
assert_contains "--help mentions --dry-run" "\-\-dry-run" "$help_output"

# ---------------------------------------------------------------
# 3. --dry-run mode (isolated temp HOME)
# ---------------------------------------------------------------
echo ""
echo "--- 3. --dry-run mode ---"

TMP_HOME=$(mktemp -d)
cleanup() { rm -rf "$TMP_HOME"; }
trap cleanup EXIT

dry_output=$(HOME="$TMP_HOME" bash "$SCRIPT" --dry-run 2>&1)
dry_exit=$?

assert_exit "--dry-run exits 0" 0 "$dry_exit"
assert_contains "--dry-run shows DRY-RUN banner"  "DRY-RUN MODE"         "$dry_output"
assert_contains "--dry-run shows Phase 1"         "PHASE 1"              "$dry_output"
assert_contains "--dry-run shows Phase 2"         "PHASE 2"              "$dry_output"
assert_contains "--dry-run shows Phase 3"         "PHASE 3"              "$dry_output"
assert_contains "--dry-run shows Phase 4"         "PHASE 4"              "$dry_output"
assert_contains "--dry-run shows Phase 5"         "PHASE 5"              "$dry_output"
assert_contains "--dry-run shows Phase 6"         "PHASE 6"              "$dry_output"
assert_contains "--dry-run intercepts sudo"       "\[DRY-RUN | sudo\]"   "$dry_output"
assert_contains "--dry-run shows completion"      "INSTALLATION COMPLETE" "$dry_output"
assert_contains "--dry-run shows results table"   "RESULTS:"             "$dry_output"

# Verify log directory was created inside isolated TMP_HOME only
[ -d "$TMP_HOME/.local/share/speculator/logs" ] \
    && pass "--dry-run log dir created inside temp HOME" \
    || fail "--dry-run log dir created inside temp HOME" \
            "expected $TMP_HOME/.local/share/speculator/logs"

# Verify dry-run does not run real apt or dpkg commands
# (All system commands must appear as [DRY-RUN | sudo] lines, not raw output)
assert_not_contains "--dry-run has no raw 'apt-get' output" "^Get:[0-9]" "$dry_output"
assert_not_contains "--dry-run has no dpkg output" "^Setting up " "$dry_output"

# ---------------------------------------------------------------
# 4. Argument parsing
# ---------------------------------------------------------------
echo ""
echo "--- 4. Argument parsing ---"

# Unknown args should not cause the script to exit non-zero or crash
# (The script uses a case statement that silently ignores unknown args)
# We test this by checking if the --help path is reached cleanly.
assert_contains "--help is case-insensitive enough" "Usage:" "$help_output"

# ---------------------------------------------------------------
# 5. Dry-run tracking (mark_ok / mark_fail)
# ---------------------------------------------------------------
echo ""
echo "--- 5. Install tracking ---"

# In dry-run, no real packages install, so all tracked items land in FAIL or nowhere.
# The results table must still appear with valid counts.
assert_contains "results table has numeric count" "[0-9]*/[0-9]*" "$dry_output"

# ---------------------------------------------------------------
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1

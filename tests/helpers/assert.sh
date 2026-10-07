#!/usr/bin/env bash
###############################################################################
## tests/helpers/assert.sh — minimal assertions shared by the test files
## Source it, call _test for each check, then finish with _test_summary.
###############################################################################

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

# _true CONDITION...: "true" when the command succeeds, "false" otherwise
_true() { "$@" >/dev/null 2>&1 && echo true || echo false; }

_section() { echo ""; echo "── $1 ──"; }

_test_summary() {
  echo ""
  printf "  \033[32m✔ %d passed\033[0m   \033[31m✖ %d failed\033[0m   (total: %d)\n" \
    "$PASS" "$FAIL" "$TOTAL"
  echo ""
  [ "$FAIL" -eq 0 ]
}

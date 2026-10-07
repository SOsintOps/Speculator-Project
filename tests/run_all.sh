#!/usr/bin/env bash
###############################################################################
## tests/run_all.sh — syntax gate, ShellCheck gate, then every tests/test_*.sh
## Usage: bash tests/run_all.sh   (exit code 0 only when everything passes)
###############################################################################

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
declare -a results=()
failed=0

mapfile -d '' scripts < <(find . -type f -name '*.sh' -not -path './.git/*' -print0)

echo "==> bash -n on ${#scripts[@]} scripts"
syntax_ok=true
for f in "${scripts[@]}"; do
  bash -n "$f" || { echo "    syntax error: $f"; syntax_ok=false; }
done
$syntax_ok && results+=("PASS  bash -n") || { results+=("FAIL  bash -n"); failed=1; }

if command -v shellcheck >/dev/null 2>&1; then
  echo "==> shellcheck --severity=error"
  if shellcheck --severity=error "${scripts[@]}"; then
    results+=("PASS  shellcheck")
  else
    results+=("FAIL  shellcheck"); failed=1
  fi
else
  results+=("SKIP  shellcheck (not installed)")
fi

# The tests source the scripts, so they only run when the syntax is valid.
if $syntax_ok; then
  for t in tests/test_*.sh; do
    echo "==> $t"
    if bash "$t"; then
      results+=("PASS  $t")
    else
      results+=("FAIL  $t"); failed=1
    fi
  done
fi

echo ""
echo "═══════════════════════════════════════════════════"
printf '  %s\n' "${results[@]}"
echo "═══════════════════════════════════════════════════"
exit "$failed"

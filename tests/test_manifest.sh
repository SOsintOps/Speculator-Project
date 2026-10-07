#!/usr/bin/env bash
###############################################################################
## test_manifest.sh — config/tools.conf integrity and agreement with the
## installer and the launcher scripts. No network, no Zenity, no tools needed.
###############################################################################

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tests/helpers/assert.sh"
CONF="$ROOT/config/tools.conf"
INSTALLER="$ROOT/speculator_install.sh"

CATEGORIES="email username fullname phone hash domain instagram reddit video archives image frameworks sharelink"
PLACEHOLDERS="target outfile outdir programs_dir session_id"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Manifest Tests — config/tools.conf"
echo "═══════════════════════════════════════════════════"

entries() { grep -v -e '^#' -e '^[[:space:]]*$' "$CONF"; }

_section "1. Line format"
bad_fields=0
while IFS= read -r line; do
  n=$(awk -F'|' '{print NF}' <<< "$line")
  [ "$n" -eq 9 ] || { echo "     9 fields expected, $n found: $line"; ((bad_fields++)); }
done < <(entries)
_test "every entry has 9 fields" "0" "$bad_fields"
_test "ids are unique" "" "$(entries | cut -d'|' -f2 | sort | uniq -d)"
_test "tool count = 58" "58" "$(entries | wc -l | tr -d ' ')"

_section "2. Field values"
while IFS='|' read -r name id cat ctype cval cmd ext venv vname; do
  _test "$id: known category ($cat)" "true" "$(_true grep -qw "$cat" <<< "$CATEGORIES")"
  _test "$id: check type ($ctype)" "true" "$(_true grep -qxE 'binary|repo|pipx|go' <<< "$ctype")"
  _test "$id: needs_venv yes/no" "true" "$(_true grep -qxE 'yes|no' <<< "$venv")"
  if [ "$venv" = "yes" ]; then
    _test "$id: venv name follows the installer" "true" \
      "$(_true grep -qxE "${cval//./\\.}Environment|\\.venv" <<< "$vname")"
  fi
  for ph in $(grep -oE '\{[a-z_]+\}' <<< "$cmd" | tr -d '{}' | sort -u); do
    _test "$id: placeholder {$ph} is known" "true" "$(_true grep -qw "$ph" <<< "$PLACEHOLDERS")"
  done
  [ -n "$name" ] && [ -n "$cmd" ] && [ -n "$ext" ] || _test "$id: name, command and extension set" "set" "empty"
done < <(entries)

_section "3. Every tool is installed by speculator_install.sh"
while IFS='|' read -r _ id _ ctype cval _; do
  case "$ctype" in
    repo) _test "$id: installer clones $cval" "true" "$(_true grep -qE "/${cval}(\\.git)?[\"/ ]" "$INSTALLER")" ;;
    go)   _test "$id: installer builds $cval" "true" "$(_true grep -qE "\"(go|bin):${cval}\"" "$INSTALLER")" ;;
  esac
done < <(entries)

_section "4. Every category has a launcher"
for c in $CATEGORIES; do
  _test "category $c has tools" "true" "$(_true grep -q "^[^#][^|]*|[^|]*|$c|" "$CONF")"
  _test "category $c is run by a script" "true" \
    "$(_true grep -rqE "run_category \"$c\"|load_manifest \"$c\"" "$ROOT/scripts")"
done

_section "5. Desktop shortcuts"
for d in "$ROOT"/shortcuts/*.desktop; do
  n="$(basename "$d")"
  icon="$(sed -n 's|^Icon=.*/||p' "$d")"
  if [ -n "$icon" ]; then
    _test "$n: icon $icon is in media/icons" "true" "$(_true test -f "$ROOT/media/icons/$icon")"
  fi
  script="$(sed -n 's|^Exec=__HOME__/.local/share/speculator/scripts/||p' "$d")"
  if [ -n "$script" ]; then
    _test "$n: script $script exists" "true" "$(_true test -f "$ROOT/scripts/$script")"
  fi
done

_test_summary

#!/usr/bin/env bash
# maigret-web.sh — Launch Maigret web interface
# Version: 0.2.0

set -euo pipefail

PORT=5001
URL="http://127.0.0.1:${PORT}"
MAIGRET_BIN="$HOME/.local/bin/maigret"
EVIDENCE_DIR="$HOME/Downloads/evidence/maigret"

if [ ! -x "$MAIGRET_BIN" ]; then
    echo "ERROR: maigret not found at $MAIGRET_BIN"
    echo "Install it with: pipx install maigret"
    read -rp "Press Enter to close..."
    exit 1
fi

MAIGRET_REPORTS="/tmp/maigret_reports"

mkdir -p "$EVIDENCE_DIR"

mkdir -p "$MAIGRET_REPORTS"
if [ -L "$EVIDENCE_DIR/reports" ]; then
    : # symlink already exists
elif [ -d "$EVIDENCE_DIR/reports" ]; then
    rmdir "$EVIDENCE_DIR/reports" 2>/dev/null || rm -rf "$EVIDENCE_DIR/reports"
    ln -s "$MAIGRET_REPORTS" "$EVIDENCE_DIR/reports"
else
    ln -s "$MAIGRET_REPORTS" "$EVIDENCE_DIR/reports"
fi

echo "Starting Maigret web UI on ${URL} ..."
echo "Reports: ${EVIDENCE_DIR}/reports/"
sleep 1
xdg-open "$URL" 2>/dev/null &

exec "$MAIGRET_BIN" --web "$PORT"

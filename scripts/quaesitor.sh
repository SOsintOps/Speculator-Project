#!/usr/bin/env bash
# quaesitor.sh — Launch Quaesitor (SOsintOps fork of OSInt Graph): the case
# as a graph in the browser. The archive is kept in the evidence folder.
# Version: 0.2.0

set -euo pipefail

# 5000 is Changedetection.io, 5001 Maigret Web: Quaesitor takes 5002.
PORT=5002
URL="http://127.0.0.1:${PORT}"
PROGRAMS_DIR="$HOME/.local/share/speculator/programs"
QUAESITOR_DIR="$PROGRAMS_DIR/quaesitor"
QUAESITOR_PY="$QUAESITOR_DIR/quaesitorEnvironment/bin/python"
DATA_DIR="$HOME/Downloads/evidence/quaesitor"

if [ ! -f "$QUAESITOR_DIR/app.py" ] || [ ! -x "$QUAESITOR_PY" ]; then
    echo "ERROR: Quaesitor not found at $QUAESITOR_DIR"
    echo "Run speculator_install.sh to install it."
    read -rp "Press Enter to close..."
    exit 1
fi

mkdir -p "$DATA_DIR"

echo "Starting Quaesitor on ${URL} ..."
echo "Archive: ${DATA_DIR}/"
echo "Close this window or press Ctrl+C to stop it."

# Open the browser only once the server answers (up to 40 s), so the first
# page is not a connection error; the server keeps this terminal.
(
    for _i in $(seq 1 80); do
        if curl -s -o /dev/null "$URL"; then
            xdg-open "$URL" 2>/dev/null
            exit 0
        fi
        sleep 0.5
    done
    echo "Quaesitor did not answer on ${URL}; open it by hand once it is up."
) &

cd "$QUAESITOR_DIR"
DATA_DIR="$DATA_DIR" PORT="$PORT" exec "$QUAESITOR_PY" app.py

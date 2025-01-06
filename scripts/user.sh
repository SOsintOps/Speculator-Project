#!/usr/bin/env bash
################################################################################
## OSINT Unified Input Script (English Version + Improvements)
## - Single input (username, email or hash)
## - Automatically detects the type with basic regex or NameThatHash (if installed)
## - Offers a menu to run the relevant OSINT tools
## - Saves the results in ~/Desktop/evidences/<inputValue>
## - Moves Blackbird/Maigret reports from their folders to the dedicated subfolder
## - Includes a "Run all" option for each category
## - Checks required tools before starting
################################################################################

set -euo pipefail

EVIDENCE_DIR="$HOME/Desktop/evidences"

###############################################################################
# 0. Pre-check: verify that required tools are installed
###############################################################################
REQUIRED_TOOLS=(
  zenity
  holehe
  socialscan
  python3
  ghunt
  h8mail
  nth
  sth
  sherlock
  bdfr
  maigret
)

check_required_tools() {
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      zenity --error --text="The tool '$tool' is not installed or not in PATH.\nPlease install it before running this script."
      exit 1
    fi
  done
}

###############################################################################
# 1. Ensure ~/Desktop/evidences directory exists
###############################################################################
ensure_base_dir() {
  if [ ! -d "$EVIDENCE_DIR" ]; then
    mkdir -p "$EVIDENCE_DIR"
  fi
}

###############################################################################
# 2. Advanced hash detection using NameThatHash
#    Returns 0 (success) if "nth" believes it's a known hash; otherwise 1 (fail)
###############################################################################
advanced_hash_detection() {
  local value="$1"

  # If nth is present, try to identify
  local detection
  detection="$(nth --text "$value" 2>/dev/null || true)"

  # If we find "Possible Hashes" in the output, we assume it's a valid hash
  if echo "$detection" | grep -iq "Possible Hashes"; then
    return 0
  fi
  return 1
}

###############################################################################
# 3. Classify the input: return "email", "hash" or "username"
###############################################################################
classify_input() {
  local value="$1"

  # Very basic email check
  if [[ "$value" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    echo "email"
    return
  fi

  # Try advanced hash detection with nth
  if advanced_hash_detection "$value"; then
    echo "hash"
    return
  fi

  # Fallback manual check for common hash lengths (MD5=32, SHA1=40, SHA256=64)
  local length=${#value}
  if [[ "$value" =~ ^[A-Fa-f0-9]+$ ]]; then
    if [ "$length" -eq 32 ] || [ "$length" -eq 40 ] || [ "$length" -eq 64 ]; then
      echo "hash"
      return
    fi
  fi

  # Otherwise treat as username
  echo "username"
}

###############################################################################
# Create or locate the subfolder for a specific inputValue
###############################################################################
create_session_dir() {
  local inputValue="$1"
  local sessionDir="$EVIDENCE_DIR/$inputValue"
  if [ ! -d "$sessionDir" ]; then
    mkdir -p "$sessionDir"
  fi
  echo "$sessionDir"
}

###############################################################################
# 4. Run ALL Email tools
###############################################################################
run_all_email_tools() {
  local inputValue="$1"
  local sessionDir
  sessionDir="$(create_session_dir "$inputValue")"

  # 1) Holehe
  holehe "$inputValue" > "$sessionDir/$inputValue-Holehe.txt"

  # 2) SocialScan
  socialscan "$inputValue" --json "$sessionDir/$inputValue-socialscan.txt"

  # 3) Eyes
  pushd ~/Downloads/Programs/eyes/Eyes >/dev/null 2>&1
  python3 eyes.py "$inputValue"
  popd >/dev/null 2>&1

  # 4) GHunt
  ghunt email "$inputValue" > "$sessionDir/$inputValue-GHunt.txt"

  # 5) H8Mail
  h8mail -t "$inputValue" -c ~/Downloads/h8mail_config.ini \
    -o "$sessionDir/$inputValue-H8Mail.txt"

  zenity --info --text="All email tools have finished.\nResults are in: $sessionDir"
}

###############################################################################
# 5. Menu for Email tools
###############################################################################
run_email_tools() {
  local inputValue="$1"
  ensure_base_dir
  local sessionDir
  sessionDir="$(create_session_dir "$inputValue")"

  local choice
  choice=$(zenity --list \
    --title="Email Tools" \
    --column="Tool" \
    "Email-Holehe" \
    "Email-SocialScan" \
    "Email-Eyes" \
    "Email-GHunt" \
    "Email-H8Mail" \
    "RUN ALL (Email Tools)" \
    --height=300 --width=300)

  case "$choice" in
    "Email-Holehe")
      holehe "$inputValue" > "$sessionDir/$inputValue-Holehe.txt"
      xdg-open "$sessionDir/$inputValue-Holehe.txt" >/dev/null 2>&1 &
      ;;
    "Email-SocialScan")
      socialscan "$inputValue" --json "$sessionDir/$inputValue-socialscan.txt"
      xdg-open "$sessionDir/$inputValue-socialscan.txt" >/dev/null 2>&1 &
      ;;
    "Email-Eyes")
      pushd ~/Downloads/Programs/eyes/Eyes >/dev/null 2>&1
      python3 eyes.py "$inputValue"
      popd >/dev/null 2>&1
      zenity --info --text="Eyes completed. Check the eyes/Eyes folder for any extra outputs.\nPartial results are not automatically saved here."
      ;;
    "Email-GHunt")
      ghunt email "$inputValue" > "$sessionDir/$inputValue-GHunt.txt"
      xdg-open "$sessionDir/$inputValue-GHunt.txt" >/dev/null 2>&1 &
      ;;
    "Email-H8Mail")
      h8mail -t "$inputValue" -c ~/Downloads/h8mail_config.ini \
        -o "$sessionDir/$inputValue-H8Mail.txt"
      xdg-open "$sessionDir/$inputValue-H8Mail.txt" >/dev/null 2>&1 &
      ;;
    "RUN ALL (Email Tools)")
      run_all_email_tools "$inputValue"
      ;;
  esac
}

###############################################################################
# 6. Run ALL Hash tools
###############################################################################
run_all_hash_tools() {
  local inputValue="$1"
  local sessionDir
  sessionDir="$(create_session_dir "$inputValue")"

  # 1) NameThatHash
  nth --text "$inputValue" | tee "$sessionDir/$inputValue-nth.txt"

  # 2) SearchThatHash
  sth --text "$inputValue" | tee "$sessionDir/$inputValue-sth.txt"

  zenity --info --text="All hash tools have finished.\nResults are in: $sessionDir"
}

###############################################################################
# 7. Menu for Hash tools
###############################################################################
run_hash_tools() {
  local inputValue="$1"
  ensure_base_dir
  local sessionDir
  sessionDir="$(create_session_dir "$inputValue")"

  local choice
  choice=$(zenity --list \
    --title="Hash Tools" \
    --column="Tool" \
    "Hash-NameThatHash" \
    "Hash-SearchThatHash" \
    "RUN ALL (Hash Tools)" \
    --height=200 --width=300)

  case "$choice" in
    "Hash-NameThatHash")
      nth --text "$inputValue" | tee "$sessionDir/$inputValue-nth.txt"
      xdg-open "$sessionDir/$inputValue-nth.txt" >/dev/null 2>&1 &
      ;;
    "Hash-SearchThatHash")
      sth --text "$inputValue" | tee "$sessionDir/$inputValue-sth.txt"
      xdg-open "$sessionDir/$inputValue-sth.txt" >/dev/null 2>&1 &
      ;;
    "RUN ALL (Hash Tools)")
      run_all_hash_tools "$inputValue"
      ;;
  esac
}

###############################################################################
# 8. Run ALL Username tools
###############################################################################
run_all_username_tools() {
  local inputValue="$1"
  local sessionDir
  sessionDir="$(create_session_dir "$inputValue")"

  # 1) Sherlock
  sherlock "$inputValue" --csv -o "$sessionDir/Sherlock-$inputValue.csv"

  # 2) SocialScan
  socialscan "$inputValue" --json "$sessionDir/$inputValue-socialscan.txt"

  # 3) Blackbird
  pushd ~/Downloads/Programs/blackbird >/dev/null 2>&1
  python3 blackbird.py -u "$inputValue" --pdf
  popd >/dev/null 2>&1
  # Move entire contents from results to sessionDir
  mv -f ~/Downloads/Programs/blackbird/results/* "$sessionDir" 2>/dev/null || true

  # 4) Maigret
  maigret -a -P -T "$inputValue"
  mv -f ~/Downloads/Programs/Maigret/reports/*"$inputValue"* "$sessionDir" 2>/dev/null || true

  # 5) WhatsMyName
  pushd ~/Downloads/Programs/WhatsMyName-Python >/dev/null 2>&1
  python3 whatsmyname.py -u "$inputValue" | tee "$sessionDir/$inputValue-WhatsMyName.txt"
  popd >/dev/null 2>&1

  # 6) BDFR
  mkdir -p "$sessionDir/BDFR"
  bdfr archive "$sessionDir/BDFR" --user "$inputValue" --submitted
  bdfr archive "$sessionDir/BDFR" --user "$inputValue" --all-comments

  # 7) H8Mail
  h8mail -t "$inputValue" -q username \
    -c ~/Downloads/h8mail_config.ini \
    -o "$sessionDir/$inputValue-H8Mail.txt"

  zenity --info --text="All username tools have finished.\nReports have been moved to $sessionDir."
}

###############################################################################
# 9. Menu for Username tools
###############################################################################
run_username_tools() {
  local inputValue="$1"
  ensure_base_dir
  local sessionDir
  sessionDir="$(create_session_dir "$inputValue")"

  local choice
  choice=$(zenity --list \
    --title="Username Tools" \
    --column="Tool" \
    "Username-Sherlock" \
    "Username-SocialScan" \
    "Username-Blackbird" \
    "Username-Maigret" \
    "Username-WhatsMyName" \
    "Username-BDFR" \
    "Username-H8Mail" \
    "RUN ALL (Username Tools)" \
    --height=400 --width=300)

  case "$choice" in
    "Username-Sherlock")
      sherlock "$inputValue" --csv -o "$sessionDir/Sherlock-$inputValue.csv"
      xdg-open "$sessionDir/Sherlock-$inputValue.csv" >/dev/null 2>&1 &
      ;;
    "Username-SocialScan")
      socialscan "$inputValue" --json "$sessionDir/$inputValue-socialscan.txt"
      xdg-open "$sessionDir/$inputValue-socialscan.txt" >/dev/null 2>&1 &
      ;;
    "Username-Blackbird")
      pushd ~/Downloads/Programs/blackbird >/dev/null 2>&1
      python3 blackbird.py -u "$inputValue" --pdf
      popd >/dev/null 2>&1
      # Move entire contents from results to sessionDir
      mv -f ~/Downloads/Programs/blackbird/results/* "$sessionDir" 2>/dev/null || true
      zenity --info --text="Blackbird done. Files in 'results' were moved to $sessionDir."
      ;;
    "Username-Maigret")
      maigret -a -P -T "$inputValue"
      mv -f ~/Downloads/Programs/Maigret/reports/*"$inputValue"* "$sessionDir" 2>/dev/null || true
      zenity --info --text="Maigret done. Reports moved to $sessionDir."
      ;;
    "Username-WhatsMyName")
      pushd ~/Downloads/Programs/WhatsMyName-Python >/dev/null 2>&1
      python3 whatsmyname.py -u "$inputValue" | tee "$sessionDir/$inputValue-WhatsMyName.txt"
      popd >/dev/null 2>&1
      xdg-open "$sessionDir/$inputValue-WhatsMyName.txt" >/dev/null 2>&1 &
      ;;
    "Username-BDFR")
      mkdir -p "$sessionDir/BDFR"
      bdfr archive "$sessionDir/BDFR" --user "$inputValue" --submitted
      bdfr archive "$sessionDir/BDFR" --user "$inputValue" --all-comments
      xdg-open "$sessionDir/BDFR" >/dev/null 2>&1 &
      ;;
    "Username-H8Mail")
      h8mail -t "$inputValue" -q username \
        -c ~/Downloads/h8mail_config.ini \
        -o "$sessionDir/$inputValue-H8Mail.txt"
      xdg-open "$sessionDir/$inputValue-H8Mail.txt" >/dev/null 2>&1 &
      ;;
    "RUN ALL (Username Tools)")
      run_all_username_tools "$inputValue"
      ;;
  esac
}

###############################################################################
# 10. Main flow
###############################################################################
main() {
  # 10.a) Check that all required tools are installed
  check_required_tools

  # 10.b) Prompt for input
  local inputValue
  inputValue=$(zenity --entry \
    --title="OSINT Tool - Single Input" \
    --text="Enter a username, email, or hash:" \
    --width=400)

  # If user cancels
  if [ -z "${inputValue:-}" ]; then
    exit 0
  fi

  # 10.c) Classify
  local category
  category=$(classify_input "$inputValue")

  # 10.d) Show the menu relevant to the detected category
  case "$category" in
    "email")
      run_email_tools "$inputValue"
      ;;
    "hash")
      run_hash_tools "$inputValue"
      ;;
    "username")
      run_username_tools "$inputValue"
      ;;
  esac

  # 10.e) Ask if user wants to repeat
  zenity --question \
    --title="Repeat?" \
    --text="Do you want to run another query?" \
    --ok-label="Yes" \
    --cancel-label="No"

  if [ "$?" -eq 0 ]; then
    main
  else
    exit 0
  fi
}

main



#!/usr/bin/env bash
###############################################################################
## tests/helpers/mock_zenity.sh — headless stand-in for zenity
## Source it after the script under test, then queue the answers with
## zenity_answers "first" "second" ... Each dialog takes the next answer;
## "<cancel>" makes it return 1 like the Cancel button, and an empty queue
## cancels every dialog. zenity_calls lists the dialogs shown (first option).
## The queue is a file because zenity usually runs inside $( ).
###############################################################################

_ZENITY_FILE="$(mktemp)"
: > "${_ZENITY_FILE}.calls"

zenity_answers() { printf '%s\n' "$@" > "$_ZENITY_FILE"; : > "${_ZENITY_FILE}.calls"; }

zenity() {
  echo "$1" >> "${_ZENITY_FILE}.calls"
  [ -s "$_ZENITY_FILE" ] || return 1
  local answer
  answer="$(head -n 1 "$_ZENITY_FILE")"
  sed -i '1d' "$_ZENITY_FILE"
  [ "$answer" = "<cancel>" ] && return 1
  printf '%s\n' "$answer"
}

zenity_calls() { cat "${_ZENITY_FILE}.calls"; }

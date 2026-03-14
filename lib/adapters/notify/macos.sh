#!/usr/bin/env bash
# lib/adapters/notify/macos.sh — Notification adapter using osascript (macOS)

# Guard against double-sourcing
[[ -n "${_KALL_NOTIFY_MACOS_LOADED:-}" ]] && return 0
_KALL_NOTIFY_MACOS_LOADED=1

# _notify_send TITLE BODY [-i icon] [-t timeout] [-u urgency]
_notify_send() {
  local title="$1"
  local body="$2"
  shift 2

  # Parse optional flags (ignored on macOS but accepted for interface compat)
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|-t|-u) shift 2 ;;
      *)        shift ;;
    esac
  done

  osascript -e "display notification \"$body\" with title \"$title\""
}

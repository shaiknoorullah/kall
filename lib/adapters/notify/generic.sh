#!/usr/bin/env bash
# lib/adapters/notify/generic.sh — Fallback notification adapter (stderr echo)

# Guard against double-sourcing
[[ -n "${_KALL_NOTIFY_GENERIC_LOADED:-}" ]] && return 0
_KALL_NOTIFY_GENERIC_LOADED=1

# _notify_send TITLE BODY [-i icon] [-t timeout] [-u urgency]
_notify_send() {
  local title="$1"
  local body="$2"
  shift 2

  local urgency="normal"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -u) urgency="$2"; shift 2 ;;
      -i|-t) shift 2 ;;
      *)     shift ;;
    esac
  done

  echo "[notify:${urgency}] ${title}: ${body}" >&2
}

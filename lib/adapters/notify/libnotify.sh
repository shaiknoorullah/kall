#!/usr/bin/env bash
# lib/adapters/notify/libnotify.sh — Notification adapter using notify-send (libnotify)

# Guard against double-sourcing
[[ -n "${_KALL_NOTIFY_LIBNOTIFY_LOADED:-}" ]] && return 0
_KALL_NOTIFY_LIBNOTIFY_LOADED=1

# _notify_send TITLE BODY [-i icon] [-t timeout] [-u urgency]
_notify_send() {
  local title="$1"
  local body="$2"
  shift 2

  local icon="" timeout="" urgency=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) icon="$2"; shift 2 ;;
      -t) timeout="$2"; shift 2 ;;
      -u) urgency="$2"; shift 2 ;;
      *)  shift ;;
    esac
  done

  local args=()
  [[ -n "$icon" ]] && args+=(-i "$icon")
  [[ -n "$timeout" ]] && args+=(-t "$timeout")
  [[ -n "$urgency" ]] && args+=(-u "$urgency")

  notify-send "${args[@]}" "$title" "$body"
}

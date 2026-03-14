#!/usr/bin/env bash
# lib/notify.sh — Notification convenience wrappers
#
# Provides simple functions that delegate to _notify_send() from the
# loaded notify adapter (libnotify, macos, or generic).

# Guard against double-sourcing
[[ -n "${_KALL_NOTIFY_LOADED:-}" ]] && return 0
_KALL_NOTIFY_LOADED=1

# notify TITLE [BODY]
#   Send a standard notification with 3-second timeout.
notify() {
  _notify_send "$1" "${2:-}" -t 3000
}

# notify_critical TITLE [BODY]
#   Send a critical/urgent notification (no auto-dismiss).
notify_critical() {
  _notify_send "$1" "${2:-}" -u critical
}

# notify_with_icon TITLE [BODY] [ICON]
#   Send a notification with a custom icon and 3-second timeout.
notify_with_icon() {
  _notify_send "$1" "${2:-}" -i "${3:-}" -t 3000
}

#!/usr/bin/env bash
# lib/adapters/wm/generic.sh — Safe-default WM adapter
#
# Provides fallback implementations when no specific WM is detected.
# wm_lock tries hyprlock -> swaylock -> i3lock -> warn.

# Guard against double-sourcing
[[ -n "${_KALL_WM_GENERIC_LOADED:-}" ]] && return 0
_KALL_WM_GENERIC_LOADED=1

wm_exit() {
  log_warn "wm_exit: no WM adapter configured; cannot exit"
  return 1
}

wm_lock() {
  if command -v hyprlock &>/dev/null; then
    hyprlock
  elif command -v swaylock &>/dev/null; then
    swaylock
  elif command -v i3lock &>/dev/null; then
    i3lock
  else
    log_warn "wm_lock: no screen locker found (tried hyprlock, swaylock, i3lock)"
    return 0
  fi
}

get_monitors() {
  echo '[{"name":"default","width":1920,"height":1080,"focused":true}]'
}

get_active_window() {
  echo '{"title":"unknown","class":"unknown","pid":0}'
}

get_workspaces() {
  echo '[{"id":1,"name":"1","focused":true}]'
}

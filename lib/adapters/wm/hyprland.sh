#!/usr/bin/env bash
# lib/adapters/wm/hyprland.sh — Hyprland WM adapter (hyprctl based)

# Guard against double-sourcing
[[ -n "${_KALL_WM_HYPRLAND_LOADED:-}" ]] && return 0
_KALL_WM_HYPRLAND_LOADED=1

wm_exit() {
  hyprctl dispatch exit
}

wm_lock() {
  if command -v hyprlock &>/dev/null; then
    hyprlock
  elif command -v swaylock &>/dev/null; then
    swaylock
  else
    log_warn "wm_lock: no screen locker found"
    return 1
  fi
}

get_monitors() {
  hyprctl monitors -j
}

get_active_window() {
  hyprctl activewindow -j
}

get_workspaces() {
  hyprctl workspaces -j
}

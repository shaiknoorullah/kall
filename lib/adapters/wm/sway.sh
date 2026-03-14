#!/usr/bin/env bash
# lib/adapters/wm/sway.sh — Sway WM adapter (swaymsg based)

# Guard against double-sourcing
[[ -n "${_KALL_WM_SWAY_LOADED:-}" ]] && return 0
_KALL_WM_SWAY_LOADED=1

wm_exit() {
  swaymsg exit
}

wm_lock() {
  swaylock
}

get_monitors() {
  swaymsg -t get_outputs -r
}

get_active_window() {
  local tree
  tree="$(swaymsg -t get_tree -r 2>/dev/null)" || {
    echo '{"title":"unknown","class":"unknown","pid":0}'
    return
  }
  echo "$tree" | jq '{title: (.nodes[].nodes[]? | recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true) | .name // "unknown"), class: (.nodes[].nodes[]? | recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true) | .app_id // "unknown"), pid: (.nodes[].nodes[]? | recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true) | .pid // 0)}' 2>/dev/null || echo '{"title":"unknown","class":"unknown","pid":0}'
}

get_workspaces() {
  swaymsg -t get_workspaces -r
}

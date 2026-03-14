#!/usr/bin/env bash
# lib/adapters/wm/i3.sh — i3 WM adapter (i3-msg/xrandr/xdotool based)

# Guard against double-sourcing
[[ -n "${_KALL_WM_I3_LOADED:-}" ]] && return 0
_KALL_WM_I3_LOADED=1

wm_exit() {
  i3-msg exit
}

wm_lock() {
  i3lock -c 1E1E2E
}

get_monitors() {
  if command -v xrandr &>/dev/null; then
    xrandr --query | awk '
      / connected/ {
        name=$1; primary=0; focused=0
        if ($3 == "primary") { primary=1; focused=1 }
        for (i=1; i<=NF; i++) {
          if ($i ~ /^[0-9]+x[0-9]+\+/) {
            split($i, res, /[x+]/)
            printf "{\"name\":\"%s\",\"width\":%s,\"height\":%s,\"focused\":%s}\n", name, res[1], res[2], (focused ? "true" : "false")
          }
        }
      }' | jq -s '.'
  else
    echo '[{"name":"default","width":1920,"height":1080,"focused":true}]'
  fi
}

get_active_window() {
  if command -v xdotool &>/dev/null; then
    local wid wname wclass wpid
    # shellcheck disable=SC2034
    wid="$(xdotool getactivewindow 2>/dev/null)" || {
      echo '{"title":"unknown","class":"unknown","pid":0}'
      return
    }
    wname="$(xdotool getactivewindow getwindowname 2>/dev/null || echo "unknown")"
    wclass="$(xdotool getactivewindow getwindowclassname 2>/dev/null || echo "unknown")"
    wpid="$(xdotool getactivewindow getwindowpid 2>/dev/null || echo "0")"
    printf '{"title":"%s","class":"%s","pid":%s}\n' "$wname" "$wclass" "$wpid"
  else
    echo '{"title":"unknown","class":"unknown","pid":0}'
  fi
}

get_workspaces() {
  i3-msg -t get_workspaces 2>/dev/null || echo '[{"id":1,"name":"1","focused":true}]'
}

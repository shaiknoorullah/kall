#!/usr/bin/env bash
# lib/adapters/wm/bspwm.sh — bspwm WM adapter (bspc based)

# Guard against double-sourcing
[[ -n "${_KALL_WM_BSPWM_LOADED:-}" ]] && return 0
_KALL_WM_BSPWM_LOADED=1

wm_exit() {
  bspc quit
}

wm_lock() {
  if command -v i3lock &>/dev/null; then
    i3lock -c 1E1E2E
  elif command -v slock &>/dev/null; then
    slock
  else
    log_warn "wm_lock: no screen locker found (tried i3lock, slock)"
    return 1
  fi
}

get_monitors() {
  local monitors=()
  local focused_monitor
  focused_monitor="$(bspc query -M -m focused --names 2>/dev/null || echo "")"
  while IFS= read -r name; do
    local focused="false"
    [[ "$name" == "$focused_monitor" ]] && focused="true"
    monitors+=("{\"name\":\"$name\",\"width\":0,\"height\":0,\"focused\":$focused}")
  done < <(bspc query -M --names 2>/dev/null)
  if [[ ${#monitors[@]} -eq 0 ]]; then
    echo '[{"name":"default","width":1920,"height":1080,"focused":true}]'
  else
    local IFS=','
    echo "[${monitors[*]}]"
  fi
}

get_active_window() {
  local wid
  wid="$(bspc query -N -n focused 2>/dev/null)" || {
    echo '{"title":"unknown","class":"unknown","pid":0}'
    return
  }
  if command -v xdotool &>/dev/null; then
    local wname wclass wpid
    wname="$(xdotool getwindowname "$wid" 2>/dev/null || echo "unknown")"
    wclass="$(xdotool getwindowclassname "$wid" 2>/dev/null || echo "unknown")"
    wpid="$(xdotool getwindowpid "$wid" 2>/dev/null || echo "0")"
    printf '{"title":"%s","class":"%s","pid":%s}\n' "$wname" "$wclass" "$wpid"
  else
    printf '{"title":"unknown","class":"0x%s","pid":0}\n' "$wid"
  fi
}

get_workspaces() {
  local workspaces=()
  local focused_desktop
  focused_desktop="$(bspc query -D -d focused --names 2>/dev/null || echo "")"
  local id=1
  while IFS= read -r name; do
    local focused="false"
    [[ "$name" == "$focused_desktop" ]] && focused="true"
    workspaces+=("{\"id\":$id,\"name\":\"$name\",\"focused\":$focused}")
    (( id++ ))
  done < <(bspc query -D --names 2>/dev/null)
  if [[ ${#workspaces[@]} -eq 0 ]]; then
    echo '[{"id":1,"name":"1","focused":true}]'
  else
    local IFS=','
    echo "[${workspaces[*]}]"
  fi
}

#!/usr/bin/env bash
# lib/adapters/wm/macos.sh — macOS WM adapter (osascript/pmset based)

# Guard against double-sourcing
[[ -n "${_KALL_WM_MACOS_LOADED:-}" ]] && return 0
_KALL_WM_MACOS_LOADED=1

wm_exit() {
  osascript -e 'tell application "System Events" to log out'
}

wm_lock() {
  pmset displaysleepnow
}

get_monitors() {
  local count
  count="$(osascript -e 'tell application "Image Events" to count displays' 2>/dev/null || echo "1")"
  if [[ "$count" -le 1 ]]; then
    local res
    res="$(osascript -e 'tell application "Finder" to get bounds of window of desktop' 2>/dev/null || echo "")"
    if [[ -n "$res" ]]; then
      local w h
      w="$(echo "$res" | awk -F', ' '{print $3}')"
      h="$(echo "$res" | awk -F', ' '{print $4}')"
      echo "[{\"name\":\"main\",\"width\":${w:-1920},\"height\":${h:-1080},\"focused\":true}]"
    else
      echo '[{"name":"main","width":1920,"height":1080,"focused":true}]'
    fi
  else
    echo '[{"name":"main","width":1920,"height":1080,"focused":true}]'
  fi
}

get_active_window() {
  local app_name window_name
  app_name="$(osascript -e '
    tell application "System Events"
      set frontApp to name of first application process whose frontmost is true
    end tell
    return frontApp
  ' 2>/dev/null || echo "unknown")"
  window_name="$(osascript -e '
    tell application "System Events"
      set frontApp to first application process whose frontmost is true
      set winName to name of first window of frontApp
    end tell
    return winName
  ' 2>/dev/null || echo "unknown")"
  printf '{"title":"%s","class":"%s","pid":0}\n' "$window_name" "$app_name"
}

get_workspaces() {
  local count
  count="$(osascript -e '
    tell application "System Events"
      set desktopCount to count of desktops
    end tell
    return desktopCount
  ' 2>/dev/null || echo "1")"
  local workspaces=()
  local i
  for (( i = 1; i <= count; i++ )); do
    local focused="false"
    [[ "$i" -eq 1 ]] && focused="true"
    workspaces+=("{\"id\":$i,\"name\":\"$i\",\"focused\":$focused}")
  done
  local IFS=','
  echo "[${workspaces[*]}]"
}

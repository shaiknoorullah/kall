#!/usr/bin/env bash
# lib/platform.sh — Cross-platform abstractions for clipboard, screenshots, wallpaper, URLs
#
# Loads WM and notify adapters, then exposes unified platform functions
# that dispatch based on $KALL_SESSION (wayland/x11/darwin).

# Guard against double-sourcing
[[ -n "${_KALL_PLATFORM_LOADED:-}" ]] && return 0
_KALL_PLATFORM_LOADED=1

# =============================================================================
# Load WM adapter
# =============================================================================

_kall_wm_adapter="$KALL_LIB_DIR/adapters/wm/${KALL_WM}.sh"
if [[ -f "$_kall_wm_adapter" ]]; then
  # shellcheck source=/dev/null
  source "$_kall_wm_adapter"
  log_debug "platform.sh: loaded WM adapter ${KALL_WM}.sh"
else
  # shellcheck source=adapters/wm/generic.sh
  source "$KALL_LIB_DIR/adapters/wm/generic.sh"
  log_debug "platform.sh: WM adapter ${KALL_WM}.sh not found, loaded generic.sh"
fi
unset _kall_wm_adapter

# =============================================================================
# Load notify adapter
# =============================================================================

if [[ "$KALL_OS" == "darwin" ]]; then
  # shellcheck source=adapters/notify/macos.sh
  source "$KALL_LIB_DIR/adapters/notify/macos.sh"
  log_debug "platform.sh: loaded notify adapter macos.sh"
elif command -v notify-send &>/dev/null; then
  # shellcheck source=adapters/notify/libnotify.sh
  source "$KALL_LIB_DIR/adapters/notify/libnotify.sh"
  log_debug "platform.sh: loaded notify adapter libnotify.sh"
else
  # shellcheck source=adapters/notify/generic.sh
  source "$KALL_LIB_DIR/adapters/notify/generic.sh"
  log_debug "platform.sh: loaded notify adapter generic.sh (fallback)"
fi

# =============================================================================
# Clipboard
# =============================================================================

clipboard_copy() {
  case "$KALL_SESSION" in
    wayland) wl-copy ;;
    x11)     xclip -selection clipboard ;;
    darwin)  pbcopy ;;
  esac
}

clipboard_paste() {
  case "$KALL_SESSION" in
    wayland) wl-paste ;;
    x11)     xclip -selection clipboard -o ;;
    darwin)  pbpaste ;;
  esac
}

# =============================================================================
# Screenshots
# =============================================================================

screenshot_full() {
  local output="$1"
  case "$KALL_SESSION" in
    wayland) grim "$output" ;;
    x11)     maim "$output" ;;
    darwin)  screencapture "$output" ;;
  esac
}

screenshot_area() {
  local output="$1"
  case "$KALL_SESSION" in
    wayland) grim -g "$(slurp)" "$output" ;;
    x11)     maim -s "$output" ;;
    darwin)  screencapture -s "$output" ;;
  esac
}

screenshot_window() {
  local output="$1"
  case "$KALL_SESSION" in
    wayland)
      local geom
      if command -v slurp &>/dev/null && command -v hyprctl &>/dev/null; then
        geom="$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)" || geom=""
      fi
      if [[ -n "$geom" ]]; then
        grim -g "$geom" "$output"
      else
        grim "$output"
      fi
      ;;
    x11)
      maim -i "$(xdotool getactivewindow)" "$output"
      ;;
    darwin)
      screencapture -w "$output"
      ;;
  esac
}

# =============================================================================
# Wallpaper
# =============================================================================

set_wallpaper() {
  local path="$1"
  case "$KALL_SESSION" in
    wayland) swww img "$path" ;;
    x11)     feh --bg-fill "$path" ;;
    darwin)  osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$path\"" ;;
  esac
}

# =============================================================================
# URL opening
# =============================================================================

open_url() {
  local url="$1"
  case "$KALL_OS" in
    darwin) open "$url" ;;
    *)      xdg-open "$url" ;;
  esac
}

# =============================================================================
# Screen locking (delegates to WM adapter)
# =============================================================================

lock_screen() {
  wm_lock
}

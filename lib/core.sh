#!/usr/bin/env bash
# lib/core.sh — Environment detection, XDG path setup, kall.yml config parsing
#
# INV-CFG-01: All configuration MUST come from kall.yml or defaults
# INV-CFG-02: kall MUST start with empty/missing config (all defaults apply)
#
# This file is sourced by every other lib file and by the dispatcher.
# It MUST be safe to source multiple times (guard below).

# Guard against double-sourcing
[[ -n "${_KALL_CORE_LOADED:-}" ]] && return 0
_KALL_CORE_LOADED=1

# =============================================================================
# XDG path setup
# =============================================================================

KALL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kall"
KALL_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/kall"
KALL_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/kall"
KALL_CONFIG_FILE="$KALL_CONFIG_DIR/kall.yml"

# Auto-detect lib directory (where this file lives)
KALL_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export KALL_CONFIG_DIR KALL_DATA_DIR KALL_STATE_DIR KALL_CONFIG_FILE KALL_LIB_DIR

# =============================================================================
# OS detection
# =============================================================================

_kall_detect_os() {
  local kernel
  kernel="$(uname)"
  case "${kernel,,}" in
    linux*)  echo "linux" ;;
    darwin*) echo "darwin" ;;
    *)       echo "linux" ;;
  esac
}

KALL_OS="$(_kall_detect_os)"
export KALL_OS

# =============================================================================
# Session type detection
# =============================================================================

_kall_detect_session() {
  # Darwin is always "darwin"
  if [[ "$KALL_OS" == "darwin" ]]; then
    echo "darwin"
    return
  fi

  # Check XDG_SESSION_TYPE
  case "${XDG_SESSION_TYPE:-}" in
    wayland) echo "wayland" ;;
    x11)     echo "x11" ;;
    *)       echo "x11" ;;  # Default to x11 when undetectable on Linux
  esac
}

KALL_SESSION="$(_kall_detect_session)"
export KALL_SESSION

# =============================================================================
# Window manager detection
# =============================================================================

_kall_detect_wm() {
  # Darwin is always "macos"
  if [[ "$KALL_OS" == "darwin" ]]; then
    echo "macos"
    return
  fi

  local desktop="${XDG_CURRENT_DESKTOP:-}"
  case "${desktop,,}" in
    hyprland) echo "hyprland" ;;
    i3)       echo "i3" ;;
    sway)     echo "sway" ;;
    bspwm)    echo "bspwm" ;;
    awesome)  echo "awesome" ;;
    dwm)      echo "dwm" ;;
    *)        echo "generic" ;;
  esac
}

KALL_WM="$(_kall_detect_wm)"
export KALL_WM

# =============================================================================
# Config parsing helpers
# =============================================================================

# _kall_read_config KEY [DEFAULT]
#
# Reads a value from kall.yml using yq. Returns DEFAULT if:
#   - yq is not installed
#   - kall.yml does not exist
#   - the key is missing or null
#
# This MUST handle all edge cases gracefully (INV-CFG-02).
_kall_read_config() {
  local key="$1"
  local default="${2:-}"

  # No config file? Return default.
  if [[ ! -f "$KALL_CONFIG_FILE" ]]; then
    echo "$default"
    return
  fi

  # No yq? Return default.
  if ! command -v yq &>/dev/null; then
    echo "$default"
    return
  fi

  # Read the value via yq
  local value
  value="$(yq ".$key" "$KALL_CONFIG_FILE" 2>/dev/null)" || {
    echo "$default"
    return
  }

  # Handle null/empty — yq returns literal "null" for missing keys
  if [[ -z "$value" || "$value" == "null" ]]; then
    echo "$default"
    return
  fi

  echo "$value"
}

# =============================================================================
# Export config values (with defaults)
# =============================================================================

# --- Menu & theme ---
KALL_MENU_BACKEND="$(_kall_read_config menu_backend "rofi")"
KALL_THEME="$(_kall_read_config theme "catppuccin-mocha")"
KALL_STYLE="$(_kall_read_config launcher_style "style_1")"
KALL_DYNAMIC_THEME="$(_kall_read_config dynamic_theme "false")"

export KALL_MENU_BACKEND KALL_THEME KALL_STYLE KALL_DYNAMIC_THEME

# --- Logging ---
KALL_LOG_LEVEL="$(_kall_read_config logging.level "${KALL_LOG_LEVEL:-INFO}")"
KALL_LOG_FILE="$(_kall_read_config logging.file "${KALL_LOG_FILE:-true}")"
KALL_LOG_MAX_SIZE_MB="$(_kall_read_config logging.max_size_mb "${KALL_LOG_MAX_SIZE_MB:-1}")"
KALL_LOG_KEEP_ROTATED="$(_kall_read_config logging.keep_rotated "${KALL_LOG_KEEP_ROTATED:-3}")"
: "${KALL_LOG_DIR:=$KALL_STATE_DIR/logs}"

export KALL_LOG_LEVEL KALL_LOG_FILE KALL_LOG_MAX_SIZE_MB KALL_LOG_KEEP_ROTATED KALL_LOG_DIR

# --- Appearance ---
# Each property can be: a value (kall applies), "false" (system handles), or absent (default applies)
KALL_APPEARANCE_MANAGED="$(_kall_read_config appearance.managed "true")"
KALL_FONT="$(_kall_read_config appearance.font "JetBrainsMono Nerd Font 12")"
KALL_ICON_THEME="$(_kall_read_config appearance.icon_theme "Papirus-Dark")"
KALL_BORDER_RADIUS="$(_kall_read_config appearance.border_radius "12")"
KALL_BORDER_WIDTH="$(_kall_read_config appearance.border_width "2")"
KALL_OPACITY="$(_kall_read_config appearance.opacity "0.9")"

export KALL_APPEARANCE_MANAGED KALL_FONT KALL_ICON_THEME
export KALL_BORDER_RADIUS KALL_BORDER_WIDTH KALL_OPACITY

# =============================================================================
# Source log.sh and emit startup debug message
# =============================================================================

# shellcheck source=log.sh
source "$KALL_LIB_DIR/log.sh"

log_debug "core.sh loaded: OS=$KALL_OS SESSION=$KALL_SESSION WM=$KALL_WM BACKEND=$KALL_MENU_BACKEND THEME=$KALL_THEME"

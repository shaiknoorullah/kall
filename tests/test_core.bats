#!/usr/bin/env bats
# tests/test_core.bats — Tests for lib/core.sh environment detection and config parsing

setup() {
  load test_helper/common.bash
  common_setup

  # Set up log directory in test temp
  export KALL_LOG_DIR="$TEST_TEMP/logs"
  mkdir -p "$KALL_LOG_DIR"

  # Enable file logging
  export KALL_LOG_FILE="true"
  export KALL_LOG_LEVEL="INFO"

  # Clear any prior core.sh guard so we can re-source
  unset _KALL_CORE_LOADED

  # Clear any prior log.sh guard so core.sh can source it
  unset _KALL_LOG_LOADED

  # Clear all KALL_ detection vars so each test starts clean
  unset KALL_OS KALL_SESSION KALL_WM
  unset KALL_CONFIG_DIR KALL_DATA_DIR KALL_STATE_DIR
  unset KALL_CONFIG_FILE KALL_LIB_DIR
  unset KALL_MENU_BACKEND KALL_THEME KALL_STYLE KALL_DYNAMIC_THEME
  unset KALL_APPEARANCE_MANAGED KALL_FONT KALL_ICON_THEME
  unset KALL_BORDER_RADIUS KALL_BORDER_WIDTH KALL_OPACITY

  # Default: simulate linux
  uname() { echo "Linux"; }
  export -f uname
}

teardown() {
  # Remove uname override
  unset -f uname 2>/dev/null || true
  common_teardown
}

# --- Helper: source core.sh in a subshell and print requested var ---
_source_core_and_get() {
  local var_name="$1"
  (
    source "$LIB_DIR/core.sh" 2>/dev/null
    echo "${!var_name}"
  )
}

# === Session detection ===

# --- 1. Detects wayland session from XDG_SESSION_TYPE ---

@test "detects wayland session from XDG_SESSION_TYPE" {
  export XDG_SESSION_TYPE="wayland"
  local result
  result="$(_source_core_and_get KALL_SESSION)"
  [[ "$result" == "wayland" ]]
}

# --- 2. Detects x11 session ---

@test "detects x11 session from XDG_SESSION_TYPE" {
  export XDG_SESSION_TYPE="x11"
  local result
  result="$(_source_core_and_get KALL_SESSION)"
  [[ "$result" == "x11" ]]
}

# --- 3. Detects darwin (mock uname) ---

@test "detects darwin session when OS is darwin" {
  uname() { echo "Darwin"; }
  export -f uname
  local result
  result="$(_source_core_and_get KALL_SESSION)"
  [[ "$result" == "darwin" ]]
}

# --- 4. Falls back to x11 when undetectable ---

@test "falls back to x11 when session type undetectable" {
  unset XDG_SESSION_TYPE
  local result
  result="$(_source_core_and_get KALL_SESSION)"
  [[ "$result" == "x11" ]]
}

# === WM detection ===

# --- 5. Detects hyprland from XDG_CURRENT_DESKTOP ---

@test "detects hyprland from XDG_CURRENT_DESKTOP" {
  export XDG_CURRENT_DESKTOP="Hyprland"
  local result
  result="$(_source_core_and_get KALL_WM)"
  [[ "$result" == "hyprland" ]]
}

# --- 6. Detects i3 from XDG_CURRENT_DESKTOP ---

@test "detects i3 from XDG_CURRENT_DESKTOP" {
  export XDG_CURRENT_DESKTOP="i3"
  local result
  result="$(_source_core_and_get KALL_WM)"
  [[ "$result" == "i3" ]]
}

# --- 7. Falls back to generic for unknown WM ---

@test "falls back to generic for unknown WM" {
  export XDG_CURRENT_DESKTOP="SomeUnknownWM"
  local result
  result="$(_source_core_and_get KALL_WM)"
  [[ "$result" == "generic" ]]
}

# === Config defaults (INV-CFG-02) ===

# --- 8. Provides defaults when no kall.yml exists ---

@test "provides defaults when no kall.yml exists" {
  # Ensure no config file exists
  [[ ! -f "$XDG_CONFIG_HOME/kall/kall.yml" ]]

  local backend theme style dynamic
  backend="$(_source_core_and_get KALL_MENU_BACKEND)"
  theme="$(_source_core_and_get KALL_THEME)"
  style="$(_source_core_and_get KALL_STYLE)"
  dynamic="$(_source_core_and_get KALL_DYNAMIC_THEME)"

  [[ "$backend" == "rofi" ]]
  [[ "$theme" == "catppuccin-mocha" ]]
  [[ "$style" == "style_1" ]]
  [[ "$dynamic" == "false" ]]
}

# --- 9. Reads menu_backend from kall.yml (mock yq) ---

@test "reads menu_backend from kall.yml via yq" {
  # Create a config file so _kall_read_config tries yq
  mkdir -p "$XDG_CONFIG_HOME/kall"
  echo "menu_backend: wofi" > "$XDG_CONFIG_HOME/kall/kall.yml"

  # Set yq mock to return "wofi"
  echo "wofi" > "$TEST_TEMP/yq_response"

  local result
  result="$(_source_core_and_get KALL_MENU_BACKEND)"
  [[ "$result" == "wofi" ]]
}

# === XDG path setup ===

# --- 10. Sets KALL_CONFIG_DIR correctly ---

@test "sets KALL_CONFIG_DIR correctly" {
  local result
  result="$(_source_core_and_get KALL_CONFIG_DIR)"
  [[ "$result" == "$XDG_CONFIG_HOME/kall" ]]
}

# --- 11. Sets KALL_DATA_DIR correctly ---

@test "sets KALL_DATA_DIR correctly" {
  local result
  result="$(_source_core_and_get KALL_DATA_DIR)"
  [[ "$result" == "$XDG_DATA_HOME/kall" ]]
}

# === log.sh sourcing ===

# --- 12. Sources log.sh successfully ---

@test "sources log.sh successfully" {
  (
    source "$LIB_DIR/core.sh" 2>/dev/null
    # log_info should be available after sourcing core.sh
    declare -f log_info > /dev/null
  )
}

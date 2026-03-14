#!/usr/bin/env bats
# tests/test_platform.bats — Tests for lib/platform.sh cross-platform abstractions

setup() {
  load test_helper/common.bash
  common_setup

  # Set up log directory in test temp
  export KALL_LOG_DIR="$TEST_TEMP/logs"
  mkdir -p "$KALL_LOG_DIR"

  export KALL_LOG_FILE="true"
  export KALL_LOG_LEVEL="ERROR"

  # Clear guards so we can re-source
  unset _KALL_CORE_LOADED
  unset _KALL_LOG_LOADED
  unset _KALL_PLATFORM_LOADED
  unset _KALL_WM_GENERIC_LOADED
  unset _KALL_WM_HYPRLAND_LOADED
  unset _KALL_WM_I3_LOADED
  unset _KALL_WM_SWAY_LOADED
  unset _KALL_WM_BSPWM_LOADED
  unset _KALL_WM_DWM_LOADED
  unset _KALL_WM_MACOS_LOADED
  unset _KALL_NOTIFY_LIBNOTIFY_LOADED
  unset _KALL_NOTIFY_MACOS_LOADED
  unset _KALL_NOTIFY_GENERIC_LOADED

  # Clear detection vars
  unset KALL_OS KALL_SESSION KALL_WM

  # Default: simulate Linux + generic WM
  uname() { echo "Linux"; }
  export -f uname
}

teardown() {
  unset -f uname 2>/dev/null || true
  common_teardown
}

# --- Helper: source core.sh + platform.sh in subshell with given session type ---
_source_platform() {
  local session_type="$1"
  (
    export XDG_SESSION_TYPE="$session_type"
    export XDG_CURRENT_DESKTOP="generic"
    source "$LIB_DIR/core.sh" 2>/dev/null
    unset _KALL_PLATFORM_LOADED
    source "$LIB_DIR/platform.sh" 2>/dev/null
  )
}

# === clipboard_copy uses correct tool per session ===

@test "clipboard_copy uses wl-copy on wayland" {
  export XDG_SESSION_TYPE="wayland"
  export XDG_CURRENT_DESKTOP="generic"
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  echo "test" | clipboard_copy
  assert_mock_called "wl-copy"
}

@test "clipboard_copy uses xclip on x11" {
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  echo "test" | clipboard_copy
  assert_mock_called "xclip"
  assert_mock_called_with "xclip" "-selection clipboard"
}

@test "clipboard_copy uses pbcopy on darwin" {
  uname() { echo "Darwin"; }
  export -f uname
  unset XDG_SESSION_TYPE
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  echo "test" | clipboard_copy
  assert_mock_called "pbcopy"
}

# === screenshot_full uses correct tool per session ===

@test "screenshot_full uses grim on wayland" {
  export XDG_SESSION_TYPE="wayland"
  export XDG_CURRENT_DESKTOP="generic"
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  screenshot_full "/tmp/shot.png"
  assert_mock_called "grim"
  assert_mock_called_with "grim" "/tmp/shot.png"
}

@test "screenshot_full uses maim on x11" {
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  screenshot_full "/tmp/shot.png"
  assert_mock_called "maim"
  assert_mock_called_with "maim" "/tmp/shot.png"
}

@test "screenshot_full uses screencapture on darwin" {
  uname() { echo "Darwin"; }
  export -f uname
  unset XDG_SESSION_TYPE
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  screenshot_full "/tmp/shot.png"
  assert_mock_called "screencapture"
  assert_mock_called_with "screencapture" "/tmp/shot.png"
}

# === lock_screen delegates to wm_lock ===

@test "lock_screen delegates to wm_lock" {
  export XDG_SESSION_TYPE="wayland"
  export XDG_CURRENT_DESKTOP="generic"
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null

  # wm_lock from generic.sh tries hyprlock first
  lock_screen
  assert_mock_called "hyprlock"
}

# === open_url per OS ===

@test "open_url uses xdg-open on linux" {
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  open_url "https://example.com"
  assert_mock_called "xdg-open"
  assert_mock_called_with "xdg-open" "https://example.com"
}

@test "open_url uses open on darwin" {
  uname() { echo "Darwin"; }
  export -f uname
  unset XDG_SESSION_TYPE
  source "$LIB_DIR/core.sh" 2>/dev/null
  unset _KALL_PLATFORM_LOADED
  source "$LIB_DIR/platform.sh" 2>/dev/null
  open_url "https://example.com"
  assert_mock_called "open"
  assert_mock_called_with "open" "https://example.com"
}

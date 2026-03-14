#!/usr/bin/env bats
# tests/test_notify.bats — Tests for lib/notify.sh convenience wrappers

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
  unset _KALL_NOTIFY_LOADED
  unset _KALL_WM_GENERIC_LOADED
  unset _KALL_NOTIFY_LIBNOTIFY_LOADED
  unset _KALL_NOTIFY_MACOS_LOADED
  unset _KALL_NOTIFY_GENERIC_LOADED

  # Default: simulate linux x11
  uname() { echo "Linux"; }
  export -f uname
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"

  # Source core.sh and platform.sh (loads libnotify adapter via mock notify-send)
  source "$LIB_DIR/core.sh" 2>/dev/null
  source "$LIB_DIR/platform.sh" 2>/dev/null
  source "$LIB_DIR/notify.sh" 2>/dev/null
}

teardown() {
  unset -f uname 2>/dev/null || true
  common_teardown
}

# === notify() calls _notify_send with correct args ===

@test "notify calls notify-send with title and timeout" {
  notify "Test Title" "Test Body"
  assert_mock_called "notify-send"
  assert_mock_called_with "notify-send" "-t 3000 Test Title Test Body"
}

@test "notify works with title only" {
  notify "Alert"
  assert_mock_called "notify-send"
  assert_mock_called_with "notify-send" "-t 3000 Alert"
}

# === notify_critical() calls _notify_send with urgency ===

@test "notify_critical calls notify-send with critical urgency" {
  notify_critical "Danger" "Disk full"
  assert_mock_called "notify-send"
  assert_mock_called_with "notify-send" "-u critical Danger Disk full"
}

# === notify_with_icon() calls _notify_send with icon and timeout ===

@test "notify_with_icon calls notify-send with icon and timeout" {
  notify_with_icon "Update" "New version" "update-icon"
  assert_mock_called "notify-send"
  assert_mock_called_with "notify-send" "-i update-icon -t 3000 Update New version"
}

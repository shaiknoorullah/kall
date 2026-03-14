#!/usr/bin/env bats
# tests/test_notify_adapters.bats — Tests for lib/adapters/notify/ adapters

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

  # Set KALL_LIB_DIR so core.sh can find log.sh
  export KALL_LIB_DIR="$LIB_DIR"

  # Source core.sh for log functions
  source "$LIB_DIR/core.sh" 2>/dev/null

  export NOTIFY_ADAPTER_DIR="$LIB_DIR/adapters/notify"
}

teardown() {
  common_teardown
}

# === libnotify adapter calls notify-send mock ===

@test "libnotify adapter calls notify-send" {
  unset _KALL_NOTIFY_LIBNOTIFY_LOADED
  source "$NOTIFY_ADAPTER_DIR/libnotify.sh"
  _notify_send "Test Title" "Test Body"
  assert_mock_called "notify-send"
}

@test "libnotify adapter passes title and body to notify-send" {
  unset _KALL_NOTIFY_LIBNOTIFY_LOADED
  source "$NOTIFY_ADAPTER_DIR/libnotify.sh"
  _notify_send "Hello" "World"
  assert_mock_called_with "notify-send" "Hello World"
}

@test "libnotify adapter passes optional flags to notify-send" {
  unset _KALL_NOTIFY_LIBNOTIFY_LOADED
  source "$NOTIFY_ADAPTER_DIR/libnotify.sh"
  _notify_send "Title" "Body" -i "icon.png" -u "critical"
  assert_mock_called_with "notify-send" "-i icon.png -u critical Title Body"
}

# === generic adapter outputs to stderr ===

@test "generic adapter outputs notification to stderr" {
  unset _KALL_NOTIFY_GENERIC_LOADED
  source "$NOTIFY_ADAPTER_DIR/generic.sh"
  run _notify_send "Alert" "Something happened"
  [[ "$status" -eq 0 ]]
  # run captures stderr in output for bats
  [[ "$output" == *"Alert"* ]]
  [[ "$output" == *"Something happened"* ]]
}

@test "generic adapter includes urgency in stderr output" {
  unset _KALL_NOTIFY_GENERIC_LOADED
  source "$NOTIFY_ADAPTER_DIR/generic.sh"
  run _notify_send "Warn" "Disk full" -u "critical"
  [[ "$output" == *"critical"* ]]
  [[ "$output" == *"Warn"* ]]
}

# === ALL adapters implement _notify_send ===

@test "all notify adapters implement _notify_send" {
  local adapters=(libnotify macos generic)

  for adapter in "${adapters[@]}"; do
    (
      unset _KALL_NOTIFY_LIBNOTIFY_LOADED
      unset _KALL_NOTIFY_MACOS_LOADED
      unset _KALL_NOTIFY_GENERIC_LOADED

      source "$NOTIFY_ADAPTER_DIR/${adapter}.sh"
      if ! declare -f _notify_send >/dev/null 2>&1; then
        echo "FAIL: adapter '$adapter' missing function '_notify_send'" >&2
        exit 1
      fi
    )
  done
}

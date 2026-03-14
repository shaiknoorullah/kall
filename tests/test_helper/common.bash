#!/usr/bin/env bash
# tests/test_helper/common.bash — Shared test infrastructure for kall

# --- Project paths ---
export PROJECT_ROOT
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export LIB_DIR="$PROJECT_ROOT/lib"
export MOCKS_DIR="$PROJECT_ROOT/tests/test_helper/mocks"

# --- Load bats helpers ---
load "$PROJECT_ROOT/tests/test_helper/bats-support/load"
load "$PROJECT_ROOT/tests/test_helper/bats-assert/load"

# --- common_setup: call from setup() in each test file ---
common_setup() {
  # Create isolated temp directory
  TEST_TEMP="$(mktemp -d)"
  export TEST_TEMP

  # Mock log file for tracking mock invocations
  export MOCK_LOG="$TEST_TEMP/mock_calls.log"
  touch "$MOCK_LOG"

  # Menu mock output files
  export MENU_MOCK_OUTPUT="$TEST_TEMP/menu_output"
  export MENU_MULTI_OUTPUT="$TEST_TEMP/menu_multi_output"
  export MENU_CALL_COUNT="$TEST_TEMP/menu_call_count"
  echo "0" > "$MENU_CALL_COUNT"

  # Override HOME to isolate tests from user config
  export REAL_HOME="$HOME"
  export HOME="$TEST_TEMP/home"
  mkdir -p "$HOME"

  # Set XDG dirs into temp
  export XDG_CONFIG_HOME="$TEST_TEMP/config"
  export XDG_DATA_HOME="$TEST_TEMP/data"
  export XDG_CACHE_HOME="$TEST_TEMP/cache"
  export XDG_STATE_HOME="$TEST_TEMP/state"
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"

  # Inject mocks into PATH (prepend so they shadow real binaries)
  export PATH="$MOCKS_DIR:$PATH"
}

# --- common_teardown: call from teardown() in each test file ---
common_teardown() {
  if [[ -n "${TEST_TEMP:-}" && -d "$TEST_TEMP" ]]; then
    rm -rf "$TEST_TEMP"
  fi
}

# --- Mock assertion helpers ---

# Assert a mock was called at least once
# Usage: assert_mock_called <mock_name>
assert_mock_called() {
  local mock_name="$1"
  if ! grep -q "^$mock_name " "$MOCK_LOG" 2>/dev/null; then
    echo "Expected mock '$mock_name' to have been called, but it was not." >&2
    echo "Mock log contents:" >&2
    cat "$MOCK_LOG" >&2
    return 1
  fi
}

# Assert a mock was NOT called
# Usage: assert_mock_not_called <mock_name>
assert_mock_not_called() {
  local mock_name="$1"
  if grep -q "^$mock_name " "$MOCK_LOG" 2>/dev/null; then
    echo "Expected mock '$mock_name' NOT to have been called, but it was." >&2
    echo "Mock log contents:" >&2
    cat "$MOCK_LOG" >&2
    return 1
  fi
}

# Assert a mock was called with specific arguments
# Usage: assert_mock_called_with <mock_name> <expected_args...>
assert_mock_called_with() {
  local mock_name="$1"
  shift
  local expected_args="$*"
  if ! grep -q "^$mock_name $expected_args" "$MOCK_LOG" 2>/dev/null; then
    echo "Expected mock '$mock_name' to have been called with: $expected_args" >&2
    echo "Mock log contents:" >&2
    cat "$MOCK_LOG" >&2
    return 1
  fi
}

# Get all calls to a specific mock
# Usage: get_mock_calls <mock_name>
get_mock_calls() {
  local mock_name="$1"
  grep "^$mock_name " "$MOCK_LOG" 2>/dev/null || true
}

# Set outputs for multi-call menu mock (rofi)
# Usage: set_menu_outputs "output1" "output2" "output3"
set_menu_outputs() {
  : > "$MENU_MULTI_OUTPUT"
  for output in "$@"; do
    echo "$output" >> "$MENU_MULTI_OUTPUT"
  done
  echo "0" > "$MENU_CALL_COUNT"
}

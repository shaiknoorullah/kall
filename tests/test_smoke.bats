#!/usr/bin/env bats
# tests/test_smoke.bats — Smoke tests for kall test infrastructure

setup() {
  load test_helper/common.bash
  common_setup
}

teardown() {
  common_teardown
}

# --- Test infrastructure works ---

@test "test infrastructure loads without error" {
  # If we got here, common_setup succeeded
  [[ -n "$PROJECT_ROOT" ]]
  [[ -n "$LIB_DIR" ]]
  [[ -n "$MOCKS_DIR" ]]
}

@test "PROJECT_ROOT points to the kall repo" {
  [[ -f "$PROJECT_ROOT/LICENSE" ]]
  [[ -f "$PROJECT_ROOT/.gitignore" ]]
}

# --- Mocks are on PATH ---

@test "rofi mock is on PATH" {
  run which rofi
  assert_success
  assert_output --partial "mocks/rofi"
}

@test "wl-copy mock is on PATH" {
  run which wl-copy
  assert_success
  assert_output --partial "mocks/wl-copy"
}

@test "yq mock is on PATH" {
  run which yq
  assert_success
  assert_output --partial "mocks/yq"
}

@test "notify-send mock is on PATH" {
  run which notify-send
  assert_success
  assert_output --partial "mocks/notify-send"
}

@test "all expected mocks exist and are executable" {
  local mocks=(
    rofi wl-copy wl-paste xclip pbcopy pbpaste
    notify-send yq grim slurp maim screencapture
    xdotool feh swww xdg-open open
    hyprctl hyprlock swaylock i3lock
    i3-msg swaymsg playerctl osascript
  )
  for mock in "${mocks[@]}"; do
    [[ -x "$MOCKS_DIR/$mock" ]]
  done
}

# --- Mock logging works ---

@test "mock logs invocation to MOCK_LOG" {
  rofi -dmenu -p "test"
  assert_mock_called "rofi"
}

@test "mock logs arguments correctly" {
  notify-send "Test Title" "Test Body"
  assert_mock_called_with "notify-send" "Test Title Test Body"
}

@test "assert_mock_not_called passes for uncalled mock" {
  assert_mock_not_called "rofi"
}

@test "get_mock_calls returns logged calls" {
  wl-copy "hello"
  wl-copy "world"
  local calls
  calls="$(get_mock_calls "wl-copy")"
  echo "$calls" | grep -q "hello"
  echo "$calls" | grep -q "world"
}

# --- TEST_TEMP is isolated ---

@test "TEST_TEMP exists and is a directory" {
  [[ -d "$TEST_TEMP" ]]
}

@test "TEST_TEMP is unique per test" {
  # Write a marker file
  echo "marker" > "$TEST_TEMP/unique_marker"
  [[ -f "$TEST_TEMP/unique_marker" ]]
}

@test "HOME is overridden to TEST_TEMP" {
  [[ "$HOME" == "$TEST_TEMP/home" ]]
  [[ -d "$HOME" ]]
}

@test "XDG dirs are set to TEST_TEMP subdirs" {
  [[ "$XDG_CONFIG_HOME" == "$TEST_TEMP/config" ]]
  [[ "$XDG_DATA_HOME" == "$TEST_TEMP/data" ]]
  [[ "$XDG_CACHE_HOME" == "$TEST_TEMP/cache" ]]
  [[ "$XDG_STATE_HOME" == "$TEST_TEMP/state" ]]
  [[ -d "$XDG_CONFIG_HOME" ]]
  [[ -d "$XDG_DATA_HOME" ]]
  [[ -d "$XDG_CACHE_HOME" ]]
  [[ -d "$XDG_STATE_HOME" ]]
}

# --- Menu multi-output support ---

@test "rofi mock supports multi-call output" {
  set_menu_outputs "first" "second" "third"
  run rofi -dmenu
  assert_output "first"
  run rofi -dmenu
  assert_output "second"
  run rofi -dmenu
  assert_output "third"
}

# --- yq mock response file ---

@test "yq mock reads from yq_response file" {
  echo '{"key": "value"}' > "$TEST_TEMP/yq_response"
  run yq '.key' test.yml
  assert_output '{"key": "value"}'
  assert_mock_called "yq"
}

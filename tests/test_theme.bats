#!/usr/bin/env bats
# tests/test_theme.bats — Tests for lib/theme.sh palette loader

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
  unset _KALL_THEME_LOADED

  # Clear color vars
  unset KALL_COLOR_MAIN_BG KALL_COLOR_MAIN_FG KALL_COLOR_MAIN_BR KALL_COLOR_MAIN_EX
  unset KALL_COLOR_SELECT_BG KALL_COLOR_SELECT_FG
  unset KALL_COLOR_URGENT_BG KALL_COLOR_URGENT_FG

  # Default: simulate linux x11
  uname() { echo "Linux"; }
  export -f uname
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"

  # Source core.sh for logging
  source "$LIB_DIR/core.sh" 2>/dev/null

  # Set palettes dir to the real project palettes
  export KALL_PALETTES_DIR="$PROJECT_ROOT/themes/palettes"

  # Configure yq mock to return a color value
  echo "#AABBCC" > "$TEST_TEMP/yq_response"
}

teardown() {
  unset -f uname 2>/dev/null || true
  common_teardown
}

# === load_theme exports KALL_COLOR_* variables ===

@test "load_theme exports all KALL_COLOR_* variables" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  # All color vars should be set (yq mock returns #AABBCC for all)
  [[ -n "$KALL_COLOR_MAIN_BG" ]]
  [[ -n "$KALL_COLOR_MAIN_FG" ]]
  [[ -n "$KALL_COLOR_MAIN_BR" ]]
  [[ -n "$KALL_COLOR_MAIN_EX" ]]
  [[ -n "$KALL_COLOR_SELECT_BG" ]]
  [[ -n "$KALL_COLOR_SELECT_FG" ]]
  [[ -n "$KALL_COLOR_URGENT_BG" ]]
  [[ -n "$KALL_COLOR_URGENT_FG" ]]
}

@test "load_theme sets colors from yq mock" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  echo "#112233" > "$TEST_TEMP/yq_response"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  [[ "$KALL_COLOR_MAIN_BG" == "#112233" ]]
  [[ "$KALL_COLOR_MAIN_FG" == "#112233" ]]
}

@test "load_theme calls yq with palette file path" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  export KALL_THEME="catppuccin-mocha"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  assert_mock_called "yq"
  assert_mock_called_with "yq" ".colors.main_bg $KALL_PALETTES_DIR/catppuccin-mocha.yml"
}

# === list_palettes shows available palettes ===

@test "list_palettes includes catppuccin-mocha" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  run list_palettes
  assert_success
  assert_line "catppuccin-mocha"
}

@test "list_palettes includes dracula" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  run list_palettes
  assert_success
  assert_line "dracula"
}

@test "list_palettes shows all 6 palettes" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  run list_palettes
  assert_success
  local count
  count="$(echo "$output" | wc -l)"
  [[ "$count" -eq 6 ]]
}

# === Fallback on missing palette ===

@test "load_theme falls back to catppuccin-mocha for unknown palette" {
  unset _KALL_THEME_LOADED
  export KALL_DYNAMIC_THEME="false"
  export KALL_THEME="nonexistent-palette"
  source "$LIB_DIR/theme.sh" 2>/dev/null

  # Should still have loaded colors (from catppuccin-mocha fallback)
  [[ -n "$KALL_COLOR_MAIN_BG" ]]
  # yq should have been called with catppuccin-mocha path
  assert_mock_called_with "yq" ".colors.main_bg $KALL_PALETTES_DIR/catppuccin-mocha.yml"
}

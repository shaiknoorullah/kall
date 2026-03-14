#!/usr/bin/env bats
# tests/test_keybinds.bats — Tests for lib/keybinds.sh keybinding translation

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
  unset _KALL_KEYBINDS_LOADED

  # Default: simulate linux x11
  uname() { echo "Linux"; }
  export -f uname
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"

  # Source core.sh for logging, then keybinds.sh
  source "$LIB_DIR/core.sh" 2>/dev/null
  source "$LIB_DIR/keybinds.sh" 2>/dev/null
}

teardown() {
  unset -f uname 2>/dev/null || true
  common_teardown
}

# === Hyprland translation ===

@test "hyprland: mod+shift+e translates correctly" {
  run _translate_keybind "hyprland" "mod,shift" "e" "kall power"
  assert_success
  assert_output 'bind = $mainMod SHIFT, E, exec, kall power'
}

@test "hyprland: mod-only translates correctly" {
  run _translate_keybind "hyprland" "mod" "Return" "kall launch"
  assert_success
  assert_output 'bind = $mainMod, RETURN, exec, kall launch'
}

# === i3 translation ===

@test "i3: mod+shift+e translates correctly" {
  run _translate_keybind "i3" "mod,shift" "e" "kall power"
  assert_success
  assert_output 'bindsym $mod+Shift+e exec kall power'
}

@test "i3: mod-only translates correctly" {
  run _translate_keybind "i3" "mod" "Return" "kall launch"
  assert_success
  assert_output 'bindsym $mod+Return exec kall launch'
}

# === sway translation (same as i3) ===

@test "sway: mod+shift+e translates correctly" {
  run _translate_keybind "sway" "mod,shift" "e" "kall power"
  assert_success
  assert_output 'bindsym $mod+Shift+e exec kall power'
}

# === bspwm (sxhkd) translation ===

@test "bspwm: mod+shift+e translates correctly" {
  run _translate_keybind "bspwm" "mod,shift" "e" "kall power"
  assert_success
  # bspwm format: super + shift + e\n\tkall power
  assert_line --index 0 "super + shift + e"
  assert_line --index 1 "	kall power"
}

@test "bspwm: mod-only translates correctly" {
  run _translate_keybind "bspwm" "mod" "Return" "kall launch"
  assert_success
  assert_line --index 0 "super + Return"
  assert_line --index 1 "	kall launch"
}

# === awesome translation ===

@test "awesome: mod+shift+e translates correctly" {
  run _translate_keybind "awesome" "mod,shift" "e" "kall power"
  assert_success
  assert_output 'awful.key({ modkey, "Shift" }, "e", function() awful.spawn("kall power") end)'
}

# === skhd translation ===

@test "skhd: mod+shift+e translates correctly" {
  run _translate_keybind "skhd" "mod,shift" "e" "kall power"
  assert_success
  assert_output "cmd + shift + e : kall power"
}

# === unknown WM ===

@test "unknown WM falls back to comment format" {
  run _translate_keybind "unknown" "mod,shift" "e" "kall power"
  assert_success
  assert_output "# kall power (bind mod,shift + e)"
}

#!/usr/bin/env bats
# tests/test_dispatcher.bats — Tests for the kall dispatcher entry point

setup() {
  load test_helper/common.bash
  common_setup

  # Set up log directory in test temp
  export KALL_LOG_DIR="$TEST_TEMP/logs"
  mkdir -p "$KALL_LOG_DIR"
  export KALL_LOG_FILE="true"
  export KALL_LOG_LEVEL="INFO"

  # Clear sourcing guards so each test starts fresh
  unset _KALL_CORE_LOADED _KALL_LOG_LOADED _KALL_PLATFORM_LOADED
  unset _KALL_MENU_LOADED _KALL_THEME_LOADED _KALL_NOTIFY_LOADED
  unset _KALL_KEYBINDS_LOADED

  # Clear detection vars
  unset KALL_OS KALL_SESSION KALL_WM
  unset KALL_MENU_BACKEND KALL_THEME KALL_STYLE KALL_DYNAMIC_THEME

  # Simulate linux x11
  uname() { echo "Linux"; }
  export -f uname
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"

  # Create mock rofi backend so menu.sh can load it
  export KALL_BACKENDS_DIR="$TEST_TEMP/backends"
  mkdir -p "$KALL_BACKENDS_DIR/rofi"
  cat > "$KALL_BACKENDS_DIR/rofi/adapter.sh" <<'ADAPTER'
#!/usr/bin/env bash
menu_dmenu() { cat; }
menu_launch() { :; }
menu_calc() { :; }
menu_keys() { :; }
menu_supports() { return 0; }
ADAPTER
  chmod +x "$KALL_BACKENDS_DIR/rofi/adapter.sh"

  # Create modules dir for routing tests
  export KALL_MODULES_DIR="$TEST_TEMP/modules"
  mkdir -p "$KALL_MODULES_DIR"

  # Create a minimal palette so theme.sh doesn't fail
  export KALL_PALETTES_DIR="$TEST_TEMP/palettes"
  mkdir -p "$KALL_PALETTES_DIR"
  cat > "$KALL_PALETTES_DIR/catppuccin-mocha.yml" <<'PALETTE'
name: catppuccin-mocha
colors:
  main_bg: "#1e1e2e"
  main_fg: "#cdd6f4"
  main_br: "#89b4fa"
  main_ex: "#f38ba8"
  select_bg: "#313244"
  select_fg: "#cdd6f4"
  urgent_bg: "#f38ba8"
  urgent_fg: "#1e1e2e"
PALETTE
}

teardown() {
  unset -f uname 2>/dev/null || true
  common_teardown
}

# =============================================================================
# Flag tests
# =============================================================================

@test "kall --help shows usage and exits 0" {
  run "$PROJECT_ROOT/kall" --help
  assert_success
  assert_output --partial "Usage:"
  assert_output --partial "kall"
}

@test "kall -h shows usage and exits 0" {
  run "$PROJECT_ROOT/kall" -h
  assert_success
  assert_output --partial "Usage:"
}

@test "kall --version shows version string" {
  run "$PROJECT_ROOT/kall" --version
  assert_success
  assert_output "kall 2.0.0"
}

@test "kall -v shows version string" {
  run "$PROJECT_ROOT/kall" -v
  assert_success
  assert_output "kall 2.0.0"
}

# =============================================================================
# Routing tests
# =============================================================================

@test "kall with no arguments shows usage and exits 1" {
  run "$PROJECT_ROOT/kall"
  assert_failure
  assert_output --partial "Usage:"
}

@test "kall nonexistent_xyz errors with exit 1" {
  run "$PROJECT_ROOT/kall" nonexistent_xyz
  assert_failure
}

@test "kall list succeeds" {
  run "$PROJECT_ROOT/kall" list
  assert_success
  # With no config, shows the setup prompt
  assert_output --partial "(none"
}

@test "kall list --available succeeds" {
  run "$PROJECT_ROOT/kall" list --available
  assert_success
}

@test "kall list --available shows modules with module.yml" {
  # Create a module with module.yml
  mkdir -p "$KALL_MODULES_DIR/testmod"
  touch "$KALL_MODULES_DIR/testmod/module.yml"

  run "$PROJECT_ROOT/kall" list --available
  assert_success
  assert_output --partial "testmod"
}

# =============================================================================
# Group routing
# =============================================================================

@test "kall routes to group when group yml exists" {
  mkdir -p "$KALL_MODULES_DIR/groups"
  touch "$KALL_MODULES_DIR/groups/mygroup.yml"

  run "$PROJECT_ROOT/kall" mygroup
  assert_success
  assert_output --partial "Group 'mygroup'"
}

# =============================================================================
# CLI command stubs
# =============================================================================

@test "kall setup prints coming soon" {
  run "$PROJECT_ROOT/kall" setup
  assert_success
  assert_output --partial "coming soon"
}

@test "kall doctor prints coming soon" {
  run "$PROJECT_ROOT/kall" doctor
  assert_success
  assert_output --partial "coming soon"
}

@test "kall theme prints coming soon" {
  run "$PROJECT_ROOT/kall" theme
  assert_success
  assert_output --partial "coming soon"
}

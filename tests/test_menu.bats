#!/usr/bin/env bats
# tests/test_menu.bats — Tests for lib/menu.sh menu abstraction

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
  unset _KALL_MENU_LOADED

  # Default: simulate linux x11
  uname() { echo "Linux"; }
  export -f uname
  export XDG_SESSION_TYPE="x11"
  export XDG_CURRENT_DESKTOP="generic"

  # Source core.sh for logging
  source "$LIB_DIR/core.sh" 2>/dev/null

  # Create a mock backends directory with a valid adapter
  export KALL_BACKENDS_DIR="$TEST_TEMP/backends"
  mkdir -p "$KALL_BACKENDS_DIR/rofi"

  # Create a minimal valid adapter
  cat > "$KALL_BACKENDS_DIR/rofi/adapter.sh" << 'ADAPTER'
#!/usr/bin/env bash
menu_dmenu() { :; }
menu_launch() { :; }
menu_calc() { :; }
menu_keys() { :; }
menu_supports() { :; }
ADAPTER
}

teardown() {
  unset -f uname 2>/dev/null || true
  common_teardown
}

# === Loading works with valid adapter ===

@test "menu.sh loads a valid backend adapter" {
  export KALL_MENU_BACKEND="rofi"
  unset _KALL_MENU_LOADED
  source "$LIB_DIR/menu.sh" 2>/dev/null
  # All 5 functions should be available
  declare -f menu_dmenu >/dev/null
  declare -f menu_launch >/dev/null
  declare -f menu_calc >/dev/null
  declare -f menu_keys >/dev/null
  declare -f menu_supports >/dev/null
}

# === Missing backend fails fatally ===

@test "menu.sh fails when backend directory is missing" {
  unset _KALL_MENU_LOADED
  run env \
    HOME="$HOME" \
    KALL_LOG_DIR="$KALL_LOG_DIR" \
    KALL_LOG_FILE="true" \
    KALL_LOG_LEVEL="ERROR" \
    KALL_BACKENDS_DIR="$KALL_BACKENDS_DIR" \
    PATH="$MOCKS_DIR:$PATH" \
    XDG_SESSION_TYPE="x11" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    bash -c "
      source '$LIB_DIR/core.sh' 2>/dev/null
      export KALL_MENU_BACKEND='nonexistent'
      source '$LIB_DIR/menu.sh'
    "
  assert_failure
}

# === Interface validation catches missing function ===

@test "menu.sh fails when adapter is missing a required function" {
  # Create an incomplete adapter (missing menu_keys)
  mkdir -p "$KALL_BACKENDS_DIR/incomplete"
  cat > "$KALL_BACKENDS_DIR/incomplete/adapter.sh" << 'ADAPTER'
#!/usr/bin/env bash
menu_dmenu() { :; }
menu_launch() { :; }
menu_calc() { :; }
menu_supports() { :; }
ADAPTER

  run env \
    HOME="$HOME" \
    KALL_LOG_DIR="$KALL_LOG_DIR" \
    KALL_LOG_FILE="true" \
    KALL_LOG_LEVEL="ERROR" \
    KALL_BACKENDS_DIR="$KALL_BACKENDS_DIR" \
    PATH="$MOCKS_DIR:$PATH" \
    XDG_SESSION_TYPE="x11" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    bash -c "
      source '$LIB_DIR/core.sh' 2>/dev/null
      export KALL_MENU_BACKEND='incomplete'
      source '$LIB_DIR/menu.sh'
    "
  assert_failure
  assert_output --partial "menu_keys"
}

# === KALL_BACKENDS_DIR defaults correctly ===

@test "KALL_BACKENDS_DIR defaults to project backends directory" {
  unset KALL_BACKENDS_DIR
  unset _KALL_MENU_LOADED

  # Create a backends dir relative to project root
  local project_backends
  project_backends="$(cd "$LIB_DIR/.." && pwd)/backends"
  mkdir -p "$project_backends/rofi"
  cat > "$project_backends/rofi/adapter.sh" << 'ADAPTER'
#!/usr/bin/env bash
menu_dmenu() { :; }
menu_launch() { :; }
menu_calc() { :; }
menu_keys() { :; }
menu_supports() { :; }
ADAPTER

  export KALL_MENU_BACKEND="rofi"
  source "$LIB_DIR/menu.sh" 2>/dev/null
  [[ "$KALL_BACKENDS_DIR" == "$project_backends" ]]

  # Clean up
  rm -rf "$project_backends"
}

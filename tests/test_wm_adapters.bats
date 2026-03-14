#!/usr/bin/env bats
# tests/test_wm_adapters.bats — Tests for lib/adapters/wm/ adapters

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

  export WM_ADAPTER_DIR="$LIB_DIR/adapters/wm"
}

teardown() {
  common_teardown
}

# === generic adapter: implements all 5 functions ===

@test "generic adapter implements all 5 required functions" {
  (
    unset _KALL_WM_GENERIC_LOADED
    source "$WM_ADAPTER_DIR/generic.sh"
    declare -f wm_exit >/dev/null
    declare -f wm_lock >/dev/null
    declare -f get_monitors >/dev/null
    declare -f get_active_window >/dev/null
    declare -f get_workspaces >/dev/null
  )
}

# === generic get_monitors returns valid JSON ===

@test "generic get_monitors returns valid JSON" {
  (
    unset _KALL_WM_GENERIC_LOADED
    source "$WM_ADAPTER_DIR/generic.sh"
    local output
    output="$(get_monitors)"
    echo "$output" | jq . >/dev/null 2>&1
  )
}

# === generic wm_lock doesn't crash ===

@test "generic wm_lock does not crash" {
  (
    unset _KALL_WM_GENERIC_LOADED
    source "$WM_ADAPTER_DIR/generic.sh"
    run wm_lock
    [[ "$status" -eq 0 ]]
  )
}

# === ALL adapters implement the full interface ===

@test "all WM adapters implement the full 5-function interface" {
  local adapters=(generic hyprland i3 sway bspwm dwm macos)
  local functions=(wm_exit wm_lock get_monitors get_active_window get_workspaces)

  for adapter in "${adapters[@]}"; do
    (
      # Clear all adapter guards
      unset _KALL_WM_GENERIC_LOADED
      unset _KALL_WM_HYPRLAND_LOADED
      unset _KALL_WM_I3_LOADED
      unset _KALL_WM_SWAY_LOADED
      unset _KALL_WM_BSPWM_LOADED
      unset _KALL_WM_DWM_LOADED
      unset _KALL_WM_MACOS_LOADED

      source "$WM_ADAPTER_DIR/${adapter}.sh"
      for fn in "${functions[@]}"; do
        if ! declare -f "$fn" >/dev/null 2>&1; then
          echo "FAIL: adapter '$adapter' missing function '$fn'" >&2
          exit 1
        fi
      done
    )
  done
}

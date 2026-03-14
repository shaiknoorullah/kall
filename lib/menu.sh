#!/usr/bin/env bash
# lib/menu.sh — Menu abstraction with backend adapter loading and interface validation
#
# Loads the configured menu backend adapter (rofi, wofi, etc.) and verifies
# that it implements the required interface.

# Guard against double-sourcing
[[ -n "${_KALL_MENU_LOADED:-}" ]] && return 0
_KALL_MENU_LOADED=1

# =============================================================================
# Backend adapter loading
# =============================================================================

KALL_BACKENDS_DIR="${KALL_BACKENDS_DIR:-$(cd "$KALL_LIB_DIR/.." && pwd)/backends}"
export KALL_BACKENDS_DIR

_kall_menu_adapter="$KALL_BACKENDS_DIR/$KALL_MENU_BACKEND/adapter.sh"

if [[ ! -f "$_kall_menu_adapter" ]]; then
  log_fatal "menu.sh: backend adapter not found: $_kall_menu_adapter"
fi

# shellcheck source=/dev/null
source "$_kall_menu_adapter"

# =============================================================================
# Interface validation
# =============================================================================

_kall_menu_required_functions=(
  menu_dmenu
  menu_launch
  menu_calc
  menu_keys
  menu_supports
)

for _kall_fn in "${_kall_menu_required_functions[@]}"; do
  if ! declare -f "$_kall_fn" &>/dev/null; then
    log_fatal "menu.sh: backend '$KALL_MENU_BACKEND' missing required function: $_kall_fn"
  fi
done

unset _kall_menu_adapter _kall_menu_required_functions _kall_fn

log_debug "menu.sh: loaded backend '$KALL_MENU_BACKEND' from $KALL_BACKENDS_DIR"

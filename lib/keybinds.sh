#!/usr/bin/env bash
# lib/keybinds.sh — Normalized keybinding translation for multiple WMs
#
# Translates a generic keybind spec (mods + key + command) into the
# syntax required by each supported window manager.

# Guard against double-sourcing
[[ -n "${_KALL_KEYBINDS_LOADED:-}" ]] && return 0
_KALL_KEYBINDS_LOADED=1

# =============================================================================
# Block markers for injected keybinds
# =============================================================================

KALL_KEYBIND_BLOCK_START="# >>> kall keybinds >>>"
KALL_KEYBIND_BLOCK_END="# <<< kall keybinds <<<"

export KALL_KEYBIND_BLOCK_START KALL_KEYBIND_BLOCK_END

# =============================================================================
# _translate_keybind — Convert generic keybind to WM-specific syntax
# =============================================================================

# _translate_keybind WM MODS_CSV KEY COMMAND
#   WM:       hyprland, i3, sway, bspwm, awesome, skhd, or unknown
#   MODS_CSV: Comma-separated modifiers (e.g. "mod,shift" or "mod")
#   KEY:      The key to bind (e.g. "e", "Return", "1")
#   COMMAND:  The command to run (e.g. "kall power")
_translate_keybind() {
  local wm="$1"
  local mods_csv="$2"
  local key="$3"
  local command="$4"

  case "$wm" in
    hyprland)
      _translate_hyprland "$mods_csv" "$key" "$command"
      ;;
    i3|sway)
      _translate_i3_sway "$mods_csv" "$key" "$command"
      ;;
    bspwm)
      _translate_bspwm "$mods_csv" "$key" "$command"
      ;;
    awesome)
      _translate_awesome "$mods_csv" "$key" "$command"
      ;;
    skhd)
      _translate_skhd "$mods_csv" "$key" "$command"
      ;;
    *)
      _translate_unknown "$mods_csv" "$key" "$command"
      ;;
  esac
}

# --- Hyprland: bind = $mainMod SHIFT, E, exec, kall power ---
_translate_hyprland() {
  local mods_csv="$1" key="$2" command="$3"
  local hypr_mods=""

  IFS=',' read -ra mod_array <<< "$mods_csv"
  for mod in "${mod_array[@]}"; do
    mod="$(echo "$mod" | tr -d ' ')"
    case "${mod,,}" in
      # shellcheck disable=SC2016
      mod|super) hypr_mods+='$mainMod ' ;;
      shift)     hypr_mods+="SHIFT " ;;
      ctrl)      hypr_mods+="CTRL " ;;
      alt)       hypr_mods+="ALT " ;;
    esac
  done

  # Trim trailing space
  hypr_mods="${hypr_mods% }"
  local hypr_key="${key^^}"

  echo "bind = ${hypr_mods}, ${hypr_key}, exec, ${command}"
}

# --- i3/sway: bindsym $mod+Shift+e exec kall power ---
_translate_i3_sway() {
  local mods_csv="$1" key="$2" command="$3"
  local i3_mods=""

  IFS=',' read -ra mod_array <<< "$mods_csv"
  for mod in "${mod_array[@]}"; do
    mod="$(echo "$mod" | tr -d ' ')"
    case "${mod,,}" in
      mod|super) i3_mods+="\$mod+" ;;
      shift)     i3_mods+="Shift+" ;;
      ctrl)      i3_mods+="Ctrl+" ;;
      alt)       i3_mods+="Mod1+" ;;
    esac
  done

  echo "bindsym ${i3_mods}${key} exec ${command}"
}

# --- bspwm (sxhkd): super + shift + e\n\tkall power ---
_translate_bspwm() {
  local mods_csv="$1" key="$2" command="$3"
  local bsp_mods=""

  IFS=',' read -ra mod_array <<< "$mods_csv"
  for mod in "${mod_array[@]}"; do
    mod="$(echo "$mod" | tr -d ' ')"
    case "${mod,,}" in
      mod|super) bsp_mods+="super + " ;;
      shift)     bsp_mods+="shift + " ;;
      ctrl)      bsp_mods+="ctrl + " ;;
      alt)       bsp_mods+="alt + " ;;
    esac
  done

  printf '%s%s\n\t%s\n' "$bsp_mods" "$key" "$command"
}

# --- awesome: awful.key({ modkey, "Shift" }, "e", function() awful.spawn("kall power") end) ---
_translate_awesome() {
  local mods_csv="$1" key="$2" command="$3"
  local aw_mods=""

  IFS=',' read -ra mod_array <<< "$mods_csv"
  local first=1
  for mod in "${mod_array[@]}"; do
    mod="$(echo "$mod" | tr -d ' ')"
    [[ "$first" -eq 1 ]] || aw_mods+=", "
    first=0
    case "${mod,,}" in
      mod|super) aw_mods+="modkey" ;;
      shift)     aw_mods+="\"Shift\"" ;;
      ctrl)      aw_mods+="\"Control\"" ;;
      alt)       aw_mods+="\"Mod1\"" ;;
    esac
  done

  echo "awful.key({ ${aw_mods} }, \"${key}\", function() awful.spawn(\"${command}\") end)"
}

# --- skhd: shift + cmd - e : kall power ---
_translate_skhd() {
  local mods_csv="$1" key="$2" command="$3"
  local skhd_mods=""

  IFS=',' read -ra mod_array <<< "$mods_csv"
  for mod in "${mod_array[@]}"; do
    mod="$(echo "$mod" | tr -d ' ')"
    case "${mod,,}" in
      mod|super) skhd_mods+="cmd + " ;;
      shift)     skhd_mods+="shift + " ;;
      ctrl)      skhd_mods+="ctrl + " ;;
      alt)       skhd_mods+="alt + " ;;
    esac
  done

  echo "${skhd_mods}${key} : ${command}"
}

# --- Unknown WM: comment format ---
_translate_unknown() {
  local mods_csv="$1" key="$2" command="$3"
  echo "# ${command} (bind ${mods_csv} + ${key})"
}

# =============================================================================
# inject_keybinds — Stub for injecting keybinds into WM config
# =============================================================================

# inject_keybinds CONFIG_FILE KEYBINDS...
#   Injects keybinds between block markers in the given config file.
#   Stub implementation — to be completed when WM config paths are finalized.
inject_keybinds() {
  log_debug "keybinds.sh: inject_keybinds stub called"
  return 0
}

# =============================================================================
# remove_keybinds — Stub for removing injected keybinds from WM config
# =============================================================================

# remove_keybinds CONFIG_FILE
#   Removes everything between block markers in the given config file.
#   Stub implementation — to be completed when WM config paths are finalized.
remove_keybinds() {
  log_debug "keybinds.sh: remove_keybinds stub called"
  return 0
}

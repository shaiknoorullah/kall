#!/usr/bin/env bash
# lib/theme.sh — Palette loader with wallbash color extraction
#
# Loads color palettes from YAML files, exports KALL_COLOR_* variables,
# and optionally extracts colors from the current wallpaper via ImageMagick.

# Guard against double-sourcing
[[ -n "${_KALL_THEME_LOADED:-}" ]] && return 0
_KALL_THEME_LOADED=1

# =============================================================================
# Palette directory
# =============================================================================

KALL_PALETTES_DIR="${KALL_PALETTES_DIR:-$(cd "$KALL_LIB_DIR/.." && pwd)/themes/palettes}"
export KALL_PALETTES_DIR

# =============================================================================
# load_theme — Load a named palette and export KALL_COLOR_* vars
# =============================================================================

# load_theme [PALETTE_NAME]
#   Reads colors from a YAML palette file via yq and exports them.
#   Falls back to catppuccin-mocha if the requested palette is not found.
load_theme() {
  local palette_name="${1:-${KALL_THEME:-catppuccin-mocha}}"
  local palette_file="$KALL_PALETTES_DIR/${palette_name}.yml"

  # Fallback to catppuccin-mocha if palette not found
  if [[ ! -f "$palette_file" ]]; then
    log_warn "theme.sh: palette '$palette_name' not found, falling back to catppuccin-mocha"
    palette_name="catppuccin-mocha"
    palette_file="$KALL_PALETTES_DIR/${palette_name}.yml"
  fi

  if [[ ! -f "$palette_file" ]]; then
    log_error "theme.sh: fallback palette catppuccin-mocha not found at $palette_file"
    return 1
  fi

  if ! command -v yq &>/dev/null; then
    log_error "theme.sh: yq not found, cannot load palette"
    return 1
  fi

  # Read each color via yq and export
  KALL_COLOR_MAIN_BG="$(yq '.colors.main_bg' "$palette_file" 2>/dev/null)"
  KALL_COLOR_MAIN_FG="$(yq '.colors.main_fg' "$palette_file" 2>/dev/null)"
  KALL_COLOR_MAIN_BR="$(yq '.colors.main_br' "$palette_file" 2>/dev/null)"
  KALL_COLOR_MAIN_EX="$(yq '.colors.main_ex' "$palette_file" 2>/dev/null)"
  KALL_COLOR_SELECT_BG="$(yq '.colors.select_bg' "$palette_file" 2>/dev/null)"
  KALL_COLOR_SELECT_FG="$(yq '.colors.select_fg' "$palette_file" 2>/dev/null)"
  KALL_COLOR_URGENT_BG="$(yq '.colors.urgent_bg' "$palette_file" 2>/dev/null)"
  KALL_COLOR_URGENT_FG="$(yq '.colors.urgent_fg' "$palette_file" 2>/dev/null)"

  export KALL_COLOR_MAIN_BG KALL_COLOR_MAIN_FG KALL_COLOR_MAIN_BR KALL_COLOR_MAIN_EX
  export KALL_COLOR_SELECT_BG KALL_COLOR_SELECT_FG
  export KALL_COLOR_URGENT_BG KALL_COLOR_URGENT_FG

  log_debug "theme.sh: loaded palette '$palette_name'"
}

# =============================================================================
# generate_wallbash — Extract dominant colors from a wallpaper via ImageMagick
# =============================================================================

# generate_wallbash WALLPAPER_PATH
#   Uses ImageMagick to extract dominant colors from the wallpaper and
#   sets KALL_COLOR_* vars. Returns 1 on failure.
generate_wallbash() {
  local wallpaper="$1"

  if [[ ! -f "$wallpaper" ]]; then
    log_warn "theme.sh: wallpaper not found: $wallpaper"
    return 1
  fi

  if ! command -v convert &>/dev/null; then
    log_warn "theme.sh: ImageMagick (convert) not found, cannot generate wallbash"
    return 1
  fi

  # Extract 8 dominant colors using ImageMagick color quantization
  local colors
  colors="$(convert "$wallpaper" -resize 100x100! -colors 8 -unique-colors txt:- 2>/dev/null \
    | grep -oE '#[0-9A-Fa-f]{6}' | head -8)" || {
    log_warn "theme.sh: failed to extract colors from wallpaper"
    return 1
  }

  local color_count
  color_count="$(echo "$colors" | wc -l)"
  if [[ "$color_count" -lt 8 ]]; then
    log_warn "theme.sh: insufficient colors extracted from wallpaper ($color_count < 8)"
    return 1
  fi

  # Map extracted colors to KALL_COLOR_* vars
  # Sort by luminance: darkest first for backgrounds, lightest for foregrounds
  local sorted
  sorted="$(echo "$colors" | while IFS= read -r hex; do
    # Calculate relative luminance from hex
    local r g b
    r="$((16#${hex:1:2}))"
    g="$((16#${hex:3:2}))"
    b="$((16#${hex:5:2}))"
    local lum=$(( r * 299 + g * 587 + b * 114 ))
    printf '%06d %s\n' "$lum" "$hex"
  done | sort -n)"

  KALL_COLOR_MAIN_BG="$(echo "$sorted" | sed -n '1p' | awk '{print $2}')"
  KALL_COLOR_MAIN_FG="$(echo "$sorted" | sed -n '8p' | awk '{print $2}')"
  KALL_COLOR_MAIN_BR="$(echo "$sorted" | sed -n '6p' | awk '{print $2}')"
  KALL_COLOR_MAIN_EX="$(echo "$sorted" | sed -n '5p' | awk '{print $2}')"
  KALL_COLOR_SELECT_BG="$(echo "$sorted" | sed -n '2p' | awk '{print $2}')"
  KALL_COLOR_SELECT_FG="$(echo "$sorted" | sed -n '7p' | awk '{print $2}')"
  KALL_COLOR_URGENT_BG="$(echo "$sorted" | sed -n '4p' | awk '{print $2}')"
  KALL_COLOR_URGENT_FG="$(echo "$sorted" | sed -n '8p' | awk '{print $2}')"

  export KALL_COLOR_MAIN_BG KALL_COLOR_MAIN_FG KALL_COLOR_MAIN_BR KALL_COLOR_MAIN_EX
  export KALL_COLOR_SELECT_BG KALL_COLOR_SELECT_FG
  export KALL_COLOR_URGENT_BG KALL_COLOR_URGENT_FG

  log_debug "theme.sh: generated wallbash colors from $wallpaper"
}

# =============================================================================
# list_palettes — List available palette names
# =============================================================================

list_palettes() {
  local f
  for f in "$KALL_PALETTES_DIR"/*.yml; do
    [[ -f "$f" ]] || continue
    basename "$f" .yml
  done
}

# =============================================================================
# Auto-load on source
# =============================================================================

if [[ "${KALL_DYNAMIC_THEME:-false}" == "true" ]]; then
  # Try wallbash first, fall back to static palette
  if ! generate_wallbash "${KALL_WALLPAPER:-}"; then
    load_theme
  fi
else
  load_theme
fi

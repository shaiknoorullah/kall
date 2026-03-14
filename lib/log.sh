#!/usr/bin/env bash
# lib/log.sh — Structured, leveled logging with file output and rotation
#
# INV-LOG-01: All log output MUST go through these functions
# INV-LOG-02: Debug logs MUST NOT be written to kall.log
# INV-LOG-03: Log rotation MUST NOT block startup
#
# Log levels: TRACE(0) DEBUG(1) INFO(2) WARN(3) ERROR(4) FATAL(5)
#
# Configuration (env vars):
#   KALL_LOG_LEVEL      — TRACE|DEBUG|INFO|WARN|ERROR|FATAL (default: INFO)
#   KALL_LOG_FILE       — true|false (default: true)
#   KALL_LOG_DIR        — directory for log files
#   KALL_LOG_MAX_SIZE_MB — rotation threshold in MB (default: 1)
#   KALL_LOG_KEEP_ROTATED — number of rotated files to keep (default: 3)

# Guard against double-sourcing
[[ -n "${_KALL_LOG_LOADED:-}" ]] && return 0
_KALL_LOG_LOADED=1

# --- Log level constants ---
declare -gA _KALL_LOG_LEVELS=(
  [TRACE]=0
  [DEBUG]=1
  [INFO]=2
  [WARN]=3
  [ERROR]=4
  [FATAL]=5
)

# --- Defaults ---
: "${KALL_LOG_LEVEL:=INFO}"
: "${KALL_LOG_FILE:=true}"
: "${KALL_LOG_MAX_SIZE_MB:=1}"
: "${KALL_LOG_KEEP_ROTATED:=3}"

# --- Internal: resolve numeric log level ---
_kall_log_level_num() {
  local level="${1^^}"
  echo "${_KALL_LOG_LEVELS[$level]:-2}"
}

# --- Internal: check if debug mode is active ---
_kall_log_debug_active() {
  local current_num
  current_num="$(_kall_log_level_num "${KALL_LOG_LEVEL}")"
  [[ "$current_num" -le 1 ]]
}

# --- Log rotation ---
# Rotates kall.log when it exceeds the configured size threshold.
# Called at source time (non-blocking) and can be called manually.
_kall_log_rotate() {
  [[ "${KALL_LOG_FILE}" == "true" ]] || return 0
  [[ -n "${KALL_LOG_DIR:-}" ]] || return 0

  local logfile="$KALL_LOG_DIR/kall.log"
  [[ -f "$logfile" ]] || return 0

  local max_bytes
  max_bytes=$(( ${KALL_LOG_MAX_SIZE_MB:-1} * 1024 * 1024 ))

  local file_size
  file_size=$(stat -c%s "$logfile" 2>/dev/null || stat -f%z "$logfile" 2>/dev/null || echo 0)

  if [[ "$file_size" -gt "$max_bytes" ]]; then
    local keep="${KALL_LOG_KEEP_ROTATED:-3}"

    # Remove the oldest rotated file if it would exceed keep count
    if [[ -f "${logfile}.${keep}" ]]; then
      rm -f "${logfile}.${keep}"
    fi

    # Shift existing rotated files up by one
    local i
    for (( i = keep - 1; i >= 1; i-- )); do
      if [[ -f "${logfile}.${i}" ]]; then
        mv -f "${logfile}.${i}" "${logfile}.$(( i + 1 ))"
      fi
    done

    # Move current log to .1
    mv -f "$logfile" "${logfile}.1"
  fi
}

# --- Internal: core log function ---
_kall_log() {
  local level="$1"
  shift
  local message="$*"

  local level_num
  level_num="$(_kall_log_level_num "$level")"

  local current_num
  current_num="$(_kall_log_level_num "${KALL_LOG_LEVEL}")"

  # --- Format the timestamp ---
  local timestamp
  if [[ "$level_num" -le 1 ]]; then
    # TRACE/DEBUG: include milliseconds
    timestamp="$(date '+%Y-%m-%d %H:%M:%S.%3N' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S.000')"
  else
    # INFO+: no milliseconds
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  fi

  # --- Format the log line ---
  local log_line
  if [[ "$level_num" -le 1 ]]; then
    # TRACE/DEBUG format: [LEVEL] YYYY-MM-DD HH:MM:SS.mmm file.sh:line  message
    local caller_file caller_line
    # Walk up the call stack to find the actual caller (not log.sh internals)
    local frame=1
    while [[ "$frame" -lt 10 ]]; do
      caller_file="${BASH_SOURCE[$frame]:-unknown}"
      caller_line="${BASH_LINENO[$((frame - 1))]:-0}"
      # Stop if we've left log.sh
      if [[ "$caller_file" != *"log.sh" ]]; then
        break
      fi
      (( frame++ ))
    done
    caller_file="$(basename "$caller_file")"
    log_line="[${level}] ${timestamp} ${caller_file}:${caller_line}  ${message}"
  else
    # INFO+ format: [LEVEL] YYYY-MM-DD HH:MM:SS  message
    log_line="[${level}] ${timestamp}  ${message}"
  fi

  # --- Output to stderr ---
  # ERROR(4) and FATAL(5) are always shown regardless of configured level
  if [[ "$level_num" -ge 4 || "$level_num" -ge "$current_num" ]]; then
    echo "$log_line" >&2
  fi

  # --- Output to log files ---
  if [[ "${KALL_LOG_FILE}" == "true" && -n "${KALL_LOG_DIR:-}" ]]; then
    mkdir -p "$KALL_LOG_DIR" 2>/dev/null || true

    # kall.log: INFO+ only (INV-LOG-02: never DEBUG/TRACE)
    if [[ "$level_num" -ge 2 ]]; then
      echo "$log_line" >> "$KALL_LOG_DIR/kall.log"
    fi

    # debug.log: all levels, only when debug mode is active
    if _kall_log_debug_active; then
      echo "$log_line" >> "$KALL_LOG_DIR/debug.log"
    fi
  fi

  # FATAL: exit after logging
  if [[ "$level" == "FATAL" ]]; then
    exit 1
  fi
}

# --- Public API ---

log_trace() { _kall_log TRACE "$@"; }
log_debug() { _kall_log DEBUG "$@"; }
log_info()  { _kall_log INFO  "$@"; }
log_warn()  { _kall_log WARN  "$@"; }
log_error() { _kall_log ERROR "$@"; }
log_fatal() { _kall_log FATAL "$@"; }

# --- Run rotation at source time (non-blocking, INV-LOG-03) ---
_kall_log_rotate &>/dev/null || true

#!/usr/bin/env bats
# tests/test_log.bats — Tests for lib/log.sh structured logging

setup() {
  load test_helper/common.bash
  common_setup

  # Set up log directory in test temp
  export KALL_LOG_DIR="$TEST_TEMP/logs"
  mkdir -p "$KALL_LOG_DIR"

  # Enable file logging by default
  export KALL_LOG_FILE="true"

  # Default log level
  export KALL_LOG_LEVEL="INFO"

  # Source the logging library
  source "$LIB_DIR/log.sh"
}

teardown() {
  common_teardown
}

# --- 1. INFO message shown at INFO level ---

@test "INFO message shown at INFO level" {
  run log_info "hello world"
  assert_success
  assert_output --partial "[INFO]"
  assert_output --partial "hello world"
}

# --- 2. DEBUG message hidden at INFO level ---

@test "DEBUG message hidden at INFO level" {
  export KALL_LOG_LEVEL="INFO"
  run log_debug "debug stuff"
  assert_success
  refute_output --partial "debug stuff"
}

# --- 3. DEBUG message shown at DEBUG level ---

@test "DEBUG message shown at DEBUG level" {
  export KALL_LOG_LEVEL="DEBUG"
  run log_debug "debug visible"
  assert_success
  assert_output --partial "[DEBUG]"
  assert_output --partial "debug visible"
}

# --- 4. WARN message shown at INFO level ---

@test "WARN message shown at INFO level" {
  export KALL_LOG_LEVEL="INFO"
  run log_warn "warning here"
  assert_success
  assert_output --partial "[WARN]"
  assert_output --partial "warning here"
}

# --- 5. ERROR message always shown ---

@test "ERROR message always shown" {
  export KALL_LOG_LEVEL="FATAL"
  run log_error "critical error"
  assert_success
  assert_output --partial "[ERROR]"
  assert_output --partial "critical error"
}

# --- 6. Writes to kall.log when file logging enabled ---

@test "writes to kall.log when file logging enabled" {
  export KALL_LOG_FILE="true"
  log_info "persistent message"
  [[ -f "$KALL_LOG_DIR/kall.log" ]]
  grep -q "persistent message" "$KALL_LOG_DIR/kall.log"
}

# --- 7. Does not write to kall.log when file logging disabled ---

@test "does not write to kall.log when file logging disabled" {
  export KALL_LOG_FILE="false"
  log_info "ephemeral message" 2>/dev/null
  if [[ -f "$KALL_LOG_DIR/kall.log" ]]; then
    ! grep -q "ephemeral message" "$KALL_LOG_DIR/kall.log"
  fi
}

# --- 8. DEBUG does not write to kall.log even in debug mode (INV-LOG-02) ---

@test "DEBUG does not write to kall.log even in debug mode" {
  export KALL_LOG_LEVEL="DEBUG"
  export KALL_LOG_FILE="true"
  log_debug "secret debug" 2>/dev/null
  if [[ -f "$KALL_LOG_DIR/kall.log" ]]; then
    ! grep -q "secret debug" "$KALL_LOG_DIR/kall.log"
  fi
}

# --- 9. INFO format is clean (no file:line) ---

@test "INFO format is clean with no file:line" {
  run log_info "clean message"
  assert_success
  # INFO format should be: [INFO] YYYY-MM-DD HH:MM:SS  message
  # It should NOT contain .sh: or .bats: (source location)
  refute_output --regexp '\.sh:[0-9]+'
  refute_output --regexp '\.bats:[0-9]+'
}

# --- 10. TRACE format includes source location in debug mode ---

@test "TRACE format includes source location" {
  export KALL_LOG_LEVEL="TRACE"
  run log_trace "trace message"
  assert_success
  assert_output --partial "[TRACE]"
  assert_output --partial "trace message"
  # TRACE format should include file:line (bats uses .bash internally)
  assert_output --regexp '\.(sh|bats|bash):[0-9]+'
}

# --- 11. Rotates when log exceeds max size ---

@test "rotates when log exceeds max size" {
  export KALL_LOG_MAX_SIZE_MB="0"

  # Create a log file that exceeds the threshold (any size > 0 bytes)
  local logfile="$KALL_LOG_DIR/kall.log"
  # Write some content to make it non-empty
  printf '%1000s' ' ' > "$logfile"

  # Run rotation
  _kall_log_rotate

  # Original should be gone or empty, rotated file should exist
  [[ -f "${logfile}.1" ]]
}

# --- 12. FATAL exits with code 1 ---

@test "FATAL exits with code 1" {
  run log_fatal "something broke"
  assert_failure 1
  assert_output --partial "[FATAL]"
  assert_output --partial "something broke"
}

# --- Additional invariant tests ---

@test "TRACE message hidden at INFO level" {
  export KALL_LOG_LEVEL="INFO"
  run log_trace "trace stuff"
  assert_success
  refute_output --partial "trace stuff"
}

@test "TRACE does not write to kall.log even in trace mode" {
  export KALL_LOG_LEVEL="TRACE"
  export KALL_LOG_FILE="true"
  log_trace "trace secret" 2>/dev/null
  if [[ -f "$KALL_LOG_DIR/kall.log" ]]; then
    ! grep -q "trace secret" "$KALL_LOG_DIR/kall.log"
  fi
}

@test "DEBUG format includes source location" {
  export KALL_LOG_LEVEL="DEBUG"
  run log_debug "debug with location"
  assert_success
  assert_output --regexp '\.(sh|bats|bash):[0-9]+'
}

@test "writes to debug.log when debug mode active" {
  export KALL_LOG_LEVEL="DEBUG"
  export KALL_LOG_FILE="true"
  log_debug "debug file entry" 2>/dev/null
  [[ -f "$KALL_LOG_DIR/debug.log" ]]
  grep -q "debug file entry" "$KALL_LOG_DIR/debug.log"
}

@test "INFO also writes to debug.log when debug mode active" {
  export KALL_LOG_LEVEL="DEBUG"
  export KALL_LOG_FILE="true"
  log_info "info in debug" 2>/dev/null
  [[ -f "$KALL_LOG_DIR/debug.log" ]]
  grep -q "info in debug" "$KALL_LOG_DIR/debug.log"
}

@test "rotation keeps correct number of rotated files" {
  export KALL_LOG_MAX_SIZE_MB="0"
  export KALL_LOG_KEEP_ROTATED="2"

  local logfile="$KALL_LOG_DIR/kall.log"

  # Simulate multiple rotations
  printf 'content-round-1' > "$logfile"
  _kall_log_rotate
  printf 'content-round-2' > "$logfile"
  _kall_log_rotate
  printf 'content-round-3' > "$logfile"
  _kall_log_rotate

  # Should have .1 and .2 but NOT .3 (keep_rotated=2)
  [[ -f "${logfile}.1" ]]
  [[ -f "${logfile}.2" ]]
  [[ ! -f "${logfile}.3" ]]
}

@test "log format includes timestamp" {
  run log_info "timestamped"
  assert_success
  # Should match YYYY-MM-DD HH:MM:SS pattern
  assert_output --regexp '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}'
}

@test "WARN writes to kall.log" {
  export KALL_LOG_FILE="true"
  log_warn "warn to file" 2>/dev/null
  [[ -f "$KALL_LOG_DIR/kall.log" ]]
  grep -q "warn to file" "$KALL_LOG_DIR/kall.log"
}

@test "ERROR writes to kall.log" {
  export KALL_LOG_FILE="true"
  log_error "error to file" 2>/dev/null
  [[ -f "$KALL_LOG_DIR/kall.log" ]]
  grep -q "error to file" "$KALL_LOG_DIR/kall.log"
}

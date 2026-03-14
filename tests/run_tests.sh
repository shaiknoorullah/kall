#!/usr/bin/env bash
# tests/run_tests.sh — BATS test runner for kall
# Checks bats installed, auto-installs helpers if missing, runs tests.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#shellcheck disable=SC2034
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HELPER_DIR="$SCRIPT_DIR/test_helper"

# --- Check bats is installed ---
if ! command -v bats &>/dev/null; then
  echo "ERROR: bats is not installed."
  echo "Install it with your package manager:"
  echo "  arch: pacman -S bash-bats"
  echo "  brew: brew install bats-core"
  echo "  apt:  apt install bats"
  exit 1
fi

# --- Auto-install bats-support if missing ---
if [[ ! -d "$HELPER_DIR/bats-support" ]]; then
  echo "Installing bats-support..."
  git clone --depth 1 https://github.com/bats-core/bats-support.git \
    "$HELPER_DIR/bats-support"
fi

# --- Auto-install bats-assert if missing ---
if [[ ! -d "$HELPER_DIR/bats-assert" ]]; then
  echo "Installing bats-assert..."
  git clone --depth 1 https://github.com/bats-core/bats-assert.git \
    "$HELPER_DIR/bats-assert"
fi

# --- Run tests ---
if [[ $# -gt 0 ]]; then
  # Run specific test file(s)
  bats "$@"
else
  # Run all test_*.bats files
  bats "$SCRIPT_DIR"/test_*.bats
fi

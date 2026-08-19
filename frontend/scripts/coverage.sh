#!/usr/bin/env bash
# Runs the full test suite with coverage and prints a filtered per-file report.
# Exclusions: generated code, app bootstrap, and DI wiring (see plan).
set -euo pipefail
cd "$(dirname "$0")/.."

fvm flutter test --coverage "$@"

lcov --quiet --ignore-errors empty,unused --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/main.dart' \
  'lib/core/di/injection_container.dart' \
  -o coverage/lcov.filtered.info

lcov --list coverage/lcov.filtered.info
echo "----"
lcov --summary coverage/lcov.filtered.info

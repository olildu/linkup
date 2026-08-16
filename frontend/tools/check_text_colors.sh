#!/usr/bin/env bash
# Fails if presentation layer uses hardcoded Material Colors on text-related properties.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/lib/presentation"

PATTERN='(TextStyle|hintStyle|labelColor|unselectedLabelColor|labelStyle|unselectedLabelStyle).*color:\s*Colors\.'

if rg -n "$PATTERN" "$TARGET" --glob '*.dart' 2>/dev/null; then
  echo ""
  echo "error: hardcoded Colors.* found on text styles in lib/presentation."
  echo "Use Theme.of(context).textTheme / colorScheme or AppColors from lib/presentation/constants/colors.dart."
  exit 1
fi

echo "ok: no hardcoded Colors.* on text style properties in lib/presentation"

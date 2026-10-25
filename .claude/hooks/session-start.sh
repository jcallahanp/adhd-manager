#!/usr/bin/env bash
# SessionStart hook: prints the stable header (status + rules pointer). stdout becomes context.
# Also records the git base of this session so the Stop gate can see what changed.
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
input="$(cat 2>/dev/null || true)"
sid="$(printf '%s' "$input" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | head -n1)"
src="$(printf '%s' "$input" | sed -n 's/.*"source" *: *"\([^"]*\)".*/\1/p' | head -n1)"

if [ -n "$sid" ] && [ ! -f "/tmp/ap-base-$sid" ]; then
  git -C "$ROOT" rev-parse HEAD > "/tmp/ap-base-$sid" 2>/dev/null || true
fi

echo "=== PLATFORM: STATUS HEADER (docs/STATUS.md) ==="
head -n 60 "$ROOT/docs/STATUS.md" 2>/dev/null || echo "(docs/STATUS.md is missing)"
echo "=== WORKING RULES, SHORT FORM (full text: docs/RULES.md) ==="
echo "This session covers one task from the status file. The spec is docs/SPEC.md; decisions are appended to docs/DECISIONS.md."
echo "The Stop hook blocks finishing until docs/STATUS.md and a docs/log/<date>-<task>.md entry are updated when files changed."
if [ "$src" = "compact" ] && [ -n "$sid" ] && [ -f "/tmp/ap-checkpoint-$sid" ]; then
  echo "=== CHECKPOINT WRITTEN BEFORE COMPACTION ==="
  cat "/tmp/ap-checkpoint-$sid"
fi
exit 0

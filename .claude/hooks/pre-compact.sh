#!/usr/bin/env bash
# PreCompact hook: writes a git-state checkpoint that the SessionStart(compact) hook prints back.
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
input="$(cat 2>/dev/null || true)"
sid="$(printf '%s' "$input" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | head -n1)"
[ -z "$sid" ] && exit 0
cd "$ROOT" 2>/dev/null || exit 0
{
  echo "Compaction at $(date -u +%Y-%m-%dT%H:%MZ). Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null). HEAD: $(git rev-parse --short HEAD 2>/dev/null)."
  echo "Uncommitted files:"
  git status --porcelain 2>/dev/null | head -n 40
  echo "Last commits:"
  git log --oneline -n 5 2>/dev/null
  echo "Open ledger items: see docs/STATUS.md 'In progress'."
} > "/tmp/ap-checkpoint-$sid" 2>/dev/null
exit 0

#!/usr/bin/env bash
# Stop hook: when files changed in this session, require a docs/STATUS.md update and a docs/log entry.
# Never loops: exits 0 when stop_hook_active is already set.
# Manual run (hooks not loaded): AP_BASE=origin/main bash .claude/hooks/stop-gate.sh </dev/null
set -u
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
input="$(cat 2>/dev/null || true)"
case "$input" in
  *'"stop_hook_active": true'*|*'"stop_hook_active":true'*) exit 0 ;;
esac
sid="$(printf '%s' "$input" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | head -n1)"
cd "$ROOT" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

base="${AP_BASE:-}"
[ -z "$base" ] && [ -n "$sid" ] && [ -f "/tmp/ap-base-$sid" ] && base="$(cat "/tmp/ap-base-$sid")"
changed="$(
  { [ -n "$base" ] && git diff --name-only "$base" HEAD 2>/dev/null
    git status --porcelain 2>/dev/null | awk '{print $NF}'
  } | sort -u
)"
[ -z "$changed" ] && exit 0

code="$(printf '%s\n' "$changed" | grep -v -E '^docs/(STATUS\.md|log/)' | grep -v -E '^\.claude/' || true)"
[ -z "$code" ] && exit 0

status_ok="$(printf '%s\n' "$changed" | grep -c -E '^docs/STATUS\.md$' || true)"
log_ok="$(printf '%s\n' "$changed" | grep -c -E '^docs/log/[0-9]{4}-[0-9]{2}-[0-9]{2}-.+\.md$' || true)"
if [ "${status_ok:-0}" -gt 0 ] && [ "${log_ok:-0}" -gt 0 ]; then exit 0; fi

missing=""
[ "${status_ok:-0}" -eq 0 ] && missing="docs/STATUS.md"
[ "${log_ok:-0}" -eq 0 ] && missing="${missing:+$missing and }a docs/log/<date>-<task>.md entry (template: docs/log/TEMPLATE.md)"
printf '{"decision":"block","reason":"Files changed in this session but the ledger was not updated. Update %s, commit, then finish."}\n' "$missing"
exit 0

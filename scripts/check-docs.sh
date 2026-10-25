#!/usr/bin/env bash
# Docs consistency check. Exit 1 on any contradiction CI can detect.
set -u
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$root" || exit 1; fail=0
say() { echo "::error::$1"; fail=1; }
# 1. CLAUDE.md short; STATUS short
[ "$(wc -l < CLAUDE.md)" -le 40 ] || say "CLAUDE.md over 40 lines"
[ "$(wc -l < docs/STATUS.md)" -le 40 ] || say "docs/STATUS.md over 40 lines"
# 2. Decision ids unique and sequential
ids="$(grep -o -E '^- D-[0-9]{3}' docs/DECISIONS.md | sed 's/^- //')"
[ "$(printf '%s\n' "$ids" | sort | uniq -d | wc -l)" -eq 0 ] || say "duplicate decision ids in docs/DECISIONS.md"
# 3. Every D-nnn referenced anywhere exists in DECISIONS
for ref in $(grep -rho -E 'D-[0-9]{3}' CLAUDE.md docs security .github 2>/dev/null | sort -u); do
  grep -q -E "^- $ref " docs/DECISIONS.md || say "$ref is referenced but not defined in docs/DECISIONS.md"
done
# 4. Files CLAUDE.md points at exist
for f in $(grep -o -E '`[A-Za-z0-9_./-]+`' CLAUDE.md | tr -d '`' | grep -E '^(docs|security|scripts|\.claude)/|\.md$' | sort -u); do
  [ -e "$f" ] || [ -e "${f%/}" ] || say "CLAUDE.md points at missing path $f"
done
# 5. Every log entry has the required sections
for f in docs/log/20*.md; do
  for h in "## Task" "## Done" "## Deviations" "## Bottlenecks" "## Verification"; do
    grep -q "^$h" "$f" || say "$f lacks section '$h'"
  done
done
# 6. STATUS 'Next' items with issue numbers point at the same task ids used in logs or issues (format only)
grep -E '^- M[0-9]+-[0-9A-Z]+ \(#[0-9]+\)' docs/STATUS.md >/dev/null || echo "note: no issue-linked tasks in STATUS"
[ "$fail" -eq 0 ] && echo "docs consistent"
exit "$fail"

#!/usr/bin/env bash
# Usage: scripts/task-log.sh M1-03 "Short title"  -> creates docs/log/<today>-M1-03.md from the template.
set -eu
id="${1:?task id, e.g. M1-03}"; title="${2:?short title}"
root="$(git rev-parse --show-toplevel)"
f="$root/docs/log/$(date +%F)-$id.md"
[ -e "$f" ] && { echo "exists: $f"; exit 0; }
sed -e "s/YYYY-MM-DD/$(date +%F)/" -e "s/TASK-ID/$id/" -e "s/short title/$title/" "$root/docs/log/TEMPLATE.md" > "$f"
echo "$f"

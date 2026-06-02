#!/usr/bin/env bash
# Compare Cursor terminalAllowlist vs Claude Bash allow entries.
# Exit 1 if drift detected. Requires jq.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CURSOR_PERMS="${ROOT}/packages/cursor/permissions.json"
CLAUDE_SETTINGS="${ROOT}/packages/claude/settings.json"

if ! command -v jq &>/dev/null; then
  echo "SKIP: jq required" >&2
  exit 0
fi

cursor_tmp=$(mktemp)
claude_tmp=$(mktemp)
trap 'rm -f "$cursor_tmp" "$claude_tmp"' EXIT

jq -r '.terminalAllowlist[]' "$CURSOR_PERMS" | sort -u >"$cursor_tmp"
jq -r '.permissions.allow[] | select(startswith("Bash(")) |
  sub("^Bash\\("; "") | sub(":.*$"; "")' "$CLAUDE_SETTINGS" | sort -u >"$claude_tmp"

only_cursor=$(comm -23 "$cursor_tmp" "$claude_tmp" || true)
only_claude=$(comm -13 "$cursor_tmp" "$claude_tmp" || true)

failed=0
if [[ -n "$only_cursor" ]]; then
  echo "In Cursor terminalAllowlist but missing from Claude Bash allow:" >&2
  echo "$only_cursor" | sed 's/^/  - /' >&2
  failed=1
fi
if [[ -n "$only_claude" ]]; then
  echo "In Claude Bash allow but missing from Cursor terminalAllowlist:" >&2
  echo "$only_claude" | sed 's/^/  - /' >&2
  failed=1
fi

if [[ "$failed" -eq 0 ]]; then
  echo "ok: terminal allowlist in sync ($(wc -l <"$cursor_tmp" | tr -d ' ') entries)"
  exit 0
fi

echo "hint: update packages/cursor/permissions.json and packages/claude/settings.json together" >&2
exit 1

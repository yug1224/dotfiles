#!/usr/bin/env bash
# Compare Cursor terminalAllowlist / mcpAllowlist vs Claude permissions.allow.
# Exit 1 if drift detected. Requires jq.
#
# Env:
#   REQUIRE_JQ=1  — fail if jq is missing (CI). Default: SKIP with exit 0.
#   MCP_EXCEPTIONS — path to exception file (default: scripts/mcp-allowlist-exceptions.txt)
#     Lines: only_cursor|<canonical> or only_claude|<canonical>
#     Exact match only (side|canonical must equal the drifted entry).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_PERMS="${CURSOR_PERMS:-${ROOT}/packages/cursor/permissions.json}"
CLAUDE_SETTINGS="${CLAUDE_SETTINGS:-${ROOT}/packages/claude/settings.json}"
MCP_EXCEPTIONS="${MCP_EXCEPTIONS:-${ROOT}/scripts/mcp-allowlist-exceptions.txt}"

if ! command -v jq &>/dev/null; then
  if [[ "${REQUIRE_JQ:-0}" == "1" ]]; then
    echo "ERROR: jq required (REQUIRE_JQ=1)" >&2
    exit 1
  fi
  echo "SKIP: jq required" >&2
  exit 0
fi

normalize_server() {
  case "$1" in
    user-github) printf '%s' "github" ;;
    *) printf '%s' "$1" ;;
  esac
}

claude_mcp_to_canonical() {
  local e="$1"
  e="${e#mcp__}"
  local server="${e%%__*}"
  local tool="${e#*__}"
  server="$(normalize_server "$server")"
  printf '%s:%s\n' "$server" "$tool"
}

cursor_mcp_to_canonical() {
  local e="$1"
  local server="${e%%:*}"
  local tool="${e#*:}"
  server="$(normalize_server "$server")"
  printf '%s:%s\n' "$server" "$tool"
}

# Exact match: side|canonical must equal the drifted entry.
is_excepted() {
  local side="$1" entry="$2"
  [[ -f "$MCP_EXCEPTIONS" ]] || return 1
  local line ex_side ex_pat
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    ex_side="${line%%|*}"
    ex_pat="${line#*|}"
    if [[ "$ex_side" == "$side" && "$ex_pat" == "$entry" ]]; then
      return 0
    fi
  done <"$MCP_EXCEPTIONS"
  return 1
}

cursor_term=$(mktemp)
claude_term=$(mktemp)
cursor_mcp=$(mktemp)
claude_mcp=$(mktemp)
trap 'rm -f "$cursor_term" "$claude_term" "$cursor_mcp" "$claude_mcp"' EXIT

jq -r '.terminalAllowlist[]' "$CURSOR_PERMS" | sort -u >"$cursor_term"
jq -r '.permissions.allow[] | select(startswith("Bash(")) |
  sub("^Bash\\("; "") | sub(":.*$"; "")' "$CLAUDE_SETTINGS" | sort -u >"$claude_term"

failed=0

only_cursor_term=$(comm -23 "$cursor_term" "$claude_term" || true)
only_claude_term=$(comm -13 "$cursor_term" "$claude_term" || true)

if [[ -n "$only_cursor_term" ]]; then
  echo "In Cursor terminalAllowlist but missing from Claude Bash allow:" >&2
  echo "$only_cursor_term" | sed 's/^/  - /' >&2
  failed=1
fi
if [[ -n "$only_claude_term" ]]; then
  echo "In Claude Bash allow but missing from Cursor terminalAllowlist:" >&2
  echo "$only_claude_term" | sed 's/^/  - /' >&2
  failed=1
fi

while IFS= read -r e; do
  [[ -z "$e" ]] && continue
  cursor_mcp_to_canonical "$e"
done < <(jq -r '.mcpAllowlist[]' "$CURSOR_PERMS") | sort -u >"$cursor_mcp"

while IFS= read -r e; do
  [[ -z "$e" ]] && continue
  claude_mcp_to_canonical "$e"
done < <(jq -r '.permissions.allow[] | select(startswith("mcp__"))' "$CLAUDE_SETTINGS") | sort -u >"$claude_mcp"

only_cursor_mcp=""
while IFS= read -r c || [[ -n "$c" ]]; do
  [[ -z "$c" ]] && continue
  if is_excepted "only_cursor" "$c"; then
    continue
  fi
  only_cursor_mcp+="$c"$'\n'
done < <(comm -23 "$cursor_mcp" "$claude_mcp" || true)

only_claude_mcp=""
while IFS= read -r l || [[ -n "$l" ]]; do
  [[ -z "$l" ]] && continue
  if is_excepted "only_claude" "$l"; then
    continue
  fi
  only_claude_mcp+="$l"$'\n'
done < <(comm -13 "$cursor_mcp" "$claude_mcp" || true)

if [[ -n "${only_cursor_mcp}" ]]; then
  echo "In Cursor mcpAllowlist but missing from Claude mcp allow:" >&2
  printf '%s' "$only_cursor_mcp" | sed '/^$/d; s/^/  - /' >&2
  failed=1
fi
if [[ -n "${only_claude_mcp}" ]]; then
  echo "In Claude mcp allow but missing from Cursor mcpAllowlist:" >&2
  printf '%s' "$only_claude_mcp" | sed '/^$/d; s/^/  - /' >&2
  failed=1
fi

if [[ "$failed" -eq 0 ]]; then
  echo "ok: terminal allowlist in sync ($(wc -l <"$cursor_term" | tr -d ' ') entries)"
  echo "ok: mcp allowlist in sync (cursor=$(wc -l <"$cursor_mcp" | tr -d ' ') claude=$(wc -l <"$claude_mcp" | tr -d ' ') canonical)"
  exit 0
fi

echo "hint: update packages/cursor/permissions.json and packages/claude/settings.json together" >&2
echo "hint: intentional MCP asymmetries go in scripts/mcp-allowlist-exceptions.txt" >&2
exit 1

#!/usr/bin/env bash
# Verify Cursor alwaysApply and Claude CLAUDE.md Tier A match always-on.json.
# Bidirectional for both hosts. Ignores *.local.* wrappers.
# Bash 3.2 compatible. Requires jq.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT}/packages/shared/ai/manifests/always-on.json"
CURSOR_RULES="${ROOT}/packages/cursor/rules"
CLAUDE_MD="${ROOT}/packages/claude/CLAUDE.md"

if [[ ! -f "$MANIFEST" ]]; then
  echo "FAIL: missing $MANIFEST" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  if [[ "${REQUIRE_JQ:-0}" == "1" ]]; then
    echo "ERROR: jq required (REQUIRE_JQ=1)" >&2
    exit 1
  fi
  echo "SKIP: jq required" >&2
  exit 0
fi

failed=0

CURSOR_EXPECTED="$(jq -r '.cursor.alwaysApply[]' "$MANIFEST")"
CLAUDE_EXPECTED="$(jq -r '.claude.tierA[]' "$MANIFEST")"

CURSOR_ACTUAL_FILE="$(mktemp)"
CLAUDE_ACTUAL_FILE="$(mktemp)"
trap 'rm -f "$CURSOR_ACTUAL_FILE" "$CLAUDE_ACTUAL_FILE"' EXIT

find "$CURSOR_RULES" -type f -name '*.mdc' ! -name '*.local.mdc' -print0 |
  while IFS= read -r -d '' f; do
    rel="${f#"$CURSOR_RULES"/}"
    id="${rel%.mdc}"
    case "$id" in
      *.local) continue ;;
    esac
    if grep -qE '^alwaysApply:[[:space:]]*true[[:space:]]*$' "$f"; then
      printf '%s\n' "$id"
    fi
  done | sort -u >"$CURSOR_ACTUAL_FILE"

while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if ! grep -qxF "$id" "$CURSOR_ACTUAL_FILE"; then
    echo "FAIL: manifest cursor.alwaysApply missing in wrappers: $id" >&2
    failed=1
  fi
done <<<"$CURSOR_EXPECTED"

while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if ! printf '%s\n' "$CURSOR_EXPECTED" | grep -qxF "$id"; then
    echo "FAIL: Cursor alwaysApply:true not in manifest: $id" >&2
    failed=1
  fi
done <"$CURSOR_ACTUAL_FILE"

: >"$CLAUDE_ACTUAL_FILE"
if grep -qE '^@~/.config/shared/ai/AGENTS\.md[[:space:]]*$' "$CLAUDE_MD"; then
  echo "AGENTS.md" >>"$CLAUDE_ACTUAL_FILE"
fi
if grep -qE '^@RTK\.md[[:space:]]*$' "$CLAUDE_MD"; then
  echo "RTK.md" >>"$CLAUDE_ACTUAL_FILE"
fi
grep -E '^@\./rules/[^[:space:]]+\.md[[:space:]]*$' "$CLAUDE_MD" |
  sed -E 's|^@\./rules/(.*)\.md[[:space:]]*$|\1|' >>"$CLAUDE_ACTUAL_FILE" || true
sort -u "$CLAUDE_ACTUAL_FILE" -o "$CLAUDE_ACTUAL_FILE"

while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if ! grep -qxF "$id" "$CLAUDE_ACTUAL_FILE"; then
    echo "FAIL: CLAUDE.md missing Tier A import for: $id" >&2
    failed=1
  fi
done <<<"$CLAUDE_EXPECTED"

while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if ! printf '%s\n' "$CLAUDE_EXPECTED" | grep -qxF "$id"; then
    echo "FAIL: CLAUDE.md Tier A import not in manifest: $id" >&2
    failed=1
  fi
done <"$CLAUDE_ACTUAL_FILE"

if [[ "$failed" -eq 0 ]]; then
  echo "ok: always-on sync"
  exit 0
fi
exit 1

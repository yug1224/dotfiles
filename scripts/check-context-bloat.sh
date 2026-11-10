#!/usr/bin/env bash
# Soft line-budget warnings; hard fail on kernel/CLAUDE.md over limit and stray .mdc.
# Usage: ./scripts/check-context-bloat.sh [--fail]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-}"
FAIL=0

check() {
  local limit="$1" path="$2" lines
  [[ -f "$path" ]] || return 0
  lines="$(wc -l <"$path" | tr -d ' ')"
  if [[ "$lines" -gt "$limit" ]]; then
    echo "WARN: ${path#"$ROOT/"} has $lines lines (soft limit $limit)" >&2
    [[ "$MODE" == "--fail" ]] && FAIL=1
  fi
  return 0
}

check_hard() {
  local limit="$1" path="$2" lines
  [[ -f "$path" ]] || { echo "FAIL: ${path#"$ROOT/"} is missing" >&2; exit 1; }
  lines="$(wc -l <"$path" | tr -d ' ')"
  if [[ "$lines" -gt "$limit" ]]; then
    echo "FAIL: ${path#"$ROOT/"} has $lines lines (hard limit $limit)" >&2
    FAIL=1
  fi
}

while IFS= read -r -d '' f; do check 120 "$f"; done \
  < <(find "$ROOT/packages/shared/ai/rules" -name '*.md' ! -name '*.local.md' -print0)

check_hard 40 "$ROOT/packages/claude/CLAUDE.md"
check_hard 40 "$ROOT/packages/cursor/rules/kernel.mdc"
check 60 "$ROOT/packages/cursor/README.md"
check 60 "$ROOT/packages/claude/README.md"
check 80 "$ROOT/packages/shared/ai/README.md"
check 80 "$ROOT/packages/shared/ai/CONVENTIONS.md"

# Hard fail: only kernel.mdc is allowed under packages/cursor/rules/
CURSOR_RULES_DIR="$ROOT/packages/cursor/rules"
while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  [[ "$base" == "kernel.mdc" ]] && continue
  echo "FAIL: disallowed .mdc in packages/cursor/rules/: ${f#"$ROOT/"}" >&2
  exit 1
done < <(find "$CURSOR_RULES_DIR" -name '*.mdc' -print0)

if [[ "$FAIL" -ne 0 ]]; then
  echo "check-context-bloat: failed" >&2
  exit 1
fi
echo "ok: check-context-bloat"

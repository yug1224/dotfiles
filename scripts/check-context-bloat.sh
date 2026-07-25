#!/usr/bin/env bash
# Context bloat check for AI config (warn-first).
# Usage: ./scripts/check-context-bloat.sh [--fail]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0
MODE="${1:-}"

warn() {
  echo "WARN: $*" >&2
  if [[ "$MODE" == "--fail" ]]; then
    FAIL=1
  fi
}

# Always-on: Claude Tier A entry count from manifest
ALWAYS_ON="$ROOT/packages/shared/ai/manifests/always-on.json"
if command -v jq >/dev/null 2>&1; then
  tier_count="$(jq '.claude.tierA | length' "$ALWAYS_ON")"
  if [[ "$tier_count" -gt 2 ]]; then
    warn "claude.tierA has $tier_count entries (prefer <=2; token-opt + INDEX expected)"
  else
    echo "ok: claude.tierA count=$tier_count"
  fi
  cursor_count="$(jq '.cursor.alwaysApply | length' "$ALWAYS_ON")"
  echo "ok: cursor.alwaysApply count=$cursor_count"
else
  warn "jq not found; skip always-on count check"
fi

# Line-count warnings for shared commands/rules.
# Known soft overages (baseline): warn only when *exceeding* baseline.
# Shrink baseline when files get smaller; do not raise without review.
baseline_for() {
  case "$1" in
  */rules/blog/blog-review-rule.md) echo 216 ;;
  *) echo 0 ;;
  esac
}

warn_lines() {
  local path="$1"
  local soft="$2"
  local lines base limit
  lines="$(wc -l <"$path" | tr -d ' ')"
  base="$(baseline_for "$path")"
  if [[ "$base" -gt "$soft" ]]; then
    limit="$base"
  else
    limit="$soft"
  fi
  if [[ "$lines" -gt "$limit" ]]; then
    warn "$path has $lines lines (soft limit $limit)"
  fi
}

while IFS= read -r -d '' f; do
  warn_lines "$f" 220
done < <(find "$ROOT/packages/shared/ai/commands" -name '*.md' ! -name '*.local.md' -print0)

while IFS= read -r -d '' f; do
  warn_lines "$f" 200
done < <(find "$ROOT/packages/shared/ai/rules" -name '*.md' ! -name '*.local.md' -print0)

# CLAUDE.md should stay thin
claude_md="$ROOT/packages/claude/CLAUDE.md"
if [[ -f "$claude_md" ]]; then
  warn_lines "$claude_md" 40
  if grep -qE '^@~/.config/shared/ai/AGENTS\.md[[:space:]]*$' "$claude_md"; then
    warn "CLAUDE.md still always-imports AGENTS.md"
  fi
  if grep -qE '^@RTK\.md[[:space:]]*$' "$claude_md"; then
    warn "CLAUDE.md still always-imports RTK.md"
  fi
fi

# Informational: Cursor *.local.mdc with alwaysApply:true (excluded from manifest by design)
local_aa=0
local_aa_lines=0
if [[ -d "$ROOT/packages/cursor/rules" ]]; then
  while IFS= read -r -d '' f; do
    if grep -qE '^alwaysApply:[[:space:]]*true[[:space:]]*$' "$f"; then
      local_aa=$((local_aa + 1))
      # Prefer shared .local.md body line count when present
      id="${f#"$ROOT/packages/cursor/rules/"}"
      id="${id%.mdc}"
      body="$ROOT/packages/shared/ai/rules/${id}.md"
      if [[ -f "$body" ]]; then
        local_aa_lines=$((local_aa_lines + $(wc -l <"$body" | tr -d ' ')))
      else
        local_aa_lines=$((local_aa_lines + $(wc -l <"$f" | tr -d ' ')))
      fi
    fi
  done < <(find "$ROOT/packages/cursor/rules" -type f -name '*.local.mdc' -print0 2>/dev/null || true)
fi
# Also count deployed/home wrappers if present (optional, non-failing)
if [[ -d "$HOME/.cursor/rules" ]]; then
  while IFS= read -r -d '' f; do
    if grep -qE '^alwaysApply:[[:space:]]*true[[:space:]]*$' "$f"; then
      # Avoid double-count if symlink into packages
      if command -v realpath >/dev/null 2>&1; then
        real="$(realpath "$f")"
      else
        real="$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$f" 2>/dev/null || echo "$f")"
      fi
      case "$real" in
      "$ROOT"/*) continue ;;
      esac
      local_aa=$((local_aa + 1))
      local_aa_lines=$((local_aa_lines + $(wc -l <"$f" | tr -d ' ')))
    fi
  done < <(find "$HOME/.cursor/rules" -type f -name '*.local.mdc' -print0 2>/dev/null || true)
fi
echo "info: cursor local alwaysApply count=$local_aa approx_lines=$local_aa_lines (excluded from manifest; see always-on.json notes)"

if [[ "$FAIL" -ne 0 ]]; then
  echo "check-context-bloat: failed" >&2
  exit 1
fi
echo "ok: check-context-bloat"

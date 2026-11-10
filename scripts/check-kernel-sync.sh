#!/usr/bin/env bash
# Fail when Cursor kernel.mdc and Claude CLAUDE.md drift apart.
# Allowed differences (stripped before diff):
#   Cursor: frontmatter
#   Claude: `# CLAUDE.md` 見出し
# codegraph install が足す CODEGRAPH_START〜END ブロックは差分として FAIL にする。
# Usage: ./scripts/check-kernel-sync.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CURSOR="$ROOT/packages/cursor/rules/kernel.mdc"
CLAUDE="$ROOT/packages/claude/CLAUDE.md"

# 空行を除いて比較する（段落の区切り位置の差は問わない）
normalize_cursor() {
  awk 'NR == 1 && /^---$/ { fm = 1; next } fm && /^---$/ { fm = 0; next } !fm' "$CURSOR" \
    | grep -v -e '^[[:space:]]*$'
}

normalize_claude() {
  grep -v -e '^# CLAUDE\.md$' -e '^[[:space:]]*$' "$CLAUDE"
}

if ! diff -u --label kernel.mdc --label CLAUDE.md <(normalize_cursor) <(normalize_claude) >&2; then
  echo "FAIL: packages/cursor/rules/kernel.mdc と packages/claude/CLAUDE.md の指示がずれています" >&2
  exit 1
fi
echo "ok: check-kernel-sync"

#!/usr/bin/env bash
# Cursor の kernel.mdc は Claude の CLAUDE.md から作る。正本は CLAUDE.md。
# kernel.mdc = 下の frontmatter + CLAUDE.md の `# CLAUDE.md` 見出しより後ろ。
# Usage: ./scripts/check-kernel-sync.sh          # ずれていれば FAIL
#        ./scripts/check-kernel-sync.sh --write  # kernel.mdc を作り直す（make kernel）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CURSOR="$ROOT/packages/cursor/rules/kernel.mdc"
CLAUDE="$ROOT/packages/claude/CLAUDE.md"

generate() {
  printf '%s\n' '---' 'description: 作業種別ごとの詳細ルールの自動 Read' 'alwaysApply: true' '---' ''
  # 見出しと、その直後の空行を落とす
  awk 'skip && /^[[:space:]]*$/ { next } { skip = 0 } /^# CLAUDE\.md$/ { skip = 1; next } { print }' "$CLAUDE"
}

# codegraph install が足すブロックは消す決まり（docs/setup-codegraph.md）。kernel.mdc に写さない
if grep -q 'CODEGRAPH_START' "$CLAUDE"; then
  echo "FAIL: CLAUDE.md に codegraph install のブロックがあります。消してください（packages/shared/ai/docs/setup-codegraph.md）" >&2
  exit 1
fi

if [[ "${1:-}" == "--write" ]]; then
  generate >"$CURSOR"
  echo "wrote: ${CURSOR#"$ROOT/"}"
  exit 0
fi

if ! diff -u --label kernel.mdc --label "generated from CLAUDE.md" "$CURSOR" <(generate) >&2; then
  echo "FAIL: kernel.mdc が CLAUDE.md とずれています。CLAUDE.md を直して make kernel を実行してください" >&2
  exit 1
fi
echo "ok: check-kernel-sync"

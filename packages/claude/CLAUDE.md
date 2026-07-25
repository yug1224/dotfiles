# CLAUDE.md

このファイルは Claude Code 全セッションで自動的にロードされる、ユーザーレベルの常時コンテキスト。常時ロードはトークン最適化とルール発見索引のみに絞り、規約・チェックリストの本文はコマンド／明示 Read でオンデマンドに取り込む。

- 共有本文の原本は `packages/shared/ai/`。`make mise` で `~/.config/shared/ai/` に展開され、`@~/.config/shared/ai/...` で参照する
- `packages/claude/rules/` のラッパーは `~/.claude/rules/` に展開され、`@./rules/...`（`~/.claude/` 基準の相対パス）で参照する

## 常時ロード（Tier A）

@./rules/conventions/token-optimization-rule.md
@./rules/INDEX.md

## オンデマンド（Tier B）

以下は常時ロードしない。必要になった時点で取り込む（索引は `INDEX.md`）。

- スラッシュコマンド: `~/.claude/commands/`（`/suggest-commit-message`、`/suggest-branch-name`、`/review-diff`、`/review-pr` など）
- サブエージェント: `~/.claude/agents/`
- ルール本文: `INDEX.md` の表に従い `@./rules/...` を明示 Read
- 共通メンテ手順・RTK・CodeGraph: `~/.config/shared/ai/AGENTS.md`、`docs/ALLOWLIST-SYNC.md`、`docs/RTK.md`、`docs/CODEGRAPH.md`

常時ロード対象の正本は `packages/shared/ai/manifests/always-on.json`（`make check-sync` が照合）。

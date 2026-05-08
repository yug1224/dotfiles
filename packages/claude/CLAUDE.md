# CLAUDE.md

このファイルは Claude Code 全セッションで自動的にロードされる、ユーザーレベルの常時コンテキスト。共有の AGENTS 本文は `~/.config/shared/ai/` に `make stow` で展開され、`@~/.config/shared/ai/...` で取り込む。`packages/claude/rules/` のラッパーは `~/.claude/rules/` に展開され、`@./rules/...`（`~/.claude/` 基準の相対パス）で取り込む。

## 共通規約

@~/.config/shared/ai/AGENTS.md

## 開発規約

@./rules/conventions/commit-message-rule.md
@./rules/conventions/branch-name-rule.md

## レビュー / チケット運用

@./rules/conventions/review-common-rule.md
@./rules/conventions/ticket-retrieval-rule.md

## エージェント・コマンド

`~/.claude/agents/` と `~/.claude/commands/` 配下にラッパーを配置している。本文は `packages/shared/shared/ai/{agents,commands}/` の原本を `@`-import（`@~/.config/shared/ai/` 絶対パス）で取り込む。詳細は `@~/.config/shared/ai/AGENTS.md` を参照。

`~/.claude/rules/` 配下のラッパーは `packages/shared/shared/ai/rules/` の原本を `@~/.config/shared/ai/rules/...` で `@`-import する。

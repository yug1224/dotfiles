# AGENTS.md

このファイルは Cursor / Claude Code 向けの **メンテ・運用メモ**（ツール横断の allowlist / always-on / CodeGraph）。エージェントの常時コンテキストには載せない。必要時のみ Read する（Claude Tier A からは外している）。

## このリポジトリでの位置付け

- 原本: `packages/shared/ai/AGENTS.md`
- デプロイ先: `make mise` により `~/.config/shared/ai/` に展開される
- 各ツール側からの参照（全て `@~/.config/shared/ai/` 絶対パス）:
  - Cursor: `packages/cursor/commands/*.md` → `@~/.config/shared/ai/commands/...`、`packages/cursor/rules/<sub>/*.mdc` → `@~/.config/shared/ai/rules/<sub>/...`
  - Claude Code: `packages/claude/commands/*.md` → `@~/.config/shared/ai/commands/...`。常時ロードは `packages/claude/CLAUDE.md` の Tier A（`token-optimization-rule` + `INDEX`）

## 運用方針

- 規約・プロンプト本体・hook シェルスクリプトなど **ツール非依存の素材**は `packages/shared/ai/` に置く
- ツール固有の frontmatter / 設定 JSON / ホストごとの hook 仕様は各 `packages/<tool>/` に置く
- 共通本文を編集する場合は `packages/shared/ai/` 配下の原本のみを変更する

詳細な allowlist・RTK・CodeGraph の手順は [docs/ALLOWLIST-SYNC.md](./docs/ALLOWLIST-SYNC.md) を参照（本ファイルから移設）。

## Always-on

正本: [`manifests/always-on.json`](./manifests/always-on.json)。Cursor `alwaysApply` は `token-optimization-rule` のみ。Claude Tier A は同ルール + `INDEX`（発見索引・本文はオンデマンド）。`*.local.*` の `alwaysApply: true`（例: `coding-rule.local`）は意図的 L2 で manifest 外（`notes.localAlwaysApply`）。`make check-sync` が照合する。

## CodeGraph（要約）

- セットアップ: [docs/CODEGRAPH.md](./docs/CODEGRAPH.md)
- 利用ルール: [rules/conventions/codegraph-rule.md](./rules/conventions/codegraph-rule.md)（Cursor: agent-requestable。Claude: コマンド／明示 Read）
- **プロジェクトごと**に `codegraph init` が必要

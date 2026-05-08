# AGENTS.md

このファイルは Cursor / Claude Code / Gemini CLI の各 AI コーディングツールが共通で参照する規約・運用ルールを集約する。`packages/shared/shared/ai/` の単一原本として管理し、各ツールの設定パッケージから `@`-import（`@~/.config/shared/ai/` 絶対パス）で取り込む。

## このリポジトリでの位置付け

- 原本: `packages/shared/shared/ai/AGENTS.md`
- デプロイ先: `make stow` により `~/.config/shared/ai/` に展開される
- 各ツール側からの参照（全て `@~/.config/shared/ai/` 絶対パス）:
  - Cursor: `packages/cursor/commands/*.md` → `@~/.config/shared/ai/commands/...`、`packages/cursor/rules/<sub>/*.mdc` → `@~/.config/shared/ai/rules/<sub>/...`
  - Claude Code: `packages/claude/CLAUDE.md` → `@~/.config/shared/ai/AGENTS.md`、`packages/claude/commands/*.md` → `@~/.config/shared/ai/commands/...`
  - Gemini CLI: 同様に `@~/.config/shared/ai/...`

## 運用方針

- 規約・プロンプト本体・hook シェルスクリプトなど **ツール非依存の素材**は `packages/shared/shared/ai/` に置く
- ツール固有の frontmatter / 設定 JSON / ホストごとの hook 仕様は各 `packages/<tool>/` に置く
- 共通本文を編集する場合は `packages/shared/shared/ai/` 配下の原本のみを変更する

（個別の規約・チェックリストは順次このディレクトリ配下に集約していく）

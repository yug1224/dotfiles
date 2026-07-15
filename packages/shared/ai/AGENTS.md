# AGENTS.md

このファイルは Cursor / Claude Code が共通で参照する規約・運用ルールを集約する（Gemini CLI 用ホストパッケージ `packages/gemini` は **未実装**）。`packages/shared/ai/` の単一原本として管理し、各ツールの設定パッケージから `@`-import（`@~/.config/shared/ai/` 絶対パス）で取り込む。

## このリポジトリでの位置付け

- 原本: `packages/shared/ai/AGENTS.md`
- デプロイ先: `make mise-dotfiles` により `~/.config/shared/ai/` に展開される
- 各ツール側からの参照（全て `@~/.config/shared/ai/` 絶対パス）:
  - Cursor: `packages/cursor/commands/*.md` → `@~/.config/shared/ai/commands/...`、`packages/cursor/rules/<sub>/*.mdc` → `@~/.config/shared/ai/rules/<sub>/...`
  - Claude Code: `packages/claude/CLAUDE.md` → `@~/.config/shared/ai/AGENTS.md`、`packages/claude/commands/*.md` → `@~/.config/shared/ai/commands/...`

## 運用方針

- 規約・プロンプト本体・hook シェルスクリプトなど **ツール非依存の素材**は `packages/shared/ai/` に置く
- ツール固有の frontmatter / 設定 JSON / ホストごとの hook 仕様は各 `packages/<tool>/` に置く
- 共通本文を編集する場合は `packages/shared/ai/` 配下の原本のみを変更する

## Allowlist 同期チェックリスト

ターミナル / MCP の Auto-run 許可リストは **Cursor と Claude で別ファイル・別フォーマット**に存在する。追加・変更時は両方を同時に更新する。

| ツール | ファイル                                              | 形式例                                         |
| ------ | ----------------------------------------------------- | ---------------------------------------------- |
| Cursor | `packages/cursor/permissions.json`                    | `"git status"`, `"github:get_*"`               |
| Claude | `packages/claude/settings.json` → `permissions.allow` | `"Bash(git status:*)"`, `"mcp__github__get_*"` |

### 変更手順

1. ポリシー意図を決める（読み取り専用 terminal / MCP か、書き込みか）
2. Cursor `permissions.json` の `terminalAllowlist` または `mcpAllowlist` に追加
3. Claude `settings.json` の `permissions.allow` に同等エントリを追加（`Bash(<cmd>:*)` または `mcp__<server>__<tool>` 形式）
4. 破壊的操作は allowlist ではなく **guard-shell**（deny/ask）で制御する — allowlist に載せない
5. RTK が書き換えるコマンド（`git status` → `rtk git status`）は allowlist を拡張しない — RTK hook が `permission: allow` を返す
6. **必須**: `make check-sync`（terminal + MCP allowlist / wrapper parity / deny-guard / always-on）

### MCP 意図的非対称

- Playwright MCP は Cursor のみ許可（例外は `scripts/mcp-allowlist-exceptions.txt` に **個別列挙**。新規 Playwright ツールは例外ファイルも更新すること）。
- 比較時は `user-github` を `github` に正規化する（両ファイルに二重記載があっても可）

### RTK との関係

RTK は **インストール済み・hook 有効** を前提とする。詳細（セットアップ・hook 配線・競合の対処）: [docs/RTK.md](./docs/RTK.md)

## Guard matcher（意図的非対称）

- Cursor `hooks.json`: guard は `git |gh |pnpm `、RTK は `Shell`
- Claude `settings.json`: guard / RTK とも `Bash` matcher → 同一 `packages/shared/ai/hooks/guard-shell.sh`
- matcher を同一に揃える必要はない（判定ロジックの正本は shared）

## Always-on

正本: [`manifests/always-on.json`](./manifests/always-on.json)。Cursor `alwaysApply` と Claude Tier A は意図的に非対称。`make check-sync` が照合する。

## CodeGraph

セマンティックコードインテリジェンス（ローカル知識グラフ）。CLI は mise でグローバルインストール、MCP 配線は手動マージ。

- セットアップ・トラブルシュート: [docs/CODEGRAPH.md](./docs/CODEGRAPH.md)
- エージェント利用ルール: [rules/conventions/codegraph-rule.md](./rules/conventions/codegraph-rule.md)
- **プロジェクトごと**に `codegraph init` が必要（`.codegraph/` 作成）。未初期化では MCP 有効でもインデックスなし
- Cursor: `packages/cursor/rules/conventions/codegraph-rule.mdc`（agent-requestable）
- Claude: `packages/claude/CLAUDE.md` から `codegraph-rule` を import

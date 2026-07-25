# Allowlist / Guard / RTK 同期手順

`AGENTS.md` から分離したメンテ手順。dotfiles の allowlist や hook を変更するときだけ Read する。

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
6. **必須**: `make check-sync`（terminal + MCP allowlist / wrapper parity / deny-guard / always-on / context-bloat）

### MCP 意図的非対称

- Playwright MCP は Cursor のみ許可（例外は `scripts/mcp-allowlist-exceptions.txt` に **個別列挙**。新規 Playwright ツールは例外ファイルも更新すること）。
- 比較時は `user-github` を `github` に正規化する（両ファイルに二重記載があっても可）

### RTK との関係

RTK は **インストール済み・hook 有効** を前提とする。詳細（セットアップ・hook 配線・競合の対処）: [RTK.md](./RTK.md)

## Guard matcher（意図的非対称）

- Cursor `hooks.json`: guard は `git |gh |pnpm `、RTK は `Shell`
- Claude `settings.json`: guard / RTK とも `Bash` matcher → 同一 `packages/shared/ai/hooks/guard-shell.sh`
- matcher を同一に揃える必要はない（判定ロジックの正本は shared）

# VS Code / Cursor ユーザー設定（`settings.json`）

このパッケージは **Visual Studio Code** と **Cursor** の両方のユーザー設定ディレクトリへ同じ `settings.json` を `make mise`（ルート `mise.toml` の `[dotfiles]`）で配布する。

## デプロイ先

- `~/Library/Application Support/Code/User`（VS Code）
- `~/Library/Application Support/Cursor/User`（Cursor）

```bash
make mise
```

設定変更後は **Developer: Reload Window** を実行する。

## パス（`$HOME` 固定）

[`settings.json`](settings.json) の oxfmt 関連パスは **`$HOME` ベースの固定パス**で記述する（Oxc 拡張と custom-local-formatters が展開する）。

| キー / 用途                          | パス                                                                       |
| ------------------------------------ | -------------------------------------------------------------------------- |
| dotfiles ルート                      | `$HOME/.dotfiles`（`make mise` でリポジトリへ symlink）                    |
| `oxc.fmt.configPath`                 | `$HOME/.dotfiles/oxfmt.config.ts`                                          |
| `oxc.path.oxfmt` / `oxc.path.oxlint` | `$HOME/.local/share/mise/installs/npm-oxfmt/latest/...`（mise グローバル） |
| `customLocalFormatters`              | `$HOME/.dotfiles/packages/code/bin/oxfmt-stdin.sh`                         |

**前提**: `make mise` によりリポジトリが `$HOME/.dotfiles` に symlink されること（clone 場所は問わない）。適用後は **Developer: Reload Window** を実行する。

Oxc の LSP は `${workspaceFolder}` を展開しない。

## 保存時フォーマット（Oxc）

[oxc-vscode](https://github.com/oxc-project/oxc-vscode) の Oxfmt は **ファイル全体** のフォーマットのみ対応する。次をユーザー設定で有効にしている。

| キー                       | 値                            | 役割                                         |
| -------------------------- | ----------------------------- | -------------------------------------------- |
| `editor.formatOnSave`      | `true`                        | 保存時にフォーマット                         |
| `editor.formatOnSaveMode`  | `file`                        | 変更行だけではなくファイル全体を対象（必須） |
| `editor.codeActionsOnSave` | `source.format.oxc`: `always` | Oxc の Code Action 経由でもフォーマット      |

非 JS 言語では `source.format.oxc` を `never` にし、下記 CLI ラッパーと二重実行しない。

問題時: コマンドパレットの `Oxc: Show Output Channel (Formatter)` / `Restart oxfmt Server`。拡張は Marketplace の **Oxc**（`oxc.oxc-vscode`）を最新に保つ。

**「拡張機能 'Oxc' はフォーマッタとして構成されていますが、'TypeScript'-ファイルをフォーマットできません」** は、ほぼ常に **oxfmt の LSP が起動していない**（フォーマッタ未登録）状態。次を確認する。

| 確認                                                                | 対処                                                                                                                                        |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| ステータスバーに `oxc` が出ない / Output に `No valid oxfmt binary` | `mise install` で `npm:oxfmt` を入れる。dotfiles 以外ではルートに `oxfmt` を入れるか、ユーザー設定の `oxc.path.oxfmt` を確認                |
| Node を **mise** 等だけで入れている                                 | ユーザー設定の **`oxc.useExecPath`: `true`**（Cursor / VS Code 同梱 Node で `cli.js` を実行）                                               |
| 他リポジトリで dotfiles の `oxfmt.config.ts` を使いたい             | そのリポジトリの `.vscode/settings.json` に `"oxc.fmt.configPath": "oxfmt.config.ts"` とルートの設定ファイル。無いパスを指すと LSP が落ちる |
| 設定変更後も直らない                                                | `Oxc: Restart oxfmt Server` → **Developer: Reload Window**                                                                                  |

## フォーマッタ（ハイブリッド）

| 言語                                       | `editor.defaultFormatter`          | 経路                                                            |
| ------------------------------------------ | ---------------------------------- | --------------------------------------------------------------- |
| JavaScript / TypeScript / JSX / TSX        | `oxc.oxc-vscode`                   | LSP + `source.format.oxc`                                       |
| CSS / HTML / JSON / JSONC / Markdown / Vue | `jkillian.custom-local-formatters` | `oxfmt` CLI（stdin）                                            |
| Terraform                                  | `hashicorp.terraform`              | `source.formatAll.terraform`（`[terraform-vars]` は保存時 off） |

`customLocalFormatters.formatters` は [`bin/oxfmt-stdin.sh`](bin/oxfmt-stdin.sh) 経由で mise グローバルの `oxfmt` を呼ぶ（`$HOME/.local/share/mise/shims/oxfmt`、未インストール時は `node_modules/.bin/oxfmt` にフォールバック）。

`oxc.path.oxfmt` / `oxc.fmt.configPath` / `oxc.useExecPath` は **ユーザー設定（本ファイル）にのみ**書く。dotfiles リポジトリを開いたときも同じ `$HOME` パスで `oxfmt.config.ts` を指すため、[`.vscode/settings.json`](../../.vscode/settings.json) に Oxc 設定は置かない（重複と上書きの混乱を避ける）。

[`.vscode/settings.json`](../../.vscode/settings.json) に置くのは **ワークスペース依存だけ**（例: `typescript.tsdk` → このリポジトリの `node_modules/typescript`）。

**他リポジトリ**では、そのプロジェクトの `.vscode/settings.json` に `"oxc.fmt.configPath": "oxfmt.config.ts"` と `"oxc.path.oxfmt": "node_modules/oxfmt/dist/cli.js"`（ルートからの相対パス）を書く。詳細は [`packages/oxfmt/README.md`](../oxfmt/README.md)。

## 主な拡張（mise bootstrap）

ルート [`mise.toml`](../../mise.toml) の `[tasks.bootstrap]` で `code --install-extension` により冪等インストール。`vscode:` package plugin（`mise-plugins/mise-vscode-extensions`）は公式例のみで repo 未公開のため、公開後に宣言化予定。

- フォーマット: **`oxc.oxc-vscode`**、**`jkillian.custom-local-formatters`**（非 JS）
- Terraform: HashiCorp 拡張は手動インストール想定

## AI ルール・エージェントとの関係

`settings.json` はエディタのフォーマッタ・拡張機能・UI などの設定であり、**Cursor の `rules` / `commands` / `agents` や `packages/shared/ai` の共有ルールとは別レイヤー**である。AI 用の dotfiles は [`packages/cursor`](../cursor/README.md)、[`packages/claude`](../claude/README.md)、[`packages/shared/ai`](../shared/ai/README.md) を参照する。

**Claude Code** は VS Code / Cursor の `settings.json` を読み込まない（CLI / 別プロセス）。エディタ設定の共有は本 `packages/code` パッケージ、**ターミナル・MCP の allowlist やエージェント規約**の共有は `packages/shared/ai`（および `make mise` 先の `~/.config/shared/ai`）で行う、という切り分けになる。

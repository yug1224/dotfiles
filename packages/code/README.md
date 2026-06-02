# VS Code / Cursor ユーザー設定（`settings.json`）

このパッケージは **Visual Studio Code** と **Cursor** の両方のユーザー設定ディレクトリへ同じ `settings.json` を `stow` で配布する。

## デプロイ先

リポジトリの [`Makefile`](../../Makefile) より:

- `~/Library/Application Support/Code/User`（VS Code）
- `~/Library/Application Support/Cursor/User`（Cursor）

```bash
make stow
```

設定変更後は **Developer: Reload Window** を実行する。

## パス置換（`dotfiles-path`）

[`settings.json`](settings.json) は [`.gitattributes`](../../.gitattributes) の `filter=dotfiles-path` 対象。**Cursor / VS Code / Oxc は `__DOTFILES__` を解釈しない**（README 後述のとおり LSP も展開しない）。実際に読まれるのは **smudge 後の絶対パス**だけ。

| 場所                   | 中身                                             |
| ---------------------- | ------------------------------------------------ |
| Git にコミットされる形 | `__DOTFILES__/...`（マシン非依存）               |
| 作業ツリー・stow 先    | `/path/to/dotfiles/...`（smudge 済みであること） |

- `git checkout` / clone 時: smudge で `__DOTFILES__` → リポジトリの絶対パス
- `git add` 時: clean で絶対パス → `__DOTFILES__` に戻る
- **作業ツリーや `~/Library/Application Support/Cursor/User/settings.json` に `__DOTFILES__` が残っているとフォーマット等が壊れる** → `git checkout HEAD -- packages/code/settings.json`（filter 有効時）か、手動で実パスに直してから `make stow`

`packages/git` を stow し、グローバル Git に `[filter "dotfiles-path"]` が入っていることも前提とする。

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

| 確認                                                                | 対処                                                                                                                                                                      |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ステータスバーに `oxc` が出ない / Output に `No valid oxfmt binary` | ワークスペースで `pnpm install` または `npm install`。dotfiles 以外ではルートに `oxfmt` を入れるか、ユーザー設定の `oxc.path.oxfmt`（dotfiles の `node_modules`）が有効か |
| Node を **mise** 等だけで入れている                                 | ユーザー設定の **`oxc.useExecPath`: `true`**（Cursor / VS Code 同梱 Node で `cli.js` を実行）                                                                             |
| 他リポジトリで dotfiles の `oxfmt.config.ts` を使いたい             | そのリポジトリの `.vscode/settings.json` に `"oxc.fmt.configPath": "oxfmt.config.ts"` とルートの設定ファイル。無いパスを指すと LSP が落ちる                               |
| 設定変更後も直らない                                                | `Oxc: Restart oxfmt Server` → **Developer: Reload Window**                                                                                                                |

## フォーマッタ（ハイブリッド）

| 言語                                       | `editor.defaultFormatter`          | 経路                                                            |
| ------------------------------------------ | ---------------------------------- | --------------------------------------------------------------- |
| JavaScript / TypeScript / JSX / TSX        | `oxc.oxc-vscode`                   | LSP + `source.format.oxc`                                       |
| CSS / HTML / JSON / JSONC / Markdown / Vue | `jkillian.custom-local-formatters` | `oxfmt` CLI（stdin）                                            |
| Terraform                                  | `hashicorp.terraform`              | `source.formatAll.terraform`（`[terraform-vars]` は保存時 off） |

`customLocalFormatters.formatters` は [`bin/oxfmt-stdin.sh`](bin/oxfmt-stdin.sh) 経由で `oxfmt` を呼ぶ（`__DOTFILES__` は git の `dotfiles-path` フィルタで実パスに展開される。リポジトリ内が `__DOTFILES__` のままなら `git checkout HEAD -- packages/code/settings.json` で smudge する）。

`oxc.path.oxfmt` / `oxc.fmt.configPath` / `oxc.useExecPath` は **ユーザー設定（本ファイル）にのみ**書く。dotfiles リポジトリを開いたときも同じ絶対パスで `oxfmt.config.ts` を指すため、[`.vscode/settings.json`](../../.vscode/settings.json) に Oxc 設定は置かない（重複と上書きの混乱を避ける）。

[`.vscode/settings.json`](../../.vscode/settings.json) に置くのは **ワークスペース依存だけ**（例: `typescript.tsdk` → このリポジトリの `node_modules/typescript`）。

Oxc の LSP は `${workspaceFolder}` や `__DOTFILES__` を展開しない。

**他リポジトリ**では、そのプロジェクトの `.vscode/settings.json` に `"oxc.fmt.configPath": "oxfmt.config.ts"` と `"oxc.path.oxfmt": "node_modules/oxfmt/dist/cli.js"`（ルートからの相対パス）を書く。詳細は [`packages/oxfmt/README.md`](../oxfmt/README.md)。

## 主な拡張（Brewfile）

[`Brewfile`](../../Brewfile) の `vscode '...'` と対応。

- フォーマット: **`oxc.oxc-vscode`**、**`jkillian.custom-local-formatters`**（非 JS）
- Terraform: HashiCorp 拡張は手動インストール想定

## AI ルール・エージェントとの関係

`settings.json` はエディタのフォーマッタ・拡張機能・UI などの設定であり、**Cursor の `rules` / `commands` / `agents` や `packages/shared/shared/ai` の共有ルールとは別レイヤー**である。AI 用の dotfiles は [`packages/cursor`](../cursor/README.md)、[`packages/claude`](../claude/README.md)、[`packages/shared/shared/ai`](../shared/shared/ai/README.md) を参照する。

**Claude Code** は VS Code / Cursor の `settings.json` を読み込まない（CLI / 別プロセス）。エディタ設定の共有は本 `packages/code` パッケージ、**ターミナル・MCP の allowlist やエージェント規約**の共有は `packages/shared/shared/ai`（および `make stow` 先の `~/.config/shared/ai`）で行う、という切り分けになる。

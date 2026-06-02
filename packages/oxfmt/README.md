# oxfmt（このリポジトリ）

## 構成

| ファイル                                                      | 役割                                                                                         |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [`preset.base.ts`](preset.base.ts)                            | 他リポジトリにも持ち出せる汎用プリセット（スタイル・import ソート・package.json ソートなど） |
| リポジトリルートの [`oxfmt.config.ts`](../../oxfmt.config.ts) | `presetBase` をインポートし、リポジトリ固有の設定を上書きした **実効設定**                   |

`oxfmt.config.ts` は `presetBase` をスプレッドし、`printWidth` / `ignorePatterns` / `overrides` などリポジトリ固有の値を直接記述しています。

## npm scripts

| コマンド         | 説明                                  |
| ---------------- | ------------------------------------- |
| `pnpm run check` | フォーマット差分チェック（CI 向け）   |
| `pnpm run fmt`   | 全ファイルをフォーマット（`--write`） |

## エディタ（OXC）

[`packages/code/settings.json`](../code/settings.json) のユーザー設定では、`oxc.fmt.configPath` は `__DOTFILES__/oxfmt.config.ts`（stow 後は dotfiles ルート固定）、`oxc.path.oxfmt` は `__DOTFILES__/node_modules/oxfmt/dist/cli.js` です。**dotfiles リポジトリで `npm install` または `pnpm install` 済み**であることが前提です。

他リポジトリをワークスペースのルートで開く場合は、そのプロジェクトの `.vscode/settings.json` で `"oxc.fmt.configPath": "oxfmt.config.ts"` のように**ワークスペースルートからの相対パス**で指定する（`${workspaceFolder}` は Oxc LSP では展開されない）。**dotfiles リポジトリ自体**は [`packages/code/settings.json`](../code/settings.json)（ユーザー設定）の絶対パスで足りる。設定ファイルをリネームしたら、参照パスも手動で更新してください（自動追従しません）。

保存時フォーマットは [`packages/code/README.md`](../code/README.md) の `editor.formatOnSaveMode` / `source.format.oxc` を参照。

## 他リポジトリで汎用だけ使う

`preset.base.ts` の `presetBase` オブジェクトをコピーするか、内容を `.oxfmtrc.json` に書き起こして使ってください。必要ならそこで `printWidth` 等を上書きします。

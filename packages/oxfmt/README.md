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

[`packages/code/settings.json`](../code/settings.json) のユーザー設定では、`oxc.fmt.configPath` は `$HOME/.dotfiles/oxfmt.config.ts`（`make mise` 前提）、`oxc.path.oxfmt` は mise グローバル（`$HOME/.local/share/mise/installs/npm-oxfmt/latest/lib/node_modules/oxfmt/dist/cli.js`）です。**`mise install` で `npm:oxfmt` が入っていること**が前提です（lefthook / `pnpm run fmt` は引き続きローカル `node_modules` の `oxfmt` も使用）。

他リポジトリをワークスペースのルートで開く場合は、そのプロジェクトの `.vscode/settings.json` で `"oxc.fmt.configPath": "oxfmt.config.ts"` のように**ワークスペースルートからの相対パス**で指定する（`${workspaceFolder}` は Oxc LSP では展開されない）。**dotfiles リポジトリ自体**は [`packages/code/settings.json`](../code/settings.json)（ユーザー設定）の `$HOME` パスで足りる。設定ファイルをリネームしたら、参照パスも手動で更新してください（自動追従しません）。

保存時フォーマットは [`packages/code/README.md`](../code/README.md) の `editor.formatOnSaveMode` / `source.format.oxc` を参照。

## 他リポジトリで汎用だけ使う

`preset.base.ts` の `presetBase` オブジェクトをコピーするか、内容を `.oxfmtrc.json` に書き起こして使ってください。必要ならそこで `printWidth` 等を上書きします。

## 依存の所有権

oxfmt は二重管理です。エディタの `oxc.path.oxfmt` は mise の `npm:oxfmt`（グローバル）を指し、CI / lefthook / `pnpm run fmt|check` はルート [`package.json`](../../package.json) の `devDependencies.oxfmt`（`node_modules`）を使います。npm 側の更新は Dependabot（ecosystem: npm）が担当します。エディタ側を揃えるときは `mise upgrade npm:oxfmt`（または `mise install`）でグローバルを更新してください。

Node の正本はルート [`.node-version`](../../.node-version)（`24`）です。[`packages/mise/config.toml`](../mise/config.toml) の `node = "24"` と揃え、CI の `actions/setup-node` は `node-version-file: .node-version` で同じ値を読みます。

Dependabot は npm に加え GitHub Actions も週次で更新し、`github-actions` グループ（`patterns: ["*"]`）にまとめて PR します。設定は [`.github/dependabot.yml`](../../.github/dependabot.yml) を参照。

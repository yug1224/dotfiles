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

[`packages/code/settings.json`](../code/settings.json) の `oxc.fmt.configPath` は `${workspaceFolder}/oxfmt.config.ts` です。**このリポジトリをワークスペースのルートで開き**、`pnpm install` 済みであることが前提です。設定ファイルをリネームしたら `oxc.fmt.configPath` も同じパスに更新してください（自動追従しません）。

## 他リポジトリで汎用だけ使う

`preset.base.ts` の `presetBase` オブジェクトをコピーするか、内容を `.oxfmtrc.json` に書き起こして使ってください。必要ならそこで `printWidth` 等を上書きします。

# Raycast Extensions

個人利用向け Raycast 拡張。ルートの pnpm workspace（`packages/raycast/*`）の一員です。

## 拡張一覧

| 名前                  | パス                                                 | 説明                   |
| --------------------- | ---------------------------------------------------- | ---------------------- |
| Audio Device Settings | [`audio-device-settings/`](./audio-device-settings/) | 入出力切替・input mute |

## Import（共通手順）

1. リポジトリルートで `pnpm install`
2. 各拡張で `pnpm run dev`（ルートからなら `pnpm --filter audio-device-settings dev` も可）
3. Raycast で開発用拡張として読み込み

前提: [SwitchAudioSource](https://github.com/deweller/switchaudio-osx)。導入は `make mise`（`[bootstrap.packages]` の `brew:switchaudio-osx`）を優先。

## Quality（ルートから）

```sh
pnpm run lint:check   # packages/raycast 配下を oxlint（type-aware）
pnpm run lint:fix     # oxlint --fix
pnpm run fmt:check    # oxfmt --check
pnpm run fmt:fix      # oxfmt write
pnpm run type:check   # 各拡張の tsc --noEmit
pnpm run check        # fmt:check + lint:check + type:check
```

拡張ごとの詳細は、各サブディレクトリの README を参照してください。

# audio-device-settings

macOS の入出力オーディオデバイス切替と input mute を行う Raycast 拡張。

## Installation

```sh
make mise      # brew:switchaudio-osx を含む（リポジトリルート）
pnpm install   # リポジトリルートで実行
pnpm run dev   # このディレクトリ、またはルートから pnpm --filter audio-device-settings dev
```

[SwitchAudioSource](https://github.com/deweller/switchaudio-osx) が必要です。正の導入経路は `make mise`（`mise.toml` の `[bootstrap.packages]` → `brew:switchaudio-osx`）。単体なら `brew install switchaudio-osx` でも可。

## Development

- **lint**: `pnpm run lint:check` / `pnpm run lint:fix`（oxlint + type-aware）
- **format**: `pnpm run fmt:check` / `pnpm run fmt:fix`（ルートの `oxfmt` 設定を参照）
- **typecheck**: `pnpm run type:check`（`tsc --noEmit`）
- **check**: `pnpm run check`（lint:check + type:check + fmt:check）

## Usage

- **Set Input Audio Device** — 入力デバイス一覧から選択
- **Set Output Audio Device** — 出力デバイス一覧から選択
- **Mute / Unmute / Toggle** — 入力デバイスの mute（公式 `-m` オプション、Core Audio 経由）

mute は音量を 0 にするのではなく、Core Audio の mute フラグを操作します。unmute すると直前の音量レベルが復元されます。

## License

[MIT](https://choosealicense.com/licenses/mit/)

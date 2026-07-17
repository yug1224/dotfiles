# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install        # Homebrew インストール・Prezto clone（install.sh）
make mise           # mise bootstrap（packages / dotfiles / tools / bootstrap task）
make node           # pnpm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
make check          # oxfmt check + AI sync 検証（allowlist / wrapper / deny-guard / always-on）+ script 最小テスト + check-bootstrap（macOS）
```

- `make install`（`install.sh`）は初回 seed として Homebrew・Prezto・mise 導入に加え、`mise.toml` がある場合は **`mise bootstrap --yes` まで**実行する（重い・GUI reconcile の可能性あり）。日常の再適用は **`make mise`**。
- パッケージマネージャは **pnpm**（`packageManager` / `pnpm-lock.yaml`）。`npm install` は使わない。
- lefthook pre-commit は oxfmt + secretlint のみ。AI sync は **`make check` / CI** で担保する。
- bootstrap には **mise ≥ 2026.7.7** が必要（ルート `mise.toml` の `min_version`。不足時は `make mise` の gate が `brew upgrade mise`）。
- `install.sh` は `/usr/bin/curl` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make mise` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/ai/docs/RTK.md`](packages/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。
- 依存の所有権（oxfmt の二重管理・Node 正本は [`.node-version`](.node-version)）は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。
- エディタの oxfmt パスは `$HOME/.dotfiles/...`（`make mise` でリポジトリが `~/.dotfiles` に symlink される前提）。
- bootstrap の dry-run: `mise bootstrap -n`。macOS の `make check-bootstrap` は **`[bootstrap.packages]` の `brew:` / `brew-cask:` のみ**不足を検出する（`[tasks.bootstrap]` の cask は対象外。CI は ubuntu のみで no-op）。
- **`make install` / `make mise` の前に、対象 GUI アプリ（Chrome / Slack 等）を終了**すること。既存マシンでは mise が cask を reconcile 再インストールすることがある。
- Tap 由来 formula を brew で触る場合: `brew trust --formula cloudflare/cloudflare/curl dotenvx/brew/dotenvx`

### 設定レイヤ

| 層                   | 正本                                                     | 対象                                                                                                                                       |
| -------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| mise `[dotfiles]`    | ルート [`mise.toml`](mise.toml)                          | zsh / shared / rtk / git（config・ignore）/ pnpm / tig / code（双ターゲット）/ cursor / claude / ssh（config のみ）/ mise（`config.toml`） |
| mise `[tools]`       | [`packages/mise/config.toml`](packages/mise/config.toml) | runtimes（node / pnpm / …）+ CLI（`gh` `jq` `bat` `delta` `difftastic` `fd` `lefthook` `peco` `ripgrep`（バイナリ `rg`）`rtk` `tlrc` 等）  |
| mise `[bootstrap.*]` | ルート [`mise.toml`](mise.toml)                          | formulae + 一部 cask（`brew:` / `brew-cask:`）。pkg/特殊配布 cask・VS Code 拡張・rtmpdump は `[tasks.bootstrap]`                           |

**所有権ルール**

- 設定の正本はルート [`mise.toml`](mise.toml) の `[dotfiles]`。展開は `make mise`（bootstrap の dotfiles フェーズ）。
- `*.local.*` / 秘密ファイルは `[dotfiles]` に取り込まない（`.zshrc.local` / `settings.local.json` / SSH 鍵含む）。
- 通常ファイル（symlink でない）で conflict になる場合は、バックアップのうえ `mise -C . dotfiles apply --force --yes`。

### mise `config.local.toml`（非管理）

- `[tools]` の正本は [`packages/mise/config.toml`](packages/mise/config.toml) → `~/.config/mise/config.toml`（symlink）。
- マシン固有は **`~/.config/mise/config.local.toml`**（[`packages/mise/config.local.toml`](packages/mise/config.local.toml) は `.gitignore` 済み。**コミットしない**）。
- 例（パスは自分の作業ルートに置換）:

```toml
[settings]
trusted_config_paths = ["/PATH/TO/Workspaces"]
```

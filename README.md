# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install        # Homebrew インストール・Prezto clone（install.sh）
make brew           # Brewfile（mise / casks 等）
make node           # npm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
make mise-dotfiles  # [dotfiles] の symlink（zsh / shared / editors / ssh / ~/.config/mise 等）
```

- `make install` だけでは **Brew bundle・node_modules・mise dotfiles は入りません**。上記の順で足してください。
- `[dotfiles]` には **mise ≥ 2026.7.4** が必要（`Brewfile` の `mise` / ルート `mise.toml` の `min_version`）。
- `install.sh` は `curl | bash` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make brew` → `make mise-dotfiles` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/ai/docs/RTK.md`](packages/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。

### 設定レイヤ

| 層                | 正本                                                     | 対象                                                                                                                                       |
| ----------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| mise `[dotfiles]` | ルート [`mise.toml`](mise.toml)                          | zsh / shared / rtk / git（config・ignore）/ pnpm / tig / code（双ターゲット）/ cursor / claude / ssh（config のみ）/ mise（`config.toml`） |
| mise `[tools]`    | [`packages/mise/config.toml`](packages/mise/config.toml) | node / pnpm CLI / npm グローバル等                                                                                                         |
| Homebrew          | [`Brewfile`](Brewfile)                                   | casks / ネイティブ依存 / 残 CLI（`tig`・`rtk` 含む）                                                                                       |

**所有権ルール**

- 設定の正本はルート [`mise.toml`](mise.toml) の `[dotfiles]`。展開は `make mise-dotfiles`。
- `*.local.*` / 秘密ファイルは `[dotfiles]` に取り込まない（`.zshrc.local` / `settings.local.json` / SSH 鍵含む）。
- 通常ファイル（symlink でない）で conflict になる場合は、バックアップのうえ `mise -C . dotfiles apply --force --yes`。

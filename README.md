# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install        # Homebrew インストール・Prezto clone（install.sh）
make brew           # Brewfile（mise / stow / casks 等）
make node           # npm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
make mise-dotfiles  # [dotfiles] の symlink（zsh / shared / editors / ssh / ~/.config/mise 等）
```

- `make install` だけでは **Brew bundle・node_modules・mise dotfiles は入りません**。上記の順で足してください。
- `[dotfiles]` には **mise ≥ 2026.7.4** が必要（`Brewfile` の `mise` / ルート `mise.toml` の `min_version`）。
- `install.sh` は `curl | bash` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make brew` → `make mise-dotfiles` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/shared/ai/docs/RTK.md`](packages/shared/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。

### 設定レイヤ

| 層                | 正本                                                               | 対象                                                                                                                 |
| ----------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| mise `[dotfiles]` | ルート [`mise.toml`](mise.toml)                                    | zsh / shared / rtk / git / pnpm / tig / code（双ターゲット）/ cursor / claude / ssh（config のみ）/ `~/.config/mise` |
| mise `[tools]`    | [`packages/mise/mise/config.toml`](packages/mise/mise/config.toml) | node / pnpm CLI / npm グローバル等                                                                                   |
| Homebrew          | [`Brewfile`](Brewfile)                                             | casks / ネイティブ依存 / 残 CLI（`tig`・`rtk`・移行用 `stow` 含む）                                                  |

**所有権ルール**

- 同一ターゲットを旧 Stow と mise で二重管理しない。既存マシンで Stow から外すときは先に正しい `-t` で `stow -D` してから `make mise-dotfiles`。
- `*.local.*` / 秘密ファイルは `[dotfiles]` に取り込まない（`.zshrc.local` / `settings.local.json` / SSH 鍵含む）。
- 既存マシンで設定を Stow から外す例:

```bash
git pull
make brew
stow -D -v -d ./packages -t ~ tig zsh ssh
stow -D -v -d ./packages -t ~/.config rtk git shared mise
stow -D -v -d ./packages -t ~/Library/Preferences/pnpm pnpm
stow -D -v -d ./packages -t ~/Library/Application\ Support/Code/User code
stow -D -v -d ./packages -t ~/Library/Application\ Support/Cursor/User code
stow -D -v -d ./packages -t ~/.cursor cursor
stow -D -v -d ./packages -t ~/.claude claude
mkdir -p ~/.ssh/00_global ~/.ssh/01_github
make mise-dotfiles
test -f packages/zsh/.zshrc.local && ln -sfn "$(pwd)/packages/zsh/.zshrc.local" ~/.zshrc.local
test -f packages/claude/settings.local.json && ln -sfn "$(pwd)/packages/claude/settings.local.json" ~/.claude/settings.local.json
mise -C . dotfiles status
```

- 通常ファイル（symlink でない）で conflict になる場合は、バックアップのうえ `mise -C . dotfiles apply --force --yes`。

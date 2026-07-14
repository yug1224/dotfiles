# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install        # Homebrew インストール・Prezto clone（install.sh）
make brew           # Brewfile（mise / stow / casks 等）
make node           # npm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
make stow           # Stow 管理の symlink（未移行パッケージ）
make mise-dotfiles  # ~/.dotfiles 安定パス + mise [dotfiles] の symlink
```

- `make install` だけでは **Brew bundle・stow・node_modules・mise dotfiles は入りません**。上記の順で足してください。
- `[dotfiles]` には **mise ≥ 2026.7.4** が必要（`Brewfile` の `mise` / ルート `mise.toml` の `min_version`）。
- `install.sh` は `curl | bash` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make brew` → `make stow` → `make mise-dotfiles` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/shared/ai/docs/RTK.md`](packages/shared/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。

### mise と Stow の境界

| 層                | 正本                                                               | 対象                                                                                   |
| ----------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| mise `[dotfiles]` | ルート [`mise.toml`](mise.toml)                                    | `~/.dotfiles`、`~/.tigrc`、`~/.config/{rtk,git,shared}`、pnpm `rc`、zsh（`.zshrc` 等） |
| mise `[tools]`    | [`packages/mise/mise/config.toml`](packages/mise/mise/config.toml) | node / pnpm CLI / npm グローバル等                                                     |
| Stow              | [`Makefile`](Makefile) の `stow`                                   | mise config / cursor / claude / code / ssh（未移行分）                                 |
| Homebrew          | [`Brewfile`](Brewfile)                                             | casks / ネイティブ依存 / 残 CLI（`tig`・`rtk` バイナリ含む）                           |

**所有権ルール**

- 同一ターゲットを Stow と mise で二重管理しない。移管時は先に正しい `-t` で `stow -D` し、Makefile から外してから `make mise-dotfiles`。
- `*.local.*` / 秘密ファイルは `[dotfiles]` に取り込まない（`.zshrc.local` 含む）。
- 既存マシンで設定を Stow から外す例:

```bash
git pull
make brew
stow -D -v -d ./packages -t ~ tig zsh
stow -D -v -d ./packages -t ~/.config rtk git shared
stow -D -v -d ./packages -t ~/Library/Preferences/pnpm pnpm
make mise-dotfiles
# .zshrc.local は非管理。ソースがある場合は再リンク:
test -f packages/zsh/.zshrc.local && ln -sfn "$(pwd)/packages/zsh/.zshrc.local" ~/.zshrc.local
mise -C . dotfiles status
```

- 通常ファイル（symlink でない）で conflict になる場合は、バックアップのうえ `mise -C . dotfiles apply --force --yes`。

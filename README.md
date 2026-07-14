# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install        # Homebrew インストール・Prezto clone（install.sh）
make brew           # Brewfile（mise / stow / casks 等）
make node           # npm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
make stow           # Stow 管理の symlink（tig 以外）
make mise-dotfiles  # ~/.dotfiles 安定パス + mise [dotfiles] の symlink
```

- `make install` だけでは **Brew bundle・stow・node_modules・mise dotfiles は入りません**。上記の順で足してください。
- `[dotfiles]` には **mise ≥ 2026.7.4** が必要（`Brewfile` の `mise` / ルート `mise.toml` の `min_version`）。
- `install.sh` は `curl | bash` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make brew` → `make stow` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/shared/ai/docs/RTK.md`](packages/shared/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。

### mise と Stow の境界

| 層                | 正本                                                               | 対象                                                            |
| ----------------- | ------------------------------------------------------------------ | --------------------------------------------------------------- |
| mise `[dotfiles]` | ルート [`mise.toml`](mise.toml)                                    | `~/.dotfiles`、パイロットは `~/.tigrc`                          |
| mise `[tools]`    | [`packages/mise/mise/config.toml`](packages/mise/mise/config.toml) | node / pnpm / npm CLI 等                                        |
| Stow              | [`Makefile`](Makefile) の `stow`                                   | zsh / git / mise config / cursor / claude / code 等（未移行分） |
| Homebrew          | [`Brewfile`](Brewfile)                                             | casks / ネイティブ依存 / 残 CLI（`tig` バイナリ含む）           |

**所有権ルール**

- 同一ターゲットを Stow と mise で二重管理しない。移管時は先に `stow -D` し、Makefile から外してから `make mise-dotfiles`。
- `*.local.*` / 秘密ファイルは `[dotfiles]` に取り込まない。
- 既存マシンで tig を Stow から外す例:

```bash
git pull
make brew                              # mise ≥ 2026.7.4 を確実に
stow -D -v -d ./packages -t ~ tig      # 先に Stow 側の所有を外す
make mise-dotfiles
mise -C . dotfiles status
```

- `~/.tigrc` が通常ファイル（symlink でない）で conflict になる場合は、バックアップのうえ `mise -C . dotfiles apply --force --yes`。

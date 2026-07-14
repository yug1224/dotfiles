# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install        # Homebrew インストール・Prezto clone（install.sh）
make brew           # Brewfile（mise / casks / ネイティブ依存等）
make mise-dotfiles  # [dotfiles] の symlink（zsh / shared / editors / ssh / ~/.config/mise 等）
make mise-tools     # [tools]（node / pnpm / gh / jq / rtk / fd / ripgrep 等）— mise-dotfiles の後
make node           # npm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
```

- `make install` だけでは **Brew bundle・node_modules・mise dotfiles・tools は入りません**。上記の順で足してください。
- `[dotfiles]` には **mise ≥ 2026.7.4** が必要（`Brewfile` の `mise` / ルート `mise.toml` の `min_version`）。
- `install.sh` は `curl | bash` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make brew` → `make mise-dotfiles` → `make mise-tools` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/ai/docs/RTK.md`](packages/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。

### 設定レイヤ

| 層                | 正本                                                     | 対象                                                                                                                                       |
| ----------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| mise `[dotfiles]` | ルート [`mise.toml`](mise.toml)                          | zsh / shared / rtk / git（config・ignore）/ pnpm / tig / code（双ターゲット）/ cursor / claude / ssh（config のみ）/ mise（`config.toml`） |
| mise `[tools]`    | [`packages/mise/config.toml`](packages/mise/config.toml) | runtimes（node / pnpm / …）+ CLI（`gh` `jq` `bat` `delta` `difftastic` `fd` `lefthook` `peco` `ripgrep`（バイナリ `rg`）`rtk` `tlrc` 等）  |
| Homebrew          | [`Brewfile`](Brewfile)                                   | casks / ネイティブ・GNU 依存 / registry 弱・なし CLI（`tig`・`tree`・`eza` 等。`eza` は aqua なし）/ **`mise` 本体**                       |

**所有権ルール**

- 設定の正本はルート [`mise.toml`](mise.toml) の `[dotfiles]`。展開は `make mise-dotfiles`。
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

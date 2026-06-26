# dotfiles

## Usage

初回セットアップ（例）:

```bash
git clone https://github.com/yug1224/dotfiles.git
cd dotfiles
make install   # Homebrew インストール・Prezto clone（install.sh）
make brew      # Brewfile のパッケージ
make node      # npm install（lefthook の pre-commit で oxfmt / secretlint に必要。TypeScript はエディタの言語サービス用）
make stow      # 各種設定のシンボリックリンク
```

- `make install` だけでは **Brew bundle・stow・node_modules は入りません**。上記の順で足してください。
- `install.sh` は `curl | bash` で Homebrew を入れます。Intel Mac では `/opt/homebrew` ではなく `/usr/local` 側になる場合があります。
- AI 設定（Cursor / Claude Code）は **RTK 前提**。`make brew` → `make stow` の後、`rtk --version && rtk gain` で smoke test すること。詳細は [`packages/shared/shared/ai/docs/RTK.md`](packages/shared/shared/ai/docs/RTK.md)。
- Cursor / AI 用のルールは [`packages/cursor/README.md`](packages/cursor/README.md) を参照。
- oxfmt の構成は [`packages/oxfmt/README.md`](packages/oxfmt/README.md) を参照。

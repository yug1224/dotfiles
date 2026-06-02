# ~/.claude

Claude Code の設定ファイル群。`stow -t ~/.claude claude` で `~/.claude/` にデプロイされる。

## 方針

- 共有素材（agents 本文、rules、hooks など）は `packages/shared/shared/ai/` に置き、`make stow` で `~/.config/shared/ai/` に展開される。ラッパーからは `@~/.config/shared/ai/...` 絶対パスで取り込む（例: `@~/.config/shared/ai/rules/...`）。
- Claude Code 固有の設定（`settings.json` の hooks / permissions、`CLAUDE.md`）はこのパッケージに直接記述する

## ディレクトリ構成（順次拡充）

```
packages/claude/
├── AGENTS.md → ../shared/shared/ai/AGENTS.md   # 共通規約（symlink）
├── agents/                       # Claude frontmatter ラッパー
├── commands/                     # スラッシュコマンドラッパー（本文は shared）
├── rules/                        # ルールラッパー（blog/, conventions/, visual/ 等）
├── hooks/                        # Claude 用 adapter（共有 guard は ~/.config/shared/ai/hooks/）
├── settings.json                 # hooks / permissions / model
├── CLAUDE.md                     # ルール集約（@RTK.md 参照）
├── RTK.md                        # RTK 利用ガイド（shared 正本のラッパー）
└── README.md
```

コマンド・ルールの一覧とカテゴリは [`packages/cursor/README.md`](../cursor/README.md) の commands / rules 節を参照（Cursor と Claude でラッパーは対応する）。

Claude Code の Agent Skills（`~/.claude/skills/` に `<name>/SKILL.md` を置く形式）は本 dotfiles の `packages/claude` には**現状同梱していない**。利用する場合はローカルで `~/.claude/skills/` に追加するか、必要なら `packages/claude/skills/` を新設して `make stow` で配布する。

## `@`-import の基準（`make stow` 後）

| ラッパー（リポジトリ）                | 共有本文への import 例                    |
| ------------------------------------- | ----------------------------------------- |
| `packages/claude/commands/*.md`       | `@~/.config/shared/ai/commands/...`       |
| `packages/claude/agents/*.md`         | `@~/.config/shared/ai/agents/...`         |
| `packages/claude/rules/<subdir>/*.md` | `@~/.config/shared/ai/rules/<subdir>/...` |
| `packages/claude/CLAUDE.md`           | `@~/.config/shared/ai/AGENTS.md`          |

詳細とフックの委譲先は [`packages/shared/shared/ai/README.md`](../shared/shared/ai/README.md) を参照。命名・`.local.md` 上書きは [CONVENTIONS.md](../shared/shared/ai/CONVENTIONS.md)。運用メモは `shared/ai/README.local.md`（gitignore）。

## ローカル拡張（`*.local.*`）

[`packages/cursor`](../cursor/README.md) と同様、Git に載せたくない端末専用の定義は **`*.local.md` / `*.local.*`** とする（本パッケージの [`.gitignore`](.gitignore) で除外済み）。

```
~/.claude/
├── commands/
│   ├── magi.md                 ← stow（Git 管理）
│   └── my-team.local.md        ← ローカル専用コマンド
├── rules/
│   └── conventions/
│       └── my-policy.local.md  ← ローカル専用ルール（Claude は .md ラッパーでも可）
~/.config/shared/ai/rules/.../
    └── *.local.md              ← 共有ルール本文から参照する補助（stow で全ツールから見える）
```

- **共有ルールから参照する補助ファイル**（例: `pr-review-rule.local.md`）は **`~/.config/shared/ai/rules/<subdir>/`**（リポジトリでは `packages/shared/shared/ai/rules/<subdir>/`）に置く。`make stow` で `~/.config/shared/ai/` に展開され、Cursor / Claude のどちらからでも同じパスで参照できる。
- **`~/.claude/commands/` 直下の `*.local.md`** は Claude 専用のスラッシュコマンドとして追加できる。Git 管理のコマンドと**同名**にしない（挙動が不定になりうる）。
- Cursor 専用の `.mdc` やフックの詳細は [`packages/cursor/README.md`](../cursor/README.md) の「ローカル拡張」を参照。

## settings.json の hooks（PreToolUse）

`stow` で `~/.claude/settings.json` にデプロイされる。Bash ツール実行前に **2 段**の `PreToolUse` フックが順に走る（guard → RTK）。

| 順序 | コマンド                             | 説明                                                                                         |
| ---- | ------------------------------------ | -------------------------------------------------------------------------------------------- |
| 1    | `$HOME/.claude/hooks/guard-shell.sh` | 破壊的 git / gh / pnpm の deny・ask（共有判定は `~/.config/shared/ai/hooks/guard-shell.sh`） |
| 2    | `rtk hook claude`                    | Shell コマンドを `rtk` 経由へ書き換え（トークン削減。[RTK](https://github.com/rtk-ai/rtk)）  |

**前提**: Homebrew の `rtk`（PATH）、guard 用の `jq`（Brewfile 既存）。`rtk hook claude` は `packages/claude/hooks/` 配下のスクリプトではなく RTK バイナリを直接呼ぶ。

初回セットアップは **`rtk init -g --no-patch`**（設定 JSON はパッチしない）。本リポジトリでは `settings.json` と [`RTK.md`](RTK.md)（shared 正本のラッパー）を正本とし、`CLAUDE.md` の `@RTK.md` で参照する。RTK アップデートで `RTK.md` の文言が変わる場合は `rtk init -g --no-patch` で生成物を確認し、shared 正本を手動同期すること。

**インストール確認**: `rtk --version && rtk gain`（詳細は [CONVENTIONS.md](../shared/shared/ai/CONVENTIONS.md) の RTK 節）。

guard は `rtk ` プレフィックスを strip して分類するため、`rtk git push` でも deny が効く。詳細は [`packages/cursor/README.md`](../cursor/README.md) の guard-shell 判定表を参照。

## 既存設定との衝突

`~/.claude/settings.json` または `~/.claude/RTK.md` が **symlink ではない通常ファイル**として存在する場合（`rtk init -g` 等で生成された場合）、`make stow` が失敗する。正本は本リポジトリの [`settings.json`](settings.json) / [`RTK.md`](RTK.md)（shared 正本のラッパー）である。

```bash
# 内容確認（settings.json が repo と同一ならバックアップして削除してよい）
diff ~/.claude/settings.json packages/claude/settings.json
diff ~/.claude/RTK.md packages/claude/RTK.md
mv -f ~/.claude/settings.json ~/.claude/settings.json.bak
mv -f ~/.claude/RTK.md ~/.claude/RTK.md.bak
make stow
```

`rtk init` で設定をパッチしないよう、初回確認は **`rtk init -g --no-patch`** を使う（[CONVENTIONS.md](../shared/shared/ai/CONVENTIONS.md) の RTK 節）。

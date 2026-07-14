# ~/.claude

Claude Code の設定ファイル群。`stow -t ~/.claude claude` で `~/.claude/` にデプロイされる。

## 方針

- 共有素材（agents 本文、rules、hooks など）は `packages/shared/shared/ai/` に置き、`make mise-dotfiles` で `~/.config/shared/ai/` に展開される。ラッパーからは `@~/.config/shared/ai/...` 絶対パスで取り込む（例: `@~/.config/shared/ai/rules/...`）。
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

コマンド・ルールの一覧とカテゴリは [`packages/cursor/README.md`](../cursor/README.md) の commands / rules 節を参照（Cursor と Claude でラッパーは対応する）。コマンド basename の旧→新対応は [`packages/shared/shared/ai/docs/LOCAL-SETUP.md`](../shared/shared/ai/docs/LOCAL-SETUP.md) を参照。

Claude Code の Agent Skills（`~/.claude/skills/` に `<name>/SKILL.md` を置く形式）は本 dotfiles の `packages/claude` には**現状同梱していない**。利用する場合はローカルで `~/.claude/skills/` に追加するか、必要なら `packages/claude/skills/` を新設して `make stow` で配布する。

## `@`-import の基準（`make mise-dotfiles` 後）

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
    └── *.local.md              ← 共有ルール本文から参照する補助（mise [dotfiles] で全ツールから見える）
```

- **共有ルールから参照する補助ファイル**（例: `pr-review-rule.local.md`）は **`~/.config/shared/ai/rules/<subdir>/`**（リポジトリでは `packages/shared/shared/ai/rules/<subdir>/`）に置く。`make mise-dotfiles` で `~/.config/shared/ai/` に展開され、Cursor / Claude のどちらからでも同じパスで参照できる。
- **`~/.claude/commands/` 直下の `*.local.md`** は Claude 専用のスラッシュコマンドとして追加できる。Git 管理のコマンドと**同名**にしない（挙動が不定になりうる）。
- Cursor 専用の `.mdc` やフックの詳細は [`packages/cursor/README.md`](../cursor/README.md) の「ローカル拡張」を参照。

## settings.json の hooks（PreToolUse）

`stow` で `~/.claude/settings.json` にデプロイされる。Bash 実行前に **2 段**の `PreToolUse` が順に走る（guard → RTK）。

| 順序 | コマンド                             | matcher |
| ---- | ------------------------------------ | ------- |
| 1    | `$HOME/.claude/hooks/guard-shell.sh` | `Bash`  |
| 2    | `rtk hook claude`                    | `Bash`  |

RTK 前提・セットアップ・stow 衝突・guard 判定表: [`packages/shared/shared/ai/docs/RTK.md`](../shared/shared/ai/docs/RTK.md)。`CLAUDE.md` は [`RTK.md`](RTK.md)（shared 正本のラッパー）を常時 import する。

## CodeGraph

セマンティックコードインテリジェンス。セットアップ・MCP 手動マージ・プロジェクト `init`: [`packages/shared/shared/ai/docs/CODEGRAPH.md`](../shared/shared/ai/docs/CODEGRAPH.md)。`CLAUDE.md` は `codegraph-rule` を import する。`~/.claude.json` への MCP マージは手動（dotfiles 未管理）。

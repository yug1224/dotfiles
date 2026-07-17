# ~/.claude

Claude Code の設定ファイル群。`make mise`（ルート `mise.toml` の `[dotfiles]`）で `~/.claude/` にデプロイされる。

## 方針

- 共有素材（agents 本文、rules、hooks など）は `packages/shared/ai/` に置き、`make mise` で `~/.config/shared/ai/` に展開される。ラッパーからは `@~/.config/shared/ai/...` 絶対パスで取り込む（例: `@~/.config/shared/ai/rules/...`）。
- Claude Code 固有の設定（`settings.json` の hooks / permissions、`CLAUDE.md`）はこのパッケージに直接記述する

## ディレクトリ構成（順次拡充）

```
packages/claude/
├── AGENTS.md → ../shared/ai/AGENTS.md   # 共通規約（symlink）
├── agents/                       # Claude frontmatter ラッパー
├── commands/                     # スラッシュコマンドラッパー（本文は shared）
├── rules/                        # ルールラッパー（blog/, writing/, conventions/, visual/ 等）
├── hooks/                        # Claude 用 adapter（共有 guard は ~/.config/shared/ai/hooks/）
├── settings.json                 # hooks / permissions / model
├── CLAUDE.md                     # ルール集約（@RTK.md 参照）
├── RTK.md                        # RTK 利用ガイド（shared 正本のラッパー）
└── README.md
```

コマンド・ルールの一覧とカテゴリは [`packages/cursor/README.md`](../cursor/README.md) の commands / rules 節を参照（Cursor と Claude でラッパーは対応する）。コマンド basename の旧→新対応は [`packages/shared/ai/docs/LOCAL-SETUP.md`](../shared/ai/docs/LOCAL-SETUP.md) を参照。

### writing/（日本語文章規範）

`packages/claude/rules/writing/` に次を置く（`make scaffold-wrappers` で生成）:

| ラッパー                           | 共有本文                                                              |
| ---------------------------------- | --------------------------------------------------------------------- |
| `japanese-tech-writing-rule.md`    | `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md`    |
| `cognitive-rhythm-writing-rule.md` | `@~/.config/shared/ai/rules/writing/cognitive-rhythm-writing-rule.md` |

- **Tier**: B（コマンド経由 / agent-requestable）。CLAUDE.md Tier A には載せない
- **用途**: 日本語出力の基底。Git 管理コマンドからの必須 Read は `plan-blog` / `suggest-development-log` / `suggest-pr-description`（`review-blog` は writing-style 経由）。採用メッセージ系（`.local`）は必須 Read する場合も適用は `tech-doc-lite`
- **優先**: blog では `writing-style-rule` の Override が優先（JTW は `blog-base`）。開発ログ／PR 説明／採用メッセージは `tech-doc-lite`。CRW は体験記・読み物時のみ opt-in
- **出典**: [`packages/shared/ai/README.md`](../shared/ai/README.md)「出典・蒸留」（JTW: Unlicense / CRW: 原典に表記なし）

Claude Code の Agent Skills（`~/.claude/skills/` に `<name>/SKILL.md` を置く形式）は本 dotfiles の `packages/claude` には**現状同梱していない**。利用する場合はローカルで `~/.claude/skills/` に追加するか、必要なら `packages/claude/skills/` を新設して `make mise` で配布する。

## `@`-import の基準（`make mise` 後）

| ラッパー（リポジトリ）                | 共有本文への import 例                    |
| ------------------------------------- | ----------------------------------------- |
| `packages/claude/commands/*.md`       | `@~/.config/shared/ai/commands/...`       |
| `packages/claude/agents/*.md`         | `@~/.config/shared/ai/agents/...`         |
| `packages/claude/rules/<subdir>/*.md` | `@~/.config/shared/ai/rules/<subdir>/...` |
| `packages/claude/CLAUDE.md`           | `@~/.config/shared/ai/AGENTS.md`          |

詳細とフックの委譲先は [`packages/shared/ai/README.md`](../shared/ai/README.md) を参照。命名・`.local.md` 上書きは [CONVENTIONS.md](../shared/ai/CONVENTIONS.md)。運用メモは `shared/ai/README.local.md`（gitignore）。

## ローカル拡張（`*.local.*`）

[`packages/cursor`](../cursor/README.md) と同様、Git に載せたくない端末専用の定義は **`*.local.md` / `*.local.*`** とする（本パッケージの [`.gitignore`](.gitignore) で除外済み）。

```
~/.claude/
├── commands/
│   ├── magi.md                 ← mise [dotfiles]（Git 管理）
│   └── my-team.local.md        ← ローカル専用コマンド
├── rules/
│   └── conventions/
│       └── my-policy.local.md  ← ローカル専用ルール（Claude は .md ラッパーでも可）
~/.config/shared/ai/rules/.../
    └── *.local.md              ← 共有ルール本文から参照する補助（mise [dotfiles] で全ツールから見える）
```

- **共有ルールから参照する補助ファイル**（例: `pr-review-rule.local.md`）は **`~/.config/shared/ai/rules/<subdir>/`**（リポジトリでは `packages/shared/ai/rules/<subdir>/`）に置く。`make mise` で `~/.config/shared/ai/` に展開され、Cursor / Claude のどちらからでも同じパスで参照できる。
- **`~/.claude/commands/` 直下の `*.local.md`** は Claude 専用のスラッシュコマンドとして追加できる。Git 管理のコマンドと**同名**にしない（挙動が不定になりうる）。
- Cursor 専用の `.mdc` やフックの詳細は [`packages/cursor/README.md`](../cursor/README.md) の「ローカル拡張」を参照。

## settings.json の hooks（PreToolUse）

`make mise` で `~/.claude/settings.json` にデプロイされる。Bash 実行前に **2 段**の `PreToolUse` が順に走る（guard → RTK）。

| 順序 | コマンド                             | matcher |
| ---- | ------------------------------------ | ------- |
| 1    | `$HOME/.claude/hooks/guard-shell.sh` | `Bash`  |
| 2    | `$HOME/.claude/hooks/rtk-hook.sh`    | `Bash`  |

RTK 前提・セットアップ・競合対処・guard 判定表: [`packages/shared/ai/docs/RTK.md`](../shared/ai/docs/RTK.md)。`CLAUDE.md` は [`RTK.md`](RTK.md)（shared 正本のラッパー）を常時 import する。

## CodeGraph

セマンティックコードインテリジェンス。セットアップ・MCP 手動マージ・プロジェクト `init`: [`packages/shared/ai/docs/CODEGRAPH.md`](../shared/ai/docs/CODEGRAPH.md)。`CLAUDE.md` は `codegraph-rule` を import する。`~/.claude.json` への MCP マージは手動（dotfiles 未管理）。

# `packages/shared/shared/ai/`（クロスツール共有素材）

Cursor / Claude Code / Gemini CLI が共通で参照する素材の原本。`make stow` で `~/.config/shared/ai/` に展開される（`packages/shared` パッケージが `~/.config` に stow される）。

## ディレクトリ構成

```
packages/shared/
└── shared/
    └── ai/
        ├── AGENTS.md       # 3 ツール共通の規約ドキュメント
        ├── agents/         # frontmatter なしの agent 本文
        ├── commands/       # frontmatter なしの command 本文
        ├── rules/          # frontmatter なしの rule 本文
        └── hooks/          # 共有シェルスクリプト（guard-shell 本体）
```

各ツールの `packages/<tool>/` 配下から、`@`-import（**`@~/.config/shared/ai/` 絶対パス**）で取り込む。

## `@`-import パス（`@~/.config/shared/ai/` 絶対パス）

`stow` で `~/.config/shared/ai/` にデプロイされた共有本文を、`@~/.config/shared/ai/...` で参照する。Cursor は symlink の配置場所からの相対パスでは共有本文に届かないため、この絶対パス形式を使う。

| ラッパー配置（リポジトリ）             | 共有本文への import 例                    |
| -------------------------------------- | ----------------------------------------- |
| `packages/cursor/commands/*.md`        | `@~/.config/shared/ai/commands/...`       |
| `packages/cursor/agents/*.md`          | `@~/.config/shared/ai/agents/...`         |
| `packages/cursor/rules/<subdir>/*.mdc` | `@~/.config/shared/ai/rules/<subdir>/...` |
| `packages/claude/commands/*.md`        | `@~/.config/shared/ai/commands/...`       |
| `packages/claude/agents/*.md`          | `@~/.config/shared/ai/agents/...`         |
| `packages/claude/rules/<subdir>/*.md`  | `@~/.config/shared/ai/rules/<subdir>/...` |
| `packages/claude/CLAUDE.md`            | `@~/.config/shared/ai/AGENTS.md`          |

**フック**: 判定ロジックの正本は [`shared/ai/hooks/guard-shell.sh`](hooks/guard-shell.sh) のみ（stdin の JSON を解釈し `permission` を返す）。`make stow` で `~/.config/shared/ai/hooks/` に展開される。Cursor は [`packages/cursor/hooks/guard-shell.sh`](../../cursor/hooks/guard-shell.sh) が `$HOME/.config/shared/ai/hooks/guard-shell.sh` へ `exec` する薄ラッパー。Claude は [`packages/claude/hooks/guard-shell.sh`](../../claude/hooks/guard-shell.sh)（adapter）が同じ JSON 形を `$HOME/.config/shared/ai/hooks/guard-shell.sh` にパイプする。

## ローカル専用ファイル（`*.local.*`）

- **ツール専用**: `~/.cursor/commands/*.local.md` 等は [`packages/cursor/README.md`](../../cursor/README.md) の「ローカル拡張」を参照（`.gitignore` で `*.local.*` を除外）。
- **共有ツリー側**: 共有ルールから参照する補助（例: `pr-review-rule.local.md`）は **`shared/ai/rules/` 配下の同じサブディレクトリ**に置く。`make stow` で `~/.config/shared/ai/rules/` に展開され、Cursor / Claude のどちらからでも同じ絶対パスで参照可能。

## 編集ルール

- ここに置くファイルは **frontmatter を含めない**（ツール非依存の本文のみ）
- ツール固有の挙動（globs / model / readonly / tools / hook 入出力 JSON など）は呼び出し側（各 `packages/<tool>/`）で表現する

## ルールファイルの所在（Cursor / Claude 共通）

共有の規約本文はすべてこのツリー内の `rules/**/*.md` にある。`make stow` により `~/.config/shared/ai/rules/` へ展開される。

**Read ツールで本文を開くとき**は、次のいずれかを使う（実在パスを指す）。

- この dotfiles リポジトリをワークスペースにしている場合: `packages/shared/shared/ai/rules/.../*.md`
- デプロイ済みの場合: `~/.config/shared/ai/rules/.../*.md`

Cursor の「ルール」として frontmatter（`description` / `globs` / `alwaysApply` 等）付きで読み込まれるファイルは **`~/.cursor/rules/**/_.mdc`** にあり、本文は `@~/.config/shared/ai/rules/.../_.md` と同一である。

Claude Code の `~/.claude/rules/**/*.md` はラッパーであり、中身は同じく `@~/.config/shared/ai/rules/.../*.md` を `@`-import する。

### 新規ルールやチェックリストを追加するとき

1. 本文（frontmatter なし）を `packages/shared/shared/ai/rules/<subdir>/` に `.md` で追加する。
2. Cursor 向けに `packages/cursor/rules/<subdir>/<名前>.mdc` を置き、frontmatter のあとに `@~/.config/shared/ai/rules/<subdir>/<名前>.md` で本文を取り込む（既存の `.mdc` をコピーしてパスだけ差し替えるとよい）。
3. Claude 向けに `packages/claude/rules/<subdir>/<名前>.md` を置き、先頭行で `@~/.config/shared/ai/rules/<subdir>/<名前>.md` とする。
4. コマンドやエージェントの説明文では、`packages/shared/shared/ai/rules/...` とデプロイ後の `~/.config/shared/ai/` を併記する。

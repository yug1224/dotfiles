# `packages/shared/ai/`（クロスツール共有素材）

Cursor / Claude Code が共通で参照する素材の原本（Gemini CLI 用ホストパッケージ `packages/gemini` は **未実装**）。`make mise-dotfiles` で `~/.config/shared/ai/` に展開される（ルート `mise.toml` の `[dotfiles]`）。

**RTK 前提**: Shell トークン削減と hook 連携は [docs/RTK.md](./docs/RTK.md) が正本。セットアップ順・hook 配線・競合の対処はそちらを参照。

**CodeGraph**: セマンティックコードインテリジェンスは [docs/CODEGRAPH.md](./docs/CODEGRAPH.md) が正本。MCP 手動マージ・プロジェクト `init` 手順はそちらを参照。

**読む順序**: [docs/BOUNDARY.md](./docs/BOUNDARY.md)（公開境界）→ [docs/LOCAL-SETUP.md](./docs/LOCAL-SETUP.md)（`.local.md`）→ [docs/RTK.md](./docs/RTK.md)（前提）→ [CONVENTIONS.md](./CONVENTIONS.md)（命名）→ [AGENTS.md](./AGENTS.md)（allowlist 同期）

## ルール taxonomy

| 種別              | 配置                                                                  | 用途                                                      |
| ----------------- | --------------------------------------------------------------------- | --------------------------------------------------------- |
| Convention        | `rules/conventions/`                                                  | 行動規範（レビュー、CodeGraph、自己申告、チケット取得）   |
| Checklist         | `rules/checklists/`                                                   | PASS/FAIL 列挙                                            |
| Blog              | `rules/blog/`                                                         | 執筆・公開（`publish-checklist` / `blog-review-rule` 等） |
| Writing           | `rules/writing/`                                                      | 媒体非依存の日本語文章規範（JTW / CRW）                   |
| Meta              | `rules/meta/`                                                         | dotfiles AI 設定変更（3 ラッパー、`alwaysApply: false`）  |
| Domain-only local | `rules/<domain>/*.local.md`                                           | ドメイン固有・自社固有（**Git 管理外**）                  |
| Local registry    | `~/.config/shared/ai/rules/conventions/pr-feedback-registry.local.md` | 再発防止 FB 全系列（Git 外）                              |
| Command-only ref  | 例: `output-verification-rule.md`                                     | ラッパーなし、cmd から直接 `@`                            |
| Local             | `~/.config/shared/ai/**/*.local.md`                                   | プロジェクト固有（Git 管理外。`*.local.*` gitignore）     |

公開境界: [docs/BOUNDARY.md](./docs/BOUNDARY.md)

## 出典・蒸留

外部ソースを蒸留した shared ルールの一覧。手順の正本は [CONVENTIONS.md](./CONVENTIONS.md)「外部ソースの蒸留」。

| ファイル                                         | 原典                                                                                                                                                      | ライセンス     | 扱い         |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ |
| `rules/blog/blog-review-rule.md`                 | [nwiizo gist](https://gist.github.com/nwiizo/c75043438866100452fd249e536341d4)（元: [はてな](https://syu-m-5151.hatenablog.com/entry/2025/05/19/100659)） | 原典に表記なし | 蒸留・再構成 |
| `rules/writing/japanese-tech-writing-rule.md`    | [k16shikano gist](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d)                                                                    | Unlicense      | 蒸留・再構成 |
| `rules/writing/cognitive-rhythm-writing-rule.md` | [k16shikano gist](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432)                                                                    | 原典に表記なし | 蒸留・再構成 |

`rules/blog/writing-style-rule.md` は自ブログ過去記事からの独自抽出であり、外部蒸留ではない。

フィードバック運用: [docs/PR-FEEDBACK-PLAYBOOK.md](./docs/PR-FEEDBACK-PLAYBOOK.md)（log / index は `docs/feedback-*.local.md`）

- 命名・配置: [CONVENTIONS.md](./CONVENTIONS.md)
- ローカル上書き（`.local.md`）: [docs/LOCAL-SETUP.md](./docs/LOCAL-SETUP.md)。端末固有の手順は **`README.local.md`**（`*.local.*` で gitignore。各自作成・private バックアップ）

## ディレクトリ構成

```
packages/shared/
└── ai/
    ├── AGENTS.md       # 3 ツール共通の規約ドキュメント
    ├── docs/           # クロスツールドキュメント（RTK 等）
    ├── agents/         # frontmatter なしの agent 本文
    ├── commands/       # frontmatter なしの command 本文
    ├── rules/          # frontmatter なしの rule 本文
    └── hooks/          # 共有シェルスクリプト（guard-shell 本体）
```

各ツールの `packages/<tool>/` 配下から、`@`-import（**`@~/.config/shared/ai/` 絶対パス**）で取り込む。

## `@`-import パス（`@~/.config/shared/ai/` 絶対パス）

`make mise-dotfiles` で `~/.config/shared/ai/` にデプロイされた共有本文を、`@~/.config/shared/ai/...` で参照する。Cursor は symlink の配置場所からの相対パスでは共有本文に届かないため、この絶対パス形式を使う。

| ラッパー配置（リポジトリ）             | 共有本文への import 例                    |
| -------------------------------------- | ----------------------------------------- |
| `packages/cursor/commands/*.md`        | `@~/.config/shared/ai/commands/...`       |
| `packages/cursor/agents/*.md`          | `@~/.config/shared/ai/agents/...`         |
| `packages/cursor/rules/<subdir>/*.mdc` | `@~/.config/shared/ai/rules/<subdir>/...` |
| `packages/claude/commands/*.md`        | `@~/.config/shared/ai/commands/...`       |
| `packages/claude/agents/*.md`          | `@~/.config/shared/ai/agents/...`         |
| `packages/claude/rules/<subdir>/*.md`  | `@~/.config/shared/ai/rules/<subdir>/...` |
| `packages/claude/CLAUDE.md`            | `@~/.config/shared/ai/AGENTS.md`          |

**フック**: guard 判定の正本は [`hooks/guard-shell.sh`](hooks/guard-shell.sh)。Cursor / Claude は各パッケージの薄ラッパー経由で共有本体を呼ぶ。RTK hook は guard の**後**に実行される。3 層構成（guard / RTK / allowlist）の詳細は [docs/RTK.md](./docs/RTK.md)。guard 判定の代表ケースは [`guard-shell.test.sh`](hooks/guard-shell.test.sh)、詳細表は [`packages/cursor/README.md`](../../cursor/README.md)。Allowlist 同期は [AGENTS.md](./AGENTS.md)。

## ローカル専用ファイル（`*.local.*`）

- **ツール専用**: `packages/cursor/` / `packages/claude/` の `*.local.*` も同様（`.gitignore` で除外）。運用メモは `README.local.md`。
- **共有本文**: 汎用 `.md`（Git）と同名の **`.local.md`（gitignore）** を同じディレクトリに置く。Git 側のルール・コマンドは「存在すれば Read」と記載し、無くても動作する。
- 参照パス: `@~/.config/shared/ai/...`（`make mise-dotfiles` 後）

## 編集ルール

- ここに置くファイルは **frontmatter を含めない**（ツール非依存の本文のみ）
- ツール固有の挙動（globs / model / readonly / tools / hook 入出力 JSON など）は呼び出し側（各 `packages/<tool>/`）で表現する

## ルールファイルの所在（Cursor / Claude 共通）

共有の規約本文はすべてこのツリー内の `rules/**/*.md` にある。`make mise-dotfiles` により `~/.config/shared/ai/rules/` へ展開される。

**Read ツールで本文を開くとき**は、次のいずれかを使う（実在パスを指す）。

- この dotfiles リポジトリをワークスペースにしている場合: `packages/shared/ai/rules/.../*.md`
- デプロイ済みの場合: `~/.config/shared/ai/rules/.../*.md`

Cursor の「ルール」として frontmatter（`description` / `globs` / `alwaysApply` 等）付きで読み込まれるファイルは **`~/.cursor/rules/**/<name>.mdc`** にあり、本文は `@~/.config/shared/ai/rules/.../<name>.md` と同一である。

Claude Code の `~/.claude/rules/**/*.md` はラッパーであり、中身は同じく `@~/.config/shared/ai/rules/.../*.md` を `@`-import する。

### 新規ルールやチェックリストを追加するとき

1. 本文（frontmatter なし）を `packages/shared/ai/rules/<subdir>/` に `.md` で追加する。1 行目に `応答の冒頭に「✅️: <rule-id>」と出力する。` を記載する。
2. Cursor 向けに `packages/cursor/rules/<subdir>/<名前>.mdc` を置き、frontmatter のあとに `@~/.config/shared/ai/rules/<subdir>/<名前>.md` で本文を取り込む（既存の `.mdc` をコピーしてパスだけ差し替えるとよい）。**`alwaysApply: false` をデフォルト**（例外: token-optimization のみ true）。
3. Claude 向けに `packages/claude/rules/<subdir>/<名前>.md` を置き、先頭行で `@~/.config/shared/ai/rules/<subdir>/<名前>.md` とする。
4. コマンドやエージェントの説明文では、`packages/shared/ai/rules/...` とデプロイ後の `~/.config/shared/ai/` を併記する。
5. dotfiles PR 前: `rules/meta/wrapper-parity-checklist.md` を確認。

**Registry / Meta**: registry は `pr-feedback-registry.local.md` のみ（ラッパー不要）。Meta は `rules/meta/` + Cursor/Claude ラッパー。

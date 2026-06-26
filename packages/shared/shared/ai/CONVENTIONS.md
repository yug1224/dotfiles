# AI 素材の命名・配置規約

正本は `packages/shared/shared/ai/`。各ツールは `packages/cursor/` / `packages/claude/` から `@~/.config/shared/ai/...` で取り込む。

## 共通

| 項目                   | 規則                                                 |
| ---------------------- | ---------------------------------------------------- |
| 文字                   | kebab-case（小文字・ハイフン）                       |
| shared 本文            | `.md` のみ（frontmatter なし）                       |
| ローカル上書き         | `<basename>.local.md`（同一ディレクトリ、gitignore） |
| 本文・Steps の参照     | `@~/.config/shared/ai/<type>/<subdir>/<file>.md`     |
| Git 本文に書かないもの | 会社名・製品名・自社固有ワークスペースパス           |

## 種別ごとの basename

| 種別           | パターン                 | 配置                                                        |
| -------------- | ------------------------ | ----------------------------------------------------------- |
| ルール         | `<topic>-rule.md`        | `rules/<domain>/`                                           |
| チェックリスト | `<topic>-checklist.md`   | 原則 `rules/checklists/`（ブログ公開前は `rules/blog/` 可） |
| コマンド       | 下記「コマンド命名」参照 | `commands/`                                                 |
| エージェント   | `<name>.md`              | `agents/`                                                   |

### コマンド命名

新規は **`<verb>-<noun>.md`**（例: `suggest-plan.md`, `fix-issue.md`）。既存は次の **安定した系列** を維持する（スラッシュコマンド名＝basename のため、安易なリネームは避ける）。

| 系列         | パターン            | 例                                                   |
| ------------ | ------------------- | ---------------------------------------------------- |
| 提案系       | `suggest-<noun>.md` | `suggest-plan`, `suggest-pr-description`             |
| レビュー系   | `<scope>-review.md` | `diff-review`, `pr-review`, `magi-pr-review`         |
| ブログ系     | `blog-<noun>.md`    | `blog-plan`, `blog-review`                           |
| その他固有名 | 単一トピック        | `magi`, `apply-coding-rule`, `graphic-record-prompt` |

### 自己申告（`Applied:`）の rule-id

- **ルール / チェックリスト**: 共有本文 1 行目に `応答の冒頭に「Applied: <rule-id>」と出力する。` を記載。`<rule-id>` はファイル名から拡張子（`.md`）を除いた文字列（例: `writing-style-rule.md` → `writing-style-rule`）。**`-rule` を二重に付けない**（誤: `writing-style-rule-rule`）。`alwaysApply: true` のルール（例: `token-optimization-rule`）も同一 — 毎応答の冒頭に出力する。
- **コマンド**: Step 0 に `応答の冒頭に \`Applied: /command-name\` と出力する。`（スラッシュ付き）。frontmatter の `name:`および`/command-name` と basename を一致させる。
- **対比**: ルールは `Applied: rule-id`（スラッシュなし）、コマンドは `Applied: /command-name`（スラッシュあり）。いずれも **応答の冒頭** に出す。
- **ラッパー**（`.mdc` / Claude の `rules/**/*.md`）: `Applied:` は **共有本文**にのみ書く。ラッパーは frontmatter + `@~/.config/shared/ai/...` の import のみ（blog / conventions と同型）。

### レガシー例外（リネームしない）

| ファイル                                   | 理由                                                                    |
| ------------------------------------------ | ----------------------------------------------------------------------- |
| `rules/checklists/test-strategy-matrix.md` | 追加前からの basename。チェックリストだが `-checklist` サフィックスなし |

## `.md` と `.local.md`

| パターン                 | 説明                                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------------------- |
| ペア                     | 汎用 `.md`（Git）+ 差分 `.local.md`（gitignore）                                                                |
| only-local（ルール）     | 汎用 `.md` なし。`<topic>-rule.local.md` 推奨（例: `coding-rule.local.md`）                                     |
| only-local（参照データ） | ルールではないプロファイル等。`<topic>.local.md` 可（例: `company-profile.local.md`, `role-profiles.local.md`） |
| Git のみ                 | 上書き不要                                                                                                      |

`.local.md` は差分・追記のみ（汎用 `.md` の全文コピー禁止）。採用・自社固有は **Git に載せず** `rules/recruiting/*.local.md` と `commands/*.local.md` のみで維持する。

### オプション Read テンプレ（コマンド・ルールに埋め込む）

```markdown
## ルールの読み込み

1. `@~/.config/shared/ai/rules/<subdir>/<name>.md` を Read（必須）
2. 同ディレクトリの `<name>.local.md` を Glob で確認。存在する場合のみ Read。無ければスキップ
3. 矛盾時は `.local.md` を優先
```

## ツール別ラッパー

| ツール | ルール                            | コマンド                        |
| ------ | --------------------------------- | ------------------------------- |
| Cursor | `<name>.mdc` / `<name>.local.mdc` | `<name>.md` / `<name>.local.md` |
| Claude | `<name>.md` / `<name>.local.md`   | 同左                            |

コマンド frontmatter の `name:` は basename と一致（拡張子除く）。

## 新規追加手順

1. 本文を `packages/shared/shared/ai/` に追加
2. Cursor: `packages/cursor/rules/<subdir>/<name>.mdc` + `@import`
3. Claude: `packages/claude/rules/<subdir>/<name>.md` + `@import`
4. `make stow` で反映

詳細は [README.md](./README.md)。端末固有の運用・一覧は gitignore の `README.local.md`（各自作成）。

## RTK（Rust Token Killer）

AI 設定は **RTK インストール済み・hook 有効** を前提とする。詳細は [docs/RTK.md](./docs/RTK.md) を参照。

| 項目                | 正本                                              |
| ------------------- | ------------------------------------------------- |
| RTK 利用ガイド      | `packages/shared/shared/ai/docs/RTK.md`           |
| hook 設定（Claude） | `packages/claude/settings.json`                   |
| hook 設定（Cursor） | `packages/cursor/hooks.json`                      |
| RTK 設定            | `packages/rtk/rtk/config.toml` → `~/.config/rtk/` |
| エージェント運用    | `rules/conventions/token-optimization-rule.md`    |

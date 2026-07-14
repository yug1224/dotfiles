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

| 種別           | パターン                        | 配置                                                                                                                                           |
| -------------- | ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| ルール         | `<topic>-rule.md`               | `rules/<domain>/`（`meta/` は dotfiles 変更メタ）                                                                                              |
| チェックリスト | `<topic>-checklist.md`          | 原則 `rules/checklists/`。例外: `publish-checklist.md` は `rules/blog/` 可。`rules/meta/*-checklist.md`（`leakage` / `wrapper-parity` 等）も可 |
| **Meta**       | `<topic>-rule.md` 等            | `rules/meta/` — dotfiles AI 設定変更手順（`alwaysApply: false`）                                                                               |
| **Registry**   | `pr-feedback-registry.local.md` | `rules/conventions/` — 再発防止（**Git 管理外**）                                                                                              |
| コマンド       | 下記「コマンド命名」参照        | `commands/`                                                                                                                                    |
| エージェント   | `<name>.md`                     | `agents/`                                                                                                                                      |

### コマンド命名

新規・既存とも **`<verb>-<object>.md`**（スラッシュコマンド名＝basename）。例: `suggest-plan.md`, `analyze-issue.md`, `review-pr.md`。

選定基準: 日本語会話・業務でカタカナ／基礎語として通じやすいこと。難しめのビジネス英語は避ける。新コマンドは下表の許可動詞から選ぶ（勝手に系列を増やさない）。

| 動詞           | 意味（JP）                                     | 心象               | 避ける語                                   |
| -------------- | ---------------------------------------------- | ------------------ | ------------------------------------------ |
| `suggest`      | 提案する                                       | サジェスト         | —                                          |
| `review`       | レビューする                                   | レビュー           | —                                          |
| `plan`         | 計画する                                       | プラン             | —                                          |
| `write`        | 文章・プロンプト案を書く（未適用）             | 書く               | `draft`（馴染み薄い）                      |
| `capture`      | フィードバック等を記録・取り込む（log 追記案） | 記録する／取り込む | `lesson` を object にしない                |
| `analyze`      | 調査・分析し方針を出す（自動修正しない）       | 分析する           | `diagnose` / `fix`（馴染み薄い・修復暗示） |
| `apply`        | ルールを読み込み適用する                       | 適用する           | —                                          |
| `verify`       | 出力を検証する                                 | ベリファイ／検証   | —                                          |
| （例外）`magi` | ブランド合議の起動                             | —                  | `run-magi` は冗長                          |

`write` / `capture` / `suggest` の使い分け: 単一の本文・プロンプト案を起こすなら `write`、フィードバック等を log に取り込むなら `capture`、規約に沿った候補を並べるなら `suggest`。

リネームは許可する。`packages/shared` + Cursor + Claude の **3 ラッパーと参照を同一変更で同期**する（`Applied: /新名` と frontmatter `name:` も一致させる）。

#### 旧 → 新対応表

| 旧                        | 新                        | 変更                              |
| ------------------------- | ------------------------- | --------------------------------- |
| `suggest-branch-name`     | `suggest-branch-name`     | 維持                              |
| `suggest-commit-message`  | `suggest-commit-message`  | 維持                              |
| `suggest-pr-description`  | `suggest-pr-description`  | 維持                              |
| `suggest-plan`            | `suggest-plan`            | 維持                              |
| `suggest-development-log` | `suggest-development-log` | 維持                              |
| `apply-coding-rule`       | `apply-coding-rule`       | 維持                              |
| `verify-output`           | `verify-output`           | 維持                              |
| `magi`                    | `magi`                    | 維持（唯一の名詞例外）            |
| `pr-review`               | `review-pr`               | リネーム                          |
| `diff-review`             | `review-diff`             | リネーム                          |
| `blog-review`             | `review-blog`             | リネーム                          |
| `magi-pr-review`          | `review-pr-magi`          | リネーム（MAGI は suffix）        |
| `blog-plan`               | `plan-blog`               | リネーム                          |
| `capture-pr-lesson`       | `capture-pr-feedback`     | リネーム（`lesson` → `feedback`） |
| `fix-issue`               | `analyze-issue`           | リネーム                          |
| `graphic-record-prompt`   | `write-graphic-prompt`    | リネーム                          |

手元の `*.local.md` 追従は [docs/LOCAL-SETUP.md](./docs/LOCAL-SETUP.md) を参照。

### スキル命名

業務リポジトリ側の Skills は **名詞先頭** `<domain>-<pattern>`（コマンドの動詞先頭と名前空間分離）。コマンド動詞プレフィックス（`suggest-` / `review-` / `plan-` / `write-` / `capture-` / `analyze-` / `apply-` / `verify-` / `magi`）は先頭に付けない。`name:` は dirname と一致。詳細は [docs/templates/skills/README.md](./docs/templates/skills/README.md)。

### 自己申告（`Applied:`）の rule-id

- **ルール / チェックリスト**: 共有本文 1 行目に `応答の冒頭に「Applied: <rule-id>」と出力する。` を記載。`<rule-id>` はファイル名から拡張子（`.md`）を除いた文字列（例: `writing-style-rule.md` → `writing-style-rule`）。**`-rule` を二重に付けない**（誤: `writing-style-rule-rule`）。`alwaysApply: true` のルール（例: `token-optimization-rule`）も同一 — 毎応答の冒頭に出力する。
- **`.local.md` の rule-id**: basename そのまま（例: `coding-rule.local.md` → `Applied: coding-rule.local`、`pr-review-rule.local.md` → `Applied: pr-review-rule.local`）。ラッパーには書かない。
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

`.local.md` は差分・追記のみ（汎用 `.md` の全文コピー禁止）。ドメイン固有・自社固有は **Git に載せず** `rules/<domain>/*.local.md` と `commands/*.local.md` のみで維持する。

### 実装系 vs レビュー系（意図的分離）

| フェーズ     | 主なファイル                                                                                                            | サブエージェント                     |
| ------------ | ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| **実装**     | `coding-rule.local.md`                                                                                                  | ローカル定義（例: 積極利用）         |
| **レビュー** | `review-common-rule.md` + `pr-review-rule.md`（必須）+ 任意 `pr-review-rule.local.md` + `pr-feedback-registry.local.md` | **明示時のみ**（review-common 準拠） |

両方の方針を 1 ファイルに混在させない。

### フィードバック蒸留

log / index / registry は **常に local**（`*.local.*` gitignore）。

| 系列                      | log / index / registry                                       | 詳細の蒸留先                                     |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------ |
| FB-00x / プロジェクト固有 | `docs/feedback-*.local.md` + `pr-feedback-registry.local.md` | shared rule / cmd（汎用化時）または `*.local.md` |

dotfiles 変更時 → `rules/meta/`

詳細: [docs/PR-FEEDBACK-PLAYBOOK.md](./docs/PR-FEEDBACK-PLAYBOOK.md)、初期化: [docs/LOCAL-SETUP.md](./docs/LOCAL-SETUP.md)

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
4. `make mise-dotfiles` で shared 本文と Cursor / Claude ラッパーを反映（必要なら `make stow` で `~/.config/mise`）

**Meta ルール**（`rules/meta/`）は dotfiles AI 設定 PR 時のみ Read。`alwaysApply: false`。

**Registry**（`pr-feedback-registry.local.md`）はレビュー cmd / `review-common-rule` からオプション Read（存在時のみ）。Git にコミットしない。

詳細は [README.md](./README.md)。端末固有の運用・一覧は gitignore の `README.local.md`（各自作成）。

## RTK（Rust Token Killer）

AI 設定は **RTK インストール済み・hook 有効** を前提とする。詳細は [docs/RTK.md](./docs/RTK.md) を参照。

| 項目                | 正本                                                                      |
| ------------------- | ------------------------------------------------------------------------- |
| RTK 利用ガイド      | `packages/shared/shared/ai/docs/RTK.md`                                   |
| hook 設定（Claude） | `packages/claude/settings.json`                                           |
| hook 設定（Cursor） | `packages/cursor/hooks.json`                                              |
| RTK 設定            | `packages/rtk/rtk/config.toml` → `~/.config/rtk/`（`make mise-dotfiles`） |
| エージェント運用    | `rules/conventions/token-optimization-rule.md`                            |

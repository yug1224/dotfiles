利用可能な情報を総合的に分析し、**プロジェクトの PR テンプレートに準拠した** PR Title と Description を提案する。プロジェクトにテンプレートがない場合のみ、参照ルールのビルトインテンプレートを使用する。

**参照ルール**:

- `@~/.config/shared/ai/rules/conventions/pr-description-rule.md`（PR Title・Description）
- `@~/.config/shared/ai/rules/conventions/commit-message-rule.md`（PR Title の type / scope / subject 定義）

**Input**: `/suggest-pr-description` の後に続く引数は、GitHub PR URL、チケット ID、またはチケット URL（すべて任意）。チケット取得は `ticket-retrieval-rule` に従う。

**使用例**:

- `/suggest-pr-description`
- `/suggest-pr-description https://github.com/owner/repo/pull/123`
- `/suggest-pr-description PROJ-1234`
- `/suggest-pr-description https://github.com/owner/repo/pull/123 PROJ-1234`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `Applied: /suggest-pr-description` と出力する。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/pr-description-rule.md` と `commit-message-rule.md` を Read する。同ディレクトリの `pr-description-rule.local.md` があれば併せて Read（無ければスキップ）
2. チケット引数がある場合のみ、`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md` を Read。同ディレクトリの `ticket-retrieval-rule.local.md` があれば併せて Read

### 2. 引数の解析

引数を以下のカテゴリに分類する。

- `github.com` を含む URL かつ `/pull/` を含む → **GitHub PR URL**
- 上記以外の URL、またはチケット ID パターン（`[A-Z]+-\d+`）に一致する文字列 → **チケット**

### 3. テンプレートの検出（最優先）

**変更情報の収集や分析よりも先に、使用するテンプレートを確定する。**

a. **プロジェクトの PR テンプレートを検索**

PR URL がある場合はそのリポジトリの、ない場合は現在の作業ディレクトリの以下のパスを確認する。

```bash
ls .github/PULL_REQUEST_TEMPLATE.md .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

見つかった場合は Read ツールでその内容を取得し、以降のステップではこのテンプレートの**セクション構成・見出し・チェックリスト項目をそのまま使用**する。

b. **フォールバック: ビルトインテンプレートを判定**

プロジェクトに PR テンプレートが存在しない場合のみ、参照ルールのビルトインテンプレートを使用する。

| 条件                       | テンプレート               |
| -------------------------- | -------------------------- |
| フロントエンド系リポジトリ | フロントエンドテンプレート |
| 上記以外                   | バックエンドテンプレート   |

### 4. 変更情報の収集

a. **GitHub PR URL がある場合**（既存 PR の改善）

PR URL から `owner`, `repo`, `pullNumber` を抽出し、以下の優先順で情報を取得する。

**優先: gh CLI**

```bash
gh pr view <URL> --json title,body,commits,files,headRefName,baseRefName
gh pr diff <URL> --patch
```

diff が大きい場合は `--stat` で概要を先に取得し、主要な変更ファイルのみ個別に確認する。

**フォールバック: GitHub MCP（gh CLI が実行できない場合）**

- `pull_request_read`（method: `get`）で PR の詳細（タイトル、本文、ブランチ名）を取得
- `pull_request_read`（method: `get_diff`）で差分を取得
- `pull_request_read`（method: `get_files`）で変更ファイル一覧を取得
- `list_commits` で PR ブランチのコミット履歴を取得

いずれの手段でも、既存の Title / Description を保持しておく。

b. **GitHub PR URL がない場合**（新規生成）

まずデフォルトブランチを自動検出し、差分を取得する。

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```

検出できない場合は `develop` → `main` の順に試す。

```bash
git --no-pager log --oneline origin/<base>..HEAD
git --no-pager diff origin/<base>...HEAD --stat
git --no-pager diff origin/<base>...HEAD
```

diff が大きい場合は `--stat` の概要で全体像を把握してから、主要なファイルのみ個別に確認する。

### 5. チケット情報の取得（引数がある場合のみ）

チケット ID またはチケット URL が渡された場合のみ、`ticket-retrieval-rule`（および存在すれば `.local.md`）に従いチケットの目的・背景・要件を取得する。
引数がなければこのステップはスキップする。

### 6. 変更内容の分析

- `.codegraph/` がある場合、構造・フロー調査は `@~/.config/shared/ai/rules/conventions/token-optimization-rule.md` に従い CodeGraph を explore / Grep より先に使う

diff の読み取りだけでは変更の全体像が把握しにくい場合、Task ツール（`explore`, `readonly: true`）で関連コードを調査する。

**Step 3 で確定したテンプレートのセクション構成に沿って**、以下の情報を整理する:

- 変更の主目的を1つ特定する（機能追加、バグ修正、リファクタリングなど）→ PR Title の `type` に対応
- 影響範囲（scope）を決定する（kebab-case。不明確なら省略）
- 技術的な変更を具体的に把握する
- 変更ファイルから影響する領域を分類する（API / UI / DB / Config / テスト 等）
- 変更内容に応じて必要な確認項目を判定する
- スクリーンショットの要否を判定する（UI 変更がある場合は必要）

整理した情報を、テンプレートの各セクションにどう振り分けるかを決定する。

### 7. PR Title と Description の生成

- **PR Title**: `pr-description-rule` の「PR タイトル」に従い、`type(scope): subject [TICKET-ID]` 形式で生成する（`type` / `scope` / subject の定義は `commit-message-rule` のヘッダーに準拠）
  - 例: `feat(user-list): フィルタリング機能を追加 [PROJ-1234]`
  - ヘッダー全体 72 文字以内（subject 50 文字以内、`[TICKET-ID]` 含む）
  - scope が不明確な場合は省略（例: `chore: 依存関係を更新`）
  - チケット ID が取得できた場合のみ、末尾に半角スペース + `[TICKET-ID]` を付与する
  - ブランチ名の `type` と PR Title の `type` を揃える（例: `feat/...` → `feat(...):`）
- Step 3 で確定したテンプレートの構造に従って PR Description を生成する
- **プロジェクトテンプレートの場合**: セクション構成・見出し・チェックリスト項目を変更しない。チェックリストには項目を追加してもよいが、**既存の項目は削除しない**
- **ビルトインテンプレートの場合**: 参照ルールの「セクションごとの変更ルール」に従う
  - `📝 PR概要` `主な実装内容` `変更前後のスクリーンショット`: プレースホルダーを適切な内容に置き換える
  - `👮‍♂️ 動作確認`: リストの追加・変更は不可、チェックを入れることのみ可
  - `✅ 困ったらこの辺をチェック`: テンプレートの内容をそのまま維持し、変更しない
- チケット情報があれば、テンプレート内の該当セクション（関連リンク等）に反映する
- PR URL がある場合は、既存 Description との改善ポイントも補足する

### 8. PR 文案の下書き作成

下記フォーマットに従い**下書き**を作成する（この Step ではユーザーに提示しない）。コードブロック内はそのままコピー可能にする。

### 9. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 10. 最終出力

Step 9 で修正した内容を、下記フォーマットに従ってユーザーに提示する。

---

## 出力フォーマット

### PR URL がある場合（既存 PR の改善）

```markdown
## PR Title

\`\`\`
feat(scope): 変更概要 [TICKET-ID]
\`\`\`

## PR Description

\`\`\`markdown
（テンプレートに沿った PR Description 全文）
\`\`\`

## 改善ポイント

- 既存 Description からの変更点1
- 既存 Description からの変更点2
```

### PR URL がない場合（新規生成）

```markdown
## PR Title

\`\`\`
feat(scope): 変更概要 [TICKET-ID]
\`\`\`

## PR Description

\`\`\`markdown
（テンプレートに沿った PR Description 全文）
\`\`\`
```

---

## Guardrails

- **プロジェクトの PR テンプレートが存在する場合は、そのテンプレートの構造から絶対に逸脱しない**
- PR Title は `type(scope): subject [TICKET-ID]` 形式とする（プロジェクトにタイトル慣習がある場合はそちらを優先）
- PR Title のヘッダー全体は 72 文字以内、subject は 50 文字以内を目安とする（`[TICKET-ID]` 含む）
- PR Title の scope が不明確な場合は省略する
- PR Description は日本語で記述する（技術用語は英語可）
- テンプレートのすべてのセクションを埋める
- 「目的」は該当するものを **1つだけ選んで** 記載する
- プレースホルダー（`todo`, `タスク概要`）は必ず具体的な内容に置き換える
- チケット ID が取得できた場合は、PR Title の subject 末尾に半角スペース + `[TICKET-ID]` を付与する
- チケット取得は `ticket-retrieval-rule`（+ 存在すれば `.local.md`）に従い、引数で ID/URL が渡された場合のみ実行する
- 既存 PR の改善時は、元の Description の良い部分は活かしつつ改善する
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

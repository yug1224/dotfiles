利用可能な情報を総合的に分析し、**プロジェクトの PR テンプレートに準拠した** PR Title と Description を提案する。プロジェクトにテンプレートがない場合のみ、参照ルールのビルトインテンプレートを使用する。

**参照ルール**:

- `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md`（スライス `tech-doc-lite`。PR テンプレ構造は最優先）
- `@~/.config/shared/ai/rules/conventions/pr-description-rule.md`（PR Title・Description・手順詳細）
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

応答の冒頭に `✅️: /suggest-pr-description` と出力する（ルール側の `✅️` はユーザー向けに出さない）。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md` を Read する（適用は `tech-doc-lite`）
2. `@~/.config/shared/ai/rules/conventions/pr-description-rule.md` と `commit-message-rule.md` を Read する。同ディレクトリの `pr-description-rule.local.md` があれば併せて Read（無ければスキップ）
3. チケット引数がある場合のみ、`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md` を Read。同ディレクトリの `ticket-retrieval-rule.local.md` があれば併せて Read

### 2. 引数の解析

引数を以下のカテゴリに分類する。

- `github.com` を含む URL かつ `/pull/` を含む → **GitHub PR URL**
- 上記以外の URL、またはチケット ID パターン（`[A-Z]+-\d+`）に一致する文字列 → **チケット**

### 3. テンプレートの検出（最優先）

**変更情報の収集や分析よりも先に**、`pr-description-rule` の「テンプレートの検出」に従い、使用するテンプレートを確定する。

### 4. 変更情報の収集

`pr-description-rule` の「変更情報の収集」に従う。

### 5. チケット情報の取得（引数がある場合のみ）

チケット ID またはチケット URL が渡された場合のみ、`ticket-retrieval-rule`（および存在すれば `.local.md`）に従いチケットの目的・背景・要件を取得する。引数がなければスキップする。

### 6. 変更内容の分析

`pr-description-rule` の「変更内容の分析」に従う。diff の読み取りだけでは全体像が把握しにくい場合は、`@~/.config/shared/ai/rules/conventions/agent-delegation-rule.md` に従い Task で関連コードを調査する。

### 7. PR Title と Description の生成

`pr-description-rule` の「PR Title と Description の生成」に従う（PR Title の type / scope / subject は `commit-message-rule` のヘッダー定義に準拠）。

### 8. PR 文案の下書き作成

`pr-description-rule` の「出力フォーマット」に従い**下書き**を作成する（この Step ではユーザーに提示しない）。

### 9. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 10. 最終出力

Step 9 で修正した内容を、`pr-description-rule` の「出力フォーマット」に従ってユーザーに提示する。

---

## Guardrails

- **プロジェクトの PR テンプレートが存在する場合は、そのテンプレートの構造から絶対に逸脱しない**
- 説明文の文章規範は `japanese-tech-writing-rule` の **`tech-doc-lite`**（空句・冗長・根拠なき断言のみ。テンプレ構造・チェックリスト項目は常にテンプレ優先。**一文一行は要求しない**）
- PR Title は `pr-description-rule` の「PR タイトル」に従う（プロジェクトにタイトル慣習がある場合はそちらを優先）
- PR Description は日本語で記述する（技術用語は英語可）
- チケット取得は引数で ID/URL が渡された場合のみ実行する
- 既存 PR の改善時は、元の Description の良い部分は活かしつつ改善する
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

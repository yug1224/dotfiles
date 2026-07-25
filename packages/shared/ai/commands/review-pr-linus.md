指定された GitHub PR URL を、Linus Torvalds 風の辛辣・本質重視の批判的レビューで調査し、既存実装やルールとの整合性を踏まえた重要度別の指摘レポートを出力する。Linus ペルソナは親エージェントが適用する（ペルソナ適用のために Task サブエージェントは起動しない）。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md` / `@~/.config/shared/ai/rules/conventions/linus-review-rule.md`

**Input**: `/review-pr-linus` の後に続く引数は GitHub PR URL（必須）。

**使用例**:

- `/review-pr-linus https://github.com/owner/repo/pull/123`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /review-pr-linus` と出力する。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/review-common-rule.md` を Read（必須）
2. `@~/.config/shared/ai/rules/conventions/pr-review-rule.md` を Read（必須）
3. `@~/.config/shared/ai/rules/conventions/linus-review-rule.md` を Read（必須）
4. 同ディレクトリの `review-common-rule.local.md` / `pr-review-rule.local.md` / `pr-feedback-registry.local.md` を Glob。存在する場合のみ Read
5. `@~/.config/shared/ai/docs/feedback-log.local.md` / `feedback-index.local.md` を Glob。存在する場合のみ Read

### 2. PR 情報の取得

引数から GitHub PR URL を取得し、owner / repo / PR番号 を抽出する。
引数が未指定の場合はユーザーに入力を求める。

gh CLI（`gh pr view`, `gh pr diff`, `gh pr checks`）を優先使用し、以下を取得する:

- PR 基本情報（タイトル、本文、ブランチ名、ベースブランチ）
- 差分（diff）・変更ファイル一覧
- CI ステータス・既存レビューコメント

### 3. コンテキスト収集

共通ルールの「対象リポジトリのルール照合」に従い、ルール照合とタスク背景取得を行う。

- PR 本文にチケットリンクまたはチケット ID がある場合、`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md`（および存在すれば `.local.md`）に従い背景・要件を取得する

### 4. 変更コードの深掘り調査

`review-common-rule.md` の「深掘り調査」に従い、サブエージェント利用の判定を行う。

### 5. 重要度判定と下書きレポート作成

共通ルールの「重要度判定」に従い重要度を付与し、`linus-review-rule.md` の**出力フォーマット**に従ってレビューレポートの**下書き**を作成する（この Step ではユーザーに提示しない）。

### 6. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 7. 最終レポート出力

Step 6 で修正したレビューレポートのみをユーザーに提示する。

---

## Guardrails

- PR URL が未指定の場合はユーザーに入力を求める
- gh CLI を優先使用する。実行できない場合は GitHub MCP で代替する
- 既存レビューコメントがある場合はそれも考慮に含める
- 共通ルールの Guardrails を遵守する
- `linus-review-rule.md` の Guardrails を遵守する
- Linus ペルソナ適用のために Task サブエージェントを起動しない（深掘り調査の explore / quality-advisor は `review-common-rule` に従う）
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

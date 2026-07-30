指定された GitHub PR URL のレビューを行い、既存実装やルールとの整合性を調査した上で、重要度別の指摘レポートを出力する。

**共通ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md`

**Input**: `/review-pr` の後に続く引数は GitHub PR URL（必須）。

**使用例**:

- `/review-pr https://github.com/owner/repo/pull/123`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /review-pr` と出力する。

### 1. ルール読込

`review-common-rule.md` の「レビュー系コマンド共通手順」Step 1 に従う。

### 2. PR 情報の取得

引数から GitHub PR URL を取得し、owner / repo / PR番号 を抽出する。引数が未指定の場合はユーザーに入力を求める。

gh CLI（`gh pr view`, `gh pr diff`, `gh pr checks`）を優先使用し、以下を取得する:

- PR 基本情報（タイトル、本文、ブランチ名、ベースブランチ）
- 差分（diff）・変更ファイル一覧
- CI ステータス・既存レビューコメント

### 3–7. 共通レビュー手順

`review-common-rule.md` の「レビュー系コマンド共通手順」Step 3–7 に従う（intensity: **Thin**／出力: `pr-review-rule`）。

---

## Guardrails

- PR URL が未指定の場合はユーザーに入力を求める
- gh CLI を優先使用する。実行できない場合は GitHub MCP で代替する
- 既存レビューコメントがある場合はそれも考慮に含める
- 共通ルールの Guardrails を遵守する
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

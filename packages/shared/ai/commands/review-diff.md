ステージング済み（`git diff --staged`）の変更をレビューし、既存実装やルールとの整合性を調査した上で、重要度別の指摘レポートを出力する。PR を作成する前のセルフレビューとして活用する。

**共通ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md`

**Input**: `/review-diff` の後に続く引数はレビュー対象のファイルパス（任意、省略時は全 staged 変更）。チケット ID またはチケット URL も指定可能。

**使用例**:

- `/review-diff`
- `/review-diff src/components/Button.tsx`
- `/review-diff https://github.com/owner/repo/issues/123`
- `/review-diff PROJ-1234`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /review-diff` と出力する。

### 1. ルール読込

`review-common-rule.md` の「レビュー系コマンド共通手順」Step 1 に従う。

### 2. ステージング内容の取得

```bash
git diff --staged
git diff --staged --name-only
```

- ステージングされた変更がない場合は、その旨を伝えて終了する
- 引数にファイルパスが指定された場合は `git diff --staged -- <filepath>` で絞る

### 3–7. 共通レビュー手順

`review-common-rule.md` の「レビュー系コマンド共通手順」Step 3–7 に従う（intensity: **Thin**／出力: `pr-review-rule`）。

---

## Guardrails

- ステージングされた変更がない場合はその旨を伝えて終了する
- チケット情報の取得は引数で ID/URL が渡された場合のみ実行する
- 共通ルールの Guardrails を遵守する
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

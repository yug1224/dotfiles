ステージング済み（`git diff --staged`）の変更を、Linus Torvalds 風の辛辣・本質重視の批判的レビューで調査し、既存実装やルールとの整合性を踏まえた重要度別の指摘レポートを出力する。PR を作成する前のセルフレビューとして活用する。Linus ペルソナは親エージェントが適用する（ペルソナ適用のために Task サブエージェントは起動しない）。フル敵対的検証は `quality-advisor` が担当する。深掘り調査は `explore-worker` + `quality-advisor` を常時並列起動する。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md` / `@~/.config/shared/ai/rules/conventions/linus-review-rule.md`

**Input**: `/review-diff-linus` の後に続く引数はレビュー対象のファイルパス（任意、省略時は全 staged 変更）。チケット ID またはチケット URL も指定可能。

**使用例**:

- `/review-diff-linus`
- `/review-diff-linus src/components/Button.tsx`
- `/review-diff-linus https://github.com/owner/repo/issues/123`
- `/review-diff-linus PROJ-1234`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /review-diff-linus` と出力する。

### 1. ルール読込

`review-common-rule.md` の「レビュー系コマンド共通手順」Step 1 に従う。加えて `linus-review-rule.md` を Read（必須）。

### 2. ステージング内容の取得

```bash
git diff --staged
git diff --staged --name-only
```

- ステージングされた変更がない場合は、その旨を伝えて終了する
- 引数にファイルパスが指定された場合は `git diff --staged -- <filepath>` で絞る

### 3–7. 共通レビュー手順

`review-common-rule.md` の「レビュー系コマンド共通手順」Step 3–7 に従う（intensity: **Full**／出力: `linus-review-rule`）。

---

## Guardrails

- ステージングされた変更がない場合はその旨を伝えて終了する
- チケット情報の取得は引数で ID/URL が渡された場合のみ実行する
- 共通ルールの Guardrails を遵守する
- `linus-review-rule.md` の Guardrails を遵守する
- Linus ペルソナ適用のために Task サブエージェントを起動しない（深掘り調査の `explore-worker` / `quality-advisor` は常時並列。フル敵対は `quality-advisor`、ペルソナは親）
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

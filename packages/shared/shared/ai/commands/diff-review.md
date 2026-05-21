ステージング済み（`git diff --staged`）の変更をレビューし、既存実装やルールとの整合性を調査した上で、重要度別の指摘レポートを出力する。PR を作成する前のセルフレビューとして活用する。

**共通ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md`

**Input**: `/diff-review` の後に続く引数はレビュー対象のファイルパス（任意、省略時は全 staged 変更）。チケット ID またはチケット URL も指定可能。

**使用例**:

- `/diff-review`
- `/diff-review src/components/Button.tsx`
- `/diff-review https://notion.so/xxx`
- `/diff-review DC-1234`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `Applied: /diff-review` と出力する。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/review-common-rule.md` を Read（必須）
2. `@~/.config/shared/ai/rules/conventions/pr-review-rule.md` を Read（必須）
3. 同ディレクトリの `review-common-rule.local.md` / `pr-review-rule.local.md` を Glob。存在する場合のみ Read

### 2. ステージング内容の取得

```bash
git diff --staged
git diff --staged --name-only
```

- ステージングされた変更がない場合は、その旨を伝えて終了する
- 引数にファイルパスが指定された場合は `git diff --staged -- <filepath>` で絞る

### 3. コンテキスト収集

対象リポジトリのルール・ドキュメントを参照し、ルール照合を行う。

引数にチケット ID / URL が渡された場合のみ、タスク背景を取得する:

- **Notion**: Notion MCP を使用
- **GitHub Issues / PR**: GitHub MCP または URL フェッチ
- **その他 URL**: URL フェッチ
- **ID のみ**: ユーザーに確認するか会話コンテキストから推測

### 4. 変更コードの深掘り調査

`review-common-rule.md` の「深掘り調査」に従い、サブエージェント利用の判定を行う。

### 5. 重要度判定とレポート出力

`review-common-rule.md` の「重要度判定」「出力フォーマット」に従い、レビューレポートを出力する。

---

## Guardrails

- ステージングされた変更がない場合はその旨を伝えて終了する
- チケット情報の取得は引数で ID/URL が渡された場合のみ実行する
- 共通ルールの Guardrails を遵守する

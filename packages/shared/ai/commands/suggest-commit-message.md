利用可能な情報を総合的に分析し、コミットメッセージ規約に基づいて Must have / Nice to have の2パターンを提案する。

**参照ルール**: `packages/shared/ai/rules/conventions/commit-message-rule.md`（make mise 後 `~/.config/shared/ai/rules/` 等。Cursor ラッパー: `commit-message-rule.mdc`。所在は `shared/README.md` の「ルールファイルの所在」）

**Input**: `/suggest-commit-message` の後に続く引数は、チケット ID またはチケット URL（任意）。取得方法は `ticket-retrieval-rule`（および存在すれば `.local.md`）に従う。

**使用例**:

- `/suggest-commit-message`
- `/suggest-commit-message https://github.com/owner/repo/issues/123`
- `/suggest-commit-message PROJ-1234`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /suggest-commit-message` と出力する。

### 1. 規約の読み込み

`packages/shared/ai/rules/conventions/commit-message-rule.md`（または make mise 後の `~/.config/shared/ai/rules/conventions/commit-message-rule.md`）を Read ツールで読み込み、コミットメッセージ規約を把握する。

### 2. 情報の収集

以下の情報源を**並列で**収集する。

a. **ステージング概要 + 詳細**（必須）

```bash
git --no-pager diff --staged --stat
git --no-pager diff --staged
```

ステージングされた変更がない場合は、その旨を伝えて終了する。

diff が大きい場合（目安: `--stat` の出力が20ファイル以上）は、`--stat` で全体像を把握した上で、主要な変更ファイルのみ `git --no-pager diff --staged -- <file>` で個別に確認する。

b. **既存コミット履歴**

```bash
git --no-pager log --oneline -10
```

ブランチ上の既存コミットを確認し、メッセージの一貫性や重複を検証する。

c. **チケット情報**（引数がある場合のみ）

`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md` に従い、チケットの目的・背景・タイトルを取得する。同ディレクトリの `ticket-retrieval-rule.local.md` があれば併せて Read（無ければスキップ）。

d. **コンテキスト情報**
ユーザーが `@` で添付したファイルや会話中で提供した情報があれば、それも考慮する。

### 3. 変更の分析

収集した情報を総合して以下を判断する。

- 変更の主目的を1つ特定する（feat / fix / refactor / perf / docs / style / test / chore）
- 影響範囲（scope）を決定する（kebab-case）
- 「なぜ」変更したかを特定する（チケット情報があれば優先的に活用）
- ステージングに**複数の論理的変更**が含まれていないかを判定する

### 4. Must have / Nice to have の2パターンを生成

参照ルールに基づき、以下の2段階で提案する。

- **Must have**: type(scope): subject + 変更点の箇条書き
- **Nice to have**: type(scope): subject + 変更理由の説明 + 変更点の箇条書き + footer（該当時）

チケット ID が取得できた場合は、すべてのパターンのヘッダー末尾に半角スペース + `[TICKET-ID]` を付与する。取得できなかった場合は付与しない。

### 5. Markdown形式で出力

下記フォーマットに従って出力する。コードブロック内のメッセージはそのままコピー可能にする。

---

## 出力フォーマット

### 単一変更の場合

```markdown
## Commit Message 提案

### Must have

subject + 変更点の箇条書き

\`\`\`
type(scope): subject

- 変更点1
- 変更点2
  \`\`\`

### Nice to have

subject + 変更理由 + 変更点の箇条書き + footer

\`\`\`
type(scope): subject

変更理由の説明文。

- 変更点1
- 変更点2
- 変更点3

Closes #XXX
\`\`\`
```

### 分割提案の場合

ステージングに複数の論理的変更が含まれる場合は、以下のフォーマットで分割案を提示する。

```markdown
## ⚠️ コミット分割の提案

ステージングに複数の論理的変更が含まれています。以下の分割を推奨します。

### コミット 1: type(scope): subject

対象ファイル: `file1.ts`, `file2.ts`

\`\`\`
type(scope): subject

- 変更点1
- 変更点2
  \`\`\`

### コミット 2: type(scope): subject

対象ファイル: `file3.ts`, `file4.ts`

\`\`\`
type(scope): subject

- 変更点1
- 変更点2
  \`\`\`

### 分割手順

\`\`\`bash
git reset HEAD -- file3.ts file4.ts
git commit
git add file3.ts file4.ts
git commit
\`\`\`
```

---

## Guardrails

- ヘッダー全体は72文字以内、subject は50文字以内を目安とする（`[TICKET-ID]` 部分も文字数に含む）
- subject は日本語で記述する（技術用語は英語可）
- 1コミット = 1論理的変更の原則に基づいて提案する
- ステージングに複数の論理的変更が含まれる場合は、分割案ごとにコミットメッセージと対象ファイルを提示する
- 破壊的変更がある場合は `BREAKING CHANGE:` フッターの付与を提案する
- type と scope の選択理由を簡潔に補足する
- チケット ID が取得できた場合は、ヘッダー末尾に半角スペース + `[TICKET-ID]` を付与する
- PR 作成時は、提案したヘッダー1行を PR タイトルにそのまま流用できる（[PR概要の記述ルール](../rules/conventions/pr-description-rule.md) の PR タイトルと同一形式）
- チケット情報の取得は引数で ID/URL が渡された場合のみ実行し、渡されなければスキップする

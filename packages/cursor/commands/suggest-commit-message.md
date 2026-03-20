---
name: /suggest-commit-message
id: suggest-commit-message
category: Development
description: ステージング内容からコミットメッセージを松竹梅で提案する
---

利用可能な情報を総合的に分析し、コミットメッセージ規約に基づいて松竹梅の3パターンを提案する。

**参照ルール**: `~/.cursor/rules/commit-message-rule.mdc`

**Input**: `/suggest-commit-message` の後に続く引数は、Notion チケット ID または Notion URL（任意）。

---

## Steps

### 1. 規約の読み込み

`~/.cursor/rules/commit-message-rule.mdc` を Read ツールで読み込み、コミットメッセージ規約を把握する。

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

c. **Notion チケット情報**（引数がある場合のみ）
引数に Notion チケット ID または Notion URL が渡された場合のみ、Notion MCP を使ってチケットの目的・背景を取得する。
引数がなければこのステップはスキップする。

d. **コンテキスト情報**
ユーザーが `@` で添付したファイルや会話中で提供した情報があれば、それも考慮する。

### 3. 変更の分析

収集した情報を総合して以下を判断する。

- 変更の主目的を1つ特定する（feat / fix / refactor / perf / docs / style / test / chore）
- 影響範囲（scope）を決定する（kebab-case）
- 「なぜ」変更したかを特定する（Notion チケット情報があれば優先的に活用）
- ステージングに**複数の論理的変更**が含まれていないかを判定する

### 4. 松竹梅の3パターンを生成

参照ルールに基づき、以下の3段階で提案する。

- **松（詳細）**: type(scope): subject + 変更理由の説明 + 変更点の箇条書き + footer（該当時）
- **竹（標準）**: type(scope): subject + 変更点の箇条書き
- **梅（簡潔）**: type(scope): subject のみ

### 5. Markdown形式で出力

下記フォーマットに従って出力する。コードブロック内のメッセージはそのままコピー可能にする。

---

## 出力フォーマット

### 単一変更の場合

```markdown
## Commit Message 提案

### 松（詳細）

subject + 変更理由 + 変更点の箇条書き

\`\`\`
type(scope): subject

変更理由の説明文。

- 変更点1
- 変更点2
- 変更点3

Closes #XXX
\`\`\`

### 竹（標準）

subject + 変更点の箇条書き

\`\`\`
type(scope): subject

- 変更点1
- 変更点2
  \`\`\`

### 梅（簡潔）

subject のみ

\`\`\`
type(scope): subject
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

- ヘッダー全体は72文字以内、subject は50文字以内を目安とする
- subject は日本語で記述する（技術用語は英語可）
- 1コミット = 1論理的変更の原則に基づいて提案する
- ステージングに複数の論理的変更が含まれる場合は、分割案ごとにコミットメッセージと対象ファイルを提示する
- 破壊的変更がある場合は `BREAKING CHANGE:` フッターの付与を提案する
- type と scope の選択理由を簡潔に補足する
- Notion MCP は引数で ID/URL が渡された場合のみ使用し、渡されなければ呼び出さない

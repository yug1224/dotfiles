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

1. **規約の読み込み**

   `~/.cursor/rules/commit-message-rule.mdc` を Read ツールで読み込み、コミットメッセージ規約を把握する。

2. **情報の収集**

   以下の情報源を可能な範囲で収集する。

   a. **ステージング内容**（必須）
   ```bash
   git diff --staged
   ```
   ステージングされた変更がない場合は、その旨を伝えて終了する。

   b. **Notion チケット情報**（引数がある場合のみ）
   引数に Notion チケット ID（例: `DC-1234`）または Notion URL が渡された場合のみ、Notion MCP を使ってチケットの目的・背景を取得する。
   引数がなければこのステップはスキップする。

   c. **コンテキスト情報**
   ユーザーが `@` で添付したファイルや会話中で提供した情報があれば、それも考慮する。

3. **変更の分析**

   収集した情報を総合して以下を判断する。

   - 変更の主目的を1つ特定する（feat / fix / refactor / perf / docs / style / test / chore）
   - 影響範囲（scope）を決定する（kebab-case）
   - 「なぜ」変更したかを特定する（Notion チケット情報があれば優先的に活用）

4. **松竹梅の3パターンを生成**

   参照ルールに基づき、以下の3段階で提案する。

   - **松（詳細）**: type(scope): subject + 変更理由の説明 + 変更点の箇条書き
   - **竹（標準）**: type(scope): subject + 変更点の箇条書き
   - **梅（簡潔）**: type(scope): subject のみ

5. **Markdown形式で出力**

   下記フォーマットに従って出力する。コードブロック内のメッセージはそのままコピー可能にする。

---

## 出力フォーマット

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

---

## Guardrails

- ヘッダーは50文字以内に収める
- subject は日本語で記述する（技術用語は英語可）
- 1コミット = 1論理的変更の原則に基づいて提案する
- ステージングに複数の論理的変更が含まれる場合は、コミットの分割を提案する
- type と scope の選択理由を簡潔に補足する
- Notion MCP は引数で ID/URL が渡された場合のみ使用し、渡されなければ呼び出さない

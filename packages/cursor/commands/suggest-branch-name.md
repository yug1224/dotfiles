---
name: /suggest-branch-name
id: suggest-branch-name
category: Development
description: 変更内容からブランチ名を松竹梅で提案する
---

利用可能な情報を総合的に分析し、ブランチ名規約に準拠したブランチ名を松竹梅の3パターンで提案する。

**参照ルール**: `~/.cursor/rules/branch-name-rule.mdc`

**Input**: `/suggest-branch-name` の後に続く引数は、Notion チケット ID または Notion URL（任意）。

---

## Steps

1. **規約の読み込み**

   `~/.cursor/rules/branch-name-rule.mdc` を Read ツールで読み込み、ブランチ名規約を把握する。

2. **情報の収集**

   以下の情報源を可能な範囲で収集する。

   a. **Notion チケット情報**（引数がある場合のみ）
   引数に Notion チケット ID（例: `DC-1234`）または Notion URL が渡された場合のみ、Notion MCP を使ってチケットの目的・背景・タイトルを取得する。
   引数がなければこのステップはスキップする。

   b. **ステージング内容**
   ```bash
   git diff --staged
   ```
   ステージングされた変更があれば、変更内容から目的を推測する補助情報として活用する。

   c. **コンテキスト情報**
   ユーザーが `@` で添付したファイルや会話中で提供した情報があれば、それも考慮する。

   d. **フォールバック**
   上記のいずれからも変更内容が判断できない場合は、ユーザーに何を変更・実装するかを質問する。

3. **変更の分析**

   収集した情報を総合して以下を判断する。

   - 変更の種別（type）を特定する（feat / fix / refactor / perf / docs / style / test / chore）
   - 適切な kebab-case の description を導出する
   - Notion ID が提供された場合はそれを含める

4. **松竹梅の3パターンを生成**

   参照ルールに基づき、以下の3段階で提案する。

   - **松（詳細 + Notion ID）**: `type/notion-id-descriptive-name`（変更内容が詳細にわかる名前）
   - **竹（標準 + Notion ID）**: `type/notion-id-name`（標準的な長さの名前）
   - **梅（簡潔）**: `type/short-name`（Notion ID なし、最小限の名前）

   Notion ID が提供されていない場合は、松・竹は ID なしの詳細度の違いとして提案する。

5. **Markdown形式で出力**

   下記フォーマットに従って出力する。コードブロック内のブランチ名はそのままコピー可能にする。

---

## 出力フォーマット

### Notion ID がある場合

```markdown
## Branch Name 提案

### 松（詳細 + Notion ID）

変更内容が具体的にわかる命名

\`\`\`
type/DC-XXXX-descriptive-branch-name
\`\`\`

### 竹（標準 + Notion ID）

標準的な長さの命名

\`\`\`
type/DC-XXXX-branch-name
\`\`\`

### 梅（簡潔）

最小限の命名

\`\`\`
type/short-name
\`\`\`
```

### Notion ID がない場合

```markdown
## Branch Name 提案

### 松（詳細）

変更内容が具体的にわかる命名

\`\`\`
type/descriptive-branch-name
\`\`\`

### 竹（標準）

標準的な長さの命名

\`\`\`
type/branch-name
\`\`\`

### 梅（簡潔）

最小限の命名

\`\`\`
type/short-name
\`\`\`
```

---

## Guardrails

- すべて英字小文字で記述する
- 単語はハイフン（-）で区切る（アンダースコア不可）
- type は規約で定義された8種のみ使用する
- 松と梅の文字数差が明確になるよう、粒度に差をつける
- type の選択理由を簡潔に補足する
- Notion MCP は引数で ID/URL が渡された場合のみ使用し、渡されなければ呼び出さない

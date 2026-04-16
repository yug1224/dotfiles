---
name: /suggest-branch-name
id: suggest-branch-name
category: Development
description: 変更内容からブランチ名を松竹梅で提案する
---

利用可能な情報を総合的に分析し、ブランチ名規約に準拠したブランチ名を松竹梅の3パターンで提案する。

**参照ルール**: `~/.cursor/rules/conventions/branch-name-rule.mdc`

**Input**: `/suggest-branch-name` の後に続く引数は、チケット ID またはチケット URL（任意）。Notion、GitHub Issues、Jira 等のチケットシステムに対応。

---

## Steps

### 0. トレース（必須）

応答の冒頭に `Applied: /suggest-branch-name` と出力する。

### 1. 規約の読み込み

`~/.cursor/rules/conventions/branch-name-rule.mdc` を Read ツールで読み込み、ブランチ名規約を把握する。

### 2. 情報の収集

以下の情報源を**並列で**収集する。

a. **現在のブランチと作業状態**

```bash
git branch --show-current
git status --short
```

現在のブランチ名が既に規約に準拠している場合は、その旨を補足する。

b. **変更内容**

```bash
git --no-pager diff --stat
git --no-pager diff --staged --stat
```

unstaged / staged の変更があれば、変更内容から目的を推測する補助情報として活用する。diff が大きい場合は `--stat` の概要のみで判断する。

c. **チケット情報**（引数がある場合のみ）
引数にチケット ID または URL が渡された場合のみ、適切な手段でチケットの目的・背景・タイトルを取得する。引数がなければこのステップはスキップする。

チケットシステムの判別と取得方法:

- **Notion**: Notion MCP を使用（URL に `notion.so` / `notion.site` を含む場合、または Notion ページ ID 形式の場合）
- **GitHub Issues / PR**: GitHub MCP または URL フェッチを使用（URL に `github.com` を含む場合）
- **その他の URL**: URL フェッチで内容を取得する
- **ID のみ（URL なし）**: ユーザーに補足情報を確認するか、会話コンテキストから推測する

d. **コンテキスト情報**
ユーザーが `@` で添付したファイルや会話中で提供した情報があれば、それも考慮する。

e. **フォールバック**
上記のいずれからも変更内容が判断できない場合は、ユーザーに何を変更・実装するかを質問する。

### 3. 変更の分析

収集した情報を総合して以下を判断する。

- 変更の種別（type）を特定する（feat / fix / refactor / perf / docs / style / test / chore）
- 適切な kebab-case の description を導出する
- チケット ID が提供された場合はそれを含める

### 4. 松竹梅の3パターンを生成

参照ルールに基づき、以下の3段階で提案する。全体で50文字以内を目安とする。

- **松（詳細）**: `type/ticket-id-descriptive-name`（変更内容が詳細にわかる名前）
- **竹（標準）**: `type/ticket-id-name`（標準的な長さの名前）
- **梅（簡潔）**: `type/short-name`（最小限の名前）

チケット ID が提供されていない場合は、松・竹・梅すべて ID なしの詳細度の違いとして提案する。

### 5. Markdown形式で出力

下記フォーマットに従って出力する。コードブロック内のブランチ名はそのままコピー可能にする。

---

## 出力フォーマット

### チケット ID がある場合

```markdown
## Branch Name 提案

### 松（詳細）

変更内容が具体的にわかる命名

\`\`\`
type/PROJ-XXXX-descriptive-branch-name
\`\`\`

### 竹（標準）

標準的な長さの命名

\`\`\`
type/PROJ-XXXX-branch-name
\`\`\`

### 梅（簡潔）

最小限の命名

\`\`\`
type/short-name
\`\`\`
```

### チケット ID がない場合

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
- 全体で50文字以内を目安とする
- 松と梅の文字数差が明確になるよう、粒度に差をつける
- type の選択理由を簡潔に補足する
- チケット情報の取得は引数で ID/URL が渡された場合のみ実行し、渡されなければスキップする

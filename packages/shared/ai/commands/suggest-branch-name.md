利用可能な情報を総合的に分析し、ブランチ名規約に準拠したブランチ名を Must have / Nice to have の2パターンで提案する。

**参照ルール**: `packages/shared/ai/rules/conventions/branch-name-rule.md`（mise-dotfiles 後 `~/.config/shared/ai/rules/` 等。Cursor ラッパー: `branch-name-rule.mdc`。所在は `shared/README.md` の「ルールファイルの所在」）

**Input**: `/suggest-branch-name` の後に続く引数は、チケット ID またはチケット URL（任意）。取得方法は `ticket-retrieval-rule`（および存在すれば `.local.md`）に従う。

**使用例**:

- `/suggest-branch-name`
- `/suggest-branch-name https://github.com/owner/repo/issues/123`
- `/suggest-branch-name PROJ-1234`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /suggest-branch-name` と出力する。

### 1. 規約の読み込み

`packages/shared/ai/rules/conventions/branch-name-rule.md`（または mise-dotfiles 後の `~/.config/shared/ai/rules/conventions/branch-name-rule.md`）を Read ツールで読み込み、ブランチ名規約を把握する。

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

`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md` に従い、チケットの目的・背景・タイトルを取得する。同ディレクトリの `ticket-retrieval-rule.local.md` があれば併せて Read（無ければスキップ）。

d. **コンテキスト情報**
ユーザーが `@` で添付したファイルや会話中で提供した情報があれば、それも考慮する。

e. **フォールバック**
上記のいずれからも変更内容が判断できない場合は、ユーザーに何を変更・実装するかを質問する。

### 3. 変更の分析

収集した情報を総合して以下を判断する。

- 変更の種別（type）を特定する（feat / fix / refactor / perf / docs / style / test / chore）— コミット / PR タイトルの `type` と揃える
- 適切な kebab-case の description を導出する（コミット / PR の scope 候補としても参照できる）
- チケット ID が提供された場合はそれを含める

### 4. Must have / Nice to have の2パターンを生成

参照ルールに基づき、以下の2段階で提案する。全体で50文字以内を目安とする。

- **Must have**: `type/ticket-id-name`（規約準拠の標準的な命名）
- **Nice to have**: `type/ticket-id-descriptive-name`（変更内容がより具体的にわかる命名）

チケット ID が提供されていない場合は、両パターンとも ID なしで詳細度の違いとして提案する。

### 5. Markdown形式で出力

下記フォーマットに従って出力する。コードブロック内のブランチ名はそのままコピー可能にする。

---

## 出力フォーマット

### チケット ID がある場合

```markdown
## Branch Name 提案

### Must have

規約準拠の標準的な命名

\`\`\`
type/PROJ-XXXX-branch-name
\`\`\`

### Nice to have

変更内容がより具体的にわかる命名

\`\`\`
type/PROJ-XXXX-descriptive-branch-name
\`\`\`
```

### チケット ID がない場合

```markdown
## Branch Name 提案

### Must have

規約準拠の標準的な命名

\`\`\`
type/branch-name
\`\`\`

### Nice to have

変更内容がより具体的にわかる命名

\`\`\`
type/descriptive-branch-name
\`\`\`
```

---

## Guardrails

- すべて英字小文字で記述する
- 単語はハイフン（-）で区切る（アンダースコア不可）
- type は規約で定義された8種のみ使用する
- 全体で50文字以内を目安とする
- Must have と Nice to have の粒度に明確な差をつける
- type の選択理由を簡潔に補足する
- ブランチの `type` は、同一変更のコミットヘッダー・PR タイトルの `type` と一致させる
- チケット情報の取得は引数で ID/URL が渡された場合のみ実行し、渡されなければスキップする

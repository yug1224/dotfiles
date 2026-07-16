チケット情報と GitHub PR の情報を収集・分析し、開発ログ記載ルール（MECE 構造: 概要 / 分析 / 方針 / 実装 / 検証 / 残課題）に基づいて開発ログを生成する。

**参照ルール**:

- `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md`（スライス `tech-doc-lite`。MECE／記載量は development-log-rule 優先）
- `@~/.config/shared/ai/rules/conventions/development-log-rule.md`
- `@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md`（チケット取得）

**Input**: `/suggest-development-log` の後に続く引数は、チケット URL またはチケット ID（必須）と GitHub PR URL（任意、複数可）。取得方法は `ticket-retrieval-rule`（および存在すれば `.local.md`）に従う。

**使用例**:

- `/suggest-development-log https://github.com/owner/repo/issues/123`
- `/suggest-development-log PROJ-1234`
- `/suggest-development-log PROJ-1234 https://github.com/owner/repo/pull/123`
- `/suggest-development-log PROJ-1234 https://github.com/owner/repo/pull/123 https://github.com/owner/repo/pull/124`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /suggest-development-log` と出力する。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md` を Read（必須。適用は `tech-doc-lite`）
2. `@~/.config/shared/ai/rules/conventions/development-log-rule.md` を Read（必須）
3. `@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md` を Read（必須）
4. 同ディレクトリの `ticket-retrieval-rule.local.md` を Glob。存在する場合のみ Read（矛盾時は `.local.md` を優先）

### 2. 引数の解析

引数を以下のカテゴリに分類する。

- `github.com` を含む URL かつ `/pull/` を含む → **GitHub PR URL**
- 上記以外のチケット URL またはチケット ID パターン（`[A-Z]+-\d+` 等）→ **チケット**

チケット（URL/ID）が未指定の場合はユーザーに入力を求める。

### 3. チケット情報の取得

`ticket-retrieval-rule`（および存在すれば `.local.md`）に従い、チケットの詳細を取得する。

取得すべき情報:

- チケット ID とタイトル → **概要**セクションに振り分け
- 発生事象（問題の現象） → **分析**セクションに振り分け
- 対応してほしい内容（期待される動作） → **方針**セクションに振り分け
- ステータスや優先度 → 生成判断の参考情報

### 4. GitHub情報取得（PR URL がある場合）

PR URL ごとに以下の情報を取得する。

**優先: gh CLI**

```bash
gh pr view <URL> --json title,body,commits,files,headRefName,baseRefName,statusCheckRollup
gh pr diff <URL>
```

diff が大きい場合は `--stat` で概要を先に取得し、主要な変更ファイルのみ個別に確認する。

**フォールバック: GitHub MCP（gh CLI が実行できない場合）**

- `pull_request_read`（method: `get`）で PR の詳細（タイトル、本文、ブランチ名）を取得
- `pull_request_read`（method: `get_diff`）で差分を取得
- `pull_request_read`（method: `get_files`）で変更ファイル一覧を取得

複数 PR がある場合は全て分析する。

振り分け先:

- PR タイトル・ブランチ名 → **概要**の関連 PR
- diff の変更内容 → **実装**セクション
- CI / テストの状態 → **検証**セクション

### 5. コードの深掘り調査

- `.codegraph/` がある場合、構造・フロー調査は `@~/.config/shared/ai/rules/conventions/token-optimization-rule.md` に従い CodeGraph を explore / Grep より先に使う

以下のいずれかに該当する場合、Task ツール（`explore` / `generalPurpose`, `readonly: true`）で関連コードベースを調査する。

- diff だけでは技術的原因が特定できない
- 変更ファイルが多く（目安: 10ファイル以上）、変更の全体像が把握しにくい
- 修正が既存のアーキテクチャパターンに関わる

フロントエンド / バックエンドの調査は並列で実行する。

### 6. 開発ログの下書き作成

参照ルールの MECE テンプレートと記載量の目安に従い、以下の構成で**下書き**を作成する（この Step ではユーザーに提示しない）。

- **概要**: タスクID・タイトル・説明・関連PR
- **分析**: 現象 + 原因（バグ修正の場合）、または背景 + 目標（機能開発の場合）
- **方針**: 機能要件 + 技術要件
- **実装**: 領域別の変更内容（存在する領域のみ）
- **検証**: 確認手順と結果
- **残課題**: 後続タスク・既知の制限・技術的負債（該当なしは「なし」）

WIP / Draft PR の場合は、検証・残課題セクションに「進行中」と明記する。

### 7. MECE チェック

下書きの開発ログが以下の条件を満たすか確認し、必要なら下書きを修正する。

- **排他性**: 各セクション間で内容の重複がないか（例: 概要と分析で同じ内容を繰り返していないか）
- **網羅性**: 6セクションすべてが埋まっているか（残課題が「なし」であっても記載する）
- **記載量**: 各セクションが記載量の目安の範囲内か

### 8. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 9. 最終出力

Step 8 で修正した内容を、下記出力フォーマットに従ってユーザーに提示する。コードブロック内はそのままコピー可能にする。

---

## 出力フォーマット

参照ルールの「開発ログのテンプレート」および「記載量の目安」に従い、Markdown 形式で記載する。

---

## Guardrails

- チケット URL/ID が未指定の場合はユーザーに入力を求める
- GitHub PR URL が未指定でもチケット情報だけで概要・分析・方針は生成可能とする
- チケット取得は `ticket-retrieval-rule`（+ 存在すれば `.local.md`）に従う。プロバイダ固有手順を本コマンド本文にハードコードしない
- gh CLI（`gh pr view` / `gh pr diff`）を優先使用する。gh CLI が実行できない場合は GitHub MCP で代替する
- サブエージェントは `readonly: true` で安全に調査する
- 各セクションは簡潔に（記載量の目安に従う）
- MECE・記載量・テンプレ構造は `development-log-rule` を優先。文章規範は `japanese-tech-writing-rule` の **`tech-doc-lite`**（空句・冗長・根拠なき断言のみ。**一文一行は要求しない**）
- 技術的な原因を具体的に記載する（「〜が機能していない」ではなく具体的なコード/設計レベルの原因）
- PR の変更内容から主要な実装を抽出し、PR 概要のコピペは避ける
- 実装セクションの領域（FE / BE / Infra 等）は PR が存在する側のみ記載する
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

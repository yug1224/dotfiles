GitHub PR URL からレビュー指摘・議論・マージ後の振り返りを読み取り、PR フィードバックログ（local registry）への**追記案**を生成する。ファイルの直接編集・コミット・push は行わない（読み取り専用）。

**参照ルール**:

- `@~/.config/shared/ai/rules/conventions/review-common-rule.md`（レビュー観点の整理）
- `@~/.config/shared/ai/rules/conventions/pr-feedback-registry.local.md` を Glob。存在する場合のみ Read（追記先フォーマット）
- 同ディレクトリの `review-common-rule.local.md` を Glob。存在する場合のみ Read
- `@~/.config/shared/ai/docs/feedback-log.local.md` / `feedback-index.local.md` を Glob。存在する場合のみ Read

**Input**: `/capture-pr-feedback` の後に続く引数は GitHub PR URL（必須）。

**使用例**:

- `/capture-pr-feedback https://github.com/owner/repo/pull/123`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /capture-pr-feedback` と出力する。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/review-common-rule.md` を Read（必須）
2. `@~/.config/shared/ai/rules/conventions/pr-feedback-registry.local.md` / `review-common-rule.local.md` を Glob。存在する場合のみ Read
3. `@~/.config/shared/ai/docs/feedback-log.local.md` / `feedback-index.local.md` を Glob。存在する場合のみ Read

### 2. PR 情報の取得（読み取り専用）

引数から GitHub PR URL を取得し、owner / repo / PR 番号を抽出する。未指定の場合はユーザーに入力を求める。

**優先: gh CLI（読み取りのみ）**

```bash
gh pr view <URL> --json title,body,state,mergedAt,url,author,labels,comments,reviews,reviewThreads
gh pr diff <URL> --stat
```

必要に応じて `gh api repos/{owner}/{repo}/pulls/{number}/comments` 等でレビューコメントを補完する。

**フォールバック: GitHub MCP**（gh CLI が使えない場合）

- PR 基本情報・diff・レビューコメント・スレッドを取得する

### 3. 教訓の抽出

以下を整理する（推測で断定しない。根拠が PR 上に無い項目は「不明」または省略）。

| 観点             | 抽出内容                                        |
| ---------------- | ----------------------------------------------- |
| **コンテキスト** | PR タイトル、目的、関連チケットリンク（あれば） |
| **指摘**         | レビューコメントから再発防止に効く指摘（要約）  |
| **対応**         | マージ前に取った修正・合意事項                  |
| **教訓**         | 次回以降に適用できるルール・チェック・設計判断  |
| **タグ**         | 領域（FE/BE/Infra/Process 等）、重要度          |

分類: dotfiles / AI 設定 → **FB-00x**。業務リポジトリ → **FB-Dxxx 等**。いずれも **local のみ**（Git 追記候補にしない）。

`pr-feedback-registry.local.md` のエントリ形式があればそれに従う。無い場合は下記デフォルトを使う。

### 4. 追記案の下書き作成

**下書き**として、ログファイル末尾に追記する Markdown ブロックを 1 件作成する（この Step ではユーザーに提示しない）。

```markdown
## [YYYY-MM-DD] owner/repo#123 — <PR タイトル短縮>

- **URL**: <PR URL>
- **状態**: merged | closed | open
- **タグ**: <comma-separated>
- **教訓**: <1–3 文で再発防止の要点>
- **指摘サマリ**:
  - <bullet>
- **次回チェック**:
  - <bullet>
```

### 5. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 6. 最終出力

Step 5 で修正した追記案のみをユーザーに提示する。次を明示する:

1. **追記先**（すべて local・**Git にコミットしない**）
   - `docs/feedback-log.local.md`
   - `docs/feedback-index.local.md`
   - `rules/conventions/pr-feedback-registry.local.md`
2. **コピー用 Markdown ブロック**（そのまま末尾追記できる形）
3. **根拠**（どのレビューコメント / diff から抽出したか、1 行ずつ）

---

## Guardrails

- PR URL が未指定の場合はユーザーに入力を求める
- **ファイルの Write / コミット / push / PR 作成は禁止**（提案テキストの出力のみ）
- gh CLI を優先使用する。実行できない場合は GitHub MCP で代替する
- レビュー指摘が無い PR では「教訓なし」または diff から得た設計判断のみを記載し、捏造しない
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

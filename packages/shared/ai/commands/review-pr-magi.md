MAGI System の 3 ユニット（MELCHIOR-1, BALTHASAR-2, CASPER-3）を並列投入し、異なる視点から GitHub PR のレビューを行う。MAGI は Worker（Cursor: Composer 系 / Claude: `sonnet`）。フル敵対的検証（Opus）は既定オフ — 必要なら合議後に `/verify-adversarial`。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md`

**Input**: `/review-pr-magi` の後に続く引数は GitHub PR URL（必須）。

**使用例**:

- `/review-pr-magi https://github.com/owner/repo/pull/123`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /review-pr-magi` と出力する。

### 1. 開始メッセージの出力

`--- MAGI PR Review 起動: 3 ユニット並列解析中 ---` と出力する。

### 2. PR URL の解析

引数から GitHub PR URL を取得し、owner / repo / PR番号 を抽出する。
引数が未指定の場合はユーザーに入力を求める。

### 3. ルール・エージェント定義の読み込み

以下のファイルを **並列で** 読み込む:

- `@~/.config/shared/ai/rules/conventions/review-common-rule.md`（必須）
- `@~/.config/shared/ai/rules/conventions/pr-review-rule.md`（必須）
- `@~/.config/shared/ai/rules/magi/magi-report-format.md`（必須・出力スケルトン）
- 同ディレクトリの `pr-review-rule.local.md` / `review-common-rule.local.md` / `pr-feedback-registry.local.md` を Glob。存在する場合のみ Read
- `@~/.config/shared/ai/docs/feedback-log.local.md` / `feedback-index.local.md` を Glob。存在する場合のみ Read
- `melchior-1.md`, `balthasar-2.md`, `casper-3.md`（`@~/.config/shared/ai/agents/` から）

読み込んだエージェント定義は frontmatter を除いた本文を、Step 6 のプロンプトテンプレートに埋め込む。

### 4. PR 情報の取得（gh CLI 優先、フォールバックで GitHub MCP）

以下の情報を取得する:

- PR 基本情報（タイトル、本文、ブランチ名、ベースブランチ）
- 差分（diff）
- 変更ファイル一覧
- CI ステータス
- 既存レビューコメント

### 5. タスク背景の取得（任意）

PR 本文にチケットリンクまたはチケット ID がある場合、`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md`（および存在すれば `.local.md`）に従い背景・要件を取得する。

### 6. 3体を並列投入

Task ツールで 3 つの Subagent を **1つのメッセージ内で同時に** 起動する。

- **MELCHIOR-1**: `subagent_type`: `"melchior-1"`, `readonly`: `true`
- **BALTHASAR-2**: `subagent_type`: `"balthasar-2"`, `readonly`: `true`
- **CASPER-3**: `subagent_type`: `"casper-3"`, `readonly`: `true`

各ユニットへのプロンプトは以下のテンプレートに従う（Priority / 横断観点は Step 3 の `review-common-rule` / `pr-review-rule`、確信度はエージェント定義経由の `magi-unit-common-rule` に従い、ここでは重複定義しない）:

```
{Step 3 で読み込んだエージェント定義の本文（frontmatter 除く）}

## PR レビュー共通行動規範

あなたは MAGI System の PR レビューモードで動作している。

- 他のユニットの判断は知らない前提で、独立してレビューする
- 日本語で回答する（技術用語は英語可）
- **必ず変更ファイルの周辺コード・呼び出し元・呼び出し先を調査し、具体的な根拠を示すこと**
- 根拠のないレビューコメントは避ける
- 他の2体と意見が一致するであろう部分は簡潔に、自分のペルソナ固有の視点を厚く述べること
- 指摘には Priority（P0 / P1 / P2）を付与。スタイルのみの nit は出さない
- 判定: P0/P1 あり → REJECT / P2 のみ → CONDITIONAL / 指摘なし → APPROVE

---

以下の PR をレビューし、指定された出力フォーマットで回答せよ。

## PR 情報

**タイトル**: {PR タイトル}
**ブランチ**: {head} → {base}
**変更ファイル数**: {N} ファイル

### PR 本文
{PR 本文}

### CI ステータス
{CI ステータス。取得できなかった場合は「取得不可」}

### 既存レビューコメント
{既存のレビューコメント。なければ「なし」}

### 差分（diff）
{PR の diff 全文}

### タスク背景
{ticket-retrieval で取得したタスク背景。なければ「なし」}

### 参照すべきプロジェクトルール
{変更先リポジトリに該当するルール一覧を抜粋}
```

各ユニットの出力フォーマットは、エージェント定義内の出力フォーマットに加え、末尾に「指摘事項」（P0 / P1 / P2。各項目は ファイル / 現状 / 理由 / 推奨。該当なしは「_該当なし_」）を追加するよう指示する。

### 7. 回答の収集・合議判定・指摘の統合・交差分析

`@~/.config/shared/ai/rules/magi/magi-orchestration-rule.md` に従い、以下を実施する:

1. 回答の収集と成功/失敗判定
2. 判定・確信度の抽出
3. 縮退運用（必要な場合）
4. 合議判定（PR レビュー判定への変換: APPROVE→✅, CONDITIONAL→⚠️, REJECT→❌）
5. **指摘の統合**: 3体の指摘事項を重要度別に収集し、同一問題を統合（複数ユニット言及は「指摘元」を明記）。重要度が分かれた場合は最も高い重要度を採用。連番を振り直す
6. Devil's Advocate（全会一致の場合）
7. 交差分析

Step 3 でエージェント定義の読み込みに失敗した場合:

- 1 ファイルのみ失敗: 残り 2 体で縮退運用する
- 2 ファイル以上失敗: エラーを報告し、合議は実行しない

### 8. MAGI PR Review レポートの下書き作成

`@~/.config/shared/ai/rules/magi/magi-report-format.md` の「PR Review レポート」に従いレポートの**下書き**を作成する（この Step ではユーザーに提示しない）。

### 9. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する（過剰指摘の削減・誤指摘の除去を優先）。

### 10. 最終レポート出力

Step 9 で修正した MAGI PR Review レポートのみをユーザーに提示する。

---

## Guardrails

- PR URL が未指定の場合はユーザーに入力を求める
- gh CLI を優先使用する。実行できない場合は GitHub MCP で代替する
- 3 体は必ず **並列** で起動する（逐次起動しない）
- 各ユニットのプロンプトに PR の diff 全文・CI ステータス・PR レビュールールを含める
- 各ユニットは `readonly: true` で安全に調査する
- 評価・根拠・条件・提言・指摘事項は要約せずそのまま掲載する
- 指摘事項の統合では、同一問題の重複を排除し、重要度が分かれた場合は最も高い重要度を採用する
- 合議判定では `@~/.config/shared/ai/rules/magi/magi-orchestration-rule.md` に従う
- 全会一致の場合は Devil's Advocate 注記を必ず付記する
- 指摘がないカテゴリも「_該当なし_」として明示する
- ルールファイルに記載された全てのチェック項目を確認してから結果を報告する
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

応答の冒頭に「✅️: review-common-rule」と出力する。

# レビュー共通ルール

## 参照ドキュメント

### 常に適用するルール

- **`./pr-review-rule.md`** — レビュー観点・PR 出力テンプレート（必須）

### オプション（自マシン用 `.local.md`）

同一ディレクトリの次のファイルを Glob で確認し、**存在する場合のみ** Read する。無ければスキップし、エラーにしない。

- **`./review-common-rule.local.md`** — ローカル追加観点
- **`./pr-review-rule.local.md`** — 自社モノレポ向けの追加コンテキスト・重要度の詳細定義
- **`./pr-feedback-registry.local.md`** — 再発防止レジストリ（FB-00x / FB-D。存在時のみ）
- **`../../docs/feedback-log.local.md`** / **`../../docs/feedback-index.local.md`** — ローカル log / index（存在時のみ Glob）

`.md` と `.local.md` が矛盾する場合は **`.local.md` を優先**する。

### dotfiles リポジトリで AI 設定を変更するとき

ワークスペースが dotfiles（`packages/shared/ai/` を編集）の場合、上記に加え次を Read する:

- **`../meta/ai-config-rule.md`** — 3 ラッパー原則
- **`../meta/wrapper-parity-checklist.md`** — PR 前同期チェック
- **`../meta/leakage-checklist.md`** — 公開本文漏洩チェック

### 品質チェックリスト（選択適用）

変更内容に応じて必要なものだけ Read する（全部を網羅必須にしない）:

- `../checklists/code-review-checklist.md` - コードレビュー観点
- `../checklists/owasp-top10-checklist.md` - セキュリティ観点

### 詳細観点（変更内容に応じて選択適用）

- セキュリティ（認証・認可、入力バリデーション、機密情報の取り扱い）
- エラーハンドリング（例外処理、エラーメッセージ、リカバリー）
- パフォーマンス（N+1、不要なリクエスト、メモリリーク）

## 深掘り調査

サブエージェント利用の判定:

1. ユーザーが「サブエージェントを使って」「マルチエージェントで」等と明示 → 下記「サブエージェントモード」で並列起動
2. 明示がない → 親エージェントが a. / b. の観点で直接調査（デフォルト）
3. 判断できない → ユーザーに確認してから 1 または 2 を実行

### サブエージェントモード（明示時のみ）

2 種類のサブエージェントを**並列で**起動する。

### a. コードベース調査（`explore`, Worker: Composer 系）

Task ツールで `subagent_type`: `"explore"`, `model`: `"composer-2.5"`, `readonly`: `true` を起動する（`token-optimization-rule`「Task の model 必須」）。

- `.codegraph/` がある場合、構造調査は CodeGraph を優先（`token-optimization-rule`）
- 変更周辺・呼び出し元／先・既存パターンとの整合・MECE・過剰設計

### b. 品質レビュー（`quality-advisor`, Advisor: Opus 系・明示時）

チェックリストに基づく体系的レビュー。明示時はフル敵対的検証（後述）も依頼してよい。

### 直接調査モード（デフォルト）

親エージェントが上記 a. / b. と同じ観点で直接調査する。

## 重要度判定（Priority）

発見された問題を **P0 / P1 / P2** の 3 段階に分類する（P0-1, P1-1 等）。

| Priority | 意味                                                                        | 対応         |
| -------- | --------------------------------------------------------------------------- | ------------ |
| **P0**   | Critical — セキュリティ脆弱性、データ損失、クラッシュ等。マージ前に必須修正 | Must have    |
| **P1**   | High — バグ、誤動作、エッジケース、仕様不一致等。マージ前に修正すべき       | Must have    |
| **P2**   | Medium — コード品質、保守性、ベストプラクティス。検討して改善               | Nice to have |

### nit 抑制

- スタイル・好み・表記揺れのみの指摘は **原則出さない**
- 保守・可読に実害がある場合のみ **P2**
- 判断困難なら確認事項を短く書くか省略

## 薄い敵対的検証（レビュー系・既定）

課題がある前提で反証を試みる。毎回 Opus サブを必須にしない。

1. 主張・変更の「成立しない候補」だけを挙げる（良い点の列挙は任意）
2. 事実はコード／公式 docs で接地。未確認は「未検証」
3. 確信の弱い指摘は出さない（偽陽性抑制）
4. 指摘には深刻度・根拠・確度。末尾に「反証できなかった点」（なければ「なし」）
5. **採否は人間**

フル版（`quality-advisor` Opus）はサブエージェント明示時、または `/verify-adversarial`。`/review-pr-magi` の既定は Devil's Advocate のみ（`/verify-adversarial` を二重起動しない）。

**相互排他（コマンド起動のみ）**: 同一ターンで `/verify-output` と `/verify-adversarial` を**コマンドとして**重ねない。レビュー／MAGI コマンドに内蔵されたインライン再検証・薄い敵対的検証・Devil's Advocate 注記は本排他の対象外（必須 Step を省略しない）。

## 出力フォーマット

`pr-review-rule.md` のテンプレートに従う。**最低限含める骨格**:

- **対象ファイル**（またはスコープ要約）
- **チェック結果サマリー**（該当があるカテゴリ）
- **重要度別の指摘**（P0 / P1 / P2。行番号は分かる範囲で）
- **集計**
- **次のアクション**（Must have / Nice to have）

該当がないセクションは省略してよい（「全セクション必須」「該当なし埋め」はしない）。良い点は任意。

## 共通 Guardrails

- サブエージェントは `readonly: true` で調査する
- チェックリストは変更に関係する項目を優先（全部の機械網羅は求めない）
- P0 / P1 には具体的な修正方針またはコード例を添える
- スタイル・好みのみの nit は出力しない

---

## 出典

- 原典: https://www.greptile.com/docs/code-review/first-pr-review （Severity Badges: P0 / P1 / P2）
- 原著者: Greptile
- ライセンス: 原典にライセンス表記なし（製品ドキュメント）
- 扱い: Severity Badges の優先度哲学のみを蒸留・再構成した規範である
- 敵対的検証: Anthropic Adversarial verification パターン／[Loglass 解説](https://zenn.dev/loglass/articles/6aa18c80496ec6) の要件蒸留

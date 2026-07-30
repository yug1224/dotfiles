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

## depth × intensity（正本）

| depth         | 意味                                                                  | 対象コマンド例                                                      |
| ------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **AlwaysSub** | `explore-worker` + `quality-advisor` をユーザー明示なしで必ず並列起動 | `/review-pr` `/review-diff` `/review-pr-linus` `/review-diff-linus` |
| **Magi3**     | MAGI 3体のみ（Advisor 不使用）                                        | `/review-pr-magi`                                                   |
| **OptIn**     | ユーザー明示時のみサブ起動                                            | `/verify-output` の再検証サブ、`/suggest-plan` の Advisor 等        |

| intensity     | 意味                   | 実行者                                                                       |
| ------------- | ---------------------- | ---------------------------------------------------------------------------- |
| **Thin**      | 薄い敵対的検証（後述） | 親エージェント（非 Linus レビュー系の既定）                                  |
| **Full**      | フル敵対的検証         | `quality-advisor`（`/review-*-linus`）または `/verify-adversarial`（明示時） |
| **DevilOnly** | Devil's Advocate のみ  | `/review-pr-magi` 既定                                                       |

## レビュー系コマンド共通手順（AlwaysSub 対象）

**対象コマンド**: `/review-pr` `/review-diff` `/review-pr-linus` `/review-diff-linus`

各コマンドは Step 0（トレース）と Step 2（差分取得）のみ固有。Step 1 および Step 3–7 は本節に従う。

### Step 1 ルール読込（共通）

1. `./review-common-rule.md` を Read（必須）
2. `./pr-review-rule.md` を Read（必須）
3. **Linus 系コマンド**（`/review-pr-linus` `/review-diff-linus`）のときのみ、コマンドの Step 1 で `./linus-review-rule.md` を追加 Read
4. 同ディレクトリの `review-common-rule.local.md` / `pr-review-rule.local.md` / `pr-feedback-registry.local.md` を Glob。存在する場合のみ Read
5. `../../docs/feedback-log.local.md` / `../../docs/feedback-index.local.md` を Glob。存在する場合のみ Read

### Step 3 コンテキスト収集

- **対象リポジトリのルール照合**: `pr-review-rule.md` の「コンテキスト」に従い、対象リポジトリのルール・ドキュメントを動的に参照する
- **チケット**: 引数または PR 本文にチケット ID / URL がある場合のみ、`ticket-retrieval-rule.md`（および存在すれば `.local.md`）に従い背景・要件を取得する

### Step 4 変更コードの深掘り調査

本ファイルの「深掘り調査（レビュー系・常時）」に従い、`explore-worker` と `quality-advisor` を**必ず並列**起動する。

| コマンド種別 | intensity | 敵対的検証の実行者                                                                                      |
| ------------ | --------- | ------------------------------------------------------------------------------------------------------- |
| 非 Linus     | **Thin**  | 親エージェント（薄い敵対的検証）                                                                        |
| Linus 系     | **Full**  | `quality-advisor`（フル敵対的検証を必須依頼。Linus 口調・ペルソナは付けない。ペルソナは親エージェント） |

### Step 5 重要度判定と下書きレポート作成

「重要度判定」に従い重要度を付与し、下記**出力フォーマット**に従ってレビューレポートの**下書き**を作成する（この Step ではユーザーに提示しない）。

| コマンド種別 | 出力フォーマット                                                         |
| ------------ | ------------------------------------------------------------------------ |
| 非 Linus     | `pr-review-rule.md` のテンプレート（本ファイル「出力フォーマット」参照） |
| Linus 系     | `linus-review-rule.md` の出力フォーマット                                |

### Step 6 出力の再検証（必須）

`output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。**省略禁止**。

### Step 7 最終レポート出力

Step 6 で修正したレビューレポートのみをユーザーに提示する。**省略禁止**。

## 深掘り調査（レビュー系・常時）

**対象**: `/review-pr` `/review-diff` `/review-pr-linus` `/review-diff-linus` のみ。ユーザー明示なしで次の 2 種類を**必ず並列**起動する。

**対象外**: `/review-pr-magi` `/review-blog` `/suggest-plan` `/verify-output` `/verify-adversarial` 等は本節の対象外（各コマンド・ルールの定義に従う）。

### a. コードベース調査（`explore-worker`, Worker: Composer 系・readonly）

Task ツールで `subagent_type`: `"explore-worker"`, `model`: `"composer-2.5"`, `readonly`: `true` を起動する（`agent-delegation-rule`「Task の model 必須」）。

- `.codegraph/` がある場合、構造調査は CodeGraph を優先（`codegraph-rule`）
- 変更周辺・呼び出し元／先・既存パターンとの整合・MECE・過剰設計

### b. 品質レビュー（`quality-advisor`, Advisor: Grok 系）

チェックリストに基づく体系的レビュー。敵対の厚み（薄い／フル）は次節「敵対的検証」に従う。

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

## 敵対的検証

### 薄い敵対的検証（非 Linus レビュー系・既定）

`/review-pr` `/review-diff` では**親エージェント**が実行する（Linus 版では親の薄い敵対は重ねない）。

1. 主張・変更の「成立しない候補」だけを挙げる（良い点の列挙は任意）
2. 事実はコード／公式 docs で接地。未確認は「未検証」
3. 確信の弱い指摘は出さない（偽陽性抑制）
4. 指摘には深刻度・根拠・確度。末尾に「反証できなかった点」（なければ「なし」）
5. **採否は人間**

### フル敵対的検証

次のいずれかで `quality-advisor` にフル敵対的検証を**必須依頼**する（Linus 口調・ペルソナは載せない）:

- `/review-pr-linus` `/review-diff-linus` の Step 4（常時並列の `quality-advisor` プロンプト）
- `/verify-adversarial`（ユーザーが明示起動。既定は親の薄い敵対、サブエージェント明示時は `quality-advisor` でフル）

`/review-pr-magi` の既定は Devil's Advocate のみ（`/verify-adversarial` を二重起動しない）。

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

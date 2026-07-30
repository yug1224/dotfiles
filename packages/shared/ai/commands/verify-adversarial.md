直前の assistant 応答または `@` 添付を、**課題あり前提**で敵対的に検証する。`/verify-output` の 3 軸（誤検証・間違い・ヌケモレ）より攻撃的で、反証に失敗した点を明示する。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/review-common-rule.md`（「敵対的検証」— 薄い敵対／フル敵対）

**Input**: `/verify-adversarial` の後に続く引数は任意。未指定時は直前 assistant 出力を対象とする。`@` 添付があれば併せる。

**使用例**:

- `/verify-adversarial`
- `/verify-adversarial`（直前のプラン・レビュー・説明を対象）

**関連**: 日常の再検証は `/verify-output`（[verify-output.md](./verify-output.md) → `output-verification-rule.md` の 3 軸）。敵対的・深掘りが必要なときのみ本コマンドを使う。

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /verify-adversarial` と出力する。

### 1. 敵対的検証ルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/review-common-rule.md` を Read（必須）— 「敵対的検証」節
2. 同ディレクトリの `review-common-rule.local.md` を Glob。存在する場合のみ Read

### 2. 実行モードの選択

| 条件                                           | 動作                                                                                       |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| ユーザーが「サブエージェントを使って」等と明示 | Task で `quality-advisor`（Grok 系）を **`readonly: true`** で起動し、フル敵対的検証を依頼 |
| 上記以外（既定）                               | 親エージェントが `review-common-rule` の「薄い敵対的検証」手順を直接実行                   |

### 3. 敵対的検証の実行

1. 対象テキストの主張・変更の「成立しない候補」を列挙
2. 事実は Read / Grep / 公式 docs で接地。未確認は「未検証」
3. 確信の弱い指摘は出さない
4. 採否は人間（修正版の自動上書きはしない。指摘レポートを出す）

### 4. 出力

各行または各指摘を次の形式で出す:

| 指摘 | 深刻度 | 根拠 | 確度 |
| ---- | ------ | ---- | ---- |

末尾に必須:

- **反証できなかった点**: 列挙（なければ `なし`）

深刻度は `review-common-rule` の P0 / P1 / P2 または High / Medium / Low でよい（対象に合わせて統一）。

---

## Guardrails

- コードファイルの書き換えは行わない（検証レポートのみ）
- サブエージェントは `readonly: true`
- **相互排他**: 同一ターンで `/verify-output` と**コマンドとして**併用しない（正本: `review-common-rule`）。レビュー／MAGI 内蔵のインライン再検証・Devil's Advocate は対象外。それら実施直後に本コマンドを重ねる場合はユーザー明示時のみ
- 良い点の列挙は任意（偽陽性抑制を優先）

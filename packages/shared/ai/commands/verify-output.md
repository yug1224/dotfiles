直前の AI 応答（プラン・説明・レビューレポート等）を再検証し、誤検証・間違い・ヌケモレを修正した最終版を出力する。各コマンドのインライン再検証と同じ正本手順の単体版。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/output-verification-rule.md`

**Input**: `/verify-output` の後に続く引数は任意。チケット ID またはチケット URL（直前応答の要件照合用）。

**使用例**:

- `/verify-output`
- `/verify-output PROJ-1234`
- `/verify-output https://github.com/owner/repo/issues/123`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /verify-output` と出力する。

### 1. ルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read（必須）
2. 同ディレクトリの `output-verification-rule.local.md` を Glob。存在する場合のみ Read

### 2. コンテキスト収集

- 直前の user メッセージ、`@` 添付を考慮する
- 引数にチケット ID / URL がある場合のみ、`@~/.config/shared/ai/rules/conventions/ticket-retrieval-rule.md` に従い背景を取得する

### 3. スタンドアロン再検証の実行

`output-verification-rule.md` の **「スタンドアロン再検証」**に従い、直前 assistant メッセージを検証・修正する。

---

## Guardrails

- コードファイルの書き換えは行わない
- `output-verification-rule.md` の共通 Guardrails を遵守する

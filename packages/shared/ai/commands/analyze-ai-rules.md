`/analyze-ai-config rules` の固定エイリアス。手順の正本は [`analyze-ai-config.md`](./analyze-ai-config.md)。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/ai-config-inventory-rule.md`

**Input**: `/analyze-ai-rules` の後に続く引数は任意（id 部分一致・`local`）。

**使用例**: `/analyze-ai-rules` / `/analyze-ai-rules token-optimization` / `/analyze-ai-rules local`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /analyze-ai-rules` と出力する（`✅️: ai-config-inventory-rule` は出さない）。

### 1–3. 委譲

[`analyze-ai-config.md`](./analyze-ai-config.md) を Read し、種別を **`rules` に固定**して同 Steps を実行する。追加引数があればフィルタとして適用する。

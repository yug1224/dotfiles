`/analyze-ai-config agents` の固定エイリアス。手順の正本は [`analyze-ai-config.md`](./analyze-ai-config.md)。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/ai-config-inventory-rule.md`

**Input**: `/analyze-ai-agents` の後に続く引数は任意（agent id 部分一致）。

**使用例**: `/analyze-ai-agents` / `/analyze-ai-agents quality-advisor`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /analyze-ai-agents` と出力する（`✅️: ai-config-inventory-rule` は出さない）。

### 1–3. 委譲

[`analyze-ai-config.md`](./analyze-ai-config.md) を Read し、種別を **`agents` に固定**して同 Steps を実行する。追加引数があればフィルタとして適用する。

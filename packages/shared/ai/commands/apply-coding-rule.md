コーディングルール（AIエージェント行動ルール & 一般規約）を読み込み、以降の作業に適用する。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/coding-rule.local.md`（存在する場合）

**使用例**:

- `/apply-coding-rule`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `Applied: /apply-coding-rule` と出力する。

### 1. ルールの読み込み

`@~/.config/shared/ai/rules/conventions/coding-rule.local.md` を Glob で確認する。

- **存在する場合**: Read して以降の作業に適用する
- **存在しない場合**: 「ローカルコーディングルール（`coding-rule.local.md`）が未設定です」と伝え、汎用のベストプラクティスのみで続行するかユーザーに確認する

### 2. ルールの適用確認

読み込んだルールの概要をユーザーに提示し、以降のコーディング作業に適用することを宣言する。

---

## Guardrails

- プロジェクト固有の `.cursor/rules/` がある場合はそちらも尊重する
- ルールの内容はそのまま適用し、勝手に解釈を変えない

日本語技術文書規範（JTW）を読み込み、指定スライスで以降の文章・md 作業に適用する。ファイルの書き換え・推敲は行わない（適用宣言のみ）。

**参照ルール**: `@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md`（既定スライス `tech-doc-lite`）

**Input**: `/apply-japanese-tech-writing` の後に続く引数は適用スライス（任意）。許可値は `tech-doc-lite` / `blog-base` / `full`。未指定・不正は `tech-doc-lite`。

**使用例**:

- `/apply-japanese-tech-writing`
- `/apply-japanese-tech-writing tech-doc-lite`
- `/apply-japanese-tech-writing blog-base`
- `/apply-japanese-tech-writing full`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /apply-japanese-tech-writing` と出力する。

### 1. スライスの決定

引数を解析する。

- 引数が `tech-doc-lite` / `blog-base` / `full` のいずれか → それを採用
- 引数なし → `tech-doc-lite`
- 上記以外 → 一言して `tech-doc-lite` に倒す

### 2. ルールの読み込み

`@~/.config/shared/ai/rules/writing/japanese-tech-writing-rule.md` を Read する。適用範囲は Step 1 で決めたスライスに従う。

### 3. 適用の宣言

読み込んだ規範の概要（スライス名・適用範囲の要約）をユーザーに提示し、以降の文章・md 作業にそのスライスで適用することを宣言する。

- blog 記事の構成・文体まで含めたい場合は `/plan-blog`（`writing-style-rule` Override）を案内する
- CRW（認知リズム）は本コマンドでは読み込まない

---

## Guardrails

- ルールの内容はそのまま適用し、勝手に解釈を変えない
- OpenSpec / PR / 開発ログ等の**構造テンプレは優先**する。JTW は言い回し（空句・冗長・根拠なき断言の抑制など、スライス範囲）に限定する
- blog コンテキストで `writing-style-rule` がある場合は Override / `blog-base` が優先する（引数に `full` を付けても blog Override が勝つ）
- ファイルの自動書き換え・推敲差分の適用はしない
- `cognitive-rhythm-writing-rule` は読み込まない

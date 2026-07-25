skills / rules / commands / agents を横断し、global・shared・project の AI 設定を棚卸しする。**調査のみ**（ファイル変更なし）。種別単体は本コマンドの引数、または薄いエイリアス（`/analyze-ai-skills` 等）で絞り込む。

**参照ルール**: `@~/.config/shared/ai/rules/conventions/ai-config-inventory-rule.md`

**Input**: `/analyze-ai-config` の後に続く引数は任意。

| 引数（先頭トークン）                       | 動作                                            |
| ------------------------------------------ | ----------------------------------------------- |
| （なし） / `all` / `config`                | 4 種別すべて                                    |
| `skills` / `rules` / `commands` / `agents` | 当該種別のみ                                    |
| `local`                                    | 全種別のうち `.local.*` を強調・絞り込み        |
| その他                                     | 全種別を出したうえで id/path 部分一致で絞り込み |

**使用例**:

- `/analyze-ai-config`
- `/analyze-ai-config rules`
- `/analyze-ai-config local`
- `/analyze-ai-config token-optimization`

---

## Steps

### 0. トレース（必須）

応答の冒頭に `✅️: /analyze-ai-config` と出力する（ルール由来の `✅️: ai-config-inventory-rule` は出さない。順序は inventory ルール「自己申告」節）。

### 1. インベントリルールの読み込み

1. `@~/.config/shared/ai/rules/conventions/ai-config-inventory-rule.md` を Read（必須）
2. 同ディレクトリの `ai-config-inventory-rule.local.md` を Glob。存在する場合のみ Read

### 2. 種別の決定と棚卸し

引数先頭が `skills` / `rules` / `commands` / `agents` ならその種別のみ。それ以外（なし・`all`・`config`・`local`・任意キーワード）は **skills → rules → commands → agents** の順で全種別。

`ai-config-inventory-rule.md` の「探索パス」「収集手順」に従い Glob / Read する。

### 3. 出力

同ルールの「出力フォーマット」に従う。件数サマリーは対象種別のみ（全種別時は 4 行）。

---

## Guardrails

- `ai-config-inventory-rule.md` の Guardrails を遵守する
- エイリアス `/analyze-ai-{skills,rules,commands,agents}` は本コマンドの kind 固定呼び出しと同等

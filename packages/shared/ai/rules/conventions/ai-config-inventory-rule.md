応答の冒頭に「✅️: ai-config-inventory-rule」と出力する。

# AI 設定インベントリルール

skills / rules / commands / agents の配置を **global（ホスト）・shared（dotfiles 展開）・project（cwd）** で棚卸しする正本。`/analyze-ai-*` コマンドは本ルールを参照し、手順を重複記載しない。

## 自己申告（`✅️:`）

| 起動経路                      | 冒頭に出すもの                                                                                             |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `/analyze-ai-*` コマンド経由  | **コマンドのみ**（例: `✅️: /analyze-ai-config`）。本ルールの `✅️: ai-config-inventory-rule` は**出さない** |
| ルールを `@` / 明示 Read のみ | `✅️: ai-config-inventory-rule`                                                                             |

コマンドとルールの ✅️ を同一応答で二重に出さない。

---

## スコープ定義

| スコープ    | 意味                           | 典型パス                                                                       |
| ----------- | ------------------------------ | ------------------------------------------------------------------------------ |
| **global**  | ユーザーホーム配下のツール設定 | `~/.cursor/...`, `~/.claude/...`                                               |
| **shared**  | dotfiles `make mise` 展開先    | `~/.config/shared/ai/...`                                                      |
| **project** | ワークスペース（`<cwd>`）直下  | `<cwd>/.cursor/...`, `<cwd>/.claude/...`, `<cwd>/AGENTS.md`, `<cwd>/CLAUDE.md` |

`<cwd>` は実行時のワークスペースルートとする。

---

## 探索パス（種別ごと）

### skills

| スコープ | パス                                  | 備考                                    |
| -------- | ------------------------------------- | --------------------------------------- |
| global   | `~/.cursor/skills/**/SKILL.md`        | Cursor ユーザースキル                   |
| global   | `~/.cursor/skills-cursor/**/SKILL.md` | Cursor 同梱スキル（読取のみ・編集禁止） |
| project  | `<cwd>/.cursor/skills/**/SKILL.md`    | 業務リポジトリ skill                    |

shared には skills を置かない（[templates/skills/README.md](../../docs/templates/skills/README.md)）。

### rules

| スコープ | パス                                | メタデータ取得元                                   |
| -------- | ----------------------------------- | -------------------------------------------------- |
| global   | `~/.cursor/rules/**/*.mdc`          | frontmatter: `description`, `globs`, `alwaysApply` |
| global   | `~/.claude/rules/**/*.md`           | `@import` 先・本文先頭                             |
| shared   | `~/.config/shared/ai/rules/**/*.md` | 本文 1 行目 `✅️:`、要約は見出し直下                |
| project  | `<cwd>/.cursor/rules/**/*.mdc`      | 同上（Cursor）                                     |
| project  | `<cwd>/.claude/rules/**/*.md`       | 同上（Claude）                                     |

`.local.md` / `.local.mdc` は **local: yes**。gitignore 対象でも Glob で列挙する。

### commands

| スコープ | パス                                | メタデータ取得元                      |
| -------- | ----------------------------------- | ------------------------------------- |
| global   | `~/.cursor/commands/*.md`           | frontmatter: `name`, `description`    |
| global   | `~/.claude/commands/*.md`           | 同上                                  |
| shared   | `~/.config/shared/ai/commands/*.md` | 先頭要約行・Step 0 の `/command-name` |
| project  | `<cwd>/.cursor/commands/*.md`       | frontmatter                           |
| project  | `<cwd>/.claude/commands/*.md`       | frontmatter                           |

### agents

| スコープ | パス                              | メタデータ取得元                                      |
| -------- | --------------------------------- | ----------------------------------------------------- |
| global   | `~/.cursor/agents/*.md`           | frontmatter: `name`, `description`, `model`（あれば） |
| global   | `~/.claude/agents/*.md`           | 同上                                                  |
| shared   | `~/.config/shared/ai/agents/*.md` | 見出し・役割要約                                      |
| project  | `<cwd>/.cursor/agents/*.md`       | frontmatter                                           |
| project  | `<cwd>/.claude/agents/*.md`       | frontmatter                                           |

### エントリポイント（横断）

| ファイル          | スコープ | 用途                            |
| ----------------- | -------- | ------------------------------- |
| `<cwd>/AGENTS.md` | project  | Cursor / 共通エージェント規約   |
| `<cwd>/CLAUDE.md` | project  | Claude エントリ・`@import` 一覧 |

存在する場合のみ要約行を 1 件として表に含める（id は `AGENTS.md` / `CLAUDE.md`）。

---

## 収集手順

1. 上表のパスを **Glob**（存在しないディレクトリはスキップ、エラーにしない）
2. 各ファイルを **Read** し id・説明・メタデータを抽出
3. **id の決め方**:
   - rules（shared `.md`）: basename から `.md` / `.local.md` を除く（例: `token-optimization-rule`）
   - rules（`.mdc`）: basename から `.mdc` / `.local.mdc` を除く
   - commands: frontmatter `name:` または basename（拡張子除く）
   - skills: 親ディレクトリ名（= `name:` と一致想定）
   - agents: frontmatter `name:` または basename
4. **衝突検出**: 同一 id が複数スコープ／パスに存在する場合、`collision` 列に `global+project` 等を記載
5. **ラッパー対応**: Cursor `.mdc` と shared `~/.config/shared/ai/rules/...` が `@` で対応する場合、collision に `wrapper↔shared` と注記

---

## 出力フォーマット

### 1. 件数サマリー（必須・先頭）

```
## サマリー
- skills: N（global G / project P）
- rules: N（global G / shared S / project P / local L）
- commands: N（…）
- agents: N（…）
```

単体コマンド（`/analyze-ai-skills` 等）は **当該種別の行のみ** でよい。

### 2. 種別テーブル（必須）

| path | id  | description / alwaysApply / globs / model | scope | local | collision |
| ---- | --- | ----------------------------------------- | ----- | ----- | --------- |

- **description / …**: 取れる項目だけ `/` 区切りで併記（例: `トークン節約 / alwaysApply:true`）
- **scope**: `global` | `shared` | `project`
- **local**: `yes`（`.local.*`）| `no`
- **collision**: 衝突なしは `-`。あれば短く（例: `project overrides global`, `wrapper↔shared`）

### 3. 所見（任意・最大 5 行）

重複・未ラップ・孤立 shared・project のみ存在等を簡潔に。

---

## サブエージェント

- 明示がなくても親エージェントが直接 Glob / Read で実施（デフォルト）
- ユーザーが「サブエージェントを使って」等と明示した場合のみ `explore`（`readonly: true`）を並列起動可

---

## Guardrails

- **readonly**: ファイルの作成・変更・削除は行わない
- `skills-cursor` は列挙のみ（編集・削除提案しない）
- 存在しないパスは失敗扱いにしない
- 本文の機密（トークン・社内 URL）は出力に含めない
- dotfiles リポジトリで `packages/shared/ai/` を編集している場合、インベントリ結果に **ラッパー未生成** の shared 原本があれば所見に 1 行触れる

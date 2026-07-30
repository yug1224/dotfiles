応答の冒頭に「✅️: agent-delegation-rule」と出力する。

# エージェント委譲（運用）

親 Orchestrator が Task で Worker に委譲するときのゲート・モデル pin の正本。Shell / Read 等のトークン節約は `token-optimization-rule`（always-on 要約）。

## 委譲ゲート（MUST）

親が高コストモデルのまま広域調査・複数ファイル書込を続けることは**禁止**。閾値を超えたら Task で Worker に委譲し、**`model` 省略禁止**（Cursor: `composer-2.5`、Claude Code: `sonnet`）。**`composer-2.5-fast` 禁止**。親モデル継承に頼らない。Advisor / MAGI はこのゲート対象外。

| 条件                                                                                             | 委譲先（Task）                                                |
| ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| 1〜数行、ユーザー貼付済み、直前ターンで得た要約の続き・統合・ユーザー返答（WebFetch し直さない） | **親が直接**                                                  |
| 外部 URL の WebFetch（同等の URL 取得含む）が主目的、または URL が 2 件以上                      | `general-worker` + `model: composer-2.5` + `readonly: true`   |
| 構造・意味・影響範囲・既存パターン調査（明示不要）                                               | `explore-worker` + `model: composer-2.5` + `readonly: true`   |
| 新規機能、または変更見込み 3 ファイル以上、またはまとまったテスト                                | `build-worker` + `model: composer-2.5`                        |
| ADR / OpenAPI / スキーマ設計文書等の書込                                                         | `design-worker` + `model: composer-2.5`                       |
| 専門が曖昧な複数ステップ（迷ったらこれ。直実行しない）                                           | `general-worker` + `model: composer-2.5`                      |
| 軽いファイル発見のみ                                                                             | 組み込み `explore` + `model: composer-2.5` + `readonly: true` |

専門が明確なら `general-worker` より `explore-worker` / `build-worker` / `design-worker` を優先する。ライブラリ公式 API・フレームワーク仕様は Context7 / `docs-researcher`（WebFetch と混同しない）。

## Task の model 必須（作業系）

Cursor 製品の「`model` はユーザー明示時のみ渡す」は **提案系 Advisor（Grok）に従う**。次の作業系 `subagent_type` では **例外として `model` を必ず渡す**。省略すると親が高コストモデルのとき作業系もそれになりうる。`claude-opus-*` を作業系に渡さない。**`composer-2.5-fast` は使わない**。親モデル継承に頼らない。

| subagent_type                                          | Cursor の Task `model`（必須）      | 備考                                                   |
| ------------------------------------------------------ | ----------------------------------- | ------------------------------------------------------ |
| `build-worker` / `design-worker` / `general-worker`    | `composer-2.5`                      | リポジトリ書込。frontmatter pin だけでは不足しうる     |
| `explore-worker`                                       | `composer-2.5`                      | 品質・意味・影響範囲の調査（readonly。`[fast=false]`） |
| `melchior-1` / `balthasar-2` / `casper-3`              | `composer-2.5`                      | MAGI                                                   |
| `explore`                                              | `composer-2.5`                      | 軽いファイル発見・広域探索のみ                         |
| `generalPurpose`                                       | `composer-2.5`                      | **互換・非推奨**。可能な限り `general-worker` を使う   |
| `docs-researcher` / `shell`                            | `composer-2.5`                      | ドキュメント調査・コマンド実行委譲                     |
| `design-advisor` / `build-advisor` / `quality-advisor` | 省略可（agent frontmatter の Grok） | 提案のみ。書込しない。Claude Code は `sonnet`          |

起動例（Task ツール）:

- **explore-worker**: `subagent_type`: `"explore-worker"`, `model`: `"composer-2.5"`, `readonly`: `true`
- **explore**: `subagent_type`: `"explore"`, `model`: `"composer-2.5"`, `readonly`: `true`（軽いファイル発見のみ）
- **general-worker**: `subagent_type`: `"general-worker"`, `model`: `"composer-2.5"`（専門が曖昧な複数ステップのフォールバック）
- **general-worker（URL 収集のみ）**: `subagent_type`: `"general-worker"`, `model`: `"composer-2.5"`, `readonly`: `true`（WebFetch 等。生本文は親へ返さない）
- **generalPurpose**: `subagent_type`: `"generalPurpose"`, `model`: `"composer-2.5"`（互換・非推奨。可能な限り `general-worker`）
- **build-worker**: `subagent_type`: `"build-worker"`, `model`: `"composer-2.5"`
- **design-worker**: `subagent_type`: `"design-worker"`, `model`: `"composer-2.5"`
- **MAGI**: `subagent_type`: `"melchior-1"` / `"balthasar-2"` / `"casper-3"`, `model`: `"composer-2.5"`, `readonly`: `true`（各 1 体ずつ並列）
- **docs-researcher** / **shell**: `model`: `"composer-2.5"`

### Task 自己申告（任意・推奨）

Worker を Task 起動した直後、親は短く `✅️: Task <subagent_type> composer-2.5`（Claude Code は `sonnet`）と出力してよい。観測用であり監査証跡ではない。

Cursor では上表の Composer pin を使う。Claude Code は Composer 非対応のため、作業系は Task の `model` に **`sonnet`** を渡す（Worker / MAGI / Advisor はラッパー `sonnet` と整合。親の高コストモデル継承を避ける。haiku は使わない）。

## コード構造調査との用途分担

構造・フロー・影響範囲（「X はどう動くか」「誰が呼ぶか」）の詳細優先順位は `@~/.config/shared/ai/rules/conventions/codegraph-rule.md` を参照。概要: **`explore-worker`** = 品質・意味・影響範囲の調査（readonly）、組み込み **`explore`** = 軽いファイル発見のみ、**CodeGraph** = グラフ済み構造の surgical context。Grep ループと競合ではなく用途分担する。

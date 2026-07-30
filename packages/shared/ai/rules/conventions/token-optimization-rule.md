応答の冒頭に「✅️: token-optimization-rule」と出力する（コマンド／明示適用時。always-on 単独での毎応答冒頭は不要）。

# トークン節約（エージェント運用）

全ワークスペース・全セッションでコンテキスト消費を抑える。Shell 出力は RTK hook（`guard → RTK`）が自動圧縮する。詳細は `@~/.config/shared/ai/docs/RTK.md`。

## PR / diff

1. まず `gh pr diff --name-only` または `gh pr view --json files` でスコープを確定する
2. 対象パスのみ `git diff <base>...HEAD -- <path>`（Shell 経由 → RTK）
3. フル `gh pr diff` は最終手段

## Shell（RTK 経由を優先）

| 避ける                     | 推奨                                                                                                                  |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| 広い `find` / 深い `tree`  | `Glob`、浅い `tree`、インデックスなし・ファイル発見目的の広域探索は `Task(subagent_type=explore, model=composer-2.5)` |
| 広い `grep -n` / `grep -r` | `rg` + パス・行数制限                                                                                                 |
| `cat` でファイル全量       | Read（offset/limit）または `head` / `sed -n`                                                                          |
| `git -C /path ...`         | リポジトリの cwd を合わせて `git`                                                                                     |
| Bash に `#` コメントのみ   | 説明は応答本文へ。実行が必要なコマンドだけ送る                                                                        |

## Read / Grep / Search

- 500 行超は offset/limit 付き Read、または Shell `rg` / `head`
- ライブラリ API・フレームワーク仕様は **Context7**（`resolve-library-id` → `query-docs`）。`get-library-docs` の全文取得は避ける
- ライブラリ調査は `Task(subagent_type=docs-researcher, model=composer-2.5)`、`docs-researcher` subagent、または `/docs` を優先

## 委譲（MUST・要約）

親が高コストモデルのまま広域調査・複数ファイル書込を続けることは**禁止**。閾値超えは Task で Worker に委譲し **`model` 省略禁止**（Cursor: `composer-2.5`、Claude Code: `sonnet`。`composer-2.5-fast` 禁止）。Advisor / MAGI はゲート対象外。

| 条件（要約）                                 | 委譲先             |
| -------------------------------------------- | ------------------ |
| 1〜数行・貼付済み・要約の続き                | 親が直接           |
| 外部 URL 取得が主目的 / 複数 URL             | `general-worker`   |
| 構造・意味・影響範囲調査                     | `explore-worker`   |
| 新規機能 / 3 ファイル以上 / まとまったテスト | `build-worker`     |
| ADR / OpenAPI 等の設計書込                   | `design-worker`    |
| 専門曖昧・複数ステップ                       | `general-worker`   |
| 軽いファイル発見のみ                         | 組み込み `explore` |

ゲート全文・Task `model` 必須表・起動例は `@~/.config/shared/ai/rules/conventions/agent-delegation-rule.md` を Read。

## コード構造調査

構造・フロー・影響範囲は `@~/.config/shared/ai/rules/conventions/codegraph-rule.md` に従い CodeGraph を優先。`explore-worker`（品質調査）・組み込み `explore`（軽い発見）・CodeGraph（グラフ済み構造）の用途分担。インデックスなしは Grep / Read / `Task(explore-worker, model=composer-2.5)`。詳細表は `codegraph-rule`。

## MCP

- WebFetch 主目的・複数 URL / 長文 → `Task(general-worker, model=composer-2.5, readonly: true)`（構造化要約のみ）
- ライブラリ docs → Context7 / `docs-researcher`（WebFetch 不可）
- 構造・フロー → `.codegraph/` ありなら CodeGraph `codegraph_explore`
- PR レビュー → `gh` + Shell（RTK）、MCP `get_file_contents` 連打より優先

## 計測（開発者向け）

`@~/.config/shared/ai/docs/RTK.md`（`rtk discover --all --since 7`、`rtk gain --history`）。

応答の冒頭に「✅️: token-optimization-rule」と出力する。

# トークン節約（エージェント運用）

全ワークスペース・全セッションでコンテキスト消費を抑える。Shell 出力は RTK hook（`guard → RTK`）が自動圧縮する。詳細は `@~/.config/shared/ai/docs/RTK.md`。

## PR / diff

1. まず `gh pr diff --name-only` または `gh pr view --json files` でスコープを確定する
2. 対象パスのみ `git diff <base>...HEAD -- <path>`（Shell 経由 → RTK）
3. フル `gh pr diff` は最終手段

## Shell（RTK 経由を優先）

| 避ける                     | 推奨                                                                                |
| -------------------------- | ----------------------------------------------------------------------------------- |
| 広い `find` / 深い `tree`  | `Glob`、浅い `tree`、インデックスなし・ファイル発見目的の広域探索は `Task(explore)` |
| 広い `grep -n` / `grep -r` | `rg` + パス・行数制限                                                               |
| `cat` でファイル全量       | Read（offset/limit）または `head` / `sed -n`                                        |
| `git -C /path ...`         | リポジトリの cwd を合わせて `git`                                                   |
| Bash に `#` コメントのみ   | 説明は応答本文へ。実行が必要なコマンドだけ送る                                      |

## Read / Grep / Search（ネイティブツール）

- 500 行超は offset/limit 付き Read、または Shell `rg` / `head`
- ライブラリ API・フレームワーク仕様はソース直読より **Context7**（`resolve-library-id` → `query-docs`）。`get-library-docs` の全文取得は避ける
- インデックスなし、または未知パターンのファイル発見が目的の広域探索（3 ファイル以上）は `Task(subagent_type=explore)` に委譲
- ライブラリ調査は `docs-researcher` subagent または `/docs` を優先

## コード構造調査

構造・フロー・影響範囲（「X はどう動くか」「誰が呼ぶか」）は `@~/.config/shared/ai/rules/conventions/codegraph-rule.md` に従い CodeGraph を優先する。`Task(explore)` や Grep ループと競合ではなく用途分担（explore = ファイル発見、CodeGraph = グラフ済み構造の surgical context）。

| 条件                                              | 優先ツール                                                       |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| `.codegraph/` あり                                | MCP `codegraph_explore` → CLI `codegraph explore`                |
| マルチルートの別ルート（対象ルートに index あり） | MCP `projectPath` または `cd` + CLI                              |
| インデックスなし                                  | Grep / Read / `Task(explore)`（init は提案のみ、自動実行しない） |
| 文字列横断検索                                    | `rg` / Grep                                                      |
| ライブラリ API                                    | Context7                                                         |

## MCP

- 構造・フロー調査: `.codegraph/` ありなら **CodeGraph** `codegraph_explore`（読み取り専用、allowlist 済み）
- PR レビュー: GitHub MCP の `get_file_contents` 連打より `gh` + Shell（RTK）
- Playwright `browser_snapshot` は E2E 時のみ。ドメイン固有の例外は `*.local.md` にのみ書く（本ルールには列挙しない）

## 計測（開発者向け）

```bash
rtk discover --all --since 7   # 必ず --all（CWD で sessions が変わる）
rtk gain --history
```

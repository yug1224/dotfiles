応答の冒頭に「Applied: token-optimization-rule」と出力する。

# トークン節約（エージェント運用）

全ワークスペース・全セッションでコンテキスト消費を抑える。Shell 出力は RTK hook（`guard → RTK`）が自動圧縮する。詳細は `@~/.config/shared/ai/docs/RTK.md`。

## PR / diff

1. まず `gh pr diff --name-only` または `gh pr view --json files` でスコープを確定する
2. 対象パスのみ `git diff <base>...HEAD -- <path>`（Shell 経由 → RTK）
3. フル `gh pr diff` は最終手段

## Shell（RTK 経由を優先）

| 避ける                     | 推奨                                              |
| -------------------------- | ------------------------------------------------- |
| 広い `find` / 深い `tree`  | `Glob`、浅い `tree`、大規模探索は `Task(explore)` |
| 広い `grep -n` / `grep -r` | `rg` + パス・行数制限                             |
| `cat` でファイル全量       | Read（offset/limit）または `head` / `sed -n`      |
| `git -C /path ...`         | リポジトリの cwd を合わせて `git`                 |
| Bash に `#` コメントのみ   | 説明は応答本文へ。実行が必要なコマンドだけ送る    |

## Read / Grep / Search（ネイティブツール）

- 500 行超は offset/limit 付き Read、または Shell `rg` / `head`
- ライブラリ API・フレームワーク仕様はソース直読より **Context7**（`resolve-library-id` → `query-docs`）。`get-library-docs` の全文取得は避ける
- 3 ファイル以上の広域探索は `Task(subagent_type=explore)` に委譲
- ライブラリ調査は `docs-researcher` subagent または `/docs` を優先

## MCP

- PR レビュー: GitHub MCP の `get_file_contents` 連打より `gh` + Shell（RTK）
- Playwright `browser_snapshot` は E2E 時のみ

## 計測（開発者向け）

```bash
rtk discover --all --since 7   # 必ず --all（CWD で sessions が変わる）
rtk gain --history
```

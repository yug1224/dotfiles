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

## Read / Grep / Search（ネイティブツール）

- 500 行超は offset/limit 付き Read、または Shell `rg` / `head`
- ライブラリ API・フレームワーク仕様はソース直読より **Context7**（`resolve-library-id` → `query-docs`）。`get-library-docs` の全文取得は避ける
- インデックスなし、または未知パターンのファイル発見が目的の広域探索（3 ファイル以上）は `Task(subagent_type=explore, model=composer-2.5)` に委譲（下表参照）
- まとまった**実装・テストの書込**は親直実行より `Task(subagent_type=build-worker, model=composer-2.5)` を優先。設計成果物は `Task(subagent_type=design-worker, model=composer-2.5)`。軽微修正は親のまま（常時フル委譲しない）
- ライブラリ調査は `Task(subagent_type=docs-researcher, model=composer-2.5)`、`docs-researcher` subagent、または `/docs` を優先

## Task の model 必須（作業系）

Cursor 製品の「`model` はユーザー明示時のみ渡す」は **提案系 Advisor（Opus）に従う**。次の作業系 `subagent_type` では **例外として `model` を必ず渡す**。省略すると親が Opus のとき作業系も Opus になりうる。`claude-opus-*` を作業系に渡さない。

| subagent_type                                          | Cursor の Task `model`（必須）            | 備考                                                     |
| ------------------------------------------------------ | ----------------------------------------- | -------------------------------------------------------- |
| `build-worker` / `design-worker`                       | `composer-2.5`                            | リポジトリ書込。frontmatter pin だけでは不足しうる       |
| `melchior-1` / `balthasar-2` / `casper-3`              | `composer-2.5`                            | MAGI                                                     |
| `explore`                                              | `composer-2.5` または `composer-2.5-fast` | ファイル発見・広域探索                                   |
| `generalPurpose`                                       | `composer-2.5`                            | 複数ステップ調査・実行（設計判断が必要なら別途 Advisor） |
| `docs-researcher` / `shell`                            | `composer-2.5`                            | ドキュメント調査・コマンド実行委譲                       |
| `design-advisor` / `build-advisor` / `quality-advisor` | 省略可（agent frontmatter の Opus）       | 提案のみ。書込しない                                     |

起動例（Task ツール）:

- **explore**: `subagent_type`: `"explore"`, `model`: `"composer-2.5"`（軽い広域のみ `"composer-2.5-fast"`）, `readonly`: `true`
- **generalPurpose**: `subagent_type`: `"generalPurpose"`, `model`: `"composer-2.5"`, `readonly`: `true`（調査時）
- **build-worker**: `subagent_type`: `"build-worker"`, `model`: `"composer-2.5"`
- **design-worker**: `subagent_type`: `"design-worker"`, `model`: `"composer-2.5"`
- **MAGI**: `subagent_type`: `"melchior-1"` / `"balthasar-2"` / `"casper-3"`, `model`: `"composer-2.5"`, `readonly`: `true`（各 1 体ずつ並列）
- **docs-researcher** / **shell**: `model`: `"composer-2.5"`

Cursor では上表の Composer pin を使う。Claude Code は Composer 非対応のため、作業系は Task の `model` に **`sonnet`** を渡す（Worker / MAGI はラッパー `sonnet` と整合。親 Opus 継承を避ける。haiku は使わない）。

## コード構造調査

構造・フロー・影響範囲（「X はどう動くか」「誰が呼ぶか」）は `@~/.config/shared/ai/rules/conventions/codegraph-rule.md` に従い CodeGraph を優先する。`Task(subagent_type=explore, model=composer-2.5)` や Grep ループと競合ではなく用途分担（explore = ファイル発見、CodeGraph = グラフ済み構造の surgical context）。

| 条件                                              | 優先ツール                                                                           |
| ------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `.codegraph/` あり                                | MCP `codegraph_explore` → CLI `codegraph explore`                                    |
| マルチルートの別ルート（対象ルートに index あり） | MCP `projectPath` または `cd` + CLI                                                  |
| インデックスなし                                  | Grep / Read / `Task(explore, model=composer-2.5)`（init は提案のみ、自動実行しない） |
| 文字列横断検索                                    | `rg` / Grep                                                                          |
| ライブラリ API                                    | Context7                                                                             |

## MCP

- 構造・フロー調査: `.codegraph/` ありなら **CodeGraph** `codegraph_explore`（読み取り専用、allowlist 済み）
- PR レビュー: GitHub MCP の `get_file_contents` 連打より `gh` + Shell（RTK）
- Playwright `browser_snapshot` は E2E 時のみ。ドメイン固有の例外は `*.local.md` にのみ書く（本ルールには列挙しない）

## 計測（開発者向け）

```bash
rtk discover --all --since 7   # 必ず --all（CWD で sessions が変わる）
rtk gain --history
```

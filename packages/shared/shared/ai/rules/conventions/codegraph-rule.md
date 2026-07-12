応答の冒頭に「Applied: codegraph-rule」と出力する。

# CodeGraph 利用ルール

セマンティックコードインテリジェンス（ローカル知識グラフ）の利用方針。セットアップ手順は [docs/CODEGRAPH.md](../../docs/CODEGRAPH.md) を参照。

## 前提

- CLI は mise 経由でグローバルインストール済み（`codegraph` が PATH にあること）
- **プロジェクトごと**に `.codegraph/` インデックスが必要（`codegraph init`）。未初期化では MCP は応答するがインデックスがなく、Grep/Read へのフォールバックガイダンスが返る
- エージェントが **`codegraph init` を勝手に実行しない**。必要ならユーザーに提案する

## 調査フロー

コードの構造理解・フロー追跡・影響範囲の把握では、grep/read のファイル横断ループより CodeGraph を優先する。

| 経路                                  | 用途                                                                                                              |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **MCP `codegraph_explore`**           | メインエージェント向け。1 コールで関連シンボルのソース・コールパス・blast radius を取得                           |
| **CLI `codegraph explore "<query>"`** | サブエージェント・MCP 非到達時のフォールバック（`codegraph install` が AGENTS.md に書く marker セクションの代替） |
| **CLI `codegraph status`**            | インデックス健全性・未同期ファイルの確認                                                                          |

### 使い分け

- 「X はどう動くか」「A から B にどう到達するか」→ `codegraph_explore` / `codegraph explore`
- 返却ソースは **既に Read 済み**として扱い、同内容の再 grep/read は避ける
- 編集直後に staleness バナー（`⚠️`）が付いた場合のみ、該当ファイルを Read で補完
- `.codegraph/` が無い、またはインデックス対象外のパス → 組み込みツール（Grep/Read/SemanticSearch）を使う

## サブエージェント

サブエージェントは MCP の server-instructions を受け取れない。構造調査が必要なら Shell で `codegraph explore` を実行し、結果を根拠に分析する。

## マルチルートワークスペース

- 各ワークスペースルートで `codegraph init`（`.codegraph/` はルートごと）
- 別ルートのコードを調べるときは MCP `projectPath` にそのルートの絶対パスを渡す（CLI は `cd` して `codegraph explore`）
- モノレポ（親ディレクトリ 1 つに複数サブリポジトリ）は親ルートで `codegraph init` すればまとめてインデックスされる場合あり。詳細は [CODEGRAPH.md](../../docs/CODEGRAPH.md)

## 参考

- 公式: [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)
- dotfiles セットアップ: `@~/.config/shared/ai/docs/CODEGRAPH.md`

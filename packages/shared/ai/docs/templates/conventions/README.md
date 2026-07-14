# ローカルルール（テンプレ要約）

プロジェクト固有のフィードバック・社内参照は **`~/.config/shared/ai/`** にのみ置く。dotfiles リポジトリには載せない（`*.local.*` は gitignore）。

手順・touch 一覧・蒸留フローの正本: [LOCAL-SETUP.md](../../LOCAL-SETUP.md)

| ファイル                       | 用途                                          |
| ------------------------------ | --------------------------------------------- |
| `rules/conventions/*.local.md` | 実装 / レビュー / registry のローカル追記     |
| `docs/feedback-*.local.md`     | 全フィードバックの log / index（FB-00x 含む） |

ID 体系は `pr-feedback-registry.local.md` を正本とする。

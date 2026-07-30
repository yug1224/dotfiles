# Claude Rules Index（Tier A・発見用）

本文は常時ロードしない。必要なときだけ `@./rules/<path>` を Read。Cursor の agent-requestable 相当。

| いつ                 | Read                                                                             |
| -------------------- | -------------------------------------------------------------------------------- |
| コミットメッセージ   | `conventions/commit-message-rule.md`（または `/suggest-commit-message`）         |
| ブランチ名           | `conventions/branch-name-rule.md`（または `/suggest-branch-name`）               |
| チケット取得         | `conventions/ticket-retrieval-rule.md`（または `/analyze-issue` 等）             |
| diff / PR レビュー   | `conventions/review-common-rule.md` + `pr-review-rule.md`（または `/review-*`）  |
| PR 説明              | `conventions/pr-description-rule.md`（または `/suggest-pr-description`）         |
| コード構造調査       | `conventions/codegraph-rule.md`                                                  |
| エージェント委譲     | `conventions/agent-delegation-rule.md`（Worker 起動・Task model 必須）           |
| 日本語技術文書       | `writing/japanese-tech-writing-rule.md`（または `/apply-japanese-tech-writing`） |
| X投稿要約            | `writing/x-post-rule.md`（または `/suggest-x-post`）                             |
| 実装規約（ローカル） | 存在すれば `conventions/coding-rule.local.md`                                    |
| AI 設定変更          | `meta/ai-config-rule.md`                                                         |
| 出力再検証           | `~/.config/shared/ai/rules/conventions/output-verification-rule.md`              |
| 敵対的検証           | `/verify-adversarial`                                                            |
| 資産棚卸し           | `/analyze-ai-config`（種別は引数または `/analyze-ai-skills` 等エイリアス）       |
| RTK / CodeGraph 手順 | `~/.config/shared/ai/docs/RTK.md` / `CODEGRAPH.md`                               |
| allowlist 同期       | `~/.config/shared/ai/docs/ALLOWLIST-SYNC.md`                                     |

網羅索引ではない。上表に無いルールは `~/.claude/rules/` を Glob するか、対応コマンド経由で Read する。

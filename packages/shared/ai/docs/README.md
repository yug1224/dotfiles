# `docs/`（Cursor / Claude Code 共通ドキュメント）

環境セットアップと運用フローを置く。判断基準（規約）と手順固定のワークフロー（Skill）は yug1224/skills にあり、docs はそのどちらにも入らないものを扱う。エージェントに守らせたい基準は docs ではなく `shared-rules/references/<domain>/` に書く。

docs は常時ロードしない。人間が読むか、Skill／ルールの Step から 1 回 Read する。

## 一覧

| ファイル                                       | 内容                                      | 主な読み手            | 入口                                |
| ---------------------------------------------- | ----------------------------------------- | --------------------- | ----------------------------------- |
| [setup-local-files.md](./setup-local-files.md) | `*.local.*` の置き場と初期化              | 人間（新規 clone 時） | —                                   |
| [setup-codegraph.md](./setup-codegraph.md)     | CodeGraph の MCP 配線・プロジェクト初期化 | 人間                  | —                                   |
| [project-skills.md](./project-skills.md)       | 業務リポジトリ側 Skills の命名・配置      | 人間                  | [CONVENTIONS.md](../CONVENTIONS.md) |

エージェントに読ませるときは `~/.config/shared/ai/docs/<name>.md` の絶対パスを Skill やルールの Step に書く（業務リポジトリからは dotfiles の相対パスが解決できない）。命名は [CONVENTIONS.md](../CONVENTIONS.md)、追加手順は [ai-config-rule.md](../rules/meta/ai-config-rule.md)。追加したら上の一覧に行を足す。

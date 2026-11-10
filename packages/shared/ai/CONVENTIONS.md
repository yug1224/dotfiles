# AI 素材の命名・配置規約

Skill と規約の正本は [yug1224/skills](https://github.com/yug1224/skills)（公開）と、Git 外の private リポジトリ。`gh skill` が `~/.claude/skills/` にコピーし、Cursor / Claude Code はそこを直接参照する（ラッパーなし）。docs・hooks・`rules/meta/` はこの `packages/shared/ai/` に残し、`~/.config/shared/ai/` として見える。常時カーネルは `packages/cursor/rules/kernel.mdc` と `packages/claude/CLAUDE.md`。

## 命名

| 種別           | パターン                                  | 配置                                                    |
| -------------- | ----------------------------------------- | ------------------------------------------------------- |
| ルール         | `<topic>-rule.md`                         | `skills/shared-rules/references/<domain>/`              |
| ローカル Skill | `local-<verb>-<object>/SKILL.md`          | private リポジトリの `skills/`                          |
| Skill          | `<verb>-<object>/SKILL.md`                | `skills/`（条件付きで読む大きい素材だけ `references/`） |
| ローカル上書き | `<basename>.local.md` / `<skill>.md`      | `skills/local-rules/references/<domain>/` / `overlays/` |
| ドキュメント   | `setup-<tool>.md` / `<topic>-playbook.md` | dotfiles の `docs/`（索引は `docs/README.md`）          |

ファイル名は kebab-case。Skill は `<verb>-<object>`（ローカル Skill は先頭に `local-`）で、動詞は `suggest` / `review` / `plan` / `analyze` / `apply` から選ぶ（勝手に増やさない）。例外は規約の置き場だけの参照専用 Skill（`shared-rules` / `local-rules`）で、`disable-model-invocation: true` を付ける。

Skill は frontmatter（`name` / `description`）を本文先頭に持つ。`name` はディレクトリ名と一致させ、`description` に「何をするか」と「いつ使うか」を書く（Cursor はこれで自動適用を判断する）。ルールに frontmatter は書かない。

dotfiles の Skill は動詞先頭。業務リポジトリ側の Skills は **名詞先頭** `<domain>-<pattern>`（dotfiles の動詞先頭と名前空間を分ける）。Cursor も `.claude/skills/` を読むため、置き場は `.claude/skills/` に一本化する。詳細は [docs/project-skills.md](./docs/project-skills.md)。

## Skill の自動発火

ワークフローはすべて `skills/` に置き、コマンド（`commands/`）は使わない。両ツールとも `/<name>` で呼べる。自動発火の有無は frontmatter の `disable-model-invocation` で切り替える。

| frontmatter                      | 向くもの                                                                                       | 例                                                   |
| -------------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `disable-model-invocation` なし  | 自然文の依頼（「コミットメッセージ考えて」）でも発火させたい、読み取りと提案だけのワークフロー | `suggest-commit-message`, `plan-blog`, `review-blog` |
| `disable-model-invocation: true` | 明示したときだけ動かすもの。自動発火させたくないワークフロー・再適用系・ローカル Skill         | `apply-review-feedback`                              |

- その Skill だけが使う手順・規約は SKILL.md 本文に書く（Skill 本文は呼ばれたときだけ読まれるので、分けても Read が 1 回増えるだけ）。`skills/<name>/references/` に分けるのは、条件付きでしか読まないものと、そのまま出力する長い固定文だけ。他の Skill・ルールからも参照されるルールは `shared-rules/references/` に置く（例: `commit-message-rule.md` は `suggest-pr-description` と `branch-name-rule.md` からも参照される）。規約同士が相互に参照するので、ディレクトリ構成を保ったまま 1 か所にまとめる
- Git 外のワークフローは private リポジトリの `skills/local-<name>/` に置く。Skill の `name` はディレクトリ名と一致させる必要があり、`.local` を含む名前を Skill 名にできないため、接頭辞 `local-` で区別する。既存 Skill への上書きは `local-rules/references/overlays/<skill>.md` に置き、単独のワークフローには使わない

## `.md` と `.local.md`

`.local.md` は差分・追記のみ。矛盾時は `.local.md` 優先。`shared-rules/references/<domain>/<name>.md` を Read したら、`~/.claude/skills/local-rules/references/<domain>/<name>.local.md` が存在するときだけ Read する（`gh skill` はリポジトリごとに別ディレクトリへコピーするので、同じディレクトリには置けない）。Skill への上書きは `local-rules/references/overlays/<skill>.md` に置き、その Skill の本文に Read の Step を書いたときだけ効く（Skill 本文はハーネスが注入するので自動では読まれない。現状は `analyze-ai-config` / `suggest-pr-description` / `suggest-x-post`）。

**Git に載せないもの**: 会社名・製品名・非公開 URL・自社固有ワークスペースパス。ドメイン固有／自社固有は private リポジトリの `local-rules/references/` と `local-*/` で維持する。公開側（dotfiles・yug1224/skills）には private リポジトリの名前やパスも書かない。初期化は [docs/setup-local-files.md](./docs/setup-local-files.md)。

`.local.md` を shared（Git）へ昇格させてよいのは、識別子フリーかつリポジトリ横断で再利用可能なものだけ。

## 実装系 vs レビュー系（意図的分離）

| フェーズ         | 主なファイル                                                            |
| ---------------- | ----------------------------------------------------------------------- |
| **実装**         | `coding-rule.local.md`                                                  |
| **レビュー**     | `skills/review-pr/SKILL.md`・`code-review-rule.md` + 任意の `.local.md` |
| **レビュー対応** | `review-feedback-rule.md`・`code-review-rule.md` + 任意の `*.local.md`  |

実装とレビューの方針を 1 ファイルに混在させない。重要度・比較先・指摘の絞り方は `code-review-rule.md` に一本化し、指摘する側と直す側で同じ基準を使う。反証の手順と出力の型は `review-report-rule.md` にまとめ、`/review-blog` も同じ形式で返す。コードレビューは `/review-pr`（固定テンプレートのレポート。Cursor でも同じ名前で使う）で行い、Claude Code 組み込みの `/code-review` は形式を問わないときに使う。

## 書かないもの

モデルが指示なしでも守ることは書かない。例: 汎用のレビュー観点、Conventional Commits の type の説明、`gh` / `git` の基本的な使い方、出力前の自己点検、読んだルールの自己申告（ツール呼び出しは UI に表示される）、ハーネスや MCP がすでに注入している内容。ルールに残すのは、この環境だけの決まりと、モデルの既定の癖を矯正する指示だけにする。

追加・変更の手順と漏洩チェックは [rules/meta/ai-config-rule.md](./rules/meta/ai-config-rule.md)。

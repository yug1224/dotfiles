# AI 設定変更ルール（dotfiles）

dotfiles の `packages/shared/ai/`・カーネル・ホスト設定（`packages/claude/` / `packages/cursor/`）を変更するときだけ Read する。Skill と規約の命名・配置・漏洩チェックは yug1224/skills の [CONVENTIONS.md](https://github.com/yug1224/skills/blob/main/CONVENTIONS.md)（手元では `~/Workspaces/yug1224/skills/CONVENTIONS.md`）に従う。

## 手順

1. 本文を追加・修正する。Skill と規約は入手元のリポジトリで直し、`~/.claude/skills/` は直接直さない
2. 漏洩チェック（上記 CONVENTIONS.md）を確認する
3. `make check-sync` → `make mise`。Skill の反映は `mise -C ~/.dotfiles run skills:update`（作業ツリーがそのまま入るので、入れる前にブランチを確かめる）。公開側は push して GitHub と揃える

docs は `docs/` に `setup-<tool>.md` / `<topic>-playbook.md`（kebab-case）で置き、[docs/README.md](../../docs/README.md) の一覧に行を足す。

## カーネル

正本は `packages/claude/CLAUDE.md`。`packages/cursor/rules/kernel.mdc` は直接直さず、`CLAUDE.md` を直して `make kernel` で作り直す（frontmatter を足し、`# CLAUDE.md` の見出しを落とす）。`make check-sync`（`scripts/check-kernel-sync.sh`）が作り直した結果とのずれを FAIL にする。

## 常時ロードの例外

フックで毎回 context に文章を足すのは、次の表に載せたものだけにする。プラグインやフックを足すときは、毎回 context に入るものがないか確かめ、あれば表に行を足す。

| 出どころ                                 | 入るタイミング                                                                | 残す理由                                              |
| ---------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------- |
| `codegraph prompt-hook`（settings.json） | プロンプトごと（`.codegraph/` があるときだけ）                                | 先にコードマップを渡して、grep と Read の往復を減らす |
| ponytail プラグイン                      | セッション開始・サブエージェント開始（モードを切り替えたプロンプトにも 1 行） | 変更を最小に保つ方針を、毎回指示しなくても効かせる    |

## 禁止

- `~/.cursor/skills` に Skill を入れる（`~/.claude/skills` と二重表示になる。`gh skill` は `skills:update` が `--dir` で指定した場所だけに入れる）
- カーネルと上の例外以外の常時ロードを増やす（詳細ルールの `alwaysApply: true`、`CLAUDE.md` への `@import`、`packages/cursor/rules` への kernel 以外の `.mdc`、`~/.claude/rules/` へのファイル追加）
- 外部の Skill・プラグインを固定せずに入れる（Skill は `skills:update` の `--pin`、marketplace は `settings.json` の `source.ref` に commit SHA を書く。上げるときは差分を読んでから SHA を書き換える）
- コードを探す MCP を codegraph 以外に足す（同じ役割のツールが並ぶと context を食い、どちらを使うかも迷う）
- Cursor 用の `hooks.json` を足す（Cursor は Third-Party Imports で Claude Code のフックを実行するので、ガードが 2 回動く。[packages/cursor/README.md](../../../cursor/README.md)「シェルガード」）
- Git 管理ファイルに会社名・非公開 URL を書く

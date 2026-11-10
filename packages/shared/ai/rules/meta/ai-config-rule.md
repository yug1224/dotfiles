# AI 設定変更ルール（dotfiles）

dotfiles の `packages/shared/ai/` やカーネル、または Skill のリポジトリ（yug1224/skills と private リポジトリ）を変更するときだけ Read する。命名・配置・書かないものは [CONVENTIONS.md](../../CONVENTIONS.md)。

## 手順

1. 本文を追加・修正する。Skill と規約は入手元のリポジトリで直し、`~/.claude/skills/` は直接直さない。ルールのパスは Skill の Step に書いて 1 回 Read させ、`@` でインライン展開しない（Claude Code は `@path` を起動時に展開するので二重に載る）
2. 外部ソースを蒸留した場合は yug1224/skills の README「出典・蒸留」に追記する
3. 下の漏洩チェックを確認する
4. dotfiles は `make check-sync` → `make mise`。Skill の反映は `mise -C ~/.dotfiles run skills:update`（作業ツリーがそのまま入るので、入れる前にブランチを確かめる）。公開側は push して GitHub と揃える

## 漏洩チェック（PR 前）

- [ ] tracked ファイルに会社名 / 製品名 / 非公開 URL がない
- [ ] Skill の `description`・使用例・README に製品名が残っていない（プロバイダ固有は `.local` へ）
- [ ] チケット例に会社プレフィックスがない（`PROJ-1234` を使う）
- [ ] 公開 Skill が only-local ファイルを必須 Read していない
- [ ] rename 後の旧 basename 参照が残っていない
- [ ] recruiting ドメインは private リポジトリの `local-rules/references/<domain>/*.local.md` だけに置き、公開側からは参照しない
- [ ] 公開側（dotfiles・yug1224/skills）に private リポジトリの名前やパスがない

## カーネル

`packages/claude/CLAUDE.md` と `packages/cursor/rules/kernel.mdc` は同じ指示を保つ。許す差分は Cursor の frontmatter と `CLAUDE.md` の見出しだけで、`make check-sync`（`scripts/check-kernel-sync.sh`）がずれを FAIL にする。

## 禁止

- `~/.cursor/skills` に Skill を入れる（`~/.claude/skills` と二重表示になる。`gh skill` は `--agent claude-code` だけで入れる）
- カーネル以外の常時ロードを増やす（詳細ルールの `alwaysApply: true`、`CLAUDE.md` への `@import`、`packages/cursor/rules` への kernel 以外の `.mdc`、`~/.claude/rules/` へのファイル追加）
- Git 管理ファイルに会社名・非公開 URL を書く
- `.local.md` に `.md` の全文をコピーする

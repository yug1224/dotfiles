# `*.local.*` の置き場と初期化

`*.local.*` は個人・自社固有の差分で、Git に載せない（各パッケージの `.gitignore` が `*.local.*` を除外し、`make check-sync` の `check-local-tracked.sh` が追跡漏れを検出する）。dotfiles の作業ツリーに残る `*.local.*` と `mise.local.toml` も Git 外なので、clone し直す前に退避する。

Skill と規約の Git 外の差分は、dotfiles ではなく **GitHub に push しない private リポジトリ** に置き、`skills:update` が `~/.claude/skills/` を作り直すときに `gh skill install --from-local` で一緒に入れる。dotfiles には、そのリポジトリの名前もパスも書かない。

## private リポジトリの構成

`gh skill` は `skills/*/SKILL.md` を探すので、Skill はリポジトリの `skills/` 直下に置く。

```
<private リポジトリ>/skills/
├── local-<name>/SKILL.md                # Git 外の単独 Skill
└── local-rules/                         # 参照専用（SKILL.md に disable-model-invocation: true）
    └── references/
        ├── conventions/<name>.local.md  # 公開規約への差分
        ├── <domain>/*.local.md          # ドメイン固有の一式
        └── overlays/<skill>.md          # 公開 Skill への上書き
```

## ルールの差分

公開規約 `~/.claude/skills/shared-rules/references/<domain>/<name>.md` を Read した Skill／ルールが、`~/.claude/skills/local-rules/references/<domain>/<name>.local.md` を存在時だけ Read する。

| ファイル（`local-rules/references/conventions/` 配下） | 読まれる場面                                     |
| ------------------------------------------------------ | ------------------------------------------------ |
| `coding-rule.local.md`                                 | 実装・修正時（両カーネルが作業種別で 1 回 Read） |
| `code-review-rule.local.md`                            | `/review-pr`・`/apply-review-feedback` の追記    |
| `review-feedback-rule.local.md`                        | `/apply-review-feedback` の追記                  |
| `ticket-retrieval-rule.local.md`                       | チケット取得のプロバイダ固有アダプタ             |

Skill 固有の上書きは `local-rules/references/overlays/<skill>.md` に置く（例: `/suggest-pr-description` のプロジェクト固有の書き方は `overlays/suggest-pr-description.md`）。効くのは本文に Read の Step がある Skill だけ。

## ローカル Skill

`skills/local-<name>/SKILL.md` に置くと、Cursor と Claude Code の両方に `/local-<name>` として出る。frontmatter の `name`（ディレクトリ名と同じ `local-<name>`）/ `description` と、明示したときだけ動かす `disable-model-invocation: true` を忘れない。

## インストール

公開側の `skills:update` タスクは、`~/.claude/skills/` を毎回作り直す。作業用のディレクトリ（`~/.claude/skills.staging.*`）に、yug1224/skills の clone（`~/Workspaces/yug1224/skills`）を `gh skill install --from-local --dir` で入れ、外部の Skill（nanaism/yomiyasu、GoogleChrome/modern-web-guidance）を GitHub の最新リリースから入れる。全部入れ終わってから `~/.claude/skills/` と入れ替えるので、途中で失敗したときは今の Skill が残る。

private リポジトリなど端末固有の Skill も入れるときは、dotfiles 直下に `mise.local.toml`（Git 外。ルートの `.gitignore` が除外する）を置き、`skills:update:local` タスクを書く。`skills:update` は入れ替える前に、作業用のディレクトリを `SKILLS_DIR` に渡してこのタスクを呼ぶ。入れ替えの外で `~/.claude/skills/` を直接いじらないよう、単体では実行しない。

```toml
[tasks."skills:update:local"]
run = """
#!/usr/bin/env bash
set -euo pipefail
dir="${SKILLS_DIR:?run via: mise run skills:update}"
gh skill install <private リポジトリのパス> --from-local --all --dir "$dir" --force
"""
```

yug1224/skills の clone は、`make mise` の bootstrap が `[bootstrap.repos]` で作る。clone 済みなら今の commit のまま触らず、commit 前の変更があっても `--skip-dirty` で飛ばして先へ進む。`mise.local.toml` が無い端末では公開側の Skill だけが入る。clone から入れるものは作業ツリーをそのまま入れ、`git pull` はしない（別のブランチや commit 前の変更も入る）。

`~/.claude/skills/` はコピーで、`skills:update` のたびに作り直すので、直接直したものや手で置いたものは消える。Skill のリポジトリで編集し（履歴を残すなら commit する）、`mise -C ~/.dotfiles run skills:update` で反映する。ファイルや Skill を消したり名前を変えたりしても、作り直すときにそのまま反映される。

## ホスト設定の差分

| ファイル                              | 用途                                                                                                                       |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `packages/claude/settings.local.json` | 端末ごとの env・model・plugins。`~/.claude/` への symlink は手動（[packages/claude/README.md](../../../claude/README.md)） |
| `mise.local.toml`                     | 端末固有の Skill を入れる `skills:update:local`（上記「インストール」）                                                    |

Cursor の `permissions.json` / `hooks.json` にはローカル上書きの仕組みがない。端末差分が要るときは Cursor の UI 側で設定する。

## 置いてはいけない場所

[ai-config-rule.md](../rules/meta/ai-config-rule.md)「禁止」を参照。本文は Skill のリポジトリに置き、カーネルか Skill から Read させる。業務リポジトリ側の Skill の置き場は [project-skills.md](./project-skills.md)。

## Git に載せないもの

正本は [CONVENTIONS.md](../CONVENTIONS.md)「`.md` と `.local.md`」。

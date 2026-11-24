# `*.local.*` の置き場と初期化

`*.local.*` は個人・自社固有の差分で、Git に載せない（各パッケージの `.gitignore` が `*.local.*` を除外し、`make check-sync` の `check-local-tracked.sh` が追跡漏れを検出する）。dotfiles の作業ツリーに残る `*.local.*` と `mise.local.toml` も Git 外なので、clone し直す前に退避する。

| ファイル                              | 用途                                                                                                                       |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `packages/claude/settings.local.json` | 端末ごとの env・model・plugins。`~/.claude/` への symlink は手動（[packages/claude/README.md](../../../claude/README.md)） |
| `mise.local.toml`                     | 端末固有の Skill のリポジトリ（下記「端末固有の Skill」）                                                                  |

Cursor の `permissions.json` にはローカル上書きの仕組みがない。端末差分が要るときは Cursor の UI 側で設定する。

## 端末固有の Skill

Skill と規約の Git 外の差分は、dotfiles ではなく **GitHub に push しない private リポジトリ** に置く。dotfiles には、そのリポジトリの名前もパスも書かない。Skill と規約の命名・配置と `.local.md` の決まりは yug1224/skills の [CONVENTIONS.md](https://github.com/yug1224/skills/blob/main/CONVENTIONS.md)。

入れるときは、dotfiles 直下の `mise.local.toml` にリポジトリのパスを書く（複数なら `:` 区切り）。`skills:update` が公開側の Skill と一緒に `~/.claude/skills/` に入れる。社内の情報を含みうるので `~/.gemini/config/skills/` には入れない。ただし Antigravity もカーネル（`GEMINI.md`）から `~/.claude/skills/local-rules/` の規約を絶対パスで Read する。仕組みは `mise.toml` の `skills:update` のコメントを参照。

```toml
[env]
SKILLS_LOCAL_SOURCES = "<private リポジトリのパス>"
```

`mise.local.toml` が無い端末では公開側の Skill だけが入る。Skill とカーネルが Read する `~/.claude/skills/` のパスが欠けていると、`skills:update` は入れ替えずに失敗する（使うときに作る `overlays/` は確かめない）。反映は `mise -C ~/.dotfiles run skills:update`。

## 置いてはいけない場所

[ai-config-rule.md](../rules/meta/ai-config-rule.md)「禁止」を参照。業務リポジトリ側の Skill の置き場は [project-skills.md](./project-skills.md)。

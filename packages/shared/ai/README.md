# `packages/shared/ai/`（Cursor / Claude Code / Antigravity 共有素材）

Cursor・Claude Code・Antigravity が同じ本文を読むための原本。`make mise` が `~/.config/shared` → `packages/shared` の symlink を張るので、`~/.config/shared/ai/` 配下の編集はそのままリポジトリの編集になる。

Skill と、Skill が Read する規約（`shared-rules`）は [yug1224/skills](https://github.com/yug1224/skills) にある。`make mise` が `[bootstrap.repos]` で yug1224/skills を `~/Workspaces/yug1224/skills` に clone し、`skills:update` が `gh skill` で `~/.claude/skills/` と `~/.gemini/config/skills/` を作り直す。外部の Skill は `--pin` で commit を固定する。Git 外の Skill と規約の足し方は [docs/setup-local-files.md](./docs/setup-local-files.md)。

```
packages/shared/ai/
├── rules/meta/ # この dotfiles の AI 設定を変えるときのルール
├── docs/       # セットアップ手順と運用フロー（索引: docs/README.md）
└── hooks/      # guard-shell.sh（破壊的コマンドのハード拒否本体）
```

## 各ツールからの見え方

| 素材                   | Cursor                                                           | Claude Code                                                 | Antigravity                                                                          |
| ---------------------- | ---------------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| 常時ロード（カーネル） | `~/.cursor/rules/kernel.mdc`（`alwaysApply: true`）              | `~/.claude/CLAUDE.md`                                       | `~/.gemini/GEMINI.md`（`packages/claude/CLAUDE.md` への symlink）                    |
| Skill                  | `~/.claude/skills/`（`gh skill` のコピー）を読む                 | 同左                                                        | `~/.gemini/config/skills/`（`gh skill` のコピー。端末固有の Skill は入れない）を読む |
| 規約                   | `~/.claude/skills/shared-rules/references/...` を絶対パスで Read | 同左                                                        | 同左                                                                                 |
| docs                   | `~/.config/shared/ai/docs/...` を絶対パスで Read                 | 同左                                                        | 同左                                                                                 |
| シェルガード           | Third-Party Imports で Claude Code のフックを実行                | `settings.json` の `PreToolUse`（matcher `Bash`）           | —                                                                                    |
| 権限                   | `permissions.json`                                               | `settings.json`（端末ごとの上書きは `settings.local.json`） | UI 側の設定                                                                          |

- ツール別のラッパーは持たない。Skill を 1 本足せば全ツールに同じ名前（`/<name>`）で出る
- `~/.claude/skills/` と `~/.gemini/config/skills/` はコピーで、`skills:update` のたびに作り直すので直接直さない（手で置いたものも消える）。入手元のリポジトリを直して `mise -C ~/.dotfiles run skills:update` で反映する
- カーネル同期・常時ロードの禁止は [ai-config-rule.md](./rules/meta/ai-config-rule.md)、Skill の命名・配置・自動発火の切り替えは yug1224/skills の [CONVENTIONS.md](https://github.com/yug1224/skills/blob/main/CONVENTIONS.md)
- シェルガードの挙動などホスト固有の設定は [packages/cursor/README.md](../../cursor/README.md) / [packages/claude/README.md](../../claude/README.md)

## ファイルを探す

| 知りたいこと                     | 見る場所                                                                                       |
| -------------------------------- | ---------------------------------------------------------------------------------------------- |
| Skill の命名・配置・漏洩チェック | yug1224/skills の [CONVENTIONS.md](https://github.com/yug1224/skills/blob/main/CONVENTIONS.md) |
| dotfiles の AI 設定の変更手順    | [rules/meta/ai-config-rule.md](./rules/meta/ai-config-rule.md)                                 |
| セットアップ・運用フロー         | [docs/README.md](./docs/README.md)                                                             |
| `*.local.*` の置き場と初期化     | [docs/setup-local-files.md](./docs/setup-local-files.md)                                       |
| 外部ソースを蒸留したものの出典   | [yug1224/skills の README](https://github.com/yug1224/skills)                                  |
| 手元の AI 資産の棚卸し           | `/analyze-ai-config`（引数で `skills` / `rules` などに絞り込み）                               |

`*.local.*` は Git 管理外の差分・追記。公開 clone では汎用 `.md` だけで動く。

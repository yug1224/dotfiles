# `packages/shared/ai/`（Cursor / Claude Code 共有素材）

Cursor と Claude Code が同じ本文を読むための原本。`make mise` が `~/.config/shared` → `packages/shared` の symlink を張るので、`~/.config/shared/ai/` 配下の編集はそのままリポジトリの編集になる。

Skill と、Skill が Read する規約（`shared-rules`）は [yug1224/skills](https://github.com/yug1224/skills) にある。`make mise` が yug1224/skills を `~/Workspaces/yug1224/skills` に clone し、`gh skill` で `~/.claude/skills/` にコピーする。Git 外の Skill と規約の足し方は [docs/setup-local-files.md](./docs/setup-local-files.md)。

```
packages/shared/ai/
├── rules/meta/ # この dotfiles の AI 設定を変えるときのルール
├── docs/       # セットアップ手順と運用フロー（索引: docs/README.md）
└── hooks/      # guard-shell.sh（破壊的コマンドのハード拒否本体）
```

## Cursor / Claude Code からの見え方

| 素材                   | Cursor                                                           | Claude Code                                                 |
| ---------------------- | ---------------------------------------------------------------- | ----------------------------------------------------------- |
| 常時ロード（カーネル） | `~/.cursor/rules/kernel.mdc`（`alwaysApply: true`）              | `~/.claude/CLAUDE.md`                                       |
| Skill                  | `~/.claude/skills/`（`gh skill` のコピー）を読む                 | 同左                                                        |
| 規約                   | `~/.claude/skills/shared-rules/references/...` を絶対パスで Read | 同左                                                        |
| docs                   | `~/.config/shared/ai/docs/...` を絶対パスで Read                 | 同左                                                        |
| シェルガード           | `hooks.json` の `beforeShellExecution`                           | `settings.json` の `PreToolUse`（matcher `Bash`）           |
| 権限                   | `permissions.json`                                               | `settings.json`（端末ごとの上書きは `settings.local.json`） |

- ツール別のラッパーは持たない。Skill を 1 本足せば両ツールに同じ名前（`/<name>`）で出る
- `~/.claude/skills/` はコピーなので直接直さない。入手元のリポジトリを直して `mise -C ~/.dotfiles run skills:update` で反映する
- カーネル同期・常時ロードの禁止は [ai-config-rule.md](./rules/meta/ai-config-rule.md)、Skill の自動発火の切り替えは [CONVENTIONS.md](./CONVENTIONS.md)
- シェルガードの挙動などホスト固有の設定は [packages/cursor/README.md](../../cursor/README.md) / [packages/claude/README.md](../../claude/README.md)

## ファイルを探す

| 知りたいこと                   | 見る場所                                                         |
| ------------------------------ | ---------------------------------------------------------------- |
| 命名・配置・書かないもの       | [CONVENTIONS.md](./CONVENTIONS.md)                               |
| 追加・変更の手順と漏洩チェック | [rules/meta/ai-config-rule.md](./rules/meta/ai-config-rule.md)   |
| セットアップ・運用フロー       | [docs/README.md](./docs/README.md)                               |
| `*.local.*` の置き場と初期化   | [docs/setup-local-files.md](./docs/setup-local-files.md)         |
| 外部ソースを蒸留したものの出典 | [yug1224/skills の README](https://github.com/yug1224/skills)    |
| 手元の AI 資産の棚卸し         | `/analyze-ai-config`（引数で `skills` / `rules` などに絞り込み） |

`*.local.*` は Git 管理外の差分・追記。公開 clone では汎用 `.md` だけで動く。

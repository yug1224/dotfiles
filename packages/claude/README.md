# `packages/claude/`（~/.claude）

Claude Code のホスト固有設定。`make mise` で `~/.claude/` 配下に symlink を張る。Skill と規約の本文は Cursor と共有で、`make mise` が yug1224/skills の clone から `~/.claude/skills/` にコピーする（[shared README](../shared/ai/README.md)）。

```
packages/claude/
├── CLAUDE.md            # 常時カーネル
├── settings.json        # 権限とフック
├── settings.local.json  # 端末ごとの上書き（Git 外。mise 管理外）
└── hooks/               # 薄いアダプタ。本体は shared/ai/hooks/guard-shell.sh
```

skills の入れ方と自動発火の切り替えは [shared README](../shared/ai/README.md)「Cursor / Claude Code からの見え方」と [CONVENTIONS.md](../shared/ai/CONVENTIONS.md)「Skill の自動発火」。

## カーネル

`CLAUDE.md` は `kernel.mdc` と同期する（[ai-config-rule.md](../shared/ai/rules/meta/ai-config-rule.md)「カーネル」）。`codegraph install` が書き足すブロックの扱いは [setup-codegraph.md](../shared/ai/docs/setup-codegraph.md)。

## 権限・フック（settings.json）

- **allow**: `Bash(*)` と `mcp__codegraph__*`
- **deny**: `git push` / 破壊的な `gh` / `rm -rf` の前方一致。正は `guard-shell.sh`。`settings.json` 側は保険で、`env git push` などラッパー経由は拾えない
- ガードはサンドボックスではなく事故防止。`gh api -X DELETE` や git alias 経由は対象外
- **PreToolUse**（matcher `Bash`）: `hooks/guard-shell.sh`。deny のときだけ出力し、allow 時は無出力で通常の権限判定に戻す
- **UserPromptSubmit**: `codegraph prompt-hook`（codegraph 未インストール時は何もしない）

## プラグイン

全端末で使うプラグインは `settings.json` の `enabledPlugins` と `extraKnownMarketplaces` に書く。`make mise` の bootstrap が `mise run plugins:update` を呼び、marketplace と有効なプラグインを最新にする。手で更新するときは `mise -C ~/.dotfiles run plugins:update` を実行し、Claude Code を再起動する。hook を持たず Skill だけのもの（yomiyasu）はプラグインにせず、`skills:update` で `gh skill install` する。

## 端末ごとの設定

env・model・plugins など端末ごとの設定は `settings.local.json` に書く。mise は張らないので、端末ごとに手動で symlink する。

```bash
ln -s ~/.dotfiles/packages/claude/settings.local.json ~/.claude/settings.local.json
```

セットアップ・運用フローの索引は [shared/ai/docs/README.md](../shared/ai/docs/README.md)。

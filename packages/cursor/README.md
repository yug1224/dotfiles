# `packages/cursor/`（~/.cursor）

Cursor のホスト固有設定。`make mise` で `~/.cursor/` 配下に symlink を張る。Skill と規約の本文は Claude Code と共有で、`~/.claude/skills/` を読む（[shared README](../shared/ai/README.md)）。

```
packages/cursor/
├── rules/kernel.mdc  # 常時カーネル（alwaysApply: true）。rules/ に置ける .mdc はこれだけ
├── hooks.json        # beforeShellExecution → hooks/guard-shell.sh（failClosed）
├── hooks/            # 薄いアダプタ。本体は shared/ai/hooks/guard-shell.sh
└── permissions.json  # mcpAllowlist / terminalAllowlist
```

skills の参照先は [shared README](../shared/ai/README.md)「Cursor / Claude Code からの見え方」。

## カーネル

`kernel.mdc` は `CLAUDE.md` と同期する（[ai-config-rule.md](../shared/ai/rules/meta/ai-config-rule.md)「カーネル」）。`rules/` に他の `.mdc` を足すと `make check-sync` が FAIL にする。

Cursor 公式 docs が記載するグローバル指示は User Rules（Customize → Rules）だけで、`~/.cursor/rules/*.mdc` のグローバル読込は未記載。日本語の技術文書を頼んだときに `apply-japanese-tech-writing/SKILL.md` を Read するか（エージェントのツール呼び出し表示で確認できる。`coding-rule` は Git 外なので無い環境では読まれない）で効いているか確認し、読まないときだけ kernel.mdc 本文（frontmatter 除く）を User Rules に貼る。両方に置くと二重ロードになるのでどちらか一方。kernel.mdc は正本として残す。

## 権限

- **MCP**: `*:*` を許可
- **端末**: `terminalAllowlist` に日常的に使うコマンドを列挙して自動承認する
- **拒否**: `git push` / 破壊的な `gh` / `rm -rf` は `guard-shell.sh` がハード拒否する（allowlist より優先）

`permissions.json` が効くのは Run Mode が **Allowlist** / **Auto-review** のときだけ。Run Everything ではサンドボックスも承認もかからないので使わない。

セットアップ・運用フローの索引は [shared/ai/docs/README.md](../shared/ai/docs/README.md)。業務リポジトリ側 Skill の置き場は [project-skills.md](../shared/ai/docs/project-skills.md)。

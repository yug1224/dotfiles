# VS Code / Cursor ユーザー設定（`settings.json`）

このパッケージは **Visual Studio Code** と **Cursor** の両方のユーザー設定ディレクトリへ同じ `settings.json` を `stow` で配布する。

## デプロイ先

リポジトリの [`Makefile`](../../Makefile) より:

- `~/Library/Application Support/Code/User`（VS Code）
- `~/Library/Application Support/Cursor/User`（Cursor）

```bash
make stow
```

## AI ルール・エージェントとの関係

`settings.json` はエディタのフォーマッタ・拡張機能・UI などの設定であり、**Cursor の `rules` / `commands` / `agents` や `packages/shared/shared/ai` の共有ルールとは別レイヤー**である。AI 用の dotfiles は [`packages/cursor`](../cursor/README.md)、[`packages/claude`](../claude/README.md)、[`packages/shared/shared/ai`](../shared/shared/ai/README.md) を参照する。

**Claude Code** は VS Code / Cursor の `settings.json` を読み込まない（CLI / 別プロセス）。エディタ設定の共有は本 `packages/code` パッケージ、**ターミナル・MCP の allowlist やエージェント規約**の共有は `packages/shared/shared/ai`（および `make stow` 先の `~/.config/shared/ai`）で行う、という切り分けになる。

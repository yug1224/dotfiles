# CodeGraph

ローカル知識グラフによるセマンティックコードインテリジェンス。Cursor / Claude Code から MCP `codegraph_explore` で利用する。

- 公式: [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)
- CLI: mise で `npm:@colbymchenry/codegraph`（[packages/mise/config.toml](../../../mise/config.toml)）

## セットアップの 2 段階

| 段階             | 頻度              | 内容                                               |
| ---------------- | ----------------- | -------------------------------------------------- |
| **グローバル**   | 1 回              | CLI（済）+ MCP 配線                                |
| **プロジェクト** | 各リポジトリ 1 回 | `codegraph init` → `.codegraph/` 作成 + グラフ構築 |

`codegraph install` を**そのまま実行しない**。`~/.claude/CLAUDE.md` や `~/.claude/settings.json` は `packages/claude/` への symlink なので、install はリポジトリの正本を直接書き換える。実行した場合は `git diff packages/claude packages/cursor` で差分を確認し、残す部分だけコミットする。

## 1. dotfiles デプロイ

```bash
make mise   # ~/.config/shared と cursor / claude のホスト設定を symlink
```

dotfiles 側で持っている CodeGraph 関連の設定:

| ツール      | ファイル                           | 内容                                                                         |
| ----------- | ---------------------------------- | ---------------------------------------------------------------------------- |
| Cursor      | `packages/cursor/permissions.json` | `mcpAllowlist: ["*:*"]`                                                      |
| Claude Code | `packages/claude/settings.json`    | allow `mcp__codegraph__*`、`UserPromptSubmit` フック `codegraph prompt-hook` |

使い方の要約は MCP の server instructions と `codegraph prompt-hook` が注入するので、カーネル（`CLAUDE.md` / `kernel.mdc`）には書かない。`codegraph install` が `CLAUDE.md` に `CODEGRAPH_START` 〜 `CODEGRAPH_END` ブロックを足した場合は削除する。

## 2. MCP 手動マージ

`~/.cursor/mcp.json` と `~/.claude.json` はシークレット・状態を含むため dotfiles では管理しない。スニペットを手動マージする。

```bash
codegraph install --print-config cursor   # → ~/.cursor/mcp.json にマージ
codegraph install --print-config claude   # → ~/.claude.json にマージ
```

### Cursor（`${workspaceFolder}` 必須）

```json
{
  "mcpServers": {
    "codegraph": {
      "type": "stdio",
      "command": "codegraph",
      "args": ["serve", "--mcp", "--path", "${workspaceFolder}"]
    }
  }
}
```

### Claude Code

```json
{
  "mcpServers": {
    "codegraph": {
      "type": "stdio",
      "command": "codegraph",
      "args": ["serve", "--mcp"]
    }
  }
}
```

マージ後 **Cursor / Claude Code を再起動**して MCP を読み込む。

## 3. プロジェクト初期化

```bash
cd your-project
codegraph init
codegraph status
```

- `.codegraph/` はローカルインデックス（**コミット不要**。グローバル gitignore に `.codegraph/` を推奨）
- ファイル変更後は auto-sync が有効（デフォルト）。手動 `codegraph sync` は通常不要
- インデックス削除: `codegraph uninit`

## マルチルートワークスペース

複数リポジトリを 1 つの `.code-workspace` に載せる場合:

1. **各ルートで** `codegraph init`（`.codegraph/` はルートごとに作成）
2. **普段の利用**: 編集中ファイルがあるルートのインデックスが MCP `${workspaceFolder}` のデフォルトになる
3. **別ルートを調べる**: MCP `codegraph_explore` の `projectPath` にそのルートの絶対パスを指定
4. **モノレポ（親 1 ディレクトリ）**: 親ルートで `codegraph init` すればネストした独立 git repo もインデックス対象になりうる

peer ディレクトリを 1 インデックスにまとめる機能は未対応のため、別場所のリポジトリはそれぞれ `init` + `projectPath` で扱う。

## トラブルシュート

### MCP が接続しない

1. `which codegraph` — GUI アプリ（Cursor / Claude）起動時の PATH に mise shim が通っているか確認
2. 接続失敗時は `mcp.json` の `command` を `which codegraph` の絶対パスに変更
3. macOS では `launchctl setenv PATH` で GUI アプリに PATH を渡す方法もある（`openspec` と同種の問題）

### 「CodeGraph not initialized」

プロジェクトルートで `codegraph init` を実行する。

### WSL2 / ネットワークドライブ

`Transport closed` 等が出る場合、MCP サーバーの `env` に `CODEGRAPH_NO_DAEMON=1` を追加する。

### アップグレード

```bash
mise install   # config.toml の latest を反映
codegraph upgrade --check
```

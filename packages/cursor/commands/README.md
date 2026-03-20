# commands/

Cursor カスタムスラッシュコマンドの定義ファイル。チャット内で `/command-name` と入力して起動する。

## コマンド一覧

### 共有コマンド（git 管理）

| ファイル                    | コマンド                  | カテゴリ    | 説明                                                 |
| --------------------------- | ------------------------- | ----------- | ---------------------------------------------------- |
| `magi.md`                   | `/magi`                   | Decision    | MAGI システムによる多角的意思決定支援（3体合議）     |
| `suggest-branch-name.md`    | `/suggest-branch-name`    | Development | 変更内容からブランチ名を松竹梅で提案                 |
| `suggest-commit-message.md` | `/suggest-commit-message` | Development | ステージング内容からコミットメッセージを松竹梅で提案 |

### ローカルコマンド（`*.local.md`、git 管理外）

ローカルコマンドは環境固有・プロジェクト固有のため git 管理外。以下は参考としてのファイル名パターン:

- `apply-coding-rule.local.md` — コーディングルールの適用
- `blog-review.local.md` — ブログ記事レビュー
- `diff-review.local.md` — 差分レビュー
- `magi-pr-review.local.md` — MAGI による PR レビュー
- `pr-review.local.md` — PR レビュー
- `suggest-development-log.local.md` — 開発ログの提案
- `suggest-pr-description.local.md` — PR 概要の提案
- `suggest-scout-message.local.md` — スカウト文面の提案

## Frontmatter 仕様

コマンドファイルは YAML frontmatter で以下のメタデータを定義する:

```yaml
---
name: /command-name # スラッシュコマンド名（/ 付き）
id: command-name # 一意の識別子
category: Development # カテゴリ（Development, Decision 等）
description: 説明文 # コマンドの説明
---
```

## ルール参照パス

コマンドからルールを参照する場合は `~/.cursor/rules/...` の絶対パスを使用する。これは `stow` デプロイ後のパスであり、Cursor が実行時に読み込む前提。

```markdown
**参照ルール**: `~/.cursor/rules/branch-name-rule.mdc`
```

## 新規コマンドの追加手順

1. 上記の frontmatter 仕様に従ってコマンドファイルを作成する
2. 共有コマンドは `<name>.md`、ローカル専用は `<name>.local.md` とする
3. ルールを参照する場合は `~/.cursor/rules/` の絶対パスで記述する
4. この README のコマンド一覧を更新する（共有コマンドの場合）

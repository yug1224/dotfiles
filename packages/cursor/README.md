# ~/.cursor

Cursor の設定ファイル群。`stow -t ~/.cursor cursor` で `~/.cursor/` にデプロイされる。

## ディレクトリ構成

```
packages/cursor/
├── agents/          # カスタムエージェント定義
│   ├── melchior-1.md
│   ├── balthasar-2.md
│   └── casper-3.md
├── commands/        # カスタムコマンド（/slash コマンド）
│   ├── magi.md
│   ├── suggest-commit-message.md
│   └── suggest-branch-name.md
├── rules/           # Cursor ルール
│   ├── branch-name-rule.mdc
│   ├── commit-message-rule.mdc
│   └── blog-review-rule.mdc
├── .gitignore
└── README.md
```

## ローカル設定の規約

環境固有・プロジェクト固有の設定は `*.local.*` サフィックスを付けて管理する。

- `*.local.*` ファイルは `.gitignore` により git 管理外
- 共通ファイルと同じディレクトリに配置する（サブディレクトリ不要）
- ファイルが存在しない環境でもエラーにならない

### 例

```
rules/
├── commit-message-rule.mdc          # 共通（git 管理）
├── coding-rule.local.mdc            # ローカル（git 管理外）
└── pr-review-rule.local.mdc         # ローカル（git 管理外）

commands/
├── magi.md                           # 共通（git 管理）
└── pr-review.local.md                # ローカル（git 管理外）
```

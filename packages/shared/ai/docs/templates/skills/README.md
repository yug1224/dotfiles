# プロジェクト Skills 配置ガイド（テンプレ）

dotfiles リポジトリには **実行時 Skills を同梱しない**。各業務リポジトリの `.cursor/skills/`（または Claude 同等）を正本とする。

## 命名

| 項目     | 規則                                                                                                                              |
| -------- | --------------------------------------------------------------------------------------------------------------------------------- |
| 形       | kebab-case・**名詞先頭** `<domain>-<pattern>`（または `<feature>-<concern>`）                                                     |
| 例       | `list-page-pattern`, `checkout-api-errors`                                                                                        |
| 禁止先頭 | コマンド動詞プレフィックス: `suggest-` / `review-` / `plan-` / `write-` / `capture-` / `analyze-` / `apply-` / `verify-` / `magi` |
| `name:`  | frontmatter の `name:` は **ディレクトリ名（skill-id）と一致**                                                                    |

コマンド（動詞先頭 `/suggest-…`）とスキル（名詞先頭）は名前空間を分離する。スキル側でコマンド動詞を先頭に付けると slash と衝突しやすい。

コマンド命名の正本: [CONVENTIONS.md](../../../CONVENTIONS.md) の「コマンド命名」。

## いつ skill を使うか

| 手段               | 用途                                            |
| ------------------ | ----------------------------------------------- |
| shared rules       | 再発防止・自己申告（✅️:）・レビュー手順（横断） |
| shared commands    | 手順固定ワークフロー                            |
| **project skills** | 画面パターン・ドメイン API・社内規約の深い手順  |

## 配置例（業務リポジトリ側）

```
.cursor/skills/
└── list-page-pattern/
    └── SKILL.md
```

## dotfiles からの参照

`pr-review-rule.local.md` または `coding-rule.local.md` に、Read 対象 skill パスを列挙する（**リポジトリ相対パスのみ**）。

```markdown
## プロジェクト skill 参照

- `@.cursor/skills/list-page-pattern/SKILL.md` — 一覧画面レビュー時
```

## 禁止

- dotfiles の `packages/shared/` に社内 skill 本文をコミットしない
- skill 内に private URL・認証情報を書かない

## 関連

- [LOCAL-SETUP.md](../../LOCAL-SETUP.md) — `.local.*` 初期化の正本
- [CONVENTIONS.md](../../../CONVENTIONS.md) — コマンド／スキル命名
- [conventions/README.md](../conventions/README.md) — ローカルルール要約

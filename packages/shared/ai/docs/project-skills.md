# プロジェクト Skills 配置ガイド

業務リポジトリ側の Skill を、Cursor / Claude Code の両方から同じ名前で引くための規約。dotfiles が入れる Skill（yug1224/skills。`gh skill` で `~/.claude/skills` にコピー）の使い分けは [CONVENTIONS.md](../CONVENTIONS.md)「Skill の自動発火」。

## 置き場は `.claude/skills/` に一本化する

Cursor は `.cursor/skills/` に加えて `.claude/skills/` と `~/.claude/skills/` も読む（[Cursor Docs: Agent Skills](https://cursor.com/docs/context/skills)）。Claude Code が読むのは `.claude/skills/` だけなので、ここに置けば 1 箇所で両ツールに効く。

| 種別                   | 正本                                                  | 置き場                                |
| ---------------------- | ----------------------------------------------------- | ------------------------------------- |
| プロジェクト Skill     | 業務リポジトリ内の本文                                | `<repo>/.claude/skills/<id>/SKILL.md` |
| 汎用 Skill             | yug1224/skills の `skills/<id>/SKILL.md`              | `~/.claude/skills/<id>/SKILL.md`      |
| 社内 Skill（機密あり） | push しない private リポジトリの `skills/local-<id>/` | `~/.claude/skills/local-<id>/`        |

`.cursor/skills/` や `~/.cursor/skills/` にも同じ Skill を置くと、Cursor では同名 Skill が 2 つ見える。両方に置かない。

## 命名

| 項目     | 規則                                                                                 |
| -------- | ------------------------------------------------------------------------------------ |
| 形       | kebab-case・**名詞先頭** `<domain>-<pattern>`（または `<feature>-<concern>`）        |
| 例       | `list-page-pattern`, `checkout-api-errors`                                           |
| 禁止先頭 | コマンド動詞プレフィックス: `suggest-` / `review-` / `plan-` / `analyze-` / `apply-` |
| `name:`  | frontmatter の `name:` は **ディレクトリ名（skill-id）と一致**                       |

dotfiles の Skill（動詞先頭 `/suggest-…`、ローカルは `/local-…`）と業務リポジトリの Skill（名詞先頭）は名前空間を分ける。どちらも同じ Skill 一覧に出るので、名前が衝突すると区別できなくなる。命名の正本は [CONVENTIONS.md](../CONVENTIONS.md)。

## Skill・ルールの使い分け

| 手段           | 用途                                           |
| -------------- | ---------------------------------------------- |
| shared rules   | リポジトリ横断の再発防止・レビュー基準         |
| shared skills  | 手順固定のワークフロー                         |
| project skills | 画面パターン・ドメイン API・社内規約の深い手順 |

## dotfiles のルールから Skill を参照する

`local-rules/references/conventions/` の `code-review-rule.local.md` や `coding-rule.local.md` に、Read させたい Skill のパスを **リポジトリ相対** で列挙する。

```markdown
## プロジェクト skill 参照

- `.claude/skills/list-page-pattern/SKILL.md` — 一覧画面レビュー時に Read
```

## 社内 Skill（Git 管理外）

機密を含みうる Skill は、GitHub に push しない private リポジトリの `skills/local-<id>/` に置き、`gh skill install --from-local` で入れる（[setup-local-files.md](./setup-local-files.md)「インストール」）。自動で発火させたくないときは frontmatter に `disable-model-invocation: true` を付ける。両ツールとも、明示的に `/<id>` で呼んだときだけ読み込む。

識別子・機密数値・非公開 URL は Skill 本文に書かず、`local-rules/references/<domain>/*.local.md` に分ける。

## 禁止

- 社内 Skill の本文を公開リポジトリ（dotfiles・yug1224/skills）に **Git コミットしない**
- Skill 内に private URL・認証情報を書かない（Git 外の本文でも同じ）

Cursor が `~/.claude/skills` を読むのは互換パス扱い。Cursor のチャットで `/` 補完に dotfiles の Skill（例: `suggest-commit-message`）が出るかで確認する。

## 関連

- [setup-local-files.md](./setup-local-files.md) — `*.local.*` の置き場
- [CONVENTIONS.md](../CONVENTIONS.md) — コマンド／Skill 命名

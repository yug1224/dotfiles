# ローカル AI ルール初期化

`.local.*` は **Git 管理しない**（`packages/shared/shared/ai/.gitignore`）。展開先（`~/.config/shared/ai/`）で個人・プロジェクト固有ルールを直接編集する。

公開境界の契約は [BOUNDARY.md](./BOUNDARY.md) を参照。

## 前提

```bash
make mise-dotfiles   # shared → ~/.config/shared/ai/
```

## ルールファイル

`~/.config/shared/ai/rules/conventions/`:

| ファイル                         | 用途                                     | 典型層        |
| -------------------------------- | ---------------------------------------- | ------------- |
| `coding-rule.local.md`           | **実装時**のコーディング規約             | L2            |
| `pr-review-rule.local.md`        | **レビュー時**の追加観点                 | L1/L2 overlay |
| `review-common-rule.local.md`    | レビュー共通のローカル追記               | L1 overlay    |
| `pr-feedback-registry.local.md`  | フィードバック registry（FB-00x / FB-D） | L2            |
| `ticket-retrieval-rule.local.md` | チケット取得のプロバイダ固有アダプタ     | L1/L2 overlay |

```bash
SHARED=~/.config/shared/ai
mkdir -p "$SHARED/rules/conventions" "$SHARED/docs"
touch "$SHARED/rules/conventions/coding-rule.local.md" \
      "$SHARED/rules/conventions/pr-review-rule.local.md" \
      "$SHARED/rules/conventions/review-common-rule.local.md" \
      "$SHARED/rules/conventions/pr-feedback-registry.local.md" \
      "$SHARED/rules/conventions/ticket-retrieval-rule.local.md" \
      "$SHARED/docs/feedback-log.local.md" \
      "$SHARED/docs/feedback-index.local.md"
```

## コマンドリネーム対応表（ローカル追従用）

コマンド basename 変更後、手元の `*.local.md` / Cursor・Claude ラッパー内の `@~/.config/shared/ai/commands/<name>.md` を旧名から新名へ更新する。

| 旧                      | 新                     |
| ----------------------- | ---------------------- |
| `pr-review`             | `review-pr`            |
| `diff-review`           | `review-diff`          |
| `blog-review`           | `review-blog`          |
| `magi-pr-review`        | `review-pr-magi`       |
| `blog-plan`             | `plan-blog`            |
| `capture-pr-lesson`     | `capture-pr-feedback`  |
| `fix-issue`             | `analyze-issue`        |
| `graphic-record-prompt` | `write-graphic-prompt` |

（上記 8 件。ローカル側の `fix-issue.local.md` 等も新 basename に合わせてリネームする。）

## フィードバックの蒸留

log / index / registry は **すべて local**:

1. `docs/feedback-log.local.md` に記録
2. `docs/feedback-index.local.md` に ID を追加
3. `pr-feedback-registry.local.md` に概要行を追加
4. 詳細を shared rule（汎用化できたもの）または `*.local.md` に追記

**dotfiles Git には log / index / registry をコミットしない。** Git に載せるのは蒸留先となった shared rules / commands のみ。

## Cursor 専用（任意）

`~/.cursor/rules/**/*.local.mdc`（`packages/cursor/.gitignore` 対象）

## 実装 vs レビューの分離

| フェーズ | 主なファイル                                       | サブエージェント   |
| -------- | -------------------------------------------------- | ------------------ |
| 実装     | `coding-rule.local.md`                             | ローカル定義に従う |
| レビュー | `review-common-rule` + `pr-review-rule` + registry | **明示時のみ**     |

## Git に載せないもの

- 会社名・製品名・private org/repo URL・業務ツールの private URL
- `*.local.*` 全文（`feedback-*.local.md` / `pr-feedback-registry.local.md` 含む）
- 業務リポジトリ固有の詳細ルール（未汎用化分）

詳細: [PR-FEEDBACK-PLAYBOOK.md](./PR-FEEDBACK-PLAYBOOK.md) / [BOUNDARY.md](./BOUNDARY.md)

応答の冒頭に「Applied: ai-config-rule」と出力する。

# AI 設定変更ルール（dotfiles）

`packages/shared/ai/` および Cursor / Claude ラッパーを変更するときの手順。`alwaysApply: false` — dotfiles リポジトリで AI 設定を触るときのみ Read。

## 3 ラッパー原則

1. **正本**: `packages/shared/ai/` に frontmatter なし `.md`
2. **Cursor**: `packages/cursor/rules/<subdir>/<name>.mdc` — frontmatter + `@~/.config/shared/ai/rules/<subdir>/<name>.md`
3. **Claude**: `packages/claude/rules/<subdir>/<name>.md` — 1 行 `@import`

コマンド・エージェントも同型（shared 正本 → 各 `packages/<tool>/` ラッパー）。

## 追加・変更手順

1. shared 本文を追加・修正（1 行目に `Applied: <rule-id>` を shared のみ記載）
2. Cursor `.mdc` と Claude `.md` ラッパーを **同時** に追加・更新
3. `wrapper-parity-checklist.md` と `leakage-checklist.md` を上から確認
4. `make mise-dotfiles` で shared 本文と Cursor / Claude ラッパーを反映

## 例外

| ファイル                      | ラッパー | 理由                      |
| ----------------------------- | -------- | ------------------------- |
| `output-verification-rule.md` | なし     | コマンドから直接 `@` 参照 |

## CLAUDE.md Tier 判定

| Tier          | 内容                             | 例                                                  |
| ------------- | -------------------------------- | --------------------------------------------------- |
| A（常時）     | `CLAUDE.md` から `@./rules/...`  | token-optimization, commit-message, review-common   |
| B（参照）     | agent-requestable / コマンド経由 | meta ルール、`pr-feedback-registry.local`（存在時） |
| C（ローカル） | `.local.md` のみ                 | coding-rule.local, pr-review-rule.local             |

新規 convention は Tier B をデフォルトとし、`alwaysApply: true` は token-optimization のみ。

## 禁止

- shared 本文に frontmatter を書く
- ラッパーに `Applied:` を書く（正本のみ）
- Git 管理ファイルに会社名・非公開 URL を書く
- 1 ファイルだけ更新してラッパーを放置（FB-005）

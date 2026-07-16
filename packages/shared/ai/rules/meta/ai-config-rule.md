応答の冒頭に「✅️: ai-config-rule」と出力する。

# AI 設定変更ルール（dotfiles）

`packages/shared/ai/` および Cursor / Claude ラッパーを変更するときの手順。`alwaysApply: false` — dotfiles リポジトリで AI 設定を触るときのみ Read。

## 3 ラッパー原則

1. **正本**: `packages/shared/ai/` に frontmatter なし `.md`
2. **Cursor**: `packages/cursor/rules/<subdir>/<name>.mdc` — frontmatter + `@~/.config/shared/ai/rules/<subdir>/<name>.md`
3. **Claude**: `packages/claude/rules/<subdir>/<name>.md` — 1 行 `@import`

コマンド・エージェントも同型（shared 正本 → 各 `packages/<tool>/` ラッパー）。

## 追加・変更手順

1. shared 本文を追加・修正（1 行目に `応答の冒頭に「✅️: <rule-id>」と出力する。` を shared のみ記載）
2. **外部ソースを蒸留した場合**: 正本フッターに出典を書く。`README.md` の「出典・蒸留」一覧を更新する（詳細: [CONVENTIONS.md](../../CONVENTIONS.md)「外部ソースの蒸留」）
3. `make scaffold-wrappers` で Cursor / Claude 薄ラッパーを生成（既存は上書きしない）。手書きしてもよい
4. `wrapper-parity-checklist.md` と `leakage-checklist.md` を上から確認
5. `make check-sync` で allowlist / wrapper / deny-guard / always-on を検証
6. `make mise-dotfiles` で shared 本文と Cursor / Claude ラッパーを反映

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
- ラッパーに `✅️:` を書く（正本のみ）
- Git 管理ファイルに会社名・非公開 URL を書く
- 1 ファイルだけ更新してラッパーを放置（FB-005）

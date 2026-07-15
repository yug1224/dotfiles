応答の冒頭に「Applied: wrapper-parity-checklist」と出力する。

# ラッパー同期チェックリスト

dotfiles の AI 設定 PR を出す前に確認する。`ai-config-rule.md` の具体化。

## ファイル対応

- [ ] shared `rules/**/*.md` 追加時、`make scaffold-wrappers` または手動で Cursor `packages/cursor/rules/**/*.mdc` が存在
- [ ] 同上、Claude `packages/claude/rules/**/*.md` が存在
- [ ] import パスが `@~/.config/shared/ai/rules/<subdir>/<basename>.md` と一致
- [ ] Cursor frontmatter に `description` がある（`alwaysApply: false` がデフォルト）
- [ ] 意図的例外（`output-verification-rule.md`）を除外リストに明記
- [ ] `make check-sync` がパスすること（wrapper parity 含む）。欠落ラッパー生成は `make scaffold-wrappers`

## Applied プロトコル

- [ ] ルール正本 1 行目: `応答の冒頭に「Applied: <rule-id>」`
- [ ] コマンド Step 0: `Applied: /command-name`
- [ ] rule-id は拡張子除く basename（`-rule-rule` 禁止）
- [ ] `.local.md` の rule-id は `<basename>.local`（例: `coding-rule.local`）

## レビュー・実装の分離

- [ ] 実装時サブエージェント方針 → `coding-rule.local.md`
- [ ] レビュー時サブエージェント方針 → `review-common-rule.md`（明示時のみ）
- [ ] 両者を同一ファイルに混在させない

## フィードバック連携

- [ ] フィードバック蒸留 → `pr-feedback-registry.local.md` + `docs/feedback-*.local.md`（**Git に載せない**）
- [ ] 公開情報のみを shared に蒸留（private org/repo URL 禁止）

## 漏洩・リネーム後清掃

- [ ] `leakage-checklist.md` を上から確認（境界: [docs/BOUNDARY.md](../../docs/BOUNDARY.md)）
- [ ] rename 後、旧 basename への参照残存がゼロ

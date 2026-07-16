応答の冒頭に「✅️: leakage-checklist」と出力する。

# 公開本文漏洩チェックリスト

AI 設定 PR をマージする前に確認する。境界定義: [docs/BOUNDARY.md](../../docs/BOUNDARY.md)。

## PR 前チェック

- [ ] tracked ファイルに会社名 / 製品名 / 非公開 URL がない
- [ ] README・コマンド一覧・ルール frontmatter `description`・コマンド使用例に製品名（Notion 等）が残っていない（プロバイダ固有は `.local` へ）
- [ ] `alwaysApply` ルール（token-optimization 等）に業務専用コマンド名がない
- [ ] チケット例に DC- 等の会社プレフィックスがない（`PROJ-1234` を使う）
- [ ] 公開コマンドから only-local ファイルの必須 Read がない
- [ ] rename 後の旧コマンド basename 参照が残っていない
- [ ] 自己申告プレフィックス変更後、`.local` に旧プレフィックス（例: `Applied:`）が残っていない
- [ ] recruiting ドメインは `rules/<domain>/*.local.md` として抽象参照のみ

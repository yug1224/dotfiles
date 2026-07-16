応答の冒頭に「✅️: branch-name-rule」と出力する。

# ブランチ名規約

## 基本原則

- **英字小文字**: すべて小文字で記述
- **ハイフン区切り**: 単語はハイフン（-）で区切る
- **簡潔に**: 変更内容が一目でわかる名前（**全体で50文字以内**を目安）
- **チケット ID**: タスクと紐付ける場合は description の先頭に付与（任意）

---

## フォーマット

### 基本形式

```
<type>/<description>
```

### チケット ID を含める場合（任意）

```
<type>/<ticket-id>-<description>
```

**例**:

```
feat/user-filter
feat/PROJ-1234-user-filter
fix/PROJ-5678-api-null-error
refactor/PROJ-9012-query-service-separation
```

---

## タイプ（Type）

| Type         | 説明                     |
| ------------ | ------------------------ |
| **feat**     | 新機能の追加             |
| **fix**      | バグ修正                 |
| **refactor** | 動作を変えないコード改善 |
| **perf**     | パフォーマンス改善       |
| **docs**     | ドキュメント変更         |
| **style**    | フォーマット変更         |
| **test**     | テスト追加・修正         |
| **chore**    | ビルド・ツール変更       |

---

## 実践例

### ✅ Good

```
feat/user-list-filtering
feat/PROJ-1234-user-list-filtering
fix/PROJ-5678-null-response-handling
refactor/separate-query-service
chore/update-dependencies
```

### ❌ Bad

```
feature/UserListFiltering
```

→ 大文字を使用している、type が長い（`feature` → `feat`）

```
fix_bug
```

→ アンダースコア使用、何のバグか不明

```
PROJ-1234
```

→ type なし、description なし

```
update
```

→ type なし、変更内容が不明確

---

## よく使うパターン

| パターン           | 基本形式                     | チケット ID 付き                       |
| ------------------ | ---------------------------- | -------------------------------------- |
| 機能追加           | `feat/user-authentication`   | `feat/PROJ-1234-user-authentication`   |
| バグ修正           | `fix/login-validation`       | `fix/PROJ-5678-login-validation`       |
| リファクタリング   | `refactor/user-api`          | `refactor/PROJ-9012-user-api`          |
| 依存関係更新       | `chore/deps-update`          | `chore/deps-update`                    |
| ドキュメント更新   | `docs/update-readme`         | `docs/PROJ-3456-update-readme`         |
| 緊急修正（Hotfix） | `fix/security-vulnerability` | `fix/PROJ-7890-security-vulnerability` |

---

## 関連規約（Git 運用の一貫性）

ブランチの `type` は [コミットメッセージ規約](./commit-message-rule.md) および [PR概要の記述ルール](./pr-description-rule.md)（PR タイトル）と同一 8 種を用い、**同じ変更では `type` を揃える**（例: ブランチ `feat/...` → コミット・PR タイトル `feat(scope): ...`）。

チケット ID の表記はブランチでは `type/PROJ-1234-description`、コミット / PR タイトルでは末尾の `[PROJ-1234]` と異なるが、いずれも任意である。

---

## 参考

- [Conventional Commits](https://www.conventionalcommits.org/ja/)

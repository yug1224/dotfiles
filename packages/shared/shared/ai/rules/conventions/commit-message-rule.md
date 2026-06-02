応答の冒頭に「Applied: commit-message-rule」と出力する。

# コミットメッセージ規約

## 基本原則

- **1コミット = 1論理的変更**: コミットは小さく、目的を1つに絞る
- **「なぜ」を説明する**: 「何を」変更したかではなく、「なぜ」変更したかを記述する
- **日本語で記述**: コミットメッセージは日本語で書く（技術用語は英語可）

---

## フォーマット

```
<type>(<scope>): <subject> [<ticket-id>]

<body>

<footer>
```

### ヘッダー（必須）

- **ヘッダー全体で72文字以内**（subject 部分は50文字以内を目安）
- type: 小文字、scope: kebab-case
- 末尾にピリオド不要
- `[ticket-id]` は任意。チケット ID 等が判明している場合のみ、半角スペース + 角括弧で subject の末尾に付与する

```
feat(user-list): フィルタリング機能を追加
fix(api-client): API応答のnull値エラーを修正
feat(user-list): フィルタリング機能を追加 [PROJ-1234]
fix(api-client): API応答のnull値エラーを修正 [PROJ-5678]
```

### ボディ（推奨）

- ヘッダーとの間に1行空ける
- 句点で適切に改行
- 「なぜ」と「何が変わったか」を説明
- 主な変更点を箇条書き

```
- カテゴリ選択UIを実装
- APIクエリパラメータにcategoryを追加
```

### フッター（任意）

- ボディとの間に1行空ける
- Issue / チケットの参照や破壊的変更の明示に使用

```
Closes #123
```

```
BREAKING CHANGE: レスポンスの `items` フィールドを `data` にリネーム
```

---

## タイプ（Type）

| Type         | 説明                               |
| ------------ | ---------------------------------- |
| **feat**     | 新機能の追加                       |
| **fix**      | バグ修正                           |
| **refactor** | 動作を変えないコード改善           |
| **perf**     | パフォーマンス改善                 |
| **docs**     | ドキュメント変更                   |
| **style**    | フォーマット変更（意味に影響なし） |
| **test**     | テスト追加・修正                   |
| **chore**    | ビルド・ツール変更                 |

**選択のコツ**:

- ユーザーに影響がある変更 → `feat` / `fix`
- 動作が変わらない改善 → `refactor`
- 迷ったらコミットを分割

---

## スコープ（Scope）

変更が影響する範囲を示す（kebab-case）。プロジェクト構造に応じて命名。

**例**:

- フロントエンド: `user-list`, `form-factory`, `api-client`
- バックエンド: `user-api`, `auth`, `notification`
- インフラ: `cdk-stack`, `github-actions`
- 共通: `deps`, `ci`, `config`

スコープが不明確な場合は省略可能。

---

## 実践例

### ✅ Good

```
feat(user-list): フィルタリング機能を追加

- カテゴリ選択UIを実装
- APIクエリパラメータにcategoryを追加
```

```
fix(api-client): null値レスポンスのハンドリングを修正

- レスポンスのnullチェックを追加
- フォールバック値の設定ロジックを実装
```

```
feat(auth): OAuth2認証フローを追加

- Google OAuth2のコールバック処理を実装
- セッション管理ミドルウェアを追加

Closes #123
```

```
feat(user-list): フィルタリング機能を追加 [PROJ-1234]

- カテゴリ選択UIを実装
- APIクエリパラメータにcategoryを追加
```

### ❌ Bad

```
fix: バグ修正
```

→ スコープなし、何のバグか不明、理由なし

```
feat: 一覧画面とユーザー管理を追加
```

→ 複数の変更を1コミットに含めている

```
refactor(user): コードを整理
```

→ 「なぜ」がない、何が改善されたか不明

---

## コミット前チェックリスト

- [ ] `git --no-pager diff --staged` でステージング内容を確認
- [ ] 1コミット = 1論理的変更
- [ ] ヘッダー全体72文字以内（subject 50文字以内）
- [ ] 「なぜ」を説明している
- [ ] チケット ID が判明している場合はヘッダー末尾に `[TICKET-ID]` を付与
- [ ] 破壊的変更がある場合は `BREAKING CHANGE:` を記載
- [ ] テストとLintが通る

### よく使うコマンド

```bash
git --no-pager diff --staged        # ステージング確認
git --no-pager diff --staged --stat # ステージング概要
git add -p                          # 対話的にステージング
git commit --amend                  # コミット修正（push前のみ）
```

---

## 参考

- [Conventional Commits](https://www.conventionalcommits.org/ja/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)

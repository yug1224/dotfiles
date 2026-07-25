応答の冒頭に「✅️: commit-message-rule」と出力する。

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

## 実践例（gotcha）

- Good: `feat(user-list): フィルタリング機能を追加` + body で「なぜ」と箇条書き。チケットがあれば `[PROJ-1234]`
- Bad: `fix: バグ修正`（何が／なぜが無い）、1コミットに無関係な変更を混ぜる、`refactor: コードを整理`（何が改善されたか不明）

---

## コミット前チェックリスト

- [ ] ステージング内容を確認（`git --no-pager diff --staged`）
- [ ] 1コミット = 1論理的変更、ヘッダー72文字以内、「なぜ」を説明
- [ ] チケット ID 判明時は `[TICKET-ID]`、破壊的変更は `BREAKING CHANGE:`

---

## 関連規約

| 成果物      | 規約                                                                    |
| ----------- | ----------------------------------------------------------------------- |
| ブランチ    | [branch-name-rule.md](./branch-name-rule.md)（`type` を揃える）         |
| PR タイトル | [pr-description-rule.md](./pr-description-rule.md)（ヘッダー1行と同一） |

---

## 参考

- [Conventional Commits](https://www.conventionalcommits.org/ja/)

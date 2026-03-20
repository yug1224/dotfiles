# skills/

エージェントスキルの定義ファイル。会話コンテキストからタスクの種類を自動検出し、適切な Advisor エージェントにディスパッチする。

## スキル一覧

各スキルは Advisor エージェントと 1:1 で対応する。

| ディレクトリ         | 対応エージェント    | トリガー例                                        |
| -------------------- | ------------------- | ------------------------------------------------- |
| `a11y-advisor/`      | `a11y-advisor`      | アクセシビリティ、WCAG、ARIA、フォーカス管理      |
| `api-advisor/`       | `api-advisor`       | API 設計、エンドポイント設計、OpenAPI             |
| `architect-advisor/` | `architect-advisor` | アーキテクチャ、非機能要件、技術選定              |
| `backend-advisor/`   | `backend-advisor`   | エンドポイント実装、サービス、モジュール          |
| `database-advisor/`  | `database-advisor`  | スキーマ、マイグレーション、テーブル設計          |
| `domain-advisor/`    | `domain-advisor`    | DDD、ドメインモデリング、集約設計、ユビキタス言語 |
| `frontend-advisor/`  | `frontend-advisor`  | コンポーネント、ページ実装、UI                    |
| `infra-advisor/`     | `infra-advisor`     | CDK、デプロイ、CI/CD、Docker                      |
| `review-advisor/`    | `review-advisor`    | PR レビュー、コードレビュー                       |
| `security-advisor/`  | `security-advisor`  | セキュリティ、認証、認可、脆弱性対策              |
| `test-advisor/`      | `test-advisor`      | テスト、カバレッジ、テストケース設計              |

## 3 Phase ディスパッチパターン

すべてのスキルは共通の 3 Phase 構造に従う。

```
Phase 1: コンテキスト収集
  ↓
Phase 2: サブエージェントへの委譲
  ↓
Phase 3: 結果の適用
```

### Phase 1: コンテキスト収集

プロジェクトルール、既存実装パターン、ライブラリドキュメント等を収集し、ユーザーに報告する。

### Phase 2: サブエージェントへの委譲

Task ツールで対応する Advisor エージェントを起動し、Phase 1 で収集したコンテキストとタスク内容を渡す。

### Phase 3: 結果の適用

サブエージェントの分析結果を確認し、必要に応じて他の Advisor への委譲や追加アクションを実行する。

## Skill と Agent の関係

Skill の Phase 1 と Agent の「行動原則 > 調査フロー」には意図的な重複がある。

| 経路             | 動作                                                                                        |
| ---------------- | ------------------------------------------------------------------------------------------- |
| **Skill 経由**   | Skill が Phase 1 でコンテキスト収集し、Agent に渡す。Agent は渡されたコンテキストを活用する |
| **直接呼び出し** | Agent が自ら「行動原則」に従って調査を行う                                                  |

この二重構造により、どちらの経路で呼び出されてもエージェントが適切に機能する。

## SKILL.md の構造

```markdown
---
name: <advisor-name>
description: <description with trigger keywords>
---

# <Name> Dispatcher

## トリガー条件

## Phase 1: コンテキスト収集

### 収集完了時の出力

## Phase 2: サブエージェントへの委譲

## Phase 3: 結果の適用
```

### Frontmatter の description

`description` にはトリガーキーワードを日本語・英語の両方で含める。Cursor がスキルの自動検出に使用する。

## 新規スキルの追加手順

1. `skills/<advisor-name>/SKILL.md` を作成する
2. 上記の構造に従い、Phase 1〜3 を定義する
3. 対応する Agent が `agents/<advisor-name>.md` に存在することを確認する（なければ先に作成）
4. この README のスキル一覧を更新する

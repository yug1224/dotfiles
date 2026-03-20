---
name: database-advisor
description: Guides database schema design and migration by delegating to the database-advisor specialist agent. Use when designing schemas, creating migrations, adding tables, defining relations, optimizing indexes, or working with Prisma. Triggers for schema, migration, table, relation, index, Prisma, database, column, スキーマ, マイグレーション, テーブル, カラム, データベース.
---

# Database Advisor Dispatcher

データベース設計タスクを検出し、`database-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- テーブル/モデルの追加・変更
- リレーションの設計
- マイグレーションの作成
- インデックスの追加・最適化
- Prisma スキーマの編集

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のデータベース関連ルールを Read で収集する
2. **既存スキーマ**: Glob でスキーマファイル (`prisma/schema/`, `drizzle/`, `src/entities/` 等) の配置を把握し、Read で関連ドメインのスキーマを読み込む
3. **既存パターン**: Grep で既存のインデックス定義、リレーションパターン、命名規則を調査する
4. **ライブラリドキュメント**: context7 MCP でプロジェクトの ORM / クエリビルダー（Prisma, TypeORM, Drizzle 等）の最新仕様を確認する (`resolve-library-id` → `query-docs`)

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存スキーマ**: (参照したスキーマファイルとモデル構造の要約)
> - **既存パターン**: (インデックス・リレーションの命名規則の要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)

## Phase 2: サブエージェントへの委譲

Task ツールで `database-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `database-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存スキーマ: (渡すスキーマの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のデータベースルール
  - 関連ドメインの既存スキーマ
  - 既存の命名規則・インデックスパターン
  - Prisma の最新仕様

## Phase 3: 結果の適用

サブエージェントの提案に基づいて実装する:

1. 提案されたスキーマ変更を適用する
2. プロジェクトの ORM に対応するバリデーション・フォーマットコマンド（例: `npx prisma validate` / `npx prisma format`）で検証する
3. 必要に応じてマイグレーションを生成する
4. 問題があれば `database-advisor` に再度相談する

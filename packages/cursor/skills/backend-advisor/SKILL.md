---
name: backend-advisor
description: Guides backend API development by delegating to the backend-advisor specialist agent. Use when implementing API endpoints, controllers, services, modules, use cases, DTOs, guards, or any backend feature. Triggers for API endpoint, controller, service, module, usecase, DTO, guard, middleware, バックエンド, エンドポイント, モジュール.
---

# Backend Advisor Dispatcher

バックエンド開発タスクを検出し、`backend-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- API エンドポイントの追加・修正
- モジュール/コントローラー/サービスの作成
- ユースケースの実装
- DTO の設計
- ガード/ミドルウェアの追加

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のバックエンド関連ルール（アーキテクチャ、コーディング規約等）を Read で収集する
2. **既存パターン**: Glob でバックエンドの `src/` 配下のモジュール構造を把握し、Grep/SemanticSearch で同ドメインの既存モジュールを調査する
3. **ライブラリドキュメント**: context7 MCP でプロジェクトのバックエンドフレームワーク（NestJS, Express 等）やバリデーションライブラリの最新 API を確認する (`resolve-library-id` → `query-docs`)

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存パターン**: (参照したモジュール構造とコードファイルの要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)

## Phase 2: サブエージェントへの委譲

Task ツールで `backend-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `backend-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存パターン: (渡す既存パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のアーキテクチャルール
  - 同ドメインの既存モジュール構成とコードスニペット
  - ライブラリの最新 API ドキュメント

## Phase 3: 結果の適用

サブエージェントの提案に基づいて実装する:

1. 提案されたモジュール構成に従ってコードを作成する
2. `package.json` の scripts を確認し、該当するリント・型チェックコマンドで検証する
3. 問題があれば `backend-advisor` に再度相談する

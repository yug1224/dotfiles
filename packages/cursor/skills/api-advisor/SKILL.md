---
name: api-advisor
description: Guides API interface design by delegating to the api-advisor specialist agent. Use when designing API contracts, endpoint structures, request/response types, or OpenAPI specifications. Triggers for API design, API contract, OpenAPI, endpoint design, REST API, interface design, API 設計, インターフェース設計, エンドポイント設計.
---

# API Advisor Dispatcher

API 設計タスクを検出し、`api-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- 新規 API エンドポイントの設計
- リクエスト/レスポンス型の定義
- OpenAPI 仕様の策定
- API バージョニングの検討
- Breaking change の影響分析

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内の API 関連ルールを Read で収集する
2. **既存 API パターン**: Grep で既存のコントローラー・DTO を検索し、エンドポイントの命名規則やレスポンス形式を把握する
3. **フロントエンド契約**: Read でフロントエンドの API クライアント型定義 (`schema.d.ts` 等) を確認する
4. **ライブラリドキュメント**: context7 MCP で OpenAPI / プロジェクトの API フレームワーク（NestJS Swagger 等）の最新仕様を確認する (`resolve-library-id` → `query-docs`)

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存パターン**: (参照した既存コードのファイルパスとパターンの要約)
> - **フロントエンド契約**: (API クライアント型定義の有無と要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)

## Phase 2: サブエージェントへの委譲

Task ツールで `api-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `api-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存パターン: (渡す既存パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有の API ルール
  - 既存エンドポイントのパターンとコード例
  - フロントエンドの API クライアント型定義
  - OpenAPI / Swagger の最新仕様

## Phase 3: 結果の適用

サブエージェントの設計提案を確認し、実装を進める:

1. エンドポイント設計を確認する
2. 必要に応じて `backend-advisor` にバックエンド実装を、`frontend-advisor` にフロントエンド統合を委譲する
3. API クライアントの再生成が必要な場合は `package.json` の scripts を確認し、該当するコマンド（例: `pnpm gen-api`）を実行する

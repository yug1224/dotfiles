---
name: domain-advisor
description: Guides domain modeling by delegating to the domain-advisor specialist agent. Use when designing domain models, aggregates, entities, value objects, domain events, ubiquitous language, or context maps. Triggers for DDD, domain-driven design, bounded context, aggregate, entity, value object, domain event, ubiquitous language, context map, domain service, anti-corruption layer, ドメイン駆動設計, 境界づけられたコンテキスト, 集約, エンティティ, 値オブジェクト, ドメインイベント, ユビキタス言語, ドメインモデリング, ドメインサービス.
---

# Domain Advisor Dispatcher

ドメインモデリング関連タスクを検出し、`domain-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- 新機能のドメインモデル設計
- Entity / Value Object の使い分け判断
- 集約の境界設計
- ドメインイベントの設計
- ユビキタス言語の整理
- コンテキストマップの作成
- ドメインモデルのレビュー

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のアーキテクチャ・ドメイン関連ルール（ディレクトリ構成、レイヤー設計、CQRS パターン等）を Read で収集する
2. **既存ドメインモデル**: Grep で既存の Entity / Value Object / Domain Event / Domain Service を検索し、命名規則とパターンを把握する
3. **モジュール構成**: Glob でプロジェクトのディレクトリ構造を把握し、モジュール境界とレイヤー構造を理解する
4. **トランザクション管理**: Grep で UseCase 層のトランザクション管理パターン（PrismaTx, Transaction 等）を確認する
5. **ライブラリドキュメント**: context7 MCP で関連フレームワークの最新仕様を確認する（`resolve-library-id` → `query-docs`）

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存ドメインモデル**: (参照した Entity / VO / Domain Event のファイルパスとパターンの要約)
> - **モジュール構成**: (確認したモジュール境界とレイヤー構造)
> - **トランザクション管理**: (UseCase 層のトランザクション管理パターン)

## Phase 2: サブエージェントへの委譲

Task ツールで `domain-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `domain-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存ドメインモデル: (渡す Entity / VO / Domain Event パターンの要約)
>   - モジュール構成: (渡すモジュール境界・レイヤー構造の要約)
>   - トランザクション管理: (渡すトランザクション管理パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のアーキテクチャ・ドメインルール
  - 既存の Entity / Value Object / Domain Event のパターンとコード例
  - モジュール構成とレイヤー構造
  - トランザクション管理の方式

## Phase 3: 結果の適用

サブエージェントの分析結果を確認し、必要に応じて追加アクションを実行する:

1. ドメインモデル設計を確認する
2. 必要に応じて `backend-advisor` に実装パターン（CQRS, Repository）を、`database-advisor` にスキーマ設計を、`api-advisor` に API 契約を委譲する
3. `package.json` の scripts を確認し、該当するリント・型チェックコマンドで検証する

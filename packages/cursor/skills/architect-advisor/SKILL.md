---
name: architect-advisor
description: Guides architecture design by delegating to the architect-advisor specialist agent. Use when evaluating system architecture, making technology selection decisions, analyzing non-functional requirements, or reviewing architectural fitness. Triggers for architecture, non-functional requirements, technology selection, system design, availability, observability, performance, security, アーキテクチャ, 非機能要件, 技術選定, システム設計.
---

# Architect Advisor Dispatcher

アーキテクチャ設計タスクを検出し、`architect-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- 新機能のアーキテクチャ検討
- 技術選定の相談
- 非機能要件（可用性、可観測性、変更容易性、性能、セキュリティ）の分析
- システム全体の構造設計
- アーキテクチャレビュー

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のアーキテクチャ関連ルール（ディレクトリ構成、レイヤー設計等）を Read で収集する
2. **技術スタック**: `package.json` / `tsconfig.json` 等からプロジェクトの技術スタックを把握する
3. **既存アーキテクチャ**: Glob でプロジェクト全体のディレクトリ構造を把握し、Grep/SemanticSearch で既存のモジュール構成・レイヤー構造を調査する
4. **ライブラリドキュメント**: context7 MCP で関連フレームワークの最新仕様を確認する (`resolve-library-id` → `query-docs`)
5. **監視状況**: Datadog MCP で現行の監視設定を把握する (該当する場合)
6. **非機能要件チェックリスト**: 網羅的な品質特性の確認が必要な場合は [references/non-functional-requirements-checklist.md](references/non-functional-requirements-checklist.md) を参照する

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **技術スタック**: (プロジェクトの主要技術の要約)
> - **既存アーキテクチャ**: (モジュール構成・レイヤー構造の要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)
> - **監視状況**: (Datadog から取得した情報の要約、該当する場合)

## Phase 2: サブエージェントへの委譲

Task ツールで `architect-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `architect-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 技術スタック: (渡す技術スタック情報の要約)
>   - 既存アーキテクチャ: (渡すアーキテクチャ情報の要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のアーキテクチャルール
  - 技術スタック情報
  - 既存のモジュール構成とレイヤー構造
  - フレームワークの最新仕様
  - 現行の監視設定 (該当する場合)

## Phase 3: 結果の適用

サブエージェントの提案を確認し、対応する:

1. アーキテクチャ提案を確認する
2. 必要に応じて各専門エージェントに実装を委譲する:
   - バックエンド実装 → `backend-advisor`
   - フロントエンド実装 → `frontend-advisor`
   - DB スキーマ設計 → `database-advisor`
   - インフラ構築 → `infra-advisor`
   - API 設計 → `api-advisor`
3. 大規模な変更の場合は、段階的な移行計画に沿って進める

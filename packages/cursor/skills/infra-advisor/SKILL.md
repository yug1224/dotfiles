---
name: infra-advisor
description: Guides infrastructure development by delegating to the infra-advisor specialist agent. Use when working with CDK stacks, AWS resources, CI/CD pipelines, Docker configurations, deployment settings, or cloud infrastructure. Triggers for CDK, stack, deploy, AWS, CI/CD, Docker, infrastructure, pipeline, CloudFormation, インフラ, デプロイ, パイプライン.
---

# Infra Advisor Dispatcher

インフラストラクチャ開発タスクを検出し、`infra-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- CDK スタック/コンストラクトの作成・修正
- AWS リソースの追加
- CI/CD ワークフローの設計
- Docker 設定の変更
- デプロイ設定の更新

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のインフラ関連ルール（スタック設計、命名規則等）を Read で収集する
2. **既存パターン**: Glob で IaC コード (`lib/`, `bin/`) と CI/CD ワークフロー (`.github/workflows/`) の構造を把握し、Grep で既存のスタック・コンストラクトパターンを調査する
3. **ライブラリドキュメント**: context7 MCP で AWS CDK の最新コンストラクト API を確認する (`resolve-library-id` → `query-docs`)
4. **監視状況**: Datadog MCP の `get_monitors` / `list_dashboards` で現行の監視設定を把握する (該当する場合)

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存パターン**: (参照したスタック・ワークフローのファイルパスとパターンの要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)
> - **監視状況**: (Datadog から取得した監視設定の要約、該当する場合)

## Phase 2: サブエージェントへの委譲

Task ツールで `infra-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `infra-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存パターン: (渡す既存パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)
>   - 監視状況: (渡す監視情報の要約、該当する場合)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のインフラルール
  - 既存のスタック構成とパターン
  - AWS CDK の最新 API ドキュメント
  - 現行の監視設定 (該当する場合)

## Phase 3: 結果の適用

サブエージェントの提案に基づいて実装する:

1. 提案されたリソース構成に従ってコードを作成する
2. `package.json` の scripts を確認し、該当する型チェック・テストコマンドで検証する
3. 問題があれば `infra-advisor` に再度相談する

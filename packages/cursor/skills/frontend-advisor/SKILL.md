---
name: frontend-advisor
description: Guides frontend UI development by delegating to the frontend-advisor specialist agent. Use when implementing React components, pages, routes, forms, tables, dialogs, layouts, state management, styling, or any frontend feature. Triggers for component, page, route, UI, form, table, dialog, layout, styling, Storybook, フロントエンド, 画面, コンポーネント, ページ.
---

# Frontend Advisor Dispatcher

フロントエンド開発タスクを検出し、`frontend-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- React コンポーネントの作成・修正
- ページ・ルートの追加
- 状態管理の設計 (Zustand, XState)
- API クライアント統合 (TanStack Query)
- UI ライブラリの使用 (Radix UI, Tailwind)
- Storybook ストーリーの作成

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **Storybook MCP**: `get-ui-building-instructions` を呼び出し、プロジェクトのコンポーネント開発指示を取得する
2. **プロジェクトルール**: `.cursor/rules/` 内のフロントエンド関連ルールを Read で収集する
3. **既存パターン**: Glob でフロントエンドの `src/` 配下の構造を把握し、Grep で類似の既存実装を探す
4. **ライブラリドキュメント**: context7 MCP で使用するライブラリの最新 API を確認する (`resolve-library-id` → `query-docs`)
5. **デザイン仕様**: Figma URL が与えられた場合、Figma MCP の `get_design_context` でデザインを取得する

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存パターン**: (参照したコンポーネント・ページのファイルパスとパターンの要約)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)
> - **MCP**: (Storybook / Figma から取得した情報の要約)

## Phase 2: サブエージェントへの委譲

Task ツールで `frontend-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `frontend-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存パターン: (渡す既存パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)
>   - デザイン仕様: (渡すデザイン情報の要約、該当する場合)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - Storybook のコンポーネント開発指示
  - プロジェクト固有のフロントエンドルール
  - 類似する既存実装のコードスニペット
  - ライブラリの最新 API ドキュメント
  - デザイン仕様 (該当する場合)

## Phase 3: 結果の適用

サブエージェントの提案に基づいて実装する:

1. 提案されたファイル構成に従ってコードを作成する
2. `package.json` の scripts を確認し、該当するリント・型チェックコマンドで検証する
3. 問題があれば `frontend-advisor` に再度相談する

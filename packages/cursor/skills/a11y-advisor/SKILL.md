---
name: a11y-advisor
description: Guides accessibility implementation by delegating to the a11y-advisor specialist agent. Use when designing accessible components, reviewing WCAG compliance, implementing ARIA attributes, keyboard navigation, focus management, or screen reader support. Triggers for accessibility, a11y, WCAG, ARIA, screen reader, keyboard navigation, focus management, color contrast, semantic HTML, アクセシビリティ, キーボード操作, フォーカス管理, スクリーンリーダー, コントラスト.
---

# A11y Advisor Dispatcher

アクセシビリティ関連タスクを検出し、`a11y-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- コンポーネントのアクセシビリティ設計
- WCAG 準拠のレビュー
- ARIA 属性・ロールの設計
- キーボードナビゲーションの実装
- フォーカス管理の設計
- スクリーンリーダー対応
- カラーコントラストの検証

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のアクセシビリティ関連ルール（コーディングルール内の a11y セクション等）を Read で収集する
2. **既存 a11y パターン**: Grep で既存コンポーネントの `aria-` 属性、`role=` 属性の使用パターンを検索する
3. **UI ライブラリ**: `package.json` からアクセシビリティ対応の UI ライブラリ（Radix UI, React Aria, Headless UI 等）とテストツール（axe-core, jest-axe 等）を確認する
4. **Storybook MCP**: `get-ui-building-instructions` でプロジェクトのコンポーネント開発指示を取得し、a11y アドオンの設定を確認する
5. **ライブラリドキュメント**: context7 MCP で axe-core / Radix UI / React Aria の最新 API ドキュメントを確認する（`resolve-library-id` → `query-docs`）
6. **WCAG チェックリスト**: 詳細な達成基準の確認が必要な場合は [references/wcag-checklist.md](references/wcag-checklist.md) を参照する

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存パターン**: (参照した既存コードのファイルパスとパターンの要約)
> - **UI ライブラリ**: (確認したアクセシビリティ対応ライブラリ)
> - **ライブラリドキュメント**: (確認したライブラリとバージョン)

## Phase 2: サブエージェントへの委譲

Task ツールで `a11y-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `a11y-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存パターン: (渡す既存パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有の a11y ルール
  - 既存コンポーネントの ARIA パターンとコード例
  - UI ライブラリのアクセシビリティサポート状況
  - WCAG チェックリスト（該当する場合）

## Phase 3: 結果の適用

サブエージェントの分析結果を確認し、必要に応じて追加アクションを実行する:

1. アクセシビリティ設計を確認する
2. 必要に応じて `frontend-advisor` にコンポーネント実装を、`test-advisor` に a11y テストの追加を委譲する
3. `package.json` の scripts を確認し、該当するリント・型チェックコマンドで検証する

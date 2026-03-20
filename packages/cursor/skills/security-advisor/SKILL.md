---
name: security-advisor
description: Guides security implementation by delegating to the security-advisor specialist agent. Use when designing authentication, authorization, input validation, secrets management, security headers, or vulnerability mitigation. Triggers for security, authentication, authorization, OWASP, vulnerability, CORS, CSP, encryption, secrets, multi-tenant, セキュリティ, 認証, 認可, 脆弱性, シークレット.
---

# Security Advisor Dispatcher

セキュリティ関連タスクを検出し、`security-advisor` サブエージェントに委譲するスキル。

## トリガー条件

- 認証・認可の設計・実装
- 入力バリデーションの設計
- シークレット管理の検討
- セキュリティヘッダーの設定
- 脆弱性対策・OWASP 対応
- マルチテナントのデータ分離
- セキュリティレビュー

## Phase 1: コンテキスト収集

以下の順序でコンテキストを収集する:

1. **プロジェクトルール**: `.cursor/rules/` 内のセキュリティ関連ルールを Read で収集する
2. **既存セキュリティパターン**: Grep で既存の認証・認可実装（guard, middleware, interceptor, auth）を検索し、パターンを把握する
3. **依存パッケージ**: `package.json` からセキュリティ関連ライブラリ（helmet, passport, jose, bcrypt, next-auth 等）を確認する
4. **シークレット管理**: Grep でシークレットの取り扱い（環境変数、設定ファイル）を確認する
5. **ライブラリドキュメント**: context7 MCP でセキュリティライブラリの最新仕様を確認する（`resolve-library-id` → `query-docs`）
6. **OWASP チェックリスト**: 詳細な対策パターンが必要な場合は [references/owasp-top10-checklist.md](references/owasp-top10-checklist.md) を参照する

### 収集完了時の出力

Phase 1 完了後、以下のフォーマットで読み込んだコンテキストをユーザーに報告する：

> **読み込みコンテキスト:**
>
> - **ルール**: (読み込んだルールファイルのリスト)
> - **既存パターン**: (参照した既存コードのファイルパスとパターンの要約)
> - **ライブラリ情報**: (確認したセキュリティライブラリ、バージョン、および context7 で取得したドキュメントの要約)

## Phase 2: サブエージェントへの委譲

Task ツールで `security-advisor` サブエージェントを起動する。

委譲前に以下を出力する：

> **サブエージェント起動:**
>
> - **委譲先**: `security-advisor`
> - **渡すコンテキスト**:
>   - ルール: (渡すルールの要約)
>   - 既存パターン: (渡す既存パターンの要約)
>   - ドキュメント: (渡すドキュメントの要約)

プロンプトには以下を含める:

- ユーザーのタスク内容
- Phase 1 で収集したコンテキスト:
  - プロジェクト固有のセキュリティルール
  - 既存の認証・認可パターンとコード例
  - セキュリティライブラリの設定と使用状況
  - OWASP チェックリスト（該当する場合）

## Phase 3: 結果の適用

サブエージェントの分析結果を確認し、必要に応じて追加アクションを実行する:

1. セキュリティ設計を確認する
2. 必要に応じて `backend-advisor` に認証・認可の実装を、`infra-advisor` に WAF / ネットワーク設定を委譲する
3. `package.json` の scripts を確認し、該当するリント・型チェックコマンドで検証する

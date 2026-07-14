# 公開境界（L0 / L1 / L2）

dotfiles の AI 設定における公開範囲の契約。

| 層  | 名前       | Git      | 内容                                       |
| --- | ---------- | -------- | ------------------------------------------ |
| L0  | Public     | 載せる   | 識別子フリー・横断再利用可能な shared 本文 |
| L1  | Pair-local | 載せない | ペア／チーム固有（`*.local.*`）            |
| L2  | Only-local | 載せない | 個人・会社固有（`*.local.*`）              |

## 配置（CONVENTIONS）↔ 層の対応

CONVENTIONS の「ペア / only-local」は**ファイル配置**、本ドキュメントの L0/L1/L2 は**内容所有**。同名っぽいが直交する。

| 配置（CONVENTIONS）      | 典型層                             | 例                                              |
| ------------------------ | ---------------------------------- | ----------------------------------------------- |
| 汎用 `.md` のみ          | L0                                 | `ticket-retrieval-rule.md`                      |
| 汎用 `.md` + `.local.md` | L0 + L1/L2 overlay                 | `ticket-retrieval-rule.local.md`                |
| `.local.md` のみ         | L2                                 | `coding-rule.local.md`、registry / feedback log |
| overlay の内容判定       | L1=チーム共有可、L2=個人・会社固有 | Promote 前に a–d                                |

`ticket-retrieval-rule.local.md` は配置上「ペア」でも、内容が会社アダプタなら境界上は L2。

## Promote 基準（L1/L2 → L0）

次をすべて満たすものだけ shared（Git）へ蒸留する。

- **a** 識別子フリー（会社名・製品名・非公開 URL なし）
- **b** リポジトリ横断で再利用可能
- **c** Applied プロトコル（`Applied: <id>`）を満たす
- **d** ラッパー同期（wrapper-parity）済み

## Git 禁止

- 会社名・製品名
- 非公開 URL（private org/repo、社内 Notion 等）
- `alwaysApply` ルール内の業務専用コマンド名

## 関連

- [LOCAL-SETUP.md](./LOCAL-SETUP.md) — `.local.*` の初期化
- [PR-FEEDBACK-PLAYBOOK.md](./PR-FEEDBACK-PLAYBOOK.md) — フィードバック蒸留
- [leakage-checklist.md](../rules/meta/leakage-checklist.md) — PR 前漏洩チェック

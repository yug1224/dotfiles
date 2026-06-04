GitHub PR・ADR・開発ログ・自由記述を入力に、画像生成 LLM へ渡す **固定指示 + markdown サマリ** を 1 本だけ出力する。画像は生成しない（下流の別チャットで生成する）。

**参照ルール**:

- `@~/.config/shared/ai/rules/visual/graphic-record-style-rule.md`（必須）
- `@~/.config/shared/ai/rules/visual/graphic-record-source-rule.md`（必須）
- 同ディレクトリの `graphic-record-style-rule.local.md` / `graphic-record-source-rule.local.md`（存在する場合のみ Glob → Read）

**Input**: `/graphic-record-prompt` の後ろ。PR URL、`.md` パス、自由記述、複数可。

**使用例**:

- `/graphic-record-prompt https://github.com/owner/repo/pull/123`
- `/graphic-record-prompt ./docs/adr/0001-use-postgres.md`
- `/graphic-record-prompt 認証を JWT+Refresh に変更。背景はセッション Cookie のみ。目標はリフレッシュ対応。`

---

## Steps

### 0. トレース

応答冒頭に `Applied: /graphic-record-prompt` のみ（ルール側の `Applied: graphic-record-*` はユーザー向けに出さない）。

### 1. ルール読み込み

1. `@~/.config/shared/ai/rules/visual/graphic-record-style-rule.md` を Read（必須）
2. `@~/.config/shared/ai/rules/visual/graphic-record-source-rule.md` を Read（必須）
3. 同ディレクトリの `*.local.md` を Glob。存在する場合のみ Read。矛盾時は `.local.md` を優先

スタイルルールの **ブロックA固定文案・左から4列・白背景・実装列最広** を正とする。**縦4帯・12セクション・画像API用1段落・確認用の別出力は使わない**。

### 2. 入力の取得

- 引数: URL・パス・テキストをすべて取得（`graphic-record-source-rule` の取得方法）
- 空なら PR URL / パス / 説明のいずれかを求める
- 4 列合計が 12 を超え、自動圧縮で要点が失われるときだけ、優先ソースを 1 点確認

### 3. コア抽出

`graphic-record-source-rule` の成果物表に従い整理する。

- `key_messages`（3〜5）を先に決め、4 列へ配分
- `background_items` / `goal_items` / `implementation_items` / `remaining_items` は列上限（3/3/6/2）内。合計 12 超は **背景 → 目標 → 実装** の順で削る
- `policy_items` / `verification_items` を必要に応じて生成
- **`compressed_summary`** を source ルール「compressed_summary の組み立て」に従い生成（**唯一の出力本文**）
- `mascot_line`（ユーモア可、20 字前後）

### 4. プロンプト生成

スタイルルール「ブロックA固定文案」を **そのまま**出力し、`{compressed_summary}` のみ差し替える。

### 5. 出力の下書き組み立て

導線文テンプレと出力フォーマットに従い、応答全体（導線文 + fenced ブロック 1 つ）の**下書き**を組み立てる（この Step ではユーザーに提示しない）。

### 6. 品質チェック

下書きに対して以下を確認し、必要なら下書きを修正する。

- [ ] `Applied:` + 導線文 + **fenced ブロック 1 つだけ**（画像生成用）
- [ ] 固定文 8 行 + 内側 `markdown` サマリのみ（別ブロック・12セクション・画像API段落なし）
- [ ] サマリに `## 概要` `## 分析` `## 方針` `## 実装` `## 残課題` がある（`## 検証` は任意）
- [ ] `## 実装` が最も行数・情報量が多い
- [ ] 4 列・実装最広・白背景・左下熊が固定文に含まれる
- [ ] 機密・diff/ADR 全文転載なし

### 7. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 8. 最終出力

Step 7 で修正した導線文 + fenced ブロックのみをユーザーに提示する（下記「導線文テンプレ」「出力フォーマット」に従う）。

---

## 導線文テンプレ（ブロック外・固定構成）

`Applied:` の次に、次の内容を **この順**で出力する（言い換え可だが項目は省略しない）。

1. 「以下の fenced ブロック全体をコピーし、**新しいチャット**（Gemini / ChatGPT / Cursor 等）に貼り付けてください。」
2. 追いメッセージは **任意**（貼り付けだけで画像 1 枚が得られる運用が多い）。送る場合: `説明なしで画像を1枚だけ生成してください。`
3. **Cursor**: `GenerateImage` または利用可能な画像生成ツールを使うこと。
4. **ChatGPT**: 画像生成対応モデルで、テキスト解説ではなく **画像 1 枚**として出力すること。
5. **Gemini**: 画像生成で **1 枚**出力すること。

---

## 出力フォーマット

導線文のあと、**fenced ブロック 1 つだけ**を出力する。

スタイルルール「ブロックA固定文案」の `{compressed_summary}` を実体で置換する。外側・内側とも fenced `markdown` で囲む。

````markdown
日本語にてグラフィックレコードで説明している画像に変換してください。
図や矢印、ボックス、キャプション、色を使って、コアとなるアイデアを視覚的に説明してください。

背景色は白。正しい日本語を出力してください。
可愛い動物さん（メガネを掛けた熊さん）を左下に、ワンポイントだけ配置してください。
熊はユーモアあふれるセリフを表示してください。

左から順番に 1.背景・2.目標・3.実装・4.残課題 とグルーピングしてまとめてください。3.実装 は他と比べて広くしてください。

```markdown
{compressed_summary — 改行・見出し構造を保持}
```
````

- 熊のセリフは `mascot_line` をサマリ末尾に `> 熊のセリフ: …` として 1 行追記してもよい（任意。固定文の「ユーモアあふれるセリフ」と矛盾しない内容にする）

---

## Guardrails

- GenerateImage / 画像 API は呼ばない（2 段階ワークフローの Step 1 のみ）
- 情報不足時は推測せず 1〜2 点確認
- 応答は **fenced ブロック 1 つ + 導線文** のみ。ブロック外にメタ・ラベル一覧・要点箇条書き・確認用の第二ブロックを出さない
- 「ホワイトボード」「板面」はプロンプトに書かない
- サマリ内: パスは短縮可、バッククォートで短い識別子は可（source ルール準拠）
- **縦4帯・方針/実装・12セクション・画像API用1段落・確認用出力は使わない**
- **左/右/中央・下部フローの旧 4 分割は使わない**
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

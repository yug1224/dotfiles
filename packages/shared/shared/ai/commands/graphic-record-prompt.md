GitHub PR・ADR・開発ログ・自由記述を入力に、Gemini Nano Banana Pro へ渡す **固定指示 + 日本語描画内容** を 1 本だけ出力する。画像は生成しない（下流の別チャットで生成する）。

**参照ルール**:

- `@~/.config/shared/ai/rules/visual/graphic-record-style-rule.md`（必須）
- `@~/.config/shared/ai/rules/visual/graphic-record-source-rule.md`（必須）
- 同ディレクトリの `graphic-record-style-rule.local.md` / `graphic-record-source-rule.local.md`（存在する場合のみ Glob → Read）

**Input**: `/graphic-record-prompt` の後ろ。PR URL、`.md` パス、自由記述、複数可。

**オプション引数**:

| 引数                | 用途                                                         |
| ------------------- | ------------------------------------------------------------ |
| `size:WIDTHxHEIGHT` | 解像度上書き（例: `size:2560x1440`）。未指定時は `1920x1080` |

**使用例**:

- `/graphic-record-prompt https://github.com/owner/repo/pull/123`
- `/graphic-record-prompt size:2560x1440 ./docs/adr/0001-use-postgres.md`
- `/graphic-record-prompt 認証を JWT+Refresh に変更。背景はセッション Cookie のみ。目標はリフレッシュ対応。`

---

## Steps

### 0. トレース

応答冒頭に `Applied: /graphic-record-prompt` のみ（ルール側の `Applied: graphic-record-*` はユーザー向けに出さない）。

### 1. ルール読み込み

1. `@~/.config/shared/ai/rules/visual/graphic-record-style-rule.md` を Read（必須）
2. `@~/.config/shared/ai/rules/visual/graphic-record-source-rule.md` を Read（必須）
3. 同ディレクトリの `*.local.md` を Glob。存在する場合のみ Read。矛盾時は `.local.md` を優先

スタイルルールの **ブロックA固定文案（v3.1・鮮やかフラット・文章厚化）・左から4列・白背景・実装列最広・装飾必須** を正とする。**`image_generation_prompt` は使う。ADR型 `compressed_summary` の出力・ネスト markdown は使わない**（`compressed_summary` は Step 3 内部 QA のみ）。**縦4帯・12セクション・確認用の別出力は使わない**。

### 2. 入力の取得

- 引数: URL・パス・テキストをすべて取得（`graphic-record-source-rule` の取得方法）
- `size:WIDTHxHEIGHT` があれば style ルールに従い解像度行を上書き
- 空なら PR URL / パス / 説明のいずれかを求める
- 4 列合計が 12 を超え、自動圧縮で要点が失われるときだけ、優先ソースを 1 点確認

### 3. コア抽出

`graphic-record-source-rule` の成果物表に従い整理する。

- `key_messages`（3〜5）を先に決め、4 列へ配分
- `background_items` / `goal_items` / `implementation_items` / `remaining_items` は列上限（3/3/6/2）内。合計 12 超は **背景 → 目標 → 実装** の順で削る
- `policy_items` / `verification_items` を必要に応じて生成
- **`compressed_summary`** を source ルール「compressed_summary の組み立て」に従い生成（**内部 QA 専用。最終出力に含めない**）
- `policy_items` / `verification_items` の要点を `implementation_items` にマージする
- マージ後の `*_items` から **`image_generation_prompt`** を source ルール「image_generation_prompt の組み立て」に従い生成（**ブロックA【描画内容】用**）
- `mascot_line`（ユーモア可、20 字前後）→ `熊の吹き出し「」` に入れる

### 4. プロンプト生成

スタイルルール「ブロックA固定文案」を **そのまま**出力し、`{image_generation_prompt}` のみ差し替える。`size:` 指定時は 【画風・レイアウト】の解像度行（`1920x1080`）を置換。

### 5. 出力の下書き組み立て

導線文テンプレと出力フォーマットに従い、応答全体（導線文 + fenced ブロック 1 つ）の**下書き**を組み立てる（この Step ではユーザーに提示しない）。

### 6. 品質チェック

下書きに対して以下を確認し、必要なら下書きを修正する。

#### A. 内部抽出 QA（`compressed_summary`）

- [ ] `## 概要` `## 分析` `## 方針` `## 実装` `## 残課題` がある（`## 検証` は任意）
- [ ] `## 実装` が最も行数・情報量が多い
- [ ] 4 列合計 12 以内、実装列が最厚
- [ ] `policy_items` / `verification_items` の要点が `implementation_items` に統合されている
- [ ] 機密・diff/ADR 全文転載なし

#### B. 最終出力ブロック

- [ ] `Applied:` + 導線文 + **fenced ブロック 1 つだけ**（画像生成用）
- [ ] ブロックA固定文 4 セクション（出力指示・画風・描画内容・避ける要素）+ `image_generation_prompt` のみ（`compressed_summary`・ネスト markdown・別ブロックなし）
- [ ] `image_generation_prompt` は **全文日本語**、**2000〜2800 字**、列見出し `【1.背景】`〜`【4.残課題】`
- [ ] 画像内固定文言が **「」** で囲まれている（タイトル・キャプション・コールアウト・熊のセリフ）
- [ ] 各列に **`列リード:`（50〜90字）** がある
- [ ] 背景・目標に **ミニ図解が各 3 項目**
- [ ] 各キャプションが **名詞+説明文（70〜110字/項目）**
- [ ] 実装列に **小見出し帯（`■`）・表・フロー・黄コールアウト（2つ以上）** がある
- [ ] 4 列・実装最広・白背景・左下熊・鮮やかフラット装飾が固定文に含まれる
- [ ] 【避ける要素】にネガティブプロンプト全文がある（`判読不能な過密文字`）
- [ ] 【実行指示 — 厳守】が **含まれていない**
- [ ] 外側 fence は `text`

### 7. 出力の再検証（必須）

`@~/.config/shared/ai/rules/conventions/output-verification-rule.md` を Read し、**「インライン再検証」**に従って下書きを検証・修正する。

### 8. 最終出力

Step 7 で修正した導線文 + fenced ブロックのみをユーザーに提示する（下記「導線文テンプレ」「出力フォーマット」に従う）。`compressed_summary` はユーザーに出さない。

---

## 導線文テンプレ（ブロック外・固定構成）

`Applied:` の次に、次の 1 行だけを出力する（言い換え可）。

「以下の fenced ブロック全体をコピーし、Gemini の「画像を作成」+ Thinking モデル（Nano Banana Pro）の新しいチャットに 1 回で貼り付けてください。」

---

## 出力フォーマット

導線文のあと、**fenced ブロック 1 つだけ**を出力する。外側は fenced `text` で囲む（`markdown` は使わない）。

スタイルルール「ブロックA固定文案」の `{image_generation_prompt}` を実体で置換する。固定文案の全文コピーは style ルールを正とする（コマンド側に二重定義しない）。

---

## Guardrails

- GenerateImage / 画像 API は呼ばない（2 段階ワークフローの Step 1 のみ）
- 情報不足時は推測せず 1〜2 点確認
- 応答は **fenced ブロック 1 つ + 導線文** のみ。ブロック外にメタ・ラベル一覧・要点箇条書き・`compressed_summary`・確認用の第二ブロックを出さない
- 「ホワイトボード」「板面」はプロンプトに書かない
- `image_generation_prompt` 内: パスは短縮可、短い識別子は可（source ルール準拠）
- **縦4帯・方針/実装・12セクション・ネスト markdown・確認用出力は使わない**
- **左/右/中央・下部フローの旧 4 分割は使わない**
- **`【実行指示 — 厳守】`・`【図:...】` 形式（v2.x）は使わない**
- 最終 fence は **`text`**（`markdown` ではない）
- 最終 Step の再検証完了前に、成果物をユーザーへ出力しない

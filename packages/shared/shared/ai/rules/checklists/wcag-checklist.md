このルールを適用したら、「Applied: wcag-checklist」と出力する。

# WCAG 2.2 AA チェックリスト

アクセシビリティレビュー・設計時に参照する WCAG 2.2 Level AA 達成基準のチェックリスト。Web アプリケーションで特に重要な項目を抽出。

## 1. Perceivable（知覚可能）

### 1.1 テキスト代替

- [ ] **1.1.1 非テキストコンテンツ (A)**: 全ての非テキストコンテンツにテキスト代替がある
  - 画像: 意味のある `alt` 属性
  - 装飾画像: `alt=""` または CSS background
  - アイコンボタン: `aria-label` または視覚的に隠されたテキスト

```tsx
// Good: 意味のある画像
<img src="logo.png" alt="会社ロゴ" />

// Good: 装飾画像
<img src="divider.png" alt="" role="presentation" />

// Good: アイコンボタン
<button aria-label="閉じる"><CloseIcon /></button>
```

### 1.3 適応可能

- [ ] **1.3.1 情報と関係 (A)**: 見た目で伝わる情報が、プログラムで判定可能か
  - 見出し: `<h1>` - `<h6>` を適切に使用
  - リスト: `<ul>` / `<ol>` / `<dl>` を使用
  - テーブル: `<th>` / `scope` / `<caption>` を使用
  - フォーム: `<label>` と `<input>` を関連付け

- [ ] **1.3.2 意味のある順序 (A)**: DOM 順序が視覚的な順序と一致している

### 1.4 判別可能

- [ ] **1.4.1 色の使用 (A)**: 色だけで情報を伝えていない（アイコン、テキスト等を併用）
- [ ] **1.4.3 コントラスト（最低限） (AA)**: テキストのコントラスト比が 4.5:1 以上（大きなテキストは 3:1 以上）
- [ ] **1.4.4 テキストのサイズ変更 (AA)**: 200% までズームしてもコンテンツが利用可能
- [ ] **1.4.11 非テキストのコントラスト (AA)**: UI コンポーネントと図の境界線のコントラスト比が 3:1 以上

## 2. Operable（操作可能）

### 2.1 キーボードアクセス

- [ ] **2.1.1 キーボード (A)**: 全機能がキーボードだけで操作可能
- [ ] **2.1.2 キーボードトラップなし (A)**: キーボードフォーカスがコンポーネント内に閉じ込められない（モーダルのフォーカストラップは Escape で解除可能）

```tsx
// Good: キーボード操作可能なカスタムボタン
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  }}
>
  アクション
</div>

// Better: ネイティブ要素を使う
<button onClick={handleClick}>アクション</button>
```

### 2.4 ナビゲーション

- [ ] **2.4.1 ブロックスキップ (A)**: メインコンテンツへのスキップリンクがある
- [ ] **2.4.2 ページタイトル (A)**: 各ページに適切なタイトルがある
- [ ] **2.4.3 フォーカス順序 (A)**: フォーカスの移動順序が意味のある順序
- [ ] **2.4.6 見出しとラベル (AA)**: 見出しとラベルがコンテンツの内容を説明している
- [ ] **2.4.7 フォーカスの可視性 (AA)**: キーボードフォーカスが視覚的に明確

```css
/* Good: フォーカスインジケータ */
:focus-visible {
  outline: 2px solid var(--focus-ring);
  outline-offset: 2px;
}
```

### 2.5 入力方法

- [ ] **2.5.3 ラベルとテキスト (A)**: 視覚的なラベルがアクセシブル名に含まれている

## 3. Understandable（理解可能）

### 3.1 読みやすさ

- [ ] **3.1.1 ページの言語 (A)**: `<html lang="ja">` で言語が指定されている
- [ ] **3.1.2 部分的な言語 (AA)**: 異なる言語の箇所に `lang` 属性がある

### 3.2 予測可能

- [ ] **3.2.1 フォーカス時 (A)**: フォーカスを受けただけでコンテキストが変化しない
- [ ] **3.2.2 入力時 (A)**: 値を変更しただけで予期しないコンテキスト変化が起きない

### 3.3 入力支援

- [ ] **3.3.1 エラーの特定 (A)**: エラーが検出された場合、エラー箇所が特定され、テキストで説明されている
- [ ] **3.3.2 ラベルまたは説明 (A)**: フォーム入力にラベルまたは説明がある

```tsx
// Good: エラーメッセージの関連付け
<label htmlFor="email">メールアドレス</label>
<input
  id="email"
  type="email"
  aria-invalid={!!error}
  aria-describedby={error ? "email-error" : undefined}
/>
{error && (
  <p id="email-error" role="alert">
    {error}
  </p>
)}
```

- [ ] **3.3.3 エラーの修正候補 (AA)**: エラーの修正方法が提示されている
- [ ] **3.3.4 エラーの防止（法的、金融、データ） (AA)**: 重要な操作は確認・取り消し可能

## 4. Robust（堅牢）

### 4.1 互換性

- [ ] **4.1.2 名前、役割、値 (A)**: 全 UI コンポーネントの名前と役割がプログラムで判定可能
- [ ] **4.1.3 ステータスメッセージ (AA)**: ステータスメッセージが `role="status"` または `aria-live` で支援技術に伝えられる

```tsx
// Good: ステータスメッセージ
<div role="status" aria-live="polite">
  3件の結果が見つかりました
</div>

// Good: 緊急のメッセージ
<div role="alert" aria-live="assertive">
  セッションが期限切れです
</div>
```

## コンポーネント別 WAI-ARIA パターン

| コンポーネント | role                              | キー操作                                    | 必須属性                                 |
| -------------- | --------------------------------- | ------------------------------------------- | ---------------------------------------- |
| Dialog         | `dialog`                          | Escape で閉じる、フォーカストラップ         | `aria-modal`, `aria-labelledby`          |
| Tabs           | `tablist` / `tab` / `tabpanel`    | Arrow で切替、Tab でパネルへ                | `aria-selected`, `aria-controls`         |
| Menu           | `menu` / `menuitem`               | Arrow で移動、Enter で選択、Escape で閉じる | `aria-expanded`, `aria-haspopup`         |
| Combobox       | `combobox` / `listbox` / `option` | Arrow で候補移動、Enter で選択              | `aria-expanded`, `aria-activedescendant` |
| Accordion      | `button` + region                 | Enter/Space でトグル                        | `aria-expanded`, `aria-controls`         |
| Tooltip        | `tooltip`                         | Escape で閉じる                             | 参照元に `aria-describedby`              |
| Alert          | `alert`                           | -                                           | `aria-live="assertive"`                  |
| Toast          | `status`                          | -                                           | `aria-live="polite"`                     |

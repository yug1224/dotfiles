globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'zenn',
  match: (location) => location.origin === 'https://zenn.dev',
  boost: async ({ clickElement }) => {
    // 上下に同系ボタンが2つあるため querySelector（1件）でトグル二重クリックを避ける
    const likeButton = document.querySelector('button[aria-label="いいね"][data-pressed="false"]');
    const bookmarkButton = document.querySelector('button[aria-label="ブックマーク"][data-pressed="false"]');
    // クラス名がハッシュ化されているので文言で探す（著者と Publication の両方）
    const followButtons = Array.from(document.querySelectorAll('button')).filter((v) => v.textContent.trim() === 'フォロー');
    for (const el of [likeButton, bookmarkButton, ...followButtons]) {
      await clickElement(el);
    }
  },
});

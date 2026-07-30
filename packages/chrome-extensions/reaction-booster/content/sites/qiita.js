globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'qiita',
  match: (location) => location.origin === 'https://qiita.com',
  boost: async ({ clickElement }) => {
    const likeStock = document.querySelectorAll('div.p-items_main > article button[aria-label="いいねする"],div.p-items_main > article button[aria-label="ストックする"]');
    const followButtons = Array.from(document.querySelectorAll('div.p-items_main > div > section button')).filter((v) => v.textContent === 'フォロー');
    for (const el of [...likeStock, ...followButtons]) {
      await clickElement(el);
    }
  },
});

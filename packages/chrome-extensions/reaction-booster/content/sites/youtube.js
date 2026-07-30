globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'youtube',
  match: (location) => location.origin === 'https://www.youtube.com',
  boost: async ({ clickElement }) => {
    // title は空になった。actions 欄の view-model を使い、押済みはスキップ
    const likeButton = document.querySelector('#top-level-buttons-computed like-button-view-model button[aria-pressed="false"]');
    for (const el of [likeButton]) {
      await clickElement(el);
    }
  },
});

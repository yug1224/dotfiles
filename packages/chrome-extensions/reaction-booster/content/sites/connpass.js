globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'connpass',
  match: (location) => /https:\/\/([a-z0-9-]+\.)?connpass\.com/.test(location.origin),
  boost: async ({ clickElement }) => {
    const bookmark = document.querySelector('span[title="ブックマークする"]:not([style="display: none;"])');
    const join = document.querySelector('span[title="メンバーになると、このグループの新規イベントのお知らせが届いたりします"]:not([style="display: none;"])');
    for (const el of [bookmark, join]) {
      await clickElement(el);
    }
  },
});

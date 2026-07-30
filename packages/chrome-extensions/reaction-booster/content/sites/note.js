globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'note',
  match: (location, document) => location.origin === 'https://note.com' || !!document.querySelector('a.a-link.o-footer__powerdbyLogo.fn[href="https://note.com/"]'),
  boost: async ({ clickElement }) => {
    const likeButton = document.querySelector('div.p-article__action button[aria-label="スキ"]');
    const followButton = document.querySelector('#sideCreatorProfile > span > span > button[data-type="primary"]');
    for (const el of [likeButton, followButton]) {
      await clickElement(el);
    }
  },
});

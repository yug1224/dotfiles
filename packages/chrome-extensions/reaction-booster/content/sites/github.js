globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'github',
  match: (location) => location.origin === 'https://github.com',
  boost: async ({ clickElement }) => {
    const starButton = document.querySelector('button[data-testid="star-button"][aria-label^="Star"]');
    for (const el of [starButton]) {
      await clickElement(el);
    }
  },
});

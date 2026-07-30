globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'speakerdeck',
  match: (location) => location.origin === 'https://speakerdeck.com',
  boost: async ({ clickElement }) => {
    const starLink = document.querySelector('.deck a[data-method="post"][href$="/star"]');
    const followLink = document.querySelector('.deck a[data-method="post"][href^="/connections/"]');
    for (const el of [starLink, followLink]) {
      await clickElement(el);
    }
  },
});

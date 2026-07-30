globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.dispatch = async () => {
  const adapter = ReactionBooster.adapters.find((a) => a.match(location, document));
  if (adapter) {
    await adapter.boost({ clickElement: ReactionBooster.clickElement });
    return { status: 'ok', siteId: adapter.id };
  }
  console.debug('[Reaction Booster] unsupported', location.origin);
  return { status: 'unsupported' };
};

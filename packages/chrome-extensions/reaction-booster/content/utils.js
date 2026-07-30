globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.delay = (ms) => new Promise((r) => setTimeout(r, ms));
ReactionBooster.clickElement = async (el) => {
  if (!el) return false;
  el.click();
  await ReactionBooster.delay(200);
  return true;
};

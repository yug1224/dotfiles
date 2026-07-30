(async () => {
  const result = await ReactionBooster.dispatch();
  try {
    chrome.runtime.sendMessage({
      type: 'reaction-booster/result',
      ...result,
    });
  } catch (_) {
    // SW がいない等は無視
  }
})();

const CONTENT_FILES = [
  'content/utils.js',
  'content/sites/qiita.js',
  'content/sites/zenn.js',
  'content/sites/note.js',
  'content/sites/speakerdeck.js',
  'content/sites/connpass.js',
  'content/sites/github.js',
  'content/sites/youtube.js',
  'content/registry.js',
  'content/main.js',
];

const BADGE_ALARM_PREFIX = 'reaction-booster/clear-badge:';

function clearBadge(tabId) {
  chrome.action.setBadgeText({ tabId, text: '' });
}

function scheduleBadgeClear(tabId, delayMs) {
  chrome.alarms.create(`${BADGE_ALARM_PREFIX}${tabId}`, {
    when: Date.now() + delayMs,
  });
}

function setBadge(tabId, text, autoClearMs) {
  chrome.action.setBadgeText({ tabId, text });
  if (autoClearMs != null) {
    scheduleBadgeClear(tabId, autoClearMs);
  }
}

chrome.alarms.onAlarm.addListener((alarm) => {
  if (!alarm.name.startsWith(BADGE_ALARM_PREFIX)) return;
  const tabId = Number(alarm.name.slice(BADGE_ALARM_PREFIX.length));
  if (!Number.isNaN(tabId)) {
    clearBadge(tabId);
  }
});

chrome.runtime.onMessage.addListener((message, sender) => {
  const tabId = sender.tab?.id;
  if (!tabId || message.type !== 'reaction-booster/result') return;

  if (message.status === 'ok') {
    setBadge(tabId, 'OK', 2000);
  } else if (message.status === 'unsupported') {
    setBadge(tabId, 'N/A', 3000);
  }
});

chrome.action.onClicked.addListener(async (tab) => {
  const tabId = tab?.id;
  if (!tabId) return;

  try {
    clearBadge(tabId);
    await chrome.scripting.executeScript({
      target: { tabId },
      files: CONTENT_FILES,
    });
  } catch (err) {
    console.error('[Reaction Booster]', err);
  }
});

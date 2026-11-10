globalThis.ReactionBooster = globalThis.ReactionBooster || {};
ReactionBooster.adapters = ReactionBooster.adapters || [];
ReactionBooster.adapters.push({
  id: 'note',
  // note pro の独自ドメイン（note.findy.co.jp など）も note.com と同じアプリのメタタグを持つ
  match: (location, document) => location.origin === 'https://note.com' || !!document.querySelector('meta[name="twitter:app:id:googleplay"][content="mu.note"]'),
  boost: async ({ clickElement }) => {
    // サイドバーのプロフィールは画面幅によって描画されないので、記事下のクリエイター欄を使う
    const footerButtons = () => [...document.querySelectorAll('#note-article footer button')];
    // ログイン状態の読み込み前に押すと保存されないので、フォローボタンに文言（フォロー／フォロー中）が出るまで最大 10 秒待つ
    for (let i = 0; i < 50 && !footerButtons().some((el) => el.textContent.trim().startsWith('フォロー')); i++) {
      await ReactionBooster.delay(200);
    }
    // 記事外（固定バーやおすすめ記事）のスキを避けて記事内のものを押す
    const likeButton = document.querySelector('#note-article button[aria-pressed="false"]:has(svg[aria-label="スキ"])');
    const followButton = footerButtons().find((el) => el.textContent.trim() === 'フォロー');
    for (const el of [likeButton, followButton]) {
      await clickElement(el);
    }
  },
});

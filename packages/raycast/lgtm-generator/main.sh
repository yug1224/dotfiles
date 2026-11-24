#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Random LGTM (AI)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎨
# @raycast.packageName LGTM Generator
# @raycast.argument1 { "type": "text", "placeholder": "テーマ（空でランダム即コピー）", "optional": true }

set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

POOL_SIZE="${LGTM_POOL_SIZE:-3}"
CACHE_DIR="${HOME}/.cache/lgtm-generator"
POOL_DIR="${CACHE_DIR}/pool"
LOCK_DIR="${CACHE_DIR}/replenish.lock"
CUSTOM_THEME="${1:-}"
# クリップボードにはファイルの場所が入るので、コピーした GIF は別名で残す。同じパスだとクリップボード履歴で重複扱いになり、古い項目も今の GIF を指してしまう
COPIED_DIR="${CACHE_DIR}/copied"
# shortcut: 新しい 30 本だけ残すので、それより古い履歴の項目は貼れなくなる。履歴を遡って使うなら増やす
KEEP_COPIED=30

mkdir -p "$POOL_DIR" "$COPIED_DIR"

# 異常終了で残った古いロック（5分以上前）を掃除
find "$LOCK_DIR" -maxdepth 0 -mmin +5 -exec rmdir {} \; 2>/dev/null || true

# API キーは環境変数を優先し、無ければキーチェーン（サービス lgtm-generator、アカウント gemini）から読む
keychain_key() {
  security find-generic-password -s lgtm-generator -a "$1" -w
}

# 引数から 1 つをランダムに返す。zsh の $RANDOM は $(...) の中で親の乱数が進まず毎回同じ値になるので jot で選ぶ（1 始まり）
pick() {
  printf '%s' "${@[$(jot -r 1 1 $#)]}"
}

# 誰が・どこで・何をする・画風・カメラの動きを組み合わせる。「何をする」は 3 秒でループできる 1 つの動きにし、文字が出る動作は入れない
build_prompt() {
  local custom="$1"
  local scene style camera

  if [ -n "$custom" ]; then
    scene="$custom"
  else
    local who action where
    who=$(pick \
      "a chubby shiba inu" \
      "a smug orange cat" \
      "a sleepy capybara" \
      "a tiny hamster in a business suit" \
      "a yellow rubber duck" \
      "a retro tin toy robot" \
      "a seasoned sushi chef" \
      "an exhausted software developer in a hoodie" \
      "a confident pigeon" \
      "a fluffy alpaca" \
      "a grumpy owl" \
      "a penguin in tiny sunglasses" \
      "a short-legged corgi" \
      "a lazy sloth" \
      "a mischievous raccoon" \
      "a goldfish in a fishbowl" \
      "a red panda" \
      "a frog wearing a tiny crown" \
      "a stoic samurai" \
      "a cheerful grandma")
    action=$(pick \
      "giving an enthusiastic thumbs up" \
      "putting on pixelated sunglasses in one smooth move" \
      "dropping a microphone and nodding" \
      "slamming a big rubber stamp down with full force" \
      "clapping slowly and approvingly" \
      "throwing confetti into the air" \
      "bouncing with a fist pump" \
      "nodding vigorously" \
      "doing a tiny victory dance" \
      "having their head explode into a swirling galaxy" \
      "blowing a chef's kiss" \
      "spinning around in an office chair" \
      "raising a glass for a toast" \
      "bowing deeply and respectfully" \
      "headbanging with an air guitar" \
      "hopping up and down with joy" \
      "pointing double finger guns at the camera" \
      "doing a dramatic slow hair flip" \
      "typing furiously, then turning to the camera with a wink" \
      "giving a standing ovation")
    where=$(pick \
      "in a blinking server room" \
      "in an empty office late at night" \
      "in a Japanese public bathhouse" \
      "aboard a space station" \
      "in a convenience store in the middle of the night" \
      "in a corporate meeting room" \
      "at the edge of an erupting volcano" \
      "at a ramen shop counter" \
      "on a crowded Tokyo train" \
      "in a neon-lit arcade" \
      "on a tropical beach" \
      "in a cardboard box fort" \
      "on stage at a rock concert" \
      "in a cozy room with a kotatsu" \
      "on the surface of the moon")
    scene="${who} ${action} ${where}"
  fi

  style=$(pick \
    "Japanese ukiyo-e woodblock print style" \
    "vibrant 16-bit pixel art" \
    "cute claymation miniature" \
    "grainy early-2000s webcam footage" \
    "worn VHS tape footage with scanlines and noise" \
    "a crude MS Paint doodle" \
    "a deep-fried, oversaturated meme look" \
    "90s anime cel shading" \
    "a glossy 3D toy commercial look" \
    "black-and-white silent film" \
    "cinematic 35mm film with soft bokeh" \
    "risograph print texture with bold pop colors" \
    "low-poly 90s video game 3D graphics" \
    "a flat vector cartoon" \
    "grainy security camera footage")
  camera=$(pick \
    "a sudden dramatic zoom-in on the face" \
    "a slow push-in" \
    "shaky handheld camera" \
    "slow motion" \
    "a fast whip pan" \
    "a static locked-off shot" \
    "a camera orbiting around the subject" \
    "camera shake on every beat" \
    "a low-angle hero shot" \
    "a fisheye lens close-up")

  printf 'Create a short, seamlessly looping, funny internet-meme style reaction animation: %s. Style: %s. Camera: %s. Keep the bold English letters "LGTM" prominently and cleanly displayed with high contrast in every frame so it is instantly readable. Show "LGTM" exactly once, never repeated. Overlay "LGTM" as a static caption fixed in place, unaffected by the camera movement. No other text, no typos, no watermarks.' "$scene" "$style" "$camera"
}

fetch_and_save_gif() {
  local prompt="$1"
  local dest="$2"
  local work_dir mp4_file gif_file b64=""
  local model="${GEMINI_VIDEO_MODEL:-gemini-omni-1.2-flash}"
  local payload

  work_dir=$(mktemp -d "${CACHE_DIR}/work.XXXXXX")
  mp4_file="${work_dir}/raw.mp4"
  gif_file="${work_dir}/out.gif"

  # API は GIF を返せないので、Omni に 3 秒の MP4 を作らせて ffmpeg で GIF にする。GIF は幅 480px に縮めるので 360p で足りる
  payload=$(jq -n --arg model "$model" --arg prompt "$prompt" '{
    model: $model,
    input: $prompt,
    response_format: { type: "video", aspect_ratio: "16:9", duration: "3s", resolution: "360p" }
  }')

  b64=$(curl -sS "https://generativelanguage.googleapis.com/v1beta/interactions" \
    -H "Content-Type: application/json" \
    -H "x-goog-api-key: ${GEMINI_API_KEY:-$(keychain_key gemini)}" \
    -d "$payload" | jq -r '[.steps[]? | select(.type == "model_output") | .content[]? | select(.type == "video") | .data][0] // empty')

  if [ -z "$b64" ]; then
    rm -rf "$work_dir"
    return 1
  fi

  printf '%s' "$b64" | base64 -d > "$mp4_file"
  ffmpeg -v error -y -i "$mp4_file" \
    -vf "fps=12,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" \
    -loop 0 "$gif_file"
  mv "$gif_file" "$dest"
  rm -rf "$work_dir"
}

count_pool() {
  find "$POOL_DIR" -maxdepth 1 -name '*.gif' | wc -l | tr -d ' '
}

replenish_pool() {
  mkdir "$LOCK_DIR" 2>/dev/null || return 0
  trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

  while [ "$(count_pool)" -lt "$POOL_SIZE" ]; do
    local target="${POOL_DIR}/$(date +%Y%m%d-%H%M%S)-${RANDOM}.gif"
    if ! fetch_and_save_gif "$(build_prompt "")" "$target"; then
      break
    fi
  done
}

# GIF の画像データをコピーするとブラウザが静止画に変換するので、Finder と同じくファイルとしてコピーする
copy_to_clipboard() {
  local img="$1"
  osascript -l JavaScript \
    -e 'ObjC.import("AppKit")' \
    -e '$.NSPasteboard.generalPasteboard.clearContents' \
    -e "\$.NSPasteboard.generalPasteboard.writeObjects(\$([\$.NSURL.fileURLWithPath(\"$img\")]))" >/dev/null

  # ファイル名は日時なので、名前の逆順で並べた KEEP_COPIED 本目より後ろが古いもの
  find "$COPIED_DIR" -maxdepth 1 -name 'lgtm-*.gif' | sort -r | tail -n +$((KEEP_COPIED + 1)) | while read -r old; do
    rm -f "$old"
  done
}

CURRENT_GIF="${COPIED_DIR}/lgtm-$(date +%Y%m%d-%H%M%S).gif"

# 1. テーマを手動指定したときはその場で生成してコピー
if [ -n "$CUSTOM_THEME" ]; then
  if fetch_and_save_gif "$(build_prompt "$CUSTOM_THEME")" "$CURRENT_GIF"; then
    copy_to_clipboard "$CURRENT_GIF"
    echo "Copied LGTM! (${CUSTOM_THEME})"
  else
    echo "画像生成に失敗しました"
    exit 1
  fi
  exit 0
fi

# 2. 在庫プールに画像があれば即コピーし、裏で3枚まで自動補充
NEXT_IMG=$(find "$POOL_DIR" -maxdepth 1 -name '*.gif' | sort | head -n 1)

if [ -n "$NEXT_IMG" ]; then
  mv "$NEXT_IMG" "$CURRENT_GIF"
  copy_to_clipboard "$CURRENT_GIF"

  ( replenish_pool ) >/dev/null 2>&1 </dev/null &

  REMAIN=$(count_pool)
  echo "Copied LGTM! 👍（残りストック: ${REMAIN}枚）"
  exit 0
fi

# 3. 初回実行など在庫が空のときは1枚同期生成し、残り2枚を裏で補充
if fetch_and_save_gif "$(build_prompt "")" "$CURRENT_GIF"; then
  copy_to_clipboard "$CURRENT_GIF"
  ( replenish_pool ) >/dev/null 2>&1 </dev/null &
  echo "Copied LGTM! 👍（裏でストック補充中）"
else
  echo "画像生成に失敗しました"
  exit 1
fi

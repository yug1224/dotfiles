import { finishWithError, finishWithHud } from './lib/finish-command';
import { setMute } from './lib/switch-audio-source';

export default async function main() {
  try {
    setMute('unmute');
    await finishWithHud('Unmuted input audio device.');
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    await finishWithError(message);
  }
}

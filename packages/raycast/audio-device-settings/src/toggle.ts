import { finishWithError, finishWithHud } from './lib/finish-command';
import { setMute } from './lib/switch-audio-source';

export default async function main() {
  try {
    setMute('toggle');
    await finishWithHud('Toggled input audio device mute.');
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    await finishWithError(message);
  }
}

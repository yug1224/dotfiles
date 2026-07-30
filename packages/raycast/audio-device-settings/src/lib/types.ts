import { Icon } from '@raycast/api';

export type AudioDeviceKind = 'input' | 'output';

export type AudioSource = {
  name: string;
  type: string;
  id: string;
  uid: string;
  icon?: Icon.Checkmark | null;
};

export type MuteMode = 'mute' | 'unmute' | 'toggle';

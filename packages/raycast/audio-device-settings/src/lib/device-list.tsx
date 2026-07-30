import { ActionPanel, Action, Icon, List } from '@raycast/api';
import { useCachedPromise } from '@raycast/utils';

import { finishWithError, finishWithHud } from './finish-command';
import { getCurrentDevice, listDevices, setDevice } from './switch-audio-source';
import type { AudioDeviceKind, AudioSource } from './types';

type Props = {
  kind: AudioDeviceKind;
  listIcon: Icon;
};

type DeviceItem = AudioSource & { icon: Icon.Checkmark | null };

async function loadDevices(kind: AudioDeviceKind): Promise<DeviceItem[]> {
  const currentDevice = getCurrentDevice(kind);
  return listDevices(kind).map((device) => ({
    ...device,
    icon: device.id === currentDevice.id ? Icon.Checkmark : null,
  }));
}

export default function DeviceList({ kind, listIcon }: Props) {
  const { data: devices, error, isLoading } = useCachedPromise(loadDevices, [kind]);

  const kindLabel = kind === 'input' ? 'input' : 'output';
  const errorMessage = error instanceof Error ? error.message : error ? String(error) : undefined;

  if (errorMessage) {
    const isNotFound = errorMessage.includes('SwitchAudioSource not found');
    return (
      <List isLoading={isLoading}>
        <List.EmptyView
          title={isNotFound ? 'SwitchAudioSource が見つかりません' : 'オーディオデバイスを取得できません'}
          description={isNotFound ? 'make mise（または brew install switchaudio-osx）でインストールしてください' : errorMessage}
        />
      </List>
    );
  }

  const deviceList = devices ?? [];

  if (!isLoading && deviceList.length === 0) {
    return (
      <List isLoading={isLoading}>
        <List.EmptyView title="デバイスがありません" />
      </List>
    );
  }

  return (
    <List isLoading={isLoading}>
      {deviceList.map((device) => (
        <List.Item
          key={device.id}
          id={device.id}
          icon={listIcon}
          title={device.name}
          subtitle={device.uid}
          accessories={[{ icon: device.icon }]}
          actions={
            <ActionPanel>
              <Action
                title="Select"
                onAction={async () => {
                  try {
                    setDevice(kind, device.id);
                    await finishWithHud(`Active ${kindLabel} audio device set to ${device.name}`);
                  } catch (e) {
                    const message = e instanceof Error ? e.message : String(e);
                    await finishWithError(message);
                  }
                }}
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

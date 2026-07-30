import { Icon } from '@raycast/api';

import DeviceList from './lib/device-list';

export default function main() {
  return <DeviceList kind="input" listIcon={Icon.Microphone} />;
}

import { closeMainWindow, popToRoot, showHUD, showToast, Toast } from '@raycast/api';

export async function finishWithHud(message: string): Promise<void> {
  await closeMainWindow({ clearRootSearch: true });
  await popToRoot({ clearSearchBar: true });
  await showHUD(message);
}

export async function finishWithError(message: string): Promise<void> {
  await showToast({ style: Toast.Style.Failure, title: message });
}

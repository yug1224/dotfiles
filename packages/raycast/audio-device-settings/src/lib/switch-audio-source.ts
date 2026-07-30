import { existsSync } from 'node:fs';

import { execaSync } from 'execa';

import type { AudioDeviceKind, AudioSource, MuteMode } from './types';

const CANDIDATE_PATHS = ['/opt/homebrew/bin/SwitchAudioSource', '/usr/local/bin/SwitchAudioSource'];

let resolvedBin: string | undefined;

function resolveSwitchAudioSourceBin(): string {
  if (resolvedBin) {
    return resolvedBin;
  }

  for (const path of CANDIDATE_PATHS) {
    if (existsSync(path)) {
      resolvedBin = path;
      return path;
    }
  }

  try {
    const { stdout } = execaSync('which', ['SwitchAudioSource']);
    const bin = stdout.trim();
    if (bin) {
      resolvedBin = bin;
      return bin;
    }
  } catch {
    // fall through
  }

  throw new Error('SwitchAudioSource not found. Install with: make mise (or brew install switchaudio-osx)');
}

function runSwitchAudioSource(args: string[]): string {
  const bin = resolveSwitchAudioSourceBin();
  try {
    const { stdout } = execaSync(bin, args);
    return stdout;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`SwitchAudioSource failed: ${message}`);
  }
}

function isAudioSource(value: unknown): value is AudioSource {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const record = value as Record<string, unknown>;
  return typeof record.name === 'string' && typeof record.id === 'string' && typeof record.uid === 'string' && typeof record.type === 'string';
}

function parseJsonLines(stdout: string): AudioSource[] {
  const devices: AudioSource[] = [];

  for (const line of stdout.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (trimmed.length === 0) {
      continue;
    }

    try {
      const parsed: unknown = JSON.parse(trimmed);
      if (isAudioSource(parsed)) {
        devices.push(parsed);
      }
    } catch {
      // skip broken lines
    }
  }

  return devices;
}

export function listDevices(kind: AudioDeviceKind): AudioSource[] {
  const stdout = runSwitchAudioSource(['-f', 'json', '-t', kind, '-a']);
  return parseJsonLines(stdout);
}

export function getCurrentDevice(kind: AudioDeviceKind): AudioSource {
  const devices = parseJsonLines(runSwitchAudioSource(['-f', 'json', '-t', kind, '-c']));
  if (devices.length === 0) {
    throw new Error(`No current ${kind} device found`);
  }
  return devices[0];
}

export function setDevice(kind: AudioDeviceKind, id: string): void {
  runSwitchAudioSource(['-t', kind, '-i', id]);
}

export function setMute(mode: MuteMode): void {
  runSwitchAudioSource(['-m', mode, '-t', 'input']);
}

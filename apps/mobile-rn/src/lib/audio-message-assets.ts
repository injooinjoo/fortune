import * as FileSystem from 'expo-file-system/legacy';

import { appEnv } from './env';
import { captureError } from './error-reporting';
import { supabase } from './supabase';
import type { ChatShellAudioMessage } from './chat-shell';

const AUDIO_DIR = `${FileSystem.documentDirectory ?? ''}character-audio/`;
const AUDIO_BUCKET = 'character-audio-messages';
const SERVER_RETENTION_DAYS = 90;

function isFileUri(uri?: string | null): uri is string {
  return typeof uri === 'string' && uri.startsWith('file://');
}

function extensionFromUri(uri: string): string {
  const clean = uri.split('?')[0] ?? uri;
  const match = clean.match(/\.([a-zA-Z0-9]+)$/);
  const ext = match?.[1]?.toLowerCase();
  if (ext && ext.length <= 8) return ext;
  return 'm4a';
}

async function ensureAudioDir(): Promise<void> {
  if (!FileSystem.documentDirectory) {
    throw new Error('Document directory is unavailable');
  }
  const info = await FileSystem.getInfoAsync(AUDIO_DIR);
  if (!info.exists) {
    await FileSystem.makeDirectoryAsync(AUDIO_DIR, { intermediates: true });
  }
}

export async function persistAudioMessageLocally(args: {
  sourceUri: string;
  messageId: string;
}): Promise<string> {
  if (!isFileUri(args.sourceUri)) {
    return args.sourceUri;
  }

  await ensureAudioDir();
  const ext = extensionFromUri(args.sourceUri);
  const destination = `${AUDIO_DIR}${args.messageId}.${ext}`;
  const existing = await FileSystem.getInfoAsync(destination);
  if (existing.exists) {
    return destination;
  }

  await FileSystem.copyAsync({ from: args.sourceUri, to: destination });
  return destination;
}

async function localFileExists(uri?: string): Promise<boolean> {
  if (!isFileUri(uri)) return false;
  try {
    const info = await FileSystem.getInfoAsync(uri);
    return info.exists;
  } catch {
    return false;
  }
}

export async function uploadAudioMessageAsset(args: {
  characterId: string;
  messageId: string;
  localUri: string;
  mimeType?: string;
  durationMillis?: number;
}): Promise<{
  storagePath: string;
  expiresAt: string;
  sizeBytes?: number;
} | null> {
  if (!supabase || !appEnv.isSupabaseConfigured) return null;
  if (!isFileUri(args.localUri)) return null;

  try {
    const { data: sessionData } = await supabase.auth.getSession();
    const session = sessionData.session;
    if (!session) return null;

    const info = await FileSystem.getInfoAsync(args.localUri);
    if (!info.exists) return null;
    const sizeBytes = 'size' in info && typeof info.size === 'number' ? info.size : null;

    const ext = extensionFromUri(args.localUri);
    const storagePath = `users/${session.user.id}/characters/${args.characterId}/${args.messageId}.${ext}`;
    const endpoint = `${appEnv.supabaseUrl}/storage/v1/object/${AUDIO_BUCKET}/${storagePath}`;
    const mimeType = args.mimeType ?? (ext === 'm4a' ? 'audio/mp4' : `audio/${ext}`);

    const uploadResult = await FileSystem.uploadAsync(endpoint, args.localUri, {
      httpMethod: 'POST',
      uploadType: FileSystem.FileSystemUploadType.BINARY_CONTENT,
      headers: {
        Authorization: `Bearer ${session.access_token}`,
        apikey: appEnv.supabaseAnonKey,
        'Content-Type': mimeType,
        'x-upsert': 'true',
      },
    });
    if (uploadResult.status < 200 || uploadResult.status >= 300) {
      throw new Error(
        `Audio upload failed: ${uploadResult.status} ${uploadResult.body ?? ''}`,
      );
    }

    const expiresAt = new Date(
      Date.now() + SERVER_RETENTION_DAYS * 24 * 60 * 60 * 1000,
    ).toISOString();

    await supabase.from('character_audio_messages').upsert({
      user_id: session.user.id,
      character_id: args.characterId,
      message_id: args.messageId,
      storage_path: storagePath,
      mime_type: mimeType,
      duration_millis: args.durationMillis ?? null,
      size_bytes: sizeBytes,
      expires_at: expiresAt,
      deleted_at: null,
    }, { onConflict: 'user_id,message_id' });

    return {
      storagePath,
      expiresAt,
      sizeBytes: sizeBytes ?? undefined,
    };
  } catch (error) {
    captureError(error, { surface: 'chat:audio-asset-upload' }).catch(() => undefined);
    return null;
  }
}

export async function resolvePlayableAudioUri(
  message: Pick<ChatShellAudioMessage, 'audioLocalUri' | 'audioStoragePath' | 'audioUrl' | 'expiresAt'>,
): Promise<{ uri: string; expired: boolean }> {
  if (await localFileExists(message.audioLocalUri)) {
    return { uri: message.audioLocalUri!, expired: false };
  }

  // Legacy messages stored the local file path in audioUrl. Keep this fallback so
  // old conversations still play if the file survived on-device.
  if (await localFileExists(message.audioUrl)) {
    return { uri: message.audioUrl!, expired: false };
  }

  const expiresAtMs = message.expiresAt ? Date.parse(message.expiresAt) : NaN;
  const serverExpired = Number.isFinite(expiresAtMs) && expiresAtMs <= Date.now();
  if (serverExpired) {
    return { uri: '', expired: true };
  }

  if (supabase && message.audioStoragePath) {
    const { data, error } = await supabase.storage
      .from(AUDIO_BUCKET)
      .createSignedUrl(message.audioStoragePath, 60 * 60);
    if (!error && data?.signedUrl) {
      return { uri: data.signedUrl, expired: false };
    }
    if (serverExpired) {
      return { uri: '', expired: true };
    }
  }

  if (message.audioUrl && !isFileUri(message.audioUrl)) {
    return { uri: message.audioUrl, expired: false };
  }

  return { uri: '', expired: serverExpired };
}

export function stripLocalAudioFieldsForRemote(
  message: ChatShellAudioMessage,
): ChatShellAudioMessage {
  const { audioLocalUri: _audioLocalUri, ...remoteSafe } = message;
  if (isFileUri(remoteSafe.audioUrl)) {
    return { ...remoteSafe, audioUrl: '' };
  }
  return remoteSafe;
}

export type ChatSurfaceMode = 'list' | 'chat';

export function shouldDiscardAudioMessageRecording(args: {
  recordingCharacterId: string | null | undefined;
  activeCharacterId: string | null | undefined;
  surfaceMode: ChatSurfaceMode;
}): boolean {
  const { recordingCharacterId, activeCharacterId, surfaceMode } = args;
  if (!recordingCharacterId) return false;
  if (surfaceMode !== 'chat') return true;
  return activeCharacterId !== recordingCharacterId;
}

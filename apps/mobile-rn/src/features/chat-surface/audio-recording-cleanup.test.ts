import { haneulOracleCharacter, findChatCharacterById, normalizeChatCharacterId } from '../../lib/chat-characters.ts';
import { shouldDiscardAudioMessageRecording } from './audio-recording-cleanup.ts';

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

{
  assert(
    normalizeChatCharacterId(' fortune_haneul ') === haneulOracleCharacter.id,
    'legacy fortune_* selectedCharacterId/deeplink는 하늘이 단일 채팅방으로 정규화되어야 한다',
  );
  assert(
    findChatCharacterById('fortune_haneul')?.id === haneulOracleCharacter.id,
    'legacy fortune_* ID가 제거된 캐릭터나 이서준(luts)로 fallback 되면 안 된다',
  );
}

{
  assert(
    shouldDiscardAudioMessageRecording({
      recordingCharacterId: 'luts',
      activeCharacterId: 'luts',
      surfaceMode: 'chat',
    }) === false,
    '같은 채팅방에 머무르는 동안에는 녹음이 유지되어야 한다',
  );
  assert(
    shouldDiscardAudioMessageRecording({
      recordingCharacterId: 'luts',
      activeCharacterId: haneulOracleCharacter.id,
      surfaceMode: 'chat',
    }) === true,
    '녹음 중 다른 캐릭터 채팅방으로 전환하면 기존 녹음은 폐기되어야 한다',
  );
  assert(
    shouldDiscardAudioMessageRecording({
      recordingCharacterId: haneulOracleCharacter.id,
      activeCharacterId: haneulOracleCharacter.id,
      surfaceMode: 'list',
    }) === true,
    '녹음 중 채팅 리스트/화면 밖으로 나가면 녹음은 폐기되어야 한다',
  );
  assert(
    shouldDiscardAudioMessageRecording({
      recordingCharacterId: null,
      activeCharacterId: 'luts',
      surfaceMode: 'list',
    }) === false,
    '활성 녹음이 없으면 폐기 동작을 트리거하지 않아야 한다',
  );
}

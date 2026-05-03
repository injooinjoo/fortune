/**
 * useChatTtsHaptics — TTS 컨트롤러 + 캐릭터 응답 햅틱을 한 hook 으로 묶음.
 *
 * 추출 이유: chat-screen.tsx (3,500+ 줄) 분해 1단계. TTS/Haptic 은 송수신 흐름과
 * 독립적 (오디오 + 진동 API 만 호출, 메시지 state 영향 0) 이라 가장 위험 낮은
 * 분해 대상. 도메인 hook 으로 격리해 chat-screen 의 책임 영역 줄임.
 *
 * 동작 변경 0:
 *   - useTextToSpeech 인스턴스 1개 (화면 전체 1개). 새 재생 시 직전 자동 unload.
 *   - chatHapticsEnabled 토글이 false 면 진동 안 함.
 *   - emotion '애정' 이면 loveHeartbeat, 그 외 tapLight (메신저 표준 — 메시지
 *     도착 시 짧은 햅틱. 카톡과 동일 UX).
 *
 * 사용:
 *   const { tts, handlePlayTts, handleStopTts, triggerAssistantHaptic } =
 *     useChatTtsHaptics({ selectedCharacterId, chatHapticsEnabled });
 *
 * tts 객체는 chat-screen 의 SpeakerButton (state.status / activeMessageId / error)
 * + handleDeleteUserMessage (clearCache) 에서 직접 사용해야 하므로 그대로 노출.
 */

import { useCallback, useEffect, useRef } from 'react';

import { loveHeartbeat, tapLight } from '../../../lib/haptics';
import { useTextToSpeech } from '../../../lib/use-text-to-speech';

interface UseChatTtsHapticsInput {
  selectedCharacterId: string;
  chatHapticsEnabled: boolean;
}

export function useChatTtsHaptics(input: UseChatTtsHapticsInput) {
  const { selectedCharacterId, chatHapticsEnabled } = input;

  // 화면 전체 1개 인스턴스. 동시 재생 없음 — 새 play 호출 시 직전 자동 unload.
  const tts = useTextToSpeech();

  const handlePlayTts = useCallback(
    (args: { messageId: string; text: string; emotion?: string }) => {
      void tts.play({
        messageId: args.messageId,
        text: args.text,
        characterId: selectedCharacterId,
        emotion: args.emotion,
      });
    },
    [selectedCharacterId, tts],
  );

  const handleStopTts = useCallback(() => {
    void tts.stop();
  }, [tts]);

  // chatHapticsEnabled 토글 값을 ref 로 보관 — useCallback 의존성에서 제외해
  // 매 토글 시 새 callback 객체 안 만듦 (자식 컴포넌트 props 변동 방지).
  const chatHapticsEnabledRef = useRef(chatHapticsEnabled);
  useEffect(() => {
    chatHapticsEnabledRef.current = chatHapticsEnabled;
  }, [chatHapticsEnabled]);

  const triggerAssistantHaptic = useCallback(
    (emotionTag: string | undefined) => {
      if (!chatHapticsEnabledRef.current) {
        return;
      }
      if (emotionTag === '애정') {
        loveHeartbeat();
      } else {
        tapLight();
      }
    },
    [],
  );

  return { tts, handlePlayTts, handleStopTts, triggerAssistantHaptic };
}

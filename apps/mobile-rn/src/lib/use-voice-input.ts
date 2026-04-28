/**
 * Shared hook for voice input using `expo-speech-recognition` (iOS Speech
 * framework / Android SpeechRecognizer). On-device, realtime, offline-capable.
 *
 * 이전에는 expo-av + Whisper 엣지 함수를 썼는데 iOS에서
 * `Audio.Recording.prepareToRecordAsync()`가 간헐적으로 실패해
 * "녹음을 시작할 수 없습니다" 에러로 멈추는 문제가 있었다.
 * expo-speech-recognition은 app.config.ts에 이미 플러그인이 등록돼 있고
 * 네트워크 왕복 없이 디바이스 내장 엔진으로 변환한다.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { Alert } from 'react-native';

// Native module은 dev build에만 링크됨. JS 패키지 자체 import가 top-level에서
// throw하면 chat 탭 전체가 죽으므로 require로 감싸 런타임에 안전하게 로드한다.
type SpeechRecognitionNative = {
  ExpoSpeechRecognitionModule: {
    isRecognitionAvailable: () => boolean;
    requestPermissionsAsync: () => Promise<{ granted: boolean }>;
    start: (opts: { lang: string; interimResults: boolean; continuous: boolean }) => void;
    stop: () => void;
  };
  useSpeechRecognitionEvent: (event: string, cb: (e: { results?: { transcript: string }[]; isFinal?: boolean; error?: string; message?: string }) => void) => void;
};

let nativeSpeech: SpeechRecognitionNative | null = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  nativeSpeech = require('expo-speech-recognition') as SpeechRecognitionNative;
} catch {
  nativeSpeech = null;
}

const NOOP_EVENT = (_event: string, _cb: unknown) => {};
const ExpoSpeechRecognitionModule = nativeSpeech?.ExpoSpeechRecognitionModule ?? {
  isRecognitionAvailable: () => false,
  requestPermissionsAsync: async () => ({ granted: false }),
  start: () => {},
  stop: () => {},
};
const useSpeechRecognitionEvent = nativeSpeech?.useSpeechRecognitionEvent ?? NOOP_EVENT;

export type VoiceInputState = 'idle' | 'recording' | 'transcribing';

interface UseVoiceInputOptions {
  /** Called when a final transcript is received. */
  onTranscript: (text: string) => void;
  /** BCP-47 language tag. Default 'ko-KR'. */
  language?: string;
}

export function useVoiceInput({
  onTranscript,
  language = 'ko-KR',
}: UseVoiceInputOptions) {
  const [state, setState] = useState<VoiceInputState>('idle');
  // 마지막에 받은 final 텍스트. end 이벤트 시점에 onTranscript로 flush.
  const lastTranscriptRef = useRef<string>('');
  // stop()을 명시적으로 호출했는지 추적 — end 이벤트에서 사용자 의도로 중단된
  // 것인지 에러로 끊긴 것인지 구분.
  const stopRequestedRef = useRef<boolean>(false);

  const isRecording = state === 'recording';
  const isTranscribing = state === 'transcribing';
  const isActive = state !== 'idle';

  useSpeechRecognitionEvent('result', (event) => {
    const latest = event.results?.[0]?.transcript ?? '';
    if (latest) {
      lastTranscriptRef.current = latest;
    }
    // isFinal이 true면 그 자리에서 바로 flush (continuous=false 기준 1회성).
    if (event.isFinal && latest) {
      onTranscript(latest);
      lastTranscriptRef.current = '';
    }
  });

  useSpeechRecognitionEvent('error', (event) => {
    // no-speech / aborted는 조용히 무시, 나머지는 Alert.
    const silent = event.error === 'no-speech' || event.error === 'aborted';
    if (!silent) {
      console.warn('[useVoiceInput] Recognition error:', event.error, event.message);
      Alert.alert(
        '음성 인식 실패',
        event.message || '음성을 인식하지 못했습니다. 다시 시도해 주세요.',
      );
    }
    stopRequestedRef.current = false;
    lastTranscriptRef.current = '';
    setState('idle');
  });

  useSpeechRecognitionEvent('end', () => {
    // end는 stop() 후 또는 침묵으로 타임아웃됐을 때 호출된다. result 이벤트에서
    // isFinal이 못 오고 남은 interim 텍스트가 있으면 여기서 flush.
    const pending = lastTranscriptRef.current;
    lastTranscriptRef.current = '';
    stopRequestedRef.current = false;
    if (pending) {
      onTranscript(pending);
    }
    setState('idle');
  });

  // 언마운트 시 활성 세션 정리.
  useEffect(() => {
    return () => {
      try {
        ExpoSpeechRecognitionModule.stop();
      } catch {
        // 이미 중단된 상태면 무시
      }
    };
  }, []);

  const startRecording = useCallback(async () => {
    try {
      // Expo Go 또는 플러그인이 아직 네이티브에 링크되지 않은 빌드에서는
      // 미리 차단 — start()가 크래시/무응답 대신 명확한 안내 표시.
      if (!ExpoSpeechRecognitionModule.isRecognitionAvailable()) {
        Alert.alert(
          '음성 입력 미지원',
          '이 빌드에서는 음성 인식을 사용할 수 없습니다. 최신 dev 빌드를 설치한 뒤 다시 시도해 주세요.',
        );
        return;
      }

      const permission = await ExpoSpeechRecognitionModule.requestPermissionsAsync();
      if (!permission.granted) {
        Alert.alert(
          '마이크 권한',
          '음성 입력을 위해 마이크 권한이 필요합니다. 설정에서 허용해 주세요.',
        );
        return;
      }

      lastTranscriptRef.current = '';
      stopRequestedRef.current = false;

      // continuous: true — 사용자가 직접 stop 누르기 전까지 끊지 않는다.
      // continuous: false 일 때 native 측 ExpoSpeechRecognizer.swift 가 매 결과
      // 후 3초 침묵 타이머를 재설정해서 자동 stopListening() 을 호출한다 — 사용자가
      // 잠깐 숨 고를 때마다 녹음이 끊기는 원인. continuous 모드에서는 그 타이머를
      // 안 건다.
      ExpoSpeechRecognitionModule.start({
        lang: language,
        interimResults: true,
        continuous: true,
      });

      setState('recording');
    } catch (error) {
      console.warn('[useVoiceInput] Failed to start recognition:', error);
      Alert.alert(
        '음성 입력',
        '녹음을 시작할 수 없습니다. 다시 시도해 주세요.',
      );
      setState('idle');
    }
  }, [language]);

  const stopAndTranscribe = useCallback(async () => {
    try {
      stopRequestedRef.current = true;
      setState('transcribing');
      ExpoSpeechRecognitionModule.stop();
      // 실제 완료는 end/result 이벤트에서 state=idle로 되돌린다.
    } catch (error) {
      console.warn('[useVoiceInput] Failed to stop recognition:', error);
      setState('idle');
    }
  }, []);

  const toggleRecording = useCallback(async () => {
    if (state === 'recording') {
      await stopAndTranscribe();
    } else if (state === 'idle') {
      await startRecording();
    }
    // 'transcribing'이면 무시 — 결과 대기 중
  }, [state, startRecording, stopAndTranscribe]);

  const cancelRecording = useCallback(async () => {
    try {
      ExpoSpeechRecognitionModule.stop();
    } catch {
      // already stopped
    }
    lastTranscriptRef.current = '';
    stopRequestedRef.current = false;
    setState('idle');
  }, []);

  return {
    state,
    isRecording,
    isTranscribing,
    isActive,
    toggleRecording,
    cancelRecording,
  };
}

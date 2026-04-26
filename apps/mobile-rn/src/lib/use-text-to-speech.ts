import { useCallback, useEffect, useRef, useState } from 'react';

import { Audio, type AVPlaybackStatus } from 'expo-av';
import * as FileSystem from 'expo-file-system/legacy';

import { getCharacterVoice, normalizeEmotion } from './character-voices';
import { captureError } from './error-reporting';
import { supabase } from './supabase';

export type TtsStatus = 'idle' | 'loading' | 'playing' | 'error';

export interface TtsErrorState {
  code: 'PREMIUM_REQUIRED' | 'TTS_FAILED' | 'INVALID_INPUT' | 'INTERNAL';
  message: string;
}

interface TtsControllerState {
  status: TtsStatus;
  activeMessageId: string | null;
  error: TtsErrorState | null;
}

interface PlayArgs {
  messageId: string;
  text: string;
  characterId: string;
  emotion?: string;
}

interface CharacterTtsResponse {
  success: boolean;
  audioBase64?: string;
  mimeType?: string;
  error?: string;
  errorCode?: TtsErrorState['code'];
}

const CACHE_FILE_PREFIX = 'tts.v1.';

function resolveCachePath(messageId: string): string {
  // 메시지 id 에 path-unsafe 문자가 들어와도 안전하게.
  const safeId = messageId.replace(/[^a-zA-Z0-9_-]/g, '_');
  return `${FileSystem.documentDirectory}${CACHE_FILE_PREFIX}${safeId}.wav`;
}

/**
 * 캐릭터 채팅 음성 재생 hook.
 *
 * 한 화면에 여러 메시지가 있어도 controller 는 1개만 두고, 동시 재생을 막는다
 * (새 재생 시 직전 sound 인스턴스를 unload). 같은 메시지를 두 번째 누르면
 * 이미 캐시된 wav 파일을 사용하므로 즉시 재생.
 *
 * 호출자(SpeakerButton) 는 자기 messageId 와 controller.activeMessageId 를
 * 비교해서 자기 버튼만 'playing' 으로 표시할 수 있게 한다.
 */
export function useTextToSpeech() {
  const soundRef = useRef<Audio.Sound | null>(null);
  const generationRef = useRef(0); // 동시 호출 race 방지용 카운터
  const [state, setState] = useState<TtsControllerState>({
    status: 'idle',
    activeMessageId: null,
    error: null,
  });

  const stopInternal = useCallback(async () => {
    if (soundRef.current) {
      try {
        await soundRef.current.stopAsync().catch(() => undefined);
        await soundRef.current.unloadAsync().catch(() => undefined);
      } catch {
        // ignore
      }
      soundRef.current = null;
    }
  }, []);

  useEffect(() => {
    return () => {
      // unmount 시 정리.
      void stopInternal();
    };
  }, [stopInternal]);

  const stop = useCallback(async () => {
    await stopInternal();
    setState({ status: 'idle', activeMessageId: null, error: null });
  }, [stopInternal]);

  /**
   * 캐시 파일이 있으면 그 path 반환, 없으면 Edge Function 호출 → 파일 쓰기 → path 반환.
   * 401/402 같은 인증/결제 에러는 throw 해서 호출자가 분기.
   */
  const loadOrFetchAudio = useCallback(
    async (args: PlayArgs): Promise<string> => {
      const cachePath = resolveCachePath(args.messageId);
      const info = await FileSystem.getInfoAsync(cachePath);
      if (info.exists && (info.size ?? 0) > 44) {
        return cachePath;
      }

      const voice = getCharacterVoice(args.characterId);
      const emotion = normalizeEmotion(args.emotion);

      if (!supabase) {
        throw {
          code: 'INTERNAL',
          message: 'Supabase not configured',
        } as TtsErrorState;
      }

      const { data, error } = await supabase.functions.invoke<CharacterTtsResponse>(
        'character-tts',
        {
          body: {
            text: args.text,
            voice,
            emotion,
            messageId: args.messageId,
          },
        },
      );

      if (error) {
        // FunctionsHttpError 의 context 안에 응답 body 가 들어있을 수 있음.
        const ctxResp = (error as unknown as { context?: { json?: () => Promise<CharacterTtsResponse> } })
          .context;
        if (ctxResp?.json) {
          try {
            const parsed = await ctxResp.json();
            if (parsed?.errorCode) {
              const err: TtsErrorState = {
                code: parsed.errorCode,
                message: parsed.error ?? 'TTS 호출 실패',
              };
              throw err;
            }
          } catch (parseErr) {
            // 파싱 실패 시 generic 에러로 떨어짐.
            if ((parseErr as TtsErrorState).code) throw parseErr;
          }
        }
        throw {
          code: 'TTS_FAILED',
          message: error.message ?? 'TTS 호출 실패',
        } as TtsErrorState;
      }

      if (!data?.success || !data.audioBase64) {
        throw {
          code: data?.errorCode ?? 'TTS_FAILED',
          message: data?.error ?? 'TTS 응답 없음',
        } as TtsErrorState;
      }

      // base64 wav 를 디스크에 쓴다.
      await FileSystem.writeAsStringAsync(cachePath, data.audioBase64, {
        encoding: FileSystem.EncodingType.Base64,
      });
      return cachePath;
    },
    [],
  );

  const play = useCallback(
    async (args: PlayArgs) => {
      const myGeneration = generationRef.current + 1;
      generationRef.current = myGeneration;

      // 이전 재생 정리 + loading 상태로 전환.
      await stopInternal();
      if (generationRef.current !== myGeneration) return; // 더 새로운 호출이 있으면 abort
      setState({
        status: 'loading',
        activeMessageId: args.messageId,
        error: null,
      });

      try {
        // iOS 무음 모드에서도 들리도록 audio mode 설정.
        await Audio.setAudioModeAsync({
          playsInSilentModeIOS: true,
          allowsRecordingIOS: false,
          staysActiveInBackground: false,
          shouldDuckAndroid: true,
          playThroughEarpieceAndroid: false,
        }).catch(() => undefined);

        const sourcePath = await loadOrFetchAudio(args);
        if (generationRef.current !== myGeneration) return;

        const { sound } = await Audio.Sound.createAsync(
          { uri: sourcePath },
          { shouldPlay: true },
        );
        if (generationRef.current !== myGeneration) {
          await sound.unloadAsync().catch(() => undefined);
          return;
        }
        soundRef.current = sound;
        setState({
          status: 'playing',
          activeMessageId: args.messageId,
          error: null,
        });

        sound.setOnPlaybackStatusUpdate((status: AVPlaybackStatus) => {
          if (!status.isLoaded) return;
          if (status.didJustFinish) {
            // 자연 종료.
            void sound.unloadAsync().catch(() => undefined);
            if (soundRef.current === sound) soundRef.current = null;
            if (generationRef.current === myGeneration) {
              setState({ status: 'idle', activeMessageId: null, error: null });
            }
          }
        });
      } catch (err) {
        if (generationRef.current !== myGeneration) return;
        const ttsError =
          err && typeof err === 'object' && 'code' in (err as TtsErrorState)
            ? (err as TtsErrorState)
            : ({
                code: 'INTERNAL',
                message: '음성 재생 실패',
              } as TtsErrorState);

        // 비-premium 거절은 정상 분기 — Sentry 안 보냄. 그 외 실제 에러만.
        if (ttsError.code !== 'PREMIUM_REQUIRED') {
          captureError(err, { surface: 'chat:tts-play' }).catch(() => undefined);
        }

        setState({
          status: 'error',
          activeMessageId: args.messageId,
          error: ttsError,
        });
      }
    },
    [loadOrFetchAudio, stopInternal],
  );

  /**
   * 메시지 삭제 시 호출 — 디스크 캐시 정리. assistant 메시지에만 의미 있지만
   * 호출부가 sender 모를 수 있어 무조건 호출 가능.
   */
  const clearCache = useCallback(async (messageId: string) => {
    const cachePath = resolveCachePath(messageId);
    await FileSystem.deleteAsync(cachePath, { idempotent: true }).catch(
      () => undefined,
    );
  }, []);

  return { state, play, stop, clearCache };
}

/**
 * Shared hook for voice input using expo-av recording + Whisper API
 * via the speech-to-text Supabase Edge Function.
 *
 * Works in Expo Go — no native modules required beyond expo-av.
 */

import { useCallback, useRef, useState } from 'react';
import { Alert } from 'react-native';
import { Audio } from 'expo-av';

import { supabase } from './supabase';

export type VoiceInputState = 'idle' | 'recording' | 'transcribing';

interface UseVoiceInputOptions {
  /** Called when a transcript is successfully received */
  onTranscript: (text: string) => void;
  /** Language code for Whisper (default: 'ko') */
  language?: string;
}

export function useVoiceInput({ onTranscript, language = 'ko' }: UseVoiceInputOptions) {
  const [state, setState] = useState<VoiceInputState>('idle');
  const recordingRef = useRef<Audio.Recording | null>(null);

  const isRecording = state === 'recording';
  const isTranscribing = state === 'transcribing';
  const isActive = state !== 'idle';

  const startRecording = useCallback(async () => {
    try {
      // Request microphone permission
      const permission = await Audio.requestPermissionsAsync();
      if (!permission.granted) {
        Alert.alert(
          '마이크 권한',
          '음성 입력을 위해 마이크 권한이 필요합니다. 설정에서 마이크 권한을 허용해 주세요.',
        );
        return;
      }

      // Configure audio mode for recording
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
      });

      // Start recording
      const recording = new Audio.Recording();
      await recording.prepareToRecordAsync(
        Audio.RecordingOptionsPresets.HIGH_QUALITY,
      );
      await recording.startAsync();
      recordingRef.current = recording;
      setState('recording');
    } catch (error) {
      console.warn('[useVoiceInput] Failed to start recording:', error);
      Alert.alert('음성 입력', '녹음을 시작할 수 없습니다. 다시 시도해 주세요.');
      setState('idle');
    }
  }, []);

  const stopAndTranscribe = useCallback(async () => {
    const recording = recordingRef.current;
    if (!recording) {
      setState('idle');
      return;
    }

    try {
      setState('transcribing');

      // Stop recording
      await recording.stopAndUnloadAsync();

      // Reset audio mode so playback works normally
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: false,
        playsInSilentModeIOS: true,
      });

      const uri = recording.getURI();
      recordingRef.current = null;

      if (!uri) {
        Alert.alert('음성 입력', '녹음 파일을 찾을 수 없습니다.');
        setState('idle');
        return;
      }

      if (!supabase) {
        Alert.alert('음성 입력', '서버 연결이 설정되지 않았습니다.');
        setState('idle');
        return;
      }

      // Build FormData for the edge function
      const formData = new FormData();
      formData.append('file', {
        uri,
        type: 'audio/m4a',
        name: 'recording.m4a',
      } as unknown as Blob);
      formData.append('language', language);

      // Call our Supabase Edge Function which proxies to Whisper
      const { data, error } = await supabase.functions.invoke(
        'speech-to-text',
        { body: formData },
      );

      if (error) {
        console.warn('[useVoiceInput] Edge function error:', error);
        Alert.alert(
          '음성 인식 실패',
          '음성을 텍스트로 변환하지 못했습니다. 다시 시도해 주세요.',
        );
        setState('idle');
        return;
      }

      const payload = data as { success?: boolean; text?: string; error?: string } | null;

      if (!payload?.success || !payload.text) {
        const reason = payload?.error ?? '음성이 인식되지 않았습니다.';
        // If text is simply empty (silence), don't show an alert — just return
        if (!payload?.text && payload?.success) {
          setState('idle');
          return;
        }
        Alert.alert('음성 인식', reason);
        setState('idle');
        return;
      }

      onTranscript(payload.text);
      setState('idle');
    } catch (error) {
      console.warn('[useVoiceInput] Transcription error:', error);
      recordingRef.current = null;
      Alert.alert(
        '음성 입력',
        '오류가 발생했습니다. 다시 시도해 주세요.',
      );
      setState('idle');
    }
  }, [language, onTranscript]);

  const toggleRecording = useCallback(async () => {
    if (state === 'recording') {
      await stopAndTranscribe();
    } else if (state === 'idle') {
      await startRecording();
    }
    // If 'transcribing', ignore tap — wait for it to finish
  }, [state, startRecording, stopAndTranscribe]);

  const cancelRecording = useCallback(async () => {
    const recording = recordingRef.current;
    if (recording) {
      try {
        await recording.stopAndUnloadAsync();
      } catch {
        // Already stopped
      }
      recordingRef.current = null;
    }
    await Audio.setAudioModeAsync({
      allowsRecordingIOS: false,
      playsInSilentModeIOS: true,
    }).catch(() => undefined);
    setState('idle');
  }, []);

  return {
    /** Current voice input state */
    state,
    /** Whether currently recording audio */
    isRecording,
    /** Whether currently transcribing audio */
    isTranscribing,
    /** Whether recording or transcribing (not idle) */
    isActive,
    /** Toggle recording: start if idle, stop+transcribe if recording */
    toggleRecording,
    /** Cancel an in-progress recording without transcribing */
    cancelRecording,
  };
}

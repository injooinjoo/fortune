/**
 * TextInput with a microphone button for speech-to-text (STT).
 * Uses expo-speech-recognition for native STT on iOS/Android.
 * Falls back gracefully if the module is not available.
 */

import { useCallback, useRef, useState } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, TextInput, View, type TextInputProps } from 'react-native';

import { fortuneTheme } from '../lib/theme';

let SpeechModule: {
  start: (options: { lang: string; interimResults: boolean }) => void;
  stop: () => void;
  requestPermissionsAsync: () => Promise<{ granted: boolean }>;
  addListener: (event: string, handler: (data: unknown) => void) => { remove: () => void };
} | null = null;

try {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const mod = require('expo-speech-recognition');
  SpeechModule = mod.ExpoSpeechRecognitionModule ?? null;
} catch {
  // Not available
}

interface VoiceTextInputProps extends Omit<TextInputProps, 'style'> {
  onChangeText: (text: string) => void;
  value: string;
  multiline?: boolean;
}

export function VoiceTextInput({
  onChangeText,
  value,
  multiline = false,
  placeholder,
  ...rest
}: VoiceTextInputProps) {
  const [isListening, setIsListening] = useState(false);
  const subscriptionsRef = useRef<Array<{ remove: () => void }>>([]);

  const cleanup = useCallback(() => {
    for (const sub of subscriptionsRef.current) {
      sub.remove();
    }
    subscriptionsRef.current = [];
    setIsListening(false);
  }, []);

  const handleMicPress = useCallback(async () => {
    if (!SpeechModule) return;

    if (isListening) {
      try { SpeechModule.stop(); } catch { /* ignore */ }
      cleanup();
      return;
    }

    try {
      const { granted } = await SpeechModule.requestPermissionsAsync();
      if (!granted) return;

      setIsListening(true);

      const resultSub = SpeechModule.addListener('result', (event: unknown) => {
        const e = event as { results?: Array<{ transcript?: string }> };
        const transcript = e.results?.[0]?.transcript;
        if (transcript) {
          onChangeText(value ? `${value} ${transcript}` : transcript);
        }
      });

      const endSub = SpeechModule.addListener('end', () => {
        cleanup();
      });

      const errorSub = SpeechModule.addListener('error', () => {
        cleanup();
      });

      subscriptionsRef.current = [resultSub, endSub, errorSub];

      SpeechModule.start({
        lang: 'ko-KR',
        interimResults: false,
      });
    } catch {
      cleanup();
    }
  }, [isListening, onChangeText, value, cleanup]);

  const hasMic = SpeechModule != null;

  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'flex-start',
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: isListening ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.lg,
        borderWidth: 1,
      }}
    >
      <TextInput
        {...rest}
        multiline={multiline}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={fortuneTheme.colors.textTertiary}
        style={{
          flex: 1,
          color: fortuneTheme.colors.textPrimary,
          fontFamily: 'System',
          fontSize: 15,
          minHeight: multiline ? 104 : 52,
          paddingHorizontal: 14,
          paddingVertical: multiline ? 14 : 12,
          textAlignVertical: multiline ? 'top' : 'center',
        }}
        value={value}
      />
      {hasMic ? (
        <Pressable
          accessibilityLabel={isListening ? '음성 입력 중지' : '음성 입력 시작'}
          accessibilityRole="button"
          onPress={() => void handleMicPress()}
          style={({ pressed }) => ({
            alignItems: 'center',
            justifyContent: 'center',
            paddingHorizontal: 12,
            paddingVertical: multiline ? 14 : 14,
            opacity: pressed ? 0.6 : 1,
          })}
        >
          <Ionicons
            name={isListening ? 'mic' : 'mic-outline'}
            size={20}
            color={isListening ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.textTertiary}
          />
        </Pressable>
      ) : null}
    </View>
  );
}

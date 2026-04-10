/**
 * Compact bottom-bar text input for surveys.
 * Mirrors the chat composer design: [skip?] [TextInput] [mic|send]
 */

import { useCallback, useRef, useState } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, TextInput, View } from 'react-native';

import { AppText } from './app-text';
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

interface SurveyComposerProps {
  value: string;
  onChangeText: (text: string) => void;
  onSubmit: () => void;
  onSkip?: () => void;
  placeholder?: string;
}

export function SurveyComposer({
  value,
  onChangeText,
  onSubmit,
  onSkip,
  placeholder = '답변을 적어주세요.',
}: SurveyComposerProps) {
  const [isListening, setIsListening] = useState(false);
  const subscriptionsRef = useRef<Array<{ remove: () => void }>>([]);
  const hasDraft = value.trim().length > 0;
  const hasMic = SpeechModule != null;

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

  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: isListening
          ? fortuneTheme.colors.ctaBackground
          : fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.inputArea,
        borderWidth: 1,
        paddingHorizontal: 12,
        paddingVertical: 8,
      }}
    >
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        {/* Left button: skip (if available) */}
        {onSkip ? (
          <Pressable
            accessibilityLabel="건너뛰기"
            accessibilityRole="button"
            onPress={onSkip}
            style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
          >
            <View
              style={{
                alignItems: 'center',
                backgroundColor: fortuneTheme.colors.surfaceElevated,
                borderRadius: 16,
                height: 32,
                justifyContent: 'center',
                width: 32,
              }}
            >
              <Ionicons
                color={fortuneTheme.colors.textSecondary}
                name="chevron-forward-outline"
                size={16}
              />
            </View>
          </Pressable>
        ) : null}

        {/* TextInput */}
        <View style={{ flex: 1 }}>
          <TextInput
            accessibilityLabel="survey text input"
            multiline
            onChangeText={onChangeText}
            placeholder={placeholder}
            placeholderTextColor={fortuneTheme.colors.textTertiary}
            style={{
              color: fortuneTheme.colors.textPrimary,
              maxHeight: 72,
              minHeight: 28,
              paddingHorizontal: 4,
              paddingVertical: 6,
              textAlignVertical: 'center',
            }}
            value={value}
          />
        </View>

        {/* Right button: send or mic */}
        <Pressable
          accessibilityLabel={hasDraft ? '답변 보내기' : isListening ? '음성 입력 중지' : '음성 입력'}
          accessibilityRole="button"
          disabled={hasDraft ? false : !hasMic}
          onPress={
            hasDraft
              ? onSubmit
              : hasMic
                ? () => void handleMicPress()
                : undefined
          }
          style={{
            alignItems: 'center',
            backgroundColor: hasDraft
              ? fortuneTheme.colors.ctaBackground
              : fortuneTheme.colors.surfaceElevated,
            borderRadius: 16,
            height: 32,
            justifyContent: 'center',
            minWidth: 32,
            paddingHorizontal: hasDraft ? 10 : 0,
          }}
        >
          {hasDraft ? (
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
              보내기
            </AppText>
          ) : (
            <Ionicons
              color={
                isListening
                  ? fortuneTheme.colors.ctaBackground
                  : fortuneTheme.colors.textSecondary
              }
              name={isListening ? 'mic' : 'mic-outline'}
              size={18}
            />
          )}
        </Pressable>
      </View>
    </View>
  );
}

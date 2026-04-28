/**
 * Compact bottom-bar text input for surveys.
 * Mirrors the chat composer design: [skip?] [TextInput] [mic|send]
 *
 * Voice input uses expo-av recording + OpenAI Whisper via Supabase Edge Function.
 */

import { useCallback, useEffect, useRef } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { ActivityIndicator, Animated, Easing, Pressable, TextInput, View } from 'react-native';

import { AppText } from './app-text';
import { VoiceWaveform } from './voice-waveform';
import { fortuneTheme } from '../lib/theme';
import { useVoiceInput } from '../lib/use-voice-input';

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
  const hasDraft = value.trim().length > 0;

  const handleTranscript = useCallback(
    (text: string) => {
      onChangeText(value ? `${value} ${text}` : text);
    },
    [onChangeText, value],
  );

  const { isRecording, isTranscribing, isActive, currentVolume, toggleRecording } =
    useVoiceInput({ onTranscript: handleTranscript });

  // Pulse animation for recording indicator
  const pulseAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    if (isRecording) {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 0.5,
            duration: 600,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 600,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]),
      ).start();
    } else {
      pulseAnim.stopAnimation();
      pulseAnim.setValue(1);
    }
  }, [isRecording, pulseAnim]);

  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: isRecording
          ? '#EF4444'
          : isActive
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

        {/* TextInput / Waveform */}
        <View style={{ flex: 1 }}>
          {isRecording ? (
            <View
              style={{
                alignItems: 'center',
                flexDirection: 'row',
                minHeight: 28,
                paddingHorizontal: 4,
                paddingVertical: 6,
              }}
            >
              <VoiceWaveform
                color="#EF4444"
                height={20}
                volume={currentVolume}
              />
            </View>
          ) : (
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
          )}
        </View>

        {/* Right button: send or mic */}
        <Pressable
          accessibilityLabel={
            hasDraft
              ? '답변 보내기'
              : isRecording
                ? '녹음 중지'
                : isTranscribing
                  ? '변환 중'
                  : '음성 입력'
          }
          accessibilityRole="button"
          disabled={isTranscribing}
          onPress={
            hasDraft && !isActive
              ? onSubmit
              : () => void toggleRecording()
          }
          style={{
            alignItems: 'center',
            backgroundColor: hasDraft && !isActive
              ? fortuneTheme.colors.ctaBackground
              : isRecording
                ? '#EF4444'
                : fortuneTheme.colors.surfaceElevated,
            borderRadius: 16,
            height: 32,
            justifyContent: 'center',
            minWidth: 32,
            paddingHorizontal: hasDraft && !isActive ? 10 : 0,
          }}
        >
          {hasDraft && !isActive ? (
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
              보내기
            </AppText>
          ) : isTranscribing ? (
            <ActivityIndicator size="small" color={fortuneTheme.colors.ctaBackground} />
          ) : (
            <Animated.View style={{ opacity: isRecording ? pulseAnim : 1 }}>
              <Ionicons
                color={isRecording ? '#FFFFFF' : fortuneTheme.colors.textSecondary}
                name={isRecording ? 'mic' : 'mic-outline'}
                size={18}
              />
            </Animated.View>
          )}
        </Pressable>
      </View>
    </View>
  );
}

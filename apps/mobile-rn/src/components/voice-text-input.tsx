/**
 * TextInput with a microphone button for speech-to-text (STT).
 * Uses expo-av recording + OpenAI Whisper via Supabase Edge Function.
 * Works in Expo Go without native modules.
 */

import { useCallback, useEffect, useRef } from 'react';

import { Ionicons } from '@expo/vector-icons';
import {
  ActivityIndicator,
  Animated,
  Easing,
  Pressable,
  TextInput,
  View,
  type TextInputProps,
} from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { useVoiceInput } from '../lib/use-voice-input';
import { VoiceWaveform } from './voice-waveform';

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
  const handleTranscript = useCallback(
    (text: string) => {
      onChangeText(value ? `${value} ${text}` : text);
    },
    [onChangeText, value],
  );

  const { isRecording, isTranscribing, currentVolume, toggleRecording } = useVoiceInput({
    onTranscript: handleTranscript,
  });

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
        flexDirection: 'row',
        alignItems: 'flex-start',
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: isRecording
          ? '#EF4444'
          : fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.lg,
        borderWidth: 1,
      }}
    >
      {isRecording ? (
        <View
          style={{
            alignItems: 'center',
            flex: 1,
            flexDirection: 'row',
            gap: 10,
            minHeight: multiline ? 104 : 52,
            paddingHorizontal: 14,
            paddingVertical: multiline ? 14 : 12,
          }}
        >
          <VoiceWaveform
            color="#EF4444"
            height={20}
            volume={currentVolume}
          />
          <View style={{ flex: 1 }} />
        </View>
      ) : (
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
      )}
      <Pressable
        accessibilityLabel={
          isRecording
            ? '녹음 중지'
            : isTranscribing
              ? '변환 중'
              : '음성 입력 시작'
        }
        accessibilityRole="button"
        disabled={isTranscribing}
        onPress={() => void toggleRecording()}
        style={({ pressed }) => ({
          alignItems: 'center',
          justifyContent: 'center',
          paddingHorizontal: 12,
          paddingVertical: multiline ? 14 : 14,
          opacity: pressed ? 0.6 : 1,
        })}
      >
        {isTranscribing ? (
          <ActivityIndicator
            size="small"
            color={fortuneTheme.colors.ctaBackground}
          />
        ) : (
          <Animated.View style={{ opacity: isRecording ? pulseAnim : 1 }}>
            <Ionicons
              name={isRecording ? 'mic' : 'mic-outline'}
              size={20}
              color={isRecording ? '#EF4444' : fortuneTheme.colors.textTertiary}
            />
          </Animated.View>
        )}
      </Pressable>
    </View>
  );
}

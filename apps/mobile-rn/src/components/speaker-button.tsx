import { useCallback } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { ActivityIndicator, Alert, Pressable } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import type { TtsErrorState, TtsStatus } from '../lib/use-text-to-speech';

interface SpeakerButtonProps {
  /** 이 버튼이 담당하는 메시지 id. controller 의 activeMessageId 와 비교해 자기 상태 판정. */
  messageId: string;
  /** 글로벌 controller 상태 — 다른 메시지가 재생 중이면 이 버튼은 idle 로 남음. */
  controllerStatus: TtsStatus;
  controllerActiveMessageId: string | null;
  controllerError: TtsErrorState | null;
  onPress: () => void;
  onStop: () => void;
}

const PREMIUM_TITLE = '프리미엄 기능';
const PREMIUM_BODY = '캐릭터 음성 재생은 프리미엄 구독자 전용입니다. 구독을 둘러볼까요?';

export function SpeakerButton({
  messageId,
  controllerStatus,
  controllerActiveMessageId,
  controllerError,
  onPress,
  onStop,
}: SpeakerButtonProps) {
  const isMine = controllerActiveMessageId === messageId;
  const status: TtsStatus = isMine ? controllerStatus : 'idle';
  const isError = isMine && controllerStatus === 'error' && controllerError != null;

  const handlePress = useCallback(() => {
    if (isError && controllerError?.code === 'PREMIUM_REQUIRED') {
      Alert.alert(PREMIUM_TITLE, controllerError.message ?? PREMIUM_BODY, [
        { text: '나중에', style: 'cancel' },
        { text: '구독 보기', onPress: () => router.push('/premium') },
      ]);
      return;
    }
    if (status === 'playing' || status === 'loading') {
      onStop();
      return;
    }
    onPress();
  }, [controllerError, isError, onPress, onStop, status]);

  const iconName: React.ComponentProps<typeof Ionicons>['name'] = (() => {
    if (status === 'playing') return 'stop-circle-outline';
    if (status === 'error') return 'alert-circle-outline';
    return 'volume-medium-outline';
  })();

  const tint =
    status === 'error'
      ? fortuneTheme.colors.error
      : status === 'playing'
        ? fortuneTheme.colors.accentTertiary
        : fortuneTheme.colors.textTertiary;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={
        status === 'playing'
          ? '음성 재생 중지'
          : status === 'loading'
            ? '음성 준비 중'
            : '음성으로 듣기'
      }
      hitSlop={8}
      onPress={handlePress}
      style={({ pressed }) => ({
        alignItems: 'center',
        flexDirection: 'row',
        gap: 4,
        marginTop: 4,
        opacity: pressed ? 0.6 : 1,
        paddingVertical: 4,
        paddingHorizontal: 4,
      })}
    >
      {status === 'loading' ? (
        <ActivityIndicator color={tint} size="small" />
      ) : (
        <Ionicons color={tint} name={iconName} size={18} />
      )}
    </Pressable>
  );
}

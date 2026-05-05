import { useEffect, useRef, useState } from 'react';
import { Animated, Easing, View } from 'react-native';

import { AppText } from '../../components/app-text';
import type { ChatShellProgressMessage } from '../../lib/chat-shell';
import { fortuneTheme, withAlpha } from '../../lib/theme';

interface Props {
  message: ChatShellProgressMessage;
}

/**
 * 30초+ 비동기 운세 작업이 진행 중일 때 채팅 흐름에 표시되는 카드.
 *
 * - 1초 tick으로 경과시간 갱신 (re-render는 메시지가 mount된 동안만)
 * - estimatedSeconds 가 있으면 "약 N초 남음" 표시 (음수 시 "곧 완료" 로 폴백)
 * - phaseSteps 가 있으면 도트 시각화 (●●●○ 패턴)
 * - 펄스 애니메이션은 소형: scale 1 → 1.04 (1.4s) Sine in-out
 *
 * 상태 변경(phase 텍스트 / step 인덱스)은 호출측이 message-store updateMessage 로
 * 인플레이스 갱신 → React 가 자동 re-render. 이 컴포넌트는 stateless 렌더러.
 */
export function ProgressMessageCard({ message }: Props) {
  const elapsed = useElapsedSeconds(message.startedAt);
  const isErrored = message.error != null && message.error.length > 0;
  const pulse = usePulseAnimation(!isErrored);

  const remaining =
    message.estimatedSeconds != null
      ? Math.max(0, message.estimatedSeconds - elapsed)
      : null;

  const stepDots =
    message.phaseSteps && message.phaseSteps.length > 0 ? (
      <StepDots
        total={message.phaseSteps.length}
        currentIndex={message.currentStepIndex ?? 0}
      />
    ) : null;

  const accentColor = isErrored
    ? fortuneTheme.colors.error
    : fortuneTheme.colors.ctaBackground;

  return (
    <View
      style={{
        marginVertical: 6,
        paddingHorizontal: 16,
        paddingVertical: 14,
        borderRadius: fortuneTheme.radius.md,
        backgroundColor: withAlpha(accentColor, 0.06),
        borderWidth: 1,
        borderColor: withAlpha(accentColor, 0.18),
        gap: 10,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
        <Animated.View
          style={{
            width: 10,
            height: 10,
            borderRadius: 5,
            backgroundColor: accentColor,
            transform: [{ scale: pulse }],
          }}
        />
        <AppText
          variant="bodyMedium"
          color={fortuneTheme.colors.textPrimary}
          style={{ fontWeight: '600', flex: 1 }}
        >
          {message.phase}
        </AppText>
      </View>

      {stepDots}

      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textSecondary}
      >
        {isErrored
          ? (message.error ?? '오류가 발생했어요')
          : formatStatusLine(elapsed, remaining)}
      </AppText>
    </View>
  );
}

function StepDots({
  total,
  currentIndex,
}: {
  total: number;
  currentIndex: number;
}) {
  return (
    <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, idx) => {
        const isDone = idx < currentIndex;
        const isActive = idx === currentIndex;
        return (
          <View
            key={idx}
            style={{
              width: isActive ? 18 : 6,
              height: 6,
              borderRadius: 3,
              backgroundColor: isDone
                ? fortuneTheme.colors.ctaBackground
                : isActive
                  ? fortuneTheme.colors.ctaBackground
                  : withAlpha(fortuneTheme.colors.textSecondary, 0.25),
            }}
          />
        );
      })}
    </View>
  );
}

function formatStatusLine(elapsed: number, remaining: number | null): string {
  const elapsedLabel = `${elapsed}초 경과`;
  if (remaining == null) return elapsedLabel;
  if (remaining <= 0) return `${elapsedLabel} · 곧 완료`;
  return `${elapsedLabel} · 약 ${remaining}초 남음`;
}

function useElapsedSeconds(startedAt: number): number {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    setNow(Date.now());
    const tick = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(tick);
  }, [startedAt]);
  return Math.max(0, Math.floor((now - startedAt) / 1000));
}

function usePulseAnimation(active: boolean): Animated.Value {
  const value = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    if (!active) {
      value.setValue(1);
      return;
    }
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(value, {
          toValue: 1.4,
          duration: 700,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(value, {
          toValue: 1,
          duration: 700,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [value, active]);
  return value;
}

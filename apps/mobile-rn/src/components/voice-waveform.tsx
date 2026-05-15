/**
 * 녹음 중 실제 음량 샘플을 왼쪽으로 부드럽게 흘려보내는 긴 스펙트럼이다.
 * 새 샘플은 오른쪽에서 들어오고 기존 기록은 왼쪽으로 지나간다.
 *
 * 실시간 amplitude 는 `expo-speech-recognition` 의 `volumechange` 이벤트에서
 * 가져오며, `useVoiceInput` 이 0~1 정규화 값을 `currentVolume` 으로 노출한다.
 * 이 컴포넌트는 그 값만 prop 으로 받는다.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { Animated, Easing, View } from 'react-native';
import type { LayoutChangeEvent } from 'react-native';

import { fortuneTheme } from '../lib/theme';

interface VoiceWaveformProps {
  /** 0~1 정규화된 음량. useVoiceInput.currentVolume 그대로 전달. */
  volume: number;
  /** 막대 색상. 미지정 시 fortuneTheme.colors.ctaBackground. */
  color?: string;
  /** 막대 한 개의 너비. 기본 3. */
  barWidth?: number;
  /** 막대 사이 간격. 기본 5. */
  barGap?: number;
  /** 컨테이너 height. 막대 최대 높이도 이 값에서 결정됨. 기본 24. */
  height?: number;
}

const MIN_BAR_COUNT = 36;
const SAMPLE_INTERVAL_MS = 70;
const MIN_HEIGHT_RATIO = 0.08;
const SILENCE_THRESHOLD = 0.015;

function buildSilentRatios(count: number): number[] {
  return Array.from({ length: count }, () => MIN_HEIGHT_RATIO);
}

function buildAnimatedValues(count: number): Animated.Value[] {
  return Array.from({ length: count }, () => new Animated.Value(MIN_HEIGHT_RATIO));
}

function buildNextSample(volume: number, previousSample: number): number {
  const normalizedVolume = Math.max(0, Math.min(1, volume));
  const target = normalizedVolume <= SILENCE_THRESHOLD
    ? MIN_HEIGHT_RATIO
    : MIN_HEIGHT_RATIO + Math.pow(normalizedVolume, 0.72) * (1 - MIN_HEIGHT_RATIO);

  // 실제 volume 만 사용하되 샘플 간 높이 변화는 살짝 보간해서 부들부들 떨림을 줄인다.
  return previousSample * 0.35 + target * 0.65;
}

export function VoiceWaveform({
  volume,
  color,
  barWidth = 3,
  barGap = 5,
  height = 24,
}: VoiceWaveformProps) {
  const volumeRef = useRef(volume);
  const latestSampleRef = useRef(MIN_HEIGHT_RATIO);
  const ratiosRef = useRef<number[]>(buildSilentRatios(MIN_BAR_COUNT));
  const [animatedValues, setAnimatedValues] = useState<Animated.Value[]>(() =>
    buildAnimatedValues(MIN_BAR_COUNT),
  );

  useEffect(() => {
    volumeRef.current = volume;
  }, [volume]);

  const handleLayout = useCallback(
    (event: LayoutChangeEvent) => {
      const width = event.nativeEvent.layout.width;
      const nextCount = Math.max(MIN_BAR_COUNT, Math.ceil(width / (barWidth + barGap)) + 2);

      setAnimatedValues((currentValues) => {
        if (currentValues.length === nextCount) {
          return currentValues;
        }

        ratiosRef.current = buildSilentRatios(nextCount);
        latestSampleRef.current = MIN_HEIGHT_RATIO;
        return buildAnimatedValues(nextCount);
      });
    },
    [barGap, barWidth],
  );

  useEffect(() => {
    const interval = setInterval(() => {
      const nextSample = buildNextSample(volumeRef.current, latestSampleRef.current);
      latestSampleRef.current = nextSample;
      const nextRatios = [...ratiosRef.current.slice(1), nextSample];
      ratiosRef.current = nextRatios;

      Animated.parallel(
        animatedValues.map((value, index) =>
          Animated.timing(value, {
            toValue: nextRatios[index] ?? MIN_HEIGHT_RATIO,
            duration: SAMPLE_INTERVAL_MS,
            easing: Easing.out(Easing.quad),
            useNativeDriver: false,
          }),
        ),
      ).start();
    }, SAMPLE_INTERVAL_MS);

    return () => {
      clearInterval(interval);
      animatedValues.forEach((value) => value.stopAnimation());
    };
  }, [animatedValues]);

  const barColor = color ?? fortuneTheme.colors.ctaBackground;

  return (
    <View
      accessibilityElementsHidden
      importantForAccessibility="no-hide-descendants"
      onLayout={handleLayout}
      style={{
        alignItems: 'center',
        flex: 1,
        flexDirection: 'row',
        height,
        overflow: 'hidden',
      }}
    >
      {animatedValues.map((value, index) => (
        <Animated.View
          key={index}
          style={{
            backgroundColor: barColor,
            borderRadius: barWidth / 2,
            height: value.interpolate({
              inputRange: [0, 1],
              outputRange: [Math.max(2, height * MIN_HEIGHT_RATIO), height],
            }),
            marginRight: barGap,
            opacity: value.interpolate({
              inputRange: [MIN_HEIGHT_RATIO, MIN_HEIGHT_RATIO + 0.01, 1],
              outputRange: [0.42, 0.42, 0.92],
            }),
            width: barWidth,
          }}
        />
      ))}
    </View>
  );
}

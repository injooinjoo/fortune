/**
 * 녹음 중 음량을 왼쪽으로 흐르는 긴 스펙트럼으로 시각화한다.
 * 새 샘플은 오른쪽에서 들어오고 기존 기록은 맥박처럼 왼쪽으로 지나간다.
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

type Sample = {
  id: number;
  ratio: number;
};

const MIN_BAR_COUNT = 36;
const SAMPLE_INTERVAL_MS = 110;
const MIN_HEIGHT_RATIO = 0.16;
const IDLE_RATIOS = [0.16, 0.24, 0.18, 0.3, 0.2, 0.26] as const;

function buildNextSample(volume: number, sampleIndex: number): number {
  const normalizedVolume = Math.max(0, Math.min(1, volume));
  const heartbeat = normalizedVolume > 0.05 && sampleIndex % 9 === 0 ? 0.22 : 0;
  const ripple = (((sampleIndex * 7) % 13) / 70) * (0.35 + normalizedVolume);
  const driven = MIN_HEIGHT_RATIO + normalizedVolume * 0.66 + heartbeat + ripple;

  return Math.max(MIN_HEIGHT_RATIO, Math.min(1, driven));
}

function buildIdleSamples(count: number): Sample[] {
  return Array.from({ length: count }, (_, index) => ({
    id: index,
    ratio: IDLE_RATIOS[index % IDLE_RATIOS.length],
  }));
}

export function VoiceWaveform({
  volume,
  color,
  barWidth = 3,
  barGap = 5,
  height = 24,
}: VoiceWaveformProps) {
  const translateX = useRef(new Animated.Value(0)).current;
  const volumeRef = useRef(volume);
  const sampleIndexRef = useRef(MIN_BAR_COUNT);
  const [sampleCount, setSampleCount] = useState(MIN_BAR_COUNT);
  const [samples, setSamples] = useState<Sample[]>(() => buildIdleSamples(MIN_BAR_COUNT));

  useEffect(() => {
    volumeRef.current = volume;
  }, [volume]);

  const handleLayout = useCallback(
    (event: LayoutChangeEvent) => {
      const width = event.nativeEvent.layout.width;
      const nextCount = Math.max(MIN_BAR_COUNT, Math.ceil(width / (barWidth + barGap)) + 3);

      setSampleCount((currentCount) => {
        if (currentCount === nextCount) {
          return currentCount;
        }
        return nextCount;
      });
    },
    [barGap, barWidth],
  );

  useEffect(() => {
    setSamples((currentSamples) => {
      if (currentSamples.length === sampleCount) {
        return currentSamples;
      }

      if (currentSamples.length > sampleCount) {
        return currentSamples.slice(currentSamples.length - sampleCount);
      }

      const missingCount = sampleCount - currentSamples.length;
      const prefix = Array.from({ length: missingCount }, (_, index) => ({
        id: sampleIndexRef.current + index + 1,
        ratio: IDLE_RATIOS[index % IDLE_RATIOS.length],
      }));
      sampleIndexRef.current += missingCount;
      return [...prefix, ...currentSamples];
    });
  }, [sampleCount]);

  useEffect(() => {
    let stopped = false;
    let timeout: ReturnType<typeof setTimeout> | undefined;
    const stepWidth = barWidth + barGap;

    const scheduleNextSample = () => {
      if (stopped) {
        return;
      }

      translateX.setValue(0);
      Animated.timing(translateX, {
        toValue: -stepWidth,
        duration: SAMPLE_INTERVAL_MS,
        easing: Easing.linear,
        useNativeDriver: true,
      }).start(({ finished }) => {
        if (stopped || !finished) {
          return;
        }

        sampleIndexRef.current += 1;
        const nextSample: Sample = {
          id: sampleIndexRef.current,
          ratio: buildNextSample(volumeRef.current, sampleIndexRef.current),
        };
        setSamples((currentSamples) => [...currentSamples.slice(1), nextSample]);
        timeout = setTimeout(scheduleNextSample, 0);
      });
    };

    scheduleNextSample();

    return () => {
      stopped = true;
      if (timeout) {
        clearTimeout(timeout);
      }
      translateX.stopAnimation();
    };
  }, [barGap, barWidth, translateX]);

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
      <Animated.View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          transform: [{ translateX }],
        }}
      >
        {samples.map((sample, index) => (
          <View
            key={sample.id}
            style={{
              backgroundColor: barColor,
              borderRadius: barWidth / 2,
              height: Math.max(2, height * sample.ratio),
              marginRight: barGap,
              opacity: index > samples.length - 7 ? 1 : 0.78,
              width: barWidth,
            }}
          />
        ))}
      </Animated.View>
    </View>
  );
}

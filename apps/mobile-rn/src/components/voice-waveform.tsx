/**
 * 녹음 중 음량을 막대 5개로 시각화한다. 클로드 앱과 동일한 톤 — 마이크에서
 * 들어오는 amplitude 를 받아 막대 높이를 부드럽게 보간한다.
 *
 * 실시간 amplitude 는 `expo-speech-recognition` 의 `volumechange` 이벤트에서
 * 가져오며, `useVoiceInput` 이 0~1 정규화 값을 `currentVolume` 으로 노출한다.
 * 이 컴포넌트는 그 값만 prop 으로 받는다.
 */

import { useEffect, useRef } from 'react';
import { Animated, Easing, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';

interface VoiceWaveformProps {
  /** 0~1 정규화된 음량. useVoiceInput.currentVolume 그대로 전달. */
  volume: number;
  /** 막대 색상. 미지정 시 fortuneTheme.colors.ctaBackground. */
  color?: string;
  /** 막대 한 개의 너비. 기본 3. */
  barWidth?: number;
  /** 막대 사이 간격. 기본 4. */
  barGap?: number;
  /** 컨테이너 height. 막대 최대 높이도 이 값에서 결정됨. 기본 24. */
  height?: number;
}

const BAR_COUNT = 5;

// 각 막대마다 음량을 약간 다르게 받아들이게 해서 정확히 똑같이 움직이지 않도록.
// 가운데 막대가 가장 민감, 양 끝 막대가 덜 민감 (자연스러운 스펙트럼 느낌).
const BAR_SENSITIVITY = [0.7, 0.9, 1.0, 0.9, 0.7] as const;

// 침묵일 때도 살짝 보이도록 하는 최소 비율 (height 의 16%).
const MIN_HEIGHT_RATIO = 0.16;

export function VoiceWaveform({
  volume,
  color,
  barWidth = 3,
  barGap = 4,
  height = 24,
}: VoiceWaveformProps) {
  const animValues = useRef(
    Array.from({ length: BAR_COUNT }, () => new Animated.Value(MIN_HEIGHT_RATIO)),
  ).current;

  useEffect(() => {
    const targets = BAR_SENSITIVITY.map((sensitivity) => {
      const driven = volume * sensitivity;
      return Math.max(MIN_HEIGHT_RATIO, Math.min(1, driven));
    });

    const animations = animValues.map((value, idx) =>
      Animated.timing(value, {
        toValue: targets[idx],
        // 100ms — volumechange 이벤트 갱신 주기와 동일하게 맞춰서 끊김 없는
        // 보간. useNativeDriver 는 height 보간 불가라 false.
        duration: 100,
        easing: Easing.out(Easing.quad),
        useNativeDriver: false,
      }),
    );
    Animated.parallel(animations).start();
  }, [volume, animValues]);

  const barColor = color ?? fortuneTheme.colors.ctaBackground;

  return (
    <View
      accessibilityElementsHidden
      importantForAccessibility="no-hide-descendants"
      style={{
        alignItems: 'center',
        flexDirection: 'row',
        height,
        justifyContent: 'center',
      }}
    >
      {animValues.map((value, idx) => (
        <Animated.View
          key={idx}
          style={{
            backgroundColor: barColor,
            borderRadius: barWidth / 2,
            height: value.interpolate({
              inputRange: [0, 1],
              outputRange: [0, height],
            }),
            marginHorizontal: barGap / 2,
            width: barWidth,
          }}
        />
      ))}
    </View>
  );
}

/**
 * StarField — 24개 랜덤 별 twinkle 애니메이션.
 */

import { useEffect, useMemo, useRef } from 'react';
import { Animated, Easing, View } from 'react-native';

interface StarSpec {
  key: number;
  xPct: number;
  yPct: number;
  diameter: number;
  baseOpacity: number;
  delayMs: number;
  durationMs: number;
}

export interface StarFieldProps {
  count?: number;
}

export function StarField({ count = 24 }: StarFieldProps) {
  const stars = useMemo<StarSpec[]>(
    () =>
      Array.from({ length: count }, (_, i) => {
        const r = Math.random() * 1.2 + 0.4;
        return {
          key: i,
          xPct: Math.random() * 100,
          yPct: Math.random() * 100,
          diameter: r * 2,
          baseOpacity: Math.random() * 0.6 + 0.2,
          delayMs: Math.random() * 2000,
          durationMs: 2000 + Math.random() * 1000,
        };
      }),
    [count],
  );

  return (
    <View
      pointerEvents="none"
      style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
    >
      {stars.map((s) => (
        <Star key={s.key} spec={s} />
      ))}
    </View>
  );
}

function Star({ spec }: { spec: StarSpec }) {
  const opacity = useRef(new Animated.Value(spec.baseOpacity)).current;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.delay(spec.delayMs),
        Animated.timing(opacity, {
          toValue: Math.min(1, spec.baseOpacity + 0.4),
          duration: spec.durationMs / 2,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(opacity, {
          toValue: spec.baseOpacity,
          duration: spec.durationMs / 2,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]),
    );
    loop.start();
    return () => {
      loop.stop();
    };
  }, [opacity, spec.baseOpacity, spec.delayMs, spec.durationMs]);

  return (
    <Animated.View
      style={{
        position: 'absolute',
        left: `${spec.xPct}%`,
        top: `${spec.yPct}%`,
        width: spec.diameter,
        height: spec.diameter,
        borderRadius: spec.diameter,
        backgroundColor: '#FFFFFF',
        opacity,
      }}
    />
  );
}

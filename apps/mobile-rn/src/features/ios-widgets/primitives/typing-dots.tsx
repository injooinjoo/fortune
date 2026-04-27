/**
 * TypingDots — 3개 dot bounce (1200ms cycle, 160ms stagger).
 */

import { useEffect, useMemo, useRef } from 'react';
import { Animated, View } from 'react-native';

import { WIDGET_COLORS } from './colors';

export interface TypingDotsProps {
  color?: string;
  size?: number;
}

export function TypingDots({ color = WIDGET_COLORS.whiteMid, size = 4 }: TypingDotsProps) {
  const dots = useMemo(() => [0, 1, 2].map(() => new Animated.Value(0)), []);
  const started = useRef(false);

  useEffect(() => {
    if (started.current) return;
    started.current = true;
    dots.forEach((dot, i) => {
      const loop = Animated.loop(
        Animated.sequence([
          Animated.delay(i * 160),
          Animated.timing(dot, {
            toValue: -3,
            duration: 300,
            useNativeDriver: true,
          }),
          Animated.timing(dot, {
            toValue: 0,
            duration: 300,
            useNativeDriver: true,
          }),
          Animated.delay(1200 - 600 - i * 160),
        ]),
      );
      loop.start();
    });
  }, [dots]);

  return (
    <View style={{ flexDirection: 'row', alignItems: 'center' }}>
      {dots.map((dot, i) => (
        <Animated.View
          key={i}
          style={{
            width: size,
            height: size,
            borderRadius: size,
            marginHorizontal: size * 0.35,
            backgroundColor: color,
            transform: [{ translateY: dot }],
          }}
        />
      ))}
    </View>
  );
}

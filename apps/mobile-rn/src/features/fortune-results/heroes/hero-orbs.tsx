// HeroOrbs: port of result-cards.jsx HeroLove (~277-293) — 2 orbs drift in from sides with a heart
// connector. RN can't drop-shadow SVG paths, so heart is a styled Text glyph; orbs are shadowed Views.
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroOrbsProps {
  data: EmbeddedResultPayload;
  progress: number;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const LEFT_COLOR = '#FF8FB1';
const RIGHT_COLOR = '#C4B8FF';

export default function HeroOrbs({ data, progress }: HeroOrbsProps) {
  const p = clamp01(progress);
  const leftAnim = useRef(new Animated.Value(0)).current;
  const rightAnim = useRef(new Animated.Value(0)).current;
  const heartAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(leftAnim, {
      toValue: easeOut(stage(p, 0, 0.5)),
      duration: 200,
      useNativeDriver: true,
    }).start();
    Animated.timing(rightAnim, {
      toValue: easeOut(stage(p, 0.15, 0.65)),
      duration: 200,
      useNativeDriver: true,
    }).start();
    Animated.timing(heartAnim, {
      toValue: stage(p, 0.4, 0.7),
      duration: 200,
      useNativeDriver: true,
    }).start();
  }, [p, leftAnim, rightAnim, heartAnim]);

  const leftTx = leftAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [-24, 0],
  });
  const rightTx = rightAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [24, 0],
  });
  const leftScale = leftAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.6, 1],
  });
  const rightScale = rightAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.6, 1],
  });
  const heartScale = heartAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.4, 1.2],
  });

  const scoreLabel =
    typeof data.score === 'number' ? `${Math.round(data.score)}` : '';

  return (
    <View
      style={{
        paddingVertical: 18,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 6,
        }}
      >
        <Animated.View
          style={{
            width: 56,
            height: 56,
            borderRadius: 28,
            backgroundColor: LEFT_COLOR,
            shadowColor: LEFT_COLOR,
            shadowOpacity: 0.6,
            shadowRadius: 12,
            shadowOffset: { width: 0, height: 0 },
            opacity: leftAnim,
            transform: [{ translateX: leftTx }, { scale: leftScale }],
          }}
        />
        <Animated.Text
          style={{
            fontSize: 28,
            lineHeight: 32,
            color: '#FF8FB1',
            opacity: heartAnim,
            transform: [{ scale: heartScale }],
          }}
        >
          ♥
        </Animated.Text>
        <Animated.View
          style={{
            width: 56,
            height: 56,
            borderRadius: 28,
            backgroundColor: RIGHT_COLOR,
            shadowColor: RIGHT_COLOR,
            shadowOpacity: 0.6,
            shadowRadius: 12,
            shadowOffset: { width: 0, height: 0 },
            opacity: rightAnim,
            transform: [{ translateX: rightTx }, { scale: rightScale }],
          }}
        />
      </View>
      {scoreLabel ? (
        <Text
          style={{
            marginTop: 10,
            fontSize: 12,
            lineHeight: 16,
            color: fortuneTheme.colors.textSecondary,
            letterSpacing: 1.2,
          }}
        >
          {data.title}
        </Text>
      ) : null}
    </View>
  );
}

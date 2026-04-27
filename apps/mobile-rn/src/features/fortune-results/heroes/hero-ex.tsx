/**
 * HeroEx — `result-cards.jsx:HeroEx` (824-836). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface HeroExProps {
  data?: unknown;
  progress?: number;
}

function Orb({ color, highlight }: { color: string; highlight: string }) {
  return (
    <View
      style={{
        width: 44,
        height: 44,
        borderRadius: 22,
        backgroundColor: color,
        overflow: 'hidden',
      }}
    >
      <View
        style={{
          position: 'absolute',
          top: 4,
          left: 10,
          width: 18,
          height: 18,
          borderRadius: 9,
          backgroundColor: highlight,
          opacity: 0.7,
        }}
      />
    </View>
  );
}

export default function HeroEx({ progress = 1 }: HeroExProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.5);
  const off = tween(easeOut(l), 0, 24);
  const centerOpacity = stage(p, 0.3, 0.5);

  const leftAnim = useRef(new Animated.Value(0)).current;
  const rightAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(leftAnim, {
      toValue: -off,
      duration: 120,
      useNativeDriver: true,
    }).start();
    Animated.timing(rightAnim, {
      toValue: off,
      duration: 120,
      useNativeDriver: true,
    }).start();
  }, [off, leftAnim, rightAnim]);

  return (
    <View
      style={{
        paddingTop: 16,
        paddingHorizontal: 6,
        paddingBottom: 6,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 6,
      }}
    >
      <Animated.View
        style={{ opacity: l, transform: [{ translateX: leftAnim }] }}
      >
        <Orb color="#7a3850" highlight="#FFC7D9" />
      </Animated.View>
      <Text
        style={{
          fontFamily: 'ZenSerif',
          fontSize: 20,
          color: fortuneTheme.colors.textTertiary,
          opacity: centerOpacity,
        }}
      >
        · · ·
      </Text>
      <Animated.View
        style={{ opacity: l, transform: [{ translateX: rightAnim }] }}
      >
        <Orb color="#3b2a94" highlight="#C4B8FF" />
      </Animated.View>
    </View>
  );
}

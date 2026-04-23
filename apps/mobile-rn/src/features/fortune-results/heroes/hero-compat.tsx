/**
 * HeroCompat — `result-cards.jsx:HeroCompat` (353-371). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface CompatData {
  pair?: { a?: string; b?: string };
  leftLabel?: string;
  rightLabel?: string;
}

interface HeroCompatProps {
  data: EmbeddedResultPayload;
  progress?: number;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const AMBER = '#E0A76B';

function Orb({ color, highlight, glow }: { color: string; highlight: string; glow: string }) {
  return (
    <View
      style={{
        width: 54,
        height: 54,
        borderRadius: 27,
        backgroundColor: color,
        overflow: 'hidden',
        shadowColor: glow,
        shadowOpacity: 0.33,
        shadowRadius: 16,
        shadowOffset: { width: 0, height: 0 },
      }}
    >
      <View
        style={{
          position: 'absolute',
          top: 6,
          left: 12,
          width: 22,
          height: 22,
          borderRadius: 11,
          backgroundColor: highlight,
          opacity: 0.75,
        }}
      />
    </View>
  );
}

export default function HeroCompat({ data, progress = 1 }: HeroCompatProps) {
  // Defensive: data 가 런타임에 undefined 로 도착해도 crash 방지.
  const raw: CompatData = (data && typeof data === 'object'
    ? ((data as unknown as { compat?: CompatData }).compat ?? {})
    : {}) as CompatData;
  const leftLabel = raw.pair?.a ?? raw.leftLabel ?? '나';
  const rightLabel = raw.pair?.b ?? raw.rightLabel ?? '상대';
  const p = clamp01(progress);

  const l = stage(p, 0, 0.4);
  const off = tween(easeOut(l), 60, 0);
  const centerOpacity = stage(p, 0.3, 0.5);

  const leftAnim = useRef(new Animated.Value(-60)).current;
  const rightAnim = useRef(new Animated.Value(60)).current;

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
    <View style={{ paddingTop: 16, paddingHorizontal: 6, paddingBottom: 6 }}>
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 12,
        }}
      >
        <Animated.View
          style={{
            alignItems: 'center',
            opacity: l,
            transform: [{ translateX: leftAnim }],
          }}
        >
          <Orb color="#8B7BE8" highlight="#C4B8FF" glow="#8B7BE8" />
          <Text
            style={{
              fontSize: 11,
              color: fortuneTheme.colors.textSecondary,
              marginTop: 6,
            }}
          >
            {leftLabel}
          </Text>
        </Animated.View>

        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 30,
            color: AMBER,
            opacity: centerOpacity,
          }}
        >
          ❂
        </Text>

        <Animated.View
          style={{
            alignItems: 'center',
            opacity: l,
            transform: [{ translateX: rightAnim }],
          }}
        >
          <Orb color="#FF8FB1" highlight="#FFC7D9" glow="#FF8FB1" />
          <Text
            style={{
              fontSize: 11,
              color: fortuneTheme.colors.textSecondary,
              marginTop: 6,
            }}
          >
            {rightLabel}
          </Text>
        </Animated.View>
      </View>
    </View>
  );
}

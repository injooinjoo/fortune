// HeroCalendar: port of result-cards.jsx HeroCal (~183-202). Perspective X-flip approximated
// with rotateX (RN transform supports rotateX but ignores CSS perspective — slight fidelity loss).
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroCalendarProps {
  data: EmbeddedResultPayload;
  progress: number;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const AMBER = '#E0A76B';

export default function HeroCalendar({ data, progress }: HeroCalendarProps) {
  const raw = data as unknown as {
    lunar?: string;
    season?: string;
    cal?: { ganji?: string; lunar?: string; season?: string };
  };
  const ganji = raw.cal?.ganji ?? '甲辰';
  const lunarFull = raw.lunar ?? raw.cal?.lunar ?? '음력 4월 11일';
  const season = raw.season ?? raw.cal?.season ?? '곡우';
  const dayWord = lunarFull.split(' ').pop() ?? lunarFull;

  const p = clamp01(progress);
  const anim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const local = easeOut(stage(p, 0, 0.55));
    Animated.timing(anim, {
      toValue: local,
      duration: 200,
      useNativeDriver: true,
    }).start();
  }, [p, anim]);

  const rotateX = anim.interpolate({
    inputRange: [0, 1],
    outputRange: ['60deg', '0deg'],
  });

  return (
    <View
      style={{
        paddingTop: 16,
        paddingHorizontal: 4,
        paddingBottom: 4,
        alignItems: 'center',
      }}
    >
      <Animated.View
        style={{
          width: 200,
          height: 130,
          borderRadius: 14,
          borderWidth: 1,
          borderColor: fortuneTheme.colors.border,
          // linear-gradient(180deg, #1A1A1A, #111118) 근사: 상단 레이어 + 하단 레이어
          backgroundColor: '#1A1A1A',
          overflow: 'hidden',
          opacity: anim,
          transform: [{ perspective: 700 }, { rotateX }],
        }}
      >
        {/* 하단 레이어 (gradient 근사) */}
        <View
          style={{
            position: 'absolute',
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: '#111118',
          }}
        />
        <Text
          style={{
            position: 'absolute',
            top: 10,
            left: 0,
            right: 0,
            textAlign: 'center',
            fontSize: 9,
            lineHeight: 12,
            color: AMBER,
            letterSpacing: 2,
          }}
        >
          {ganji}
        </Text>
        <Text
          style={{
            position: 'absolute',
            top: 30,
            left: 0,
            right: 0,
            textAlign: 'center',
            fontSize: 48,
            lineHeight: 56,
            fontFamily: 'ZenSerif',
            color: fortuneTheme.colors.textPrimary,
            letterSpacing: 0.96,
          }}
        >
          {dayWord}
        </Text>
        <Text
          style={{
            position: 'absolute',
            bottom: 14,
            left: 0,
            right: 0,
            textAlign: 'center',
            fontSize: 10,
            lineHeight: 14,
            color: fortuneTheme.colors.textSecondary,
            letterSpacing: 1.2,
          }}
        >
          {lunarFull} · {season}
        </Text>
        <View
          style={{
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
            height: 3,
            backgroundColor: AMBER,
          }}
        />
      </Animated.View>
    </View>
  );
}

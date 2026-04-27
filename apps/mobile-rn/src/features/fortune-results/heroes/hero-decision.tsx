/**
 * HeroDecision — `result-cards.jsx:HeroDecision` (688-706).
 *
 * 원본:
 *   SVG 160×100 저울.
 *   - 바(120px 가로) 중앙 (80,50), rotate -tilt deg, tilt = tween(easeOut(stage(p, 0.2, 0.7)), 0, diff * 0.3)
 *   - 좌 플레이트: rect (10,40,24,16) rx 3 fill #8FB8FF, 텍스트 'A' fg 0B0B10 700
 *   - 우 플레이트: rect (126,40,24,16) rx 3 fill #E0A76B, 텍스트 'B' fg 0B0B10 700
 *   - 플레이트 fadeIn [p:0.1..0.4]
 *   - 스탠드: 수직선 (80,50→80,90), 삼각형 받침 (70,95-90,95-80,82) fill fg2
 *
 * RN 포팅: View 조합 + transform rotate.
 */
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface HeroDecisionProps {
  data?: unknown;
  progress?: number;
}

function extractDiff(payload: unknown): number {
  if (!payload || typeof payload !== 'object') return 20;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const options = Array.isArray(data.options) ? data.options : null;
  if (!options || options.length < 2) return 20;
  const a =
    typeof (options[0] as Record<string, unknown>)?.v === 'number'
      ? ((options[0] as Record<string, unknown>).v as number)
      : 50;
  const b =
    typeof (options[1] as Record<string, unknown>)?.v === 'number'
      ? ((options[1] as Record<string, unknown>).v as number)
      : 50;
  return Math.max(-60, Math.min(60, a - b));
}

export default function HeroDecision({ data: payload, progress = 1 }: HeroDecisionProps) {
  const p = clamp01(progress);
  const diff = extractDiff(payload);
  const tiltAngle = tween(easeOut(stage(p, 0.2, 0.7)), 0, diff * 0.3);
  const plateOpacity = stage(p, 0.1, 0.4);

  const tiltAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(tiltAnim, {
      toValue: -tiltAngle,
      duration: 120,
      useNativeDriver: true,
    }).start();
  }, [tiltAngle, tiltAnim]);

  const rotate = tiltAnim.interpolate({
    inputRange: [-90, 90],
    outputRange: ['-90deg', '90deg'],
  });

  return (
    <View
      style={{
        paddingTop: 10,
        paddingHorizontal: 6,
        paddingBottom: 2,
        alignItems: 'center',
      }}
    >
      <View style={{ width: 160, height: 100, alignItems: 'center', justifyContent: 'center' }}>
        {/* 저울 바 + 플레이트 (회전) */}
        <Animated.View
          style={{
            position: 'absolute',
            top: 40,
            left: 10,
            width: 140,
            height: 20,
            transform: [{ rotate }],
          }}
        >
          {/* 바 */}
          <View
            style={{
              position: 'absolute',
              top: 9,
              left: 10,
              width: 120,
              height: 2,
              backgroundColor: fortuneTheme.colors.textSecondary,
            }}
          />
          {/* 좌 플레이트 A */}
          <View
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: 24,
              height: 16,
              borderRadius: 3,
              backgroundColor: '#8FB8FF',
              alignItems: 'center',
              justifyContent: 'center',
              opacity: plateOpacity,
            }}
          >
            <Text
              style={{
                fontSize: 10,
                fontWeight: '700',
                color: '#0B0B10',
              }}
            >
              A
            </Text>
          </View>
          {/* 우 플레이트 B */}
          <View
            style={{
              position: 'absolute',
              top: 0,
              right: 0,
              width: 24,
              height: 16,
              borderRadius: 3,
              backgroundColor: '#E0A76B',
              alignItems: 'center',
              justifyContent: 'center',
              opacity: plateOpacity,
            }}
          >
            <Text
              style={{
                fontSize: 10,
                fontWeight: '700',
                color: '#0B0B10',
              }}
            >
              B
            </Text>
          </View>
        </Animated.View>
        {/* 스탠드 (수직선 + 받침 삼각형 근사) */}
        <View
          style={{
            position: 'absolute',
            top: 50,
            left: 79,
            width: 2,
            height: 40,
            backgroundColor: fortuneTheme.colors.textSecondary,
          }}
        />
        <View
          style={{
            position: 'absolute',
            top: 82,
            left: 70,
            width: 0,
            height: 0,
            borderLeftWidth: 10,
            borderRightWidth: 10,
            borderBottomWidth: 13,
            borderLeftColor: 'transparent',
            borderRightColor: 'transparent',
            borderBottomColor: fortuneTheme.colors.textSecondary,
            transform: [{ rotate: '180deg' }],
          }}
        />
      </View>
    </View>
  );
}

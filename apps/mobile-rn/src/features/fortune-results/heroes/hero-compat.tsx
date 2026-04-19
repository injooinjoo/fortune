// HeroCompat: port of result-cards.jsx HeroCompat (~352-371). Two orbs converge to center
// then 4 metric bars stack below. Orbs are Views with backgroundColor + shadow (no radial gradient).
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

import { MetricBar } from '../primitives/metric-bar';

interface HeroCompatProps {
  data: EmbeddedResultPayload;
  progress: number;
}

interface CompatMetric {
  label?: string;
  score?: number;
}
interface CompatData {
  leftLabel?: string;
  rightLabel?: string;
  metrics?: CompatMetric[];
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const AMBER = '#E0A76B';
const LEFT_COLOR = '#8B7BE8';
const RIGHT_COLOR = '#FF8FB1';
const BAR_COLORS = ['#8B7BE8', '#FF8FB1', '#68B593', '#E0A76B'];

const PLACEHOLDER_METRICS: CompatMetric[] = [
  { label: '가치관', score: 72 },
  { label: '생활리듬', score: 65 },
  { label: '감정교감', score: 80 },
  { label: '장기궁합', score: 70 },
];

export default function HeroCompat({ data, progress }: HeroCompatProps) {
  const raw = (data as unknown as { compat?: CompatData }).compat ?? {};
  const leftLabel = raw.leftLabel ?? '나';
  const rightLabel = raw.rightLabel ?? '상대';
  const metrics: CompatMetric[] =
    raw.metrics && raw.metrics.length > 0
      ? raw.metrics.slice(0, 4)
      : PLACEHOLDER_METRICS;
  const p = clamp01(progress);

  const leftAnim = useRef(new Animated.Value(0)).current;
  const rightAnim = useRef(new Animated.Value(0)).current;
  const centerAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(leftAnim, {
      toValue: easeOut(stage(p, 0, 0.4)),
      duration: 160,
      useNativeDriver: true,
    }).start();
    Animated.timing(rightAnim, {
      toValue: easeOut(stage(p, 0.05, 0.45)),
      duration: 160,
      useNativeDriver: true,
    }).start();
    Animated.timing(centerAnim, {
      toValue: stage(p, 0.3, 0.5),
      duration: 160,
      useNativeDriver: true,
    }).start();
  }, [p, leftAnim, rightAnim, centerAnim]);

  const leftTx = leftAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [-60, 0],
  });
  const rightTx = rightAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [60, 0],
  });

  return (
    <View style={{ paddingVertical: 10 }}>
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
            opacity: leftAnim,
            transform: [{ translateX: leftTx }],
          }}
        >
          <View
            style={{
              width: 54,
              height: 54,
              borderRadius: 27,
              backgroundColor: LEFT_COLOR,
              shadowColor: LEFT_COLOR,
              shadowOpacity: 0.6,
              shadowRadius: 12,
              shadowOffset: { width: 0, height: 0 },
            }}
          />
          <Text
            style={{
              fontSize: 11,
              lineHeight: 14,
              color: fortuneTheme.colors.textSecondary,
              marginTop: 6,
            }}
          >
            {leftLabel}
          </Text>
        </Animated.View>
        <Animated.Text
          style={{
            fontSize: 30,
            lineHeight: 36,
            color: AMBER,
            opacity: centerAnim,
          }}
        >
          ❂
        </Animated.Text>
        <Animated.View
          style={{
            alignItems: 'center',
            opacity: rightAnim,
            transform: [{ translateX: rightTx }],
          }}
        >
          <View
            style={{
              width: 54,
              height: 54,
              borderRadius: 27,
              backgroundColor: RIGHT_COLOR,
              shadowColor: RIGHT_COLOR,
              shadowOpacity: 0.6,
              shadowRadius: 12,
              shadowOffset: { width: 0, height: 0 },
            }}
          />
          <Text
            style={{
              fontSize: 11,
              lineHeight: 14,
              color: fortuneTheme.colors.textSecondary,
              marginTop: 6,
            }}
          >
            {rightLabel}
          </Text>
        </Animated.View>
      </View>
      <View style={{ marginTop: 16, gap: 8, paddingHorizontal: 6 }}>
        {metrics.map((m, i) => (
          <MetricBar
            key={i}
            label={m.label ?? ''}
            value={m.score ?? 0}
            max={100}
            color={BAR_COLORS[i % BAR_COLORS.length]}
            progress={stage(p, 0.45 + i * 0.08, 0.7 + i * 0.08)}
            suffix="%"
          />
        ))}
      </View>
    </View>
  );
}

// HeroLine: port of result-cards.jsx HeroLine (~327-350). RN has no SVG dasharray reveal —
// approximated as a row of value-height bars (growing width + height) connected by visual gap.
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroLineProps {
  data: EmbeddedResultPayload;
  progress: number;
}

interface TimelinePoint {
  label?: string;
  value?: number;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const PLACEHOLDER: TimelinePoint[] = [
  { label: '1', value: 40 },
  { label: '2', value: 55 },
  { label: '3', value: 48 },
  { label: '4', value: 70 },
  { label: '5', value: 82 },
  { label: '6', value: 78 },
  { label: '7', value: 92 },
];

const CHART_H = 72;

export default function HeroLine({ data, progress }: HeroLineProps) {
  const raw = (data as unknown as { timeline?: TimelinePoint[] }).timeline;
  const series: TimelinePoint[] =
    raw && raw.length > 0 ? raw.slice(0, 12) : PLACEHOLDER;
  const color = '#8FB8FF';
  const p = clamp01(progress);

  const anims = useRef(series.map(() => new Animated.Value(0))).current;

  useEffect(() => {
    series.forEach((_, i) => {
      const local = stage(p, 0.1 + i * 0.06, 0.3 + i * 0.06);
      Animated.timing(anims[i], {
        toValue: local,
        duration: 100,
        useNativeDriver: false,
      }).start();
    });
  }, [p, anims, series]);

  const maxV = Math.max(...series.map((s) => s.value ?? 0), 1);

  return (
    <View style={{ paddingVertical: 14, paddingHorizontal: 10 }}>
      <View
        style={{
          height: CHART_H,
          flexDirection: 'row',
          alignItems: 'flex-end',
          gap: 4,
        }}
      >
        {series.map((pt, i) => {
          const target = ((pt.value ?? 0) / maxV) * (CHART_H - 6);
          const heightAnim = anims[i].interpolate({
            inputRange: [0, 1],
            outputRange: [2, Math.max(2, target)],
          });
          const isLast = i === series.length - 1;
          return (
            <View
              key={i}
              style={{
                flex: 1,
                alignItems: 'center',
                justifyContent: 'flex-end',
              }}
            >
              <Animated.View
                style={{
                  width: isLast ? 7 : 4,
                  height: heightAnim,
                  borderRadius: 2,
                  backgroundColor: color,
                  opacity: anims[i],
                }}
              />
            </View>
          );
        })}
      </View>
      <View
        style={{
          flexDirection: 'row',
          gap: 4,
          marginTop: 6,
        }}
      >
        {series.map((pt, i) => (
          <Animated.Text
            key={i}
            style={{
              flex: 1,
              textAlign: 'center',
              fontSize: 9,
              lineHeight: 12,
              color: fortuneTheme.colors.textTertiary,
              opacity: anims[i],
            }}
            numberOfLines={1}
          >
            {pt.label ?? i + 1}
          </Animated.Text>
        ))}
      </View>
    </View>
  );
}

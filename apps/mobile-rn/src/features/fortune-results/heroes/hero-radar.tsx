// HeroRadar: port of result-cards.jsx HeroRadar (~418-446). RN has no polygon primitive —
// replaced with a horizontal bar-group of 6 labeled traits. Fidelity loss: no radar geometry.
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroRadarProps {
  data: EmbeddedResultPayload;
  progress: number;
}

interface TraitPoint {
  label?: string;
  value?: number;
  k?: string;
  v?: number;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const COLOR = '#8B7BE8';

const PLACEHOLDER: TraitPoint[] = [
  { label: '감성', value: 70 },
  { label: '이성', value: 60 },
  { label: '직관', value: 85 },
  { label: '실행', value: 55 },
  { label: '탐구', value: 75 },
  { label: '교감', value: 65 },
];

export default function HeroRadar({ data, progress }: HeroRadarProps) {
  const raw = (data as unknown as { traits?: TraitPoint[] }).traits;
  const traits: TraitPoint[] =
    raw && raw.length > 0 ? raw.slice(0, 6) : PLACEHOLDER;
  const p = clamp01(progress);

  const anims = useRef(traits.map(() => new Animated.Value(0))).current;

  useEffect(() => {
    traits.forEach((_, i) => {
      const local = easeOut(stage(p, 0.05 + i * 0.08, 0.35 + i * 0.08));
      Animated.timing(anims[i], {
        toValue: local,
        duration: 120,
        useNativeDriver: false,
      }).start();
    });
  }, [p, anims, traits]);

  return (
    <View style={{ paddingVertical: 12, paddingHorizontal: 6, gap: 8 }}>
      {traits.map((t, i) => {
        const value = Math.max(0, Math.min(100, t.value ?? t.v ?? 0));
        const label = t.label ?? t.k ?? '';
        const widthAnim = anims[i].interpolate({
          inputRange: [0, 1],
          outputRange: ['0%', `${value}%`],
        });
        return (
          <View
            key={i}
            style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}
          >
            <Text
              style={{
                width: 48,
                fontSize: 11,
                lineHeight: 14,
                color: fortuneTheme.colors.textSecondary,
              }}
              numberOfLines={1}
            >
              {label}
            </Text>
            <View
              style={{
                flex: 1,
                height: 6,
                borderRadius: 3,
                backgroundColor: 'rgba(255,255,255,0.06)',
                overflow: 'hidden',
              }}
            >
              <Animated.View
                style={{
                  height: '100%',
                  width: widthAnim,
                  backgroundColor: COLOR,
                  borderRadius: 3,
                }}
              />
            </View>
            <Text
              style={{
                width: 28,
                textAlign: 'right',
                fontSize: 11,
                lineHeight: 14,
                fontWeight: '700',
                color: fortuneTheme.colors.textPrimary,
              }}
            >
              {value}
            </Text>
          </View>
        );
      })}
    </View>
  );
}

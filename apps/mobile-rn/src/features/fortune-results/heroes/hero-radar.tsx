/**
 * HeroRadar — `result-cards.jsx:HeroRadar` (419-446). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

interface HeroRadarProps {
  data: EmbeddedResultPayload;
  progress?: number;
  color?: string;
}

interface TraitPoint {
  label?: string;
  value?: number;
  k?: string;
  v?: number;
}

const DEFAULT_TRAITS: TraitPoint[] = [
  { label: '감성', value: 70 },
  { label: '이성', value: 60 },
  { label: '직관', value: 85 },
  { label: '실행', value: 55 },
  { label: '탐구', value: 75 },
  { label: '교감', value: 65 },
];

export default function HeroRadar({ data, progress = 1, color = '#8B7BE8' }: HeroRadarProps) {
  const raw = (data as unknown as { traits?: TraitPoint[] }).traits;
  const traits: TraitPoint[] = raw && raw.length > 0 ? raw : DEFAULT_TRAITS;
  const p = clamp01(progress);
  const eased = easeOut(p);

  return (
    <View
      style={{
        paddingTop: 10,
        paddingHorizontal: 12,
        paddingBottom: 2,
        gap: 4,
      }}
    >
      {traits.map((t, i) => {
        const v = t.value ?? t.v ?? 0;
        const label = t.label ?? t.k ?? '';
        const fill = (v / 100) * eased;
        return (
          <View
            key={`rad-${i}`}
            style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}
          >
            <Text
              style={{
                width: 36,
                fontSize: 10,
                color: fortuneTheme.colors.textSecondary,
                fontFamily: 'ZenSerif',
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
                backgroundColor: 'rgba(255,255,255,0.08)',
                overflow: 'hidden',
              }}
            >
              <View
                style={{
                  width: `${fill * 100}%`,
                  height: '100%',
                  backgroundColor: color,
                  borderRadius: 3,
                }}
              />
            </View>
          </View>
        );
      })}
    </View>
  );
}

/**
 * HeroHealth — `result-cards.jsx:HeroHealth` (296-325). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { View } from 'react-native';

import type { EmbeddedResultPayload } from '../../chat-results/types';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const FG2 = '#9198AA';

interface HeroHealthProps {
  data: EmbeddedResultPayload;
  progress?: number;
}

interface HealthZone {
  region?: 'head' | 'chest' | 'belly' | 'lower' | 'heart' | 'legs';
  score?: number;
}

const dotColor = (v: number) => (v >= 75 ? '#68B593' : v >= 60 ? '#E0A76B' : '#FF8C7A');

const ZONE_DOTS = [
  { key: 'head', top: 8, t: 0.05 },
  { key: 'heart', top: 48, t: 0.2 },
  { key: 'belly', top: 80, t: 0.35 },
  { key: 'legs', top: 118, t: 0.5 },
] as const;

function zoneScore(zones: HealthZone[] | undefined, key: string, fallback: number): number {
  if (!zones) return fallback;
  const alt: Record<string, string[]> = {
    head: ['head'],
    heart: ['chest', 'heart'],
    belly: ['belly'],
    legs: ['lower', 'legs'],
  };
  const candidates = alt[key] ?? [key];
  for (const z of zones) {
    if (z.region && candidates.includes(z.region) && typeof z.score === 'number') {
      return z.score;
    }
  }
  return fallback;
}

export default function HeroHealth({ data, progress = 1 }: HeroHealthProps) {
  const zones = (data as unknown as { zones?: HealthZone[] }).zones;
  const p = clamp01(progress);

  return (
    <View
      style={{
        paddingTop: 12,
        paddingHorizontal: 6,
        paddingBottom: 2,
        alignItems: 'center',
      }}
    >
      <View style={{ width: 90, height: 140, position: 'relative' }}>
        <View
          style={{
            position: 'absolute',
            top: 6,
            left: 33,
            width: 24,
            height: 24,
            borderRadius: 12,
            borderWidth: 1.5,
            borderColor: FG2,
          }}
        />
        <View
          style={{
            position: 'absolute',
            top: 32,
            left: 43,
            width: 4,
            height: 90,
            backgroundColor: FG2,
            opacity: 0.5,
          }}
        />
        {ZONE_DOTS.map((z) => {
          const v = zoneScore(zones, z.key, 70);
          const opacity = stage(p, z.t, z.t + 0.3);
          const color = dotColor(v);
          return (
            <View
              key={z.key}
              style={{
                position: 'absolute',
                top: z.top,
                left: 35,
                width: 20,
                height: 20,
                borderRadius: 10,
                backgroundColor: color,
                opacity,
                shadowColor: color,
                shadowOpacity: 0.6,
                shadowRadius: 8,
                shadowOffset: { width: 0, height: 0 },
              }}
            />
          );
        })}
      </View>
    </View>
  );
}

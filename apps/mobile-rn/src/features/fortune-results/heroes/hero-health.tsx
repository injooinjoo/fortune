// HeroHealth: port of result-cards.jsx HeroHealth (~295-325). No body_outline.svg available,
// so we fall back to a vertical stack of 4 labeled glow circles (head/chest/belly/lower).
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroHealthProps {
  data: EmbeddedResultPayload;
  progress: number;
}

type Region = 'head' | 'chest' | 'belly' | 'lower';
interface HealthZone {
  region?: Region;
  score?: number;
}

const REGION_LABEL: Record<Region, string> = {
  head: '머리',
  chest: '가슴',
  belly: '복부',
  lower: '하체',
};
const REGION_ORDER: Region[] = ['head', 'chest', 'belly', 'lower'];

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const colorFor = (v: number) =>
  v >= 75 ? '#68B593' : v >= 60 ? '#E0A76B' : '#FF8C7A';

const PLACEHOLDER: Record<Region, number> = {
  head: 80,
  chest: 70,
  belly: 65,
  lower: 72,
};

export default function HeroHealth({ data, progress }: HeroHealthProps) {
  const raw = (data as unknown as { zones?: HealthZone[] }).zones;
  const scoreByRegion: Record<Region, number> = { ...PLACEHOLDER };
  if (raw) {
    raw.forEach((z) => {
      if (z.region && typeof z.score === 'number') {
        scoreByRegion[z.region] = z.score;
      }
    });
  }
  const p = clamp01(progress);

  const anims = useRef(REGION_ORDER.map(() => new Animated.Value(0))).current;

  useEffect(() => {
    REGION_ORDER.forEach((_, i) => {
      const local = stage(p, 0.05 + i * 0.15, 0.35 + i * 0.15);
      Animated.timing(anims[i], {
        toValue: local,
        duration: 180,
        useNativeDriver: true,
      }).start();
    });
  }, [p, anims]);

  return (
    <View style={{ paddingVertical: 10, alignItems: 'center', gap: 8 }}>
      {REGION_ORDER.map((region, i) => {
        const v = scoreByRegion[region];
        const col = colorFor(v);
        const scale = anims[i].interpolate({
          inputRange: [0, 1],
          outputRange: [0.5, 1],
        });
        return (
          <View
            key={region}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 12,
              minWidth: 180,
            }}
          >
            <Animated.View
              style={{
                width: 22,
                height: 22,
                borderRadius: 11,
                backgroundColor: col,
                shadowColor: col,
                shadowOpacity: 0.8,
                shadowRadius: 8,
                shadowOffset: { width: 0, height: 0 },
                opacity: anims[i],
                transform: [{ scale }],
              }}
            />
            <Text
              style={{
                flex: 1,
                fontSize: 12,
                lineHeight: 16,
                color: fortuneTheme.colors.textSecondary,
              }}
            >
              {REGION_LABEL[region]}
            </Text>
            <Text
              style={{
                fontSize: 14,
                lineHeight: 18,
                fontWeight: '700',
                color: fortuneTheme.colors.textPrimary,
              }}
            >
              {v}
            </Text>
          </View>
        );
      })}
    </View>
  );
}

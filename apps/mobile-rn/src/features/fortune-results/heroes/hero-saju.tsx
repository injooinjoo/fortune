// HeroSaju: port of result-cards.jsx HeroSaju (~144-181). 4 pillars stamp-in + 5-element bars.
// Bars use percent heights (useNativeDriver:false). Pillars use scale + opacity on native driver.
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroSajuProps {
  data: EmbeddedResultPayload;
  progress: number;
}

type ElementKey = 'wood' | 'fire' | 'earth' | 'metal' | 'water';
interface SajuPillar {
  label?: string;
  sky?: string;
  gnd?: string;
  skyEl?: ElementKey;
  gndEl?: ElementKey;
}

const ELC: Record<ElementKey, string> = {
  wood: '#68B593',
  fire: '#FF8C7A',
  earth: '#E0A76B',
  metal: '#C9CED6',
  water: '#8FB8FF',
};
const ELC_LABEL: Record<ElementKey, string> = {
  wood: '木',
  fire: '火',
  earth: '土',
  metal: '金',
  water: '水',
};
const EL_KEYS: ElementKey[] = ['wood', 'fire', 'earth', 'metal', 'water'];

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const PLACEHOLDER_PILLARS: SajuPillar[] = [
  { label: '年', sky: '甲', gnd: '子', skyEl: 'wood', gndEl: 'water' },
  { label: '月', sky: '丙', gnd: '午', skyEl: 'fire', gndEl: 'fire' },
  { label: '日', sky: '戊', gnd: '辰', skyEl: 'earth', gndEl: 'earth' },
  { label: '時', sky: '庚', gnd: '申', skyEl: 'metal', gndEl: 'metal' },
];
const PLACEHOLDER_ELEMENTS: Record<ElementKey, number> = {
  wood: 40,
  fire: 60,
  earth: 80,
  metal: 50,
  water: 30,
};

export default function HeroSaju({ data, progress }: HeroSajuProps) {
  const raw = data as unknown as {
    pillars?: SajuPillar[];
    elements?: Partial<Record<ElementKey, number>>;
  };
  const pillars: SajuPillar[] =
    raw.pillars && raw.pillars.length === 4
      ? raw.pillars
      : PLACEHOLDER_PILLARS;
  const elements: Record<ElementKey, number> = {
    ...PLACEHOLDER_ELEMENTS,
    ...(raw.elements ?? {}),
  };
  const p = clamp01(progress);

  const pillarAnims = useRef(pillars.map(() => new Animated.Value(0))).current;
  const barAnims = useRef(EL_KEYS.map(() => new Animated.Value(0))).current;

  useEffect(() => {
    pillars.forEach((_, i) => {
      const local = stage(p, i * 0.12, i * 0.12 + 0.35);
      Animated.timing(pillarAnims[i], {
        toValue: local,
        duration: 100,
        useNativeDriver: true,
      }).start();
    });
    EL_KEYS.forEach((_, i) => {
      const local = stage(p, 0.4 + i * 0.05, 0.6 + i * 0.05);
      Animated.timing(barAnims[i], {
        toValue: easeOut(local),
        duration: 80,
        useNativeDriver: false,
      }).start();
    });
  }, [p, pillarAnims, barAnims, pillars]);

  return (
    <View style={{ paddingVertical: 10 }}>
      <View style={{ flexDirection: 'row', gap: 6 }}>
        {pillars.map((pi, i) => {
          const scale = pillarAnims[i].interpolate({
            inputRange: [0, 1],
            outputRange: [0.6, 1],
          });
          const skyEl = pi.skyEl ?? 'earth';
          const gndEl = pi.gndEl ?? 'earth';
          return (
            <Animated.View
              key={i}
              style={{
                flex: 1,
                borderWidth: 1,
                borderColor: fortuneTheme.colors.border,
                borderRadius: 10,
                paddingVertical: 8,
                paddingHorizontal: 4,
                alignItems: 'center',
                backgroundColor: 'rgba(255,255,255,0.02)',
                opacity: pillarAnims[i],
                transform: [{ scale }],
              }}
            >
              <Text
                style={{
                  fontSize: 9,
                  lineHeight: 11,
                  color: fortuneTheme.colors.textTertiary,
                  letterSpacing: 1,
                }}
              >
                {pi.label ?? ''}
              </Text>
              <Text
                style={{
                  fontSize: 22,
                  lineHeight: 26,
                  color: ELC[skyEl],
                  marginTop: 2,
                }}
              >
                {pi.sky ?? ''}
              </Text>
              <Text
                style={{
                  fontSize: 18,
                  lineHeight: 22,
                  color: ELC[gndEl],
                }}
              >
                {pi.gnd ?? ''}
              </Text>
            </Animated.View>
          );
        })}
      </View>
      <View
        style={{
          flexDirection: 'row',
          gap: 3,
          marginTop: 12,
          height: 44,
          alignItems: 'flex-end',
        }}
      >
        {EL_KEYS.map((k, i) => {
          const targetPct = elements[k];
          const height = barAnims[i].interpolate({
            inputRange: [0, 1],
            outputRange: ['0%', `${targetPct}%`],
          });
          return (
            <View key={k} style={{ flex: 1, alignItems: 'center' }}>
              <View
                style={{
                  height: 28,
                  width: '70%',
                  justifyContent: 'flex-end',
                }}
              >
                <Animated.View
                  style={{
                    width: '100%',
                    height,
                    backgroundColor: ELC[k],
                    borderRadius: 2,
                  }}
                />
              </View>
              <Text
                style={{
                  fontSize: 10,
                  lineHeight: 12,
                  color: fortuneTheme.colors.textSecondary,
                  marginTop: 3,
                }}
              >
                {ELC_LABEL[k]}
              </Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

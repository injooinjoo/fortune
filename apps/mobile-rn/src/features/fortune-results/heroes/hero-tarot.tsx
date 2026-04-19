// HeroTarot: port of result-cards.jsx HeroTarot (~107-142). RN can't do backface-visibility/Y-flip
// cleanly, so we approximate with scale-in + slight rotateZ tilt (fanned layout) — fidelity loss accepted.
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface HeroTarotProps {
  data: EmbeddedResultPayload;
  progress: number;
}

interface SpreadCard {
  name?: string;
  suit?: string;
  meaning?: string;
  num?: string;
  art?: string;
  pos?: string;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeInOut = (t: number) =>
  t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;

const AMBER = '#E0A76B';
const PLACEHOLDERS: SpreadCard[] = [
  { num: 'I', art: '☽', name: '과거', pos: 'Past' },
  { num: 'II', art: '☀', name: '현재', pos: 'Present' },
  { num: 'III', art: '✦', name: '미래', pos: 'Future' },
];

export default function HeroTarot({ data, progress }: HeroTarotProps) {
  const raw = (data as unknown as { spread?: SpreadCard[] }).spread;
  const spread: SpreadCard[] =
    raw && raw.length > 0 ? raw.slice(0, 3) : PLACEHOLDERS;
  const p = clamp01(progress);

  const anims = useRef(spread.map(() => new Animated.Value(0))).current;

  useEffect(() => {
    spread.forEach((_, i) => {
      const delay = i * 0.18;
      const local = easeInOut(stage(p, delay, delay + 0.55));
      Animated.timing(anims[i], {
        toValue: local,
        duration: 120,
        useNativeDriver: true,
      }).start();
    });
  }, [p, anims, spread]);

  return (
    <View
      style={{
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        gap: 10,
        paddingVertical: 18,
      }}
    >
      {spread.map((c, i) => {
        const tilt = (i - 1) * 8; // -8 / 0 / 8 deg fan
        const scale = anims[i].interpolate({
          inputRange: [0, 1],
          outputRange: [0.5, 1],
        });
        const opacity = anims[i];
        const rotate = anims[i].interpolate({
          inputRange: [0, 1],
          outputRange: ['0deg', `${tilt}deg`],
        });
        return (
          <Animated.View
            key={i}
            style={{
              width: 74,
              height: 112,
              borderRadius: 8,
              borderWidth: 1,
              borderColor: `${AMBER}55`,
              backgroundColor: '#1A1028',
              padding: 6,
              alignItems: 'center',
              justifyContent: 'center',
              opacity,
              transform: [{ scale }, { rotate }],
            }}
          >
            <Text
              style={{
                fontSize: 10,
                lineHeight: 12,
                color: AMBER,
                letterSpacing: 1,
              }}
            >
              {c.num ?? String(i + 1)}
            </Text>
            <Text
              style={{
                fontSize: 28,
                lineHeight: 34,
                color: AMBER,
                marginVertical: 4,
              }}
            >
              {c.art ?? '✦'}
            </Text>
            <Text
              style={{
                fontSize: 10,
                lineHeight: 13,
                color: fortuneTheme.colors.textSecondary,
                textAlign: 'center',
              }}
              numberOfLines={1}
            >
              {c.name ?? c.suit ?? ''}
            </Text>
            <Text
              style={{
                fontSize: 9,
                lineHeight: 12,
                color: fortuneTheme.colors.textTertiary,
                marginTop: 4,
                textAlign: 'center',
              }}
              numberOfLines={1}
            >
              {c.pos ?? c.meaning ?? ''}
            </Text>
          </Animated.View>
        );
      })}
    </View>
  );
}

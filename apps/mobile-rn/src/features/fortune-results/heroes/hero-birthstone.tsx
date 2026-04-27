/**
 * HeroStone (birthstone) — `result-cards.jsx:HeroStone` (497-523). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface StoneData {
  name?: string;
  month?: string;
  color?: string;
}

interface HeroStoneProps {
  data?: unknown;
  progress?: number;
}

function extractStone(payload: unknown): StoneData {
  const fallback: StoneData = { name: '자수정', month: '2월', color: '#8B7BE8' };
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const stone = (data.stone ?? data.birthstone ?? data) as Record<string, unknown>;
  return {
    name: typeof stone.name === 'string' ? stone.name : fallback.name,
    month: typeof stone.month === 'string' ? stone.month : fallback.month,
    color: typeof stone.color === 'string' ? stone.color : fallback.color,
  };
}

export default function HeroBirthstone({ data: payload, progress = 1 }: HeroStoneProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.5);
  const eased = easeOut(l);
  const rotate = tween(eased, -30, 0);
  const scale = tween(eased, 0.5, 1);
  const textOpacity = stage(p, 0.3, 0.55);
  const stone = extractStone(payload);
  const stoneColor = stone.color ?? '#8B7BE8';

  return (
    <View
      style={{
        paddingTop: 16,
        paddingHorizontal: 6,
        paddingBottom: 4,
        alignItems: 'center',
        position: 'relative',
      }}
    >
      <View
        style={{
          width: 80,
          height: 80,
          opacity: l,
          transform: [{ rotate: `${rotate}deg` }, { scale }],
          shadowColor: stoneColor,
          shadowOpacity: 0.6 * l,
          shadowRadius: 10 * l,
          shadowOffset: { width: 0, height: 0 },
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <View
          style={{
            width: 60,
            height: 60,
            backgroundColor: stoneColor,
            borderWidth: 1.5,
            borderColor: stoneColor,
            transform: [{ rotate: '45deg' }],
            borderRadius: 6,
            opacity: 0.85,
          }}
        />
        <View
          style={{
            position: 'absolute',
            width: 30,
            height: 30,
            backgroundColor: '#FFFFFF',
            opacity: 0.35,
            transform: [{ rotate: '45deg' }],
            borderRadius: 4,
            top: 10,
          }}
        />
      </View>
      <View
        style={{
          position: 'absolute',
          right: 20,
          top: 14,
          alignItems: 'flex-end',
          opacity: textOpacity,
        }}
      >
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 15,
            color: fortuneTheme.colors.textPrimary,
          }}
        >
          {stone.name}
        </Text>
        <Text
          style={{
            fontSize: 10,
            color: fortuneTheme.colors.textTertiary,
            marginTop: 2,
          }}
        >
          {stone.month}
        </Text>
      </View>
    </View>
  );
}

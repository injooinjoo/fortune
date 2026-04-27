/**
 * HeroDate — `result-cards.jsx:HeroDate` (632-646) — 소개팅.
 *   - 달력 카드 58×64 radius 10 border
 *     상단 띠 #FF8FB1 흰색 "TODAY" 10px letter-spacing 0.1em
 *     본문 가운데 serif ☾ 24px
 *     scale 0.9→1 + fadeIn [p:0..0.4]
 *   - 우측: 시간/장소 텍스트, fadeIn [p:0.2..0.5]
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const ACCENT = '#FF8FB1';

function extractDateMeta(payload: unknown): { time: string; place: string } {
  const fallback = { time: '오늘 저녁 7:30', place: '성수동 카페' };
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  return {
    time: typeof data.time === 'string' ? data.time : fallback.time,
    place: typeof data.place === 'string' ? data.place : fallback.place,
  };
}

interface HeroDateProps {
  data: unknown;
  progress?: number;
}

export default function HeroDate({ data: payload, progress = 1 }: HeroDateProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.4);
  const cardScale = tween(easeOut(l), 0.9, 1);
  const textOpacity = stage(p, 0.2, 0.5);
  const meta = extractDateMeta(payload);

  return (
    <View
      style={{
        paddingHorizontal: 10,
        paddingTop: 14,
        paddingBottom: 4,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 12,
      }}
    >
      <View
        style={{
          width: 58,
          height: 64,
          borderRadius: 10,
          overflow: 'hidden',
          borderWidth: 1,
          borderColor: fortuneTheme.colors.border,
          opacity: l,
          transform: [{ scale: cardScale }],
        }}
      >
        <View
          style={{
            backgroundColor: ACCENT,
            paddingVertical: 3,
            alignItems: 'center',
          }}
        >
          <Text
            style={{
              color: '#ffffff',
              fontSize: 10,
              letterSpacing: 1,
            }}
          >
            TODAY
          </Text>
        </View>
        <View style={{ flex: 1, alignItems: 'center', paddingTop: 6 }}>
          <Text
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 24,
              color: fortuneTheme.colors.textPrimary,
            }}
          >
            ☾
          </Text>
        </View>
      </View>
      <View style={{ opacity: textOpacity }}>
        <Text
          style={{
            fontSize: 12,
            color: fortuneTheme.colors.textSecondary,
          }}
        >
          {meta.time}
        </Text>
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 14,
            color: fortuneTheme.colors.textPrimary,
            marginTop: 2,
          }}
        >
          {meta.place}
        </Text>
      </View>
    </View>
  );
}

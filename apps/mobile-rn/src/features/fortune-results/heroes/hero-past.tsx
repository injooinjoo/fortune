/**
 * HeroPast — `result-cards.jsx:HeroPast` (709-726). View-only 근사.
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface HeroPastProps {
  data: unknown;
  progress?: number;
}

function extractPast(payload: unknown): { symbol: string; era: string; pastRole: string } {
  const fallback = { symbol: '✦', era: '고려시대', pastRole: '서리' };
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  return {
    symbol: typeof data.symbol === 'string' ? data.symbol : fallback.symbol,
    era: typeof data.era === 'string' ? data.era : fallback.era,
    pastRole: typeof data.pastRole === 'string' ? data.pastRole : fallback.pastRole,
  };
}

export default function HeroPast({ data: payload, progress = 1 }: HeroPastProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.6);
  const scale = tween(easeOut(l), 0.5, 1);
  const captionOpacity = stage(p, 0.3, 0.55);
  const past = extractPast(payload);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 14,
        paddingBottom: 4,
        alignItems: 'center',
        gap: 6,
      }}
    >
      <View
        style={{
          width: 70,
          height: 70,
          borderRadius: 35,
          backgroundColor: '#8B7BE8',
          alignItems: 'center',
          justifyContent: 'center',
          opacity: l,
          transform: [{ scale }],
          overflow: 'hidden',
        }}
      >
        <View
          style={{
            position: 'absolute',
            top: 6,
            left: 14,
            width: 40,
            height: 40,
            borderRadius: 20,
            backgroundColor: '#FFE0EC',
            opacity: 0.85,
          }}
        />
        <View
          style={{
            position: 'absolute',
            inset: 0,
            borderRadius: 35,
            borderWidth: 10,
            borderColor: '#0B0B10',
            opacity: 0.4,
          }}
        />
        <Text style={{ fontFamily: 'ZenSerif', fontSize: 30, color: '#ffffff' }}>
          {past.symbol}
        </Text>
      </View>
      <Text
        style={{
          fontSize: 11,
          color: fortuneTheme.colors.textSecondary,
          fontFamily: 'ZenSerif',
          opacity: captionOpacity,
          textAlign: 'center',
        }}
      >
        {past.era} · {past.pastRole}
      </Text>
    </View>
  );
}

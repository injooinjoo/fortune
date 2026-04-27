/**
 * HeroLucky — `result-cards.jsx:HeroLucky` (395-416).
 *
 * 원본:
 *   padding 14/6/4, 3-col grid gap 8
 *   d.slots: [{sw: color, k: 라벨, v: 값}]
 *   각 타일:
 *     border FT.border, radius 12, padding 10/6, bg rgba(255,255,255,0.02)
 *     스태거: l = stage(p, i*0.08, i*0.08+0.35), translateY (1-l)*10 + scale 0.9→1
 *     스와치 22×22 원 color, glow 8px color55 (흰색일 땐 box-shadow 1px ring)
 *     라벨 9px fg3 letter-spacing 0.1em
 *     값 12px fg 700
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface LuckySlot {
  sw: string; // swatch color
  k: string; // key/label
  v: string; // value
}

interface HeroLuckyProps {
  data?: unknown;
  progress?: number;
}

const DEFAULT_SLOTS: LuckySlot[] = [
  { sw: '#8B7BE8', k: 'COLOR', v: '보라' },
  { sw: '#FFC86B', k: 'NUMBER', v: '7' },
  { sw: '#68B593', k: 'PLACE', v: '공원' },
  { sw: '#F5F6FB', k: 'TIME', v: '오전' },
  { sw: '#FF8FB1', k: 'DIRECTION', v: '동쪽' },
  { sw: '#8FB8FF', k: 'ITEM', v: '반지' },
];

function extractSlots(payload: unknown): LuckySlot[] {
  if (!payload || typeof payload !== 'object') return DEFAULT_SLOTS;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.slots) ? data.slots : null;
  if (!arr) return DEFAULT_SLOTS;
  const parsed = arr
    .map((it): LuckySlot | null => {
      if (!it || typeof it !== 'object') return null;
      const r = it as Record<string, unknown>;
      const sw = typeof r.sw === 'string' ? r.sw : null;
      const k = typeof r.k === 'string' ? r.k : null;
      const v = typeof r.v === 'string' ? r.v : typeof r.v === 'number' ? String(r.v) : null;
      if (!sw || !k || v == null) return null;
      return { sw, k, v };
    })
    .filter((x): x is LuckySlot => x != null);
  return parsed.length >= 3 ? parsed.slice(0, 6) : DEFAULT_SLOTS;
}

function LuckyTile({
  slot,
  opacity,
  translateY,
  scale,
}: {
  slot: LuckySlot;
  opacity: number;
  translateY: number;
  scale: number;
}) {
  const isWhite = slot.sw === '#F5F6FB' || slot.sw.toLowerCase() === '#ffffff';
  return (
    <View
      style={{
        width: '32%',
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
        borderRadius: 12,
        paddingVertical: 10,
        paddingHorizontal: 6,
        backgroundColor: 'rgba(255,255,255,0.02)',
        alignItems: 'center',
        opacity,
        transform: [{ translateY }, { scale }],
      }}
    >
      <View
        style={{
          width: 22,
          height: 22,
          borderRadius: 11,
          backgroundColor: slot.sw,
          shadowColor: slot.sw,
          shadowOpacity: isWhite ? 0 : 0.33,
          shadowRadius: 8,
          shadowOffset: { width: 0, height: 0 },
          borderWidth: isWhite ? 1 : 0,
          borderColor: 'rgba(255,255,255,0.15)',
          marginBottom: 6,
        }}
      />
      <Text
        style={{
          fontSize: 9,
          color: fortuneTheme.colors.textTertiary,
          letterSpacing: 1,
        }}
      >
        {slot.k}
      </Text>
      <Text
        style={{
          fontSize: 12,
          color: fortuneTheme.colors.textPrimary,
          fontWeight: '700',
          marginTop: 2,
        }}
      >
        {slot.v}
      </Text>
    </View>
  );
}

export default function HeroLucky({ data: payload, progress = 1 }: HeroLuckyProps) {
  const p = clamp01(progress);
  const slots = extractSlots(payload);

  return (
    <View
      style={{
        paddingTop: 14,
        paddingHorizontal: 6,
        paddingBottom: 4,
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 8,
        justifyContent: 'center',
      }}
    >
      {slots.map((slot, i) => {
        const l = stage(p, i * 0.08, i * 0.08 + 0.35);
        const translateY = (1 - l) * 10;
        const scale = tween(easeOut(l), 0.9, 1);
        return (
          <LuckyTile
            key={`${slot.k}-${i}`}
            slot={slot}
            opacity={l}
            translateY={translateY}
            scale={scale}
          />
        );
      })}
    </View>
  );
}

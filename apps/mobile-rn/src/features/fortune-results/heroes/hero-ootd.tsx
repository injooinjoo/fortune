/**
 * HeroOOTD — `result-cards.jsx:HeroOOTD` (595-610).
 * 5색(혹은 가변) 팔레트 직사각형(48×66, radius 6)이 왼쪽→오른쪽 스태거 fadeIn + translateY 10→0.
 * 검은색(#0E0E12)만 미세한 border 추가.
 */
import { View } from 'react-native';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const DEFAULT_PALETTE = ['#1F2130', '#8B7BE8', '#E0A76B', '#F5F6FB', '#FF8FB1'];

function extractPalette(payload: unknown): string[] {
  if (!payload || typeof payload !== 'object') return DEFAULT_PALETTE;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.palette) ? data.palette : null;
  if (!arr || arr.length === 0) return DEFAULT_PALETTE;
  return arr.filter((c): c is string => typeof c === 'string').slice(0, 7);
}

interface HeroOotdProps {
  data: unknown;
  progress?: number;
}

export default function HeroOotd({ data: payload, progress = 1 }: HeroOotdProps) {
  const p = clamp01(progress);
  const palette = extractPalette(payload);

  return (
    <View
      style={{
        paddingHorizontal: 10,
        paddingTop: 18,
        paddingBottom: 6,
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 8,
      }}
    >
      {palette.map((c, i) => {
        const l = stage(p, i * 0.12, i * 0.12 + 0.35);
        const translateY = (1 - l) * 10;
        const needsBorder = c === '#0E0E12' || c === '#000000' || c.toLowerCase() === '#000';
        return (
          <View
            key={`swatch-${i}-${c}`}
            style={{
              width: 48,
              height: 66,
              borderRadius: 6,
              backgroundColor: c,
              borderWidth: needsBorder ? 1 : 0,
              borderColor: 'rgba(255,255,255,0.1)',
              opacity: l,
              transform: [{ translateY }],
            }}
          />
        );
      })}
    </View>
  );
}

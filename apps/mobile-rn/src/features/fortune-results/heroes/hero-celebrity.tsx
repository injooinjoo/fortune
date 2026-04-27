/**
 * HeroCelebrity — `result-cards.jsx:HeroCeleb` (526-544). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const AMBER = '#E0A76B';

interface CelebData {
  you?: string;
  name?: string;
}

interface HeroCelebrityProps {
  data?: unknown;
  progress?: number;
}

function extractCeleb(payload: unknown): CelebData {
  const fallback: CelebData = { you: '나', name: '아이유' };
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const celeb = (data.celeb ?? data) as Record<string, unknown>;
  return {
    you: typeof celeb.you === 'string' ? celeb.you : fallback.you,
    name:
      typeof celeb.name === 'string'
        ? celeb.name
        : typeof data.celebName === 'string'
          ? (data.celebName as string)
          : fallback.name,
  };
}

function Orb({
  color,
  highlight,
  label,
  opacity,
  translateY,
}: {
  color: string;
  highlight: string;
  label: string;
  opacity: number;
  translateY: number;
}) {
  return (
    <View
      style={{
        alignItems: 'center',
        opacity,
        transform: [{ translateY }],
      }}
    >
      <View
        style={{
          width: 52,
          height: 52,
          borderRadius: 26,
          backgroundColor: color,
          borderWidth: 1,
          borderColor: `${color}88`,
          overflow: 'hidden',
          shadowColor: color,
          shadowOpacity: 0.4,
          shadowRadius: 14,
          shadowOffset: { width: 0, height: 0 },
        }}
      >
        <View
          style={{
            position: 'absolute',
            top: 6,
            left: 10,
            width: 20,
            height: 20,
            borderRadius: 10,
            backgroundColor: highlight,
            opacity: 0.7,
          }}
        />
      </View>
      <Text
        style={{
          fontSize: 11,
          color: fortuneTheme.colors.textPrimary,
          fontWeight: '600',
          marginTop: 6,
        }}
      >
        {label}
      </Text>
    </View>
  );
}

export default function HeroCelebrity({ data: payload, progress = 1 }: HeroCelebrityProps) {
  const p = clamp01(progress);
  const left = stage(p, 0, 0.4);
  const right = stage(p, 0.15, 0.55);
  const heartOpacity = stage(p, 0.3, 0.5);
  const celeb = extractCeleb(payload);

  return (
    <View
      style={{
        paddingTop: 14,
        paddingHorizontal: 6,
        paddingBottom: 4,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 14,
        position: 'relative',
      }}
    >
      <Orb
        color="#8B7BE8"
        highlight="#C4B8FF"
        label={celeb.you ?? ''}
        opacity={left}
        translateY={(1 - left) * 8}
      />
      <Orb
        color="#FF8FB1"
        highlight="#FFC7D9"
        label={celeb.name ?? ''}
        opacity={right}
        translateY={(1 - right) * 8}
      />
      <Text
        style={{
          position: 'absolute',
          fontFamily: 'ZenSerif',
          fontSize: 22,
          color: AMBER,
          opacity: heartOpacity,
          top: 32,
        }}
      >
        ♥
      </Text>
    </View>
  );
}

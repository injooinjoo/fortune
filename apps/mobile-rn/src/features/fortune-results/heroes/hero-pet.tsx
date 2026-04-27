/**
 * HeroPet — `result-cards.jsx:HeroPet` (547-557).
 *
 * 원본:
 *   padding 18px 6px 6px, gap 12, horizontal center
 *   이모지 48px, opacity stage(p, 0, 0.5), scale easeOut 0.7→1
 *   우측: serif 16px 이름 + 11px fg3 종류, opacity stage(p, 0.2, 0.5)
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface PetData {
  emoji?: string;
  name?: string;
  kind?: string;
}

interface HeroPetProps {
  data?: unknown;
  progress?: number;
}

function extractPet(payload: unknown): PetData {
  const fallback: PetData = { emoji: '🐶', name: '몽이', kind: '강아지' };
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const pet = (data.pet ?? data) as Record<string, unknown>;
  return {
    emoji: typeof pet.emoji === 'string' ? pet.emoji : fallback.emoji,
    name: typeof pet.name === 'string' ? pet.name : fallback.name,
    kind: typeof pet.kind === 'string' ? pet.kind : fallback.kind,
  };
}

export default function HeroPet({ data: payload, progress = 1 }: HeroPetProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.5);
  const textOpacity = stage(p, 0.2, 0.5);
  const scale = tween(easeOut(l), 0.7, 1);
  const pet = extractPet(payload);

  return (
    <View
      style={{
        paddingTop: 18,
        paddingHorizontal: 6,
        paddingBottom: 6,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        gap: 12,
      }}
    >
      <Text style={{ fontSize: 48, opacity: l, transform: [{ scale }] }}>
        {pet.emoji}
      </Text>
      <View style={{ opacity: textOpacity }}>
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 16,
            color: fortuneTheme.colors.textPrimary,
          }}
        >
          {pet.name}
        </Text>
        <Text
          style={{
            fontSize: 11,
            color: fortuneTheme.colors.textTertiary,
            marginTop: 2,
          }}
        >
          {pet.kind}
        </Text>
      </View>
    </View>
  );
}

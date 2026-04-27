/**
 * HeroNaming — `result-cards.jsx:HeroNaming` (473-494).
 *
 * 원본:
 *   padding 12px 6px 2px, gap 10, horizontal center
 *   이름 카드 (64 wide, padding 10/4, radius 10, bg rgba(255,255,255,0.03), border FT.border)
 *     - 점수 9px amber letter-spacing 0.1em
 *     - 한글 이름 serif 22px fg
 *     - 한자 serif 13px fg2
 *     - 메모 9px fg3
 *   스태거 translateY 12→0 + fadeIn [p:i*0.12..i*0.12+0.4]
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

interface NameEntry {
  score?: string | number;
  ko?: string;
  cn?: string;
  note?: string;
}

interface HeroNamingProps {
  data?: unknown;
  progress?: number;
}

const AMBER = '#E0A76B';

const DEFAULT_NAMES: NameEntry[] = [
  { score: '94', ko: '유진', cn: '裕眞', note: '재물·진실' },
  { score: '91', ko: '서율', cn: '瑞律', note: '상서로움' },
  { score: '89', ko: '지후', cn: '智厚', note: '지혜' },
];

function extractNames(payload: unknown): NameEntry[] {
  if (!payload || typeof payload !== 'object') return DEFAULT_NAMES;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.names) ? data.names : null;
  if (!arr) return DEFAULT_NAMES;
  const parsed = arr
    .map((it): NameEntry | null => {
      if (!it || typeof it !== 'object') return null;
      const r = it as Record<string, unknown>;
      const ko = typeof r.ko === 'string' ? r.ko : typeof r.name === 'string' ? (r.name as string) : null;
      if (!ko) return null;
      return {
        score: typeof r.score === 'string' || typeof r.score === 'number' ? r.score : undefined,
        ko,
        cn: typeof r.cn === 'string' ? r.cn : typeof r.hanja === 'string' ? (r.hanja as string) : undefined,
        note: typeof r.note === 'string' ? r.note : undefined,
      };
    })
    .filter((x): x is NameEntry => x != null);
  return parsed.length > 0 ? parsed.slice(0, 3) : DEFAULT_NAMES;
}

export default function HeroNaming({ data: payload, progress = 1 }: HeroNamingProps) {
  const p = clamp01(progress);
  const names = extractNames(payload);

  return (
    <View
      style={{
        paddingTop: 12,
        paddingHorizontal: 6,
        paddingBottom: 2,
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 10,
      }}
    >
      {names.map((n, i) => {
        const l = stage(p, i * 0.12, i * 0.12 + 0.4);
        const translateY = (1 - l) * 12;
        return (
          <View
            key={`name-${i}-${n.ko}`}
            style={{
              width: 64,
              paddingVertical: 10,
              paddingHorizontal: 4,
              borderRadius: 10,
              backgroundColor: 'rgba(255,255,255,0.03)',
              borderWidth: 1,
              borderColor: fortuneTheme.colors.border,
              alignItems: 'center',
              opacity: l,
              transform: [{ translateY }],
            }}
          >
            {n.score !== undefined ? (
              <Text
                style={{
                  fontSize: 9,
                  color: AMBER,
                  letterSpacing: 1,
                }}
              >
                {String(n.score)}
              </Text>
            ) : null}
            <Text
              style={{
                fontFamily: 'ZenSerif',
                fontSize: 22,
                color: fortuneTheme.colors.textPrimary,
                marginVertical: 4,
              }}
            >
              {n.ko}
            </Text>
            {n.cn ? (
              <Text
                style={{
                  fontFamily: 'ZenSerif',
                  fontSize: 13,
                  color: fortuneTheme.colors.textSecondary,
                }}
              >
                {n.cn}
              </Text>
            ) : null}
            {n.note ? (
              <Text
                style={{
                  fontSize: 9,
                  color: fortuneTheme.colors.textTertiary,
                  marginTop: 3,
                }}
              >
                {n.note}
              </Text>
            ) : null}
          </View>
        );
      })}
    </View>
  );
}

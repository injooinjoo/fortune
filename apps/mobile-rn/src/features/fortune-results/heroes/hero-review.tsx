/**
 * HeroReview — `result-cards.jsx:HeroReview` (763-783) — 하루 리뷰.
 *   2열 그리드 (끝난 일 / 내일로). 각 칸:
 *     - border FT.border, radius 10, padding 10, bg rgba(255,255,255,0.02)
 *     - 제목: 10px letter-spacing 0.14em 700; color #68B593 또는 #E0A76B
 *     - 아이템: 11px fg, '✓ ' 또는 '→ ' 접두
 *     - 스태거 opacity & translateX: l = stage(p, (ci*3+i)*0.1, +0.3)
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

function extractReview(payload: unknown): { done: string[]; open: string[] } {
  const fallback = {
    done: ['보고서 마감', '운동 30분', '장보기'],
    open: ['전화 답신', '서류 제출', '청소 마무리'],
  };
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const done = Array.isArray(data.done)
    ? (data.done as unknown[]).filter((x): x is string => typeof x === 'string').slice(0, 3)
    : [];
  const open = Array.isArray(data.open)
    ? (data.open as unknown[]).filter((x): x is string => typeof x === 'string').slice(0, 3)
    : [];
  return {
    done: done.length > 0 ? done : fallback.done,
    open: open.length > 0 ? open : fallback.open,
  };
}

interface HeroReviewProps {
  data: unknown;
  progress?: number;
}

export default function HeroReview({ data: payload, progress = 1 }: HeroReviewProps) {
  const p = clamp01(progress);
  const review = extractReview(payload);

  const columns = [
    { k: '끝난 일', items: review.done, c: '#68B593', prefix: '✓ ' },
    { k: '내일로', items: review.open, c: '#E0A76B', prefix: '→ ' },
  ];

  return (
    <View
      style={{
        paddingHorizontal: 8,
        paddingTop: 10,
        paddingBottom: 2,
        flexDirection: 'row',
        gap: 8,
      }}
    >
      {columns.map((col, ci) => (
        <View
          key={`col-${ci}`}
          style={{
            flex: 1,
            borderWidth: 1,
            borderColor: fortuneTheme.colors.border,
            borderRadius: 10,
            padding: 10,
            backgroundColor: 'rgba(255,255,255,0.02)',
          }}
        >
          <Text
            style={{
              fontSize: 10,
              color: col.c,
              letterSpacing: 1.4,
              fontWeight: '700',
            }}
          >
            {col.k.toUpperCase()}
          </Text>
          <View style={{ gap: 4, marginTop: 6 }}>
            {col.items.map((it, i) => {
              const l = stage(p, (ci * 3 + i) * 0.1, (ci * 3 + i) * 0.1 + 0.3);
              const translateX = (1 - l) * 6;
              return (
                <Text
                  key={`${ci}-${i}`}
                  style={{
                    fontSize: 11,
                    color: fortuneTheme.colors.textPrimary,
                    opacity: l,
                    transform: [{ translateX }],
                  }}
                >
                  {col.prefix}
                  {it}
                </Text>
              );
            })}
          </View>
        </View>
      ))}
    </View>
  );
}

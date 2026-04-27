/**
 * HeroMBTI — port of `Ondo Design System/project/fortune_results/result-cards.jsx:HeroMBTI` (224-246).
 *
 * 원본:
 *   - 큰 4글자 타입 (serif 40px, letter-spacing 0.16em, scale 0.85→1 + fadeIn[p:0..0.35])
 *   - 4축 바 (i*0.1+0.25..0.55+0.1*i 스테이지, easeOut 폭), a/b 레터 볼드 (pct>=50 쪽 강조)
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface MbtiAxis {
  a: string;
  b: string;
  v: number; // 0..100 — a쪽 비중
}

interface MbtiHeroData {
  type?: string;
  axes?: MbtiAxis[];
}

const DEFAULT_AXES: MbtiAxis[] = [
  { a: 'E', b: 'I', v: 60 },
  { a: 'S', b: 'N', v: 55 },
  { a: 'T', b: 'F', v: 50 },
  { a: 'J', b: 'P', v: 45 },
];

function extractMbtiData(payload: unknown): MbtiHeroData {
  if (!payload || typeof payload !== 'object') return {};
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const type = typeof data.mbtiType === 'string' ? data.mbtiType : typeof data.type === 'string' ? data.type : undefined;
  const axesSource = Array.isArray(data.axes) ? data.axes : undefined;
  const axes = axesSource
    ?.map((it): MbtiAxis | null => {
      if (!it || typeof it !== 'object') return null;
      const r = it as Record<string, unknown>;
      const a = typeof r.a === 'string' ? r.a : null;
      const b = typeof r.b === 'string' ? r.b : null;
      const v = typeof r.v === 'number' ? r.v : typeof r.value === 'number' ? (r.value as number) : null;
      if (!a || !b || v == null) return null;
      return { a, b, v: Math.max(0, Math.min(100, v)) };
    })
    .filter((x): x is MbtiAxis => x != null);
  return { type, axes: axes && axes.length === 4 ? axes : undefined };
}

interface HeroMbtiProps {
  data: unknown;
  progress?: number;
}

export default function HeroMbti({ data: payload, progress = 1 }: HeroMbtiProps) {
  const p = clamp01(progress);
  const typeStage = stage(p, 0, 0.35);
  const typeScale = tween(easeOut(typeStage), 0.85, 1);

  const info = extractMbtiData(payload);
  const mbti = info.type || 'INFP';
  const axes = info.axes ?? DEFAULT_AXES;

  return (
    <View style={{ paddingHorizontal: 6, paddingTop: 18, paddingBottom: 8 }}>
      <Text
        style={{
          textAlign: 'center',
          fontSize: 40,
          fontFamily: 'ZenSerif',
          color: fortuneTheme.colors.textPrimary,
          letterSpacing: 40 * 0.16,
          opacity: typeStage,
          transform: [{ scale: typeScale }],
        }}
      >
        {mbti}
      </Text>
      <View style={{ marginTop: 10, gap: 8 }}>
        {axes.map((a, i) => {
          const axisStage = stage(p, 0.25 + i * 0.1, 0.55 + i * 0.1);
          const pct = a.v * easeOut(axisStage);
          const aDominant = pct >= 50;
          return (
            <View
              key={`${a.a}-${a.b}`}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: 10,
              }}
            >
              <Text
                style={{
                  width: 18,
                  textAlign: 'center',
                  fontWeight: '700',
                  fontSize: 11,
                  color: aDominant
                    ? fortuneTheme.colors.textPrimary
                    : fortuneTheme.colors.textTertiary,
                }}
              >
                {a.a}
              </Text>
              <View
                style={{
                  flex: 1,
                  height: 6,
                  borderRadius: 3,
                  backgroundColor: 'rgba(255,255,255,0.06)',
                  overflow: 'hidden',
                }}
              >
                <View
                  style={{
                    height: '100%',
                    width: `${pct}%`,
                    backgroundColor: '#8B7BE8',
                    borderRadius: 3,
                  }}
                />
              </View>
              <Text
                style={{
                  width: 18,
                  textAlign: 'center',
                  fontWeight: '700',
                  fontSize: 11,
                  color: aDominant
                    ? fortuneTheme.colors.textTertiary
                    : fortuneTheme.colors.textPrimary,
                }}
              >
                {a.b}
              </Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

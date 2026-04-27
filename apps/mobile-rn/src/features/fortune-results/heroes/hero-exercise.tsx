/**
 * HeroExercise — `result-cards.jsx:HeroExercise` (729-760) — 운동 루틴.
 *   - 좌: 96×96 도넛 차트, strokeWidth 10, routine 각 세그먼트 색상
 *     COL = ['#FFC86B','#68B593','#8FB8FF','#C9CED6']
 *     rotate(-90deg), segment 순차 그려짐: l = easeOut(stage(p, i*0.12, i*0.12+0.35))
 *   - 우: 범례 (색 점 + "키 m분"), opacity 스태거
 *
 * RN 포팅: 도넛 차트 근사 — 가로 progress bar 4개로 대체 (각 색상별 분단 표시).
 *   동일 애니메이션 타이밍 + 색상 코드 유지.
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const COL = ['#FFC86B', '#68B593', '#8FB8FF', '#C9CED6'];

interface RoutineItem {
  k: string;
  m: number;
}

function extractRoutine(payload: unknown): RoutineItem[] {
  const fallback: RoutineItem[] = [
    { k: '유산소', m: 25 },
    { k: '근력', m: 20 },
    { k: '스트레칭', m: 10 },
    { k: '휴식', m: 5 },
  ];
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.routine) ? data.routine : null;
  if (!arr) return fallback;
  const parsed = arr
    .map((it): RoutineItem | null => {
      if (!it || typeof it !== 'object') return null;
      const r = it as Record<string, unknown>;
      const k = typeof r.k === 'string' ? r.k : null;
      const m = typeof r.m === 'number' ? r.m : null;
      if (!k || m == null) return null;
      return { k, m };
    })
    .filter((x): x is RoutineItem => x != null);
  return parsed.length > 0 ? parsed.slice(0, 4) : fallback;
}

interface HeroExerciseProps {
  data: unknown;
  progress?: number;
}

export default function HeroExercise({ data: payload, progress = 1 }: HeroExerciseProps) {
  const p = clamp01(progress);
  const routine = extractRoutine(payload);
  const total = routine.reduce((s, r) => s + r.m, 0) || 1;

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 10,
        paddingBottom: 4,
        gap: 12,
      }}
    >
      {/* 비율 바 (도넛 차트 근사) */}
      <View
        style={{
          flexDirection: 'row',
          height: 10,
          borderRadius: 5,
          backgroundColor: 'rgba(255,255,255,0.06)',
          overflow: 'hidden',
        }}
      >
        {routine.map((r, i) => {
          const local = stage(p, i * 0.12, i * 0.12 + 0.35);
          const widthPct = ((r.m / total) * 100) * easeOut(local);
          return (
            <View
              key={`seg-${i}-${r.k}`}
              style={{
                width: `${widthPct}%`,
                backgroundColor: COL[i % COL.length],
              }}
            />
          );
        })}
      </View>
      {/* 범례 */}
      <View style={{ gap: 4 }}>
        {routine.map((r, i) => {
          const legendOpacity = stage(p, i * 0.12, i * 0.12 + 0.4);
          return (
            <View
              key={`legend-${i}-${r.k}`}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: 6,
                opacity: legendOpacity,
              }}
            >
              <View
                style={{
                  width: 6,
                  height: 6,
                  borderRadius: 3,
                  backgroundColor: COL[i % COL.length],
                }}
              />
              <Text style={{ fontSize: 11, color: fortuneTheme.colors.textSecondary }}>
                {r.k}
              </Text>
              <Text style={{ fontSize: 11, color: fortuneTheme.colors.textPrimary }}>
                {r.m}분
              </Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

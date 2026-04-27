/**
 * HeroCoach — `result-cards.jsx:HeroCoach` (859-869).
 *   3개 Bar 스태커 (metrics top 3).
 *   COL = ['#8B7BE8', '#E0A76B', '#68B593']
 *   각 Bar p = stage(p, i*0.12, i*0.12+0.5)
 *
 * Bar 원자는 result-cards.jsx:88-100 (label + value count-up + filled progress bar).
 * RN에 MetricBar primitive 있음 — 해당 사용.
 */
import { View } from 'react-native';

import { MetricBar } from '../primitives/metric-bar';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const COL = ['#8B7BE8', '#E0A76B', '#68B593'];

interface CoachMetric {
  label: string;
  value: number;
  suffix?: string;
}

function extractMetrics(payload: unknown): CoachMetric[] {
  const fallback: CoachMetric[] = [
    { label: '지금 상태', value: 72 },
    { label: '회복 속도', value: 65 },
    { label: '추진력', value: 58 },
  ];
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.metrics) ? data.metrics : null;
  if (!arr) return fallback;
  const parsed = arr
    .map((it): CoachMetric | null => {
      if (!it || typeof it !== 'object') return null;
      const r = it as Record<string, unknown>;
      const label = typeof r.label === 'string' ? r.label : null;
      const value =
        typeof r.value === 'number'
          ? r.value
          : typeof r.value === 'string'
            ? parseInt(r.value as string, 10)
            : null;
      if (!label || value == null || Number.isNaN(value)) return null;
      return {
        label,
        value: Math.max(0, Math.min(100, value)),
        suffix: typeof r.suffix === 'string' ? r.suffix : undefined,
      };
    })
    .filter((x): x is CoachMetric => x != null);
  return parsed.length > 0 ? parsed.slice(0, 3) : fallback;
}

interface HeroCoachProps {
  data: unknown;
  progress?: number;
}

export default function HeroCoach({ data: payload, progress = 1 }: HeroCoachProps) {
  const p = clamp01(progress);
  const metrics = extractMetrics(payload);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 14,
        paddingBottom: 6,
        gap: 6,
      }}
    >
      {metrics.map((m, i) => (
        <MetricBar
          key={`coach-${i}-${m.label}`}
          label={m.label}
          value={m.value}
          max={100}
          color={COL[i % COL.length]}
          progress={stage(p, i * 0.12, i * 0.12 + 0.5)}
          suffix={m.suffix ?? ''}
        />
      ))}
    </View>
  );
}

/**
 * HeroLine — `result-cards.jsx:HeroLine` (328-350). View-only 근사 (SVG 재적용은 다음 빌드).
 *
 * 점 시리즈를 stage 애니메이션으로 순차 노출.
 */
import { View } from 'react-native';

import type { EmbeddedResultPayload } from '../../chat-results/types';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

interface HeroLineProps {
  data: EmbeddedResultPayload;
  progress?: number;
  color?: string;
  height?: number;
}

interface TimelinePoint {
  label?: string;
  value?: number;
}

const DEFAULT_SERIES: TimelinePoint[] = [
  { value: 40 },
  { value: 55 },
  { value: 48 },
  { value: 70 },
  { value: 82 },
  { value: 78 },
  { value: 92 },
];

export default function HeroLine({
  data,
  progress = 1,
  color = '#8FB8FF',
  height = 72,
}: HeroLineProps) {
  // Defensive: data/null safe 접근.
  const raw =
    data && typeof data === 'object'
      ? (data as unknown as { timeline?: TimelinePoint[] }).timeline
      : undefined;
  const series: TimelinePoint[] =
    raw && raw.length > 1 ? raw.slice(0, 12) : DEFAULT_SERIES;
  const p = clamp01(progress);

  return (
    <View style={{ paddingTop: 14, paddingHorizontal: 10, paddingBottom: 6 }}>
      <View
        style={{
          width: '100%',
          height,
          flexDirection: 'row',
          alignItems: 'flex-end',
          justifyContent: 'space-between',
        }}
      >
        {series.map((pt, i) => {
          const v = pt.value ?? 0;
          const dotOpacity = stage(p, 0.4 + i * 0.08, 0.6 + i * 0.08);
          const barOpacity = Math.min(dotOpacity, 0.25);
          const h = (v / 100) * (height - 6);
          const isLast = i === series.length - 1;
          const r = isLast ? 3.5 : 2;
          return (
            <View
              key={`lp-${i}`}
              style={{
                alignItems: 'center',
                justifyContent: 'flex-end',
                height,
              }}
            >
              <View
                style={{
                  width: 2,
                  height: h,
                  backgroundColor: color,
                  opacity: barOpacity,
                  borderRadius: 1,
                }}
              />
              <View
                style={{
                  position: 'absolute',
                  bottom: h - r,
                  width: r * 2,
                  height: r * 2,
                  borderRadius: r,
                  backgroundColor: color,
                  opacity: dotOpacity,
                }}
              />
            </View>
          );
        })}
      </View>
    </View>
  );
}

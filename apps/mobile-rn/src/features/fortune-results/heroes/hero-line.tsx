/**
 * HeroLine — wealth/career hero trend chart.
 *
 * Draws a real connected SVG trend line. The previous View-only placeholder
 * rendered isolated lollipop bars, which made the hero look like broken graph
 * decoration instead of a career/wealth flow chart.
 */
import { useRef } from 'react';
import { View } from 'react-native';
import Svg, { Circle, Defs, Line, LinearGradient, Path, Stop } from 'react-native-svg';

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

interface ChartPoint {
  x: number;
  y: number;
  value: number;
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

const CHART_WIDTH = 320;
const CHART_HEIGHT = 92;
const CHART_PADDING_X = 8;
const CHART_PADDING_TOP = 10;
const CHART_PADDING_BOTTOM = 14;

function buildLinePath(points: ChartPoint[]) {
  return points
    .map((point, index) => `${index === 0 ? 'M' : 'L'} ${point.x.toFixed(1)} ${point.y.toFixed(1)}`)
    .join(' ');
}

function buildAreaPath(points: ChartPoint[]) {
  const baseline = CHART_HEIGHT - CHART_PADDING_BOTTOM;
  return `${buildLinePath(points)} L ${points[points.length - 1].x.toFixed(1)} ${baseline} L ${points[0].x.toFixed(1)} ${baseline} Z`;
}

export default function HeroLine({
  data,
  progress = 1,
  color = '#8FB8FF',
  height = 108,
}: HeroLineProps) {
  // Defensive: data/null safe 접근.
  const raw =
    data && typeof data === 'object'
      ? (data as unknown as { timeline?: TimelinePoint[] }).timeline
      : undefined;
  const series: TimelinePoint[] =
    raw && raw.length > 1 ? raw.slice(0, 12) : DEFAULT_SERIES;
  const p = clamp01(progress);
  const gradientId = useRef(`hero-line-area-${Math.random().toString(36).slice(2)}`).current;
  const chartHeight = Math.min(Math.max(height, CHART_HEIGHT), 140);
  const chartWidth = CHART_WIDTH;
  const step =
    series.length > 1
      ? (chartWidth - CHART_PADDING_X * 2) / (series.length - 1)
      : 0;
  const points: ChartPoint[] = series.map((pt, i) => {
    const value = clamp01((pt.value ?? 0) / 100) * 100;
    const usableHeight = CHART_HEIGHT - CHART_PADDING_TOP - CHART_PADDING_BOTTOM;
    return {
      x: CHART_PADDING_X + step * i,
      y: CHART_PADDING_TOP + (1 - value / 100) * usableHeight,
      value,
    };
  });
  const linePath = buildLinePath(points);
  const areaPath = buildAreaPath(points);
  const lineOpacity = stage(p, 0.18, 0.52);
  const areaOpacity = stage(p, 0.28, 0.62) * 0.18;

  return (
    <View style={{ paddingTop: 12, paddingHorizontal: 2, paddingBottom: 8 }}>
      <Svg
        width="100%"
        height={chartHeight}
        viewBox={`0 0 ${chartWidth} ${CHART_HEIGHT}`}
        preserveAspectRatio="none"
      >
        <Defs>
          <LinearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
            <Stop offset="0" stopColor={color} stopOpacity="0.36" />
            <Stop offset="1" stopColor={color} stopOpacity="0" />
          </LinearGradient>
        </Defs>
        {[0.25, 0.5, 0.75].map((ratio) => {
          const y = CHART_PADDING_TOP + ratio * (CHART_HEIGHT - CHART_PADDING_TOP - CHART_PADDING_BOTTOM);
          return (
            <Line
              key={`grid-${ratio}`}
              x1={CHART_PADDING_X}
              x2={chartWidth - CHART_PADDING_X}
              y1={y}
              y2={y}
              stroke={color}
              strokeOpacity={0.08 * lineOpacity}
              strokeWidth={1}
            />
          );
        })}
        <Path d={areaPath} fill={`url(#${gradientId})`} opacity={areaOpacity} />
        <Path
          d={linePath}
          fill="none"
          stroke={color}
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeOpacity={0.92 * lineOpacity}
          strokeWidth={3}
        />
        {points.map((point, i) => {
          const dotOpacity = stage(p, 0.4 + i * 0.06, 0.58 + i * 0.06);
          const isLast = i === points.length - 1;
          return (
            <Circle
              key={`lp-${i}`}
              cx={point.x}
              cy={point.y}
              r={isLast ? 5 : 3.4}
              fill={color}
              opacity={dotOpacity}
            />
          );
        })}
      </Svg>
    </View>
  );
}

/**
 * HeroYearlyEncounter — `result-cards.jsx:HeroEncounter` (660-685).
 *
 * 원본:
 *   svg 140×140, center (70,70), R=54, r2=60
 *   바깥 원 r54 stroke rgba(255,255,255,0.08)
 *   12개 월 선분(R→r2) + 한자 아래 숫자 라벨 (1~12),
 *     peak(예: "3월" 포함)은 #FF8FB1 stroke 2, 아니면 fg3 stroke 1
 *     각 항목 opacity stage(p, i*0.04, i*0.04+0.3)
 *   중앙 "緣" serif 14px fg, opacity stage(p, 0.3, 0.5)
 *   padding 8/6/4
 *
 * RN 포팅: 월 선분 → rotated View(absolute), 라벨 absolute.
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

interface HeroYearlyEncounterProps {
  data?: unknown;
  progress?: number;
}

const FG3 = '#9EA3B3';

function extractPeaks(payload: unknown): number[] {
  const fallback = [3, 7, 11];
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const months = (data.months ?? data) as Record<string, unknown>;
  const peak = Array.isArray(months.peak) ? months.peak : null;
  if (!peak) return fallback;
  // 원본은 '3월' 같은 문자열 → 숫자로 변환
  const parsed = peak
    .map((v) => {
      if (typeof v === 'number') return v;
      if (typeof v === 'string') {
        const n = parseInt(v, 10);
        return Number.isNaN(n) ? null : n;
      }
      return null;
    })
    .filter((x): x is number => x != null && x >= 1 && x <= 12);
  return parsed.length > 0 ? parsed : fallback;
}

const CONTAINER = 140;
const CX = 70;
const CY = 70;
const R = 54;
const R2 = 60;
const LABEL_R = R2 + 10;

export default function HeroYearlyEncounter({ data: payload, progress = 1 }: HeroYearlyEncounterProps) {
  const p = clamp01(progress);
  const peaks = extractPeaks(payload);
  const centerOpacity = stage(p, 0.3, 0.5);

  return (
    <View
      style={{
        paddingTop: 8,
        paddingHorizontal: 6,
        paddingBottom: 4,
        alignItems: 'center',
      }}
    >
      <View style={{ width: CONTAINER, height: CONTAINER, position: 'relative' }}>
        {/* 바깥 원 */}
        <View
          style={{
            position: 'absolute',
            left: CX - R,
            top: CY - R,
            width: R * 2,
            height: R * 2,
            borderRadius: R,
            borderWidth: 1,
            borderColor: 'rgba(255,255,255,0.08)',
          }}
        />
        {/* 12개 월 눈금 선 + 라벨 */}
        {Array.from({ length: 12 }).map((_, i) => {
          const a = -Math.PI / 2 + (i / 12) * Math.PI * 2;
          const x1 = CX + Math.cos(a) * R;
          const y1 = CY + Math.sin(a) * R;
          const x2 = CX + Math.cos(a) * R2;
          const y2 = CY + Math.sin(a) * R2;
          const month = i + 1;
          const isPeak = peaks.includes(month);
          const opacity = stage(p, i * 0.04, i * 0.04 + 0.3);
          const color = isPeak ? '#FF8FB1' : FG3;
          const weight = isPeak ? 2 : 1;

          // 선분 = rotated view
          const dx = x2 - x1;
          const dy = y2 - y1;
          const length = Math.sqrt(dx * dx + dy * dy);
          const angle = (Math.atan2(dy, dx) * 180) / Math.PI;

          const lx = CX + Math.cos(a) * LABEL_R;
          const ly = CY + Math.sin(a) * LABEL_R;

          return (
            <View key={`m-${i}`} pointerEvents="none">
              <View
                style={{
                  position: 'absolute',
                  left: x1,
                  top: y1,
                  width: length,
                  height: weight,
                  backgroundColor: color,
                  opacity,
                  transformOrigin: '0 0',
                  transform: [{ rotate: `${angle}deg` }],
                }}
              />
              <Text
                style={{
                  position: 'absolute',
                  left: lx - 10,
                  top: ly - 6,
                  width: 20,
                  textAlign: 'center',
                  fontSize: 9,
                  color: isPeak ? '#FF8FB1' : fortuneTheme.colors.textSecondary,
                  opacity,
                }}
              >
                {month}
              </Text>
            </View>
          );
        })}
        {/* 중앙 緣 */}
        <Text
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            top: CY - 10,
            textAlign: 'center',
            fontFamily: 'ZenSerif',
            fontSize: 14,
            color: fortuneTheme.colors.textPrimary,
            opacity: centerOpacity,
          }}
        >
          緣
        </Text>
      </View>
    </View>
  );
}

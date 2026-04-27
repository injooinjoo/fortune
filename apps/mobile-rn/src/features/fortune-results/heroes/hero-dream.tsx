/**
 * HeroDream — `result-cards.jsx:HeroDream` (613-629).
 * 초승달 + 물결 3줄 + 꿈 모티프(serif). 어두운 물빛.
 *   - 달: radial gradient (FFE5B3 → E0A76B), radius 6→14 tween, fadeIn[p:0..0.6]
 *   - 물결 3줄: stroke sky, opacity stage(p, 0.15 + i*0.1, 0.5 + i*0.1) * 0.5
 *   - motif 텍스트: serif 13px fg, 좌상단 14/20, opacity stage(p, 0.35, 0.65), letter-spacing 0.04em, 『motif』
 *
 * RN 포팅: SVG 대신 absolute Views로 달 + 물결 근사.
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const SKY = '#8FB8FF';

function extractMotif(payload: unknown): string {
  if (!payload || typeof payload !== 'object') return '바다';
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  return (
    (typeof data.motif === 'string' && data.motif) ||
    (typeof data.dreamMotif === 'string' && data.dreamMotif) ||
    '바다'
  );
}

interface HeroDreamProps {
  data: unknown;
  progress?: number;
}

export default function HeroDream({ data: payload, progress = 1 }: HeroDreamProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.6);
  const moonR = tween(easeOut(l), 6, 14);
  const motifOpacity = stage(p, 0.35, 0.65);
  const motif = extractMotif(payload);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 14,
        paddingBottom: 4,
        height: 96,
        borderRadius: 12,
        overflow: 'hidden',
        position: 'relative',
      }}
    >
      {/* 달 — 우측 상단 */}
      <View
        style={{
          position: 'absolute',
          top: 22 - moonR + 4,
          right: 40 - moonR + 4,
          width: moonR * 2,
          height: moonR * 2,
          borderRadius: moonR,
          backgroundColor: '#E0A76B',
          opacity: l,
        }}
      >
        <View
          style={{
            position: 'absolute',
            top: moonR * 0.3,
            left: moonR * 0.35,
            width: moonR,
            height: moonR,
            borderRadius: moonR / 2,
            backgroundColor: '#FFE5B3',
            opacity: 0.7,
          }}
        />
      </View>

      {/* 물결 3줄 — 곡선 근사 (얇은 borderRadius-rounded Views로 Wave 표현) */}
      {[0, 1, 2].map((i) => {
        const waveOpacity = stage(p, 0.15 + i * 0.1, 0.5 + i * 0.1) * 0.5;
        const waveY = 55 + i * 8;
        return (
          <View
            key={`wave-${i}`}
            style={{
              position: 'absolute',
              left: 0,
              right: 0,
              top: waveY,
              height: 1,
              backgroundColor: SKY,
              opacity: waveOpacity,
            }}
          />
        );
      })}

      {/* 모티프 텍스트 */}
      <Text
        style={{
          position: 'absolute',
          left: 14,
          top: 20,
          fontFamily: 'ZenSerif',
          fontSize: 13,
          color: fortuneTheme.colors.textPrimary,
          opacity: motifOpacity,
          letterSpacing: 0.52,
        }}
      >
        『{motif}』
      </Text>
    </View>
  );
}

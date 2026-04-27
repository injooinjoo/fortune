/**
 * HeroGauge — `result-cards.jsx:HeroGauge` (374-392).
 * 반원형 게이지 (180° sweep) + 중앙 % 숫자 + 하단 라벨.
 *   - trackStroke: rgba(255,255,255,0.08), width 10
 *   - colorStroke: color, width 10, sweep = (rate/100)*180*l, l = easeOut(stage(p, 0, 0.7))
 *   - center big number: font 32 800 + "%"; label 10px fg3 letter-spacing 0.12em
 *
 * RN 포팅: react-native-svg 없이 근사 — 4분할 셀프-마스크 방식.
 *   반원 트랙을 rotate 0°..180°로 revealing.
 */
import { useEffect, useRef, useState } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const WIDTH = 160;
const HEIGHT = 92;
const THICKNESS = 10;
const RADIUS = 70;

function extractGauge(payload: unknown, fallback: number, labelFallback = 'MATCH'): {
  rate: number;
  label: string;
} {
  if (!payload || typeof payload !== 'object') return { rate: fallback, label: labelFallback };
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const rateCandidate = data.successRate ?? data.score ?? data.rate;
  const rate = typeof rateCandidate === 'number' ? Math.max(0, Math.min(100, rateCandidate)) : fallback;
  const label = typeof data.gaugeLabel === 'string' ? data.gaugeLabel : labelFallback;
  return { rate, label };
}

interface HeroGaugeProps {
  data: unknown;
  progress?: number;
  color?: string;
  label?: string;
  defaultRate?: number;
}

export default function HeroGauge({
  data: payload,
  progress = 1,
  color = fortuneTheme.colors.ctaBackground,
  label,
  defaultRate = 68,
}: HeroGaugeProps) {
  const p = clamp01(progress);
  const revealPhase = easeOut(stage(p, 0, 0.7));

  const extracted = extractGauge(payload, defaultRate, label ?? 'MATCH');
  const rate = extracted.rate;
  const effectiveLabel = label ?? extracted.label;
  const [shownNumber, setShownNumber] = useState(0);
  const maskAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    setShownNumber(Math.round(rate * revealPhase));
    Animated.timing(maskAnim, {
      toValue: revealPhase,
      duration: 60,
      useNativeDriver: true,
    }).start();
  }, [rate, revealPhase, maskAnim]);

  // 180도 반원 sweep. maskAnim 0~1 동안 sweep = rate/100 * 180°.
  const sweepDeg = maskAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', `${(rate / 100) * 180}deg`],
  });

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 16,
        paddingBottom: 4,
        alignItems: 'center',
      }}
    >
      <View style={{ width: WIDTH, height: HEIGHT, overflow: 'hidden', position: 'relative' }}>
        {/* Track (full 180° arc 근사) — 상단 반원만 보이게 overflow */}
        <View
          style={{
            position: 'absolute',
            left: (WIDTH - RADIUS * 2) / 2,
            top: (HEIGHT - RADIUS) - THICKNESS / 2,
            width: RADIUS * 2,
            height: RADIUS * 2,
            borderRadius: RADIUS,
            borderWidth: THICKNESS,
            borderColor: 'rgba(255,255,255,0.08)',
          }}
        />
        {/* Color arc — rotating mask 기법 (sweep만큼 revealing) */}
        <View
          style={{
            position: 'absolute',
            left: (WIDTH - RADIUS * 2) / 2,
            top: (HEIGHT - RADIUS) - THICKNESS / 2,
            width: RADIUS * 2,
            height: RADIUS,
            overflow: 'hidden',
          }}
        >
          <View
            style={{
              width: RADIUS * 2,
              height: RADIUS * 2,
              borderRadius: RADIUS,
              borderWidth: THICKNESS,
              borderColor: color,
              overflow: 'hidden',
            }}
          >
            {/* 왼쪽 절반 (시작점 0°) 가리는 애니메이티드 마스크 */}
            <Animated.View
              style={{
                position: 'absolute',
                left: 0,
                top: 0,
                width: RADIUS,
                height: RADIUS * 2,
                backgroundColor: fortuneTheme.colors.background,
                transformOrigin: 'right center',
                transform: [{ rotate: sweepDeg }],
              }}
            />
          </View>
        </View>
        {/* 중앙 큰 % */}
        <View
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            bottom: 6,
            alignItems: 'center',
          }}
        >
          <Text
            style={{
              fontSize: 32,
              fontWeight: '800',
              color: fortuneTheme.colors.textPrimary,
              letterSpacing: -0.64,
            }}
          >
            {shownNumber}%
          </Text>
          <Text
            style={{
              fontSize: 10,
              color: fortuneTheme.colors.textTertiary,
              letterSpacing: 1.2,
            }}
          >
            {effectiveLabel}
          </Text>
        </View>
      </View>
    </View>
  );
}

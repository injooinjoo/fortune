/**
 * HeroNewYear — `result-cards.jsx:HeroNewYear` (205-221).
 * 12개 월별 바가 왼쪽→오른쪽 순차로 솟아오른다.
 *   - 각 바 높이 = v * 0.55 * easeOut(local), local = stage(p, i*0.04, i*0.04+0.4)
 *   - 배경 gradient(180deg, amber → #8B7BE8), borderRadius 2
 *   - 컨테이너 높이 64, gap 2
 *   - 월 번호 캡션 8px fg3
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

const AMBER = '#E0A76B';
const VIOLET = '#8B7BE8';
const CONTAINER_H = 64;

function extractMonths(payload: unknown): number[] {
  const fallback = [55, 62, 70, 74, 78, 82, 78, 72, 68, 74, 86, 92];
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.months) ? data.months : null;
  if (!arr || arr.length < 12) return fallback;
  return arr.slice(0, 12).map((v) => (typeof v === 'number' ? Math.max(0, Math.min(100, v)) : 0));
}

interface HeroNewYearProps {
  data: unknown;
  progress?: number;
}

export default function HeroNewYear({ data: payload, progress = 1 }: HeroNewYearProps) {
  const p = clamp01(progress);
  const months = extractMonths(payload);

  return (
    <View style={{ paddingHorizontal: 6, paddingTop: 14, paddingBottom: 4 }}>
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'flex-end',
          height: CONTAINER_H + 14,
          gap: 2,
        }}
      >
        {months.map((v, i) => {
          const local = stage(p, i * 0.04, i * 0.04 + 0.4);
          const barHeight = v * 0.55 * easeOut(local) * 0.01 * CONTAINER_H;
          return (
            <View
              key={`m-${i}`}
              style={{
                flex: 1,
                alignItems: 'center',
                gap: 3,
              }}
            >
              <View style={{ height: CONTAINER_H, justifyContent: 'flex-end', width: '100%' }}>
                <View
                  style={{
                    width: '100%',
                    height: barHeight,
                    backgroundColor: AMBER,
                    borderRadius: 2,
                  }}
                >
                  {/* 보라색 바닥 레이어 (gradient 근사) */}
                  <View
                    style={{
                      position: 'absolute',
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: '50%',
                      backgroundColor: VIOLET,
                      borderBottomLeftRadius: 2,
                      borderBottomRightRadius: 2,
                      opacity: 0.9,
                    }}
                  />
                </View>
              </View>
              <Text
                style={{
                  fontSize: 8,
                  color: fortuneTheme.colors.textTertiary,
                }}
              >
                {i + 1}
              </Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

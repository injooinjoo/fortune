/**
 * HeroAvoid — `result-cards.jsx:HeroAvoid` (786-806).
 *   패턴(피해야 할) 리스트. 각 행:
 *     padding 8/12, radius 10, bg rgba(255,140,122,0.08), border rgba(255,140,122,0.25)
 *     ! 뱃지 20×20 원 색 #FF8C7A bg, 800 0B0B10
 *     텍스트 12px fg
 *     스태거 opacity & translateX: l = stage(p, i*0.12, i*0.12+0.35), translateX (1-l)*8
 */
import { Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const CORAL = '#FF8C7A';

function extractPatterns(payload: unknown): string[] {
  const fallback = [
    '갑작스러운 감정적 결정 피하기',
    '무례한 대화 상대와 거리 두기',
    '즉흥 소비 유의',
  ];
  if (!payload || typeof payload !== 'object') return fallback;
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const arr = Array.isArray(data.patterns)
    ? (data.patterns as unknown[]).filter((x): x is string => typeof x === 'string')
    : [];
  return arr.length > 0 ? arr.slice(0, 5) : fallback;
}

interface HeroAvoidProps {
  data: unknown;
  progress?: number;
}

export default function HeroAvoid({ data: payload, progress = 1 }: HeroAvoidProps) {
  const p = clamp01(progress);
  const patterns = extractPatterns(payload);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 12,
        paddingBottom: 2,
        gap: 6,
      }}
    >
      {patterns.map((t, i) => {
        const l = stage(p, i * 0.12, i * 0.12 + 0.35);
        const translateX = (1 - l) * 8;
        return (
          <View
            key={`pattern-${i}`}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 8,
              paddingHorizontal: 12,
              paddingVertical: 8,
              borderRadius: 10,
              backgroundColor: 'rgba(255,140,122,0.08)',
              borderWidth: 1,
              borderColor: 'rgba(255,140,122,0.25)',
              opacity: l,
              transform: [{ translateX }],
            }}
          >
            <View
              style={{
                width: 20,
                height: 20,
                borderRadius: 10,
                backgroundColor: CORAL,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Text
                style={{
                  color: '#0B0B10',
                  fontSize: 11,
                  fontWeight: '800',
                }}
              >
                !
              </Text>
            </View>
            <Text
              style={{
                flex: 1,
                fontSize: 12,
                color: fortuneTheme.colors.textPrimary,
              }}
            >
              {t}
            </Text>
          </View>
        );
      })}
    </View>
  );
}

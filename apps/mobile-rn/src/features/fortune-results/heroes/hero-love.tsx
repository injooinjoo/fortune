/**
 * HeroLove — port of `Ondo Design System/project/fortune_results/result-cards.jsx:HeroLove` (277-293).
 *
 * 원본:
 *   - 두 개 하트 (56×56, #FF8FB1) 바깥에서 안으로 수렴
 *   - 왼쪽: translateX -24→0 + scale 0.6→1, fadeIn [p:0..0.5]
 *   - 오른쪽: translateX +24→0 + scale 0.6→1, fadeIn [p:0.15..0.65]
 *   - drop-shadow 12px rgba(255,143,177,0.4)
 *
 * RN 포팅: react-native-svg 미설치 → unicode ♥ 문자로 대체 (동일 색상/효과).
 */
import { Text, View } from 'react-native';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

interface HeroLoveProps {
  data?: unknown;
  progress?: number;
}

const HEART_COLOR = '#FF8FB1';

export default function HeroLove({ progress = 1 }: HeroLoveProps) {
  const p = clamp01(progress);
  const a = stage(p, 0, 0.5);
  const b = stage(p, 0.15, 0.65);

  const leftTx = tween(easeOut(a), -24, 0);
  const leftScale = tween(easeOut(a), 0.6, 1);
  const rightTx = tween(easeOut(b), 24, 0);
  const rightScale = tween(easeOut(b), 0.6, 1);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 18,
        paddingBottom: 6,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Text
        style={{
          fontSize: 56,
          color: HEART_COLOR,
          opacity: a,
          textShadowColor: 'rgba(255,143,177,0.4)',
          textShadowOffset: { width: 0, height: 0 },
          textShadowRadius: 12,
          transform: [{ translateX: leftTx }, { scale: leftScale }],
        }}
      >
        ♥
      </Text>
      <Text
        style={{
          fontSize: 56,
          color: HEART_COLOR,
          opacity: b,
          textShadowColor: 'rgba(255,143,177,0.4)',
          textShadowOffset: { width: 0, height: 0 },
          textShadowRadius: 12,
          transform: [{ translateX: rightTx }, { scale: rightScale }],
          marginLeft: -16,
        }}
      >
        ♥
      </Text>
    </View>
  );
}

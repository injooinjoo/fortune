/**
 * HeroWish — `result-cards.jsx:HeroWish` (809-821). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { View } from 'react-native';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

interface HeroWishProps {
  data?: unknown;
  progress?: number;
}

export default function HeroWish({ progress = 1 }: HeroWishProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.5);
  const e = easeOut(l);
  const flameW = 16 * e;
  const flameH = 28 * e;

  return (
    <View
      style={{
        paddingTop: 12,
        paddingHorizontal: 6,
        paddingBottom: 4,
        alignItems: 'center',
      }}
    >
      <View style={{ width: 80, height: 100, alignItems: 'center' }}>
        {/* 불꽃 */}
        <View
          style={{
            width: flameW,
            height: flameH,
            borderRadius: flameW / 2,
            backgroundColor: '#E0A76B',
            opacity: l,
            shadowColor: '#FF8C7A',
            shadowOpacity: 0.6,
            shadowRadius: 10,
            shadowOffset: { width: 0, height: 0 },
            marginTop: 14,
          }}
        />
        {/* 초 몸체 */}
        <View
          style={{
            width: 12,
            height: 38,
            backgroundColor: '#FFF3E0',
            opacity: l,
            marginTop: 4,
          }}
        />
        {/* 받침 */}
        <View
          style={{
            width: 20,
            height: 6,
            borderRadius: 2,
            backgroundColor: '#E0A76B',
            opacity: l,
          }}
        />
      </View>
    </View>
  );
}

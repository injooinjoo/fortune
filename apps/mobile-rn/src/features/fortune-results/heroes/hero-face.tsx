/**
 * HeroFace — `result-cards.jsx:HeroFace` (449-470). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { Text, View } from 'react-native';

interface HeroFaceProps {
  data?: unknown;
  progress?: number;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const FG = '#F5F6FB';
const FG2 = '#9198AA';

const W = 110;
const H = 140;

export default function HeroFace({ progress = 1 }: HeroFaceProps) {
  const p = clamp01(progress);
  const zoneOp = (t: number) => stage(p, t, t + 0.3) * 0.18;

  return (
    <View
      style={{
        paddingTop: 10,
        paddingHorizontal: 6,
        paddingBottom: 2,
        alignItems: 'center',
      }}
    >
      <View
        style={{
          width: W,
          height: H,
          borderRadius: W / 2,
          borderWidth: 1.5,
          borderColor: FG2,
          overflow: 'hidden',
          justifyContent: 'space-between',
          alignItems: 'center',
          paddingVertical: 6,
        }}
      >
        <View
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            height: H * 0.33,
            backgroundColor: '#FFC86B',
            opacity: zoneOp(0.05),
          }}
        />
        <View
          style={{
            position: 'absolute',
            top: H * 0.33,
            left: 0,
            right: 0,
            height: H * 0.33,
            backgroundColor: '#E0A76B',
            opacity: zoneOp(0.22),
          }}
        />
        <View
          style={{
            position: 'absolute',
            top: H * 0.66,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: '#FF8FB1',
            opacity: zoneOp(0.42),
          }}
        />
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 12,
            color: FG,
            opacity: stage(p, 0.1, 0.35),
          }}
        >
          上
        </Text>
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 12,
            color: FG,
            opacity: stage(p, 0.28, 0.5),
          }}
        >
          中
        </Text>
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 12,
            color: FG,
            opacity: stage(p, 0.48, 0.7),
          }}
        >
          下
        </Text>
      </View>
    </View>
  );
}

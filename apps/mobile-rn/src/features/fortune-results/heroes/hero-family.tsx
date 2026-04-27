/**
 * HeroFamily — `result-cards.jsx:HeroFamily` (839-856).
 *   5개 점 클러스터 (가족 지도 근사):
 *     [{x:30,y:40,c:'#E0A76B'},{x:70,y:20,c:'#FFC86B'},{x:110,y:40,c:'#8FB8FF'},
 *      {x:50,y:64,c:'#FF8FB1'},{x:90,y:64,c:'#68B593'}]
 *     각 점 r tween(easeOut(l), 4, 10), l = stage(p, i*0.08, i*0.08+0.3)
 *   선 4개 (대각 연결), stroke rgba(255,255,255,0.12)
 */
import { View } from 'react-native';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const CONTAINER_W = 140;
const CONTAINER_H = 90;

const NODES = [
  { x: 30, y: 40, c: '#E0A76B' },
  { x: 70, y: 20, c: '#FFC86B' },
  { x: 110, y: 40, c: '#8FB8FF' },
  { x: 50, y: 64, c: '#FF8FB1' },
  { x: 90, y: 64, c: '#68B593' },
];

const LINES: Array<[number, number, number, number, [number, number]]> = [
  // [x1, y1, x2, y2, [stageFrom, stageTo]]
  [30, 40, 70, 20, [0.3, 0.55]],
  [70, 20, 110, 40, [0.35, 0.6]],
  [30, 40, 50, 64, [0.4, 0.65]],
  [110, 40, 90, 64, [0.45, 0.7]],
];

function diagLine(
  x1: number,
  y1: number,
  x2: number,
  y2: number,
  opacity: number,
) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const length = Math.sqrt(dx * dx + dy * dy);
  const angle = (Math.atan2(dy, dx) * 180) / Math.PI;
  return (
    <View
      pointerEvents="none"
      style={{
        position: 'absolute',
        left: x1,
        top: y1,
        width: length,
        height: 1,
        backgroundColor: 'rgba(255,255,255,0.12)',
        transformOrigin: '0 0',
        transform: [{ rotate: `${angle}deg` }],
        opacity,
      }}
    />
  );
}

interface HeroFamilyProps {
  data?: unknown;
  progress?: number;
}

export default function HeroFamily({ progress = 1 }: HeroFamilyProps) {
  const p = clamp01(progress);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 18,
        paddingBottom: 4,
        alignItems: 'center',
      }}
    >
      <View
        style={{
          width: CONTAINER_W,
          height: CONTAINER_H,
          position: 'relative',
        }}
      >
        {/* 선 (먼저 렌더 → 점 뒤에 깔림) */}
        {LINES.map(([x1, y1, x2, y2, [from, to]], i) => (
          <View key={`line-${i}`}>
            {diagLine(x1, y1, x2, y2, stage(p, from, to))}
          </View>
        ))}
        {/* 점 */}
        {NODES.map((n, i) => {
          const l = stage(p, i * 0.08, i * 0.08 + 0.3);
          const r = tween(easeOut(l), 4, 10);
          return (
            <View
              key={`node-${i}`}
              style={{
                position: 'absolute',
                left: n.x - r,
                top: n.y - r,
                width: r * 2,
                height: r * 2,
                borderRadius: r,
                backgroundColor: n.c,
                opacity: l,
              }}
            />
          );
        })}
      </View>
    </View>
  );
}

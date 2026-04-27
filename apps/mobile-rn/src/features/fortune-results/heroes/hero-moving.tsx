/**
 * HeroMoving — `result-cards.jsx:HeroMoving` (561-592). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const AMBER = '#E0A76B';
const FG2 = '#9198AA';

interface CompassData {
  lucky?: string[];
  unlucky?: string[];
}

interface HeroMovingProps {
  data?: unknown;
  progress?: number;
}

const SIZE = 130;
const DIRS = [
  { k: '北', kr: '북', angle: 0 },
  { k: '北東', kr: '북동', angle: 45 },
  { k: '東', kr: '동', angle: 90 },
  { k: '東南', kr: '동남', angle: 135 },
  { k: '南', kr: '남', angle: 180 },
  { k: '南西', kr: '남서', angle: 225 },
  { k: '西', kr: '서', angle: 270 },
  { k: '北西', kr: '북서', angle: 315 },
];

function extractCompass(payload: unknown): CompassData {
  if (!payload || typeof payload !== 'object') return { lucky: ['동', '남'], unlucky: ['서'] };
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  const compass = (data.compass ?? data) as Record<string, unknown>;
  return {
    lucky: Array.isArray(compass.lucky)
      ? (compass.lucky as unknown[]).filter((x): x is string => typeof x === 'string')
      : ['동', '남'],
    unlucky: Array.isArray(compass.unlucky)
      ? (compass.unlucky as unknown[]).filter((x): x is string => typeof x === 'string')
      : ['서'],
  };
}

export default function HeroMoving({ data: payload, progress = 1 }: HeroMovingProps) {
  const p = clamp01(progress);
  const l = stage(p, 0, 0.6);
  const rotateDeg = tween(easeOut(l), -80, 0);
  const labelOpacity = stage(p, 0.3, 0.6);
  const compass = extractCompass(payload);

  const rotAnim = useRef(new Animated.Value(-80)).current;
  useEffect(() => {
    Animated.timing(rotAnim, {
      toValue: rotateDeg,
      duration: 80,
      useNativeDriver: true,
    }).start();
  }, [rotateDeg, rotAnim]);

  const rotInterp = rotAnim.interpolate({
    inputRange: [-360, 360],
    outputRange: ['-360deg', '360deg'],
  });

  const isLucky = (kr: string) => compass.lucky?.includes(kr) ?? false;
  const isUnlucky = (kr: string) => compass.unlucky?.includes(kr) ?? false;

  const radius = SIZE / 2 - 12;

  return (
    <View
      style={{
        paddingTop: 10,
        paddingHorizontal: 6,
        paddingBottom: 4,
        alignItems: 'center',
      }}
    >
      <View
        style={{
          width: SIZE,
          height: SIZE,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <View
          style={{
            position: 'absolute',
            width: (SIZE * 50) / 60,
            height: (SIZE * 50) / 60,
            borderRadius: SIZE / 2,
            borderWidth: 1,
            borderColor: 'rgba(255,255,255,0.08)',
          }}
        />
        <View
          style={{
            position: 'absolute',
            width: 6,
            height: 6,
            borderRadius: 3,
            backgroundColor: AMBER,
          }}
        />
        <Animated.View
          style={{
            position: 'absolute',
            width: 4,
            height: SIZE * 0.66,
            transform: [{ rotate: rotInterp }],
          }}
        >
          <View
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              height: '50%',
              backgroundColor: AMBER,
              borderTopLeftRadius: 2,
              borderTopRightRadius: 2,
            }}
          />
          <View
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              height: '50%',
              backgroundColor: '#9EA3B3',
              borderBottomLeftRadius: 2,
              borderBottomRightRadius: 2,
            }}
          />
        </Animated.View>
        {DIRS.map((d) => {
          const rad = (d.angle - 90) * (Math.PI / 180);
          const x = Math.cos(rad) * radius;
          const y = Math.sin(rad) * radius;
          const color = isLucky(d.kr) ? '#68B593' : isUnlucky(d.kr) ? '#FF8C7A' : FG2;
          return (
            <Text
              key={d.k}
              style={{
                position: 'absolute',
                transform: [{ translateX: x }, { translateY: y }],
                fontSize: 10,
                fontFamily: 'ZenSerif',
                color,
                opacity: labelOpacity,
              }}
            >
              {d.k}
            </Text>
          );
        })}
      </View>
    </View>
  );
}

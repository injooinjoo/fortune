/**
 * Ring — 원형 progress indicator. SVG Circle 2개 (track + progress).
 * 마운트 시 0 → value로 dashoffset 애니메이션 (800ms ease-out).
 */

import { useEffect, useRef, type ReactNode } from 'react';
import { Animated, Easing, View } from 'react-native';
import Svg, { Circle } from 'react-native-svg';

import { WIDGET_COLORS } from './colors';

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

export interface RingProps {
  size?: number;
  stroke?: number;
  /** 0 - 100 */
  value: number;
  color?: string;
  track?: string;
  children?: ReactNode;
}

export function Ring({
  size = 54,
  stroke = 5,
  value,
  color = WIDGET_COLORS.violet,
  track = WIDGET_COLORS.track,
  children,
}: RingProps) {
  const radius = (size - stroke) / 2;
  const circumference = 2 * Math.PI * radius;
  const targetOffset = circumference - (Math.max(0, Math.min(100, value)) / 100) * circumference;

  const offsetAnim = useRef(new Animated.Value(circumference)).current;

  useEffect(() => {
    Animated.timing(offsetAnim, {
      toValue: targetOffset,
      duration: 800,
      easing: Easing.bezier(0.4, 0, 0.2, 1),
      useNativeDriver: false,
    }).start();
  }, [offsetAnim, targetOffset]);

  return (
    <View
      style={{
        width: size,
        height: size,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Svg
        width={size}
        height={size}
        style={{ position: 'absolute', transform: [{ rotate: '-90deg' }] }}
      >
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={track}
          strokeWidth={stroke}
          fill="none"
        />
        <AnimatedCircle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={color}
          strokeWidth={stroke}
          fill="none"
          strokeDasharray={`${circumference}, ${circumference}`}
          strokeDashoffset={offsetAnim}
          strokeLinecap="round"
        />
      </Svg>
      {children != null ? <View>{children}</View> : null}
    </View>
  );
}

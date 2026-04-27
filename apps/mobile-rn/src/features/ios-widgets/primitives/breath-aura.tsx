/**
 * BreathAura — 원형 radial glow + 호흡 (scale/opacity, 3400ms).
 */

import { useEffect, useRef, type ReactNode } from 'react';
import { Animated, Easing, View } from 'react-native';
import Svg, { Defs, RadialGradient, Rect, Stop } from 'react-native-svg';

import { WIDGET_COLORS } from './colors';
import { withAlpha } from '../../../lib/theme';

export interface BreathAuraProps {
  color?: string;
  size?: number;
  children?: ReactNode;
}

export function BreathAura({
  color = WIDGET_COLORS.violet,
  size = 60,
  children,
}: BreathAuraProps) {
  const scale = useRef(new Animated.Value(0.94)).current;
  const opacity = useRef(new Animated.Value(0.6)).current;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.parallel([
          Animated.timing(scale, {
            toValue: 1.06,
            duration: 1700,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(opacity, {
            toValue: 1,
            duration: 1700,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]),
        Animated.parallel([
          Animated.timing(scale, {
            toValue: 0.94,
            duration: 1700,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(opacity, {
            toValue: 0.6,
            duration: 1700,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]),
      ]),
    );
    loop.start();
    return () => {
      loop.stop();
    };
  }, [scale, opacity]);

  return (
    <View
      style={{
        width: size,
        height: size,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Animated.View
        style={{
          position: 'absolute',
          width: size,
          height: size,
          opacity,
          transform: [{ scale }],
        }}
      >
        <Svg width={size} height={size}>
          <Defs>
            <RadialGradient id="breath" cx="50%" cy="50%" rx="50%" ry="50%">
              <Stop offset="0%" stopColor={withAlpha(color, 0.5)} stopOpacity={1} />
              <Stop offset="65%" stopColor={color} stopOpacity={0} />
            </RadialGradient>
          </Defs>
          <Rect x="0" y="0" width={size} height={size} fill="url(#breath)" />
        </Svg>
      </Animated.View>
      <View>{children}</View>
    </View>
  );
}

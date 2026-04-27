/**
 * CornerGlow — 위젯 우상단 120×120 radial glow.
 * SVG RadialGradient + Rect로 구현.
 */

import Svg, { Defs, RadialGradient, Rect, Stop } from 'react-native-svg';
import { View } from 'react-native';

import { WIDGET_COLORS } from './colors';

export interface CornerGlowProps {
  color?: string;
  opacity?: number;
  size?: number;
  /** 기본 우상단, 그 외 4방향 커스텀 */
  position?: 'topRight' | 'topLeft' | 'bottomRight' | 'bottomLeft';
}

export function CornerGlow({
  color = WIDGET_COLORS.violet,
  opacity = 0.5,
  size = 120,
  position = 'topRight',
}: CornerGlowProps) {
  const pos: { top?: number; bottom?: number; left?: number; right?: number } = {};
  const offset = -30;
  if (position === 'topRight') {
    pos.top = offset;
    pos.right = offset;
  } else if (position === 'topLeft') {
    pos.top = offset;
    pos.left = offset;
  } else if (position === 'bottomRight') {
    pos.bottom = offset;
    pos.right = offset;
  } else {
    pos.bottom = offset;
    pos.left = offset;
  }

  const gradientId = `corner-glow-${color.replace(/[^a-z0-9]/gi, '')}-${position}`;

  return (
    <View
      pointerEvents="none"
      style={{
        position: 'absolute',
        width: size,
        height: size,
        opacity,
        ...pos,
      }}
    >
      <Svg width={size} height={size}>
        <Defs>
          <RadialGradient id={gradientId} cx="50%" cy="50%" rx="50%" ry="50%">
            <Stop offset="0%" stopColor={color} stopOpacity={1} />
            <Stop offset="70%" stopColor={color} stopOpacity={0} />
          </RadialGradient>
        </Defs>
        <Rect x="0" y="0" width={size} height={size} fill={`url(#${gradientId})`} />
      </Svg>
    </View>
  );
}

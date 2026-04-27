/**
 * OndoMark — 위젯 우상단 작은 원형 로고.
 */

import Svg, { Circle } from 'react-native-svg';

import { WIDGET_COLORS } from './colors';

export interface OndoMarkProps {
  size?: number;
  color?: string;
}

export function OndoMark({ size = 12, color = WIDGET_COLORS.whiteSoft }: OndoMarkProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 16 16">
      <Circle cx="8" cy="8" r="7" stroke={color} strokeWidth={1.3} fill="none" />
      <Circle cx="8" cy="8" r="2.2" fill={color} />
    </Svg>
  );
}

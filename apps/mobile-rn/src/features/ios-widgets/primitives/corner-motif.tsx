/**
 * CornerMotif — 한국 장식 4-petal SVG.
 * 벤치마크 widget-primitives.jsx와 동일 path.
 */

import Svg, { Circle, G, Path } from 'react-native-svg';
import { View, type ViewStyle } from 'react-native';

export interface CornerMotifProps {
  size?: number;
  color?: string;
  style?: ViewStyle;
}

export function CornerMotif({
  size = 22,
  color = 'rgba(224,167,107,0.25)',
  style,
}: CornerMotifProps) {
  return (
    <View
      pointerEvents="none"
      style={[{ position: 'absolute', width: size, height: size }, style]}
    >
      <Svg width={size} height={size} viewBox="0 0 24 24">
        <G fill={color}>
          <Path d="M12 2 C14 7, 14 7, 12 12 C10 7, 10 7, 12 2 Z" />
          <Path d="M2 12 C7 10, 7 10, 12 12 C7 14, 7 14, 2 12 Z" />
          <Path d="M12 22 C10 17, 10 17, 12 12 C14 17, 14 17, 12 22 Z" />
          <Path d="M22 12 C17 14, 17 14, 12 12 C17 10, 17 10, 22 12 Z" />
          <Circle cx="12" cy="12" r={1.5} />
        </G>
      </Svg>
    </View>
  );
}

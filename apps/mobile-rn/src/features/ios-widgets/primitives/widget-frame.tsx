/**
 * WidgetFrame — iOS 위젯의 기본 컨테이너.
 *
 * 5개 사이즈 variant (small/medium/large/lockCircle/lockRect).
 * 탭 시 scale 0.97. 기본 블러/보더/그림자 스타일은 벤치마크 widget-primitives.jsx를 참고.
 */

import { useMemo, useState, type ReactNode } from 'react';
import { Pressable, View, type ViewStyle } from 'react-native';

import { WIDGET_COLORS } from './colors';

export type WidgetSize = 'small' | 'medium' | 'large' | 'lockCircle' | 'lockRect';

export interface WidgetSizeSpec {
  w: number;
  h: number;
  r: number;
}

export const WIDGET_SIZES: Record<WidgetSize, WidgetSizeSpec> = {
  small:      { w: 155, h: 155, r: 22 },
  medium:     { w: 330, h: 155, r: 22 },
  large:      { w: 330, h: 330, r: 26 },
  lockCircle: { w: 58,  h: 58,  r: 29 },
  lockRect:   { w: 158, h: 72,  r: 16 },
};

export interface WidgetFrameProps {
  size?: WidgetSize;
  tint?: string;
  onPress?: () => void;
  /** 패딩 제거 (드물게 타로 카드처럼 코너까지 채우는 경우) */
  bare?: boolean;
  children?: ReactNode;
  style?: ViewStyle;
}

export function WidgetFrame({
  size = 'small',
  tint,
  onPress,
  bare = false,
  children,
  style,
}: WidgetFrameProps) {
  const [pressed, setPressed] = useState(false);
  const spec = WIDGET_SIZES[size];
  const padding = size === 'lockCircle' || size === 'lockRect' ? 10 : 16;

  const baseStyle = useMemo<ViewStyle>(
    () => ({
      width: spec.w,
      height: spec.h,
      borderRadius: spec.r,
      backgroundColor: tint ?? WIDGET_COLORS.surface,
      borderWidth: 0.5,
      borderColor: WIDGET_COLORS.border,
      overflow: 'hidden',
      position: 'relative',
      shadowColor: '#000',
      shadowOpacity: 0.35,
      shadowRadius: 16,
      shadowOffset: { width: 0, height: 8 },
      elevation: 8,
    }),
    [spec.w, spec.h, spec.r, tint],
  );

  const content = bare ? (
    children
  ) : (
    <View
      style={{
        padding,
        width: '100%',
        height: '100%',
        position: 'relative',
      }}
    >
      {children}
    </View>
  );

  const pressedStyle: ViewStyle = {
    transform: [{ scale: pressed ? 0.97 : 1 }],
  };

  if (onPress) {
    return (
      <Pressable
        onPress={onPress}
        onPressIn={() => setPressed(true)}
        onPressOut={() => setPressed(false)}
        style={[baseStyle, pressedStyle, style]}
      >
        {content}
      </Pressable>
    );
  }

  return <View style={[baseStyle, style]}>{content}</View>;
}

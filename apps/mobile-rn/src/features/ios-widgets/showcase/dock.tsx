/**
 * Dock + AppIcon — iPhone 홈스크린 Dock.
 * 원본: iphone-shell.jsx Dock, AppIcon.
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';
import Svg, { Defs, LinearGradient, Rect, Stop } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

export interface DockProps {
  children: ReactNode;
}

export function Dock({ children }: DockProps) {
  return (
    <View
      style={{
        position: 'absolute',
        bottom: 34,
        left: 16,
        right: 16,
        height: 78,
        backgroundColor: 'rgba(255,255,255,0.12)',
        borderWidth: 0.5,
        borderColor: 'rgba(255,255,255,0.12)',
        borderRadius: 32,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-around',
        paddingHorizontal: 14,
      }}
    >
      {children}
    </View>
  );
}

export interface AppIconProps {
  /** [startColor, endColor] gradient. 단색이면 두 번째도 같은 값 */
  gradient: readonly [string, string];
  glyph: string;
}

export function AppIcon({ gradient, glyph }: AppIconProps) {
  const gradientId = `app-icon-${gradient.join('-').replace(/[^a-z0-9]/gi, '')}`;

  return (
    <View
      style={{
        width: 54,
        height: 54,
        borderRadius: 13,
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
        borderWidth: 0.5,
        borderColor: 'rgba(255,255,255,0.15)',
        shadowColor: '#000',
        shadowOpacity: 0.35,
        shadowRadius: 6,
        shadowOffset: { width: 0, height: 2 },
      }}
    >
      <Svg
        width={54}
        height={54}
        style={{ position: 'absolute', top: 0, left: 0 }}
      >
        <Defs>
          <LinearGradient id={gradientId} x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0%" stopColor={gradient[0]} stopOpacity={1} />
            <Stop offset="100%" stopColor={gradient[1]} stopOpacity={1} />
          </LinearGradient>
        </Defs>
        <Rect x="0" y="0" width="54" height="54" fill={`url(#${gradientId})`} />
      </Svg>
      <AppText
        color="#FFFFFF"
        style={{ fontSize: 22, fontWeight: '800', lineHeight: 26 }}
      >
        {glyph}
      </AppText>
    </View>
  );
}

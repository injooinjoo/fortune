/**
 * Wallpaper — iPhone 화면 배경. aurora/dusk/minhwa variants.
 * 원본: iphone-shell.jsx Wallpaper. RadialGradient 여러 겹 + StarField.
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';
import Svg, { Defs, LinearGradient, RadialGradient, Rect, Stop } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

import { StarField } from '../primitives';

export type WallpaperVariant = 'aurora' | 'dusk' | 'minhwa';

export interface WallpaperProps {
  variant?: WallpaperVariant;
  children?: ReactNode;
}

export function Wallpaper({ variant = 'aurora', children }: WallpaperProps) {
  return (
    <View style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
      <View
        pointerEvents="none"
        style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
      >
        {variant === 'aurora' && <AuroraLayer />}
        {variant === 'dusk' && <DuskLayer />}
        {variant === 'minhwa' && <MinhwaLayer />}
        <StarField count={28} />
      </View>
      <View style={{ flex: 1 }}>{children}</View>
    </View>
  );
}

function AuroraLayer() {
  return (
    <Svg width="100%" height="100%">
      <Defs>
        <RadialGradient id="aur-violet" cx="10%" cy="15%" rx="55%" ry="45%">
          <Stop offset="0%" stopColor="#8B7BE8" stopOpacity={0.35} />
          <Stop offset="100%" stopColor="#8B7BE8" stopOpacity={0} />
        </RadialGradient>
        <RadialGradient id="aur-blue" cx="90%" cy="100%" rx="70%" ry="55%">
          <Stop offset="0%" stopColor="#8FB8FF" stopOpacity={0.22} />
          <Stop offset="100%" stopColor="#8FB8FF" stopOpacity={0} />
        </RadialGradient>
        <RadialGradient id="aur-amber" cx="78%" cy="35%" rx="38%" ry="38%">
          <Stop offset="0%" stopColor="#E0A76B" stopOpacity={0.14} />
          <Stop offset="100%" stopColor="#E0A76B" stopOpacity={0} />
        </RadialGradient>
      </Defs>
      <Rect x="0" y="0" width="100%" height="100%" fill="#05060C" />
      <Rect x="0" y="0" width="100%" height="100%" fill="url(#aur-violet)" />
      <Rect x="0" y="0" width="100%" height="100%" fill="url(#aur-blue)" />
      <Rect x="0" y="0" width="100%" height="100%" fill="url(#aur-amber)" />
    </Svg>
  );
}

function DuskLayer() {
  return (
    <Svg width="100%" height="100%">
      <Defs>
        <LinearGradient id="dusk-base" x1="0" y1="0" x2="0" y2="1">
          <Stop offset="0%" stopColor="#0B0B10" stopOpacity={1} />
          <Stop offset="40%" stopColor="#1A1028" stopOpacity={1} />
          <Stop offset="75%" stopColor="#2A1A38" stopOpacity={1} />
          <Stop offset="100%" stopColor="#3A1F28" stopOpacity={1} />
        </LinearGradient>
        <RadialGradient id="dusk-amber" cx="92%" cy="5%" rx="55%" ry="50%">
          <Stop offset="0%" stopColor="#E0A76B" stopOpacity={0.3} />
          <Stop offset="100%" stopColor="#E0A76B" stopOpacity={0} />
        </RadialGradient>
      </Defs>
      <Rect x="0" y="0" width="100%" height="100%" fill="url(#dusk-base)" />
      <Rect x="0" y="0" width="100%" height="100%" fill="url(#dusk-amber)" />
    </Svg>
  );
}

function MinhwaLayer() {
  return (
    <View style={{ flex: 1, backgroundColor: '#0B0B10' }}>
      <View
        pointerEvents="none"
        style={{
          position: 'absolute',
          top: '18%',
          left: '15%',
          opacity: 0.08,
        }}
      >
        <AppText
          style={{
            fontSize: 240,
            lineHeight: 240,
            fontFamily: 'ZenSerif',
            color: '#E0A76B',
            transform: [{ rotate: '-8deg' }],
          }}
        >
          溫
        </AppText>
      </View>
    </View>
  );
}

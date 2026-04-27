/**
 * AvatarSquare — 색 그라디언트 사각형 + 중앙 글자/이모지.
 * 벤치마크 Avatar를 RN으로 포팅. expo-linear-gradient가 없어
 * SVG LinearGradient로 구현.
 */

import Svg, { Defs, LinearGradient, Rect, Stop } from 'react-native-svg';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import { withAlpha } from '../../../lib/theme';
import { WIDGET_COLORS } from './colors';

export interface AvatarSquareProps {
  /** 배경 그라디언트 색 (135deg: color → color+55 alpha) */
  tint: string;
  /** 중앙에 표시할 글자 / 이모지 */
  glyph: string;
  /** 가로/세로 픽셀 */
  size?: number;
  /** 모서리 radius (기본 size*0.34) */
  radius?: number;
}

const EMOJI_REGEX = /[\u{1F300}-\u{1FAFF}]|[\u2600-\u27BF]/u;

export function AvatarSquare({ tint, glyph, size = 32, radius }: AvatarSquareProps) {
  const r = radius ?? size * 0.34;
  const isEmoji = EMOJI_REGEX.test(glyph);
  const gradientId = `avatar-${tint.replace(/[^a-z0-9]/gi, '')}`;

  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: r,
        overflow: 'hidden',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Svg
        width={size}
        height={size}
        style={{ position: 'absolute', top: 0, left: 0 }}
      >
        <Defs>
          <LinearGradient id={gradientId} x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0%" stopColor={tint} stopOpacity={1} />
            <Stop offset="100%" stopColor={tint} stopOpacity={0.53} />
          </LinearGradient>
        </Defs>
        <Rect x="0" y="0" width={size} height={size} fill={`url(#${gradientId})`} />
        {/* subtle grain overlay */}
        <Rect x="0" y="0" width={size} height={size} fill={withAlpha('#FFFFFF', 0.08)} />
      </Svg>
      <AppText
        color={isEmoji ? WIDGET_COLORS.textBright : '#0B0B10'}
        style={{
          fontSize: size * 0.44,
          fontWeight: '800',
          letterSpacing: -0.2,
        }}
      >
        {glyph}
      </AppText>
    </View>
  );
}

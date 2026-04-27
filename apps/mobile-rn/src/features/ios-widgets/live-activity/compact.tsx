/**
 * LiveActivityCompact — Dynamic Island pill. 26×26 루나 아바타 + typing + "루나 입력 중".
 * 원본: story-widgets.jsx LiveActivityCompact.
 */

import { View } from 'react-native';
import Svg, { Defs, LinearGradient, Rect, Stop } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

import { TypingDots, WIDGET_COLORS } from '../primitives';

export interface LiveActivityCompactProps {
  label?: string;
  emoji?: string;
}

export function LiveActivityCompact({
  label = '루나 입력 중',
  emoji = '🌙',
}: LiveActivityCompactProps) {
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        height: 37,
        paddingRight: 10,
        paddingLeft: 6,
        backgroundColor: '#000',
        borderRadius: 24,
      }}
    >
      <View
        style={{
          width: 26,
          height: 26,
          borderRadius: 13,
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
        }}
      >
        <Svg
          width={26}
          height={26}
          style={{ position: 'absolute', top: 0, left: 0 }}
        >
          <Defs>
            <LinearGradient id="luna-gradient" x1="0" y1="0" x2="1" y2="1">
              <Stop offset="0%" stopColor={WIDGET_COLORS.lavender} stopOpacity={1} />
              <Stop offset="100%" stopColor={WIDGET_COLORS.violet} stopOpacity={1} />
            </LinearGradient>
          </Defs>
          <Rect x="0" y="0" width="26" height="26" fill="url(#luna-gradient)" />
        </Svg>
        <AppText style={{ fontSize: 14, lineHeight: 16 }}>{emoji}</AppText>
      </View>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
        <TypingDots color={WIDGET_COLORS.lavender} size={3} />
        <AppText
          color="rgba(255,255,255,0.85)"
          style={{ fontSize: 13, fontWeight: '600' }}
        >
          {label}
        </AppText>
      </View>
    </View>
  );
}

/**
 * LockConstellationCircle — 58×58. 별자리 심볼 + 순위.
 * 원본: story-widgets.jsx LockConstellationCircle.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import { WIDGET_COLORS, WidgetFrame } from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function LockConstellationCircle() {
  const { constellation } = useWidgetData();

  return (
    <WidgetFrame size="lockCircle" tint="rgba(0,0,0,0.35)">
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <AppText
          color={WIDGET_COLORS.sky}
          style={{ fontSize: 24, lineHeight: 24, fontFamily: 'ZenSerif' }}
        >
          {constellation.symbol}
        </AppText>
        <AppText
          color="rgba(255,255,255,0.7)"
          style={{ fontSize: 8, marginTop: 3, letterSpacing: 0.5 }}
        >
          {constellation.sign.replace('자리', '')}
        </AppText>
        <AppText
          color={WIDGET_COLORS.amber}
          style={{ fontSize: 9, fontWeight: '800', marginTop: 1 }}
        >
          #{constellation.rank}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

/**
 * WealthSmall — 155×155. amber 큰 숫자 + 한줄.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  CounterText,
  OndoMark,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function WealthSmall() {
  const { wealth } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.amber} opacity={0.35} />
      <WidgetHeader label="오늘의 재물운" right={<OndoMark />} />
      <View style={{ alignItems: 'center', marginTop: 14 }}>
        <AppText
          color={WIDGET_COLORS.whiteFaint}
          style={{ fontSize: 10, letterSpacing: 1, marginBottom: 2 }}
        >
          LUCKY NO.
        </AppText>
        <CounterText
          value={wealth.luckyNumber}
          color={WIDGET_COLORS.amber}
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 52,
            fontWeight: '800',
            letterSpacing: -1,
            lineHeight: 56,
          }}
        />
      </View>
      <View style={{ position: 'absolute', bottom: 14, left: 16, right: 16 }}>
        <AppText
          color={WIDGET_COLORS.whiteStrong}
          style={{ fontSize: 11, lineHeight: 16, textAlign: 'center' }}
        >
          {wealth.summary}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

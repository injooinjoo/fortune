/**
 * ConstellationSmall — 155×155. StarField + 심볼 + 순위.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  OndoMark,
  StarField,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function ConstellationSmall() {
  const { constellation } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.starSurface}>
      <StarField />
      <CornerGlow color={WIDGET_COLORS.sky} opacity={0.3} />
      <WidgetHeader
        label="별자리 운세"
        color="rgba(143,184,255,0.65)"
        right={<OndoMark color="rgba(143,184,255,0.55)" />}
      />
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 2 }}>
        <AppText
          color={WIDGET_COLORS.sky}
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 34,
            fontWeight: '400',
            lineHeight: 34,
          }}
        >
          {constellation.symbol}
        </AppText>
        <View style={{ flex: 1, minWidth: 0 }}>
          <AppText
            color={WIDGET_COLORS.textBright}
            numberOfLines={1}
            style={{ fontSize: 13, fontWeight: '700', letterSpacing: -0.3 }}
          >
            {constellation.sign}
          </AppText>
          <AppText
            color={WIDGET_COLORS.whiteFaint}
            style={{ fontSize: 9.5, marginTop: 1 }}
          >
            {constellation.date}
          </AppText>
        </View>
      </View>
      <View
        style={{
          position: 'absolute',
          bottom: 12,
          left: 16,
          right: 16,
          flexDirection: 'row',
          alignItems: 'baseline',
          justifyContent: 'space-between',
        }}
      >
        <AppText color={WIDGET_COLORS.whiteSoft} style={{ fontSize: 10 }}>
          오늘 순위
        </AppText>
        <AppText
          color={WIDGET_COLORS.amber}
          style={{ fontFamily: 'ZenSerif', fontSize: 14, fontWeight: '800' }}
        >
          {`#${constellation.rank}`}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

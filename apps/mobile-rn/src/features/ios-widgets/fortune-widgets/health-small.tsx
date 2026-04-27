/**
 * HealthSmall — 155×155. green Ring(44) + "맑음" + 한줄.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  CounterText,
  OndoMark,
  Ring,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function HealthSmall() {
  const { health } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.green} opacity={0.3} />
      <WidgetHeader label="오늘의 건강운" right={<OndoMark />} />
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 4 }}>
        <Ring size={44} value={health.score} color={WIDGET_COLORS.green} stroke={4}>
          <CounterText
            value={health.score}
            color={WIDGET_COLORS.textBright}
            style={{ fontSize: 14, fontWeight: '800' }}
          />
        </Ring>
        <View>
          <AppText
            color={WIDGET_COLORS.green}
            style={{ fontFamily: 'ZenSerif', fontSize: 22, fontWeight: '700' }}
          >
            맑음
          </AppText>
          <AppText color={WIDGET_COLORS.whiteSoft} style={{ fontSize: 10, marginTop: 2 }}>
            컨디션 좋은 날
          </AppText>
        </View>
      </View>
      <View style={{ position: 'absolute', bottom: 14, left: 16, right: 16 }}>
        <AppText
          color={WIDGET_COLORS.textBright}
          style={{ fontSize: 12, lineHeight: 17 }}
        >
          {health.summary}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

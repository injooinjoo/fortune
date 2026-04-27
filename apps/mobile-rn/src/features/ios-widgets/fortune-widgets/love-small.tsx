/**
 * LoveSmall — 155×155. pink Ring(58) + ZEN Serif 한줄.
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

export function LoveSmall() {
  const { love } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.pink} opacity={0.35} />
      <WidgetHeader label="오늘의 연애운" right={<OndoMark />} />
      <View style={{ alignItems: 'center', marginTop: 6 }}>
        <Ring size={58} value={love.score} color={WIDGET_COLORS.pink}>
          <CounterText
            value={love.score}
            color={WIDGET_COLORS.textBright}
            style={{ fontSize: 18, fontWeight: '800', letterSpacing: -0.5 }}
          />
        </Ring>
      </View>
      <View style={{ position: 'absolute', bottom: 14, left: 16, right: 16 }}>
        <AppText
          color={WIDGET_COLORS.textBright}
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 12,
            lineHeight: 17,
            textAlign: 'center',
          }}
        >
          {love.summary}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

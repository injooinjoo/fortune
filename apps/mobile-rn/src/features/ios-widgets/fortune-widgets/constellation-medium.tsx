/**
 * ConstellationMedium — 330×155. 좌: 심볼 + 메시지 / 우: 순위 카드.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  CounterText,
  StarField,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function ConstellationMedium() {
  const { constellation } = useWidgetData();
  return (
    <WidgetFrame size="medium" tint={WIDGET_COLORS.starSurface}>
      <StarField />
      <CornerGlow color={WIDGET_COLORS.sky} opacity={0.35} />
      <View style={{ flexDirection: 'row', gap: 16, height: '100%' }}>
        <View style={{ flex: 1 }}>
          <WidgetHeader label="별자리 · 스텔라" color="rgba(143,184,255,0.65)" />
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'flex-end',
              gap: 10,
              marginTop: 4,
            }}
          >
            <AppText
              color={WIDGET_COLORS.sky}
              style={{
                fontFamily: 'ZenSerif',
                fontSize: 44,
                lineHeight: 44,
              }}
            >
              {constellation.symbol}
            </AppText>
            <View style={{ paddingBottom: 4 }}>
              <AppText
                color={WIDGET_COLORS.textBright}
                style={{ fontSize: 15, fontWeight: '800', letterSpacing: -0.2 }}
              >
                {constellation.sign}
              </AppText>
              <AppText
                color={WIDGET_COLORS.whiteFaint}
                style={{ fontSize: 10, marginTop: 2 }}
              >
                {constellation.date}
              </AppText>
            </View>
          </View>
          <AppText
            color={WIDGET_COLORS.textBright}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 13,
              lineHeight: 20,
              marginTop: 12,
              letterSpacing: -0.1,
            }}
          >
            {`"${constellation.message}"`}
          </AppText>
        </View>
        <View
          style={{
            width: 100,
            alignItems: 'center',
            justifyContent: 'center',
            borderLeftWidth: 0.5,
            borderLeftColor: WIDGET_COLORS.borderSoft,
            paddingLeft: 16,
          }}
        >
          <AppText
            color={WIDGET_COLORS.whiteFaint}
            style={{ fontSize: 9, letterSpacing: 1.5, marginBottom: 4 }}
          >
            오늘의 순위
          </AppText>
          <View style={{ flexDirection: 'row', alignItems: 'baseline' }}>
            <AppText
              color={WIDGET_COLORS.amber}
              style={{ fontFamily: 'ZenSerif', fontSize: 36, fontWeight: '800' }}
            >
              #
            </AppText>
            <CounterText
              value={constellation.rank}
              color={WIDGET_COLORS.amber}
              style={{ fontFamily: 'ZenSerif', fontSize: 36, fontWeight: '800' }}
            />
          </View>
          <AppText
            color={WIDGET_COLORS.whiteDim}
            style={{ fontSize: 9, marginTop: 2 }}
          >
            12개 별자리 중
          </AppText>
        </View>
      </View>
    </WidgetFrame>
  );
}

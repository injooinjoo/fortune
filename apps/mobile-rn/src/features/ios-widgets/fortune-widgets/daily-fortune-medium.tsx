/**
 * DailyFortuneMedium — 330×155. 좌측 headline / 우측 4 mini bars.
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

export function DailyFortuneMedium() {
  const { daily } = useWidgetData();
  const cats: Array<{ k: string; v: number; c: string }> = [
    { k: '연애', v: daily.fortune.love,   c: WIDGET_COLORS.pink },
    { k: '재물', v: daily.fortune.wealth, c: WIDGET_COLORS.amber },
    { k: '건강', v: daily.fortune.health, c: WIDGET_COLORS.green },
    { k: '업무', v: daily.fortune.career, c: WIDGET_COLORS.sky },
  ];
  return (
    <WidgetFrame size="medium" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.4} />
      <View style={{ flexDirection: 'row', gap: 14, height: '100%' }}>
        <View style={{ width: 130, flexDirection: 'column' }}>
          <WidgetHeader label="오늘의 운세" right={<OndoMark />} />
          <View style={{ marginTop: 2 }}>
            <AppText
              color={WIDGET_COLORS.amber}
              style={{
                fontFamily: 'ZenSerif',
                fontSize: 30,
                fontWeight: '700',
                letterSpacing: 0.5,
                lineHeight: 30,
              }}
            >
              {daily.level}
            </AppText>
            <AppText
              color={WIDGET_COLORS.whiteSoft}
              style={{ fontSize: 10, marginTop: 5 }}
            >
              하늘 · 사주 전문가
            </AppText>
          </View>
          <View style={{ flex: 1 }} />
          <AppText
            color={WIDGET_COLORS.textBright}
            style={{ fontSize: 11, lineHeight: 15, fontWeight: '500', letterSpacing: -0.1 }}
          >
            {daily.summary}
          </AppText>
        </View>
        <View
          style={{
            width: 0.5,
            backgroundColor: WIDGET_COLORS.borderFaint,
            alignSelf: 'stretch',
          }}
        />
        <View style={{ flex: 1, justifyContent: 'center', gap: 9 }}>
          {cats.map((c) => (
            <View
              key={c.k}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}
            >
              <AppText
                color={WIDGET_COLORS.whiteMid}
                style={{ width: 24, fontSize: 11, fontWeight: '500' }}
              >
                {c.k}
              </AppText>
              <View
                style={{
                  flex: 1,
                  height: 4,
                  borderRadius: 2,
                  backgroundColor: WIDGET_COLORS.trackSoft,
                  overflow: 'hidden',
                }}
              >
                <View
                  style={{
                    width: `${c.v}%`,
                    height: '100%',
                    backgroundColor: c.c,
                    borderRadius: 2,
                  }}
                />
              </View>
              <CounterText
                value={c.v}
                color={c.c}
                style={{
                  width: 22,
                  textAlign: 'right',
                  fontSize: 11,
                  fontWeight: '700',
                }}
              />
            </View>
          ))}
        </View>
      </View>
    </WidgetFrame>
  );
}

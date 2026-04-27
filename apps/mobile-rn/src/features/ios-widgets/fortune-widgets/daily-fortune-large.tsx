/**
 * DailyFortuneLarge — 330×330. Hero + body + lucky grid(4) + 4 mini cats.
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  CornerMotif,
  CounterText,
  OndoMark,
  Ring,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function DailyFortuneLarge() {
  const { daily, lucky } = useWidgetData();
  const cats: Array<[string, number, string]> = [
    ['연애', daily.fortune.love,   WIDGET_COLORS.pink],
    ['재물', daily.fortune.wealth, WIDGET_COLORS.amber],
    ['건강', daily.fortune.health, WIDGET_COLORS.green],
    ['업무', daily.fortune.career, WIDGET_COLORS.sky],
  ];
  return (
    <WidgetFrame size="large" tint={WIDGET_COLORS.surfaceDense}>
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.45} />
      <CornerMotif size={70} color="rgba(224,167,107,0.08)" style={{ top: 4, left: 4 }} />
      <View style={{ flex: 1 }}>
        <WidgetHeader label={headerDate()} right={<OndoMark />} />
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginTop: 2,
          }}
        >
          <View>
            <AppText
              color={WIDGET_COLORS.amber}
              style={{
                fontFamily: 'ZenSerif',
                fontSize: 38,
                fontWeight: '700',
                letterSpacing: 0.5,
                lineHeight: 38,
              }}
            >
              {daily.level}
            </AppText>
            <AppText
              color={WIDGET_COLORS.whiteSoft}
              style={{ fontSize: 10.5, marginTop: 5 }}
            >
              하늘이 전하는 오늘
            </AppText>
          </View>
          <Ring size={54} value={daily.score} color={WIDGET_COLORS.violet} stroke={4}>
            <CounterText
              value={daily.score}
              color={WIDGET_COLORS.textBright}
              style={{ fontSize: 17, fontWeight: '800', letterSpacing: -0.5 }}
            />
          </Ring>
        </View>
        <AppText
          color={WIDGET_COLORS.textBright}
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 13.5,
            lineHeight: 21,
            marginTop: 12,
            letterSpacing: -0.1,
          }}
        >
          {daily.body}
        </AppText>
        <View
          style={{
            height: 0.5,
            backgroundColor: WIDGET_COLORS.borderSoft,
            marginVertical: 12,
          }}
        />
        <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
          <View style={{ width: '50%', marginBottom: 9, flexDirection: 'row' }}>
            <LuckyCell
              label="행운의 색"
              valueText={lucky.color.name}
              swatch={
                <View
                  style={{
                    width: 10,
                    height: 10,
                    borderRadius: 2,
                    backgroundColor: lucky.color.hex,
                  }}
                />
              }
            />
          </View>
          <View style={{ width: '50%', marginBottom: 9 }}>
            <LuckyCell label="행운의 수" valueText={String(lucky.number)} />
          </View>
          <View style={{ width: '50%' }}>
            <LuckyCell label="방위" valueText={lucky.direction} />
          </View>
          <View style={{ width: '50%' }}>
            <LuckyCell label="행운의 물건" valueText={lucky.item} />
          </View>
        </View>
        <View style={{ flex: 1 }} />
        <View style={{ flexDirection: 'row', gap: 6, paddingTop: 12 }}>
          {cats.map(([k, v, c]) => (
            <View key={k} style={{ flex: 1, alignItems: 'center' }}>
              <AppText
                color={WIDGET_COLORS.whiteSoft}
                style={{ fontSize: 9.5, marginBottom: 3 }}
              >
                {k}
              </AppText>
              <CounterText
                value={v}
                color={c}
                style={{ fontSize: 13, fontWeight: '800', letterSpacing: -0.3 }}
              />
            </View>
          ))}
        </View>
      </View>
    </WidgetFrame>
  );
}

function LuckyCell({
  label,
  valueText,
  swatch,
}: {
  label: string;
  valueText: string;
  swatch?: ReactNode;
}) {
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 7, flex: 1 }}>
      {swatch}
      <View style={{ flex: 1, minWidth: 0 }}>
        <AppText color={WIDGET_COLORS.whiteFaint} style={{ fontSize: 9, marginBottom: 1 }}>
          {label}
        </AppText>
        <AppText
          color={WIDGET_COLORS.textBright}
          numberOfLines={1}
          style={{ fontSize: 12, fontWeight: '700', letterSpacing: -0.2 }}
        >
          {valueText}
        </AppText>
      </View>
    </View>
  );
}

function headerDate(): string {
  const d = new Date();
  return `오늘의 운세 · ${d.getMonth() + 1}월 ${d.getDate()}일`;
}

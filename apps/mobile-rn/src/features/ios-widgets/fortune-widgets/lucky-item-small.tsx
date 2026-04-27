/**
 * LuckyItemSmall — 155×155. 2×2 grid: 색/수/방위/시간.
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  CounterText,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function LuckyItemSmall() {
  const { lucky } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.surfaceDense}>
      <CornerGlow color={WIDGET_COLORS.amber} opacity={0.3} />
      <WidgetHeader label="오늘의 행운" />
      <View
        style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginTop: 4 }}
      >
        <LuckyCell
          label="색"
          value={
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
              <View
                style={{
                  width: 10,
                  height: 10,
                  borderRadius: 2,
                  backgroundColor: lucky.color.hex,
                  borderWidth: 0.5,
                  borderColor: 'rgba(255,255,255,0.25)',
                }}
              />
              <AppText
                color={WIDGET_COLORS.textBright}
                style={{ fontSize: 11, fontWeight: '700' }}
              >
                {lucky.color.name}
              </AppText>
            </View>
          }
        />
        <LuckyCell
          label="수"
          value={
            <CounterText
              value={lucky.number}
              color={WIDGET_COLORS.amber}
              style={{
                fontSize: 18,
                fontFamily: 'ZenSerif',
                fontWeight: '700',
                lineHeight: 18,
              }}
            />
          }
        />
        <LuckyCell
          label="방위"
          value={
            <AppText
              color={WIDGET_COLORS.textBright}
              style={{ fontSize: 12, fontWeight: '700' }}
            >
              {lucky.direction}
            </AppText>
          }
        />
        <LuckyCell
          label="시간"
          value={
            <AppText
              color={WIDGET_COLORS.textBright}
              style={{ fontSize: 11, fontWeight: '700' }}
            >
              {lucky.time}
            </AppText>
          }
        />
      </View>
    </WidgetFrame>
  );
}

function LuckyCell({ label, value }: { label: string; value: ReactNode }) {
  return (
    <View
      style={{
        width: '48%',
        backgroundColor: WIDGET_COLORS.trackFaint,
        borderRadius: 8,
        paddingHorizontal: 8,
        paddingVertical: 5,
        minHeight: 42,
        justifyContent: 'center',
      }}
    >
      <AppText
        color={WIDGET_COLORS.whiteFaint}
        style={{ fontSize: 9, marginBottom: 2 }}
      >
        {label}
      </AppText>
      <View>{value}</View>
    </View>
  );
}

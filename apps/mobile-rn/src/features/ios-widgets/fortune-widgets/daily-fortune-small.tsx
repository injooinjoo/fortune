/**
 * DailyFortuneSmall — 155×155 위젯. Ring + level + 요약 한 줄.
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

export function DailyFortuneSmall() {
  const { daily } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.35} />
      <WidgetHeader label="오늘의 운세" right={<OndoMark />} />
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 4 }}>
        <Ring size={54} value={daily.score} color={WIDGET_COLORS.violet}>
          <CounterText
            value={daily.score}
            color={WIDGET_COLORS.textBright}
            style={{ fontSize: 18, fontWeight: '800', letterSpacing: -0.5 }}
          />
        </Ring>
        <View>
          <AppText
            color={WIDGET_COLORS.amber}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 20,
              fontWeight: '700',
              letterSpacing: 0.5,
            }}
          >
            {daily.level}
          </AppText>
          <AppText
            color={WIDGET_COLORS.whiteSoft}
            style={{ fontSize: 10.5, marginTop: 2 }}
          >
            {todayLabel()}
          </AppText>
        </View>
      </View>
      <View style={{ position: 'absolute', bottom: 14, left: 16, right: 16 }}>
        <AppText
          color={WIDGET_COLORS.textBright}
          style={{
            fontSize: 12.5,
            lineHeight: 17,
            fontWeight: '500',
            letterSpacing: -0.1,
          }}
        >
          {daily.summary}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

function todayLabel(): string {
  const d = new Date();
  const weekday = ['일', '월', '화', '수', '목', '금', '토'][d.getDay()] ?? '';
  return `${d.getMonth() + 1}.${d.getDate()} ${weekday}요일`;
}

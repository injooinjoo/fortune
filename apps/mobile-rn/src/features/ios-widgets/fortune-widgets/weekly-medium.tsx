/**
 * WeeklyMedium — 330×155. 7일 bar chart (강조일 violet).
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  OndoMark,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function WeeklyMedium() {
  const { weekly } = useWidgetData();
  const highlight = weekly.find((d) => d.hi);
  return (
    <WidgetFrame size="medium" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.25} />
      <WidgetHeader label="이번 주의 운세" right={<OndoMark />} />
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'flex-end',
          justifyContent: 'space-between',
          height: 72,
          marginTop: 20,
          gap: 6,
          paddingHorizontal: 4,
        }}
      >
        {weekly.map((d) => {
          const barHeight = Math.max(8, (d.score * 0.62 * 72) / 100);
          return (
            <View
              key={d.d}
              style={{ flex: 1, alignItems: 'center', gap: 6 }}
            >
              <View
                style={{
                  width: '100%',
                  maxWidth: 24,
                  height: barHeight,
                  backgroundColor: d.hi ? WIDGET_COLORS.violet : 'rgba(255,255,255,0.10)',
                  borderRadius: 5,
                  position: 'relative',
                  shadowColor: d.hi ? WIDGET_COLORS.violet : 'transparent',
                  shadowOpacity: d.hi ? 0.5 : 0,
                  shadowRadius: 14,
                  shadowOffset: { width: 0, height: 0 },
                }}
              >
                {d.hi ? (
                  <AppText
                    color={WIDGET_COLORS.amber}
                    style={{
                      position: 'absolute',
                      top: -18,
                      left: 0,
                      right: 0,
                      textAlign: 'center',
                      fontSize: 10,
                      fontWeight: '800',
                    }}
                  >
                    {String(d.score)}
                  </AppText>
                ) : null}
              </View>
              <AppText
                color={d.hi ? WIDGET_COLORS.amber : WIDGET_COLORS.whiteSoft}
                style={{ fontSize: 10, fontWeight: d.hi ? '700' : '500' }}
              >
                {d.d}
              </AppText>
            </View>
          );
        })}
      </View>
      <View style={{ position: 'absolute', bottom: 12, left: 16, right: 16 }}>
        <AppText color={WIDGET_COLORS.whiteSoft} style={{ fontSize: 11 }}>
          <AppText color={WIDGET_COLORS.amber} style={{ fontSize: 11, fontWeight: '700' }}>
            {highlight ? `${highlight.d}요일` : '이번 주'}
          </AppText>
          {'이 가장 좋은 날이에요'}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

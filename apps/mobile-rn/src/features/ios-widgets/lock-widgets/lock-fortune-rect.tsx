/**
 * LockFortuneRect — 158×72. 오늘의 운세 level + 점수 + 한줄.
 * 원본: story-widgets.jsx LockRectFortune.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CounterText,
  OndoMark,
  WIDGET_COLORS,
  WidgetFrame,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function LockFortuneRect() {
  const { daily } = useWidgetData();

  return (
    <WidgetFrame size="lockRect" tint="rgba(0,0,0,0.35)">
      <View style={{ flex: 1, justifyContent: 'space-between' }}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <AppText
            color="rgba(255,255,255,0.6)"
            style={{ fontSize: 9, letterSpacing: 1 }}
          >
            ONDO · 오늘의 운세
          </AppText>
          <OndoMark size={10} color="rgba(255,255,255,0.55)" />
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'baseline', gap: 8 }}>
          <AppText
            color={WIDGET_COLORS.amber}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 20,
              fontWeight: '700',
              letterSpacing: 0.3,
              lineHeight: 20,
            }}
          >
            {daily.level}
          </AppText>
          <CounterText
            value={daily.score}
            color="rgba(255,255,255,0.85)"
            style={{ fontSize: 11, fontWeight: '600' }}
            format={(n) => `${n}점`}
          />
        </View>
        <AppText
          color="rgba(255,255,255,0.75)"
          numberOfLines={1}
          style={{ fontSize: 10, lineHeight: 13 }}
        >
          {daily.summary}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

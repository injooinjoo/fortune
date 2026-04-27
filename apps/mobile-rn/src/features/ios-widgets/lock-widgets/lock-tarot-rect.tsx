/**
 * LockTarotRect — 158×72. 작은 카드 + 이름 + 키워드.
 * 원본: story-widgets.jsx LockRectTarot.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  TarotFace,
  WIDGET_COLORS,
  WidgetFrame,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function LockTarotRect() {
  const { tarot } = useWidgetData();

  return (
    <WidgetFrame size="lockRect" tint="rgba(0,0,0,0.35)">
      <View
        style={{
          flex: 1,
          flexDirection: 'row',
          alignItems: 'center',
          gap: 10,
        }}
      >
        <View style={{ width: 32, height: 48 }}>
          <TarotFace card={{ name: tarot.name, ko: tarot.ko, arcana: tarot.arcana }} />
        </View>
        <View style={{ flex: 1, minWidth: 0 }}>
          <AppText
            color="rgba(255,255,255,0.55)"
            style={{ fontSize: 8, letterSpacing: 1 }}
          >
            오늘의 카드
          </AppText>
          <AppText
            color={WIDGET_COLORS.amber}
            numberOfLines={1}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 15,
              fontWeight: '700',
              lineHeight: 17,
              marginTop: 1,
            }}
          >
            {tarot.name}
          </AppText>
          <AppText
            color="rgba(255,255,255,0.75)"
            numberOfLines={1}
            style={{ fontSize: 10, marginTop: 2, lineHeight: 12 }}
          >
            {tarot.keyword}
          </AppText>
        </View>
      </View>
    </WidgetFrame>
  );
}

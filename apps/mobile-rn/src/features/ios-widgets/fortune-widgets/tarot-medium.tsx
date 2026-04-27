/**
 * TarotMedium — 330×155. 좌 카드 + 우 리딩.
 */

import { useState } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  TarotCard,
  WIDGET_COLORS,
  WidgetFrame,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function TarotMedium() {
  const { tarot } = useWidgetData();
  const [flipped, setFlipped] = useState(true);
  return (
    <WidgetFrame
      size="medium"
      tint={WIDGET_COLORS.tarotSurface}
      onPress={() => setFlipped((f) => !f)}
    >
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.35} />
      <View
        style={{ flexDirection: 'row', gap: 14, height: '100%', alignItems: 'center' }}
      >
        <View style={{ width: 80, height: 120 }}>
          <TarotCard
            width={80}
            height={120}
            flipped={flipped}
            card={{
              name: tarot.name,
              ko: tarot.ko,
              arcana: tarot.arcana,
              position: tarot.position,
            }}
          />
        </View>
        <View style={{ flex: 1, minWidth: 0 }}>
          <AppText
            color={WIDGET_COLORS.whiteFaint}
            style={{ fontSize: 10, letterSpacing: 1, marginBottom: 6 }}
          >
            {tarot.arcana}
          </AppText>
          <AppText
            color={WIDGET_COLORS.textBright}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 24,
              fontWeight: '700',
              letterSpacing: 0.5,
              lineHeight: 26,
            }}
          >
            {tarot.name}
          </AppText>
          <AppText
            color={WIDGET_COLORS.amber}
            style={{ fontSize: 11, marginTop: 4, fontWeight: '500' }}
          >
            {tarot.keyword}
          </AppText>
          <AppText
            color={WIDGET_COLORS.whiteStrong}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 12,
              lineHeight: 18,
              marginTop: 10,
            }}
          >
            {`"${tarot.reading}"`}
          </AppText>
        </View>
      </View>
    </WidgetFrame>
  );
}

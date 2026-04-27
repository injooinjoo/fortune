/**
 * TarotSmall — 155×155. 탭 시 카드 뒤집기.
 */

import { useState } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  OndoMark,
  TarotCard,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function TarotSmall() {
  const { tarot } = useWidgetData();
  const [flipped, setFlipped] = useState(false);
  return (
    <WidgetFrame
      size="small"
      tint={WIDGET_COLORS.tarotSurface}
      onPress={() => setFlipped((f) => !f)}
    >
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.3} />
      <WidgetHeader label="오늘의 카드" right={<OndoMark />} />
      <View style={{ alignItems: 'center', justifyContent: 'center', marginTop: 2 }}>
        <TarotCard
          width={64}
          height={96}
          flipped={flipped}
          card={{
            name: tarot.name,
            ko: tarot.ko,
            arcana: tarot.arcana,
            position: tarot.position,
          }}
        />
      </View>
      <View
        style={{ position: 'absolute', bottom: 12, left: 12, right: 12, alignItems: 'center' }}
      >
        <AppText
          color={WIDGET_COLORS.whiteFaint}
          style={{ fontSize: 9.5, letterSpacing: 0.2 }}
        >
          {flipped ? `${tarot.ko} · ${tarot.position}` : '탭해서 카드 뒤집기'}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

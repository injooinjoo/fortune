/**
 * TarotDrawLarge — 330×330. 3-card fan + 하나 선택해서 flip.
 * 원본: story-widgets.jsx TarotDrawLarge.
 */

import { useState } from 'react';
import { Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CornerGlow,
  OndoMark,
  StarField,
  TarotCard,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function TarotDrawLarge() {
  const { tarotDraw } = useWidgetData();
  const [drawn, setDrawn] = useState<number | null>(null);

  const hintSub =
    drawn === null
      ? tarotDraw.subhint
      : `${tarotDraw.cards[drawn].ko} · ${tarotDraw.cards[drawn].keyword}`;

  return (
    <WidgetFrame size="large" tint={WIDGET_COLORS.tarotSurface}>
      <StarField />
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.4} />
      <View style={{ flex: 1 }}>
        <WidgetHeader label="무현 · 타로 한 장 뽑기" right={<OndoMark />} />

        <View style={{ alignItems: 'center', marginTop: 10 }}>
          <AppText
            color={WIDGET_COLORS.amber}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 22,
              fontWeight: '700',
              letterSpacing: 0.3,
            }}
          >
            {tarotDraw.hint}
          </AppText>
          <AppText
            color={WIDGET_COLORS.whiteSoft}
            style={{ fontSize: 11, marginTop: 4, textAlign: 'center' }}
          >
            {hintSub}
          </AppText>
        </View>

        {/* 3 card fan */}
        <View
          style={{
            flex: 1,
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 10,
          }}
        >
          {tarotDraw.cards.map((c, i) => {
            const isDrawn = drawn === i;
            const rot = i === 0 ? -8 : i === 2 ? 8 : 0;
            const lift = isDrawn ? -14 : 0;
            return (
              <Pressable
                key={c.name}
                onPress={() => setDrawn(isDrawn ? null : i)}
                style={{
                  transform: [{ rotate: `${rot}deg` }, { translateY: lift }],
                }}
              >
                <TarotCard
                  width={74}
                  height={118}
                  flipped={isDrawn}
                  card={{ name: c.name, ko: c.ko, arcana: 'Major Arcana' }}
                />
              </Pressable>
            );
          })}
        </View>

        <View style={{ alignItems: 'center', marginTop: 'auto' }}>
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 6,
              backgroundColor: 'rgba(139,123,232,0.15)',
              borderWidth: 0.5,
              borderColor: 'rgba(139,123,232,0.3)',
              paddingVertical: 8,
              paddingHorizontal: 16,
              borderRadius: 9999,
            }}
          >
            <AppText
              color="#B7AEF0"
              style={{ fontSize: 12, fontWeight: '600' }}
            >
              {drawn === null ? '카드를 탭하세요' : '다시 펼치기'}
            </AppText>
          </View>
        </View>
      </View>
    </WidgetFrame>
  );
}

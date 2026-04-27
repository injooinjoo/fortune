/**
 * UnreadMedium — 330×155. 안 읽은 메시지 count + 3 previews.
 * 원본: story-widgets.jsx UnreadMedium.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  AvatarSquare,
  CornerGlow,
  CounterText,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { STORIES } from '../data/widget-data-mock';
import { useWidgetData } from '../data/widget-data-live';

export function UnreadMedium() {
  const { unread } = useWidgetData();

  return (
    <WidgetFrame size="medium" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={WIDGET_COLORS.violet} opacity={0.25} />
      <WidgetHeader
        label="안 읽은 메시지"
        right={
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
            <View
              style={{
                width: 5,
                height: 5,
                borderRadius: 3,
                backgroundColor: WIDGET_COLORS.violet,
              }}
            />
            <CounterText
              value={unread.total}
              color={WIDGET_COLORS.violet}
              style={{ fontSize: 11, fontWeight: '800' }}
            />
          </View>
        }
      />
      <View style={{ flexDirection: 'column', gap: 6 }}>
        {unread.items.slice(0, 3).map((m, i) => {
          const st = STORIES.find((s) => s.ko === m.char) ?? STORIES[i % STORIES.length];
          return (
            <View
              key={`${m.char}-${i}`}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}
            >
              <AvatarSquare tint={st.tint} glyph={st.avatar} size={24} />
              <View style={{ flex: 1, minWidth: 0 }}>
                <AppText
                  color={WIDGET_COLORS.textBright}
                  style={{
                    fontSize: 11,
                    fontWeight: '700',
                    letterSpacing: -0.2,
                    lineHeight: 13,
                  }}
                >
                  {m.char}
                </AppText>
                <AppText
                  color={WIDGET_COLORS.whiteSoft}
                  numberOfLines={1}
                  style={{ fontSize: 10, marginTop: 1, lineHeight: 12 }}
                >
                  {m.preview}
                </AppText>
              </View>
              <View
                style={{
                  width: 5,
                  height: 5,
                  borderRadius: 3,
                  backgroundColor: WIDGET_COLORS.violet,
                }}
              />
            </View>
          );
        })}
      </View>
    </WidgetFrame>
  );
}

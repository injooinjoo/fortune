/**
 * StoryPreviewSmall — 155×155. 해린 캐릭터 + typing bubble.
 * 원본: story-widgets.jsx StoryPreviewSmall.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  AvatarSquare,
  BreathAura,
  CornerGlow,
  OndoMark,
  TypingDots,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { STORIES } from '../data/widget-data-mock';

export function StoryPreviewSmall() {
  const story = STORIES[0]; // 해린

  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.surfaceOpaque}>
      <CornerGlow color={story.tint} opacity={0.25} />
      <WidgetHeader label="일반 채팅" right={<OndoMark />} />
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 4 }}>
        <BreathAura color={story.tint} size={44}>
          <AvatarSquare tint={story.tint} glyph={story.avatar} size={36} />
        </BreathAura>
        <View style={{ flexShrink: 1 }}>
          <AppText
            color={WIDGET_COLORS.textBright}
            style={{ fontSize: 13, fontWeight: '700', letterSpacing: -0.2 }}
          >
            {story.ko}
          </AppText>
          <AppText
            color={WIDGET_COLORS.whiteSoft}
            style={{ fontSize: 10, marginTop: 1 }}
          >
            {story.sub}
          </AppText>
        </View>
      </View>
      <View style={{ position: 'absolute', bottom: 14, left: 16, right: 16 }}>
        <View
          style={{
            backgroundColor: 'rgba(255,255,255,0.06)',
            borderRadius: 12,
            paddingHorizontal: 10,
            paddingVertical: 8,
            flexDirection: 'row',
            alignItems: 'center',
            gap: 6,
          }}
        >
          <TypingDots color={WIDGET_COLORS.whiteMid} size={3.5} />
          <AppText color={WIDGET_COLORS.whiteSoft} style={{ fontSize: 10 }}>
            입력 중…
          </AppText>
        </View>
      </View>
    </WidgetFrame>
  );
}

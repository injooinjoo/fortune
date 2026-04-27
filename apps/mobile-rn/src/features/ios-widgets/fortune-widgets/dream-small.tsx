/**
 * DreamSmall — 155×155. StarField + BreathAura 🌙 + ZEN Serif italic.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  BreathAura,
  CornerGlow,
  OndoMark,
  StarField,
  WIDGET_COLORS,
  WidgetFrame,
  WidgetHeader,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function DreamSmall() {
  const { recommendation } = useWidgetData();
  return (
    <WidgetFrame size="small" tint={WIDGET_COLORS.starSurface}>
      <StarField />
      <CornerGlow color={WIDGET_COLORS.lavender} opacity={0.35} />
      <WidgetHeader
        label="새벽의 속삭임"
        color="rgba(184,176,255,0.7)"
        right={<OndoMark color="rgba(184,176,255,0.55)" />}
      />
      <View style={{ alignItems: 'center', marginTop: 4 }}>
        <BreathAura color={WIDGET_COLORS.lavender} size={56}>
          <AppText style={{ fontSize: 34, lineHeight: 38 }}>{recommendation.avatar}</AppText>
        </BreathAura>
      </View>
      <View style={{ position: 'absolute', bottom: 12, left: 16, right: 16 }}>
        <AppText
          color={WIDGET_COLORS.textBright}
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 11,
            lineHeight: 15,
            fontStyle: 'italic',
            textAlign: 'center',
          }}
        >
          {recommendation.hook}
        </AppText>
      </View>
    </WidgetFrame>
  );
}

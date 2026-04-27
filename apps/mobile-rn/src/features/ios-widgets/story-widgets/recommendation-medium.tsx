/**
 * RecommendationMedium — 330×155. 새 캐릭터 소개 + hook 문구.
 * 원본: story-widgets.jsx RecommendationMedium.
 */

import { View } from 'react-native';
import Svg, { Defs, RadialGradient, Rect, Stop } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

import {
  BreathAura,
  StarField,
  WIDGET_COLORS,
  WidgetFrame,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function RecommendationMedium() {
  const { recommendation } = useWidgetData();

  return (
    <WidgetFrame size="medium" tint="rgba(20,16,32,0.92)">
      {/* radial glow behind the avatar */}
      <View
        pointerEvents="none"
        style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
      >
        <Svg width="100%" height="100%">
          <Defs>
            <RadialGradient id="rec-glow" cx="75%" cy="40%" rx="55%" ry="55%">
              <Stop offset="0%" stopColor={recommendation.tint} stopOpacity={0.25} />
              <Stop offset="100%" stopColor={recommendation.tint} stopOpacity={0} />
            </RadialGradient>
          </Defs>
          <Rect x="0" y="0" width="100%" height="100%" fill="url(#rec-glow)" />
        </Svg>
      </View>
      <StarField count={16} />
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          gap: 14,
          height: '100%',
        }}
      >
        <BreathAura color={recommendation.tint} size={96}>
          <View
            style={{
              width: 78,
              height: 78,
              borderRadius: 39,
              backgroundColor: recommendation.tint,
              alignItems: 'center',
              justifyContent: 'center',
              borderWidth: 0.5,
              borderColor: 'rgba(255,255,255,0.15)',
              overflow: 'hidden',
            }}
          >
            <View
              pointerEvents="none"
              style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
            >
              <Svg width="100%" height="100%">
                <Defs>
                  <RadialGradient id="rec-sheen" cx="30%" cy="25%" rx="55%" ry="55%">
                    <Stop offset="0%" stopColor="#FFFFFF" stopOpacity={0.3} />
                    <Stop offset="100%" stopColor="#FFFFFF" stopOpacity={0} />
                  </RadialGradient>
                </Defs>
                <Rect x="0" y="0" width="100%" height="100%" fill="url(#rec-sheen)" />
              </Svg>
            </View>
            <AppText style={{ fontSize: 36, lineHeight: 40 }}>
              {recommendation.avatar}
            </AppText>
          </View>
        </BreathAura>

        <View style={{ flex: 1, minWidth: 0 }}>
          <AppText
            color={WIDGET_COLORS.whiteDim}
            style={{ fontSize: 9, letterSpacing: 2, marginBottom: 6 }}
          >
            새로 만날 캐릭터
          </AppText>
          <AppText
            color={WIDGET_COLORS.textBright}
            style={{ fontSize: 17, fontWeight: '800', letterSpacing: -0.3 }}
          >
            {recommendation.ko}
          </AppText>
          <AppText
            color={WIDGET_COLORS.whiteSoft}
            style={{ fontSize: 10.5, marginBottom: 8 }}
          >
            {recommendation.sub}
          </AppText>
          <AppText
            color={WIDGET_COLORS.textBright}
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 12.5,
              lineHeight: 18,
            }}
          >
            {recommendation.hook}
          </AppText>
        </View>
      </View>
    </WidgetFrame>
  );
}

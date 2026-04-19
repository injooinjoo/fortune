// HeroEx: signature Ondo hero for the Ex-Lover result screen.
// Left column: Kicker "EX-LOVER ANALYSIS" + core emotion Title + Sub.
// Center: vertical thermometer (30px wide, ~200px tall) filled bottom-up by
// emotionalTemperature, plus 2-3 static drifting orbs with emotion tints
// (port of result-cards.jsx HeroEx — orbs are static here; no animation).
// Right column: ScoreDial showing recoveryScore.
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

const EMOTION_PALETTE = {
  obsession: '#FF6B9D',
  avoidance: '#FF6B6B',
  anxiety: '#8B7BE8',
  anger: '#FF3B30',
  sadness: '#8FB8FF',
  longing: '#E0A76B',
} as const;

const DEFAULT_ORB_COLORS = [
  withAlpha(EMOTION_PALETTE.obsession, 0.4),
  withAlpha(EMOTION_PALETTE.anxiety, 0.4),
  withAlpha(EMOTION_PALETTE.longing, 0.4),
];

const TRACK_HEIGHT = 200;
const TRACK_WIDTH = 30;

interface HeroExProps {
  emotionLabel: string;
  emotionalTemperature: number;
  recoveryScore: number;
  description?: string;
  emotionColor?: string;
  orbColors?: string[];
}

interface ThermometerProps {
  temperature: number;
  fillColor: string;
  orbColors: string[];
}

function Thermometer({ temperature, fillColor, orbColors }: ThermometerProps) {
  const pct = Math.max(0, Math.min(100, temperature));
  const fillHeight = (TRACK_HEIGHT * pct) / 100;
  const trackBg = withAlpha(fortuneTheme.colors.accentSecondary, 0.15);

  // Orbs are placed at fixed offsets around the tube for a static "drifting" feel.
  const orbLayouts = [
    { size: 26, top: 12, left: -22 },
    { size: 22, top: 78, left: TRACK_WIDTH + 4 },
    { size: 28, top: 140, left: -26 },
  ];

  return (
    <View
      style={{
        width: TRACK_WIDTH + 60,
        height: TRACK_HEIGHT + 8,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Orbs (absolute) */}
      {orbLayouts.map((o, i) => {
        const color = orbColors[i] ?? DEFAULT_ORB_COLORS[i] ?? DEFAULT_ORB_COLORS[0];
        return (
          <View
            key={i}
            style={{
              position: 'absolute',
              top: o.top,
              left: o.left + 30,
              width: o.size,
              height: o.size,
              borderRadius: o.size / 2,
              backgroundColor: color,
            }}
          />
        );
      })}

      {/* Track */}
      <View
        style={{
          width: TRACK_WIDTH,
          height: TRACK_HEIGHT,
          borderRadius: TRACK_WIDTH / 2,
          backgroundColor: trackBg,
          overflow: 'hidden',
          justifyContent: 'flex-end',
        }}
      >
        {/* Fill (bottom-up) */}
        <View
          style={{
            width: '100%',
            height: fillHeight,
            backgroundColor: fillColor,
            borderRadius: TRACK_WIDTH / 2,
          }}
        />
      </View>
    </View>
  );
}

export default function HeroEx({
  emotionLabel,
  emotionalTemperature,
  recoveryScore,
  description,
  emotionColor,
  orbColors,
}: HeroExProps) {
  const fillColor = emotionColor ?? fortuneTheme.colors.error;
  const orbs = orbColors ?? DEFAULT_ORB_COLORS;
  const clampedRecovery = Math.max(0, Math.min(100, Math.round(recoveryScore)));
  const clampedTemp = Math.max(0, Math.min(100, Math.round(emotionalTemperature)));

  const sub =
    description ??
    '관계에서 반복되는 감정의 온도입니다. 숫자보다 패턴을 먼저 살펴보세요.';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
        }}
      >
        {/* Left column: text */}
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <Kicker>EX-LOVER ANALYSIS</Kicker>
          <AppText variant="heading2" color={fillColor}>
            {emotionLabel}
          </AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {sub}
          </AppText>
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textTertiary}
          >
            감정 온도 {clampedTemp}°
          </AppText>
        </View>

        {/* Center: thermometer with orbs */}
        <Thermometer
          temperature={clampedTemp}
          fillColor={fillColor}
          orbColors={orbs}
        />

        {/* Right column: ScoreDial */}
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            gap: fortuneTheme.spacing.xs,
          }}
        >
          <ScoreDial
            score={clampedRecovery}
            color={fortuneTheme.colors.accentSecondary}
            progress={1}
            size={72}
          />
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textTertiary}
          >
            회복도
          </AppText>
        </View>
      </View>
    </Card>
  );
}

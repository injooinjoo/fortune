// HeroBirthstone: signature Ondo hero for the Birthstone result screen.
// Centered 💎 emoji wrapped in a concentric glow (soft outer halo + inner tinted
// disc) paired with a ScoreDial showing resonance/energy score. Below the gem,
// Kicker "탄생석" + Title (month name) + Sub (short description).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroBirthstoneProps {
  monthLabel: string;
  stoneName: string;
  description?: string;
  resonanceScore: number;
  /** Hex color of the gem — used for glow/accent tint. */
  gemColor?: string;
}

const OUTER_GLOW = 140;
const INNER_DISC = 108;
const GEM_SIZE = 68;

export default function HeroBirthstone({
  monthLabel,
  stoneName,
  description,
  resonanceScore,
  gemColor,
}: HeroBirthstoneProps) {
  const accent = gemColor ?? fortuneTheme.colors.accentSecondary;
  const clampedScore = Math.max(0, Math.min(100, Math.round(resonanceScore)));

  const sub =
    description ??
    `${stoneName}의 기운으로 읽는 오늘의 탄생석 인사이트입니다.`;

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
        alignItems: 'center',
        paddingVertical: fortuneTheme.spacing.lg,
      }}
    >
      {/* Gem visual: outer glow + inner tinted disc + centered emoji */}
      <View
        style={{
          width: OUTER_GLOW,
          height: OUTER_GLOW,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {/* Outer halo — soft border ring with shadow */}
        <View
          style={{
            position: 'absolute',
            width: OUTER_GLOW,
            height: OUTER_GLOW,
            borderRadius: OUTER_GLOW / 2,
            borderWidth: 1,
            borderColor: withAlpha(accent, 0.25),
            backgroundColor: withAlpha(accent, 0.08),
            shadowColor: accent,
            shadowOffset: { width: 0, height: 0 },
            shadowOpacity: 0.4,
            shadowRadius: 24,
            elevation: 6,
          }}
        />

        {/* Inner glow disc */}
        <View
          style={{
            position: 'absolute',
            width: INNER_DISC,
            height: INNER_DISC,
            borderRadius: INNER_DISC / 2,
            backgroundColor: withAlpha(accent, 0.2),
            borderWidth: 1,
            borderColor: withAlpha(accent, 0.35),
            alignItems: 'center',
            justifyContent: 'center',
          }}
        />

        {/* Centered gem emoji */}
        <AppText style={{ fontSize: GEM_SIZE, lineHeight: GEM_SIZE + 4 }}>
          💎
        </AppText>
      </View>

      {/* Text block + ScoreDial aside */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
          alignSelf: 'stretch',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <Kicker color={accent}>탄생석 · {monthLabel}</Kicker>
          <AppText variant="heading2">{stoneName}</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {sub}
          </AppText>
        </View>

        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            gap: fortuneTheme.spacing.xs,
          }}
        >
          <ScoreDial
            score={clampedScore}
            color={accent}
            progress={1}
            size={72}
          />
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textTertiary}
          >
            공명
          </AppText>
        </View>
      </View>
    </Card>
  );
}

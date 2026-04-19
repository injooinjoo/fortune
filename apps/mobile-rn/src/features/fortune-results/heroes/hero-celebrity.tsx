// HeroCelebrity: port of result-cards.jsx HeroCeleb (~526-544). Two circular avatar orbs
// (user + celebrity) with a heart glyph between them, a Kicker/title/sub stack below,
// and a ScoreDial on the right showing the compatibility score.
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroCelebrityProps {
  celebName: string;
  userLabel?: string;
  compatibilityScore: number;
  gradeLabel?: string;
  description?: string;
  leftColor?: string;
  rightColor?: string;
}

const ORB_RADIUS = 44;

function Orb({ color, label }: { color: string; label: string }) {
  return (
    <View style={{ alignItems: 'center', gap: 6 }}>
      <View
        style={{
          width: ORB_RADIUS * 2,
          height: ORB_RADIUS * 2,
          borderRadius: ORB_RADIUS,
          backgroundColor: withAlpha(color, 0.25),
          borderWidth: 1,
          borderColor: withAlpha(color, 0.6),
          shadowColor: color,
          shadowOpacity: 0.5,
          shadowRadius: 14,
          shadowOffset: { width: 0, height: 0 },
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {/* Inner highlight for silhouette feel */}
        <View
          style={{
            width: ORB_RADIUS * 1.2,
            height: ORB_RADIUS * 1.2,
            borderRadius: ORB_RADIUS,
            backgroundColor: withAlpha(color, 0.35),
            opacity: 0.6,
            position: 'absolute',
            top: ORB_RADIUS * 0.25,
            left: ORB_RADIUS * 0.3,
          }}
        />
      </View>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.textSecondary}
        style={{ textAlign: 'center', maxWidth: ORB_RADIUS * 2 + 8 }}
      >
        {label}
      </AppText>
    </View>
  );
}

export default function HeroCelebrity({
  celebName,
  userLabel = '당신',
  compatibilityScore,
  gradeLabel,
  description,
  leftColor,
  rightColor,
}: HeroCelebrityProps) {
  const resolvedLeft = leftColor ?? fortuneTheme.colors.ctaBackground;
  const resolvedRight = rightColor ?? fortuneTheme.colors.accentSecondary;

  return (
    <View
      style={{
        gap: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
      }}
    >
      {/* Orbs + heart */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 14,
        }}
      >
        <Orb color={resolvedLeft} label={userLabel} />
        <AppText
          variant="displaySmall"
          color={fortuneTheme.colors.accentSecondary}
          style={{ marginBottom: 20 }}
        >
          ♥
        </AppText>
        <Orb color={resolvedRight} label={celebName} />
      </View>

      {/* Kicker + title + sub + score dial */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: fortuneTheme.spacing.md,
          paddingHorizontal: fortuneTheme.spacing.xs,
        }}
      >
        <View style={{ flex: 1, gap: 4 }}>
          <Kicker>CELEBRITY CHEMISTRY</Kicker>
          <AppText variant="heading2">{celebName}</AppText>
          {gradeLabel ? (
            <AppText
              variant="labelLarge"
              color={fortuneTheme.colors.accentSecondary}
            >
              {gradeLabel}
            </AppText>
          ) : null}
          {description ? (
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              {description}
            </AppText>
          ) : null}
        </View>
        <ScoreDial
          score={Math.max(0, Math.min(100, compatibilityScore))}
          color={resolvedRight}
          progress={1}
          size={76}
        />
      </View>
    </View>
  );
}

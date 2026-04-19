// HeroFace: port of result-cards.jsx HeroFace (~449-470). Centered face outline with three
// horizontal zones (상정/중정/하정) tinted wood/amber/earth. Pure View geometry — no
// react-native-svg; the face is an ellipse-like rounded View and zones are overlaid bands
// clipped by the outer View's rounded border.
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

import { Kicker } from '../primitives';

interface HeroFaceProps {
  overallImpression: string;
  topZoneLabel?: string;
  midZoneLabel?: string;
  bottomZoneLabel?: string;
  description?: string;
  topScore?: number;
  midScore?: number;
  bottomScore?: number;
}

const FACE_WIDTH = 140;
const FACE_HEIGHT = 196;
const ZONE_HEIGHT = FACE_HEIGHT / 3;

function Zone({
  color,
  label,
  score,
  top,
  glyph,
}: {
  color: string;
  label: string;
  score?: number;
  top: number;
  glyph: string;
}) {
  return (
    <View
      style={{
        position: 'absolute',
        top,
        left: 0,
        right: 0,
        height: ZONE_HEIGHT,
        backgroundColor: withAlpha(color, 0.22),
        borderTopWidth: 0.5,
        borderBottomWidth: 0.5,
        borderColor: withAlpha(color, 0.4),
        alignItems: 'center',
        justifyContent: 'center',
        gap: 2,
      }}
    >
      <AppText
        variant="heading3"
        color={withAlpha(color, 0.9)}
        style={{ fontFamily: 'ZenSerif' }}
      >
        {glyph}
      </AppText>
      <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
        {label}
        {typeof score === 'number' ? ` · ${Math.round(score)}` : ''}
      </AppText>
    </View>
  );
}

export default function HeroFace({
  overallImpression,
  topZoneLabel = '상정',
  midZoneLabel = '중정',
  bottomZoneLabel = '하정',
  description,
  topScore,
  midScore,
  bottomScore,
}: HeroFaceProps) {
  // Ondo palette mapping: wood (success/green) → amber (accentTertiary) → earth (accentSecondary).
  const topColor = fortuneTheme.colors.success;
  const midColor = fortuneTheme.colors.accentTertiary;
  const bottomColor = fortuneTheme.colors.accentSecondary;

  return (
    <View
      style={{
        gap: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
      }}
    >
      {/* Face outline with 三停 zones */}
      <View style={{ alignItems: 'center' }}>
        <View
          style={{
            width: FACE_WIDTH,
            height: FACE_HEIGHT,
            borderRadius: FACE_WIDTH * 0.5,
            borderWidth: 1.5,
            borderColor: withAlpha(fortuneTheme.colors.textSecondary, 0.5),
            overflow: 'hidden',
            backgroundColor: withAlpha(
              fortuneTheme.colors.backgroundTertiary,
              0.4,
            ),
          }}
        >
          <Zone
            color={topColor}
            label={topZoneLabel}
            score={topScore}
            top={0}
            glyph="上"
          />
          <Zone
            color={midColor}
            label={midZoneLabel}
            score={midScore}
            top={ZONE_HEIGHT}
            glyph="中"
          />
          <Zone
            color={bottomColor}
            label={bottomZoneLabel}
            score={bottomScore}
            top={ZONE_HEIGHT * 2}
            glyph="下"
          />
        </View>
      </View>

      {/* Kicker + title + sub */}
      <View
        style={{
          gap: 4,
          alignItems: 'center',
          paddingHorizontal: fortuneTheme.spacing.xs,
        }}
      >
        <Kicker>FACE READING</Kicker>
        <AppText variant="heading2" style={{ textAlign: 'center' }}>
          {overallImpression}
        </AppText>
        {description ? (
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center' }}
          >
            {description}
          </AppText>
        ) : null}
      </View>
    </View>
  );
}

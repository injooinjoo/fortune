// HeroDecision: signature Ondo hero for the Decision result screen.
// Tilting balance scale — horizontal bar rotated based on recommendation
// (A/B/neutral), with labeled plates on either side + center stand. Right:
// ScoreDial showing recommendation strength. No SVG — composed from Views
// with `transform: rotate(deg)`. Ported from result-cards.jsx HeroDecision.
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroDecisionProps {
  question: string;
  optionAlabel: string;
  optionBlabel: string;
  recommendation: 'A' | 'B' | 'neutral';
  strengthScore: number;
  description?: string;
}

const BAR_WIDTH = 180;
const PLATE_WIDTH = 58;
const PLATE_HEIGHT = 28;

function Plate({
  label,
  accent,
  highlighted,
}: {
  label: string;
  accent: string;
  highlighted: boolean;
}) {
  return (
    <View
      style={{
        width: PLATE_WIDTH,
        height: PLATE_HEIGHT,
        borderRadius: fortuneTheme.radius.sm,
        backgroundColor: highlighted ? accent : withAlpha(accent, 0.4),
        alignItems: 'center',
        justifyContent: 'center',
        borderWidth: 1,
        borderColor: withAlpha(accent, 0.6),
      }}
    >
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.background}
        style={{ fontWeight: '700' }}
      >
        {label}
      </AppText>
    </View>
  );
}

function BalanceScale({ recommendation }: { recommendation: 'A' | 'B' | 'neutral' }) {
  const tilt = recommendation === 'A' ? -8 : recommendation === 'B' ? 8 : 0;
  const colorA = fortuneTheme.colors.accentSecondary;
  const colorB = fortuneTheme.colors.accentTertiary;
  const axis = fortuneTheme.colors.textSecondary;

  return (
    <View style={{ width: BAR_WIDTH, height: 80, alignItems: 'center' }}>
      {/* Tilting bar group with plates */}
      <View
        style={{
          width: BAR_WIDTH,
          height: PLATE_HEIGHT + 6,
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'space-between',
          transform: [{ rotate: `${tilt}deg` }],
        }}
      >
        <Plate label="A" accent={colorA} highlighted={recommendation === 'A'} />
        <View
          style={{
            flex: 1,
            height: 2,
            backgroundColor: axis,
            marginHorizontal: 4,
          }}
        />
        <Plate label="B" accent={colorB} highlighted={recommendation === 'B'} />
      </View>

      {/* Stand column */}
      <View
        style={{
          width: 2,
          height: 36,
          backgroundColor: axis,
        }}
      />

      {/* Triangular base */}
      <View
        style={{
          width: 36,
          height: 4,
          borderRadius: 2,
          backgroundColor: axis,
        }}
      />
    </View>
  );
}

export default function HeroDecision({
  question,
  optionAlabel,
  optionBlabel,
  recommendation,
  strengthScore,
  description,
}: HeroDecisionProps) {
  const clamped = Math.max(0, Math.min(100, Math.round(strengthScore)));
  const sub =
    description ??
    '균형추의 기울기와 강도를 함께 보면 더 정확한 판단이 됩니다.';

  const choiceLabel =
    recommendation === 'A'
      ? optionAlabel
      : recommendation === 'B'
        ? optionBlabel
        : '균형';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <View style={{ alignItems: 'center', paddingVertical: fortuneTheme.spacing.sm }}>
        <BalanceScale recommendation={recommendation} />
      </View>

      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <Kicker>DECISION</Kicker>
          <AppText variant="heading3" numberOfLines={3}>
            {question}
          </AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            추천: {choiceLabel}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
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
            score={clamped}
            color={fortuneTheme.colors.ctaBackground}
            progress={1}
            size={72}
          />
          <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
            확신도
          </AppText>
        </View>
      </View>
    </Card>
  );
}

// HeroLucky: signature Ondo hero for the Lucky Items result screen.
// 3x2 grid of 6 colored tiles (emoji + label) rotating through brand tones,
// with Kicker + Title + Sub on the left and a compact ScoreDial on the right.
// Ported from result-cards.jsx HeroLucky (grid of 6 slots with swatches).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroLuckyProps {
  items: Array<{ emoji: string; label: string }>; // up to 6
  luckyScore: number;
  description?: string;
}

const MAX_TILES = 6;

// 6 brand tones rotated across the grid. Kept as an ordered array so the
// i-th tile always maps to the same color regardless of item count.
function tileColors(): string[] {
  return [
    fortuneTheme.colors.ctaBackground,
    fortuneTheme.colors.accentSecondary,
    fortuneTheme.colors.accentTertiary,
    fortuneTheme.colors.success,
    fortuneTheme.colors.warning,
    fortuneTheme.colors.elemental.fire,
  ];
}

function LuckyTile({
  emoji,
  label,
  color,
}: {
  emoji: string;
  label: string;
  color: string;
}) {
  return (
    <View
      style={{
        flexBasis: '31%',
        flexGrow: 1,
        aspectRatio: 1,
        backgroundColor: withAlpha(color, 0.12),
        borderRadius: fortuneTheme.radius.lg,
        borderWidth: 1,
        borderColor: withAlpha(color, 0.4),
        padding: fortuneTheme.spacing.sm,
        alignItems: 'center',
        justifyContent: 'center',
        gap: fortuneTheme.spacing.xs,
      }}
    >
      {/* Emoji needs an inline fontSize — AppText variants are glyph-size tuned for text,
          not for oversized emoji rendering. */}
      <AppText style={{ fontSize: 28 }}>{emoji}</AppText>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.textSecondary}
        style={{ textAlign: 'center' }}
      >
        {label}
      </AppText>
    </View>
  );
}

export default function HeroLucky({
  items,
  luckyScore,
  description,
}: HeroLuckyProps) {
  const tiles = items.slice(0, MAX_TILES);
  const colors = tileColors();
  const sub =
    description ??
    '오늘 하루, 당신과 결이 잘 맞는 행운 아이템들이에요.';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      {/* Header row: left text column + right ScoreDial */}
      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'flex-start',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.sm }}>
          <AppText style={{ fontSize: 40 }}>🍀</AppText>
          <Kicker>LUCKY ITEMS</Kicker>
          <AppText variant="heading2">오늘의 행운 아이템</AppText>
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
            score={Math.max(0, Math.min(100, Math.round(luckyScore)))}
            color={fortuneTheme.colors.ctaBackground}
            progress={1}
            size={72}
          />
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textTertiary}
          >
            행운지수
          </AppText>
        </View>
      </View>

      {/* 3x2 tile grid */}
      {tiles.length > 0 ? (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          {tiles.map((item, i) => (
            <LuckyTile
              key={`${item.label}-${i}`}
              emoji={item.emoji}
              label={item.label}
              color={colors[i % colors.length]!}
            />
          ))}
        </View>
      ) : null}
    </Card>
  );
}

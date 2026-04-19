// HeroNaming: signature Ondo hero for the Naming result screen.
// Left column: 👶 emoji + Kicker "아기 이름 추천" + Title + Sub description.
// Right column: ScoreDial (size 72) showing top recommended name's totalScore.
// Below: horizontal row of 5 mini ohaeng bars (木/火/土/金/水) using
// fortuneTheme.colors.elemental.* tokens, with missing elements dimmed.
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

type OhaengKey = '木' | '火' | '土' | '金' | '水';

interface HeroNamingProps {
  topScore: number;
  recommendedCount: number;
  distribution: Record<OhaengKey, number>;
  missing: string[];
  description?: string;
}

const OHAENG_KEYS: OhaengKey[] = ['木', '火', '土', '金', '水'];

const OHAENG_COLOR: Record<OhaengKey, string> = {
  木: fortuneTheme.colors.elemental.wood,
  火: fortuneTheme.colors.elemental.fire,
  土: fortuneTheme.colors.elemental.earth,
  金: fortuneTheme.colors.elemental.metal,
  水: fortuneTheme.colors.elemental.water,
};

const BAR_TRACK_HEIGHT = 56;

export default function HeroNaming({
  topScore,
  recommendedCount,
  distribution,
  missing,
  description,
}: HeroNamingProps) {
  const clampedTop = Math.max(0, Math.min(100, Math.round(topScore)));

  const values = OHAENG_KEYS.map((k) => Math.max(0, distribution[k] ?? 0));
  const maxValue = Math.max(...values, 1);
  const missingSet = new Set(missing);

  const sub =
    description ??
    '사주 오행을 균형 있게 맞춘 이름 후보입니다.';

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
          <AppText variant="displaySmall">👶</AppText>
          <Kicker>아기 이름 추천</Kicker>
          <AppText variant="heading2">
            {recommendedCount}개의 추천 이름
          </AppText>
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
            score={clampedTop}
            color={fortuneTheme.colors.accentSecondary}
            progress={1}
            size={72}
          />
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textTertiary}
          >
            최고점
          </AppText>
        </View>
      </View>

      {/* Ohaeng distribution bars */}
      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.xs,
          alignItems: 'flex-end',
        }}
      >
        {OHAENG_KEYS.map((key, i) => {
          const raw = values[i] ?? 0;
          const isMissing = missingSet.has(key) || raw === 0;
          const heightPct = maxValue > 0 ? (raw / maxValue) * 100 : 0;
          const barColor = OHAENG_COLOR[key];
          const fillColor = isMissing
            ? withAlpha(barColor, 0.25)
            : barColor;

          return (
            <View
              key={key}
              style={{
                flex: 1,
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                opacity: isMissing ? 0.55 : 1,
              }}
            >
              {/* Bar track */}
              <View
                style={{
                  height: BAR_TRACK_HEIGHT,
                  width: '100%',
                  justifyContent: 'flex-end',
                  backgroundColor: withAlpha(barColor, 0.08),
                  borderRadius: fortuneTheme.radius.sm,
                  overflow: 'hidden',
                }}
              >
                <View
                  style={{
                    width: '100%',
                    height: `${Math.max(isMissing ? 6 : 8, heightPct)}%`,
                    backgroundColor: fillColor,
                    borderTopLeftRadius: fortuneTheme.radius.sm,
                    borderTopRightRadius: fortuneTheme.radius.sm,
                  }}
                />
              </View>

              {/* Element label */}
              <AppText
                variant="labelMedium"
                color={
                  isMissing
                    ? fortuneTheme.colors.textTertiary
                    : barColor
                }
              >
                {key}
              </AppText>

              {/* Value */}
              <AppText
                variant="caption"
                color={fortuneTheme.colors.textTertiary}
              >
                {raw}
              </AppText>
            </View>
          );
        })}
      </View>
    </Card>
  );
}

// HeroDailyReview: signature Ondo hero for the Daily Review result screen.
// Two-column grid: "완료 (Done)" in success-tint and "남은 일 (Open)" in
// warning-tint. Each column shows a big count (displayMedium) + small label.
// Ported from result-cards.jsx HeroReview (two-column done/open list).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';

interface HeroDailyReviewProps {
  dateLabel: string;
  doneCount: number;
  openCount: number;
  description?: string;
}

function StatColumn({
  kicker,
  count,
  label,
  accent,
  prefix,
}: {
  kicker: string;
  count: number;
  label: string;
  accent: string;
  prefix: string;
}) {
  return (
    <View
      style={{
        flex: 1,
        backgroundColor: withAlpha(accent, 0.08),
        borderWidth: 1,
        borderColor: withAlpha(accent, 0.3),
        borderRadius: fortuneTheme.radius.lg,
        padding: fortuneTheme.spacing.md,
        gap: fortuneTheme.spacing.xs,
        alignItems: 'center',
      }}
    >
      <AppText
        variant="labelMedium"
        color={accent}
        style={{ letterSpacing: 1.5, fontWeight: '700' }}
      >
        {kicker}
      </AppText>
      <AppText
        variant="displayMedium"
        style={{ color: accent, fontWeight: '800' }}
      >
        {count}
      </AppText>
      <AppText
        variant="bodySmall"
        color={fortuneTheme.colors.textSecondary}
        style={{ textAlign: 'center' }}
      >
        {prefix} {label}
      </AppText>
    </View>
  );
}

export default function HeroDailyReview({
  dateLabel,
  doneCount,
  openCount,
  description,
}: HeroDailyReviewProps) {
  const sub =
    description ??
    '오늘을 정리하며, 남길 것과 넘길 것을 분리해 보세요.';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <AppText style={{ fontSize: 36 }}>📋</AppText>
        <Kicker>DAILY REVIEW</Kicker>
        <AppText variant="heading2">{dateLabel}</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {sub}
        </AppText>
      </View>

      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <StatColumn
          kicker="DONE"
          count={doneCount}
          label="끝난 일"
          accent={fortuneTheme.colors.success}
          prefix="✓"
        />
        <StatColumn
          kicker="OPEN"
          count={openCount}
          label="남은 일"
          accent={fortuneTheme.colors.warning}
          prefix="→"
        />
      </View>
    </Card>
  );
}

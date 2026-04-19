// HeroExam: signature Ondo hero for the Exam result screen.
// Left column: Kicker "EXAM FORTUNE" + Title (exam type) + Sub.
// Right column: Pencil emoji in a success-tinted glow halo and a ScoreDial.
// Below: row of stat pills with label + value. Ported from result-cards.jsx
// HeroExam (pencil + score gauge composition).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroExamProps {
  examLabel: string;
  luckScore: number;
  stats?: Array<{ label: string; value: number }>;
  description?: string;
}

const HALO_SIZE = 88;

function PencilHalo() {
  const glow = fortuneTheme.colors.success;
  return (
    <View
      style={{
        width: HALO_SIZE,
        height: HALO_SIZE,
        borderRadius: HALO_SIZE / 2,
        backgroundColor: withAlpha(glow, 0.12),
        borderWidth: 2,
        borderColor: withAlpha(glow, 0.45),
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Inner glow */}
      <View
        style={{
          position: 'absolute',
          width: HALO_SIZE * 0.72,
          height: HALO_SIZE * 0.72,
          borderRadius: (HALO_SIZE * 0.72) / 2,
          backgroundColor: withAlpha(glow, 0.18),
        }}
      />
      <AppText style={{ fontSize: 56, transform: [{ rotate: '-15deg' }] }}>
        ✏️
      </AppText>
    </View>
  );
}

function StatPill({ label, value }: { label: string; value: number }) {
  const accent = fortuneTheme.colors.accentSecondary;
  const clamped = Math.max(0, Math.min(100, Math.round(value)));
  return (
    <View
      style={{
        flex: 1,
        backgroundColor: withAlpha(accent, 0.1),
        borderWidth: 1,
        borderColor: withAlpha(accent, 0.3),
        borderRadius: fortuneTheme.radius.md,
        paddingVertical: fortuneTheme.spacing.xs,
        paddingHorizontal: fortuneTheme.spacing.sm,
        alignItems: 'center',
        gap: 2,
      }}
    >
      <AppText variant="labelMedium" color={accent} style={{ fontWeight: '700' }}>
        {clamped}
      </AppText>
      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
    </View>
  );
}

export default function HeroExam({
  examLabel,
  luckScore,
  stats,
  description,
}: HeroExamProps) {
  const clamped = Math.max(0, Math.min(100, Math.round(luckScore)));
  const sub =
    description ??
    '시험운은 실력보다 리듬 관리에서 점수 차이가 벌어지는 구간이에요.';
  const statList = (stats ?? []).slice(0, 3);

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
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <Kicker>EXAM FORTUNE</Kicker>
          <AppText variant="heading2">{examLabel}</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            {sub}
          </AppText>
        </View>

        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <PencilHalo />
        </View>
      </View>

      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
        }}
      >
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            gap: fortuneTheme.spacing.xs,
          }}
        >
          <ScoreDial
            score={clamped}
            color={fortuneTheme.colors.success}
            progress={1}
            size={72}
          />
          <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
            시험운
          </AppText>
        </View>

        {statList.length > 0 ? (
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              gap: fortuneTheme.spacing.xs,
            }}
          >
            {statList.map((s) => (
              <StatPill key={s.label} label={s.label} value={s.value} />
            ))}
          </View>
        ) : null}
      </View>
    </Card>
  );
}

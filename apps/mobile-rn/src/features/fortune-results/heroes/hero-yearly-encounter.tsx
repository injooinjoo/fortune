// HeroYearlyEncounter: signature Ondo hero for the Yearly Encounter result.
// Circular ring with 12 equally-spaced month markers; peaks rendered in
// solid ctaBackground, others outlined. Center shows the year number.
// Right aside: ScoreDial with encounter potential. Ported from
// result-cards.jsx HeroEncounter (12-month ring with peaks).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroYearlyEncounterProps {
  year: number;
  peakMonths: number[];
  encounterScore: number;
  description?: string;
}

const RING_SIZE = 200;
const RING_RADIUS = RING_SIZE / 2 - 18;
const MARKER_SIZE = 26;

function MonthMarker({
  monthIndex,
  isPeak,
}: {
  monthIndex: number;
  isPeak: boolean;
}) {
  // i=0 at top (-90deg), 30deg steps clockwise.
  const angle = ((monthIndex * 30 - 90) * Math.PI) / 180;
  const cx = RING_SIZE / 2 + RING_RADIUS * Math.cos(angle) - MARKER_SIZE / 2;
  const cy = RING_SIZE / 2 + RING_RADIUS * Math.sin(angle) - MARKER_SIZE / 2;

  const peakColor = fortuneTheme.colors.ctaBackground;
  const idleColor = fortuneTheme.colors.textTertiary;

  return (
    <View
      style={{
        position: 'absolute',
        left: cx,
        top: cy,
        width: MARKER_SIZE,
        height: MARKER_SIZE,
        borderRadius: MARKER_SIZE / 2,
        backgroundColor: isPeak ? peakColor : 'transparent',
        borderWidth: 1,
        borderColor: isPeak ? peakColor : withAlpha(idleColor, 0.4),
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <AppText
        variant="caption"
        color={
          isPeak ? fortuneTheme.colors.background : fortuneTheme.colors.textSecondary
        }
        style={{ fontWeight: isPeak ? '800' : '500' }}
      >
        {monthIndex + 1}
      </AppText>
    </View>
  );
}

function EncounterRing({
  year,
  peakSet,
}: {
  year: number;
  peakSet: Set<number>;
}) {
  return (
    <View
      style={{
        width: RING_SIZE,
        height: RING_SIZE,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Ring background */}
      <View
        style={{
          position: 'absolute',
          width: RING_SIZE - MARKER_SIZE,
          height: RING_SIZE - MARKER_SIZE,
          borderRadius: (RING_SIZE - MARKER_SIZE) / 2,
          borderWidth: 1,
          borderColor: fortuneTheme.colors.borderOpaque,
        }}
      />

      {/* 12 markers */}
      {Array.from({ length: 12 }).map((_, i) => (
        <MonthMarker key={i} monthIndex={i} isPeak={peakSet.has(i + 1)} />
      ))}

      {/* Center year */}
      <View style={{ alignItems: 'center' }}>
        <Kicker>YEARLY ENCOUNTER</Kicker>
        <AppText variant="heading2">{year}</AppText>
      </View>
    </View>
  );
}

export default function HeroYearlyEncounter({
  year,
  peakMonths,
  encounterScore,
  description,
}: HeroYearlyEncounterProps) {
  const peakSet = new Set(peakMonths.filter((m) => m >= 1 && m <= 12));
  const clamped = Math.max(0, Math.min(100, Math.round(encounterScore)));
  const firstPeak = peakMonths.find((m) => m >= 1 && m <= 12);
  const title = firstPeak
    ? `${firstPeak}월에 최고의 만남`
    : '올해의 인연 흐름';
  const sub =
    description ??
    '12개월의 흐름 속에서 인연이 가장 선명하게 드러나는 달을 표시했어요.';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <View style={{ alignItems: 'center', paddingVertical: fortuneTheme.spacing.sm }}>
        <EncounterRing year={year} peakSet={peakSet} />
      </View>

      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <AppText variant="heading3">{title}</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
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
            인연지수
          </AppText>
        </View>
      </View>
    </Card>
  );
}

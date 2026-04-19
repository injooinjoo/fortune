// HeroMoving: signature Ondo hero for the Moving result screen.
// A compass rose — circular View with 4 cardinal direction markers (북/동/남/서)
// at the edges and a needle (rotated triangular View) pointing toward the
// lucky direction. No SVG — the needle is a pair of stacked colored Views
// rotated via `transform: rotate(deg)`.
// Ported from result-cards.jsx HeroMoving (8-dir compass with needle).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroMovingProps {
  luckyDirection: string; // e.g., '동남쪽'
  directionDegrees?: number; // 0=N, 90=E, 180=S, 270=W
  harmonyScore: number;
  description?: string;
}

const DIAL_SIZE = 170;
const NEEDLE_LEN = DIAL_SIZE * 0.4;
const NEEDLE_W = 6;

const CARDINALS: Array<{
  label: string;
  style: { top?: number; bottom?: number; left?: number; right?: number };
}> = [
  { label: '북', style: { top: 8, left: 0, right: 0 } },
  { label: '남', style: { bottom: 8, left: 0, right: 0 } },
  { label: '동', style: { top: 0, bottom: 0, right: 10 } },
  { label: '서', style: { top: 0, bottom: 0, left: 10 } },
];

function CompassDial({ degrees }: { degrees: number }) {
  const accent = fortuneTheme.colors.accentTertiary;
  return (
    <View
      style={{
        width: DIAL_SIZE,
        height: DIAL_SIZE,
        borderRadius: DIAL_SIZE / 2,
        borderWidth: 2,
        borderColor: withAlpha(accent, 0.6),
        backgroundColor: withAlpha(accent, 0.06),
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative',
      }}
    >
      {/* Inner track */}
      <View
        style={{
          position: 'absolute',
          width: DIAL_SIZE * 0.78,
          height: DIAL_SIZE * 0.78,
          borderRadius: DIAL_SIZE * 0.39,
          borderWidth: 1,
          borderColor: withAlpha(accent, 0.3),
        }}
      />

      {/* Cardinal markers — absolute positioned around the edge */}
      {CARDINALS.map((c) => (
        <View
          key={c.label}
          style={{
            position: 'absolute',
            alignItems: 'center',
            justifyContent: 'center',
            ...c.style,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
            {c.label}
          </AppText>
        </View>
      ))}

      {/* Needle group — rotated by `degrees`, anchored at the center pivot. */}
      <View
        style={{
          position: 'absolute',
          width: NEEDLE_W,
          height: NEEDLE_LEN * 2,
          alignItems: 'center',
          justifyContent: 'center',
          transform: [{ rotate: `${degrees}deg` }],
        }}
      >
        {/* Lucky tip (colored) */}
        <View
          style={{
            position: 'absolute',
            top: 0,
            width: NEEDLE_W,
            height: NEEDLE_LEN,
            backgroundColor: fortuneTheme.colors.ctaBackground,
            borderTopLeftRadius: NEEDLE_W / 2,
            borderTopRightRadius: NEEDLE_W / 2,
          }}
        />
        {/* Tail (neutral) */}
        <View
          style={{
            position: 'absolute',
            bottom: 0,
            width: NEEDLE_W,
            height: NEEDLE_LEN,
            backgroundColor: withAlpha(fortuneTheme.colors.textTertiary, 0.6),
            borderBottomLeftRadius: NEEDLE_W / 2,
            borderBottomRightRadius: NEEDLE_W / 2,
          }}
        />
      </View>

      {/* Center pivot */}
      <View
        style={{
          width: 14,
          height: 14,
          borderRadius: 7,
          backgroundColor: accent,
          borderWidth: 2,
          borderColor: fortuneTheme.colors.backgroundTertiary,
        }}
      />
    </View>
  );
}

export default function HeroMoving({
  luckyDirection,
  directionDegrees = 135,
  harmonyScore,
  description,
}: HeroMovingProps) {
  const clamped = Math.max(0, Math.min(100, Math.round(harmonyScore)));
  const sub =
    description ??
    '풍수 방위를 바탕으로 당신에게 가장 잘 맞는 이동 방향이에요.';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <View
        style={{
          alignItems: 'center',
          justifyContent: 'center',
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <CompassDial degrees={directionDegrees} />
      </View>

      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <Kicker>방위</Kicker>
          <AppText variant="heading2">{luckyDirection} 방향이 좋아요</AppText>
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
            score={clamped}
            color={fortuneTheme.colors.accentTertiary}
            progress={1}
            size={72}
          />
          <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
            방위궁합
          </AppText>
        </View>
      </View>
    </Card>
  );
}

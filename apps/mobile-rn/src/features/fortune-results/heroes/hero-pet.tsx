// HeroPet: signature Ondo hero for the Pet Compatibility result screen.
// Two overlapping circles — user emoji on the left, pet emoji on the right —
// collide at ~20% overlap to convey the owner-pet bond. Kicker + Title + Sub
// sit below, with a ScoreDial on the right showing bond score.
// Ported from result-cards.jsx HeroPet (animal + heart sparkle).
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { Kicker } from '../primitives';
import { ScoreDial } from '../primitives/score-dial';

interface HeroPetProps {
  petType: string; // e.g., '강아지', '고양이'
  petEmoji: string; // 🐕, 🐈 etc.
  userEmoji?: string; // defaults to '👤'
  bondScore: number;
  description?: string;
}

const CIRCLE_SIZE = 100; // radius ~50
// Overlap by ~20% of diameter. Applied as a negative margin on the right circle.
const OVERLAP = Math.round(CIRCLE_SIZE * 0.2);

function BondCircle({
  emoji,
  color,
  offsetLeft,
}: {
  emoji: string;
  color: string;
  offsetLeft: number;
}) {
  return (
    <View
      style={{
        width: CIRCLE_SIZE,
        height: CIRCLE_SIZE,
        borderRadius: CIRCLE_SIZE / 2,
        backgroundColor: withAlpha(color, 0.25),
        borderWidth: 2,
        borderColor: withAlpha(color, 0.6),
        alignItems: 'center',
        justifyContent: 'center',
        marginLeft: offsetLeft,
      }}
    >
      {/* Emoji needs inline fontSize — AppText variants are tuned for text,
          not for emoji glyph sizing. */}
      <AppText style={{ fontSize: 48 }}>{emoji}</AppText>
    </View>
  );
}

export default function HeroPet({
  petType,
  petEmoji,
  userEmoji = '👤',
  bondScore,
  description,
}: HeroPetProps) {
  const clamped = Math.max(0, Math.min(100, Math.round(bondScore)));
  const sub =
    description ??
    `${petType}와(과)의 오늘 유대감을 한 눈에 확인해보세요.`;

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      {/* Top: dual-circle bond visual — centered, circles overlap ~20% */}
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <BondCircle
          emoji={userEmoji}
          color={fortuneTheme.colors.accentSecondary}
          offsetLeft={0}
        />
        <BondCircle
          emoji={petEmoji}
          color={fortuneTheme.colors.accentTertiary}
          offsetLeft={-OVERLAP}
        />
      </View>

      {/* Bottom row: left text + right ScoreDial */}
      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
          <Kicker>반려동물 궁합</Kicker>
          <AppText variant="heading2">{petType}와의 유대감</AppText>
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
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textTertiary}
          >
            유대감
          </AppText>
        </View>
      </View>
    </Card>
  );
}

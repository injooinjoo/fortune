// HeroTarot: 3D flip port of Ondo spec `HeroTarot` (result-cards.jsx L107-142).
// Implements a staggered rotateY flip (180deg → 0deg) using Animated + interpolate,
// with back/front absolute layers and `backfaceVisibility: 'hidden'` for card sides.
//
// Platform caveat: `backfaceVisibility` is reliable on iOS, and mostly behaves on
// recent Android (RN >= 0.70) but can occasionally bleed the back face through during
// mid-flip on older devices. We accept this minor fidelity loss — the animation still
// reads as a reveal/flip. No Reanimated dep added.
import { useEffect, useRef } from 'react';
import { Animated, StyleSheet, Text, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

export interface HeroTarotCard {
  name: string;
  emoji?: string;
}

interface HeroTarotProps {
  cards: Array<HeroTarotCard>;
  spreadLabel?: string;
  description?: string;
}

const CARD_W = 72;
const CARD_H = 108;
const FLIP_DURATION_MS = 700;
// Staggered windows on a shared 0→1 progress: card i flips during [i*0.18, i*0.18 + 0.55]
const STAGGER_STEP = 0.18;
const FLIP_WINDOW = 0.55;
const MAX_CARDS = 3;
const FALLBACK_EMOJI = '\u2728'; // ✨

export default function HeroTarot({
  cards,
  spreadLabel,
  description,
}: HeroTarotProps) {
  const visible = cards.slice(0, MAX_CARDS);
  const progress = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    progress.setValue(0);
    Animated.timing(progress, {
      toValue: 1,
      duration: FLIP_DURATION_MS,
      useNativeDriver: true,
    }).start();
  }, [progress, visible.length]);

  return (
    <View style={styles.root}>
      {spreadLabel ? (
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.textSecondary}
          style={styles.spreadLabel}
        >
          {spreadLabel}
        </AppText>
      ) : null}

      <View style={styles.row}>
        {visible.map((card, i) => {
          const start = i * STAGGER_STEP;
          const end = start + FLIP_WINDOW;
          // inputRange must be strictly ascending and span [0,1].
          const rotateY = progress.interpolate({
            inputRange: [0, start, end, 1],
            outputRange: ['180deg', '180deg', '0deg', '0deg'],
          });
          const opacity = progress.interpolate({
            inputRange: [0, start, end, 1],
            outputRange: [0.25, 0.5, 1, 1],
          });

          return (
            <Animated.View
              key={`${card.name}-${i}`}
              style={[
                styles.cardRoot,
                {
                  opacity,
                  transform: [{ perspective: 800 }, { rotateY }],
                },
              ]}
            >
              <CardBack />
              <CardFront emoji={card.emoji ?? FALLBACK_EMOJI} name={card.name} />
            </Animated.View>
          );
        })}
      </View>

      {description ? (
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={styles.description}
        >
          {description}
        </AppText>
      ) : null}
    </View>
  );
}

function CardBack() {
  // Subtle dashed-pattern using 3 stacked small bars — cheap stand-in for CSS
  // `repeating-linear-gradient(45deg, …)` without pulling in svg/gradient deps.
  const dashAlphas = [0.55, 0.35, 0.55];
  return (
    <View
      style={[
        styles.face,
        {
          backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.45),
          borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.65),
        },
      ]}
    >
      <View style={styles.backPatternWrap} pointerEvents="none">
        {dashAlphas.map((a, idx) => (
          <View
            key={idx}
            style={[
              styles.backDash,
              { backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, a) },
            ]}
          />
        ))}
      </View>
      <Text
        style={[
          styles.backGlyph,
          { color: withAlpha(fortuneTheme.colors.accentTertiary, 0.9) },
        ]}
      >
        {'\u2726'}
      </Text>
    </View>
  );
}

function CardFront({ emoji, name }: { emoji: string; name: string }) {
  return (
    <View
      style={[
        styles.face,
        styles.faceFront,
        {
          backgroundColor: withAlpha(fortuneTheme.colors.surfaceElevated, 0.95),
          borderColor: withAlpha(fortuneTheme.colors.accentTertiary, 0.5),
        },
      ]}
    >
      <Text style={styles.frontEmoji}>{emoji}</Text>
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textPrimary}
        numberOfLines={1}
        style={styles.frontName}
      >
        {name}
      </AppText>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    alignItems: 'center',
    paddingVertical: 18,
  },
  spreadLabel: {
    marginBottom: 10,
    letterSpacing: 1.4,
    textTransform: 'uppercase',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 12,
  },
  description: {
    marginTop: 12,
    textAlign: 'center',
    paddingHorizontal: 12,
  },
  cardRoot: {
    width: CARD_W,
    height: CARD_H,
    // Container holds two absolute faces; the Animated rotation drives the flip.
  },
  face: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: 8,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    // `backfaceVisibility: 'hidden'` — reliable on iOS; mostly okay on recent Android.
    backfaceVisibility: 'hidden',
    overflow: 'hidden',
  },
  faceFront: {
    // Front face is pre-rotated 180° so it becomes visible only after rotateY crosses 90°.
    transform: [{ rotateY: '180deg' }],
    padding: 6,
  },
  backPatternWrap: {
    position: 'absolute',
    top: 8,
    bottom: 8,
    left: 8,
    right: 8,
    justifyContent: 'space-between',
  },
  backDash: {
    height: 2,
    borderRadius: 1,
    width: '100%',
  },
  backGlyph: {
    fontSize: 22,
    lineHeight: 26,
  },
  frontEmoji: {
    fontSize: 28,
    lineHeight: 34,
    marginBottom: 4,
  },
  frontName: {
    textAlign: 'center',
  },
});

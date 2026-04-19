// Ported from story-reveals.jsx:285-355. 3 numbered capsules w/ stamp flash glow.
import { useEffect, useRef, useState } from 'react';
import {
  AccessibilityInfo,
  Animated,
  Easing,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { fortuneTheme } from '../../lib/theme';
import {
  getStoryCharacterPalette,
  type StoryCharacterPalette,
} from './character-palette';
import type { StoryRomancePilotCharacterId } from '../../lib/story-romance-pilots';
import { useStages } from './use-stages';

export interface PepCapsulesData {
  items: [string, string, string];
}

export interface PepCapsulesProps {
  character: StoryRomancePilotCharacterId;
  play: number;
  speed?: number;
  data: PepCapsulesData;
}

export function PepCapsules({
  character,
  play,
  speed = 1,
  data,
}: PepCapsulesProps) {
  const palette: StoryCharacterPalette = getStoryCharacterPalette(character);
  const s = useStages(play, [200, 300, 300, 300, 300, 400], speed);
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    let mounted = true;
    AccessibilityInfo.isReduceMotionEnabled().then((v) => {
      if (mounted) setReduceMotion(v);
    });
    return () => {
      mounted = false;
    };
  }, []);

  const effective = reduceMotion ? 99 : s;

  const stampValues = useRef([
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0),
  ]).current;

  useEffect(() => {
    if (reduceMotion) return;
    stampValues.forEach((v, i) => {
      v.setValue(0);
      Animated.sequence([
        Animated.delay((200 + 300 * (i + 1)) / speed),
        Animated.timing(v, {
          toValue: 1.2,
          duration: 200 / speed,
          easing: Easing.out(Easing.quad),
          useNativeDriver: true,
        }),
        Animated.timing(v, {
          toValue: 0,
          duration: 200 / speed,
          easing: Easing.in(Easing.quad),
          useNativeDriver: true,
        }),
      ]).start();
    });
  }, [play, reduceMotion, speed, stampValues]);

  const items = data.items.map((t, i) => ({
    n: `0${i + 1}`,
    t,
    sub: '',
  }));

  return (
    <View
      style={[
        styles.card,
        {
          backgroundColor: fortuneTheme.colors.surfaceElevated,
          borderColor: fortuneTheme.colors.border,
          opacity: effective >= 1 ? 1 : 0,
          transform: [{ translateY: effective >= 1 ? 0 : 10 }],
        },
      ]}
    >
      <Text style={[styles.eyebrow, { color: palette.color }]}>
        이번 주 · 3가지만
      </Text>
      <Text style={styles.subtitle}>다 하지 말고, 이거 셋만.</Text>
      <View style={{ gap: 8 }}>
        {items.map((it, i) => {
          const shown = effective >= 2 + i;
          return (
            <View
              key={`pep-${i}`}
              style={[
                styles.capsule,
                {
                  backgroundColor: `${palette.color}12`,
                  borderColor: `${palette.color}40`,
                  opacity: shown ? 1 : 0,
                  transform: [
                    { translateX: shown ? 0 : -12 },
                    { scale: shown ? 1 : 0.96 },
                  ],
                },
              ]}
            >
              <Text style={[styles.capsuleNumber, { color: palette.color }]}>
                {it.n}
              </Text>
              <View
                style={[
                  styles.capsuleDivider,
                  { backgroundColor: `${palette.color}40` },
                ]}
              />
              <View style={{ flex: 1 }}>
                <Text style={styles.capsuleTitle}>{it.t}</Text>
                {it.sub ? (
                  <Text style={styles.capsuleSub}>{it.sub}</Text>
                ) : null}
              </View>
              <Animated.View
                pointerEvents="none"
                style={[
                  styles.stamp,
                  {
                    backgroundColor: palette.color,
                    opacity: stampValues[i].interpolate({
                      inputRange: [0, 1.2],
                      outputRange: [0, 0.55],
                    }),
                    transform: [
                      {
                        scale: stampValues[i].interpolate({
                          inputRange: [0, 1.2],
                          outputRange: [0, 1.2],
                        }),
                      },
                    ],
                  },
                ]}
              />
            </View>
          );
        })}
      </View>
      <Text
        style={[
          styles.footNote,
          { opacity: effective >= 5 ? 1 : 0 },
        ]}
      >
        일요일에 한 번 돌아볼게 — 하나도 못 했어도 괜찮아.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: 20,
    padding: 18,
    maxWidth: 340,
    width: '100%',
  },
  eyebrow: {
    fontSize: 10,
    lineHeight: 13,
    letterSpacing: 1.4,
    fontWeight: '700',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 16,
    lineHeight: 24,
    color: fortuneTheme.colors.textSubtitle,
    marginBottom: 14,
  },
  capsule: {
    flexDirection: 'row',
    alignItems: 'stretch',
    paddingVertical: 12,
    paddingHorizontal: 14,
    borderWidth: 1,
    borderRadius: 14,
    gap: 12,
    overflow: 'hidden',
  },
  capsuleNumber: {
    fontSize: 22,
    lineHeight: 28,
    fontWeight: '800',
    letterSpacing: -0.5,
    width: 30,
    textAlign: 'center',
  },
  capsuleDivider: {
    width: 1,
  },
  capsuleTitle: {
    fontSize: 14,
    lineHeight: 18,
    fontWeight: '700',
    color: fortuneTheme.colors.textPrimary,
    letterSpacing: -0.14,
  },
  capsuleSub: {
    fontSize: 12,
    lineHeight: 18,
    color: fortuneTheme.colors.textSecondary,
    marginTop: 3,
  },
  stamp: {
    position: 'absolute',
    left: -40,
    top: '50%',
    width: 80,
    height: 80,
    borderRadius: 40,
    marginTop: -40,
  },
  footNote: {
    marginTop: 14,
    paddingTop: 14,
    borderTopWidth: 1,
    borderTopColor: fortuneTheme.colors.border,
    fontSize: 12,
    lineHeight: 19,
    color: fortuneTheme.colors.textSecondary,
  },
});

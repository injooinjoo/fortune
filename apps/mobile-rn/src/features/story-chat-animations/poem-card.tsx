// Ported from story-reveals.jsx:221-280. Line-by-line serif poem; drift particles.
// Diverges: CSS blur filter on text substituted with opacity fade (RN limitation).
import { useEffect, useMemo, useRef, useState } from 'react';
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

export interface PoemCardData {
  lines: string[];
}

export interface PoemCardProps {
  character: StoryRomancePilotCharacterId;
  play: number;
  speed?: number;
  data: PoemCardData;
}

interface Particle {
  left: number;
  top: number;
  size: number;
  delay: number;
  duration: number;
}

export function PoemCard({
  character,
  play,
  speed = 1,
  data,
}: PoemCardProps) {
  const palette: StoryCharacterPalette = getStoryCharacterPalette(character);
  const lines = data.lines;
  const steps = useMemo(
    () => [200, 500, ...lines.map(() => 380), 400],
    [lines],
  );
  const s = useStages(play, steps, speed);
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
  const signatureShown = effective >= steps.length;

  const particles = useMemo<Particle[]>(
    () =>
      Array.from({ length: 5 }).map((_, i) => ({
        left: 20 + i * 55,
        top: 30 + (i % 2 === 0 ? 20 : 60),
        size: 2 + (i % 3),
        delay: i * 400,
        duration: 3600 + i * 500,
      })),
    [],
  );

  const driftValues = useRef(
    particles.map(() => new Animated.Value(0)),
  ).current;

  useEffect(() => {
    if (reduceMotion) return;
    const loops = driftValues.map((val, i) => {
      const p = particles[i];
      val.setValue(0);
      return Animated.loop(
        Animated.sequence([
          Animated.delay(p.delay),
          Animated.timing(val, {
            toValue: 1,
            duration: p.duration,
            easing: Easing.inOut(Easing.quad),
            useNativeDriver: true,
          }),
          Animated.timing(val, {
            toValue: 0,
            duration: p.duration,
            easing: Easing.inOut(Easing.quad),
            useNativeDriver: true,
          }),
        ]),
      );
    });
    loops.forEach((loop) => loop.start());
    return () => {
      loops.forEach((loop) => loop.stop());
    };
  }, [driftValues, particles, reduceMotion]);

  return (
    <View
      style={[
        styles.card,
        {
          borderColor: `${palette.color}30`,
          opacity: effective >= 1 ? 1 : 0,
          transform: [{ translateY: effective >= 1 ? 0 : 10 }],
        },
      ]}
    >
      <Text
        style={[styles.corner, { color: palette.color }]}
      >
        {'\u27E1'}
      </Text>
      <Text
        style={[
          styles.eyebrow,
          {
            color: palette.color,
            opacity: effective >= 2 ? 1 : 0,
          },
        ]}
      >
        즉흥시 · No. 17
      </Text>

      <View style={styles.poemBody}>
        {lines.map((l, i) => {
          const shown = effective >= 2 + i + 1;
          if (l === '') {
            return <View key={`gap-${i}`} style={{ height: 8 }} />;
          }
          return (
            <Text
              key={`line-${i}`}
              style={[
                styles.line,
                {
                  opacity: shown ? 1 : 0.4,
                  transform: [{ translateY: shown ? 0 : 6 }],
                },
              ]}
            >
              {l}
            </Text>
          );
        })}
      </View>

      <Text
        style={[
          styles.signature,
          { opacity: signatureShown ? 1 : 0 },
        ]}
      >
        — 수요일 밤
      </Text>

      {/* drift particles */}
      {particles.map((p, i) => (
        <Animated.View
          key={`particle-${i}`}
          pointerEvents="none"
          style={[
            styles.particle,
            {
              left: p.left,
              top: p.top,
              width: p.size,
              height: p.size,
              borderRadius: p.size / 2,
              backgroundColor: palette.color,
              opacity: driftValues[i].interpolate({
                inputRange: [0, 0.5, 1],
                outputRange: [0.1, 0.5, 0.1],
              }),
              transform: [
                {
                  translateY: driftValues[i].interpolate({
                    inputRange: [0, 1],
                    outputRange: [0, -14],
                  }),
                },
              ],
            },
          ]}
        />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    position: 'relative',
    backgroundColor: '#1C1820',
    borderWidth: 1,
    borderRadius: 20,
    paddingVertical: 20,
    paddingHorizontal: 22,
    maxWidth: 340,
    width: '100%',
    overflow: 'hidden',
  },
  corner: {
    position: 'absolute',
    top: 12,
    right: 12,
    fontSize: 18,
    lineHeight: 20,
    opacity: 0.4,
  },
  eyebrow: {
    fontSize: 10,
    lineHeight: 13,
    letterSpacing: 1.4,
    fontWeight: '700',
    marginBottom: 14,
  },
  poemBody: {
    marginBottom: 4,
  },
  line: {
    fontSize: 15,
    lineHeight: 29,
    color: fortuneTheme.colors.textPrimary,
  },
  signature: {
    marginTop: 16,
    textAlign: 'right',
    fontSize: 11,
    lineHeight: 14,
    color: fortuneTheme.colors.textTertiary,
    letterSpacing: 0.8,
  },
  particle: {
    position: 'absolute',
  },
});

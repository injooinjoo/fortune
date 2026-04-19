// Ported from story-reveals.jsx:458-549. 2 orbs + 3 rings + sync% + tags.
// Diverges: radial gradients approximated with solid palette colors; thread is a flat line View.
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
import { useCount } from './use-count';
import { useStages } from './use-stages';

export interface ResonanceOrbsData {
  percent: number;
  userTag: string;
  charTag: string;
}

export interface ResonanceOrbsProps {
  character: StoryRomancePilotCharacterId;
  play: number;
  speed?: number;
  data: ResonanceOrbsData;
}

const USER_ORB_COLOR = '#8FB8FF';

export function ResonanceOrbs({
  character,
  play,
  speed = 1,
  data,
}: ResonanceOrbsProps) {
  const palette: StoryCharacterPalette = getStoryCharacterPalette(character);
  const s = useStages(play, [200, 600, 600, 400, 500], speed);
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
  const target = effective >= 3 ? data.percent : 0;
  const vRaw = useCount(target, play, speed, 1200);
  const v = reduceMotion ? data.percent : vRaw;

  const leftDrift = useRef(new Animated.Value(-110)).current;
  const rightDrift = useRef(new Animated.Value(110)).current;

  useEffect(() => {
    leftDrift.setValue(-110);
    rightDrift.setValue(110);
    if (reduceMotion) {
      leftDrift.setValue(-34);
      rightDrift.setValue(34);
      return;
    }
    if (effective >= 2) {
      Animated.parallel([
        Animated.timing(leftDrift, {
          toValue: -34,
          duration: 1000 / speed,
          easing: Easing.bezier(0.2, 0, 0, 1),
          useNativeDriver: true,
        }),
        Animated.timing(rightDrift, {
          toValue: 34,
          duration: 1000 / speed,
          easing: Easing.bezier(0.2, 0, 0, 1),
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [effective, leftDrift, reduceMotion, rightDrift, speed]);

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
      <Text style={[styles.eyebrow, { color: palette.color }]}>오늘 밤 공명</Text>

      <View style={styles.stage}>
        {[0, 1, 2].map((i) => (
          <View
            key={`ring-${i}`}
            style={[
              styles.ring,
              {
                width: 60 + i * 30,
                height: 60 + i * 30,
                marginLeft: -(30 + i * 15),
                marginTop: -(30 + i * 15),
                borderColor: palette.color,
                opacity: effective >= 2 ? 0.24 - i * 0.06 : 0,
                transform: [{ scale: effective >= 2 ? 1 : 0.6 }],
              },
            ]}
          />
        ))}
        <Animated.View
          style={[
            styles.orb,
            {
              backgroundColor: USER_ORB_COLOR,
              shadowColor: USER_ORB_COLOR,
              transform: [{ translateX: leftDrift }, { translateY: -26 }],
            },
          ]}
        />
        <Animated.View
          style={[
            styles.orb,
            {
              backgroundColor: palette.color,
              shadowColor: palette.color,
              transform: [{ translateX: rightDrift }, { translateY: -26 }],
            },
          ]}
        />
        <View
          style={[
            styles.thread,
            {
              width: effective >= 2 ? 44 : 0,
              opacity: effective >= 2 ? 0.6 : 0,
              backgroundColor: palette.color,
            },
          ]}
        />
      </View>

      <View
        style={[
          styles.valueBlock,
          { opacity: effective >= 3 ? 1 : 0 },
        ]}
      >
        <Text style={styles.valueNumber}>
          {Math.round(v)}
          <Text style={styles.valueUnit}>%</Text>
        </Text>
        <Text style={styles.valueCaption}>SYNC · 지난 대화 기반</Text>
      </View>

      <View
        style={[
          styles.tagCard,
          {
            backgroundColor: fortuneTheme.colors.surface,
            opacity: effective >= 4 ? 1 : 0,
            transform: [{ translateY: effective >= 4 ? 0 : 4 }],
          },
        ]}
      >
        <Text style={styles.tagText}>
          오늘 밤 —{' '}
          <Text style={{ color: palette.color }}>{data.charTag}</Text>이야.
        </Text>
        <Text style={styles.tagTextSub}>너의 결: {data.userTag}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: 20,
    padding: 20,
    maxWidth: 320,
    width: '100%',
    position: 'relative',
    overflow: 'hidden',
  },
  eyebrow: {
    fontSize: 10,
    lineHeight: 13,
    letterSpacing: 1.4,
    fontWeight: '700',
    textAlign: 'center',
  },
  stage: {
    position: 'relative',
    height: 100,
    marginTop: 10,
  },
  ring: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    borderWidth: 1,
    borderRadius: 9999,
  },
  orb: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    width: 52,
    height: 52,
    marginLeft: -26,
    borderRadius: 26,
    shadowOpacity: 0.6,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 0 },
  },
  thread: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    marginLeft: -22,
    height: 1.5,
  },
  valueBlock: {
    alignItems: 'center',
    marginTop: 6,
  },
  valueNumber: {
    fontSize: 42,
    lineHeight: 46,
    fontWeight: '800',
    color: fortuneTheme.colors.textPrimary,
    letterSpacing: -1.6,
  },
  valueUnit: {
    fontSize: 16,
    lineHeight: 20,
    color: fortuneTheme.colors.textSecondary,
  },
  valueCaption: {
    fontSize: 10,
    lineHeight: 13,
    color: fortuneTheme.colors.textTertiary,
    letterSpacing: 1.4,
    marginTop: 4,
    fontWeight: '600',
  },
  tagCard: {
    marginTop: 14,
    padding: 12,
    borderRadius: 12,
  },
  tagText: {
    fontSize: 13,
    lineHeight: 22,
    color: fortuneTheme.colors.textSubtitle,
  },
  tagTextSub: {
    fontSize: 11,
    lineHeight: 16,
    marginTop: 4,
    color: fortuneTheme.colors.textTertiary,
  },
});

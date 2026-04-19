// Ported from story-reveals.jsx:62-123. Old-message card w/ shimmer sweep + 7-day stat.
// Diverges: CSS blur filter substituted with opacity fade (RN can't blur text).
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

export interface MemoryRecallData {
  title?: string;
  quote?: string;
  daysAgo?: number;
}

export interface MemoryRecallProps {
  character: StoryRomancePilotCharacterId;
  play: number;
  speed?: number;
  data: MemoryRecallData;
}

const hexAlpha = (hex: string, alphaHex: string) => `${hex}${alphaHex}`;

export function MemoryRecall({
  character,
  play,
  speed = 1,
  data,
}: MemoryRecallProps) {
  const palette: StoryCharacterPalette = getStoryCharacterPalette(character);
  const s = useStages(play, [200, 600, 500, 600, 500], speed);
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

  // Shimmer fires ONCE when effective first enters the [2,4) window. Without
  // the started ref, each stage tick inside the window reset shimmerX and
  // restarted the animation, causing a stutter.
  const shimmerX = useRef(new Animated.Value(-1)).current;
  const shimmerStarted = useRef(false);
  useEffect(() => {
    if (reduceMotion) return;
    if (effective >= 2 && effective < 4 && !shimmerStarted.current) {
      shimmerStarted.current = true;
      Animated.timing(shimmerX, {
        toValue: 1,
        duration: 1200 / speed,
        easing: Easing.bezier(0.4, 0, 0.2, 1),
        useNativeDriver: true,
      }).start();
    }
  }, [effective, reduceMotion, shimmerX, speed]);

  const title = data.title ?? '3주 전의 너';
  const quote =
    data.quote ??
    '"요즘 진짜 별 것 아닌 것도 피곤해. 그냥 좀, 누가 가만히 옆에 있어줬으면 좋겠어."';
  const daysAgo = data.daysAgo ?? 21;

  const dateLabel = useMemo(() => {
    const d = new Date();
    d.setDate(d.getDate() - daysAgo);
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${mm}.${dd} · 밤 11:14`;
  }, [daysAgo]);

  return (
    <View
      style={[
        styles.card,
        {
          borderColor: hexAlpha(palette.color, '32'),
          backgroundColor: hexAlpha(palette.color, '14'),
          opacity: effective >= 1 ? 1 : 0,
          transform: [{ translateY: effective >= 1 ? 0 : 10 }],
        },
      ]}
    >
      <View style={styles.headerRow}>
        <View
          style={[
            styles.clockDot,
            { borderColor: palette.color, backgroundColor: 'transparent' },
          ]}
        />
        <Text
          style={[
            styles.headerLabel,
            { color: palette.color },
          ]}
        >
          {title}
        </Text>
        <Text style={styles.dateLabel}>{dateLabel}</Text>
      </View>

      <View
        style={[
          styles.quoteBox,
          {
            borderLeftColor: hexAlpha(palette.color, '80'),
            opacity: effective >= 2 ? 1 : 0.2,
            transform: [{ translateY: effective >= 2 ? 0 : 4 }],
          },
        ]}
      >
        <Text style={styles.quoteText}>{quote}</Text>
        {effective >= 2 && effective < 4 ? (
          <Animated.View
            pointerEvents="none"
            style={[
              styles.shimmer,
              {
                backgroundColor: hexAlpha(palette.color, '30'),
                transform: [
                  {
                    translateX: shimmerX.interpolate({
                      inputRange: [-1, 1],
                      outputRange: [-160, 320],
                    }),
                  },
                ],
              },
            ]}
          />
        ) : null}
      </View>

      <Text
        style={[
          styles.footNote,
          {
            opacity: effective >= 4 ? 1 : 0,
            transform: [{ translateY: effective >= 4 ? 0 : 4 }],
          } as never,
        ]}
      >
        그 밤 이후로 {daysAgo}일 — 그 사이에{' '}
        <Text style={{ color: palette.color, fontWeight: '700' }}>7번</Text>{' '}
        같이 얘기 나눴어.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: 18,
    padding: 16,
    maxWidth: 340,
    width: '100%',
    overflow: 'hidden',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
    gap: 6,
  },
  clockDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    borderWidth: 2,
  },
  headerLabel: {
    fontSize: 10,
    lineHeight: 12,
    letterSpacing: 1.4,
    fontWeight: '700',
  },
  dateLabel: {
    marginLeft: 'auto',
    fontSize: 10,
    lineHeight: 12,
    color: fortuneTheme.colors.textTertiary,
    fontStyle: 'italic',
  },
  quoteBox: {
    position: 'relative',
    paddingVertical: 12,
    paddingHorizontal: 14,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderLeftWidth: 2,
    borderTopRightRadius: 12,
    borderBottomRightRadius: 12,
    overflow: 'hidden',
  },
  quoteText: {
    fontSize: 13,
    lineHeight: 21,
    color: fortuneTheme.colors.textSubtitle,
    fontStyle: 'italic',
  },
  shimmer: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    width: 140,
  },
  footNote: {
    marginTop: 12,
    fontSize: 12,
    lineHeight: 19,
    color: fortuneTheme.colors.textSecondary,
  },
});

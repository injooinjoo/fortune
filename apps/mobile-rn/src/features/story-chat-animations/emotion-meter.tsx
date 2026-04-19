// Ported from story-reveals.jsx:128-216. Tag bars + ring gauge + count-up.
// Diverges: SVG ring approximated via layered borderColor Views (no react-native-svg).
import { useEffect, useState } from 'react';
import {
  AccessibilityInfo,
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

export interface EmotionMeterData {
  scoreLabel: string;
  percent: number;
  tags: string[];
}

export interface EmotionMeterProps {
  character: StoryRomancePilotCharacterId;
  play: number;
  speed?: number;
  data: EmotionMeterData;
}

const TAG_PERCENTS = [64, 42, 18];
const COLOR_CTA = '#8B7BE8';
const COLOR_SKY = '#8FB8FF';
const COLOR_MINT = '#9BE5B5';
const COLOR_ROSE = '#E8486B';

function toneFor(v: number): string {
  if (v >= 70) return COLOR_MINT;
  if (v >= 45) return COLOR_SKY;
  if (v >= 25) return COLOR_CTA;
  return COLOR_ROSE;
}

export function EmotionMeter({
  character,
  play,
  speed = 1,
  data,
}: EmotionMeterProps) {
  const palette: StoryCharacterPalette = getStoryCharacterPalette(character);
  // Tag rows stagger at 80/140/200ms after the header baseline (stages 5-7).
  // Per JSX spec (story-reveals.jsx:128-216) — tighter than 300ms default.
  const s = useStages(play, [200, 500, 1300, 400, 80, 60, 60], speed);
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
  const target = effective >= 2 ? data.percent : 0;
  const vRaw = useCount(target, play, speed, 1300);
  const v = reduceMotion ? data.percent : vRaw;
  const tone = toneFor(v);

  const tags = data.tags.slice(0, 3).map((k, i) => ({
    k,
    p: TAG_PERCENTS[i] ?? 30,
    c: i === 0 ? COLOR_CTA : i === 1 ? COLOR_SKY : COLOR_MINT,
  }));

  return (
    <View
      style={[
        styles.card,
        {
          opacity: effective >= 1 ? 1 : 0,
          transform: [{ translateY: effective >= 1 ? 0 : 10 }],
          borderColor: fortuneTheme.colors.border,
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
        },
      ]}
    >
      <View style={styles.row}>
        {/* Ring (approximated with a thick-bordered circle + progress overlay) */}
        <View style={styles.ringWrap}>
          <View
            style={[
              styles.ringBase,
              { borderColor: fortuneTheme.colors.border },
            ]}
          />
          {/* Progress half-rings — 4 quadrants toggled by percent bracket */}
          <View
            style={[
              styles.ringFill,
              {
                borderTopColor: v >= 1 ? tone : 'transparent',
                borderRightColor: v >= 25 ? tone : 'transparent',
                borderBottomColor: v >= 50 ? tone : 'transparent',
                borderLeftColor: v >= 75 ? tone : 'transparent',
              },
            ]}
          />
          <View style={styles.ringCenter}>
            <Text
              style={[
                styles.ringValue,
                { color: tone },
              ]}
            >
              {Math.round(v)}
            </Text>
            <Text style={styles.ringCaption}>TODAY</Text>
          </View>
        </View>

        <View style={styles.col}>
          <Text
            style={[
              styles.eyebrow,
              { color: fortuneTheme.colors.textTertiary },
            ]}
          >
            마음 날씨
          </Text>
          <Text
            style={[
              styles.toneLabel,
              {
                color: tone,
                opacity: effective >= 4 ? 1 : 0,
                transform: [{ translateY: effective >= 4 ? 0 : 4 }],
              } as never,
            ]}
          >
            {data.scoreLabel}
          </Text>
          <Text
            style={[
              styles.delta,
              {
                opacity: effective >= 4 ? 1 : 0,
              },
            ]}
          >
            어제보다 <Text style={{ color: COLOR_ROSE }}>−6</Text>
          </Text>
        </View>
      </View>

      <View style={styles.divider} />

      <Text
        style={[
          styles.tagsHeader,
          { opacity: effective >= 5 ? 1 : 0 },
        ]}
      >
        감지된 감정
      </Text>
      <View style={{ gap: 8 }}>
        {tags.map((t, i) => {
          const shown = effective >= 5 + i;
          return (
            <View
              key={t.k}
              style={[
                styles.tagRow,
                {
                  opacity: shown ? 1 : 0,
                  transform: [{ translateX: shown ? 0 : -6 }],
                },
              ]}
            >
              <Text style={styles.tagKey}>{t.k}</Text>
              <View
                style={[
                  styles.barTrack,
                  { backgroundColor: fortuneTheme.colors.surfaceSecondary },
                ]}
              >
                <View
                  style={[
                    styles.barFill,
                    {
                      backgroundColor: t.c,
                      width: shown ? `${t.p}%` : '0%',
                    },
                  ]}
                />
              </View>
              <Text style={styles.tagPercent}>{t.p}</Text>
            </View>
          );
        })}
      </View>

      {/* palette color sliver to tie the card to the character vibe */}
      <View
        style={[
          styles.paletteStrip,
          { backgroundColor: palette.color, opacity: 0.18 },
        ]}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: 20,
    padding: 18,
    maxWidth: 320,
    width: '100%',
    overflow: 'hidden',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  col: { flex: 1, minWidth: 0 },
  ringWrap: {
    position: 'relative',
    width: 96,
    height: 96,
  },
  ringBase: {
    position: 'absolute',
    inset: 0 as unknown as number,
    width: 96,
    height: 96,
    borderRadius: 48,
    borderWidth: 3,
  },
  ringFill: {
    position: 'absolute',
    width: 96,
    height: 96,
    borderRadius: 48,
    borderWidth: 3,
    transform: [{ rotate: '-45deg' }],
  },
  ringCenter: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ringValue: {
    fontSize: 32,
    lineHeight: 34,
    fontWeight: '800',
    letterSpacing: -1,
  },
  ringCaption: {
    fontSize: 9,
    lineHeight: 11,
    color: fortuneTheme.colors.textTertiary,
    marginTop: 2,
    letterSpacing: 1,
  },
  eyebrow: {
    fontSize: 10,
    lineHeight: 13,
    letterSpacing: 1.4,
    fontWeight: '700',
  },
  toneLabel: {
    fontSize: 22,
    lineHeight: 28,
    fontWeight: '700',
    marginTop: 4,
  },
  delta: {
    fontSize: 11,
    lineHeight: 14,
    color: '#34C759',
    marginTop: 3,
    fontWeight: '600',
  },
  divider: {
    marginTop: 14,
    paddingTop: 14,
    borderTopWidth: 1,
    borderTopColor: fortuneTheme.colors.border,
  },
  tagsHeader: {
    fontSize: 10,
    lineHeight: 13,
    color: fortuneTheme.colors.textTertiary,
    letterSpacing: 1,
    fontWeight: '600',
    marginBottom: 8,
  },
  tagRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  tagKey: {
    width: 44,
    fontSize: 12,
    lineHeight: 16,
    color: fortuneTheme.colors.textPrimary,
    fontWeight: '600',
  },
  barTrack: {
    flex: 1,
    height: 4,
    borderRadius: 2,
    overflow: 'hidden',
  },
  barFill: {
    height: '100%',
  },
  tagPercent: {
    fontSize: 10,
    lineHeight: 13,
    color: fortuneTheme.colors.textTertiary,
    width: 28,
    textAlign: 'right',
  },
  paletteStrip: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 2,
  },
});

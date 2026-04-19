// Ported from story-reveals.jsx:360-453. Polaroid w/ Ken-Burns + typed caption.
// Diverges: grain overlay is a flat rgba fill (no repeating-linear-gradient in RN).
import { useEffect, useRef, useState } from 'react';
import {
  AccessibilityInfo,
  Animated,
  Easing,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {
  getStoryCharacterPalette,
  type StoryCharacterPalette,
} from './character-palette';
import type { StoryRomancePilotCharacterId } from '../../lib/story-romance-pilots';
import { useStages } from './use-stages';
import { useTyped } from './use-typed';

export interface PhotoRecallData {
  dateLabel: string;
  caption: string;
}

export interface PhotoRecallProps {
  character: StoryRomancePilotCharacterId;
  play: number;
  speed?: number;
  data: PhotoRecallData;
}

export function PhotoRecall({
  character,
  play,
  speed = 1,
  data,
}: PhotoRecallProps) {
  const palette: StoryCharacterPalette = getStoryCharacterPalette(character);
  const s = useStages(play, [200, 700, 300, 200, 400], speed);
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

  // Ken-Burns zoom — fire ONCE when effective first reaches 2. Without the
  // started ref, every subsequent stage tick (3,4,5) reset the value and
  // restarted the 3.4s timing, producing a rubber-banding visual.
  const zoom = useRef(new Animated.Value(1.28)).current;
  const zoomStarted = useRef(false);
  useEffect(() => {
    if (reduceMotion) {
      zoom.setValue(1.08);
      return;
    }
    if (effective >= 2 && !zoomStarted.current) {
      zoomStarted.current = true;
      Animated.timing(zoom, {
        toValue: 1.08,
        duration: 3400 / speed,
        easing: Easing.bezier(0.3, 0, 0.3, 1),
        useNativeDriver: true,
      }).start();
    }
  }, [effective, reduceMotion, speed, zoom]);

  // Use-typed default cps (45) per design; don't override here.
  const typed = useTyped(
    data.caption,
    play,
    (200 + 700 + 300 + 200) / speed,
    speed,
  );
  const typedOut = reduceMotion ? data.caption : typed;

  return (
    <View
      style={[
        styles.card,
        {
          opacity: effective >= 1 ? 1 : 0,
          transform: [
            { rotate: effective >= 1 ? '-1.8deg' : '0deg' },
            { translateY: effective >= 1 ? 0 : 10 },
          ],
        },
      ]}
    >
      <View style={styles.photo}>
        {/* sky */}
        <View style={styles.skyLayer} />
        {/* sun */}
        <View style={styles.sun} />
        {/* horizon */}
        <View style={styles.horizon} />
        {/* ground fade */}
        <View style={styles.groundFade} />
        {/* silhouettes */}
        <View style={[styles.person, { left: '30%', width: 18, height: 32 }]} />
        <View style={[styles.person, { left: '52%', width: 16, height: 30 }]} />
        {/* Ken-Burns inner zoom layer holding grain */}
        <Animated.View
          style={[
            styles.zoomLayer,
            {
              transform: [{ scale: zoom }],
            },
          ]}
        >
          <View style={styles.grain} />
        </Animated.View>
        {/* date stamp */}
        <Text
          style={[
            styles.dateStamp,
            { color: palette.color, opacity: effective >= 3 ? 1 : 0 },
          ]}
        >
          {data.dateLabel}
        </Text>
      </View>
      <View style={styles.captionWrap}>
        <Text style={styles.caption}>
          {typedOut}
          <Text
            style={[
              styles.cursor,
              {
                opacity: typedOut.length < data.caption.length ? 1 : 0,
              },
            ]}
          >
            |
          </Text>
        </Text>
      </View>
      <Text
        style={[
          styles.byline,
          { opacity: effective >= 3 ? 1 : 0 },
        ]}
      >
        — 너와 내가 꺼낸 기억
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#F5F1E8',
    borderRadius: 6,
    paddingHorizontal: 14,
    paddingTop: 14,
    paddingBottom: 18,
    maxWidth: 260,
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.6,
    shadowRadius: 36,
    shadowOffset: { width: 0, height: 14 },
    elevation: 12,
  },
  photo: {
    width: '100%',
    aspectRatio: 1,
    backgroundColor: '#2a3548',
    position: 'relative',
    overflow: 'hidden',
  },
  skyLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#3a4b6e',
  },
  sun: {
    position: 'absolute',
    top: '22%',
    right: '18%',
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#E8A268',
    opacity: 0.9,
  },
  horizon: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: '40%',
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.2)',
  },
  groundFade: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: '60%',
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  person: {
    position: 'absolute',
    bottom: '12%',
    backgroundColor: '#0a0a15',
    borderTopLeftRadius: 14,
    borderTopRightRadius: 14,
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
  },
  zoomLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  grain: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.03)',
  },
  dateStamp: {
    position: 'absolute',
    bottom: 6,
    right: 8,
    fontSize: 9,
    lineHeight: 12,
    fontFamily: 'Courier',
  },
  captionWrap: {
    marginTop: 12,
    minHeight: 32,
  },
  caption: {
    fontSize: 13,
    lineHeight: 18,
    color: '#3a2a1a',
    fontWeight: '500',
  },
  cursor: {
    fontSize: 13,
    lineHeight: 18,
    color: '#3a2a1a',
  },
  byline: {
    marginTop: 4,
    fontSize: 10,
    lineHeight: 13,
    color: '#7a6a5a',
    letterSpacing: 0.8,
  },
});

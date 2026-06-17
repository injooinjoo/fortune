import { useEffect, useRef, useState } from 'react';
import { AccessibilityInfo, Animated, Easing, Pressable } from 'react-native';

import { AppText } from '../../../components/app-text';
import { pageSnap } from '../../../lib/haptics';
import { fortuneReadingPalette } from '../../../lib/theme';
import type { ReadingSentence } from './reading-sentences';

const ENTER_MS = 1600;
const HOLD_MS = 2600;
const EXIT_MS = 1400;

interface SentenceReadingPlayerProps {
  sentences: ReadingSentence[];
  replayKey: number;
  onComplete: () => void;
}

export function SentenceReadingPlayer({
  sentences,
  replayKey,
  onComplete,
}: SentenceReadingPlayerProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  const [reduceMotion, setReduceMotion] = useState(false);
  const opacity = useRef(new Animated.Value(0)).current;
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const completingRef = useRef(false);
  const cancelledRef = useRef(false);
  const advancingRef = useRef(false);

  useEffect(() => {
    let mounted = true;
    AccessibilityInfo.isReduceMotionEnabled().then(value => {
      if (mounted) setReduceMotion(value);
    });
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    setActiveIndex(0);
    completingRef.current = false;
  }, [replayKey]);

  useEffect(() => {
    if (!sentences.length) {
      onComplete();
      return;
    }

    clearPendingTimeout();
    advancingRef.current = false;
    cancelledRef.current = false;
    opacity.stopAnimation();
    opacity.setValue(reduceMotion ? 1 : 0);

    if (reduceMotion) {
      return cleanupPlayback;
    }

    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: ENTER_MS,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start(({ finished }) => {
      if (finished && !cancelledRef.current) {
        timeoutRef.current = setTimeout(handleAdvance, HOLD_MS);
      }
    });

    return cleanupPlayback;
    // activeIndex intentionally drives one mounted active sentence at a time.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeIndex, onComplete, opacity, reduceMotion, replayKey, sentences]);

  if (!sentences.length) return null;

  const sentence = sentences[activeIndex];
  const progress = `${activeIndex + 1} / ${sentences.length}`;
  const accessibilitySentence = `${sentence.main}${sentence.sub ? ` ${sentence.sub}` : ''}`;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`오늘의 운세 리딩 ${progress}. ${accessibilitySentence}. 탭하면 다음 문장으로 넘어갑니다.`}
      onPress={handleAdvance}
      style={{ alignItems: 'center', backgroundColor: '#000000', flex: 1, justifyContent: 'center', width: '100%' }}
    >
      <Animated.View
        style={{
          alignItems: 'center',
          gap: 18,
          maxWidth: 360,
          opacity,
          paddingHorizontal: 8,
          width: '100%',
        }}
      >
        <AppText
          variant="heading1"
          color={fortuneReadingPalette.textPrimary}
          style={{ lineHeight: 42, maxWidth: 330, textAlign: 'center' }}
        >
          {sentence.main}
        </AppText>
        {sentence.sub ? (
          <AppText
            variant="bodySmall"
            color={fortuneReadingPalette.textPrimary}
            style={{ lineHeight: 25, maxWidth: 310, opacity: 0.76, textAlign: 'center' }}
          >
            {sentence.sub}
          </AppText>
        ) : null}
      </Animated.View>
    </Pressable>
  );

  function handleAdvance() {
    if (advancingRef.current || completingRef.current) return;
    advancingRef.current = true;
    pageSnap();

    if (reduceMotion) {
      goNext();
      return;
    }

    clearPendingTimeout();
    opacity.stopAnimation();

    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 0,
        duration: EXIT_MS,
        easing: Easing.in(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start(({ finished }) => {
      if (finished && !cancelledRef.current) goNext();
    });
  }

  function goNext() {
    clearPendingTimeout();
    opacity.stopAnimation();

    if (activeIndex >= sentences.length - 1) {
      if (!completingRef.current) {
        completingRef.current = true;
        onComplete();
      }
      return;
    }

    setActiveIndex(current => Math.min(current + 1, sentences.length - 1));
  }

  function cleanupPlayback() {
    cancelledRef.current = true;
    clearPendingTimeout();
    opacity.stopAnimation();
  }

  function clearPendingTimeout() {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
  }
}

import { useEffect, useRef, useState } from 'react';
import { AccessibilityInfo, Animated, Easing, Pressable } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';
import type { ReadingSentence } from './reading-sentences';

const ENTER_MS = 320;
const EXIT_MS = 260;
const BASE_HOLD_MS = 1800;
const LONG_HOLD_MS = 2500;

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
  const translateY = useRef(new Animated.Value(10)).current;
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const completingRef = useRef(false);
  const cancelledRef = useRef(false);

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
    cancelledRef.current = false;
    opacity.stopAnimation();
    translateY.stopAnimation();
    opacity.setValue(reduceMotion ? 1 : 0);
    translateY.setValue(reduceMotion ? 0 : 10);

    const activeSentence = sentences[activeIndex];
    if (reduceMotion) {
      timeoutRef.current = setTimeout(() => {
        if (!cancelledRef.current) goNext();
      }, holdDuration(activeSentence));
      return cleanupPlayback;
    }

    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: ENTER_MS,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(translateY, {
        toValue: 0,
        duration: ENTER_MS,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start(({ finished }) => {
      if (!finished || cancelledRef.current) return;
      timeoutRef.current = setTimeout(() => {
        if (cancelledRef.current) return;
        Animated.parallel([
          Animated.timing(opacity, {
            toValue: 0,
            duration: EXIT_MS,
            easing: Easing.in(Easing.cubic),
            useNativeDriver: true,
          }),
          Animated.timing(translateY, {
            toValue: -8,
            duration: EXIT_MS,
            easing: Easing.in(Easing.cubic),
            useNativeDriver: true,
          }),
        ]).start(({ finished: exitFinished }) => {
          if (exitFinished && !cancelledRef.current) goNext();
        });
      }, holdDuration(activeSentence));
    });

    return cleanupPlayback;
    // activeIndex intentionally drives one mounted active sentence at a time.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeIndex, onComplete, opacity, reduceMotion, replayKey, sentences, translateY]);

  if (!sentences.length) return null;

  const sentence = sentences[activeIndex];
  const progress = `${activeIndex + 1} / ${sentences.length}`;
  const accessibilitySentence = `${sentence.main}${sentence.sub ? ` ${sentence.sub}` : ''}`;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`운세 리딩 ${progress}. ${accessibilitySentence}. 탭하면 다음 문장으로 넘어갑니다.`}
      onPress={goNext}
      style={{ alignItems: 'center', flex: 1, justifyContent: 'center', width: '100%' }}
    >
      <Animated.View
        style={{
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
          opacity,
          transform: [{ translateY }],
          width: '100%',
        }}
      >
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          {progress}
        </AppText>
        <AppText
          variant="calligraphyTitle"
          style={{ maxWidth: 320, textAlign: 'center' }}
        >
          {sentence.main}
        </AppText>
        {sentence.sub ? (
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ maxWidth: 300, textAlign: 'center' }}
          >
            {sentence.sub}
          </AppText>
        ) : null}
      </Animated.View>
    </Pressable>
  );

  function goNext() {
    clearPendingTimeout();
    opacity.stopAnimation();
    translateY.stopAnimation();

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
    translateY.stopAnimation();
  }

  function clearPendingTimeout() {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
  }
}

function holdDuration(sentence: ReadingSentence): number {
  return sentence.main.length > 28 ? LONG_HOLD_MS : BASE_HOLD_MS;
}

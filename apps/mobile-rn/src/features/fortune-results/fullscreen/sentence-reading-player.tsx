import { useEffect, useRef, useState } from 'react';
import { AccessibilityInfo, Animated, Easing, Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { pageSnap } from '../../../lib/haptics';
import { fortuneReadingPalette, fortuneTheme, withAlpha } from '../../../lib/theme';
import type { ReadingSentence, ReadingSentenceSource } from './reading-sentences';

const ENTER_MS = 360;
const EXIT_MS = 220;

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
  const translateY = useRef(new Animated.Value(12)).current;
  const scale = useRef(new Animated.Value(0.98)).current;
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
    translateY.stopAnimation();
    scale.stopAnimation();
    opacity.setValue(reduceMotion ? 1 : 0);
    translateY.setValue(reduceMotion ? 0 : 12);
    scale.setValue(reduceMotion ? 1 : 0.98);

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
      Animated.timing(translateY, {
        toValue: 0,
        duration: ENTER_MS,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(scale, {
        toValue: 1,
        duration: ENTER_MS,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start();

    return cleanupPlayback;
    // activeIndex intentionally drives one mounted active sentence at a time.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeIndex, onComplete, opacity, reduceMotion, replayKey, scale, sentences, translateY]);

  if (!sentences.length) return null;

  const sentence = sentences[activeIndex];
  const progress = `${activeIndex + 1} / ${sentences.length}`;
  const accessibilitySentence = `${sentence.main}${sentence.sub ? ` ${sentence.sub}` : ''}`;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`오늘의 운세 리딩 ${progress}. ${accessibilitySentence}. 탭하면 다음 문장으로 넘어갑니다.`}
      onPress={handleAdvance}
      style={{ alignItems: 'center', flex: 1, justifyContent: 'center', width: '100%' }}
    >
      <View
        pointerEvents="none"
        style={{
          alignItems: 'center',
          height: 270,
          justifyContent: 'center',
          marginBottom: 16,
          width: 270,
        }}
      >
        <View
          style={{
            borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.1),
            borderRadius: 135,
            borderWidth: 1,
            height: 270,
            position: 'absolute',
            width: 270,
          }}
        />
        <View
          style={{
            borderColor: withAlpha(fortuneReadingPalette.accent, 0.16),
            borderRadius: 108,
            borderWidth: 1,
            height: 216,
            position: 'absolute',
            width: 216,
          }}
        />
        <View
          style={{
            backgroundColor: withAlpha(fortuneReadingPalette.accent, 0.18),
            borderRadius: 72,
            height: 144,
            position: 'absolute',
            width: 144,
          }}
        />
        <View
          style={{
            backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.92),
            borderRadius: 44,
            height: 88,
            shadowColor: fortuneReadingPalette.accent,
            shadowOpacity: 0.45,
            shadowRadius: 34,
            width: 88,
          }}
        />
        <AppText variant="heading2" color={fortuneReadingPalette.accentStrong} style={{ position: 'absolute' }}>
          ✦
        </AppText>
      </View>

      <Animated.View
        style={{
          alignItems: 'center',
          backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.1),
          borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.18),
          borderRadius: 32,
          borderWidth: 1,
          gap: fortuneTheme.spacing.md,
          maxWidth: 360,
          opacity,
          paddingHorizontal: 24,
          paddingVertical: 28,
          shadowColor: fortuneReadingPalette.shadow,
          shadowOpacity: 0.22,
          shadowRadius: 24,
          transform: [{ translateY }, { scale }],
          width: '100%',
        }}
      >
        <View style={{ alignItems: 'center', flexDirection: 'row', gap: 8 }}>
          <View
            style={{
              backgroundColor: sourceColor(sentence.source),
              borderRadius: 5,
              height: 10,
              width: 10,
            }}
          />
          <AppText variant="caption" color={withAlpha(fortuneReadingPalette.textPrimary, 0.58)}>
            {sourceLabel(sentence.source)} · {progress}
          </AppText>
        </View>
        <AppText
          variant="calligraphyTitle"
          color={fortuneReadingPalette.textPrimary}
          style={{ lineHeight: 38, maxWidth: 320, textAlign: 'center' }}
        >
          {sentence.main}
        </AppText>
        {sentence.sub ? (
          <AppText
            variant="bodySmall"
            color={withAlpha(fortuneReadingPalette.textPrimary, 0.66)}
            style={{ maxWidth: 300, textAlign: 'center' }}
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
    translateY.stopAnimation();
    scale.stopAnimation();

    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 0,
        duration: EXIT_MS,
        easing: Easing.in(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(translateY, {
        toValue: -10,
        duration: EXIT_MS,
        easing: Easing.in(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(scale, {
        toValue: 1.01,
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
    translateY.stopAnimation();
    scale.stopAnimation();

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
    scale.stopAnimation();
  }

  function clearPendingTimeout() {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
  }
}

function sourceLabel(source: ReadingSentenceSource): string {
  switch (source) {
    case 'summary':
      return '결과 요약';
    case 'highlight':
      return '핵심 포인트';
    case 'recommendation':
      return '하늘이 조언';
    case 'warning':
      return '조심할 기운';
    case 'specialTip':
      return '특별 팁';
    case 'luckyItem':
      return '행운 신호';
    case 'visual':
      return '이미지/효과 장면';
    case 'raw':
      return '세부 리딩';
    default:
      return '결과 카드 요약';
  }
}

function sourceColor(source: ReadingSentenceSource): string {
  switch (source) {
    case 'warning':
      return fortuneReadingPalette.sourceLove;
    case 'recommendation':
      return fortuneReadingPalette.sourceMind;
    case 'luckyItem':
    case 'visual':
      return fortuneReadingPalette.sourceFlow;
    case 'specialTip':
      return fortuneReadingPalette.sourceLuck;
    default:
      return fortuneReadingPalette.accent;
  }
}

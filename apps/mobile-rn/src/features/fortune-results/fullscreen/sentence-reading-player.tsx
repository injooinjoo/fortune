import { useEffect, useRef } from 'react';
import { Animated, Easing, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';
import type { HaneulReadingSentence } from './haneul-reading-sequence';

const ENTER_MS = 520;
const HOLD_MS = 1900;
const EXIT_MS = 460;
const SETTLE_MS = 90;

export const HANEUL_READING_STEP_MS = ENTER_MS + HOLD_MS + EXIT_MS + SETTLE_MS;

interface SentenceReadingPlayerProps {
  sentence: HaneulReadingSentence;
  step: number;
  total: number;
  onStepDone: () => void;
}

export function SentenceReadingPlayer({
  sentence,
  step,
  total,
  onStepDone,
}: SentenceReadingPlayerProps) {
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(18)).current;
  const scale = useRef(new Animated.Value(0.985)).current;
  const doneRef = useRef(onStepDone);

  useEffect(() => {
    doneRef.current = onStepDone;
  }, [onStepDone]);

  useEffect(() => {
    opacity.setValue(0);
    translateY.setValue(18);
    scale.setValue(0.985);

    const animation = Animated.sequence([
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
      ]),
      Animated.delay(HOLD_MS),
      Animated.parallel([
        Animated.timing(opacity, {
          toValue: 0,
          duration: EXIT_MS,
          easing: Easing.in(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(translateY, {
          toValue: -14,
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
      ]),
      Animated.delay(SETTLE_MS),
    ]);

    animation.start(({ finished }) => {
      if (finished) doneRef.current();
    });

    return () => animation.stop();
  }, [opacity, scale, sentence.id, translateY]);

  const progress = Math.max(0, Math.min(1, (step + 1) / total));

  return (
    <View style={{ flex: 1, justifyContent: 'center', paddingHorizontal: 24 }}>
      <View
        accessibilityLabel={`하늘이 운세 ${step + 1}/${total}`}
        style={{ gap: 20 }}
      >
        <View
          style={{
            height: 3,
            borderRadius: fortuneTheme.radius.full,
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            overflow: 'hidden',
          }}
        >
          <View
            style={{
              width: `${progress * 100}%`,
              height: '100%',
              borderRadius: fortuneTheme.radius.full,
              backgroundColor: fortuneTheme.colors.accentTertiary,
            }}
          />
        </View>
        <Animated.View
          key={sentence.id}
          accessible
          accessibilityLabel={`${sentence.main}${sentence.sub ? ` ${sentence.sub}` : ''}`}
          style={{
            minHeight: 230,
            justifyContent: 'center',
            opacity,
            transform: [{ translateY }, { scale }],
          }}
        >
          <AppText
            variant="oracleTitle"
            style={{
              fontSize: 34,
              lineHeight: 46,
              letterSpacing: -0.6,
              textAlign: 'center',
            }}
          >
            {sentence.main}
          </AppText>
          {sentence.sub ? (
            <AppText
              variant="bodyMedium"
              color={fortuneTheme.colors.textSecondary}
              style={{
                marginTop: 18,
                lineHeight: 25,
                textAlign: 'center',
              }}
            >
              {sentence.sub}
            </AppText>
          ) : null}
        </Animated.View>
      </View>
    </View>
  );
}

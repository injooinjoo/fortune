/**
 * Interactive fortune cookie card for the chat surface.
 *
 * States: idle -> tapping (1-2) -> cracking (3-4) -> revealed (5th tap)
 *
 * Uses RN core Animated API for animations.
 */

import { useCallback, useRef, useState } from 'react';

import { Animated, Pressable, View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { tapLight, confirmAction } from '../../lib/haptics';
import { fortuneTheme } from '../../lib/theme';
import { useAppBootstrap } from '../../providers/app-bootstrap-provider';
import { getDailyFortune } from './fortune-cookie-messages';

const TOTAL_TAPS = 5;
const GOLDEN = '#E0A76B';

type CookiePhase = 'idle' | 'tapping' | 'cracking' | 'revealed';

function phaseFromTaps(count: number): CookiePhase {
  if (count === 0) return 'idle';
  if (count <= 2) return 'tapping';
  if (count <= 4) return 'cracking';
  return 'revealed';
}

function ProgressDots({ count }: { count: number }) {
  return (
    <View
      style={{
        alignItems: 'center',
        flexDirection: 'row',
        gap: 8,
        justifyContent: 'center',
      }}
    >
      {Array.from({ length: TOTAL_TAPS }).map((_, index) => (
        <View
          key={index}
          style={{
            backgroundColor:
              index < count
                ? GOLDEN
                : fortuneTheme.colors.surfaceSecondary,
            borderRadius: 4,
            height: 8,
            width: 8,
          }}
        />
      ))}
    </View>
  );
}

export function FortuneCookieCard() {
  const { session } = useAppBootstrap();
  const [tapCount, setTapCount] = useState(0);
  const [fortune] = useState(() => getDailyFortune(session?.user.id));

  const phase = phaseFromTaps(tapCount);

  const cookieRotation = useRef(new Animated.Value(0)).current;
  const cookieScale = useRef(new Animated.Value(1)).current;
  const cookieOpacity = useRef(new Animated.Value(1)).current;
  const fortuneOpacity = useRef(new Animated.Value(0)).current;
  const fortuneScale = useRef(new Animated.Value(0.8)).current;

  const handleTap = useCallback(() => {
    if (tapCount >= TOTAL_TAPS) return;

    const next = tapCount + 1;
    setTapCount(next);

    if (next < TOTAL_TAPS) {
      // Wobble rotation
      Animated.sequence([
        Animated.spring(cookieRotation, { toValue: -8, speed: 40, bounciness: 12, useNativeDriver: true }),
        Animated.spring(cookieRotation, { toValue: 8, speed: 40, bounciness: 12, useNativeDriver: true }),
        Animated.spring(cookieRotation, { toValue: 0, speed: 30, bounciness: 8, useNativeDriver: true }),
      ]).start();

      // Pulse scale
      Animated.sequence([
        Animated.spring(cookieScale, { toValue: 1.05, speed: 50, bounciness: 10, useNativeDriver: true }),
        Animated.spring(cookieScale, { toValue: 1, speed: 30, bounciness: 6, useNativeDriver: true }),
      ]).start();

      if (next <= 2) {
        tapLight();
      } else {
        confirmAction();
      }
    } else {
      // Break: cookie fades out + expands
      Animated.parallel([
        Animated.timing(cookieOpacity, { toValue: 0, duration: 400, useNativeDriver: true }),
        Animated.spring(cookieScale, { toValue: 1.15, speed: 20, bounciness: 4, useNativeDriver: true }),
      ]).start();

      // Reveal fortune
      Animated.parallel([
        Animated.timing(fortuneOpacity, { toValue: 1, duration: 500, useNativeDriver: true }),
        Animated.spring(fortuneScale, { toValue: 1, speed: 14, bounciness: 8, useNativeDriver: true }),
      ]).start();

      confirmAction();
      setTimeout(() => tapLight(), 120);
    }
  }, [tapCount, cookieRotation, cookieScale, cookieOpacity, fortuneOpacity, fortuneScale]);

  const handleReset = useCallback(() => {
    setTapCount(0);
    cookieRotation.setValue(0);
    cookieScale.setValue(1);
    fortuneScale.setValue(0.8);
    Animated.timing(cookieOpacity, { toValue: 1, duration: 300, useNativeDriver: true }).start();
    Animated.timing(fortuneOpacity, { toValue: 0, duration: 200, useNativeDriver: true }).start();
  }, [cookieRotation, cookieScale, cookieOpacity, fortuneOpacity, fortuneScale]);

  const cookieAnimatedStyle = {
    opacity: cookieOpacity,
    transform: [
      { rotate: cookieRotation.interpolate({ inputRange: [-20, 20], outputRange: ['-20deg', '20deg'] }) },
      { scale: cookieScale },
    ],
  };

  const fortuneAnimatedStyle = {
    opacity: fortuneOpacity,
    transform: [{ scale: fortuneScale }],
  };

  const instructionText =
    phase === 'idle'
      ? '쿠키를 탭해서 깨뜨려 보세요'
      : phase === 'tapping'
        ? '조금만 더 눌러보세요...'
        : phase === 'cracking'
          ? '거의 다 깨졌어요!'
          : '';

  return (
    <Card
      style={{
        alignItems: 'center',
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        paddingVertical: 28,
      }}
    >
      <View
        style={{
          alignItems: 'center',
          height: 140,
          justifyContent: 'center',
          width: '100%',
        }}
      >
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="포춘쿠키 탭하기"
          onPress={handleTap}
          style={{ alignItems: 'center', justifyContent: 'center', position: 'absolute' }}
        >
          <Animated.View
            style={[
              {
                alignItems: 'center',
                justifyContent: 'center',
              },
              cookieAnimatedStyle,
            ]}
          >
            <AppText
              variant="heading1"
              style={{ fontSize: 100, lineHeight: 120 }}
            >
              🥠
            </AppText>
          </Animated.View>
        </Pressable>

        <Animated.View
          style={[
            {
              alignItems: 'center',
              justifyContent: 'center',
              paddingHorizontal: 20,
              position: 'absolute',
            },
            fortuneAnimatedStyle,
          ]}
        >
          <AppText
            variant="caption"
            color={fortuneTheme.colors.textTertiary}
            style={{ marginBottom: 8 }}
          >
            오늘의 한마디
          </AppText>
          <AppText
            variant="heading3"
            style={{
              color: GOLDEN,
              fontSize: 22,
              fontWeight: '700',
              textAlign: 'center',
            }}
          >
            {fortune}
          </AppText>
        </Animated.View>
      </View>

      {phase !== 'revealed' ? (
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textTertiary}
          style={{ marginTop: 8, textAlign: 'center' }}
        >
          {instructionText}
        </AppText>
      ) : null}

      <View style={{ marginTop: 12 }}>
        <ProgressDots count={tapCount} />
      </View>

      {phase === 'revealed' ? (
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="다시 뽑기"
          onPress={handleReset}
          style={({ pressed }) => ({
            marginTop: 16,
            opacity: pressed ? 0.7 : 1,
          })}
        >
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderColor: fortuneTheme.colors.border,
              borderRadius: 999,
              borderWidth: 1,
              paddingHorizontal: 20,
              paddingVertical: 10,
            }}
          >
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.textSecondary}
            >
              다시 뽑기
            </AppText>
          </View>
        </Pressable>
      ) : null}
    </Card>
  );
}

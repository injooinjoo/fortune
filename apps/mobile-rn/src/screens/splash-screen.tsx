import { useEffect, useRef, useState } from 'react';

import { router, type Href } from 'expo-router';
import { Animated, Easing, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { readWelcomeSeen } from '../lib/welcome-state';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

// TODO(dev): Ondo 온보딩 개발 중 — 모든 실행에서 welcome carousel 강제.
// 개발 완료 후 false 로 되돌려 gate + welcome-seen 로직 복원할 것.
const FORCE_WELCOME_FOR_DEV = true;

// Auto-advance timing. The splash is intentionally brief — it exists so the
// native launch image and the first JS-rendered screen share a common
// background, not as a lingering brand moment.
const AUTO_ADVANCE_MS = 800;
const SLOW_NETWORK_ESCAPE_MS = 4000;

const BG = '#0B0B10';
const FG = '#F5F6FB';
const FG_MUTED = '#9198AA';
const FG_DIM = '#6B6F7D';
const WARM_DOT = '#E8A268';

export function SplashScreen() {
  const { gate, status } = useAppBootstrap();
  const hasAutoNavigatedRef = useRef(false);
  const dotPulse = useRef(new Animated.Value(0)).current;

  const [authEntryTarget, setAuthEntryTarget] = useState<
    '/welcome' | '/signup' | null
  >(null);
  const [showEscape, setShowEscape] = useState(false);

  // Warm-dot breathing pulse under the wordmark.
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(dotPulse, {
          toValue: 1,
          duration: 1200,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(dotPulse, {
          toValue: 0,
          duration: 1200,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    ).start();
  }, [dotPulse]);

  useEffect(() => {
    if (FORCE_WELCOME_FOR_DEV) {
      setAuthEntryTarget('/welcome');
      return;
    }
    if (gate !== 'auth-entry') {
      setAuthEntryTarget(null);
      return;
    }
    let cancelled = false;
    void readWelcomeSeen().then((seen) => {
      if (!cancelled) setAuthEntryTarget(seen ? '/signup' : '/welcome');
    });
    return () => {
      cancelled = true;
    };
  }, [gate]);

  const nextRoute: Href | null = FORCE_WELCOME_FOR_DEV
    ? '/welcome'
    : gate === 'auth-entry'
      ? authEntryTarget
      : gate === 'profile-flow'
        ? '/onboarding'
        : '/chat';

  useEffect(() => {
    if (status !== 'ready' || hasAutoNavigatedRef.current) return;
    if (nextRoute === null) return;

    hasAutoNavigatedRef.current = true;
    const destination = nextRoute;
    const t = setTimeout(() => router.replace(destination), AUTO_ADVANCE_MS);
    return () => clearTimeout(t);
  }, [nextRoute, status]);

  // Fallback escape tap only appears if bootstrap takes unreasonably long
  // (network hiccup, Supabase timeout, etc.) so the user is never stuck.
  useEffect(() => {
    const t = setTimeout(() => setShowEscape(true), SLOW_NETWORK_ESCAPE_MS);
    return () => clearTimeout(t);
  }, []);

  const dotOpacity = dotPulse.interpolate({
    inputRange: [0, 1],
    outputRange: [0.35, 1],
  });
  const dotScale = dotPulse.interpolate({
    inputRange: [0, 1],
    outputRange: [0.85, 1.1],
  });

  return (
    <SafeAreaView
      edges={['top', 'bottom']}
      style={{ flex: 1, backgroundColor: BG }}
    >
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
          paddingHorizontal: 24,
        }}
      >
        <Text
          // Serif wordmark — ZEN Serif loaded via _layout useFonts(). Generous
          // lineHeight so the glyph isn't clipped against the variant default.
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 68,
            lineHeight: 84,
            letterSpacing: 4,
            color: FG,
            textAlign: 'center',
          }}
        >
          온도
        </Text>

        <Animated.View
          style={{
            width: 6,
            height: 6,
            borderRadius: 3,
            backgroundColor: WARM_DOT,
            marginTop: 24,
            opacity: dotOpacity,
            transform: [{ scale: dotScale }],
          }}
        />

        <Text
          style={{
            fontFamily: 'System',
            fontSize: 15,
            lineHeight: 24,
            color: FG_MUTED,
            textAlign: 'center',
            marginTop: 24,
            letterSpacing: 0.2,
          }}
        >
          마음을 들여다보는{'\n'}가장 따뜻한 방법
        </Text>
      </View>

      <View
        style={{
          alignItems: 'center',
          paddingBottom: 36,
        }}
      >
        <Text
          style={{
            fontFamily: 'System',
            fontSize: 11,
            lineHeight: 16,
            color: FG_DIM,
            letterSpacing: 2.4,
          }}
        >
          ONDO
        </Text>

        {showEscape && status !== 'ready' ? (
          <Pressable
            onPress={() => router.replace(nextRoute ?? '/welcome')}
            style={({ pressed }) => ({
              marginTop: 16,
              opacity: pressed ? 0.6 : 1,
              paddingHorizontal: 20,
              paddingVertical: 10,
            })}
          >
            <Text
              style={{
                fontFamily: 'System',
                fontSize: 13,
                lineHeight: 18,
                color: FG_MUTED,
                fontWeight: '600',
              }}
            >
              계속 →
            </Text>
          </Pressable>
        ) : null}
      </View>
    </SafeAreaView>
  );
}

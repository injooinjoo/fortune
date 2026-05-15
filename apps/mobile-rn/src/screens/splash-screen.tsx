import { useEffect, useRef, useState } from 'react';

import { ResizeMode, Video } from 'expo-av';
import { router, type Href } from 'expo-router';
import { Animated, Easing, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { formatVersionLabel } from '../lib/build-identity';
import { isOnboardingQaEmail } from '../lib/onboarding-qa';
import { readWelcomeForceEnabled, readWelcomeSeen } from '../lib/welcome-state';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

// Auto-advance timing. The splash is intentionally brief — it exists so the
// native launch image and the first JS-rendered screen share a common
// background, not as a lingering brand moment.
const AUTO_ADVANCE_MS = 1400;
const SLOW_NETWORK_ESCAPE_MS = 4000;

// Ondo Splash — Higgsfield-generated premium aura art.
// Native launch image uses the same asset via app.config.js; this JS route
// provides the OTA-updatable splash moment after bootstrap starts.
const BG = '#0B0B10';
const FG_MUTED = '#9198AA';
const FG_DIM = '#6B6F7D';

const SPLASH_LOOP = require('../../assets/splash-loop.mp4');

export function SplashScreen() {
  const { gate, session, status } = useAppBootstrap();
  const hasAutoNavigatedRef = useRef(false);

  // Entry (0→1 once at mount).
  const entry = useRef(new Animated.Value(0)).current;
  const float = useRef(new Animated.Value(0)).current;

  const [authEntryTarget, setAuthEntryTarget] = useState<Href | null>(null);
  const [qaWelcomeForce, setQaWelcomeForce] = useState<boolean | null>(null);
  const [showEscape, setShowEscape] = useState(false);

  // Entry sequence (once).
  useEffect(() => {
    Animated.timing(entry, {
      toValue: 1,
      duration: 1200,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [entry]);

  // Subtle floating loop — lightweight native transform only.
  useEffect(() => {
    const floatLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(float, {
          toValue: 1,
          duration: 2600,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(float, {
          toValue: 0,
          duration: 2600,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    );
    const delay = setTimeout(() => floatLoop.start(), 420);
    return () => {
      clearTimeout(delay);
      floatLoop.stop();
    };
  }, [float]);

  useEffect(() => {
    if (gate !== 'auth-entry') {
      setAuthEntryTarget(null);
      return;
    }
    let cancelled = false;
    void readWelcomeSeen().then((seen) => {
      if (!cancelled) {
        setAuthEntryTarget(seen ? ('/chat?showList=1' as Href) : '/welcome');
      }
    });
    return () => {
      cancelled = true;
    };
  }, [gate]);

  useEffect(() => {
    if (status !== 'ready') {
      setQaWelcomeForce(null);
      return;
    }

    const email = session?.user.email;
    if (!isOnboardingQaEmail(email)) {
      setQaWelcomeForce(false);
      return;
    }

    let cancelled = false;
    setQaWelcomeForce(null);
    void readWelcomeForceEnabled().then((enabled) => {
      if (!cancelled) setQaWelcomeForce(enabled);
    });

    return () => {
      cancelled = true;
    };
  }, [session?.user.email, status]);

  const nextRoute: Href | null =
    qaWelcomeForce === null
      ? null
      : qaWelcomeForce
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

  const artScale = entry.interpolate({
    inputRange: [0, 1],
    outputRange: [0.94, 1],
  });
  const entryOpacity = entry.interpolate({
    inputRange: [0, 0.35, 1],
    outputRange: [0, 0.78, 1],
  });
  const floatY = float.interpolate({
    inputRange: [0, 1],
    outputRange: [-5, 5],
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
        <Animated.View
          style={{
            width: '92%',
            maxWidth: 430,
            aspectRatio: 1,
            opacity: entryOpacity,
            transform: [{ scale: artScale }, { translateY: floatY }],
          }}
        >
          <Video
            source={SPLASH_LOOP}
            resizeMode={ResizeMode.CONTAIN}
            shouldPlay
            isLooping
            isMuted
            style={{ width: '100%', height: '100%' }}
          />
        </Animated.View>
      </View>

      {/* Version + escape — 기능성, 디자인 영향 X */}
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
        <Text
          style={{
            fontFamily: 'System',
            fontSize: 11,
            lineHeight: 16,
            color: FG_DIM,
            marginTop: 6,
            letterSpacing: 0.2,
          }}
        >
          {formatVersionLabel()}
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

import { useEffect, useRef, useState } from 'react';

import { router, type Href } from 'expo-router';
import { Animated, Easing, Pressable, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Svg, { Circle, Defs, RadialGradient, Stop } from 'react-native-svg';

import { formatVersionLabel } from '../lib/build-identity';
import { readWelcomeSeen } from '../lib/welcome-state';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

// Auto-advance timing. The splash is intentionally brief — it exists so the
// native launch image and the first JS-rendered screen share a common
// background, not as a lingering brand moment.
const AUTO_ADVANCE_MS = 1400;
const SLOW_NETWORK_ESCAPE_MS = 4000;

// Ondo Splash — "온기 일렁임 (Warm Ember)"
// Source: Ondo Design System/project/Ondo Splash.html
//   Core  radial: #FFE4B8 0% → #E0A76B 40% → #8B7BE8 85%   (r=70 on 1200 canvas)
//   Halo  radial: #E0A76B @0.35 → #8B7BE8 @0.18 → transparent (r=220)
// 3 레이어 (core/halo/outer) 각기 다른 주기의 breathing 으로 촛불 같은
// 비정형 일렁임 연출.
const BG = '#0B0B10';
const FG = '#F5F6FB';
const FG_MUTED = '#9198AA';
const FG_DIM = '#6B6F7D';

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

export function SplashScreen() {
  const { gate, status } = useAppBootstrap();
  const hasAutoNavigatedRef = useRef(false);

  // Entry (0→1 once at mount).
  const entry = useRef(new Animated.Value(0)).current;
  // Breathing loops — 3 independent timings for non-uniform flicker.
  const coreBreath = useRef(new Animated.Value(0)).current;
  const haloBreath = useRef(new Animated.Value(0)).current;
  const outerBreath = useRef(new Animated.Value(0)).current;

  const [authEntryTarget, setAuthEntryTarget] = useState<
    '/welcome' | '/signup' | null
  >(null);
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

  // Breathing loops — start after brief delay so entry reads cleanly.
  useEffect(() => {
    const loop = (value: Animated.Value, duration: number) =>
      Animated.loop(
        Animated.sequence([
          Animated.timing(value, {
            toValue: 1,
            duration,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: false, // SVG radius/opacity isn't native-driven
          }),
          Animated.timing(value, {
            toValue: 0,
            duration,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: false,
          }),
        ]),
      );
    const delay = setTimeout(() => {
      loop(coreBreath, 1700).start();
      loop(haloBreath, 2400).start();
      loop(outerBreath, 3200).start();
    }, 600);
    return () => clearTimeout(delay);
  }, [coreBreath, haloBreath, outerBreath]);

  useEffect(() => {
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

  const nextRoute: Href | null =
    gate === 'auth-entry'
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

  // ─────────────────────────────────────────────
  // Animated radii / opacities for SVG circles
  // ─────────────────────────────────────────────

  // Entry — ember scale 0.6→1, full opacity at end.
  const entryScale = entry.interpolate({
    inputRange: [0, 1],
    outputRange: [0.6, 1],
  });
  const entryOpacity = entry.interpolate({
    inputRange: [0, 0.4, 1],
    outputRange: [0, 0.7, 1],
  });

  // Breathing — radii multiplier relative to base.
  const coreR = coreBreath.interpolate({
    inputRange: [0, 1],
    outputRange: [68, 74], // 1.00 ↔ 1.088
  });
  const coreOpacity = coreBreath.interpolate({
    inputRange: [0, 1],
    outputRange: [0.9, 1],
  });
  const haloR = haloBreath.interpolate({
    inputRange: [0, 1],
    outputRange: [200, 232], // 1.00 ↔ 1.16
  });
  const haloOpacity = haloBreath.interpolate({
    inputRange: [0, 1],
    outputRange: [0.85, 1],
  });
  const outerR = outerBreath.interpolate({
    inputRange: [0, 1],
    outputRange: [280, 340], // widest, slowest
  });
  const outerOpacity = outerBreath.interpolate({
    inputRange: [0, 1],
    outputRange: [0.5, 0.8],
  });

  // SVG canvas sized to cover comfortably on most devices. Ember centered
  // horizontally; vertical offset above true-center so "온도" reads below.
  const SVG_SIZE = 520; // container 대략 height
  const CX = SVG_SIZE / 2;
  const CY = SVG_SIZE / 2;

  const wordmarkOpacity = entry.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: [0, 0, 1],
  });
  const wordmarkTranslateY = entry.interpolate({
    inputRange: [0, 1],
    outputRange: [12, 0],
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
        {/* Ember — 3 layered radial gradients */}
        <Animated.View
          style={{
            width: SVG_SIZE,
            height: SVG_SIZE,
            opacity: entryOpacity,
            transform: [{ scale: entryScale }],
          }}
        >
          <Svg width={SVG_SIZE} height={SVG_SIZE}>
            <Defs>
              <RadialGradient id="emberCore" cx="50%" cy="50%" r="50%">
                <Stop offset="0%" stopColor="#FFE4B8" stopOpacity={1} />
                <Stop offset="40%" stopColor="#E0A76B" stopOpacity={1} />
                <Stop offset="85%" stopColor="#8B7BE8" stopOpacity={0.9} />
                <Stop offset="100%" stopColor="#8B7BE8" stopOpacity={0} />
              </RadialGradient>
              <RadialGradient id="emberHalo" cx="50%" cy="50%" r="50%">
                <Stop offset="0%" stopColor="#E0A76B" stopOpacity={0.35} />
                <Stop offset="60%" stopColor="#8B7BE8" stopOpacity={0.18} />
                <Stop offset="100%" stopColor="#8B7BE8" stopOpacity={0} />
              </RadialGradient>
              <RadialGradient id="emberOuter" cx="50%" cy="50%" r="50%">
                <Stop offset="0%" stopColor="#E0A76B" stopOpacity={0.08} />
                <Stop offset="70%" stopColor="#8B7BE8" stopOpacity={0.04} />
                <Stop offset="100%" stopColor="#8B7BE8" stopOpacity={0} />
              </RadialGradient>
            </Defs>

            {/* Outer glow — largest, slowest */}
            <AnimatedCircle
              cx={CX}
              cy={CY}
              r={outerR}
              fill="url(#emberOuter)"
              opacity={outerOpacity}
            />
            {/* Mid halo */}
            <AnimatedCircle
              cx={CX}
              cy={CY}
              r={haloR}
              fill="url(#emberHalo)"
              opacity={haloOpacity}
            />
            {/* Core ember */}
            <AnimatedCircle
              cx={CX}
              cy={CY}
              r={coreR}
              fill="url(#emberCore)"
              opacity={coreOpacity}
            />
          </Svg>
        </Animated.View>

        {/* Wordmark — 온도, positioned just below the ember */}
        <Animated.Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 72,
            lineHeight: 88,
            letterSpacing: 6,
            color: FG,
            textAlign: 'center',
            marginTop: -40, // pull up into the lower halo
            opacity: wordmarkOpacity,
            transform: [{ translateY: wordmarkTranslateY }],
          }}
        >
          온도
        </Animated.Text>
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

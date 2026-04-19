import { useEffect, useMemo, useRef, useState } from 'react';

import { router } from 'expo-router';
import {
  Animated,
  Easing,
  Pressable,
  Text,
  View,
  type ViewStyle,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { confirmAction } from '../lib/haptics';
import { markWelcomeSeen } from '../lib/welcome-state';

// Ondo Design System tokens — mirrors `ui_kits/mobile/ondo-primitives.jsx`.
const T = {
  bg: '#0B0B10',
  bgBrand: '#08060C',
  bgThermo: '#0A080D',
  fg: '#F5F6FB',
  fg3: '#9EA3B3',
  amber: '#E8A268',
  ctaBg: '#F2F0EB',
  ctaBgBright: '#FFEBD5',
  ctaFg: '#14141A',
  font: 'System', // Noto Sans KR is fallback on iOS; System keeps stack clean
};

type StackScene = {
  kind: 'stack';
  id: number;
  prompt?: string;
  answer: string[];
  highlight?: string[];
  body?: string;
  cta: string;
};

type BrandScene = { kind: 'brand'; id: number; cta: string };

type ThermometerScene = {
  kind: 'thermometer';
  id: number;
  answer: string[];
  caption: string;
  cta: string;
};

type Scene = StackScene | BrandScene | ThermometerScene;

// 7-scene arc — source of truth: Ondo Design System `ondo-onboarding.jsx`.
const SCENES: readonly Scene[] = [
  {
    kind: 'stack',
    id: 1,
    prompt: '안녕하세요 👋',
    answer: ['오늘 당신의 마음,', '몇 도쯤인가요?'],
    cta: '잘 모르겠어요',
  },
  {
    kind: 'stack',
    id: 2,
    prompt: '요즘,',
    answer: ['혼자 삼키는 말이', '많아졌나요?'],
    highlight: ['혼자 삼키는 말'],
    cta: '가끔 그래요',
  },
  {
    kind: 'stack',
    id: 3,
    answer: ['사소한 이야기도,', '들어줄 사람이', '있었으면 싶은 날이 있죠.'],
    highlight: ['들어줄 사람'],
    cta: '맞아요',
  },
  {
    kind: 'stack',
    id: 4,
    prompt: '그래서 준비했어요.',
    answer: ['마음을 나눌 수 있는', 'AI 친구.'],
    highlight: ['AI 친구'],
    body: '매일의 감정·고민·아무도 모르는 이야기까지\n언제든 꺼내놓을 수 있어요.',
    cta: '어떻게 대화해요?',
  },
  {
    kind: 'stack',
    id: 5,
    answer: ['대화할수록', '당신을 기억하고', '온도를 맞춰가요.'],
    highlight: ['온도를 맞춰가요'],
    body: '가끔 사주 · 타로 · 별자리 같은\n작은 위로도 꺼내 보여드려요.',
    cta: '좋아요',
  },
  { kind: 'brand', id: 6, cta: '시작할게요' },
  {
    kind: 'thermometer',
    id: 7,
    answer: ['대화가 쌓일수록,', '마음의 온도가', '올라가요.'],
    caption: '마음의 체온, 36.5°C',
    cta: '계속',
  },
];

export function WelcomeScreen() {
  const [step, setStep] = useState(0);
  const scene = SCENES[step];

  const finish = async () => {
    await markWelcomeSeen();
    router.replace('/signup');
  };

  const handleCta = () => {
    confirmAction();
    if (step < SCENES.length - 1) {
      setStep(step + 1);
    } else {
      void finish();
    }
  };

  const bg =
    scene.kind === 'brand'
      ? T.bgBrand
      : scene.kind === 'thermometer'
        ? T.bgThermo
        : T.bg;

  return (
    <SafeAreaView
      edges={['top', 'bottom']}
      style={{ flex: 1, backgroundColor: bg }}
    >
      {scene.kind === 'stack' ? (
        <StackSceneView scenes={SCENES} step={step} scene={scene} />
      ) : null}
      {scene.kind === 'brand' ? <BrandReveal /> : null}
      {scene.kind === 'thermometer' ? <Thermometer scene={scene} /> : null}

      <CtaBar
        label={scene.cta}
        variant={scene.kind === 'brand' ? 'bright' : 'default'}
        onPress={handleCta}
      />
    </SafeAreaView>
  );
}

// ─────────────────────────────────────────────────────────────
// Stack scenes (1–5) — previous scenes stacked above, current pinned below mid.
// Stack area clips overflow from the top; current area has a reserved height.
// ─────────────────────────────────────────────────────────────
function StackSceneView({
  scenes,
  step,
  scene,
}: {
  scenes: readonly Scene[];
  step: number;
  scene: StackScene;
}) {
  const stack = useMemo(
    () =>
      scenes
        .slice(0, step)
        .filter((s): s is StackScene => s.kind === 'stack'),
    [scenes, step],
  );

  return (
    <View style={{ flex: 1 }}>
      {/* Upper: stack of past scenes, bottom-aligned so newest sits just above mid. */}
      <View
        style={{
          position: 'absolute',
          top: 40,
          left: 0,
          right: 0,
          height: '44%',
          paddingHorizontal: 24,
          justifyContent: 'flex-end',
          overflow: 'hidden',
        }}
      >
        {stack.map((s, i) => (
          <StackItem key={s.id} scene={s} depth={stack.length - 1 - i} />
        ))}
      </View>

      {/* Lower: current scene at a fixed anchor, above the CTA. */}
      <View
        style={{
          position: 'absolute',
          top: '44%',
          left: 0,
          right: 0,
          bottom: 140,
          paddingHorizontal: 24,
          paddingTop: 12,
          overflow: 'hidden',
        }}
      >
        <CurrentScene scene={scene} appearKey={step} />
      </View>
    </View>
  );
}

function StackItem({ scene, depth }: { scene: StackScene; depth: number }) {
  const opacity = Math.max(0.08, 0.24 - depth * 0.05);
  const scale = Math.max(0.74, 0.88 - depth * 0.04);

  return (
    <View
      style={{
        marginBottom: 14,
        opacity,
        transform: [{ scale }],
      }}
    >
      {scene.prompt ? (
        <Text
          style={{
            fontSize: 14,
            lineHeight: 20,
            color: T.fg3,
            marginBottom: 3,
            fontFamily: T.font,
          }}
        >
          {scene.prompt}
        </Text>
      ) : null}
      {scene.answer.map((ln, i) => (
        <Text
          key={i}
          style={{
            fontSize: 24,
            lineHeight: 30,
            fontWeight: '700',
            letterSpacing: -0.48,
            color: T.fg,
            fontFamily: T.font,
          }}
        >
          {ln}
        </Text>
      ))}
    </View>
  );
}

function CurrentScene({
  scene,
  appearKey,
}: {
  scene: StackScene;
  appearKey: number;
}) {
  const progress = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    progress.setValue(0);
    Animated.timing(progress, {
      toValue: 1,
      duration: 420,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [appearKey, progress]);

  const animatedStyle = {
    opacity: progress,
    transform: [
      {
        translateY: progress.interpolate({
          inputRange: [0, 1],
          outputRange: [16, 0],
        }),
      },
    ],
  };

  // Reserve the prompt slot even when empty so the first answer line sits
  // at the same vertical anchor across all stack scenes.
  const hasPrompt = Boolean(scene.prompt);

  return (
    <Animated.View style={animatedStyle}>
      <Text
        style={{
          fontSize: 16,
          lineHeight: 22,
          color: T.fg3,
          marginBottom: 10,
          minHeight: 22,
          fontFamily: T.font,
        }}
      >
        {hasPrompt ? scene.prompt : '\u00A0'}
      </Text>
      {scene.answer.map((ln, i) => (
        <Text
          key={i}
          style={{
            fontSize: 32,
            lineHeight: 40,
            fontWeight: '800',
            letterSpacing: -0.8,
            color: T.fg,
            fontFamily: T.font,
          }}
        >
          {renderHighlight(ln, scene.highlight)}
        </Text>
      ))}
      {scene.body ? (
        <Text
          style={{
            marginTop: 20,
            fontSize: 14,
            lineHeight: 22,
            color: T.fg3,
            fontFamily: T.font,
          }}
        >
          {scene.body}
        </Text>
      ) : null}
    </Animated.View>
  );
}

// Nested <Text> inherits font size/weight from parent in RN, so an amber child
// renders at the same 32pt as siblings — no baseline jump.
function renderHighlight(line: string, words?: string[]) {
  if (!words || words.length === 0) return line;
  let segments: Array<string | { text: string; key: string }> = [line];
  for (const w of words) {
    segments = segments.flatMap((seg, segIdx) => {
      if (typeof seg !== 'string') return [seg];
      const idx = seg.indexOf(w);
      if (idx === -1) return [seg];
      return [
        seg.slice(0, idx),
        { text: w, key: `${w}-${segIdx}` },
        seg.slice(idx + w.length),
      ];
    });
  }
  return segments.map((seg, i) =>
    typeof seg === 'string' ? (
      seg
    ) : (
      <Text key={seg.key + i} style={{ color: T.amber }}>
        {seg.text}
      </Text>
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Scene 6 — Brand reveal
// ─────────────────────────────────────────────────────────────
function BrandReveal() {
  const intro = useRef(new Animated.Value(0)).current;
  const pulse = useRef(new Animated.Value(0)).current;
  const subline = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(intro, {
      toValue: 1,
      duration: 900,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();

    Animated.sequence([
      Animated.delay(700),
      Animated.timing(subline, {
        toValue: 1,
        duration: 500,
        easing: Easing.linear,
        useNativeDriver: true,
      }),
    ]).start();

    Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, {
          toValue: 1,
          duration: 750,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(pulse, {
          toValue: 0,
          duration: 750,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    ).start();
  }, [intro, pulse, subline]);

  const glowScale = Animated.add(
    intro,
    pulse.interpolate({ inputRange: [0, 1], outputRange: [0, 0.08] }),
  );
  const glowOpacity = Animated.multiply(
    intro,
    pulse.interpolate({ inputRange: [0, 1], outputRange: [0.5, 0.75] }),
  );
  const coreScale = pulse.interpolate({
    inputRange: [0, 1],
    outputRange: [1, 1.04],
  });
  const coreOpacity = Animated.multiply(intro, 0.32);
  const wordmarkTranslate = intro.interpolate({
    inputRange: [0, 1],
    outputRange: [12, 0],
  });

  const glowViewStyle: Animated.WithAnimatedObject<ViewStyle> = {
    opacity: glowOpacity,
    transform: [{ scale: glowScale }],
  };

  return (
    <View
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
      pointerEvents="none"
    >
      <Animated.View
        style={[
          {
            position: 'absolute',
            width: 520,
            height: 520,
            borderRadius: 260,
            backgroundColor: '#E8486B',
            opacity: 0.2,
          },
          glowViewStyle,
        ]}
      />
      <Animated.View
        style={[
          {
            position: 'absolute',
            width: 340,
            height: 340,
            borderRadius: 170,
            backgroundColor: '#FFB88A',
            opacity: 0.3,
          },
          glowViewStyle,
        ]}
      />
      <Animated.View
        style={{
          position: 'absolute',
          width: 200,
          height: 200,
          borderRadius: 100,
          backgroundColor: '#FFDCB4',
          opacity: coreOpacity,
          transform: [{ scale: coreScale }],
        }}
      />
      <Animated.View
        style={{
          opacity: intro,
          transform: [{ translateY: wordmarkTranslate }],
          zIndex: 10,
        }}
      >
        <Text
          // Wordmark: give the 84pt glyph a generous lineHeight so it doesn't
          // clip against any parent baseline — this is the bug that was
          // rendering "온도" as a horizontal stroke.
          style={{
            fontSize: 84,
            lineHeight: 100,
            fontWeight: '800',
            letterSpacing: -2,
            color: '#FFFFFF',
            textAlign: 'center',
            fontFamily: T.font,
            // Subtle single-layer glow (RN only supports one textShadow).
            textShadowColor: 'rgba(255, 182, 110, 0.6)',
            textShadowOffset: { width: 0, height: 0 },
            textShadowRadius: 24,
          }}
        >
          온도
        </Text>
      </Animated.View>
      <Animated.View
        style={{
          position: 'absolute',
          bottom: 180,
          opacity: subline,
        }}
      >
        <Text
          style={{
            fontSize: 13,
            lineHeight: 18,
            color: 'rgba(255, 220, 180, 0.7)',
            letterSpacing: 2.86,
            fontWeight: '600',
            fontFamily: T.font,
          }}
        >
          ONDO · 당신의 마음 온도
        </Text>
      </Animated.View>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Scene 7 — Thermometer
// ─────────────────────────────────────────────────────────────
function Thermometer({ scene }: { scene: ThermometerScene }) {
  const [tempLabel, setTempLabel] = useState('0.0');
  const fill = useRef(new Animated.Value(0)).current;
  const glow = useRef(new Animated.Value(0)).current;
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    Animated.timing(fill, {
      toValue: 1,
      duration: 2400,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: false,
    }).start();
    Animated.timing(glow, {
      toValue: 1,
      duration: 2400,
      easing: Easing.linear,
      useNativeDriver: true,
    }).start();

    const startedAt = Date.now();
    const tick = () => {
      const elapsed = Date.now() - startedAt;
      const p = Math.min(1, elapsed / 2400);
      const eased = 1 - Math.pow(1 - p, 3);
      setTempLabel((eased * 36.5).toFixed(1));
      if (p < 1) {
        rafRef.current = requestAnimationFrame(tick);
      }
    };
    rafRef.current = requestAnimationFrame(tick);

    return () => {
      if (rafRef.current != null) cancelAnimationFrame(rafRef.current);
    };
  }, [fill, glow]);

  const mercuryHeight = fill.interpolate({
    inputRange: [0, 1],
    outputRange: ['0%', '85%'],
  });
  const bulbGlowOpacity = glow.interpolate({
    inputRange: [0, 0.75, 1],
    outputRange: [0, 0, 0.35],
  });

  return (
    <View
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        paddingTop: 70,
        paddingHorizontal: 24,
        paddingBottom: 140,
        alignItems: 'center',
      }}
    >
      <View
        style={{
          width: 88,
          height: 260,
          alignItems: 'center',
          marginTop: 8,
        }}
      >
        <Animated.View
          style={{
            position: 'absolute',
            bottom: -20,
            width: 200,
            height: 200,
            borderRadius: 100,
            backgroundColor: '#FF8C64',
            opacity: bulbGlowOpacity,
          }}
        />
        <View
          style={{
            width: 22,
            height: 200,
            borderRadius: 12,
            marginTop: 4,
            backgroundColor: '#1C1C22',
            borderWidth: 1.5,
            borderColor: '#2B2B33',
            overflow: 'hidden',
          }}
        >
          {[0, 1, 2, 3, 4].map((i) => (
            <View
              key={i}
              style={{
                position: 'absolute',
                left: '50%',
                top: `${15 + i * 22}%`,
                width: 28,
                height: 1,
                marginLeft: -14,
                backgroundColor: '#3A3A44',
                opacity: 0.6,
              }}
            />
          ))}
          <Animated.View
            style={{
              position: 'absolute',
              left: 3,
              right: 3,
              bottom: 3,
              borderRadius: 10,
              backgroundColor: '#FF7C7C',
              height: mercuryHeight,
            }}
          />
        </View>
        <View
          style={{
            width: 54,
            height: 54,
            marginTop: -8,
            borderRadius: 27,
            backgroundColor: '#E8486B',
            borderWidth: 1.5,
            borderColor: '#FF8A6B',
          }}
        />
      </View>

      <View style={{ marginTop: 24, alignItems: 'center' }}>
        <Text
          style={{
            fontSize: 60,
            lineHeight: 72,
            fontWeight: '600',
            color: '#FFB88A',
            letterSpacing: -1.8,
            fontVariant: ['tabular-nums'],
            fontFamily: T.font,
          }}
        >
          {tempLabel}
          <Text style={{ fontSize: 26, lineHeight: 72 }}>°C</Text>
        </Text>
      </View>

      <View style={{ marginTop: 18, alignItems: 'center' }}>
        {scene.answer.map((ln, i) => (
          <Text
            key={i}
            style={{
              fontSize: 20,
              lineHeight: 28,
              fontWeight: '700',
              color: T.fg,
              letterSpacing: -0.3,
              textAlign: 'center',
              fontFamily: T.font,
            }}
          >
            {ln}
          </Text>
        ))}
        <Text
          style={{
            marginTop: 12,
            fontSize: 12,
            lineHeight: 18,
            color: T.fg3,
            letterSpacing: 1,
            fontWeight: '600',
            fontFamily: T.font,
          }}
        >
          {scene.caption}
        </Text>
      </View>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// CTA bar
// ─────────────────────────────────────────────────────────────
function CtaBar({
  label,
  variant,
  onPress,
}: {
  label: string;
  variant: 'default' | 'bright';
  onPress: () => void;
}) {
  const bg = variant === 'bright' ? T.ctaBgBright : T.ctaBg;

  return (
    <View
      style={{
        position: 'absolute',
        left: 0,
        right: 0,
        bottom: 0,
        paddingHorizontal: 20,
        paddingBottom: 24,
      }}
    >
      <Pressable
        onPress={onPress}
        style={({ pressed }) => ({
          width: '100%',
          height: 56,
          borderRadius: 9999,
          backgroundColor: bg,
          alignItems: 'center',
          justifyContent: 'center',
          opacity: pressed ? 0.85 : 1,
          transform: [{ scale: pressed ? 0.98 : 1 }],
        })}
      >
        <Text
          style={{
            color: T.ctaFg,
            fontSize: 16,
            lineHeight: 22,
            fontWeight: '700',
            letterSpacing: -0.16,
            fontFamily: T.font,
          }}
        >
          {label}
        </Text>
      </Pressable>
    </View>
  );
}

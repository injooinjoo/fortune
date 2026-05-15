import { useEffect, useMemo, useRef, useState } from 'react';

import { router } from 'expo-router';
import {
  Animated,
  Easing,
  Pressable,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import {
  onboardingAdvance,
  onboardingBrandReveal,
  onboardingTemperatureReveal,
} from '../lib/haptics';
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
    router.replace({ pathname: '/chat', params: { showList: '1' } });
  };

  const handleCta = () => {
    onboardingAdvance();
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
  let segments: (string | { text: string; key: string })[] = [line];
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
  const float = useRef(new Animated.Value(0)).current;
  const subline = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    onboardingBrandReveal();

    Animated.parallel([
      Animated.spring(intro, {
        toValue: 1,
        speed: 7,
        bounciness: 7,
        useNativeDriver: true,
      }),
      Animated.sequence([
        Animated.delay(420),
        Animated.timing(subline, {
          toValue: 1,
          duration: 520,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
      ]),
    ]).start();

    const pulseLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, {
          toValue: 1,
          duration: 1800,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(pulse, {
          toValue: 0,
          duration: 1800,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    );
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
    pulseLoop.start();
    floatLoop.start();

    return () => {
      pulseLoop.stop();
      floatLoop.stop();
    };
  }, [float, intro, pulse, subline]);

  const orbScale = intro.interpolate({
    inputRange: [0, 1],
    outputRange: [0.86, 1],
  });
  const wordmarkY = intro.interpolate({
    inputRange: [0, 1],
    outputRange: [18, 0],
  });
  const ringScale = pulse.interpolate({
    inputRange: [0, 1],
    outputRange: [1, 1.06],
  });
  const ringOpacity = pulse.interpolate({
    inputRange: [0, 1],
    outputRange: [0.16, 0.28],
  });
  const floatY = float.interpolate({
    inputRange: [0, 1],
    outputRange: [-6, 6],
  });
  const sublineY = subline.interpolate({
    inputRange: [0, 1],
    outputRange: [8, 0],
  });

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
        paddingBottom: 54,
      }}
      pointerEvents="none"
    >
      <Animated.View
        style={{
          position: 'absolute',
          width: 420,
          height: 420,
          borderRadius: 210,
          backgroundColor: '#7B2039',
          opacity: ringOpacity,
          transform: [{ scale: ringScale }, { translateY: 6 }],
        }}
      />
      <Animated.View
        style={{
          position: 'absolute',
          width: 284,
          height: 284,
          borderRadius: 142,
          backgroundColor: '#C66E5C',
          opacity: Animated.multiply(intro, 0.18),
          transform: [{ scale: orbScale }, { translateY: floatY }],
        }}
      />
      <Animated.View
        style={{
          position: 'absolute',
          width: 206,
          height: 206,
          borderRadius: 103,
          borderWidth: 1,
          borderColor: 'rgba(255, 214, 178, 0.18)',
          opacity: intro,
          transform: [{ scale: ringScale }, { translateY: floatY }],
        }}
      />

      <Animated.View
        style={{
          width: 168,
          height: 168,
          borderRadius: 48,
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: 'rgba(255, 214, 178, 0.10)',
          borderWidth: 1,
          borderColor: 'rgba(255, 232, 210, 0.18)',
          shadowColor: '#FFB88A',
          shadowOpacity: 0.32,
          shadowRadius: 36,
          shadowOffset: { width: 0, height: 18 },
          opacity: intro,
          transform: [{ scale: orbScale }, { translateY: wordmarkY }],
        }}
      >
        <Text
          style={{
            fontSize: 66,
            lineHeight: 78,
            fontWeight: '800',
            letterSpacing: -2.2,
            color: '#FFF8F0',
            textAlign: 'center',
            fontFamily: T.font,
            textShadowColor: 'rgba(255, 178, 126, 0.42)',
            textShadowOffset: { width: 0, height: 0 },
            textShadowRadius: 22,
          }}
        >
          온도
        </Text>
      </Animated.View>

      <Animated.View
        style={{
          marginTop: 26,
          alignItems: 'center',
          opacity: subline,
          transform: [{ translateY: sublineY }],
        }}
      >
        <Text
          style={{
            fontSize: 12,
            lineHeight: 18,
            color: 'rgba(255, 232, 210, 0.72)',
            letterSpacing: 3.2,
            fontWeight: '700',
            fontFamily: T.font,
          }}
        >
          ONDO
        </Text>
        <Text
          style={{
            marginTop: 10,
            fontSize: 18,
            lineHeight: 26,
            color: '#FFF3E6',
            letterSpacing: -0.28,
            fontWeight: '700',
            fontFamily: T.font,
          }}
        >
          당신의 마음 온도
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
  const intro = useRef(new Animated.Value(0)).current;
  const glow = useRef(new Animated.Value(0)).current;
  const breathe = useRef(new Animated.Value(0)).current;
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    onboardingTemperatureReveal();

    Animated.parallel([
      Animated.spring(intro, {
        toValue: 1,
        speed: 8,
        bounciness: 5,
        useNativeDriver: true,
      }),
      Animated.timing(fill, {
        toValue: 1,
        duration: 2200,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: false,
      }),
      Animated.timing(glow, {
        toValue: 1,
        duration: 2200,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start();

    const breatheLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(breathe, {
          toValue: 1,
          duration: 1500,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(breathe, {
          toValue: 0,
          duration: 1500,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    );
    breatheLoop.start();

    const startedAt = Date.now();
    const tick = () => {
      const elapsed = Date.now() - startedAt;
      const p = Math.min(1, elapsed / 2200);
      const eased = 1 - Math.pow(1 - p, 3);
      setTempLabel((eased * 36.5).toFixed(1));
      if (p < 1) {
        rafRef.current = requestAnimationFrame(tick);
      }
    };
    rafRef.current = requestAnimationFrame(tick);

    return () => {
      breatheLoop.stop();
      if (rafRef.current != null) cancelAnimationFrame(rafRef.current);
    };
  }, [breathe, fill, glow, intro]);

  const mercuryHeight = fill.interpolate({
    inputRange: [0, 1],
    outputRange: ['10%', '82%'],
  });
  const introY = intro.interpolate({
    inputRange: [0, 1],
    outputRange: [18, 0],
  });
  const bulbGlowOpacity = glow.interpolate({
    inputRange: [0, 0.55, 1],
    outputRange: [0.08, 0.18, 0.34],
  });
  const haloScale = breathe.interpolate({
    inputRange: [0, 1],
    outputRange: [1, 1.05],
  });
  const haloOpacity = breathe.interpolate({
    inputRange: [0, 1],
    outputRange: [0.14, 0.22],
  });

  return (
    <Animated.View
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        justifyContent: 'center',
        paddingTop: 34,
        paddingHorizontal: 24,
        paddingBottom: 118,
        alignItems: 'center',
        opacity: intro,
        transform: [{ translateY: introY }],
      }}
    >
      <View
        style={{
          width: 228,
          height: 228,
          borderRadius: 114,
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: 'rgba(255, 184, 138, 0.07)',
          borderWidth: 1,
          borderColor: 'rgba(255, 210, 178, 0.10)',
        }}
      >
        <Animated.View
          style={{
            position: 'absolute',
            width: 204,
            height: 204,
            borderRadius: 102,
            backgroundColor: '#7A3328',
            opacity: haloOpacity,
            transform: [{ scale: haloScale }],
          }}
        />
        <Animated.View
          style={{
            position: 'absolute',
            bottom: 42,
            width: 128,
            height: 128,
            borderRadius: 64,
            backgroundColor: '#FF8A6B',
            opacity: bulbGlowOpacity,
            transform: [{ scale: haloScale }],
          }}
        />

        <View style={{ width: 84, height: 190, alignItems: 'center' }}>
          <View
            style={{
              width: 34,
              height: 134,
              borderRadius: 18,
              marginTop: 4,
              backgroundColor: 'rgba(255, 255, 255, 0.06)',
              borderWidth: 1,
              borderColor: 'rgba(255, 232, 210, 0.18)',
              overflow: 'hidden',
            }}
          >
            {[0, 1, 2].map((i) => (
              <View
                key={i}
                style={{
                  position: 'absolute',
                  right: 5,
                  top: `${24 + i * 22}%`,
                  width: 8,
                  height: 1,
                  backgroundColor: 'rgba(255, 232, 210, 0.24)',
                }}
              />
            ))}
            <Animated.View
              style={{
                position: 'absolute',
                left: 5,
                right: 5,
                bottom: 5,
                borderRadius: 14,
                backgroundColor: '#FF746F',
                height: mercuryHeight,
                shadowColor: '#FF8A6B',
                shadowOpacity: 0.38,
                shadowRadius: 12,
                shadowOffset: { width: 0, height: 0 },
              }}
            />
          </View>
          <View
            style={{
              width: 68,
              height: 68,
              marginTop: -14,
              borderRadius: 34,
              backgroundColor: '#E9486D',
              borderWidth: 4,
              borderColor: '#FFAE82',
              shadowColor: '#FF7C7C',
              shadowOpacity: 0.44,
              shadowRadius: 22,
              shadowOffset: { width: 0, height: 10 },
            }}
          />
        </View>
      </View>

      <Animated.View
        style={{
          marginTop: 20,
          alignItems: 'center',
          opacity: glow,
        }}
      >
        <Text
          style={{
            fontSize: 58,
            lineHeight: 66,
            fontWeight: '800',
            color: '#FFBF91',
            letterSpacing: -2.4,
            fontVariant: ['tabular-nums'],
            fontFamily: T.font,
            textShadowColor: 'rgba(255, 151, 112, 0.22)',
            textShadowOffset: { width: 0, height: 0 },
            textShadowRadius: 18,
          }}
        >
          {tempLabel}
          <Text style={{ fontSize: 22, lineHeight: 66 }}>°C</Text>
        </Text>
      </Animated.View>

      <View style={{ marginTop: 14, alignItems: 'center' }}>
        {scene.answer.map((ln, i) => (
          <Text
            key={i}
            style={{
              fontSize: 19,
              lineHeight: 28,
              fontWeight: '800',
              color: T.fg,
              letterSpacing: -0.34,
              textAlign: 'center',
              fontFamily: T.font,
            }}
          >
            {ln}
          </Text>
        ))}
        <View
          style={{
            marginTop: 18,
            paddingHorizontal: 14,
            paddingVertical: 7,
            borderRadius: 999,
            backgroundColor: 'rgba(255, 255, 255, 0.06)',
            borderWidth: 1,
            borderColor: 'rgba(255, 255, 255, 0.07)',
          }}
        >
          <Text
            style={{
              fontSize: 12,
              lineHeight: 17,
              color: 'rgba(245, 246, 251, 0.64)',
              letterSpacing: 1.1,
              fontWeight: '700',
              fontFamily: T.font,
            }}
          >
            {scene.caption}
          </Text>
        </View>
      </View>
    </Animated.View>
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

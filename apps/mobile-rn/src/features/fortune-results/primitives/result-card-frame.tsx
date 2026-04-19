// ResultCardFrame: port of result-cards.jsx:920-1011 + chat-player.jsx:147-199 shimmer sweep.
// Orchestrates the 4-phase reveal (hero / head / body / sections) driven by a single `progress` 0-1
// prop. Shimmer sweep overlays the card while progress < 0.95, fading out at 0.95.
import { useEffect, useRef, type ReactNode } from 'react';
import { Animated, Pressable, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

import { BulletList } from './bullet-list';
import { Pill } from './pill';
import { ScoreDial } from './score-dial';
import { Section } from './section';

interface ResultCardFrameProps {
  kind: string;
  data: EmbeddedResultPayload;
  progress: number;
  onPress?: () => void;
  children?: ReactNode;
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));

const AMBER = '#E0A76B';

export function ResultCardFrame({
  data,
  progress,
  onPress,
  children,
}: ResultCardFrameProps) {
  const p = clamp01(progress);
  const pKicker = stage(p, 0, 0.1);
  const pHero = stage(p, 0, 0.3);
  const pHead = stage(p, 0.22, 0.5);
  const pBody = stage(p, 0.5, 0.72);
  const pSec = stage(p, 0.7, 1);

  // Head translate-Y (6 → 0) and body translate-Y (4 → 0).
  const headAnim = useRef(new Animated.Value(pHead)).current;
  const bodyAnim = useRef(new Animated.Value(pBody)).current;

  useEffect(() => {
    Animated.timing(headAnim, {
      toValue: pHead,
      duration: 300,
      useNativeDriver: true,
    }).start();
    Animated.timing(bodyAnim, {
      toValue: pBody,
      duration: 240,
      useNativeDriver: true,
    }).start();
  }, [pHead, pBody, headAnim, bodyAnim]);

  const headTranslate = headAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [6, 0],
  });
  const bodyTranslate = bodyAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [4, 0],
  });

  // Shimmer: loops a translateX sweep across the card until progress >= 0.95.
  const shimmerAnim = useRef(new Animated.Value(0)).current;
  const shimmerOpacity = useRef(new Animated.Value(1)).current;

  // Loop only runs while progress < 0.95 — stops once the shimmer has faded
  // out so we don't leak a perpetual RAF/JS callback in the background.
  const shimmerActive = p < 0.95;
  useEffect(() => {
    if (!shimmerActive) return;
    const loop = Animated.loop(
      Animated.timing(shimmerAnim, {
        toValue: 1,
        duration: 1600,
        useNativeDriver: true,
      }),
    );
    loop.start();
    return () => {
      loop.stop();
    };
  }, [shimmerActive, shimmerAnim]);

  useEffect(() => {
    Animated.timing(shimmerOpacity, {
      toValue: shimmerActive ? 1 : 0,
      duration: 400,
      useNativeDriver: true,
    }).start();
  }, [shimmerActive, shimmerOpacity]);

  const shimmerTranslate = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [-200, 400],
  });

  const metrics = data.metrics ?? [];
  const metricCols = metrics.length >= 3 ? 3 : 2;

  const card = (
    <View
      style={{
        borderRadius: 20,
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
        backgroundColor: '#1A1A22',
        padding: 14,
        overflow: 'hidden',
      }}
    >
      {/* Kicker row */}
      <Animated.View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'space-between',
          opacity: pKicker,
        }}
      >
        <Text
          style={{
            fontSize: 10,
            lineHeight: 12,
            letterSpacing: 1.8,
            color: AMBER,
            fontWeight: '700',
            textTransform: 'uppercase',
          }}
        >
          {data.eyebrow}
        </Text>
        <Text
          style={{
            fontSize: 10,
            lineHeight: 12,
            color: fortuneTheme.colors.textTertiary,
            letterSpacing: 1.2,
          }}
        >
          Ondo
        </Text>
      </Animated.View>

      {/* Hero slot */}
      <View
        style={{
          minHeight: 180,
          justifyContent: 'center',
          marginTop: 4,
        }}
      >
        {children}
      </View>

      {/* Title + score */}
      <Animated.View
        style={{
          flexDirection: 'row',
          alignItems: 'flex-start',
          marginTop: 4,
          opacity: pHead,
          transform: [{ translateY: headTranslate }],
        }}
      >
        <View style={{ flex: 1, minWidth: 0 }}>
          <Text
            style={{
              fontSize: 22,
              lineHeight: 28,
              fontWeight: '700',
              color: fortuneTheme.colors.textPrimary,
            }}
          >
            {data.title}
          </Text>
          <Text
            style={{
              marginTop: 4,
              fontSize: 12,
              lineHeight: 19,
              color: fortuneTheme.colors.textSecondary,
            }}
          >
            {data.subtitle}
          </Text>
        </View>
        {data.score != null ? (
          <View style={{ marginLeft: 12 }}>
            <ScoreDial
              score={data.score}
              color={AMBER}
              progress={pHead}
              size={62}
            />
          </View>
        ) : null}
      </Animated.View>

      {/* Summary */}
      <Animated.View
        style={{
          marginTop: 12,
          opacity: pBody,
          transform: [{ translateY: bodyTranslate }],
        }}
      >
        <Text
          style={{
            fontSize: 14,
            lineHeight: 24,
            color: fortuneTheme.colors.textPrimary,
          }}
        >
          {data.summary}
        </Text>
      </Animated.View>

      {/* Metrics grid */}
      {metrics.length > 0 ? (
        <Animated.View
          style={{
            marginTop: 12,
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: 6,
            opacity: pBody,
          }}
        >
          {metrics.map((m, i) => (
            <View
              key={i}
              style={{
                width: `${100 / metricCols - 2}%`,
                borderWidth: 1,
                borderColor: fortuneTheme.colors.border,
                borderRadius: 10,
                paddingHorizontal: 10,
                paddingVertical: 8,
                backgroundColor: 'rgba(255,255,255,0.015)',
              }}
            >
              <Text
                style={{
                  fontSize: 9,
                  lineHeight: 11,
                  letterSpacing: 1,
                  color: fortuneTheme.colors.textTertiary,
                }}
              >
                {m.label}
              </Text>
              <Text
                style={{
                  marginTop: 2,
                  fontSize: 16,
                  lineHeight: 20,
                  fontWeight: '800',
                  color: fortuneTheme.colors.textPrimary,
                }}
              >
                {m.value}
              </Text>
              {m.note ? (
                <Text
                  style={{
                    marginTop: 2,
                    fontSize: 10,
                    lineHeight: 14,
                    color: fortuneTheme.colors.textSecondary,
                  }}
                >
                  {m.note}
                </Text>
              ) : null}
            </View>
          ))}
        </Animated.View>
      ) : null}

      {/* Highlights */}
      {data.highlights && data.highlights.length > 0 ? (
        <Section title="핵심 포인트" accent={AMBER} appear={pSec}>
          <BulletList items={data.highlights} tone="neutral" appear={pSec} />
        </Section>
      ) : null}

      {/* Recommendations */}
      {data.recommendations && data.recommendations.length > 0 ? (
        <Section title="추천 액션" accent="#68B593" appear={pSec}>
          <BulletList
            items={data.recommendations}
            tone="good"
            appear={pSec}
          />
        </Section>
      ) : null}

      {/* Warnings */}
      {data.warnings && data.warnings.length > 0 ? (
        <Section title="주의 포인트" accent="#E0A76B" appear={pSec}>
          <BulletList items={data.warnings} tone="warn" appear={pSec} />
        </Section>
      ) : null}

      {/* Lucky items */}
      {data.luckyItems && data.luckyItems.length > 0 ? (
        <Section title="행운 포인트" accent="#FFC86B" appear={pSec}>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
            {data.luckyItems.map((t, i) => (
              <Pill key={i} text={t} color="#FFC86B" />
            ))}
          </View>
        </Section>
      ) : null}

      {/* Special tip */}
      {data.specialTip ? (
        <Animated.View
          style={{
            marginTop: 14,
            padding: 12,
            borderRadius: 12,
            backgroundColor: 'rgba(139,123,232,0.08)',
            borderWidth: 1,
            borderColor: 'rgba(139,123,232,0.18)',
            opacity: pSec,
          }}
        >
          <Text
            style={{
              fontSize: 10,
              lineHeight: 12,
              letterSpacing: 1.6,
              color: '#C4B8FF',
              fontWeight: '700',
            }}
          >
            SPECIAL TIP
          </Text>
          <Text
            style={{
              marginTop: 4,
              fontSize: 13,
              lineHeight: 21,
              color: fortuneTheme.colors.textPrimary,
            }}
          >
            {data.specialTip}
          </Text>
        </Animated.View>
      ) : null}

      {/* Footer */}
      <Text
        style={{
          textAlign: 'center',
          marginTop: 14,
          fontSize: 10,
          lineHeight: 14,
          color: fortuneTheme.colors.textTertiary,
        }}
      >
        오락 목적의 AI 생성 콘텐츠입니다
      </Text>

      {/* Shimmer sweep */}
      <Animated.View
        pointerEvents="none"
        style={{
          position: 'absolute',
          top: 0,
          bottom: 0,
          left: 0,
          width: 140,
          opacity: shimmerOpacity,
          backgroundColor: 'rgba(255,255,255,0.08)',
          transform: [{ translateX: shimmerTranslate }, { skewX: '-15deg' }],
        }}
      />
    </View>
  );

  if (onPress) {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => ({ opacity: pressed ? 0.9 : 1 })}
      >
        {card}
      </Pressable>
    );
  }
  return card;
}

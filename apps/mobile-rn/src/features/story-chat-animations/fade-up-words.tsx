/**
 * Port of `Ondo Design System/project/story_chat/story-chat-player.jsx` AIBlock
 * word-stagger reveal.
 *
 * CSS 원본:
 *   animation: `fadeUp 380ms cubic-bezier(0.2,0,0,1) both`
 *   animation-delay: `${i * 40}ms`
 *   @keyframes fadeUp { from { opacity: 0; transform: translateY(6px); }
 *                       to { opacity: 1; transform: translateY(0); } }
 *
 * 단어 단위 지연 + fade + 살짝 위로 올라오는 표현. 메신저처럼 차곡차곡 단어가
 * 얹히는 느낌.
 */

import { useEffect, useRef } from 'react';
import { Animated, Easing, StyleSheet, View } from 'react-native';

import { AppText } from '../../components/app-text';
import { fortuneTheme } from '../../lib/theme';

const WORD_DURATION_MS = 380;
const PER_WORD_DELAY_MS = 40;
const TRANSLATE_FROM = 6;
const EASING = Easing.bezier(0.2, 0, 0, 1);

interface FadeUpWordsProps {
  text: string;
  variant?: Parameters<typeof AppText>[0]['variant'];
  color?: string;
  speed?: number;
}

export function FadeUpWords({
  text,
  variant = 'bodyMedium',
  color = fortuneTheme.colors.textPrimary,
  speed = 1,
}: FadeUpWordsProps) {
  const tokens = tokenize(text);

  return (
    <View style={styles.wrapper}>
      {tokens.map((token, index) => {
        if (token.kind === 'newline') {
          return <View key={`br-${index}`} style={styles.br} />;
        }
        if (token.kind === 'space') {
          return (
            <AppText key={`sp-${index}`} variant={variant} color={color}>
              {token.value}
            </AppText>
          );
        }
        return (
          <FadeUpToken
            key={`w-${index}-${token.value}`}
            text={token.value}
            delayMs={(index * PER_WORD_DELAY_MS) / speed}
            durationMs={WORD_DURATION_MS / speed}
            variant={variant}
            color={color}
          />
        );
      })}
    </View>
  );
}

function FadeUpToken({
  text,
  delayMs,
  durationMs,
  variant,
  color,
}: {
  text: string;
  delayMs: number;
  durationMs: number;
  variant: Parameters<typeof AppText>[0]['variant'];
  color: string;
}) {
  const progress = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const animation = Animated.timing(progress, {
      toValue: 1,
      duration: durationMs,
      delay: delayMs,
      easing: EASING,
      useNativeDriver: true,
    });
    animation.start();
    return () => animation.stop();
  }, [delayMs, durationMs, progress]);

  const translateY = progress.interpolate({
    inputRange: [0, 1],
    outputRange: [TRANSLATE_FROM, 0],
  });

  return (
    <Animated.View
      style={{ opacity: progress, transform: [{ translateY }] }}
    >
      <AppText variant={variant} color={color}>
        {text}
      </AppText>
    </Animated.View>
  );
}

type Token =
  | { kind: 'word'; value: string }
  | { kind: 'space'; value: string }
  | { kind: 'newline' };

function tokenize(text: string): Token[] {
  const result: Token[] = [];
  // 원본: String(children).split(/(\s+|\n)/) — 공백/개행을 separator로 분리.
  const parts = text.split(/(\s+|\n)/);
  for (const part of parts) {
    if (!part) continue;
    if (part === '\n') {
      result.push({ kind: 'newline' });
    } else if (/^\s+$/.test(part)) {
      result.push({ kind: 'space', value: part });
    } else {
      result.push({ kind: 'word', value: part });
    }
  }
  return result;
}

const styles = StyleSheet.create({
  wrapper: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-end',
  },
  br: {
    width: '100%',
    height: 0,
  },
});

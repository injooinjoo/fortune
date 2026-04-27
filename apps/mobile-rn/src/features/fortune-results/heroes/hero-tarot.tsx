/**
 * HeroTarot — `result-cards.jsx:HeroTarot` (107-142). 3장 타로 스프레드 플립.
 *
 * 원본 스펙:
 *   - 카드 74×112, gap 10, padding 22px 4px 14px
 *   - 스태거 window: delay = i*0.18, local = stage(p, delay, delay+0.55)
 *   - rotateY: tween(easeInOut(local), 180, 0)
 *   - transition: 120ms linear
 *   - 뒷면: gradient 135deg #2a1f4a → #0B0B10 60% + 대각선 dashed 패턴 + violet border 55%
 *   - 앞면: gradient 180deg #1A1028 → #0B0B10 100% + amber border 55%
 *     - num: amber 10px letter-spacing 0.1em
 *     - art: amber serif 28px (가운데)
 *     - name: fgSub 9.5px letter-spacing 0.06em
 *     - pos: fg3 9px
 *
 * RN 포팅: Animated.Value + interpolate로 rotateY. 진행도는 `progress` prop으로 외부에서 통제.
 *   (ResultCardFrame이 pHero 주입)
 */
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';
import type { TarotSpreadCard } from '../../chat-results/types';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeInOut = (t: number) =>
  t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const CARD_W = 74;
const CARD_H = 112;
const AMBER = '#E0A76B';
const VIOLET = '#8B7BE8';
const FG_SUB = '#D0D4E0';

interface TarotCardFull {
  num?: string;
  name: string;
  art?: string;
  pos?: string;
}

interface HeroTarotProps {
  data?: unknown;
  progress?: number;
  /** Optional direct cards override (used by callers with custom data shape). */
  cards?: TarotCardFull[];
}

const DEFAULT_SPREAD: TarotCardFull[] = [
  { num: 'III', name: 'The Empress', art: '✦', pos: 'PAST' },
  { num: 'XVII', name: 'The Star', art: '✧', pos: 'PRESENT' },
  { num: 'XIX', name: 'The Sun', art: '☀', pos: 'FUTURE' },
];

function cardFromSpread(c: TarotSpreadCard, i: number): TarotCardFull {
  return {
    num: c.suit ?? toRoman(i + 1),
    name: c.name,
    art: c.art ?? '✦',
    pos: c.position ?? ['PAST', 'PRESENT', 'FUTURE'][i] ?? '',
  };
}

function toRoman(n: number): string {
  const r = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
  return r[n - 1] ?? String(n);
}

function extractCards(payload: unknown, cards?: TarotCardFull[]): TarotCardFull[] {
  if (cards && cards.length > 0) return cards.slice(0, 3);
  if (!payload || typeof payload !== 'object') return DEFAULT_SPREAD;
  const root = payload as { spread?: TarotSpreadCard[] };
  if (root.spread && root.spread.length > 0) {
    return root.spread.slice(0, 3).map(cardFromSpread);
  }
  return DEFAULT_SPREAD;
}

export default function HeroTarot({ data: payload, progress = 1, cards }: HeroTarotProps) {
  const p = clamp01(progress);
  const spread = extractCards(payload, cards);

  return (
    <View
      style={{
        paddingTop: 22,
        paddingHorizontal: 4,
        paddingBottom: 14,
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 10,
      }}
    >
      {spread.map((c, i) => (
        <TarotCard key={`card-${i}-${c.name}`} card={c} progress={p} index={i} />
      ))}
    </View>
  );
}

function TarotCard({ card, progress, index }: { card: TarotCardFull; progress: number; index: number }) {
  const delay = index * 0.18;
  const local = stage(progress, delay, delay + 0.55);
  const rotDeg = tween(easeInOut(local), 180, 0);

  const rotAnim = useRef(new Animated.Value(180)).current;
  useEffect(() => {
    Animated.timing(rotAnim, {
      toValue: rotDeg,
      duration: 120,
      useNativeDriver: true,
    }).start();
  }, [rotDeg, rotAnim]);

  const rotate = rotAnim.interpolate({
    inputRange: [0, 180],
    outputRange: ['0deg', '180deg'],
  });

  return (
    <Animated.View
      style={{
        width: CARD_W,
        height: CARD_H,
        transform: [{ perspective: 800 }, { rotateY: rotate }],
      }}
    >
      {/* back — visible when rotation > 90° (i.e., initial 180° state before flip) */}
      <View
        style={{
          position: 'absolute',
          inset: 0,
          borderRadius: 8,
          backgroundColor: '#2a1f4a',
          borderWidth: 1,
          borderColor: `${VIOLET}55`,
          backfaceVisibility: 'hidden',
          overflow: 'hidden',
        }}
      >
        {/* 대각선 dashed 패턴 근사 — 반복 View 라인들 */}
        {Array.from({ length: 8 }).map((_, di) => (
          <View
            key={`dash-${di}`}
            style={{
              position: 'absolute',
              left: -20,
              top: di * 16 - 10,
              width: CARD_W + 40,
              height: 2,
              backgroundColor: 'rgba(139,123,232,0.18)',
              transform: [{ rotate: '45deg' }],
            }}
          />
        ))}
      </View>
      {/* front — 뒤집힌 뒤 정면 */}
      <View
        style={{
          position: 'absolute',
          inset: 0,
          borderRadius: 8,
          backgroundColor: '#1A1028',
          borderWidth: 1,
          borderColor: `${AMBER}55`,
          alignItems: 'center',
          justifyContent: 'center',
          padding: 6,
          transform: [{ rotateY: '180deg' }],
          backfaceVisibility: 'hidden',
        }}
      >
        {card.num ? (
          <Text
            style={{
              fontSize: 10,
              color: AMBER,
              letterSpacing: 1,
            }}
          >
            {card.num}
          </Text>
        ) : null}
        <Text
          style={{
            fontSize: 28,
            color: AMBER,
            fontFamily: 'ZenSerif',
            marginVertical: 4,
          }}
        >
          {card.art}
        </Text>
        <Text
          style={{
            fontSize: 9.5,
            color: FG_SUB,
            letterSpacing: 0.57,
            fontFamily: 'ZenSerif',
            textAlign: 'center',
          }}
          numberOfLines={2}
        >
          {card.name}
        </Text>
        {card.pos ? (
          <Text
            style={{
              fontSize: 9,
              color: fortuneTheme.colors.textTertiary,
              marginTop: 4,
            }}
          >
            {card.pos}
          </Text>
        ) : null}
      </View>
    </Animated.View>
  );
}

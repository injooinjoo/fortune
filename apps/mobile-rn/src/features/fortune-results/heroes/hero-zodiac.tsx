/**
 * HeroZodiac — 별자리(Western zodiac) + 띠(Korean zodiac) 공용 히어로.
 *
 * 업그레이드: 단색 ✦ 폴백 대신 SVG 장식 프레임 안에 Unicode 별자리 심볼 또는
 * 동양 12지 이모지를 넣는다. Ondo Design System의 `StarField`·`CornerGlow`
 * 아이덴티티(다크+앰버 악센트)를 따른다.
 *
 * 인터페이스는 기존과 호환: `<HeroZodiac data={payload} progress={0..1} />`.
 */
import { useMemo } from 'react';
import { Text, View } from 'react-native';
import Svg, {
  Circle,
  Defs,
  G,
  Line,
  RadialGradient,
  Rect,
  Stop,
} from 'react-native-svg';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const AMBER = '#E0A76B';
const SKY = '#8FB8FF';
const VIOLET = '#8B7BE8';

// ─────────────────────────────────────────────────────────────
// 12지 (Korean zodiac) — emoji + 한자
// ─────────────────────────────────────────────────────────────

const KOREAN_ZODIAC_TO_CHAR: Record<string, { emoji: string; ch: string }> = {
  rat: { emoji: '🐭', ch: '子' },
  ox: { emoji: '🐂', ch: '丑' },
  tiger: { emoji: '🐯', ch: '寅' },
  rabbit: { emoji: '🐰', ch: '卯' },
  dragon: { emoji: '🐲', ch: '辰' },
  snake: { emoji: '🐍', ch: '巳' },
  horse: { emoji: '🐎', ch: '午' },
  sheep: { emoji: '🐑', ch: '未' },
  goat: { emoji: '🐑', ch: '未' },
  monkey: { emoji: '🐒', ch: '申' },
  rooster: { emoji: '🐓', ch: '酉' },
  dog: { emoji: '🐶', ch: '戌' },
  pig: { emoji: '🐷', ch: '亥' },
  boar: { emoji: '🐷', ch: '亥' },
  쥐: { emoji: '🐭', ch: '子' },
  소: { emoji: '🐂', ch: '丑' },
  호랑이: { emoji: '🐯', ch: '寅' },
  토끼: { emoji: '🐰', ch: '卯' },
  용: { emoji: '🐲', ch: '辰' },
  뱀: { emoji: '🐍', ch: '巳' },
  말: { emoji: '🐎', ch: '午' },
  양: { emoji: '🐑', ch: '未' },
  원숭이: { emoji: '🐒', ch: '申' },
  닭: { emoji: '🐓', ch: '酉' },
  개: { emoji: '🐶', ch: '戌' },
  돼지: { emoji: '🐷', ch: '亥' },
};

// ─────────────────────────────────────────────────────────────
// 12 별자리 (Western zodiac) — Unicode + 한글
// ─────────────────────────────────────────────────────────────

interface ConstellationInfo {
  symbol: string; // Unicode 별자리
  ko: string; // "쌍둥이자리"
  /** 별자리 도트 좌표 (0~1 정규화). 단순화된 별자리 선 그림용. */
  stars: ReadonlyArray<readonly [number, number]>;
  /** 별자리 선 (stars 인덱스 페어). */
  edges: ReadonlyArray<readonly [number, number]>;
}

const CONSTELLATION_BY_KEY: Record<string, ConstellationInfo> = {
  aries: {
    symbol: '♈',
    ko: '양자리',
    stars: [[0.3, 0.35], [0.5, 0.3], [0.68, 0.4], [0.72, 0.6]],
    edges: [[0, 1], [1, 2], [2, 3]],
  },
  taurus: {
    symbol: '♉',
    ko: '황소자리',
    stars: [[0.28, 0.55], [0.44, 0.45], [0.56, 0.38], [0.72, 0.42], [0.6, 0.64]],
    edges: [[0, 1], [1, 2], [2, 3], [1, 4]],
  },
  gemini: {
    symbol: '♊',
    ko: '쌍둥이자리',
    stars: [[0.3, 0.2], [0.35, 0.5], [0.38, 0.8], [0.62, 0.2], [0.65, 0.5], [0.7, 0.8]],
    edges: [[0, 1], [1, 2], [3, 4], [4, 5], [1, 4]],
  },
  cancer: {
    symbol: '♋',
    ko: '게자리',
    stars: [[0.3, 0.35], [0.5, 0.28], [0.68, 0.35], [0.38, 0.6], [0.62, 0.6]],
    edges: [[0, 1], [1, 2], [0, 3], [2, 4], [3, 4]],
  },
  leo: {
    symbol: '♌',
    ko: '사자자리',
    stars: [[0.22, 0.36], [0.38, 0.3], [0.52, 0.36], [0.66, 0.44], [0.56, 0.66], [0.74, 0.72]],
    edges: [[0, 1], [1, 2], [2, 3], [3, 4], [3, 5]],
  },
  virgo: {
    symbol: '♍',
    ko: '처녀자리',
    stars: [[0.24, 0.3], [0.4, 0.38], [0.56, 0.5], [0.7, 0.6], [0.52, 0.72]],
    edges: [[0, 1], [1, 2], [2, 3], [2, 4]],
  },
  libra: {
    symbol: '♎',
    ko: '천칭자리',
    stars: [[0.26, 0.44], [0.5, 0.3], [0.74, 0.44], [0.5, 0.62]],
    edges: [[0, 1], [1, 2], [0, 3], [2, 3]],
  },
  scorpio: {
    symbol: '♏',
    ko: '전갈자리',
    stars: [[0.22, 0.32], [0.36, 0.44], [0.52, 0.52], [0.68, 0.56], [0.8, 0.66], [0.72, 0.8]],
    edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]],
  },
  sagittarius: {
    symbol: '♐',
    ko: '사수자리',
    stars: [[0.26, 0.6], [0.42, 0.48], [0.56, 0.36], [0.72, 0.28], [0.48, 0.62]],
    edges: [[0, 1], [1, 2], [2, 3], [1, 4]],
  },
  capricorn: {
    symbol: '♑',
    ko: '염소자리',
    stars: [[0.24, 0.36], [0.42, 0.44], [0.56, 0.52], [0.72, 0.48], [0.6, 0.72]],
    edges: [[0, 1], [1, 2], [2, 3], [2, 4]],
  },
  aquarius: {
    symbol: '♒',
    ko: '물병자리',
    stars: [[0.28, 0.38], [0.44, 0.34], [0.6, 0.42], [0.74, 0.5], [0.4, 0.58], [0.6, 0.66]],
    edges: [[0, 1], [1, 2], [2, 3], [1, 4], [2, 5]],
  },
  pisces: {
    symbol: '♓',
    ko: '물고기자리',
    stars: [[0.22, 0.3], [0.36, 0.4], [0.5, 0.5], [0.64, 0.4], [0.78, 0.3], [0.5, 0.72]],
    edges: [[0, 1], [1, 2], [2, 3], [3, 4], [2, 5]],
  },
};

// 한글/영문 별칭도 지원
const CONSTELLATION_ALIASES: Record<string, string> = {
  aries: 'aries',
  양자리: 'aries',
  taurus: 'taurus',
  황소자리: 'taurus',
  gemini: 'gemini',
  쌍둥이자리: 'gemini',
  cancer: 'cancer',
  게자리: 'cancer',
  leo: 'leo',
  사자자리: 'leo',
  virgo: 'virgo',
  처녀자리: 'virgo',
  libra: 'libra',
  천칭자리: 'libra',
  scorpio: 'scorpio',
  전갈자리: 'scorpio',
  sagittarius: 'sagittarius',
  사수자리: 'sagittarius',
  capricorn: 'capricorn',
  염소자리: 'capricorn',
  aquarius: 'aquarius',
  물병자리: 'aquarius',
  pisces: 'pisces',
  물고기자리: 'pisces',
};

// ─────────────────────────────────────────────────────────────
// 데이터 추출
// ─────────────────────────────────────────────────────────────

type ResolvedIdentity =
  | { kind: 'korean'; emoji: string; ch: string }
  | { kind: 'western'; info: ConstellationInfo }
  | { kind: 'fallback' };

function resolveIdentity(payload: unknown): ResolvedIdentity {
  if (!payload || typeof payload !== 'object') return { kind: 'fallback' };
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;

  // 1) 명시적 animal
  const animal = data.animal;
  if (animal && typeof animal === 'object') {
    const a = animal as Record<string, unknown>;
    if (typeof a.emoji === 'string' && typeof a.ch === 'string') {
      return { kind: 'korean', emoji: a.emoji, ch: a.ch };
    }
  }
  const emojiField = typeof data.zodiacEmoji === 'string' ? (data.zodiacEmoji as string) : null;
  const chField = typeof data.zodiacChar === 'string' ? (data.zodiacChar as string) : null;
  if (emojiField && chField) return { kind: 'korean', emoji: emojiField, ch: chField };

  // 2) 키 기반
  const keys = [data.zodiacAnimal, data.zodiac, data.animalKey, data.sign, data.constellation];
  for (const keyRaw of keys) {
    if (typeof keyRaw !== 'string' || !keyRaw.trim()) continue;
    const trimmed = keyRaw.trim();
    const lower = trimmed.toLowerCase();

    // 서양 별자리
    const westernKey = CONSTELLATION_ALIASES[lower] ?? CONSTELLATION_ALIASES[trimmed];
    if (westernKey) {
      return { kind: 'western', info: CONSTELLATION_BY_KEY[westernKey]! };
    }

    // 동양 12지
    const koreanHit = KOREAN_ZODIAC_TO_CHAR[lower] ?? KOREAN_ZODIAC_TO_CHAR[trimmed];
    if (koreanHit) return { kind: 'korean', ...koreanHit };
  }

  return { kind: 'fallback' };
}

// ─────────────────────────────────────────────────────────────
// SVG building blocks
// ─────────────────────────────────────────────────────────────

const BACKDROP_STARS = Array.from({ length: 22 }, (_, i) => {
  // 결정적(deterministic) 배치 — useMemo 불필요, re-render 간 안정.
  const seed = i * 9301 + 49297;
  const rx = ((seed * 1.0 + i * 7) % 100) / 100;
  const ry = ((seed * 2.3 + i * 11) % 100) / 100;
  const rr = 0.6 + ((seed * 1.7) % 100) / 100;
  const ro = 0.25 + ((seed * 0.9) % 70) / 100;
  return { x: rx, y: ry, r: rr, o: ro };
});

interface SvgFrameProps {
  size: number;
  accent: string;
}

function ZodiacBackdrop({ size, accent }: SvgFrameProps) {
  return (
    <Svg width={size} height={size} style={{ position: 'absolute', top: 0, left: 0 }}>
      <Defs>
        <RadialGradient id="zodiacGlow" cx="50%" cy="50%" r="50%">
          <Stop offset="0%" stopColor={accent} stopOpacity={0.18} />
          <Stop offset="70%" stopColor={accent} stopOpacity={0} />
        </RadialGradient>
      </Defs>
      <Rect x={0} y={0} width={size} height={size} fill="url(#zodiacGlow)" />
      {/* 백드롭 별 — 잔잔한 트윙클 느낌 정적 구성 */}
      <G>
        {BACKDROP_STARS.map((s, i) => (
          <Circle
            key={i}
            cx={s.x * size}
            cy={s.y * size}
            r={s.r}
            fill="#FFFFFF"
            opacity={s.o}
          />
        ))}
      </G>
      {/* 2겹 장식 링 */}
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={size * 0.42}
        stroke={accent}
        strokeOpacity={0.35}
        strokeWidth={0.8}
        strokeDasharray="2 4"
        fill="none"
      />
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={size * 0.34}
        stroke={accent}
        strokeOpacity={0.18}
        strokeWidth={0.6}
        fill="none"
      />
    </Svg>
  );
}

function ConstellationLines({ size, info, accent }: SvgFrameProps & { info: ConstellationInfo }) {
  // 별자리는 내부 영역(0.18~0.82)에 맞춰 스케일
  const pad = size * 0.22;
  const inner = size - pad * 2;
  const toXY = ([x, y]: readonly [number, number]) => [pad + x * inner, pad + y * inner] as const;
  return (
    <Svg
      width={size}
      height={size}
      style={{ position: 'absolute', top: 0, left: 0 }}
    >
      <G>
        {info.edges.map(([a, b], i) => {
          const pa = info.stars[a];
          const pb = info.stars[b];
          if (!pa || !pb) return null;
          const [x1, y1] = toXY(pa);
          const [x2, y2] = toXY(pb);
          return (
            <Line
              key={`edge-${i}`}
              x1={x1}
              y1={y1}
              x2={x2}
              y2={y2}
              stroke={accent}
              strokeOpacity={0.45}
              strokeWidth={0.8}
            />
          );
        })}
        {info.stars.map((s, i) => {
          const [cx, cy] = toXY(s);
          return (
            <Circle
              key={`star-${i}`}
              cx={cx}
              cy={cy}
              r={1.8}
              fill={accent}
              opacity={0.9}
            />
          );
        })}
      </G>
    </Svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Main component
// ─────────────────────────────────────────────────────────────

interface HeroZodiacProps {
  data: unknown;
  progress?: number;
}

const SIZE = 176;

export default function HeroZodiac({ data: payload, progress = 1 }: HeroZodiacProps) {
  const p = clamp01(progress);
  const localStage = stage(p, 0, 0.5);
  const accentStage = stage(p, 0.3, 0.7);
  const revealScale = tween(easeOut(localStage), 0.8, 1);

  const identity = useMemo(() => resolveIdentity(payload), [payload]);

  const accent = identity.kind === 'western' ? SKY : AMBER;

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 20,
        paddingBottom: 12,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <View
        style={{
          width: SIZE,
          height: SIZE,
          alignItems: 'center',
          justifyContent: 'center',
          opacity: localStage,
          transform: [{ scale: revealScale }],
        }}
      >
        <ZodiacBackdrop size={SIZE} accent={accent} />

        {identity.kind === 'western' ? (
          <>
            <ConstellationLines size={SIZE} info={identity.info} accent={accent} />
            <Text
              style={{
                fontFamily: 'ZenSerif',
                fontSize: 72,
                color: accent,
                opacity: accentStage,
                lineHeight: 84,
              }}
            >
              {identity.info.symbol}
            </Text>
          </>
        ) : identity.kind === 'korean' ? (
          <>
            <Text
              style={{
                fontSize: 64,
                lineHeight: 78,
              }}
            >
              {identity.emoji}
            </Text>
            <Text
              style={{
                position: 'absolute',
                top: 14,
                right: 18,
                fontFamily: 'ZenSerif',
                fontSize: 22,
                color: AMBER,
                opacity: accentStage,
              }}
            >
              {identity.ch}
            </Text>
          </>
        ) : (
          <Text
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 64,
              color: VIOLET,
              lineHeight: 76,
              opacity: accentStage,
            }}
          >
            ✦
          </Text>
        )}
      </View>
    </View>
  );
}

/**
 * HeroPastLife — 전생 리딩 헤로 (claude.ai/design Past Life spec).
 *
 * 레이아웃:
 *   - 한지 질감 배경 (cream + subtle grain dots)
 *   - 4 모서리 CornerMotif (amber) + 골드(#C9A055) 3px 프레임 + shimmer glow
 *   - 3:4 민화풍 초상 (scale 0.85 → 1, 1100ms)
 *   - 이름 (ZenSerif 700 36px)
 *   - 얇은 ─── 구분선 + 신분(ko · en)
 *   - 시대 / 성별 / 배경 배지 (stagger 100ms)
 *
 * Animation cadence (mount time):
 *   phase 0 (0~400ms):     한지 배경 + 4 모서리 opacity 0→1
 *   phase 1 (400~900ms):   골드 프레임 shimmer 등장
 *   phase 2 (900~2000ms):  초상 scale 0.85→1 + opacity 0→1 (1100ms)
 *   phase 3 (1400~2000ms): 이름 페이드인
 *   phase 4 (1700~2200ms): 신분 페이드인
 *   phase 5 (1900~2400ms): 배지 row 순차 (stagger 100ms)
 */
import { useEffect, useRef } from 'react';
import { Animated, Easing, Image, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { CornerMotif } from '../../ios-widgets/primitives/corner-motif';

const AMBER = '#E0A76B';
const GOLD_FRAME = '#C9A055';
const HANJI_CREAM = '#F4ECD8';

const ERA_COLOR: Record<string, string> = {
  early_joseon: '#3B82F6',
  middle_joseon: '#22C55E',
  late_joseon: '#F59E0B',
};

const ERA_LABEL: Record<string, string> = {
  early_joseon: '초기 조선',
  middle_joseon: '중기 조선',
  late_joseon: '후기 조선',
};

const GENDER_LABEL: Record<string, string> = {
  male: '남성',
  female: '여성',
};

export interface HeroPastLifeProps {
  /** Primary structured shape used by the embedded card path. */
  data?: unknown;
  progress?: number;
  // Optional direct props for screen-level usage.
  portraitUrl?: string;
  pastLifeName?: string;
  pastLifeStatus?: string;
  pastLifeStatusEn?: string;
  pastLifeEra?: string;
  pastLifeGender?: string;
  scenarioCategory?: string;
}

type RawPastLife = {
  portraitUrl?: unknown;
  pastLifeName?: unknown;
  pastLifeStatus?: unknown;
  pastLifeStatusEn?: unknown;
  pastLifeEra?: unknown;
  pastLifeGender?: unknown;
  scenarioCategory?: unknown;
};

function pickString(value: unknown): string | undefined {
  if (typeof value === 'string' && value.trim()) return value.trim();
  return undefined;
}

function extractPastLifeFields(data: unknown): RawPastLife {
  if (!data || typeof data !== 'object') return {};
  const root = data as Record<string, unknown>;
  const raw = (root.rawApiResponse ?? {}) as Record<string, unknown>;
  const fortune = (raw.fortune ?? raw.data ?? raw) as Record<string, unknown>;

  return {
    portraitUrl: root.portraitUrl ?? fortune.portraitUrl,
    pastLifeName: root.pastLifeName ?? fortune.pastLifeName,
    pastLifeStatus: root.pastLifeStatus ?? fortune.pastLifeStatus,
    pastLifeStatusEn: root.pastLifeStatusEn ?? fortune.pastLifeStatusEn,
    pastLifeEra: root.pastLifeEra ?? fortune.pastLifeEra,
    pastLifeGender: root.pastLifeGender ?? fortune.pastLifeGender,
    scenarioCategory: root.scenarioCategory ?? fortune.scenarioCategory,
  };
}

/** Lightweight grain: 12 faint dots randomly positioned across the hero. */
const GRAIN_DOTS: Array<{ top: `${number}%`; left: `${number}%`; size: number; op: number }> = [
  { top: '8%', left: '12%', size: 2, op: 0.22 },
  { top: '18%', left: '78%', size: 1.5, op: 0.18 },
  { top: '26%', left: '34%', size: 2.5, op: 0.2 },
  { top: '38%', left: '62%', size: 1.5, op: 0.16 },
  { top: '47%', left: '22%', size: 2, op: 0.22 },
  { top: '55%', left: '88%', size: 1, op: 0.14 },
  { top: '63%', left: '48%', size: 2, op: 0.18 },
  { top: '71%', left: '14%', size: 1.5, op: 0.2 },
  { top: '78%', left: '72%', size: 2.5, op: 0.22 },
  { top: '85%', left: '38%', size: 1, op: 0.14 },
  { top: '91%', left: '86%', size: 1.5, op: 0.16 },
  { top: '12%', left: '52%', size: 1, op: 0.14 },
];

export default function HeroPastLife(props: HeroPastLifeProps) {
  const {
    data,
    progress,
    portraitUrl: portraitUrlProp,
    pastLifeName: nameProp,
    pastLifeStatus: statusProp,
    pastLifeStatusEn: statusEnProp,
    pastLifeEra: eraProp,
    pastLifeGender: genderProp,
    scenarioCategory: scenarioProp,
  } = props;

  const extracted = extractPastLifeFields(data);
  const portraitUrl = portraitUrlProp ?? pickString(extracted.portraitUrl);
  const pastLifeName = nameProp ?? pickString(extracted.pastLifeName);
  const pastLifeStatus = statusProp ?? pickString(extracted.pastLifeStatus);
  const pastLifeStatusEn =
    statusEnProp ?? pickString(extracted.pastLifeStatusEn);
  const pastLifeEra = eraProp ?? pickString(extracted.pastLifeEra);
  const pastLifeGender = genderProp ?? pickString(extracted.pastLifeGender);
  const scenarioCategory = scenarioProp ?? pickString(extracted.scenarioCategory);

  // ── Animation values ─────────────────────────────────────────
  // phase 0: background + corner motifs
  const bgAnim = useRef(new Animated.Value(0)).current;
  // phase 1: gold frame + shimmer
  const frameAnim = useRef(new Animated.Value(0)).current;
  const shimmerAnim = useRef(new Animated.Value(0)).current;
  // phase 2: portrait scale + opacity
  const portraitAnim = useRef(new Animated.Value(0)).current;
  // phase 3/4: name + status
  const nameAnim = useRef(new Animated.Value(0)).current;
  const statusAnim = useRef(new Animated.Value(0)).current;
  // phase 5: badges (era, gender, scenario) staggered
  const eraBadgeAnim = useRef(new Animated.Value(0)).current;
  const genderBadgeAnim = useRef(new Animated.Value(0)).current;
  const scenarioBadgeAnim = useRef(new Animated.Value(0)).current;

  // Drive the mount-time absolute timeline. If `progress` is explicitly
  // provided (embedded card path), snap all values to it instead.
  useEffect(() => {
    if (typeof progress === 'number') {
      const p = Math.max(0, Math.min(1, progress));
      [
        bgAnim,
        frameAnim,
        shimmerAnim,
        portraitAnim,
        nameAnim,
        statusAnim,
        eraBadgeAnim,
        genderBadgeAnim,
        scenarioBadgeAnim,
      ].forEach((v) => v.setValue(p));
      return;
    }

    Animated.parallel([
      // phase 0 (0–400)
      Animated.timing(bgAnim, {
        toValue: 1,
        duration: 400,
        delay: 0,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      // phase 1 (400–900)
      Animated.timing(frameAnim, {
        toValue: 1,
        duration: 500,
        delay: 400,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      // phase 2 (900–2000) — 1100ms portrait
      Animated.timing(portraitAnim, {
        toValue: 1,
        duration: 1100,
        delay: 900,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      // phase 3 (1400–2000)
      Animated.timing(nameAnim, {
        toValue: 1,
        duration: 600,
        delay: 1400,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      // phase 4 (1700–2200)
      Animated.timing(statusAnim, {
        toValue: 1,
        duration: 500,
        delay: 1700,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      // phase 5 (1900–2400) — stagger 100ms
      Animated.timing(eraBadgeAnim, {
        toValue: 1,
        duration: 400,
        delay: 1900,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      Animated.timing(genderBadgeAnim, {
        toValue: 1,
        duration: 400,
        delay: 2000,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      Animated.timing(scenarioBadgeAnim, {
        toValue: 1,
        duration: 400,
        delay: 2100,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();

    // Shimmer: subtle glow pulse starting at phase 1.
    const shimmerLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(shimmerAnim, {
          toValue: 1,
          duration: 1600,
          delay: 400,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(shimmerAnim, {
          toValue: 0,
          duration: 1600,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    );
    shimmerLoop.start();

    return () => {
      shimmerLoop.stop();
    };
  }, [
    progress,
    bgAnim,
    frameAnim,
    shimmerAnim,
    portraitAnim,
    nameAnim,
    statusAnim,
    eraBadgeAnim,
    genderBadgeAnim,
    scenarioBadgeAnim,
  ]);

  const portraitScale = portraitAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.85, 1],
  });

  const shimmerOpacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.75],
  });

  const eraColor = pastLifeEra ? ERA_COLOR[pastLifeEra] ?? AMBER : AMBER;
  const eraLabel = pastLifeEra
    ? ERA_LABEL[pastLifeEra] ?? pastLifeEra
    : undefined;
  const genderLabel = pastLifeGender
    ? GENDER_LABEL[pastLifeGender] ?? pastLifeGender
    : undefined;

  return (
    <Animated.View
      style={{
        opacity: bgAnim,
        paddingVertical: 22,
        paddingHorizontal: 20,
        backgroundColor: withAlpha(HANJI_CREAM, 0.06),
        borderRadius: 14,
        borderWidth: 1,
        borderColor: withAlpha(AMBER, 0.22),
        alignItems: 'center',
        gap: 14,
        overflow: 'hidden',
      }}
    >
      {/* Hanji grain dots overlay */}
      {GRAIN_DOTS.map((d, i) => (
        <View
          key={`grain-${i}`}
          pointerEvents="none"
          style={{
            position: 'absolute',
            top: d.top,
            left: d.left,
            width: d.size,
            height: d.size,
            borderRadius: d.size / 2,
            backgroundColor: withAlpha('#8B6A3A', d.op),
          }}
        />
      ))}

      {/* Four corner motifs */}
      <CornerMotif
        size={22}
        color={withAlpha(AMBER, 0.3)}
        style={{ top: 6, left: 6 }}
      />
      <CornerMotif
        size={22}
        color={withAlpha(AMBER, 0.3)}
        style={{ top: 6, right: 6 }}
      />
      <CornerMotif
        size={22}
        color={withAlpha(AMBER, 0.3)}
        style={{ bottom: 6, left: 6 }}
      />
      <CornerMotif
        size={22}
        color={withAlpha(AMBER, 0.3)}
        style={{ bottom: 6, right: 6 }}
      />

      {/* Portrait with gold frame + shimmer */}
      <Animated.View
        style={{
          width: '86%',
          aspectRatio: 3 / 4,
          opacity: portraitAnim,
          transform: [{ scale: portraitScale }],
        }}
      >
        {/* Shimmer glow — pulsing halo */}
        <Animated.View
          pointerEvents="none"
          style={{
            position: 'absolute',
            top: -6,
            left: -6,
            right: -6,
            bottom: -6,
            borderRadius: 18,
            borderWidth: 1,
            borderColor: withAlpha(GOLD_FRAME, 0.55),
            opacity: Animated.multiply(frameAnim, shimmerOpacity),
          }}
        />
        {/* Outer gold ring */}
        <Animated.View
          style={{
            position: 'absolute',
            top: -3,
            left: -3,
            right: -3,
            bottom: -3,
            borderRadius: 15,
            borderWidth: 1,
            borderColor: withAlpha(GOLD_FRAME, 0.45),
            opacity: frameAnim,
          }}
        />
        {/* Main 3px gold frame */}
        <Animated.View
          style={{
            flex: 1,
            borderRadius: 12,
            borderWidth: 3,
            borderColor: GOLD_FRAME,
            overflow: 'hidden',
            backgroundColor: withAlpha(HANJI_CREAM, 0.08),
            alignItems: 'center',
            justifyContent: 'center',
            opacity: frameAnim,
          }}
        >
          {portraitUrl ? (
            <Image
              source={{ uri: portraitUrl, cache: 'force-cache' }}
              style={{ width: '100%', height: '100%' }}
              resizeMode="cover"
            />
          ) : (
            <AppText style={{ fontSize: 64, lineHeight: 72 }}>🏯</AppText>
          )}
        </Animated.View>
      </Animated.View>

      {/* Name (ZenSerif 700 36px) */}
      {pastLifeName ? (
        <Animated.View
          style={{ opacity: nameAnim, alignItems: 'center', width: '100%' }}
        >
          <AppText
            style={{
              fontFamily: 'ZenSerif',
              fontSize: 36,
              lineHeight: 44,
              fontWeight: '700',
              color: fortuneTheme.colors.textPrimary,
              textAlign: 'center',
            }}
          >
            {pastLifeName}
          </AppText>
        </Animated.View>
      ) : null}

      {/* ─── divider + status (ko · en) ─── */}
      {pastLifeStatus || pastLifeStatusEn ? (
        <Animated.View
          style={{
            opacity: statusAnim,
            flexDirection: 'row',
            alignItems: 'center',
            gap: 8,
            width: '100%',
            paddingHorizontal: 12,
          }}
        >
          <View
            style={{
              flex: 1,
              height: 1,
              backgroundColor: withAlpha(AMBER, 0.3),
            }}
          />
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ letterSpacing: 1 }}
          >
            {pastLifeStatus ?? ''}
            {pastLifeStatus && pastLifeStatusEn ? ' · ' : ''}
            {pastLifeStatusEn ?? ''}
          </AppText>
          <View
            style={{
              flex: 1,
              height: 1,
              backgroundColor: withAlpha(AMBER, 0.3),
            }}
          />
        </Animated.View>
      ) : null}

      {/* Badges (era · gender · scenario) — staggered */}
      {eraLabel || genderLabel || scenarioCategory ? (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            justifyContent: 'center',
            gap: 6,
          }}
        >
          {eraLabel ? (
            <Animated.View
              style={{
                opacity: eraBadgeAnim,
                paddingHorizontal: 10,
                paddingVertical: 4,
                borderRadius: 999,
                backgroundColor: withAlpha(eraColor, 0.18),
                borderWidth: 1,
                borderColor: withAlpha(eraColor, 0.5),
              }}
            >
              <AppText variant="labelMedium" color={eraColor}>
                {eraLabel}
              </AppText>
            </Animated.View>
          ) : null}
          {genderLabel ? (
            <Animated.View
              style={{
                opacity: genderBadgeAnim,
                paddingHorizontal: 10,
                paddingVertical: 4,
                borderRadius: 999,
                backgroundColor: withAlpha(AMBER, 0.12),
                borderWidth: 1,
                borderColor: withAlpha(AMBER, 0.5),
              }}
            >
              <AppText variant="labelMedium" color={AMBER}>
                {genderLabel}
              </AppText>
            </Animated.View>
          ) : null}
          {scenarioCategory ? (
            <Animated.View
              style={{
                opacity: scenarioBadgeAnim,
                paddingHorizontal: 10,
                paddingVertical: 4,
                borderRadius: 999,
                backgroundColor: withAlpha(AMBER, 0.1),
                borderWidth: 1,
                borderColor: withAlpha(AMBER, 0.35),
              }}
            >
              <AppText
                variant="labelMedium"
                color={fortuneTheme.colors.textSecondary}
              >
                {scenarioCategory}
              </AppText>
            </Animated.View>
          ) : null}
        </View>
      ) : null}
    </Animated.View>
  );
}

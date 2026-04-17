import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  HeroCard,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Type helpers for the raw face-reading API response                 */
/* ------------------------------------------------------------------ */

type R = Record<string, unknown>;

function obj(val: unknown): R {
  return val != null && typeof val === 'object' && !Array.isArray(val)
    ? (val as R)
    : {};
}

function str(val: unknown, fallback = ''): string {
  return typeof val === 'string' && val.trim() ? val.trim() : fallback;
}

function num(val: unknown, fallback = 0): number {
  if (typeof val === 'number' && !Number.isNaN(val)) return val;
  if (typeof val === 'string') {
    const n = Number(val);
    if (!Number.isNaN(n)) return n;
  }
  return fallback;
}

function arr(val: unknown): unknown[] {
  return Array.isArray(val) ? val : [];
}

function strArr(val: unknown): string[] {
  return arr(val)
    .map((v) => str(v))
    .filter(Boolean);
}

/* ------------------------------------------------------------------ */
/*  Ogwan feature card (ear, eyebrow, eye, nose, mouth)               */
/* ------------------------------------------------------------------ */

const OGWAN_LABELS: Record<string, { emoji: string; label: string }> = {
  ear: { emoji: '👂', label: '귀' },
  eyebrow: { emoji: '🔳', label: '눈썹' },
  eye: { emoji: '👁️', label: '눈' },
  nose: { emoji: '👃', label: '코' },
  mouth: { emoji: '👄', label: '입' },
};

function OgwanFeatureCard({
  featureKey,
  data,
}: {
  featureKey: string;
  data: R;
}) {
  const meta = OGWAN_LABELS[featureKey] ?? { emoji: '🔍', label: featureKey };
  const observation = str(data.observation, '관찰 데이터 없음');
  const interpretation = str(data.interpretation, '해석 데이터 없음');
  const score = num(data.score, 70);
  const advice = str(data.advice);
  const clampedScore = Math.max(0, Math.min(100, score));

  return (
    <Card>
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <AppText variant="heading4">{meta.emoji} {meta.label}</AppText>
          </View>
          <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
            {clampedScore}점
          </AppText>
        </View>

        {/* Score bar */}
        <View
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.full,
            height: 8,
            overflow: 'hidden',
          }}
        >
          <View
            style={{
              backgroundColor: fortuneTheme.colors.ctaBackground,
              borderRadius: fortuneTheme.radius.full,
              height: '100%',
              width: `${clampedScore}%`,
            }}
          />
        </View>

        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            관찰
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {observation}
          </AppText>
        </View>

        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            해석
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {interpretation}
          </AppText>
        </View>

        {advice ? (
          <InsetQuote text={advice} />
        ) : null}
      </View>
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  Samjeong period card (upper, middle, lower)                        */
/* ------------------------------------------------------------------ */

const SAMJEONG_LABELS: Record<string, { emoji: string; label: string }> = {
  upper: { emoji: '🌱', label: '초년운 (상정)' },
  middle: { emoji: '☀️', label: '중년운 (중정)' },
  lower: { emoji: '🌙', label: '말년운 (하정)' },
};

function SamjeongPeriodCard({
  periodKey,
  data,
}: {
  periodKey: string;
  data: R;
}) {
  const meta = SAMJEONG_LABELS[periodKey] ?? { emoji: '📅', label: periodKey };
  const period = str(data.period, meta.label);
  const description = str(data.description, '기간 설명 없음');
  const peakAge = str(data.peakAge);
  const score = num(data.score, 70);
  const clampedScore = Math.max(0, Math.min(100, score));

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        gap: fortuneTheme.spacing.sm,
      }}
    >
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <AppText variant="heading4">{meta.emoji} {period}</AppText>
        <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
          {clampedScore}점
        </AppText>
      </View>

      {/* Score bar */}
      <View
        style={{
          backgroundColor: fortuneTheme.colors.background,
          borderRadius: fortuneTheme.radius.full,
          height: 8,
          overflow: 'hidden',
        }}
      >
        <View
          style={{
            backgroundColor: fortuneTheme.colors.ctaBackground,
            borderRadius: fortuneTheme.radius.full,
            height: '100%',
            width: `${clampedScore}%`,
          }}
        />
      </View>

      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {description}
      </AppText>

      {peakAge ? (
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          전성기: {peakAge}
        </AppText>
      ) : null}
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  Fortune category score card                                        */
/* ------------------------------------------------------------------ */

const FORTUNE_LABELS: Record<string, { emoji: string; label: string }> = {
  wealth: { emoji: '💰', label: '재물운' },
  love: { emoji: '💕', label: '연애운' },
  career: { emoji: '💼', label: '직업운' },
  health: { emoji: '💪', label: '건강운' },
  overall: { emoji: '🌟', label: '종합운' },
};

/* ------------------------------------------------------------------ */
/*  Main FaceReadingResult component                                   */
/* ------------------------------------------------------------------ */

export function FaceReadingResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['face-reading'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract structured data from raw API response ---
  const overview = obj(raw.overview);
  const ogwan = obj(raw.ogwan);
  const samjeong = obj(raw.samjeong);
  const personality = obj(raw.personality);
  const fortunes = obj(raw.fortunes);
  const specialFeatures = arr(raw.specialFeatures);
  const faceTypeClassification = obj(raw.faceTypeClassification);
  const firstImpression = obj(raw.firstImpression);
  const compatibility = obj(raw.compatibility);
  const improvements = obj(raw.improvements);

  const hasRaw = Object.keys(raw).length > 0;

  // --- Section 1: Hero ---
  const faceType = str(overview.faceType, '분석 중');
  const faceElement = str(overview.faceTypeElement);
  const overallBlessingScore = num(overview.overallBlessingScore, result.score ?? 75);
  const heroFirstImpression = str(
    overview.firstImpression,
    result.summary || '얼굴의 균형과 오관, 삼정을 종합적으로 분석하여 흐름과 성격, 개운법까지 한눈에 정리한 프리미엄 관상 리포트입니다.',
  );

  const heroChips = result.contextTags.length > 0
    ? result.contextTags
    : [faceType, faceElement, '관상 분석'].filter(Boolean);

  // --- Section 2: Animal Type ---
  const animalType = obj(faceTypeClassification.animalType);
  const impressionType = obj(faceTypeClassification.impressionType);
  const primaryAnimal = str(animalType.primary, '분석 중');
  const secondaryAnimal = str(animalType.secondary);
  const animalMatchScore = num(animalType.matchScore, 80);
  const animalDescription = str(animalType.description, '동물상 분석 결과입니다.');
  const animalTraits = strArr(animalType.traits);

  // --- Section 3: Ogwan (5 features) ---
  const ogwanKeys = ['ear', 'eyebrow', 'eye', 'nose', 'mouth'] as const;

  // --- Section 4: Samjeong (3 periods) ---
  const samjeongKeys = ['upper', 'middle', 'lower'] as const;
  const samjeongBalance = str(samjeong.balance);
  const samjeongBalanceDesc = str(samjeong.balanceDescription);

  // --- Section 5: Fortunes ---
  const fortuneKeys = ['wealth', 'love', 'career', 'health', 'overall'] as const;
  const fortuneStatItems = fortuneKeys
    .map((key) => {
      const f = obj(fortunes[key]);
      const fMeta = FORTUNE_LABELS[key]!;
      return {
        label: `${fMeta.emoji} ${fMeta.label}`,
        value: num(f.score, 70),
        highlight: str(f.summary),
      };
    });

  // --- Section 6: Special Features ---
  const specialBadges = specialFeatures
    .map((f) => {
      const feat = obj(f);
      return {
        name: str(feat.name),
        type: str(feat.type),
        description: str(feat.description),
      };
    })
    .filter((f) => f.name);

  // --- Section 7: First Impression ---
  const trustScore = num(firstImpression.trustScore, 75);
  const trustDescription = str(firstImpression.trustDescription);
  const approachabilityScore = num(firstImpression.approachabilityScore, 75);
  const charismaScore = num(firstImpression.charismaScore, 75);

  // --- Section 8: Improvements ---
  const dailyImprovements = strArr(improvements.daily);
  const appearanceImprovements = strArr(improvements.appearance);
  const luckyColors = strArr(improvements.luckyColors);
  const luckyDirections = strArr(improvements.luckyDirections);

  // --- Personality traits ---
  const traits = strArr(personality.traits);
  const strengths = strArr(personality.strengths);
  const growthAreas = strArr(personality.growthAreas);

  // --- Compatibility ---
  const idealPartnerType = str(compatibility.idealPartnerType);
  const idealPartnerDescription = str(compatibility.idealPartnerDescription);

  // --- Fallback metrics from useResultData when no raw data ---
  const fallbackMetrics = result.metrics.length > 0
    ? result.metrics
    : [
        { label: '복점수', value: String(overallBlessingScore), note: '전체 관상 복 점수' },
        { label: '얼굴형', value: faceType, note: faceElement || '오행 기반 분류' },
        { label: '신뢰도', value: String(trustScore), note: '첫인상 신뢰 점수' },
        { label: '카리스마', value: String(charismaScore), note: '존재감 점수' },
      ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Section 1: Hero - 전체 복점수, 얼굴형, 첫인상 요약              */}
      {/* ============================================================ */}
      <HeroCard
        emoji="🔮"
        title={meta.title}
        description={heroFirstImpression}
        chips={heroChips}
        aside={
          <View
            style={{
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.lg,
              paddingVertical: fortuneTheme.spacing.sm,
              paddingHorizontal: fortuneTheme.spacing.md,
              minWidth: 80,
            }}
          >
            <AppText variant="displaySmall" color={fortuneTheme.colors.accentSecondary}>
              {overallBlessingScore}
            </AppText>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              복점수
            </AppText>
          </View>
        }
      />

      {!hasRaw && (
        <SectionCard title="관상 요약">
          <MetricGrid items={fallbackMetrics} />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 2: Animal Type - 동물상                               */}
      {/* ============================================================ */}
      {hasRaw && primaryAnimal && primaryAnimal !== '분석 중' && (
        <SectionCard title="동물상 분석" description="얼굴 특징에서 읽히는 동물상 유형입니다.">
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              gap: fortuneTheme.spacing.md,
              alignItems: 'center',
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <AppText style={{ fontSize: 48, lineHeight: 56 }}>
              {primaryAnimal.includes('강아지') || primaryAnimal.includes('개')
                ? '🐶'
                : primaryAnimal.includes('고양이')
                  ? '🐱'
                  : primaryAnimal.includes('여우')
                    ? '🦊'
                    : primaryAnimal.includes('곰')
                      ? '🐻'
                      : primaryAnimal.includes('토끼')
                        ? '🐰'
                        : primaryAnimal.includes('사슴')
                          ? '🦌'
                          : primaryAnimal.includes('늑대')
                            ? '🐺'
                            : primaryAnimal.includes('호랑이')
                              ? '🐯'
                              : '🪞'}
            </AppText>
            <AppText variant="heading2">{primaryAnimal}</AppText>
            {secondaryAnimal ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                서브: {secondaryAnimal}
              </AppText>
            ) : null}
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                매칭도
              </AppText>
              <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                {animalMatchScore}%
              </AppText>
            </View>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
            >
              {animalDescription}
            </AppText>
            {animalTraits.length > 0 ? <KeywordPills keywords={animalTraits} /> : null}
          </Card>

          {str(impressionType.type) ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <MetricGrid
                items={[
                  {
                    label: '인상 유형',
                    value: str(impressionType.type),
                    note: str(impressionType.description),
                  },
                  {
                    label: '인상 매칭도',
                    value: `${num(impressionType.matchScore, 80)}%`,
                    note: '전체 인상에서의 매칭 점수',
                  },
                ]}
              />
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 3: Ogwan - 오관 분석 (5 cards)                        */}
      {/* ============================================================ */}
      {hasRaw && (
        <SectionCard title="오관 분석" description="귀, 눈썹, 눈, 코, 입 다섯 부위의 관상 해석입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {ogwanKeys.map((key) => {
              const featureData = obj(ogwan[key]);
              if (Object.keys(featureData).length === 0) return null;
              return <OgwanFeatureCard key={key} featureKey={key} data={featureData} />;
            })}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 4: Samjeong - 삼정 (3 life periods)                   */}
      {/* ============================================================ */}
      {hasRaw && (
        <SectionCard title="삼정 분석" description="초년, 중년, 말년 세 시기의 흐름 분석입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {samjeongKeys.map((key) => {
              const periodData = obj(samjeong[key]);
              if (Object.keys(periodData).length === 0) return null;
              return <SamjeongPeriodCard key={key} periodKey={key} data={periodData} />;
            })}
          </View>

          {samjeongBalance || samjeongBalanceDesc ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <InsetQuote
                text={
                  samjeongBalance
                    ? `균형도: ${samjeongBalance}${samjeongBalanceDesc ? ` — ${samjeongBalanceDesc}` : ''}`
                    : samjeongBalanceDesc
                }
              />
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 5: Fortunes - 흐름 (재물/연애/직업/건강/종합)            */}
      {/* ============================================================ */}
      {hasRaw && (
        <SectionCard title="흐름 분석" description="관상에서 읽히는 다섯 가지 흐름 분석입니다.">
          <StatRail items={fortuneStatItems} />

          {/* Fortune detail cards */}
          <View style={{ gap: fortuneTheme.spacing.sm, marginTop: fortuneTheme.spacing.sm }}>
            {fortuneKeys.map((key) => {
              const f = obj(fortunes[key]);
              const detail = str(f.detail);
              const advice = str(f.advice);
              if (!detail && !advice) return null;
              const fMeta = FORTUNE_LABELS[key]!;
              return (
                <Card
                  key={key}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.xs,
                  }}
                >
                  <AppText variant="labelLarge">
                    {fMeta.emoji} {fMeta.label}
                  </AppText>
                  {detail ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {detail}
                    </AppText>
                  ) : null}
                  {advice ? (
                    <InsetQuote text={advice} />
                  ) : null}
                  {key === 'health' ? (
                    <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                      의료 진단이 아닙니다
                    </AppText>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 5.5: Personality                                     */}
      {/* ============================================================ */}
      {hasRaw && (traits.length > 0 || strengths.length > 0 || growthAreas.length > 0) && (
        <SectionCard title="성격 분석" description="관상에서 읽히는 성격 특성입니다.">
          {traits.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                핵심 특성
              </AppText>
              <KeywordPills keywords={traits} />
            </View>
          ) : null}
          {strengths.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                강점
              </AppText>
              <BulletList items={strengths} accent="강점" />
            </View>
          ) : null}
          {growthAreas.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                성장 포인트
              </AppText>
              <BulletList items={growthAreas} accent="성장" />
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 6: Special Features - 특수상                          */}
      {/* ============================================================ */}
      {hasRaw && specialBadges.length > 0 && (
        <SectionCard title="특수상" description="관상에서 발견된 특별한 상입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {specialBadges.map((badge, index) => (
              <Card
                key={`${badge.name}-${index}`}
                style={{
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: fortuneTheme.spacing.xs,
                  }}
                >
                  <AppText variant="heading4">
                    {badge.type === 'positive' ? '✨' : badge.type === 'neutral' ? '📎' : '⚡'}{' '}
                    {badge.name}
                  </AppText>
                </View>
                {badge.description ? (
                  <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                    {badge.description}
                  </AppText>
                ) : null}
              </Card>
            ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 7: First Impression - 첫인상 점수                     */}
      {/* ============================================================ */}
      {hasRaw && (
        <SectionCard title="첫인상 분석" description="타인에게 주는 첫인상 점수입니다.">
          <StatRail
            items={[
              {
                label: '🤝 신뢰도',
                value: trustScore,
                highlight: trustDescription || '주변 사람에게 주는 신뢰감입니다.',
              },
              {
                label: '😊 친근감',
                value: approachabilityScore,
                highlight: '다가가기 쉬운 인상의 정도입니다.',
              },
              {
                label: '🔥 카리스마',
                value: charismaScore,
                highlight: '존재감과 리더십이 느껴지는 정도입니다.',
              },
            ]}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 7.5: Compatibility                                   */}
      {/* ============================================================ */}
      {hasRaw && (idealPartnerType || idealPartnerDescription) && (
        <SectionCard title="이상형 궁합" description="관상에서 읽히는 이상적인 파트너 유형입니다.">
          <MetricGrid
            items={[
              ...(idealPartnerType
                ? [{
                    label: '이상형 유형',
                    value: idealPartnerType,
                    note: idealPartnerDescription || '관상 기반 이상형 분석',
                  }]
                : []),
              ...(num(compatibility.compatibilityScore)
                ? [{
                    label: '궁합 적합도',
                    value: `${num(compatibility.compatibilityScore)}점`,
                    note: '이상형과의 궁합 점수',
                  }]
                : []),
            ]}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 8: Improvements - 개운법                              */}
      {/* ============================================================ */}
      {hasRaw && (
        dailyImprovements.length > 0 ||
        appearanceImprovements.length > 0 ||
        luckyColors.length > 0 ||
        luckyDirections.length > 0
      ) && (
        <SectionCard title="개운법" description="운을 끌어올리는 실천 가이드입니다.">
          {luckyColors.length > 0 || luckyDirections.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.sm }}>
              {luckyColors.length > 0 ? (
                <View style={{ gap: fortuneTheme.spacing.xs }}>
                  <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                    🎨 행운 색상
                  </AppText>
                  <KeywordPills keywords={luckyColors} />
                </View>
              ) : null}
              {luckyDirections.length > 0 ? (
                <View style={{ gap: fortuneTheme.spacing.xs }}>
                  <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                    🧭 행운 방위
                  </AppText>
                  <KeywordPills keywords={luckyDirections} />
                </View>
              ) : null}
            </View>
          ) : null}

          {dailyImprovements.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                📋 일상 실천
              </AppText>
              <BulletList items={dailyImprovements} accent="실천" />
            </View>
          ) : null}

          {appearanceImprovements.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                💄 외모 포인트
              </AppText>
              <BulletList items={appearanceImprovements} accent="외모" />
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Fallback sections when no raw data                           */}
      {/* ============================================================ */}
      {!hasRaw && result.highlights.length > 0 && (
        <SectionCard title="핵심 포인트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}

      {!hasRaw && result.recommendations.length > 0 && (
        <SectionCard title="추천 행동">
          <BulletList items={result.recommendations} />
        </SectionCard>
      )}

      {result.specialTip && (
        <SectionCard title="관상 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}

      {result.luckyItems.length > 0 && (
        <SectionCard title="행운 포인트">
          <KeywordPills keywords={result.luckyItems} />
        </SectionCard>
      )}
    </View>
  );
}

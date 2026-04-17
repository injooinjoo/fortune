import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import {
  BIRTHSTONE_COMPATIBILITY,
  getBirthstoneFromDate,
  getMonthlyBirthstone,
} from '../../../lib/birthstone-data';
import { fortuneTheme } from '../../../lib/theme';
import { useMobileAppState } from '../../../providers/mobile-app-state-provider';
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
/*  Type helpers for safe access to raw API response                   */
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
/*  Main BirthstoneResult component                                    */
/* ------------------------------------------------------------------ */

export function BirthstoneResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['birthstone'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Derive birth month/day from user profile ---
  const { state } = useMobileAppState();
  const birthDate = state.profile.birthDate;
  const { monthly, daily } = getBirthstoneFromDate(birthDate || '2000-01-01');

  // --- Extract structured API data ---
  const categories = obj(raw.categories);
  const luckyItems = strArr(raw.luckyItems);
  const advice = str(raw.advice);
  const overallScore = num(raw.score, result.score ?? 78);
  const summary = str(
    raw.summary,
    result.summary ||
      `${monthly.month}월의 탄생석 ${monthly.name}(${monthly.nameEn})의 기운을 바탕으로 오늘의 흐름을 읽었습니다.`,
  );

  // Category scores from API
  const categoryKeys = ['wealth', 'love', 'career', 'health', 'overall'] as const;
  const CATEGORY_LABELS: Record<string, { emoji: string; label: string }> = {
    wealth: { emoji: '💰', label: '재물운' },
    love: { emoji: '💕', label: '연애운' },
    career: { emoji: '💼', label: '직업운' },
    health: { emoji: '💪', label: '건강운' },
    overall: { emoji: '🌟', label: '종합운' },
  };

  const categoryStatItems = categoryKeys
    .map((key) => {
      const c = obj(categories[key]);
      const catMeta = CATEGORY_LABELS[key]!;
      return {
        label: `${catMeta.emoji} ${catMeta.label}`,
        value: num(c.score, 70),
        highlight: str(c.summary),
      };
    })
    .filter((item) => item.value > 0 || item.highlight);

  // Compatibility months
  const compatibleMonths = BIRTHSTONE_COMPATIBILITY[monthly.month] ?? [];
  const compatibleStones = compatibleMonths.map((m) => getMonthlyBirthstone(m));

  // Hero chips
  const heroChips = result.contextTags.length > 0
    ? result.contextTags
    : [monthly.name, monthly.nameEn, monthly.meaning].filter(Boolean);

  // Fallback metrics
  const fallbackMetrics = result.metrics.length > 0
    ? result.metrics
    : [
        { label: '탄생석', value: monthly.name, note: `${monthly.nameEn}` },
        { label: '종합 점수', value: String(overallScore), note: '탄생석 인사이트 점수' },
        { label: '의미', value: monthly.meaning, note: `${monthly.month}월 탄생석` },
        ...(daily
          ? [{ label: '일별 탄생석', value: daily.name, note: daily.nameEn }]
          : []),
      ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Section 1: Hero - 큰 보석 이모지, 월 이름, 탄생석 이름           */}
      {/* ============================================================ */}
      <HeroCard
        emoji={monthly.emoji}
        title={meta.title}
        description={summary}
        chips={heroChips}
        aside={
          <View
            style={{
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: `${monthly.color}20`,
              borderRadius: fortuneTheme.radius.lg,
              paddingVertical: fortuneTheme.spacing.sm,
              paddingHorizontal: fortuneTheme.spacing.md,
              minWidth: 80,
            }}
          >
            <AppText style={{ fontSize: 48, lineHeight: 56 }}>
              {monthly.emoji}
            </AppText>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              {monthly.month}월
            </AppText>
          </View>
        }
      />

      {/* ============================================================ */}
      {/*  Section 2: Monthly Birthstone Card                           */}
      {/* ============================================================ */}
      <SectionCard
        title={`${monthly.month}월의 탄생석`}
        description="당신의 생월에 해당하는 탄생석 정보입니다."
      >
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            gap: fortuneTheme.spacing.md,
            alignItems: 'center',
            paddingVertical: fortuneTheme.spacing.lg,
          }}
        >
          <AppText style={{ fontSize: 72, lineHeight: 80 }}>
            {monthly.emoji}
          </AppText>
          <AppText variant="heading2">
            {monthly.name} ({monthly.nameEn})
          </AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center' }}
          >
            {monthly.meaning}
          </AppText>

          {/* Color swatch */}
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: fortuneTheme.spacing.sm,
              marginTop: fortuneTheme.spacing.xs,
            }}
          >
            <View
              style={{
                width: 24,
                height: 24,
                borderRadius: fortuneTheme.radius.full,
                backgroundColor: monthly.color,
                borderWidth: 1,
                borderColor: fortuneTheme.colors.border,
              }}
            />
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              {monthly.color}
            </AppText>
          </View>
        </Card>

        {!hasRaw && <MetricGrid items={fallbackMetrics} />}
      </SectionCard>

      {/* ============================================================ */}
      {/*  Section 3: Daily Birthstone                                  */}
      {/* ============================================================ */}
      {daily && (
        <SectionCard
          title={`${monthly.month}월 ${daily.day}일의 탄생석`}
          description="생일에 해당하는 고유한 일별 탄생석입니다."
        >
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              gap: fortuneTheme.spacing.sm,
              alignItems: 'center',
              paddingVertical: fortuneTheme.spacing.md,
            }}
          >
            <AppText style={{ fontSize: 36, lineHeight: 44 }}>
              💎
            </AppText>
            <AppText variant="heading3">
              {daily.name} ({daily.nameEn})
            </AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
            >
              {monthly.month}월 {daily.day}일에 태어난 사람만의 특별한 보석입니다.
            </AppText>
          </Card>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 4: Birthstone Fortune (API categories)               */}
      {/* ============================================================ */}
      {hasRaw && categoryStatItems.length > 0 && (
        <SectionCard
          title="탄생석 인사이트"
          description={`${monthly.name}의 기운으로 읽는 오늘의 인사이트 흐름입니다.`}
        >
          <StatRail items={categoryStatItems} />

          {/* Category detail cards */}
          <View style={{ gap: fortuneTheme.spacing.sm, marginTop: fortuneTheme.spacing.sm }}>
            {categoryKeys.map((key) => {
              const c = obj(categories[key]);
              const detail = str(c.detail);
              const catAdvice = str(c.advice);
              if (!detail && !catAdvice) return null;
              const catMeta = CATEGORY_LABELS[key]!;
              return (
                <Card
                  key={key}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.xs,
                  }}
                >
                  <AppText variant="labelLarge">
                    {catMeta.emoji} {catMeta.label}
                  </AppText>
                  {detail ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {detail}
                    </AppText>
                  ) : null}
                  {catAdvice ? <InsetQuote text={catAdvice} /> : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* Advice quote when API provides it */}
      {hasRaw && advice ? (
        <SectionCard title="탄생석 조언">
          <InsetQuote text={advice} />
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 5: Birthstone Compatibility                          */}
      {/* ============================================================ */}
      <SectionCard
        title="탄생석 궁합"
        description={`${monthly.name}과(와) 잘 어울리는 탄생석입니다.`}
      >
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {compatibleStones.map((stone) => (
            <Card
              key={stone.month}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View
                  style={{
                    width: 20,
                    height: 20,
                    borderRadius: fortuneTheme.radius.full,
                    backgroundColor: stone.color,
                    borderWidth: 1,
                    borderColor: fortuneTheme.colors.border,
                  }}
                />
                <AppText variant="labelLarge">
                  {stone.emoji} {stone.month}월 {stone.name} ({stone.nameEn})
                </AppText>
              </View>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {stone.meaning}
              </AppText>
            </Card>
          ))}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  Section 6: Lucky Items                                       */}
      {/* ============================================================ */}
      {(hasRaw && luckyItems.length > 0) || result.luckyItems.length > 0 ? (
        <SectionCard title="행운 포인트">
          <KeywordPills
            keywords={luckyItems.length > 0 ? luckyItems : result.luckyItems}
          />
        </SectionCard>
      ) : null}

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
        <SectionCard title="탄생석 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

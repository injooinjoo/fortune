import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { Chip } from '../../../components/chip';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  InsetQuote,
  KeywordPills,
  SectionCard,
  Timeline,
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
/*  Score ring                                                         */
/* ------------------------------------------------------------------ */

function ScoreRing({ score, label, emoji }: { score: number; label: string; emoji?: string }) {
  const clamped = Math.max(0, Math.min(100, score));
  return (
    <View
      style={{
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        borderRadius: fortuneTheme.radius.full,
        borderWidth: 3,
        borderColor: fortuneTheme.colors.ctaBackground,
        width: 100,
        height: 100,
      }}
    >
      {emoji ? (
        <AppText style={{ fontSize: 18, marginBottom: 2 }}>{emoji}</AppText>
      ) : null}
      <AppText variant="displaySmall" color={fortuneTheme.colors.ctaBackground}>
        {clamped}
      </AppText>
      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Direction compass display                                          */
/* ------------------------------------------------------------------ */

const DIRECTION_LABELS = ['북', '동북', '동', '동남', '남', '서남', '서', '서북'] as const;

const DIRECTION_POSITIONS: Record<string, { top?: number; bottom?: number; left?: number; right?: number }> = {
  '북': { top: 4, left: 72 },
  '동북': { top: 22, right: 14 },
  '동': { top: 72, right: 4 },
  '동남': { bottom: 22, right: 14 },
  '남': { bottom: 4, left: 72 },
  '서남': { bottom: 22, left: 14 },
  '서': { top: 72, left: 4 },
  '서북': { top: 22, left: 14 },
};

function CompassDisplay({
  activeDirection,
  score,
  isAuspicious,
}: {
  activeDirection: string;
  score: number;
  isAuspicious: boolean;
}) {
  return (
    <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.md }}>
      <View
        style={{
          width: 180,
          height: 180,
          borderRadius: fortuneTheme.radius.full,
          borderWidth: 2,
          borderColor: fortuneTheme.colors.border,
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          position: 'relative',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {/* Center compass emoji */}
        <AppText style={{ fontSize: 32 }}>🧭</AppText>

        {/* Direction labels around the circle */}
        {DIRECTION_LABELS.map((dir) => {
          const pos = DIRECTION_POSITIONS[dir] ?? {};
          const isActive = dir === activeDirection;
          return (
            <View
              key={dir}
              style={{
                position: 'absolute',
                ...pos,
                backgroundColor: isActive
                  ? isAuspicious
                    ? fortuneTheme.colors.ctaBackground
                    : fortuneTheme.colors.error
                  : 'transparent',
                borderRadius: fortuneTheme.radius.full,
                paddingHorizontal: 8,
                paddingVertical: 4,
              }}
            >
              <AppText
                variant={isActive ? 'labelLarge' : 'caption'}
                color={
                  isActive
                    ? fortuneTheme.colors.ctaForeground
                    : fortuneTheme.colors.textTertiary
                }
              >
                {dir}
              </AppText>
            </View>
          );
        })}
      </View>

      {/* Direction score and label */}
      <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading3">{activeDirection}쪽</AppText>
          <Chip
            label={isAuspicious ? '길' : '흉'}
            tone={isAuspicious ? 'accent' : 'neutral'}
          />
        </View>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          방위 궁합 {score}점
        </AppText>
      </View>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Calendar-style date display for auspicious dates                   */
/* ------------------------------------------------------------------ */

function AuspiciousDateCard({ date, index }: { date: string; index: number }) {
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.sm,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
        paddingHorizontal: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
      }}
    >
      <View
        style={{
          width: 32,
          height: 32,
          borderRadius: fortuneTheme.radius.full,
          backgroundColor: fortuneTheme.colors.ctaBackground,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
          {index + 1}
        </AppText>
      </View>
      <AppText variant="bodyMedium" style={{ flex: 1 }}>{date}</AppText>
      <AppText style={{ fontSize: 16 }}>✅</AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Avoid date card                                                    */
/* ------------------------------------------------------------------ */

function AvoidDateCard({ date }: { date: string }) {
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.sm,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
        paddingHorizontal: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
        borderLeftWidth: 3,
        borderLeftColor: fortuneTheme.colors.error,
      }}
    >
      <AppText style={{ fontSize: 16 }}>⛔</AppText>
      <AppText variant="bodyMedium" color={fortuneTheme.colors.error} style={{ flex: 1 }}>
        {date}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Feng shui tip card                                                 */
/* ------------------------------------------------------------------ */

function FengshuiTipCard({
  emoji,
  room,
  tip,
}: {
  emoji: string;
  room: string;
  tip: string;
}) {
  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        gap: fortuneTheme.spacing.xs,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
        <AppText style={{ fontSize: 20 }}>{emoji}</AppText>
        <AppText variant="labelLarge">{room}</AppText>
      </View>
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {tip}
      </AppText>
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  Lucky item card                                                    */
/* ------------------------------------------------------------------ */

function LuckyItemCard({ emoji, label }: { emoji: string; label: string }) {
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.sm,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
        paddingHorizontal: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
      }}
    >
      <AppText style={{ fontSize: 18 }}>{emoji}</AppText>
      <AppText variant="bodyMedium">{label}</AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Warning card                                                       */
/* ------------------------------------------------------------------ */

function WarningCard({ text }: { text: string }) {
  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderLeftWidth: 3,
        borderLeftColor: fortuneTheme.colors.error,
        gap: fortuneTheme.spacing.xs,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'flex-start', gap: fortuneTheme.spacing.sm }}>
        <AppText style={{ fontSize: 16 }}>⚠️</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ flex: 1 }}
        >
          {text}
        </AppText>
      </View>
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  Checklist item                                                     */
/* ------------------------------------------------------------------ */

function ChecklistItem({
  emoji,
  task,
  reason,
}: {
  emoji: string;
  task: string;
  reason: string;
}) {
  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        gap: fortuneTheme.spacing.xs,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
        <AppText style={{ fontSize: 18 }}>{emoji}</AppText>
        <AppText variant="labelLarge" style={{ flex: 1 }}>{task}</AppText>
      </View>
      {reason ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {reason}
        </AppText>
      ) : null}
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  MovingResult                                                       */
/* ------------------------------------------------------------------ */

export function MovingResult(props: FortuneResultComponentProps) {
  const _meta = resultMetadataByKind.moving;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract structured API data ---

  // Top-level
  const title = str(raw.title, result.summary || '이사 인사이트 분석');
  const overallFortune = str(raw.overall_fortune, str(raw.overallFortune, ''));
  const score = num(raw.score, result.score ?? 81);

  // Direction analysis
  const directionAnalysis = obj(raw.direction_analysis ?? raw.directionAnalysis);
  const direction = str(directionAnalysis.direction, '동남');
  const directionMeaning = str(directionAnalysis.direction_meaning ?? directionAnalysis.directionMeaning);
  const dirElement = str(directionAnalysis.element);
  const dirElementEffect = str(directionAnalysis.element_effect ?? directionAnalysis.elementEffect);
  const dirCompatibility = num(directionAnalysis.compatibility, 80);
  const dirCompatibilityReason = str(directionAnalysis.compatibility_reason ?? directionAnalysis.compatibilityReason);
  const dirIsAuspicious = dirCompatibility >= 60;

  // Timing analysis
  const timingAnalysis = obj(raw.timing_analysis ?? raw.timingAnalysis);
  const seasonLuck = str(timingAnalysis.season_luck ?? timingAnalysis.seasonLuck);
  const seasonMeaning = str(timingAnalysis.season_meaning ?? timingAnalysis.seasonMeaning);
  const monthLuck = num(timingAnalysis.month_luck ?? timingAnalysis.monthLuck);
  const timingRecommendation = str(timingAnalysis.recommendation);

  // Lucky dates (= noson/auspicious dates)
  const luckyDates = obj(raw.lucky_dates ?? raw.luckyDates ?? raw.nosonDay);
  const recommendedDates = strArr(luckyDates.recommended_dates ?? luckyDates.recommendedDates ?? luckyDates.dates);
  const avoidDates = strArr(luckyDates.avoid_dates ?? luckyDates.avoidDates);
  const bestTime = str(luckyDates.best_time ?? luckyDates.bestTime);
  const datesReason = str(luckyDates.reason ?? luckyDates.description);

  // Feng shui tips
  const fengshuiTips = obj(raw.feng_shui_tips ?? raw.fengshuiTips ?? raw.fengshui);
  const fengshuiEntrance = str(fengshuiTips.entrance);
  const fengshuiLivingRoom = str(fengshuiTips.living_room ?? fengshuiTips.livingRoom);
  const fengshuiBedroom = str(fengshuiTips.bedroom);
  const fengshuiKitchen = str(fengshuiTips.kitchen);
  const hasFengshui = fengshuiEntrance || fengshuiLivingRoom || fengshuiBedroom || fengshuiKitchen;

  // Cautions / warnings
  const cautions = obj(raw.cautions);
  const movingDayCautions = strArr(cautions.moving_day ?? cautions.movingDay);
  const firstWeekCautions = strArr(cautions.first_week ?? cautions.firstWeek);
  const thingsToAvoid = strArr(cautions.things_to_avoid ?? cautions.thingsToAvoid);
  const allCautions = [...movingDayCautions, ...firstWeekCautions, ...thingsToAvoid];
  const topWarnings = strArr(raw.warnings);

  // Recommendations
  const recommendations = obj(raw.recommendations);
  const beforeMoving = strArr(recommendations.before_moving ?? recommendations.beforeMoving);
  const movingDayRitual = strArr(recommendations.moving_day_ritual ?? recommendations.movingDayRitual);
  const afterMoving = strArr(recommendations.after_moving ?? recommendations.afterMoving);

  // Lucky items
  const luckyItemsRaw = obj(raw.lucky_items ?? raw.luckyItems);
  const luckyItemsList = strArr(luckyItemsRaw.items);
  const luckyColors = strArr(luckyItemsRaw.colors);
  const luckyPlants = strArr(luckyItemsRaw.plants);

  // Terrain analysis
  const terrain = obj(raw.terrain_analysis ?? raw.terrainAnalysis);
  const terrainType = str(terrain.terrain_type ?? terrain.terrainType);
  const terrainScore = num(terrain.feng_shui_quality ?? terrain.fengshuiQuality);
  const terrainDescription = str(terrain.quality_description ?? terrain.qualityDescription);
  const fourGuardians = obj(terrain.four_guardians ?? terrain.fourGuardians);
  const hasTerrain = terrainType || terrainDescription;

  // Settlement index
  const settlement = obj(raw.settlement_index ?? raw.settlementIndex);
  const settlementScore = num(settlement.score);
  const settlementDescription = str(settlement.description);
  const settlementFactors = strArr(settlement.factors);

  // Neighborhood chemistry
  const neighborhood = obj(raw.neighborhood_chemistry ?? raw.neighborhoodChemistry);
  const neighborhoodScore = num(neighborhood.score);
  const neighborhoodDescription = str(neighborhood.description);
  const neighborhoodVibe = str(neighborhood.vibe_match ?? neighborhood.vibeMatch);

  // Lucky checklist
  const luckyChecklist = arr(raw.lucky_checklist ?? raw.luckyChecklist);

  // Summary
  const summaryObj = obj(raw.summary);
  const oneLine = str(summaryObj.one_line ?? summaryObj.oneLine);
  const keywords = strArr(summaryObj.keywords);
  const finalMessage = str(summaryObj.final_message ?? summaryObj.finalMessage);

  // Seasonal advice (from the user's spec — map to timing analysis)
  const seasonalAdvice = str(raw.seasonalAdvice, timingRecommendation);

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Section 1: Hero - Overall score gauge                        */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
          paddingVertical: fortuneTheme.spacing.xl,
        }}
      >
        <AppText style={{ fontSize: 48 }}>🏠</AppText>
        <AppText variant="heading2" style={{ textAlign: 'center' }}>
          {title}
        </AppText>

        <ScoreRing score={score} label="이사 점수" emoji="🏠" />

        {keywords.length > 0 && (
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8, justifyContent: 'center' }}>
            {keywords.map((kw) => (
              <Chip key={kw} label={kw} />
            ))}
          </View>
        )}

        {oneLine ? (
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
          >
            {oneLine}
          </AppText>
        ) : null}
      </Card>

      {/* ============================================================ */}
      {/*  Section 1b: Overall fortune                                  */}
      {/* ============================================================ */}
      {overallFortune ? (
        <Card style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">종합 분석</AppText>
          <AppText
            variant="bodyLarge"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 28 }}
          >
            {overallFortune}
          </AppText>
        </Card>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 2: Direction analysis - Compass display               */}
      {/* ============================================================ */}
      {hasRaw && direction ? (
        <SectionCard title="방위 분석" description="이사 방향의 풍수 길흉을 분석합니다.">
          <CompassDisplay
            activeDirection={direction}
            score={dirCompatibility}
            isAuspicious={dirIsAuspicious}
          />

          {directionMeaning ? (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="labelLarge">방위 의미</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {directionMeaning}
              </AppText>
            </Card>
          ) : null}

          {dirElement ? (
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <Chip label={`오행: ${dirElement}`} tone="accent" />
              {dirElementEffect ? (
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                  style={{ flex: 1 }}
                >
                  {dirElementEffect}
                </AppText>
              ) : null}
            </View>
          ) : null}

          {dirCompatibilityReason ? (
            <InsetQuote text={dirCompatibilityReason} />
          ) : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 3: Lucky dates (auspicious dates / noson day)         */}
      {/* ============================================================ */}
      {hasRaw && recommendedDates.length > 0 ? (
        <SectionCard title="손없는 날 / 이사 길일" description="이사하기 좋은 날짜입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {recommendedDates.map((date, i) => (
              <AuspiciousDateCard key={`date-${i}`} date={date} index={i} />
            ))}
          </View>

          {avoidDates.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.sm, marginTop: fortuneTheme.spacing.md }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.error}>
                피해야 할 날짜
              </AppText>
              {avoidDates.map((date, i) => (
                <AvoidDateCard key={`avoid-${i}`} date={date} />
              ))}
            </View>
          ) : null}

          {bestTime ? (
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.sm,
                marginTop: fortuneTheme.spacing.sm,
              }}
            >
              <AppText style={{ fontSize: 16 }}>⏰</AppText>
              <AppText variant="bodyMedium">추천 시간대: {bestTime}</AppText>
            </View>
          ) : null}

          {datesReason ? <InsetQuote text={datesReason} /> : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 4: Feng shui tips                                    */}
      {/* ============================================================ */}
      {hasRaw && hasFengshui ? (
        <SectionCard title="풍수 조언" description="새 집 공간 배치 가이드입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {fengshuiEntrance ? (
              <FengshuiTipCard emoji="🚪" room="현관" tip={fengshuiEntrance} />
            ) : null}
            {fengshuiLivingRoom ? (
              <FengshuiTipCard emoji="🛋️" room="거실" tip={fengshuiLivingRoom} />
            ) : null}
            {fengshuiBedroom ? (
              <FengshuiTipCard emoji="🛏️" room="침실" tip={fengshuiBedroom} />
            ) : null}
            {fengshuiKitchen ? (
              <FengshuiTipCard emoji="🍳" room="부엌" tip={fengshuiKitchen} />
            ) : null}
          </View>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 5: Timing / Seasonal advice                          */}
      {/* ============================================================ */}
      {hasRaw && (seasonLuck || seasonalAdvice) ? (
        <SectionCard title="이사 타이밍" description="계절과 시기별 이사 조언입니다.">
          {seasonLuck ? (
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <Chip label={seasonLuck} tone="accent" />
              {monthLuck > 0 ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  월간 이사운 {monthLuck}점
                </AppText>
              ) : null}
            </View>
          ) : null}

          {seasonMeaning ? (
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ lineHeight: 24 }}
            >
              {seasonMeaning}
            </AppText>
          ) : null}

          {seasonalAdvice ? <InsetQuote text={seasonalAdvice} /> : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 5b: Terrain analysis                                 */}
      {/* ============================================================ */}
      {hasRaw && hasTerrain ? (
        <SectionCard title="지형 풍수 분석" description="이사 예정지의 지형 평가입니다.">
          {terrainType ? (
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
              <AppText style={{ fontSize: 20 }}>⛰️</AppText>
              <AppText variant="heading4">{terrainType}</AppText>
              {terrainScore > 0 ? (
                <Chip label={`풍수 ${terrainScore}점`} tone="accent" />
              ) : null}
            </View>
          ) : null}

          {terrainDescription ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ lineHeight: 24 }}>
              {terrainDescription}
            </AppText>
          ) : null}

          {/* Four guardians */}
          {Object.keys(fourGuardians).length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.sm }}>
              {str(fourGuardians.left_azure_dragon ?? fourGuardians.leftAzureDragon) ? (
                <FengshuiTipCard emoji="🐉" room="좌청룡 (동)" tip={str(fourGuardians.left_azure_dragon ?? fourGuardians.leftAzureDragon)} />
              ) : null}
              {str(fourGuardians.right_white_tiger ?? fourGuardians.rightWhiteTiger) ? (
                <FengshuiTipCard emoji="🐅" room="우백호 (서)" tip={str(fourGuardians.right_white_tiger ?? fourGuardians.rightWhiteTiger)} />
              ) : null}
              {str(fourGuardians.front_red_phoenix ?? fourGuardians.frontRedPhoenix) ? (
                <FengshuiTipCard emoji="🐦" room="전주작 (남)" tip={str(fourGuardians.front_red_phoenix ?? fourGuardians.frontRedPhoenix)} />
              ) : null}
              {str(fourGuardians.back_black_turtle ?? fourGuardians.backBlackTurtle) ? (
                <FengshuiTipCard emoji="🐢" room="후현무 (북)" tip={str(fourGuardians.back_black_turtle ?? fourGuardians.backBlackTurtle)} />
              ) : null}
            </View>
          ) : null}

          {strArr(terrain.recommendations).length > 0 ? (
            <BulletList items={strArr(terrain.recommendations)} />
          ) : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 5c: Settlement index + Neighborhood chemistry        */}
      {/* ============================================================ */}
      {hasRaw && (settlementScore > 0 || neighborhoodScore > 0) ? (
        <SectionCard title="정착 & 동네 궁합" description="새 동네 적응 예측입니다.">
          {settlementScore > 0 ? (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                <AppText style={{ fontSize: 20 }}>🏘️</AppText>
                <AppText variant="labelLarge">정착 용이도</AppText>
                <Chip label={`${settlementScore}점`} tone="accent" />
              </View>
              {settlementDescription ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {settlementDescription}
                </AppText>
              ) : null}
              {settlementFactors.length > 0 ? (
                <KeywordPills keywords={settlementFactors} />
              ) : null}
            </Card>
          ) : null}

          {neighborhoodScore > 0 ? (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                <AppText style={{ fontSize: 20 }}>🏙️</AppText>
                <AppText variant="labelLarge">동네 궁합</AppText>
                <Chip label={`${neighborhoodScore}점`} tone="accent" />
              </View>
              {neighborhoodVibe ? (
                <Chip label={neighborhoodVibe} />
              ) : null}
              {neighborhoodDescription ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {neighborhoodDescription}
                </AppText>
              ) : null}
            </Card>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 6: Lucky items for moving day                        */}
      {/* ============================================================ */}
      {hasRaw && (luckyItemsList.length > 0 || luckyColors.length > 0 || luckyPlants.length > 0) ? (
        <SectionCard title="행운 아이템" description="이사 당일 행운을 부르는 물건입니다.">
          {luckyItemsList.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>필수 아이템</AppText>
              {luckyItemsList.map((item, i) => (
                <LuckyItemCard key={`item-${i}`} emoji="🍀" label={item} />
              ))}
            </View>
          ) : null}

          {luckyColors.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>행운의 색상</AppText>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
                {luckyColors.map((color) => (
                  <Chip key={color} label={`🎨 ${color}`} />
                ))}
              </View>
            </View>
          ) : null}

          {luckyPlants.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>추천 식물</AppText>
              {luckyPlants.map((plant, i) => (
                <LuckyItemCard key={`plant-${i}`} emoji="🌿" label={plant} />
              ))}
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 6b: Lucky checklist                                  */}
      {/* ============================================================ */}
      {hasRaw && luckyChecklist.length > 0 ? (
        <SectionCard title="행운 체크리스트" description="이사 당일 실천할 미션입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {luckyChecklist.map((item, i) => {
              const d = obj(item);
              return (
                <ChecklistItem
                  key={`checklist-${i}`}
                  emoji={str(d.emoji, '✨')}
                  task={str(d.task)}
                  reason={str(d.reason)}
                />
              );
            })}
          </View>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 6c: Recommendations (before / day / after)           */}
      {/* ============================================================ */}
      {hasRaw && (beforeMoving.length > 0 || movingDayRitual.length > 0 || afterMoving.length > 0) ? (
        <SectionCard title="이사 준비 & 의식" description="단계별 실천 가이드입니다.">
          <Timeline
            items={[
              ...(beforeMoving.length > 0
                ? [{ title: '이사 전', body: beforeMoving.join('\n'), tag: '📋' }]
                : []),
              ...(movingDayRitual.length > 0
                ? [{ title: '이사 당일', body: movingDayRitual.join('\n'), tag: '🎉' }]
                : []),
              ...(afterMoving.length > 0
                ? [{ title: '입주 후', body: afterMoving.join('\n'), tag: '🏡' }]
                : []),
            ]}
          />
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 7: Warnings / Cautions                               */}
      {/* ============================================================ */}
      {hasRaw && (allCautions.length > 0 || topWarnings.length > 0) ? (
        <SectionCard title="주의사항" description="이사 시 특히 조심해야 할 점입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {[...topWarnings, ...allCautions].map((text, i) => (
              <WarningCard key={`warn-${i}`} text={text} />
            ))}
          </View>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Final message                                                */}
      {/* ============================================================ */}
      {finalMessage ? (
        <SectionCard title="마무리 메시지">
          <InsetQuote text={finalMessage} />
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

      {!hasRaw && result.warnings.length > 0 && (
        <SectionCard title="주의사항">
          <BulletList items={result.warnings} />
        </SectionCard>
      )}

      {!hasRaw && result.luckyItems.length > 0 && (
        <SectionCard title="행운 포인트">
          <KeywordPills keywords={result.luckyItems} />
        </SectionCard>
      )}

      {result.specialTip && (
        <SectionCard title="한 줄 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

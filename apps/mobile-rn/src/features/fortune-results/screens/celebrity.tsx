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
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Type helpers (same pattern as face-reading / batch-b)              */
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

function strArr(val: unknown): string[] {
  if (!Array.isArray(val)) return [];
  return val.map((v) => str(v)).filter(Boolean);
}

/* ------------------------------------------------------------------ */
/*  Grade badge colours                                                */
/* ------------------------------------------------------------------ */

const GRADE_STYLES: Record<string, { bg: string; fg: string }> = {
  '천생연분': { bg: '#FFD700', fg: '#1A1000' },
  '특별한 인연': { bg: '#B388FF', fg: '#1A0030' },
  '좋은 궁합': { bg: '#8FB8FF', fg: '#0A1A30' },
  '발전 가능': { bg: '#81C784', fg: '#0A200E' },
  '노력 필요': { bg: '#FFAB91', fg: '#2A0A00' },
};

function gradeStyle(grade: string) {
  return GRADE_STYLES[grade] ?? { bg: fortuneTheme.colors.surfaceSecondary, fg: fortuneTheme.colors.textPrimary };
}

/* ------------------------------------------------------------------ */
/*  Interaction label helper for five elements                         */
/* ------------------------------------------------------------------ */

const INTERACTION_STYLES: Record<string, { emoji: string; color: string }> = {
  '상생': { emoji: '🌿', color: fortuneTheme.colors.success },
  '상극': { emoji: '🔥', color: fortuneTheme.colors.error },
  '비화': { emoji: '🌀', color: fortuneTheme.colors.warning },
};

/* ------------------------------------------------------------------ */
/*  Score ring (circular-ish score display)                            */
/* ------------------------------------------------------------------ */

function ScoreDisplay({ score, label }: { score: number; label: string }) {
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
        width: 96,
        height: 96,
      }}
    >
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
/*  Bar meter for chemistry section                                    */
/* ------------------------------------------------------------------ */

function BarMeter({
  label,
  value,
  maxValue = 10,
}: {
  label: string;
  value: number;
  maxValue?: number;
}) {
  const pct = Math.max(0, Math.min(100, (value / maxValue) * 100));
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <AppText variant="labelLarge">{label}</AppText>
        <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
          {value}/{maxValue}
        </AppText>
      </View>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.full,
          height: 10,
          overflow: 'hidden',
        }}
      >
        <View
          style={{
            backgroundColor: fortuneTheme.colors.ctaBackground,
            borderRadius: fortuneTheme.radius.full,
            height: '100%',
            width: `${pct}%`,
          }}
        />
      </View>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  CelebrityResult                                                    */
/* ------------------------------------------------------------------ */

export function CelebrityResult(props: FortuneResultComponentProps) {
  const _meta = resultMetadataByKind.celebrity;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // ----- Extract all structured data from rawApiResponse -----

  // Top-level
  const overallScore = num(raw.overall_score, num(raw.score, result.score ?? 78));
  const compatibilityGrade = str(raw.compatibility_grade, '좋은 궁합');
  const mainMessage = str(
    raw.main_message,
    result.summary || '두 사람의 사주를 풀어보니 특별한 기운이 연결되어 있습니다.',
  );

  // Celebrity name from build context or raw
  const celebrityName = str(
    raw.celebrity_name,
    str(
      (props.payload?.rawApiResponse as R)?.celebrity_name,
      str(obj(raw.input)?.celebrity_name, '셀럽'),
    ),
  );

  // Saju Analysis
  const sajuAnalysis = obj(raw.saju_analysis);
  const fiveElements = obj(sajuAnalysis.five_elements);
  const userDominant = str(fiveElements.user_dominant);
  const celebDominant = str(fiveElements.celebrity_dominant);
  const interaction = str(fiveElements.interaction);
  const fiveInterpretation = str(fiveElements.interpretation);
  const hasFiveElements = userDominant || celebDominant || interaction;

  const dayPillar = obj(sajuAnalysis.day_pillar);
  const dayRelationship = str(dayPillar.relationship);
  const dayInterpretation = str(dayPillar.interpretation);

  const hapAnalysis = obj(sajuAnalysis.hap_analysis);
  const hasHap = hapAnalysis.has_hap === true;
  const hapType = str(hapAnalysis.hap_type);
  const hapInterpretation = str(hapAnalysis.interpretation);

  // Past Life
  const pastLife = obj(raw.past_life);
  const plConnectionType = str(pastLife.connection_type);
  const plStory = str(pastLife.story);
  const plEvidence = strArr(pastLife.evidence);
  const hasPastLife = plConnectionType || plStory;

  // Destined Timing
  const destTiming = obj(raw.destined_timing);
  const bestYear = str(destTiming.best_year);
  const bestMonth = str(destTiming.best_month);
  const timingReason = str(destTiming.timing_reason);
  const hasDestTiming = bestYear || bestMonth;

  // Intimate Compatibility
  const intimate = obj(raw.intimate_compatibility);
  const passionScore = num(intimate.passion_score, 7);
  const chemistryType = str(intimate.chemistry_type);
  const emotionalConnection = str(intimate.emotional_connection);
  const physicalHarmony = str(intimate.physical_harmony);
  const intimateAdvice = str(intimate.intimate_advice);
  const hasIntimate = chemistryType || emotionalConnection;

  // Detailed Analysis
  const detailed = obj(raw.detailed_analysis);
  const personalityMatch = str(detailed.personality_match);
  const energyCompat = str(detailed.energy_compatibility);
  const lifePathConn = str(detailed.life_path_connection);

  // Strengths / Challenges / Recommendations
  const strengths = strArr(raw.strengths);
  const challenges = strArr(raw.challenges);
  const recommendations = strArr(raw.recommendations);

  // Lucky Factors
  const lucky = obj(raw.lucky_factors);
  const bestTimeConnect = str(lucky.best_time_to_connect);
  const luckyActivity = str(lucky.lucky_activity);
  const sharedInterest = str(lucky.shared_interest);
  const luckyColor = str(lucky.lucky_color);
  const luckyDirection = str(lucky.lucky_direction);
  const hasLucky =
    bestTimeConnect || luckyActivity || sharedInterest || luckyColor || luckyDirection;

  // Special Message
  const specialMessage = str(raw.special_message);

  // Grade style
  const gStyle = gradeStyle(compatibilityGrade);
  const interStyle = INTERACTION_STYLES[interaction] ?? { emoji: '🔮', color: fortuneTheme.colors.accentSecondary };

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  1. Hero — Celebrity name + grade badge + overall score       */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
          alignItems: 'center',
          paddingVertical: fortuneTheme.spacing.xl,
        }}
      >
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          나와 {celebrityName}의 사주 궁합
        </AppText>

        <ScoreDisplay score={overallScore} label="궁합 점수" />

        <View
          style={{
            backgroundColor: gStyle.bg,
            borderRadius: fortuneTheme.radius.chip,
            paddingHorizontal: 16,
            paddingVertical: 8,
          }}
        >
          <AppText variant="labelLarge" color={gStyle.fg}>
            {compatibilityGrade}
          </AppText>
        </View>

        <AppText variant="heading2" style={{ textAlign: 'center' }}>
          {celebrityName}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  2. Main Story — immersive narrative text                     */}
      {/* ============================================================ */}
      <Card style={{ gap: fortuneTheme.spacing.sm }}>
        <AppText variant="heading4">궁합 이야기</AppText>
        <AppText
          variant="bodyLarge"
          color={fortuneTheme.colors.textSecondary}
          style={{ lineHeight: 28 }}
        >
          {mainMessage}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  3. Saju Analysis — Five elements interaction                 */}
      {/* ============================================================ */}
      {hasRaw && hasFiveElements && (
        <SectionCard title="사주 궁합 분석" description="오행의 상호작용으로 두 사람의 기운을 읽습니다.">
          {/* Five elements visualization */}
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              alignItems: 'center',
              gap: fortuneTheme.spacing.md,
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.lg,
              }}
            >
              {/* User element */}
              <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <View
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    borderRadius: fortuneTheme.radius.full,
                    width: 64,
                    height: 64,
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderWidth: 2,
                    borderColor: fortuneTheme.colors.accentSecondary,
                  }}
                >
                  <AppText variant="heading3">{userDominant || '?'}</AppText>
                </View>
                <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
                  나
                </AppText>
              </View>

              {/* Interaction arrow */}
              <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ fontSize: 24 }}>{interStyle.emoji}</AppText>
                <AppText variant="labelMedium" color={interStyle.color}>
                  {interaction || '분석 중'}
                </AppText>
              </View>

              {/* Celebrity element */}
              <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <View
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    borderRadius: fortuneTheme.radius.full,
                    width: 64,
                    height: 64,
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderWidth: 2,
                    borderColor: fortuneTheme.colors.ctaBackground,
                  }}
                >
                  <AppText variant="heading3">{celebDominant || '?'}</AppText>
                </View>
                <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
                  {celebrityName}
                </AppText>
              </View>
            </View>

            {fiveInterpretation ? (
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
              >
                {fiveInterpretation}
              </AppText>
            ) : null}
          </Card>

          {/* Day Pillar */}
          {dayRelationship || dayInterpretation ? (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelLarge">일주 관계</AppText>
                {dayRelationship ? (
                  <Chip label={dayRelationship} tone="accent" />
                ) : null}
              </View>
              {dayInterpretation ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {dayInterpretation}
                </AppText>
              ) : null}
            </Card>
          ) : null}

          {/* Hap Analysis */}
          {(hasHap || hapInterpretation) ? (
            <Card
              style={{
                backgroundColor: hasHap
                  ? fortuneTheme.colors.backgroundTertiary
                  : fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelLarge">
                  {hasHap ? '합(合) 발견!' : '합(合) 분석'}
                </AppText>
                {hapType ? (
                  <Chip label={hapType} tone={hasHap ? 'success' : 'neutral'} />
                ) : null}
              </View>
              {hapInterpretation ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {hapInterpretation}
                </AppText>
              ) : null}
            </Card>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  4. Past Life — narrative card with evidence pills             */}
      {/* ============================================================ */}
      {hasRaw && hasPastLife && (
        <SectionCard title="전생 인연" description="두 사람이 연결된 전생의 이야기입니다.">
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              gap: fortuneTheme.spacing.md,
            }}
          >
            {plConnectionType ? (
              <Chip label={plConnectionType} tone="accent" />
            ) : null}
            {plStory ? (
              <AppText
                variant="bodyMedium"
                color={fortuneTheme.colors.textSecondary}
                style={{ lineHeight: 26 }}
              >
                {plStory}
              </AppText>
            ) : null}
            {plEvidence.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  인연의 증거
                </AppText>
                <KeywordPills keywords={plEvidence} />
              </View>
            ) : null}
          </Card>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  5. Destined Timing — best year/month highlight               */}
      {/* ============================================================ */}
      {hasRaw && hasDestTiming && (
        <SectionCard title="운명의 시기" description="두 사람에게 특별한 시간이 있습니다.">
          <View
            style={{
              flexDirection: 'row',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            {bestYear ? (
              <View
                style={{
                  flex: 1,
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  borderRadius: fortuneTheme.radius.md,
                  borderWidth: 1,
                  borderColor: fortuneTheme.colors.ctaBackground,
                  padding: fortuneTheme.spacing.md,
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  최적의 해
                </AppText>
                <AppText variant="heading2" color={fortuneTheme.colors.ctaBackground}>
                  {bestYear}
                </AppText>
              </View>
            ) : null}
            {bestMonth ? (
              <View
                style={{
                  flex: 1,
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  borderRadius: fortuneTheme.radius.md,
                  borderWidth: 1,
                  borderColor: fortuneTheme.colors.accentSecondary,
                  padding: fortuneTheme.spacing.md,
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  최적의 달
                </AppText>
                <AppText variant="heading2" color={fortuneTheme.colors.accentSecondary}>
                  {bestMonth}
                </AppText>
              </View>
            ) : null}
          </View>
          {timingReason ? (
            <InsetQuote text={timingReason} />
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  6. Chemistry Analysis — 4 visual meters                      */}
      {/* ============================================================ */}
      {hasRaw && hasIntimate && (
        <SectionCard title="케미 분석" description="두 사람 사이의 에너지와 감정의 교감입니다.">
          {chemistryType ? (
            <View style={{ alignItems: 'center', marginBottom: fortuneTheme.spacing.xs }}>
              <Chip label={chemistryType} tone="accent" />
            </View>
          ) : null}

          <View style={{ gap: fortuneTheme.spacing.md }}>
            <BarMeter label="열정 지수" value={passionScore} maxValue={10} />

            {emotionalConnection ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  정서적 교감
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {emotionalConnection}
                </AppText>
              </View>
            ) : null}

            {physicalHarmony ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  에너지 조화
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {physicalHarmony}
                </AppText>
              </View>
            ) : null}

            {intimateAdvice ? (
              <InsetQuote text={intimateAdvice} />
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  7. Detailed Personality / Energy / Life-path Analysis         */}
      {/* ============================================================ */}
      {hasRaw && (personalityMatch || energyCompat || lifePathConn) && (
        <SectionCard title="심층 분석" description="성격, 에너지, 인생 경로의 연결고리입니다.">
          {personalityMatch ? (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge">성격 매칭</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {personalityMatch}
              </AppText>
            </View>
          ) : null}
          {energyCompat ? (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge">에너지 궁합</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {energyCompat}
              </AppText>
            </View>
          ) : null}
          {lifePathConn ? (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge">인생 경로 연결</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {lifePathConn}
              </AppText>
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  8. Strengths + Challenges                                    */}
      {/* ============================================================ */}
      {(strengths.length > 0 || challenges.length > 0) && (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          {strengths.length > 0 && (
            <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
              <SectionCard title="잘 맞는 점">
                <BulletList items={strengths.slice(0, 4)} accent="강점" />
              </SectionCard>
            </View>
          )}
          {challenges.length > 0 && (
            <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
              <SectionCard title="주의할 점">
                <BulletList items={challenges.slice(0, 3)} accent="주의" />
              </SectionCard>
            </View>
          )}
        </View>
      )}

      {/* ============================================================ */}
      {/*  9. Lucky Factors                                             */}
      {/* ============================================================ */}
      {hasRaw && hasLucky && (
        <SectionCard title="행운 포인트" description="두 사람의 인연을 강화하는 요소들입니다.">
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
            {bestTimeConnect ? (
              <LuckyTile emoji="🕐" label="베스트 타이밍" value={bestTimeConnect} />
            ) : null}
            {luckyActivity ? (
              <LuckyTile emoji="🎯" label="추천 활동" value={luckyActivity} />
            ) : null}
            {sharedInterest ? (
              <LuckyTile emoji="🤝" label="공통 관심사" value={sharedInterest} />
            ) : null}
            {luckyColor ? (
              <LuckyTile emoji="🎨" label="행운 색상" value={luckyColor} />
            ) : null}
            {luckyDirection ? (
              <LuckyTile emoji="🧭" label="행운 방위" value={luckyDirection} />
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  10. Recommendations                                          */}
      {/* ============================================================ */}
      {recommendations.length > 0 && (
        <SectionCard title="궁합 조언">
          <BulletList items={recommendations.slice(0, 4)} />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  11. Special Message                                          */}
      {/* ============================================================ */}
      {specialMessage ? (
        <SectionCard title="특별한 메시지">
          <InsetQuote text={specialMessage} />
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Fallback when no raw data                                    */}
      {/* ============================================================ */}
      {!hasRaw && result.highlights.length > 0 && (
        <SectionCard title="핵심 포인트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}

      {!hasRaw && result.recommendations.length > 0 && (
        <SectionCard title="궁합 조언">
          <BulletList items={result.recommendations} />
        </SectionCard>
      )}

      {result.specialTip ? (
        <SectionCard title="한 줄 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      ) : null}

      {!hasRaw && result.luckyItems.length > 0 && (
        <SectionCard title="행운 포인트">
          <KeywordPills keywords={result.luckyItems} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Lucky factor tile                                                  */
/* ------------------------------------------------------------------ */

function LuckyTile({
  emoji,
  label,
  value,
}: {
  emoji: string;
  label: string;
  value: string;
}) {
  return (
    <View
      style={{
        minWidth: '47%',
        flexGrow: 1,
        flexBasis: '47%',
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
        padding: fortuneTheme.spacing.md,
        gap: fortuneTheme.spacing.xs,
      }}
    >
      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
        {emoji} {label}
      </AppText>
      <AppText variant="heading4">{value}</AppText>
    </View>
  );
}

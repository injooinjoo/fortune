import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import { HeroPet } from '../heroes';
import {
  BulletList,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
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

function strArr(val: unknown): string[] {
  if (!Array.isArray(val)) return [];
  return val.map((v) => str(v)).filter(Boolean);
}

/* ------------------------------------------------------------------ */
/*  Energy level badge                                                 */
/* ------------------------------------------------------------------ */

const ENERGY_STYLES: Record<string, { emoji: string; color: string }> = {
  high: { emoji: '🔥', color: fortuneTheme.colors.error },
  medium: { emoji: '⚡', color: fortuneTheme.colors.warning },
  low: { emoji: '😴', color: fortuneTheme.colors.textTertiary },
};

function EnergyBadge({ level }: { level: string }) {
  const style = ENERGY_STYLES[level] ?? ENERGY_STYLES.medium!;
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.xs,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.chip,
        paddingHorizontal: 12,
        paddingVertical: 6,
      }}
    >
      <AppText variant="emojiInline">{style.emoji}</AppText>
      <AppText variant="labelMedium" color={style.color}>
        {level === 'high' ? '높음' : level === 'low' ? '낮음' : '보통'}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Lucky tile (color / snack / activity)                              */
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
        minWidth: '30%',
        flexGrow: 1,
        flexBasis: '30%',
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
        padding: fortuneTheme.spacing.md,
        gap: fortuneTheme.spacing.xs,
        alignItems: 'center',
      }}
    >
      <AppText variant="emojiCard">{emoji}</AppText>
      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
      <AppText variant="labelLarge" style={{ textAlign: 'center' }}>
        {value}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  PetCompatibilityResult                                             */
/* ------------------------------------------------------------------ */

export function PetCompatibilityResult(props: FortuneResultComponentProps) {
  const _meta = resultMetadataByKind['pet-compatibility'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract structured API data ---

  // Pet info (from input / top-level)
  const petName = str(raw.pet_name, str(obj(raw.input).pet_name, '반려동물'));
  const petSpecies = str(raw.pet_species, str(obj(raw.input).pet_species, ''));
  const petBreed = str(raw.pet_breed, str(obj(raw.input).pet_breed, ''));
  const greeting = str(raw.greeting);
  const summary = str(
    raw.summary,
    result.summary || `${petName}와(과) 함께하는 오늘의 인사이트를 확인해보세요.`,
  );

  // today_story
  const todayStory = obj(raw.today_story);
  const storyOpening = str(todayStory.opening);
  const morningChapter = str(todayStory.morning_chapter);
  const afternoonChapter = str(todayStory.afternoon_chapter);
  const eveningChapter = str(todayStory.evening_chapter);
  const hasStory = storyOpening || morningChapter || afternoonChapter || eveningChapter;

  // breed_specific
  const breedSpecific = obj(raw.breed_specific);
  const traitToday = str(breedSpecific.trait_today);
  const healthWatch = str(breedSpecific.health_watch);
  const groomingTip = str(breedSpecific.grooming_tip);
  const hasBreedSpecific = traitToday || healthWatch || groomingTip;

  // daily_condition
  const dailyCondition = obj(raw.daily_condition);
  const overallScore = num(dailyCondition.overall_score, num(raw.score, result.score ?? 78));
  const moodPrediction = str(dailyCondition.mood_prediction);
  const energyLevel = str(dailyCondition.energy_level, 'medium');
  const energyDescription = str(dailyCondition.energy_description);

  // owner_bond
  const ownerBond = obj(raw.owner_bond);
  const bondScore = num(ownerBond.bond_score, 75);
  const bondingTip = str(ownerBond.bonding_tip);
  const bestTime = str(ownerBond.best_time);
  const communicationHint = str(ownerBond.communication_hint);

  // lucky_items
  const luckyItems = obj(raw.lucky_items);
  const luckyColor = str(luckyItems.color);
  const luckySnack = str(luckyItems.snack);
  const luckyActivity = str(luckyItems.activity);
  const luckyTime = str(luckyItems.time);
  const luckySpot = str(luckyItems.spot);
  const hasLucky = luckyColor || luckySnack || luckyActivity;

  // pets_voice (premium)
  const petsVoice = obj(raw.pets_voice);
  const heartfeltLetter = str(petsVoice.heartfelt_letter);
  const secretConfession = str(petsVoice.secret_confession);
  const hasPetsVoice = heartfeltLetter || secretConfession;

  // bonding_mission
  const bondingMission = obj(raw.bonding_mission);
  const missionTitle = str(bondingMission.mission_title);
  const missionDescription = str(bondingMission.mission_description);
  const expectedReaction = str(bondingMission.expected_reaction);
  const hasMission = missionTitle || missionDescription;

  // health_insight (premium)
  const healthInsight = obj(raw.health_insight);
  const healthOverall = str(healthInsight.overall);
  const healthEnergy = num(healthInsight.energy_level, 0);
  const checkPoints = strArr(healthInsight.check_points);
  const seasonalTip = str(healthInsight.seasonal_tip);
  const hasHealth = healthOverall || checkPoints.length > 0;

  // activity_recommendation (premium)
  const activityRec = obj(raw.activity_recommendation);
  const actMorning = str(activityRec.morning);
  const actAfternoon = str(activityRec.afternoon);
  const actEvening = str(activityRec.evening);
  const actSpecial = str(activityRec.special_activity);
  const hasActivity = actMorning || actAfternoon || actEvening;

  // emotional_care (premium)
  const emotionalCare = obj(raw.emotional_care);
  const primaryEmotion = str(emotionalCare.primary_emotion);
  const emotionBondingTip = str(emotionalCare.bonding_tip);
  const stressIndicator = str(emotionalCare.stress_indicator);
  const hasEmotional = primaryEmotion || stressIndicator;

  // special_tips (premium)
  const specialTips = strArr(raw.special_tips);

  // Pet type display
  const petTypeEmoji =
    petSpecies === '강아지' || petSpecies === 'dog'
      ? '🐕'
      : petSpecies === '고양이' || petSpecies === 'cat'
        ? '🐱'
        : petSpecies === '토끼' || petSpecies === 'rabbit'
          ? '🐰'
          : petSpecies === '새' || petSpecies === 'bird'
            ? '🐦'
            : petSpecies === '햄스터' || petSpecies === 'hamster'
              ? '🐹'
              : '🐾';

  const petLabel = [petBreed, petSpecies].filter(Boolean).join(' ');

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Section 1: Hero — Dual-circle owner/pet bond visual          */}
      {/* ============================================================ */}
      <HeroPet />

      {/* ============================================================ */}
      {/*  Section 2: 오늘의 이야기 — Story chapters                      */}
      {/* ============================================================ */}
      {hasRaw && hasStory && (
        <SectionCard
          title="오늘의 이야기"
          description={storyOpening || `${petName}의 하루를 이야기로 만나보세요.`}
        >
          <Timeline
            items={[
              ...(morningChapter
                ? [{ title: '아침', body: morningChapter, tag: '🌅 오전' }]
                : []),
              ...(afternoonChapter
                ? [{ title: '오후', body: afternoonChapter, tag: '☀️ 오후' }]
                : []),
              ...(eveningChapter
                ? [{ title: '저녁', body: eveningChapter, tag: '🌙 저녁' }]
                : []),
            ]}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 3: 견종/묘종 특성                                      */}
      {/* ============================================================ */}
      {hasRaw && hasBreedSpecific && (
        <SectionCard
          title={`${petLabel || '품종'} 특성`}
          description={`${petTypeEmoji} 오늘의 품종별 맞춤 정보입니다.`}
        >
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {traitToday ? (
              <Card
                style={{
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <AppText variant="labelLarge">오늘의 특성</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {traitToday}
                </AppText>
              </Card>
            ) : null}
            {healthWatch ? (
              <Card
                style={{
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText variant="emojiInline">⚕️</AppText>
                  <AppText variant="labelLarge">건강 주의</AppText>
                </View>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {healthWatch}
                </AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  수의학적 진단이 아닙니다
                </AppText>
              </Card>
            ) : null}
            {groomingTip ? (
              <Card
                style={{
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText variant="emojiInline">✨</AppText>
                  <AppText variant="labelLarge">그루밍 팁</AppText>
                </View>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {groomingTip}
                </AppText>
              </Card>
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 4: 오늘의 컨디션 — mood, energy meters                 */}
      {/* ============================================================ */}
      {hasRaw && (
        <SectionCard
          title="오늘의 컨디션"
          description={`${petName}의 기분과 에너지 상태입니다.`}
        >
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: fortuneTheme.spacing.md,
            }}
          >
            <View style={{ flex: 1 }}>
              <StatRail
                items={[
                  {
                    label: '종합 컨디션',
                    value: overallScore,
                    highlight: moodPrediction,
                  },
                ]}
              />
            </View>
            <EnergyBadge level={energyLevel} />
          </View>
          {energyDescription ? (
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ marginTop: fortuneTheme.spacing.xs }}
            >
              {energyDescription}
            </AppText>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 5: 주인과의 유대 — bond score + tips                   */}
      {/* ============================================================ */}
      {hasRaw && (bondingTip || bestTime || communicationHint) && (
        <SectionCard
          title="주인과의 유대"
          description="오늘의 교감 포인트와 최적의 시간입니다."
        >
          <MetricGrid
            items={[
              { label: '유대감 점수', value: String(bondScore), note: '오늘의 교감 지수' },
              ...(bestTime
                ? [{ label: '최적의 시간', value: bestTime, note: '함께하기 좋은 시간' }]
                : []),
            ]}
          />
          {bondingTip ? <InsetQuote text={bondingTip} /> : null}
          {communicationHint ? (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="labelLarge">소통 힌트</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {communicationHint}
              </AppText>
            </Card>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 6: 교감 미션                                           */}
      {/* ============================================================ */}
      {hasRaw && hasMission && (
        <SectionCard title="오늘의 교감 미션" description="함께 해보세요!">
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              gap: fortuneTheme.spacing.md,
              alignItems: 'center',
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <AppText variant="emojiHero">🎯</AppText>
            <AppText variant="heading3" style={{ textAlign: 'center' }}>
              {missionTitle}
            </AppText>
            {missionDescription ? (
              <AppText
                variant="bodyMedium"
                color={fortuneTheme.colors.textSecondary}
                style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
              >
                {missionDescription}
              </AppText>
            ) : null}
            {expectedReaction ? (
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  marginTop: fortuneTheme.spacing.xs,
                }}
              >
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  예상 반응
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {expectedReaction}
                </AppText>
              </View>
            ) : null}
          </Card>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 7: Pet's Voice — 속마음 편지 (premium)                 */}
      {/* ============================================================ */}
      {hasRaw && hasPetsVoice && (
        <SectionCard
          title={`${petName}의 속마음`}
          description="반려동물의 시선으로 쓴 편지입니다."
        >
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              gap: fortuneTheme.spacing.md,
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <AppText variant="emojiCard" style={{ textAlign: 'center' }}>
              {petTypeEmoji}
            </AppText>
            {heartfeltLetter ? (
              <AppText
                variant="oracleBody"
                color={fortuneTheme.colors.textSecondary}
                style={{ lineHeight: 28, textAlign: 'center', fontStyle: 'italic' }}
              >
                &ldquo;{heartfeltLetter}&rdquo;
              </AppText>
            ) : null}
            {secretConfession ? (
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                }}
              >
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  비밀 고백
                </AppText>
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                  style={{ fontStyle: 'italic' }}
                >
                  {secretConfession}
                </AppText>
              </View>
            ) : null}
          </Card>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 8: 행운 포인트 — color, snack, activity                */}
      {/* ============================================================ */}
      {hasRaw && hasLucky && (
        <SectionCard title="행운 포인트" description={`${petName}에게 행운을 가져다 줄 것들`}>
          <View
            style={{
              flexDirection: 'row',
              flexWrap: 'wrap',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            {luckyColor ? <LuckyTile emoji="🎨" label="행운 색상" value={luckyColor} /> : null}
            {luckySnack ? <LuckyTile emoji="🦴" label="행운 간식" value={luckySnack} /> : null}
            {luckyActivity ? <LuckyTile emoji="🎾" label="행운 활동" value={luckyActivity} /> : null}
          </View>
          {(luckyTime || luckySpot) && (
            <View
              style={{
                flexDirection: 'row',
                flexWrap: 'wrap',
                gap: fortuneTheme.spacing.sm,
                marginTop: fortuneTheme.spacing.xs,
              }}
            >
              {luckyTime ? <LuckyTile emoji="🕐" label="행운 시간" value={luckyTime} /> : null}
              {luckySpot ? <LuckyTile emoji="📍" label="행운 장소" value={luckySpot} /> : null}
            </View>
          )}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 9: 건강 인사이트 (premium)                              */}
      {/* ============================================================ */}
      {hasRaw && hasHealth && (
        <SectionCard title="건강 인사이트" description={`${petName}의 건강 예보입니다.`}>
          {healthOverall ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {healthOverall}
            </AppText>
          ) : null}
          {healthEnergy > 0 && (
            <StatRail
              items={[{ label: '건강 에너지', value: healthEnergy }]}
            />
          )}
          {checkPoints.length > 0 && (
            <BulletList items={checkPoints} accent="체크" />
          )}
          {seasonalTip ? <InsetQuote text={seasonalTip} /> : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 10: 활동 추천 (premium)                                */}
      {/* ============================================================ */}
      {hasRaw && hasActivity && (
        <SectionCard title="활동 가이드" description="시간대별 추천 활동입니다.">
          <Timeline
            items={[
              ...(actMorning ? [{ title: '아침', body: actMorning, tag: '🌅' }] : []),
              ...(actAfternoon ? [{ title: '오후', body: actAfternoon, tag: '☀️' }] : []),
              ...(actEvening ? [{ title: '저녁', body: actEvening, tag: '🌙' }] : []),
              ...(actSpecial ? [{ title: '특별 활동', body: actSpecial, tag: '⭐' }] : []),
            ]}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 11: 감정 케어 (premium)                                */}
      {/* ============================================================ */}
      {hasRaw && hasEmotional && (
        <SectionCard title="감정 케어" description={`${petName}의 마음 상태입니다.`}>
          <MetricGrid
            items={[
              ...(primaryEmotion
                ? [{ label: '오늘의 감정', value: primaryEmotion }]
                : []),
              ...(stressIndicator
                ? [{ label: '스트레스 신호', value: stressIndicator }]
                : []),
            ]}
          />
          {emotionBondingTip ? <InsetQuote text={emotionBondingTip} /> : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 12: 특별 조언 (premium)                                */}
      {/* ============================================================ */}
      {specialTips.length > 0 && (
        <SectionCard title="특별 조언">
          <BulletList items={specialTips} />
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

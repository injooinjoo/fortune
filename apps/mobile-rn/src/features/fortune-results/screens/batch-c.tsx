import { Image, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  DoDontPair,
  HeroCard,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
  Timeline,
} from '../primitives';
import HeroRadar from '../heroes/hero-radar';
import { ResultCardFrame } from '../primitives/result-card-frame';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Safe extraction helpers for rawApiResponse                         */
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
/*  1. FamilyResult                                                    */
/* ------------------------------------------------------------------ */

function FamilyResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.family;
  const result = useResultData(props.payload);

  /* ---- Extract raw family data ---- */
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // Family member analysis
  const rawMembers = arr(raw.memberAnalysis ?? raw.member_analysis ?? raw.members);
  const rawRelationshipDynamics = str(raw.relationshipDynamics ?? raw.relationship_dynamics);
  const rawCommunicationAdvice = strArr(raw.communicationAdvice ?? raw.communication_advice);
  const rawConversationTiming = str(raw.conversationTiming ?? raw.conversation_timing);
  const rawHarmonyScore = num(raw.harmonyScore ?? raw.harmony_score ?? raw.familyHarmonyScore, 0);
  const rawFamilyKeywords = strArr(raw.familyKeywords ?? raw.family_keywords ?? raw.keywords);

  // Action plan / phases
  const rawActionPlan = obj(raw.actionPlan ?? raw.action_plan);
  const actionImmediate = str(rawActionPlan.immediate ?? rawActionPlan.today);
  const actionShortTerm = str(rawActionPlan.shortTerm ?? rawActionPlan.short_term ?? rawActionPlan.thisWeek);
  const actionLongTerm = str(rawActionPlan.longTerm ?? rawActionPlan.long_term ?? rawActionPlan.thisMonth);
  const hasActionPlan = actionImmediate || actionShortTerm || actionLongTerm;

  const summary =
    result.summary ||
    '가족 사이의 역할이 다시 정리되는 날이에요. 말보다 기준을 먼저 맞추면 편해집니다.';

  const statItems =
    result.metrics.length > 0
      ? result.metrics.map((m, i) => ({
          label: m.label,
          value: Number(m.value) || [86, 72, 91][i] || 80,
          highlight: m.note || '',
        }))
      : [
          {
            label: '부모와의 흐름',
            value: 86,
            highlight: '감정은 짧게, 기준은 분명하게 말하는 게 좋습니다.',
          },
          {
            label: '형제/자매와의 흐름',
            value: 72,
            highlight: '비교보다 분담이 잘 맞아야 오해가 줄어듭니다.',
          },
          {
            label: '가까운 가족과의 흐름',
            value: 91,
            highlight: '작은 안부 하나가 전체 분위기를 바꾸는 날입니다.',
          },
        ];

  const highlights =
    result.highlights.length > 0
      ? result.highlights
      : [
          '집안 일정은 먼저 공유하고 역할을 먼저 나누세요.',
          '상대가 해준 일을 문장으로 인정하면 분위기가 빨리 풀립니다.',
        ];

  const warnings =
    result.warnings.length > 0
      ? result.warnings
      : [
          '서운함을 길게 누적시키면 말 한마디가 더 커집니다.',
          '기대만 남기고 기준을 말하지 않으면 오해가 쌓입니다.',
        ];

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '한 번에 긴 대화를 하기보다, 짧게 두 번 나눠서 말해보세요.',
          '감정 설명보다 역할 설명이 더 잘 먹힙니다.',
          '늦은 밤보다 점심 전이나 저녁 초입이 대화 타이밍으로 좋습니다.',
        ];

  /* ---- Circular gauge score (raw or fallback) ---- */
  const gaugeScore = rawHarmonyScore > 0 ? rawHarmonyScore : (statItems[0]?.value ?? 80);
  const gaugeLabel = rawHarmonyScore > 0 ? '가족 화합 지수' : '가족 흐름';

  /* ---- Member avatar color palette ---- */
  const MEMBER_COLORS = ['#FF8A80', '#82B1FF', '#B9F6CA', '#FFE57F', '#EA80FC', '#84FFFF'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  1. 가족 화합 게이지 — Circular score                         */}
      {/* ============================================================ */}
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
            width: 120,
            height: 120,
            borderRadius: fortuneTheme.radius.full,
            borderWidth: 5,
            borderColor: '#FF8A65',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'rgba(255,138,101,0.10)',
          }}
        >
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>👨‍👩‍👧‍👦</AppText>
          <AppText
            variant="heading2"
            style={{ color: '#FF8A65' }}
          >
            {gaugeScore}
          </AppText>
        </View>
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          {gaugeLabel}
        </AppText>
        <AppText variant="oracleTitle">{meta.title}</AppText>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
        >
          {summary}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  2. 가족 구성원 카드 — Colored avatar + relationship + bar    */}
      {/* ============================================================ */}
      {hasRaw && rawMembers.length > 0 ? (
        <SectionCard title="가족 구성원" description="각 구성원과의 관계 에너지입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {rawMembers.slice(0, 6).map((item, index) => {
              const m = obj(item);
              const memberName = str(m.name, str(m.member, str(m.role, '구성원')));
              const memberRelation = str(m.role, str(m.relation, str(m.relationship, '')));
              const memberScore = num(m.score ?? m.compatibility ?? m.harmony, 80);
              const memberNote = str(m.note, str(m.description, str(m.advice, '')));
              const avatarColor = MEMBER_COLORS[index % MEMBER_COLORS.length];

              return (
                <Card
                  key={`member-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.sm,
                  }}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                    {/* Colored avatar circle */}
                    <View
                      style={{
                        width: 44,
                        height: 44,
                        borderRadius: fortuneTheme.radius.full,
                        backgroundColor: avatarColor,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <AppText variant="labelLarge" color="#FFFFFF">
                        {memberName.charAt(0)}
                      </AppText>
                    </View>
                    <View style={{ flex: 1 }}>
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                        <AppText variant="heading4">{memberName}</AppText>
                        {memberRelation ? (
                          <View
                            style={{
                              backgroundColor: `${avatarColor}30`,
                              paddingHorizontal: fortuneTheme.spacing.sm,
                              paddingVertical: 2,
                              borderRadius: fortuneTheme.radius.full,
                            }}
                          >
                            <AppText variant="labelMedium" color={avatarColor}>
                              {memberRelation}
                            </AppText>
                          </View>
                        ) : null}
                      </View>
                      {/* Score bar */}
                      <View style={{ marginTop: fortuneTheme.spacing.xs }}>
                        <View
                          style={{
                            flexDirection: 'row',
                            justifyContent: 'space-between',
                            marginBottom: 2,
                          }}
                        >
                          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                            조화도
                          </AppText>
                          <AppText variant="labelMedium" color={avatarColor}>
                            {memberScore}%
                          </AppText>
                        </View>
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
                              backgroundColor: avatarColor,
                              borderRadius: fortuneTheme.radius.full,
                              height: '100%',
                              width: `${Math.min(100, memberScore)}%`,
                            }}
                          />
                        </View>
                      </View>
                    </View>
                  </View>
                  {memberNote ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {memberNote}
                    </AppText>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      ) : (
        /* Fallback member cards from statItems when no raw members */
        <SectionCard title="가족 구성원" description="가까운 가족 관계의 흐름입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {statItems.map((item, index) => {
              const avatarColor = MEMBER_COLORS[index % MEMBER_COLORS.length];
              return (
                <Card
                  key={`stat-member-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.sm,
                  }}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                    <View
                      style={{
                        width: 44,
                        height: 44,
                        borderRadius: fortuneTheme.radius.full,
                        backgroundColor: avatarColor,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <AppText variant="labelLarge" color="#FFFFFF">
                        {item.label.charAt(0)}
                      </AppText>
                    </View>
                    <View style={{ flex: 1 }}>
                      <AppText variant="heading4">{item.label}</AppText>
                      <View style={{ marginTop: fortuneTheme.spacing.xs }}>
                        <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 2 }}>
                          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>조화도</AppText>
                          <AppText variant="labelMedium" color={avatarColor}>{item.value}%</AppText>
                        </View>
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
                              backgroundColor: avatarColor,
                              borderRadius: fortuneTheme.radius.full,
                              height: '100%',
                              width: `${Math.min(100, item.value)}%`,
                            }}
                          />
                        </View>
                      </View>
                    </View>
                  </View>
                  {item.highlight ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {item.highlight}
                    </AppText>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  3. 소통 조언 — Speech bubble style cards                     */}
      {/* ============================================================ */}
      <SectionCard title="소통 조언" description="가족 간 대화를 더 부드럽게 만드는 방법입니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {(hasRaw && rawCommunicationAdvice.length > 0
            ? rawCommunicationAdvice.slice(0, 5)
            : recommendations
          ).map((advice, index) => (
            <View
              key={`advice-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.lg,
                borderTopLeftRadius: fortuneTheme.radius.xs,
                padding: fortuneTheme.spacing.md,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ fontSize: 16, lineHeight: 20 }}>💬</AppText>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  조언 {index + 1}
                </AppText>
              </View>
              <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
                {advice}
              </AppText>
            </View>
          ))}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  4. 대화 타이밍 — Clock icon + best time                      */}
      {/* ============================================================ */}
      <SectionCard title="대화 타이밍">
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderLeftWidth: 4,
            borderLeftColor: '#FFB74D',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <AppText style={{ fontSize: 22, lineHeight: 28 }}>🕐</AppText>
            <AppText variant="heading4">최적의 대화 시간</AppText>
          </View>
          <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
            {rawConversationTiming || '늦은 밤보다 점심 전이나 저녁 초입이 대화 타이밍으로 좋습니다.'}
          </AppText>
        </Card>
      </SectionCard>

      {/* ============================================================ */}
      {/*  Raw API: Relationship Dynamics                               */}
      {/* ============================================================ */}
      {hasRaw && rawRelationshipDynamics ? (
        <SectionCard title="관계 역학">
          <InsetQuote text={rawRelationshipDynamics} />
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Do / Don't pair                                              */}
      {/* ============================================================ */}
      <DoDontPair
        data={{
          doTitle: '좋은 흐름',
          doItems: highlights,
          dontTitle: '주의 흐름',
          dontItems: warnings,
        }}
      />

      {/* ============================================================ */}
      {/*  Raw API: 3-Phase Action Plan                                 */}
      {/* ============================================================ */}
      {hasRaw && hasActionPlan && (
        <SectionCard title="가족 관계 실행 플랜" description="단계별로 관계를 개선하는 계획입니다.">
          <Timeline
            items={[
              ...(actionImmediate
                ? [{ title: '오늘', tag: '즉시', body: actionImmediate }]
                : []),
              ...(actionShortTerm
                ? [{ title: '이번 주', tag: '단기', body: actionShortTerm }]
                : []),
              ...(actionLongTerm
                ? [{ title: '이번 달', tag: '장기', body: actionLongTerm }]
                : []),
            ]}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  5. 가족 키워드 — Warm-colored pills                          */}
      {/* ============================================================ */}
      <SectionCard title="가족 키워드">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {(hasRaw && rawFamilyKeywords.length > 0
            ? rawFamilyKeywords.slice(0, 8)
            : ['세대 균형', '관계 재정렬', '대화 힌트']
          ).map((kw, index) => {
            const warmColors = ['#FFE0B2', '#FFCCBC', '#FFF9C4', '#FFE082', '#FFCC80', '#F8BBD0', '#D7CCC8', '#FFD180'];
            const bgColor = warmColors[index % warmColors.length];
            return (
              <View
                key={`kw-${index}`}
                style={{
                  backgroundColor: bgColor,
                  paddingHorizontal: fortuneTheme.spacing.md,
                  paddingVertical: fortuneTheme.spacing.xs + 2,
                  borderRadius: fortuneTheme.radius.full,
                }}
              >
                <AppText variant="labelMedium" color="#5D4037">
                  {kw}
                </AppText>
              </View>
            );
          })}
        </View>
      </SectionCard>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="특별 메시지">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  2. PastLifeResult — Premium 전생 리딩                               */
/* ------------------------------------------------------------------ */

const PLOT_TYPE_EMOJI: Record<string, string> = {
  TRAGEDY: '😢',
  TRIUMPH: '🏆',
  ROMANCE: '💕',
  MYSTERY: '🔮',
  ADVENTURE: '⚔️',
};

const PLOT_TYPE_LABEL: Record<string, string> = {
  TRAGEDY: '비극',
  TRIUMPH: '승리',
  ROMANCE: '로맨스',
  MYSTERY: '미스터리',
  ADVENTURE: '모험',
};

const ERA_CONFIG: Record<string, { label: string; color: string }> = {
  early_joseon: { label: '초기 조선', color: '#3B82F6' },
  middle_joseon: { label: '중기 조선', color: '#22C55E' },
  late_joseon: { label: '후기 조선', color: '#F59E0B' },
};

const GENDER_LABEL: Record<string, string> = {
  male: '남성',
  female: '여성',
};

function PastLifeResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['past-life'];
  const result = useResultData(props.payload);

  /* ---- Extract raw past-life data ---- */
  const raw = props.payload?.rawApiResponse ?? {};
  const fortune = obj(raw.fortune ?? raw.data ?? raw);
  const hasRaw = Object.keys(fortune).length > 0;

  const portraitUrl = str(fortune.portraitUrl);
  const pastLifeName = str(fortune.pastLifeName);
  const pastLifeStatus = str(fortune.pastLifeStatus);
  const pastLifeStatusEn = str(fortune.pastLifeStatusEn);
  const pastLifeGender = str(fortune.pastLifeGender);
  const pastLifeEra = str(fortune.pastLifeEra);
  const plotType = str(fortune.plotType);
  const scenarioCategory = str(fortune.scenarioCategory);
  const chapters = arr(fortune.chapters) as { title?: string; content?: string; emoji?: string }[];
  const story = str(fortune.story);
  const advice = str(fortune.advice);
  const score = num(fortune.score, 0);

  const hasPastLifeData = !!(pastLifeName || pastLifeStatus || portraitUrl || chapters.length > 0);

  /* ---- Era config ---- */
  const eraInfo = ERA_CONFIG[pastLifeEra] ?? { label: pastLifeEra, color: fortuneTheme.colors.textTertiary };

  /* ---- Plot type display ---- */
  const plotEmoji = PLOT_TYPE_EMOJI[plotType] ?? '📜';
  const plotLabel = PLOT_TYPE_LABEL[plotType] ?? plotType;

  /* ---- Fallback data from useResultData ---- */
  const summary =
    result.summary ||
    '전생의 기억이 펼쳐집니다. 지금의 당신과 연결된 과거의 이야기를 읽어보세요.';

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '전생의 패턴을 인식하면 현생의 반복을 끊을 수 있습니다.',
          '과거의 강점은 지금도 당신 안에 남아 있습니다.',
          '전생의 미완성 과제가 현생의 방향을 알려줍니다.',
        ];

  /* ---- If no past-life raw data, show fallback ---- */
  if (!hasPastLifeData) {
    const chips =
      result.contextTags.length > 0
        ? result.contextTags
        : ['전생 탐구', '운명의 연결', '과거의 메시지'];

    return (
      <View style={{ gap: fortuneTheme.spacing.md }}>
        <HeroCard emoji="🏯" title={meta.title} description={summary} chips={chips} />

        <SectionCard title="전생의 메시지" description="과거로부터 전해지는 이야기입니다.">
          <InsetQuote text={result.specialTip || '전생의 기억은 조용히 현재를 비춥니다.'} />
        </SectionCard>

        {result.recommendations.length > 0 && (
          <SectionCard title="현생 조언">
            <BulletList items={result.recommendations} />
          </SectionCard>
        )}
      </View>
    );
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Section 1: Portrait Hero                                     */}
      {/* ============================================================ */}
      <Card
        style={{
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
          paddingVertical: fortuneTheme.spacing.lg,
        }}
      >
        {/* Portrait image or placeholder */}
        {portraitUrl ? (
          <View
            style={{
              width: '100%',
              aspectRatio: 3 / 4,
              borderRadius: fortuneTheme.radius.lg,
              overflow: 'hidden',
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
            }}
          >
            <Image
              source={{ uri: portraitUrl, cache: 'force-cache' }}
              style={{ width: '100%', height: '100%' }}
              resizeMode="cover"
            />
          </View>
        ) : (
          <View
            style={{
              width: '100%',
              aspectRatio: 3 / 4,
              borderRadius: fortuneTheme.radius.lg,
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <AppText variant="displayLarge">🏯</AppText>
          </View>
        )}

        {/* Past life name (calligraphy style) */}
        {pastLifeName ? (
          <AppText variant="heading2" style={{ textAlign: 'center' }}>
            {pastLifeName}
          </AppText>
        ) : null}

        {/* Status badge: "승정원 서리 (Royal Secretary)" */}
        {pastLifeStatus ? (
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary} style={{ textAlign: 'center' }}>
            {pastLifeStatusEn ? `${pastLifeStatus} (${pastLifeStatusEn})` : pastLifeStatus}
          </AppText>
        ) : null}

        {/* Era + Gender badges row */}
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm, flexWrap: 'wrap', justifyContent: 'center' }}>
          {pastLifeEra ? (
            <View
              style={{
                backgroundColor: eraInfo.color,
                paddingHorizontal: fortuneTheme.spacing.sm,
                paddingVertical: fortuneTheme.spacing.xs,
                borderRadius: fortuneTheme.radius.full,
              }}
            >
              <AppText variant="labelMedium" color="#FFFFFF">
                {eraInfo.label}
              </AppText>
            </View>
          ) : null}
          {pastLifeGender ? (
            <View
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                paddingHorizontal: fortuneTheme.spacing.sm,
                paddingVertical: fortuneTheme.spacing.xs,
                borderRadius: fortuneTheme.radius.full,
                borderWidth: 1,
                borderColor: fortuneTheme.colors.border,
              }}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                {GENDER_LABEL[pastLifeGender] ?? pastLifeGender}
              </AppText>
            </View>
          ) : null}
        </View>
      </Card>

      {/* ============================================================ */}
      {/*  Section 2: Character Identity Card                           */}
      {/* ============================================================ */}
      <SectionCard title="전생 신원" description="당신의 전생 정체성입니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {pastLifeStatus ? (
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>신분</AppText>
              <AppText variant="bodySmall">{pastLifeStatus}</AppText>
            </View>
          ) : null}
          {pastLifeEra ? (
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>시대</AppText>
              <AppText variant="bodySmall">{eraInfo.label}</AppText>
            </View>
          ) : null}
          {pastLifeName ? (
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>이름</AppText>
              <AppText variant="bodySmall">{pastLifeName}</AppText>
            </View>
          ) : null}
          {pastLifeGender ? (
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>성별</AppText>
              <AppText variant="bodySmall">{GENDER_LABEL[pastLifeGender] ?? pastLifeGender}</AppText>
            </View>
          ) : null}
          {plotType ? (
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>줄거리 유형</AppText>
              <AppText variant="bodySmall">{plotEmoji} {plotLabel}</AppText>
            </View>
          ) : null}
          {scenarioCategory ? (
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>배경</AppText>
              <AppText variant="bodySmall">{scenarioCategory}</AppText>
            </View>
          ) : null}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  Section 3: Story Chapters                                    */}
      {/* ============================================================ */}
      {chapters.length > 0 ? (
        <SectionCard title="전생 이야기" description="당신의 전생에서 펼쳐진 서사입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {chapters.map((chapter, index) => {
              const chapterTitle = str(chapter.title, `제 ${index + 1}장`);
              const chapterEmoji = str(chapter.emoji, '📖');
              const chapterContent = str(chapter.content);

              return (
                <View key={`chapter-${index}`} style={{ gap: fortuneTheme.spacing.xs }}>
                  {index > 0 ? (
                    <View
                      style={{
                        height: 1,
                        backgroundColor: fortuneTheme.colors.divider,
                        marginVertical: fortuneTheme.spacing.xs,
                      }}
                    />
                  ) : null}
                  <AppText variant="heading4">
                    {chapterEmoji} {chapterTitle}
                  </AppText>
                  {chapterContent ? (
                    <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
                      {chapterContent}
                    </AppText>
                  ) : null}
                </View>
              );
            })}
          </View>
        </SectionCard>
      ) : story ? (
        <SectionCard title="전생 이야기" description="당신의 전생에서 펼쳐진 서사입니다.">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
            {story}
          </AppText>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 4: 전생의 메시지 + 공명도                              */}
      {/* ============================================================ */}
      {(advice || score > 0) ? (
        <SectionCard title="전생의 메시지">
          {advice ? <InsetQuote text={advice} /> : null}
          {score > 0 ? (
            <View
              style={{
                alignSelf: 'flex-start',
                backgroundColor: fortuneTheme.colors.ctaBackground,
                paddingHorizontal: fortuneTheme.spacing.md,
                paddingVertical: fortuneTheme.spacing.sm,
                borderRadius: fortuneTheme.radius.full,
                marginTop: advice ? fortuneTheme.spacing.sm : 0,
              }}
            >
              <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
                공명도 {score}점
              </AppText>
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 5: 현생 조언                                          */}
      {/* ============================================================ */}
      <SectionCard title="현생 조언" description="전생의 흐름이 현재에 전하는 메시지입니다.">
        <BulletList items={recommendations} />
      </SectionCard>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="특별 메시지">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  3. WishResult                                                      */
/* ------------------------------------------------------------------ */

function WishResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.wish;
  const result = useResultData(props.payload);

  /* ---- Extract raw wish data ---- */
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // Wish analysis
  const rawWishAnalysis = obj(raw.wishAnalysis ?? raw.wish_analysis ?? raw.analysis);
  const feasibility = str(rawWishAnalysis.feasibility ?? rawWishAnalysis.feasibilityLevel);
  const feasibilityScore = num(rawWishAnalysis.feasibilityScore ?? rawWishAnalysis.score, 0);
  const timingAdvice = str(rawWishAnalysis.timing ?? rawWishAnalysis.timingAdvice ?? rawWishAnalysis.timing_advice);
  const obstacles = strArr(rawWishAnalysis.obstacles ?? rawWishAnalysis.challenges);

  // Manifestation strategy
  const rawStrategy = obj(raw.manifestationStrategy ?? raw.manifestation_strategy ?? raw.strategy);
  const strategyOverview = str(rawStrategy.overview ?? rawStrategy.description ?? rawStrategy.summary);
  const strategySteps = strArr(rawStrategy.steps ?? rawStrategy.actions);
  const hasStrategy = strategyOverview || strategySteps.length > 0;

  // Lucky elements for the wish
  const rawLuckyElements = obj(raw.luckyElements ?? raw.lucky_elements ?? raw.lucky);
  const luckyColor = str(rawLuckyElements.color ?? rawLuckyElements.luckyColor);
  const luckyNumber = str(rawLuckyElements.number ?? rawLuckyElements.luckyNumber);
  const luckyDirection = str(rawLuckyElements.direction ?? rawLuckyElements.luckyDirection);
  const luckyTime = str(rawLuckyElements.time ?? rawLuckyElements.luckyTime ?? rawLuckyElements.bestTime);
  const luckyElementsList: string[] = [luckyColor, luckyNumber, luckyDirection, luckyTime].filter(Boolean);

  // Action steps
  const rawActionSteps = strArr(raw.actionSteps ?? raw.action_steps ?? raw.steps);

  // Wish keywords
  const rawWishKeywords = strArr(raw.wishKeywords ?? raw.wish_keywords ?? raw.keywords);

  const summary =
    result.summary ||
    '짧지만 확실한 성공 신호가 먼저 보이는 날이에요. 지금은 크게 바꾸기보다, 성공 확률이 높은 한 번을 잡는 게 좋습니다.';

  const heroTitle =
    result.highlights.length > 0
      ? result.highlights[0]
      : '지금은 반복이 성과를 만듭니다.';

  const heroBody =
    result.highlights.length > 1
      ? result.highlights[1]
      : '기대치를 크게 잡기보다, 이미 잘 되는 한 가지를 2번 더 해보세요.';

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '한 번에 모든 걸 바꾸기보다, 성공한 한 번을 다시 복제해보세요.',
          '결정 직전의 망설임은 길게 끌지 않는 편이 좋습니다.',
          '사람이 많은 자리보다, 혼자 시작하는 순간에 더 강합니다.',
        ];

  /* ---- Wish gauge score ---- */
  const wishGaugeScore = feasibilityScore > 0 ? feasibilityScore : 78;

  /* ---- Lucky element tile data ---- */
  const LUCKY_ICONS: Record<string, string> = {
    '행운 색상': '🎨',
    '행운 숫자': '🔢',
    '행운 방향': '🧭',
    '행운 시간': '🕐',
  };
  const luckyTiles = [
    ...(luckyColor ? [{ label: '행운 색상', value: luckyColor }] : []),
    ...(luckyNumber ? [{ label: '행운 숫자', value: luckyNumber }] : []),
    ...(luckyDirection ? [{ label: '행운 방향', value: luckyDirection }] : []),
    ...(luckyTime ? [{ label: '행운 시간', value: luckyTime }] : []),
  ];

  /* ---- Merged manifestation steps ---- */
  const allSteps = hasStrategy && strategySteps.length > 0
    ? strategySteps
    : rawActionSteps.length > 0
      ? rawActionSteps
      : recommendations;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  1. 소원 실현도 게이지 — Star-themed circular score            */}
      {/* ============================================================ */}
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
            width: 120,
            height: 120,
            borderRadius: fortuneTheme.radius.full,
            borderWidth: 5,
            borderColor: '#FFD700',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'rgba(255,215,0,0.08)',
          }}
        >
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>⭐</AppText>
          <AppText
            variant="heading2"
            style={{ color: '#FFD700' }}
          >
            {wishGaugeScore}
          </AppText>
        </View>
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          소원 실현도
        </AppText>
        <AppText variant="oracleTitle">{meta.title}</AppText>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
        >
          {summary}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  2. 실현 가능성 분석 — Feasibility bar + timing card           */}
      {/* ============================================================ */}
      <SectionCard title="실현 가능성 분석" description="소원의 실현 가능성과 타이밍입니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {/* Feasibility bar */}
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <AppText variant="heading4">{heroTitle}</AppText>
              <AppText variant="labelLarge" color="#FFD700">
                {wishGaugeScore}%
              </AppText>
            </View>
            <View
              style={{
                backgroundColor: fortuneTheme.colors.background,
                borderRadius: fortuneTheme.radius.full,
                height: 10,
                overflow: 'hidden',
              }}
            >
              <View
                style={{
                  backgroundColor: '#FFD700',
                  borderRadius: fortuneTheme.radius.full,
                  height: '100%',
                  width: `${Math.min(100, wishGaugeScore)}%`,
                }}
              />
            </View>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {feasibility || heroBody}
            </AppText>
          </Card>
          {/* Timing card */}
          {timingAdvice ? (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.backgroundTertiary,
                borderLeftWidth: 4,
                borderLeftColor: '#FFD700',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ fontSize: 18, lineHeight: 22 }}>🕐</AppText>
                <AppText variant="heading4">실현 타이밍</AppText>
              </View>
              <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
                {timingAdvice}
              </AppText>
            </Card>
          ) : null}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  3. 장애물 — Red warning cards                                */}
      {/* ============================================================ */}
      {obstacles.length > 0 && (
        <SectionCard title="장애물" description="소원 달성을 방해할 수 있는 요소입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {obstacles.slice(0, 5).map((obstacle, index) => (
              <Card
                key={`obstacle-${index}`}
                style={{
                  backgroundColor: 'rgba(255,59,48,0.08)',
                  borderLeftWidth: 4,
                  borderLeftColor: '#FF3B30',
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText style={{ fontSize: 16, lineHeight: 20 }}>⚠️</AppText>
                  <AppText variant="labelLarge" color="#FF6B6B">
                    장애물 {index + 1}
                  </AppText>
                </View>
                <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
                  {obstacle}
                </AppText>
              </Card>
            ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  4. 매니페스테이션 전략 — Step-by-step numbered cards          */}
      {/* ============================================================ */}
      <SectionCard
        title="매니페스테이션 전략"
        description={strategyOverview || '소원 실현을 위한 단계별 전략입니다.'}
      >
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {allSteps.slice(0, 5).map((step, index) => (
            <Card
              key={`step-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                {/* Step number badge */}
                <View
                  style={{
                    width: 32,
                    height: 32,
                    borderRadius: fortuneTheme.radius.full,
                    backgroundColor: '#FFD700',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <AppText variant="labelLarge" color="#1A1A1A">
                    {index + 1}
                  </AppText>
                </View>
                <View style={{ flex: 1 }}>
                  <AppText variant="bodyMedium" color={fortuneTheme.colors.textPrimary}>
                    {step}
                  </AppText>
                </View>
              </View>
            </Card>
          ))}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  5. 행운 요소 — Lucky element tiles                           */}
      {/* ============================================================ */}
      <SectionCard title="행운 요소" description="소원 성취에 도움이 되는 행운의 요소입니다.">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {(luckyTiles.length > 0
            ? luckyTiles
            : [
                { label: '행운 색상', value: '골드' },
                { label: '행운 숫자', value: '7' },
                { label: '행운 방향', value: '남동쪽' },
                { label: '행운 시간', value: '오후 3시' },
              ]
          ).map((tile, index) => {
            const tileColors = ['#FFF8E1', '#E8F5E9', '#E3F2FD', '#FFF3E0'];
            const tileBorderColors = ['#FFD700', '#66BB6A', '#42A5F5', '#FF9800'];
            return (
              <View
                key={`lucky-${index}`}
                style={{
                  flexBasis: '47%',
                  flexGrow: 1,
                  minWidth: '47%',
                }}
              >
                <Card
                  style={{
                    backgroundColor: fortuneTheme.colors.backgroundTertiary,
                    borderWidth: 1,
                    borderColor: tileBorderColors[index % tileBorderColors.length],
                    alignItems: 'center',
                    gap: fortuneTheme.spacing.xs,
                    paddingVertical: fortuneTheme.spacing.md,
                  }}
                >
                  <AppText style={{ fontSize: 22, lineHeight: 28 }}>
                    {LUCKY_ICONS[tile.label] ?? '✨'}
                  </AppText>
                  <AppText variant="heading3" color={tileBorderColors[index % tileBorderColors.length]}>
                    {tile.value}
                  </AppText>
                  <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                    {tile.label}
                  </AppText>
                </Card>
              </View>
            );
          })}
        </View>
      </SectionCard>

      {/* --- Raw API: Wish Keywords --- */}
      {hasRaw && rawWishKeywords.length > 0 ? (
        <SectionCard title="소원 키워드">
          <KeywordPills keywords={rawWishKeywords.slice(0, 8)} />
        </SectionCard>
      ) : null}

      {result.hasApiData && result.specialTip && (
        <SectionCard title="특별 메시지">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  4. PersonalityDnaResult                                            */
/* ------------------------------------------------------------------ */

function PersonalityDnaResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="personality-dna" data={payload} progress={1}>
      <HeroRadar data={payload} progress={1} />
    </ResultCardFrame>
  );
}

export const ResultBatchC = {
  FamilyResult,
  PastLifeResult,
  WishResult,
  PersonalityDnaResult,
};

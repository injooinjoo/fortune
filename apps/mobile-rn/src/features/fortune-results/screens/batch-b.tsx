import { View } from 'react-native';

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
  Timeline,
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Type helpers for raw API response (same pattern as face-reading)   */
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

/* -------------------------------------------------------------------------- */
/*  CareerResult                                                              */
/* -------------------------------------------------------------------------- */

function CareerResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.career;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  const roleFit = result.metrics[0]?.value ?? '88';
  const roleFitNote = result.metrics[0]?.note ?? '책임감 있는 포지션에 강함';
  const expansion = result.metrics[1]?.value ?? '73';
  const expansionNote = result.metrics[1]?.note ?? '무리한 확장은 보류';
  const execution = result.metrics[2]?.value ?? '85';
  const executionNote = result.metrics[2]?.note ?? '시작 버튼이 빠름';
  const teamwork = result.metrics[3]?.value ?? '78';
  const teamworkNote = result.metrics[3]?.note ?? '역할 분리가 있어야 편함';

  const summary = result.hasApiData
    ? result.summary
    : '이번 커리어 흐름은 확장보다 정렬이 먼저입니다. 잘 맞는 역할과 집중해야 할 기술을 먼저 고르면 속도가 붙습니다.';

  const recommendations = result.hasApiData
    ? result.recommendations
    : [
        '문제를 구조화해서 말할 때 신뢰가 빠르게 쌓입니다.',
        '역할 범위를 명확히 잡으면 추진력이 커집니다.',
      ];

  const warnings = result.hasApiData
    ? result.warnings
    : [
        '잘하는 일을 너무 많이 동시에 맡으면 집중력이 떨어집니다.',
        '당장 눈에 띄는 제안보다 오래 남는 구조를 먼저 봐야 합니다.',
      ];

  const highlights = result.hasApiData
    ? result.highlights
    : [
        '이번 커리어 운은 새로운 시작보다 \'정리된 신뢰\'를 쌓는 쪽에서 크게 열립니다.',
      ];

  const luckyItems = result.hasApiData
    ? result.luckyItems
    : ['월요일 오전', '정리된 문서', '차분한 블루', '짧은 보고'];

  // --- Raw API: skill analysis, action plan, industry insights, networking ---
  const rawCareerPath = str(raw.careerPath);
  const rawPredictions = arr(raw.predictions);
  const rawSkillAnalysis = arr(raw.skillAnalysis);
  const rawActionPlan = obj(raw.actionPlan);
  const rawIndustryInsights = str(raw.industryInsights);
  const rawNetworkingAdvice = strArr(raw.networkingAdvice);
  const rawCareerKeywords = strArr(raw.careerKeywords);
  const rawLuckyPeriods = arr(raw.luckyPeriods);
  const rawCautionPeriods = arr(raw.cautionPeriods);

  const actionImmediate = str(rawActionPlan.immediate);
  const actionShortTerm = str(rawActionPlan.shortTerm);
  const actionLongTerm = str(rawActionPlan.longTerm);
  const hasActionPlan = actionImmediate || actionShortTerm || actionLongTerm;

  /* --- Computed display values --- */
  const overallScore = Math.round(
    (num(roleFit) + num(expansion) + num(execution) + num(teamwork)) / 4,
  );
  const scoreColor =
    overallScore >= 85
      ? '#34C759'
      : overallScore >= 70
        ? '#8FB8FF'
        : overallScore >= 50
          ? '#FFCC00'
          : '#FF3B30';

  const skillLevelBadge = (level: string) => {
    const l = level.toLowerCase();
    if (l.includes('전문') || l.includes('expert') || l.includes('master'))
      return { label: '전문', color: '#FFD700', bg: '#FFD70020' };
    if (l.includes('고급') || l.includes('advanced') || l.includes('senior'))
      return { label: '고급', color: '#34C759', bg: '#34C75920' };
    if (l.includes('중급') || l.includes('intermediate') || l.includes('mid'))
      return { label: '중급', color: '#8FB8FF', bg: '#8FB8FF20' };
    return { label: '초급', color: '#FFCC00', bg: '#FFCC0020' };
  };

  const statDashboard = [
    { emoji: '🎯', label: '역할적합도', value: num(roleFit), note: roleFitNote, color: '#8B7BE8' },
    { emoji: '🚀', label: '확장운', value: num(expansion), note: expansionNote, color: '#34C759' },
    { emoji: '⚡', label: '실행력', value: num(execution), note: executionNote, color: '#FFCC00' },
    { emoji: '🤝', label: '팀워크', value: num(teamwork), note: teamworkNote, color: '#8FB8FF' },
  ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  1. Career Score Gauge (Circular)                             */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>💼</AppText>
          <View style={{ flex: 1 }}>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              커리어 컨설팅 리포트
            </AppText>
            <AppText variant="oracleTitle">{meta.title}</AppText>
          </View>
        </View>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              width: 120,
              height: 120,
              borderRadius: 60,
              borderWidth: 8,
              borderColor: scoreColor,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: `${scoreColor}15`,
            }}
          >
            <AppText style={{ fontSize: 36, fontWeight: '800', color: scoreColor, lineHeight: 44 }}>
              {overallScore}
            </AppText>
          </View>
          <AppText variant="labelLarge" style={{ color: scoreColor }}>
            {overallScore >= 85
              ? '탁월한 흐름'
              : overallScore >= 70
                ? '좋은 흐름'
                : overallScore >= 50
                  ? '조정 필요'
                  : '신중 구간'}
          </AppText>
        </View>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center' }}
        >
          {summary}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  2. Role Fitness Dashboard (2x2 grid with progress bars)     */}
      {/* ============================================================ */}
      <SectionCard title="역할 적합도 대시보드" description="커리어 핵심 4대 지표입니다.">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {statDashboard.map((stat) => {
            const clamped = Math.max(0, Math.min(100, stat.value));
            return (
              <View
                key={stat.label}
                style={{
                  minWidth: '47%',
                  flexGrow: 1,
                  flexBasis: '47%',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText style={{ fontSize: 18, lineHeight: 24 }}>{stat.emoji}</AppText>
                  <AppText variant="labelLarge">{stat.label}</AppText>
                </View>
                <AppText variant="heading3" style={{ color: stat.color }}>
                  {clamped}
                </AppText>
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
                      backgroundColor: stat.color,
                      borderRadius: fortuneTheme.radius.full,
                      height: '100%',
                      width: `${clamped}%`,
                    }}
                  />
                </View>
                {stat.note ? (
                  <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                    {stat.note}
                  </AppText>
                ) : null}
              </View>
            );
          })}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  3. Skill Analysis Cards (with level badges)                  */}
      {/* ============================================================ */}
      {hasRaw && rawSkillAnalysis.length > 0 && (
        <SectionCard title="스킬 분석" description="보유 스킬과 성장 가능성 분석입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {rawSkillAnalysis.slice(0, 6).map((item, index) => {
              const s = obj(item);
              const skillName = str(s.name, str(s.skill, '스킬'));
              const skillLevel = str(s.level, '중급');
              const skillScore = num(s.score, 75);
              const skillNote = str(s.note, str(s.description));
              const badge = skillLevelBadge(skillLevel);

              return (
                <View
                  key={`skill-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    borderRadius: fortuneTheme.radius.md,
                    padding: fortuneTheme.spacing.md,
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
                    <AppText variant="labelLarge">{skillName}</AppText>
                    <View
                      style={{
                        backgroundColor: badge.bg,
                        borderRadius: fortuneTheme.radius.full,
                        paddingHorizontal: fortuneTheme.spacing.sm,
                        paddingVertical: 2,
                      }}
                    >
                      <AppText
                        variant="labelMedium"
                        style={{ color: badge.color, fontWeight: '700' }}
                      >
                        {badge.label}
                      </AppText>
                    </View>
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
                        backgroundColor: badge.color,
                        borderRadius: fortuneTheme.radius.full,
                        height: '100%',
                        width: `${Math.min(100, skillScore)}%`,
                      }}
                    />
                  </View>
                  {skillNote ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {skillNote}
                    </AppText>
                  ) : null}
                </View>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* --- Raw API: Career Path --- */}
      {hasRaw && rawCareerPath ? (
        <SectionCard title="커리어 방향" description="현재 흐름에서 가장 유리한 커리어 방향입니다.">
          <InsetQuote text={rawCareerPath} />
        </SectionCard>
      ) : null}

      {/* --- Raw API: Predictions --- */}
      {hasRaw && rawPredictions.length > 0 && (
        <SectionCard title="커리어 예측" description="단기/중기 커리어 흐름 예측입니다.">
          <Timeline
            items={rawPredictions.slice(0, 4).map((item) => {
              const p = obj(item);
              return {
                title: str(p.period, str(p.title, '예측')),
                tag: str(p.tag, str(p.type)),
                body: str(p.description, str(p.content, '커리어 흐름을 주시하세요.')),
              };
            })}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  4. 3-Phase Action Plan (visual timeline with step circles)   */}
      {/* ============================================================ */}
      <SectionCard title="3단계 액션 플랜" description="즉시 / 단기 / 장기 실행 계획입니다.">
        <View style={{ gap: fortuneTheme.spacing.md }}>
          {([
            {
              step: 1,
              label: '즉시 실행',
              tag: '지금',
              color: '#34C759',
              body: hasActionPlan && actionImmediate
                ? actionImmediate
                : '해야 할 일과 하지 않을 일을 먼저 나눕니다.',
            },
            {
              step: 2,
              label: '단기 목표',
              tag: '1-3개월',
              color: '#8FB8FF',
              body: hasActionPlan && actionShortTerm
                ? actionShortTerm
                : '작은 성과를 보여주는 결과물을 하나 만듭니다.',
            },
            {
              step: 3,
              label: '장기 비전',
              tag: '6개월+',
              color: '#8B7BE8',
              body: hasActionPlan && actionLongTerm
                ? actionLongTerm
                : '정리된 포지션으로 제안하거나 지원하기 좋습니다.',
            },
          ] as const).map((phase) => (
            <View
              key={phase.step}
              style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}
            >
              <View style={{ alignItems: 'center', width: 36 }}>
                <View
                  style={{
                    width: 32,
                    height: 32,
                    borderRadius: 16,
                    backgroundColor: `${phase.color}25`,
                    borderWidth: 2,
                    borderColor: phase.color,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <AppText
                    variant="labelLarge"
                    style={{ color: phase.color, fontWeight: '800' }}
                  >
                    {phase.step}
                  </AppText>
                </View>
                {phase.step < 3 && (
                  <View
                    style={{
                      width: 2,
                      flex: 1,
                      minHeight: 16,
                      backgroundColor: fortuneTheme.colors.borderOpaque,
                      marginTop: 4,
                    }}
                  />
                )}
              </View>
              <View
                style={{
                  flex: 1,
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText variant="labelLarge">{phase.label}</AppText>
                  <View
                    style={{
                      backgroundColor: `${phase.color}20`,
                      borderRadius: fortuneTheme.radius.full,
                      paddingHorizontal: fortuneTheme.spacing.xs,
                      paddingVertical: 1,
                    }}
                  >
                    <AppText variant="labelMedium" style={{ color: phase.color, fontSize: 10 }}>
                      {phase.tag}
                    </AppText>
                  </View>
                </View>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {phase.body}
                </AppText>
              </View>
            </View>
          ))}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  5. Lucky / Caution Periods (side-by-side tinted cards)       */}
      {/* ============================================================ */}
      {hasRaw && (rawLuckyPeriods.length > 0 || rawCautionPeriods.length > 0) ? (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {/* Lucky periods (green tint) */}
          {rawLuckyPeriods.length > 0 && (
            <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
              <Card
                style={{
                  backgroundColor: '#34C75912',
                  borderWidth: 1,
                  borderColor: '#34C75930',
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText style={{ fontSize: 18, lineHeight: 24 }}>🍀</AppText>
                  <AppText variant="heading4" style={{ color: '#34C759' }}>행운 시기</AppText>
                </View>
                {rawLuckyPeriods.slice(0, 3).map((item, i) => {
                  const p = obj(item);
                  return (
                    <View key={`lucky-${i}`} style={{ gap: 2 }}>
                      <AppText variant="labelMedium" style={{ color: '#34C759' }}>
                        {str(p.period, str(p.title, '행운 시기'))}
                      </AppText>
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {str(p.description, str(p.content, str(p.advice, '이 시기를 활용하세요.')))}
                      </AppText>
                    </View>
                  );
                })}
              </Card>
            </View>
          )}
          {/* Caution periods (red tint) */}
          {rawCautionPeriods.length > 0 && (
            <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
              <Card
                style={{
                  backgroundColor: '#FF3B3012',
                  borderWidth: 1,
                  borderColor: '#FF3B3030',
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText style={{ fontSize: 18, lineHeight: 24 }}>⚠️</AppText>
                  <AppText variant="heading4" style={{ color: '#FF3B30' }}>주의 시기</AppText>
                </View>
                {rawCautionPeriods.slice(0, 3).map((item, i) => {
                  const p = obj(item);
                  return (
                    <View key={`caution-${i}`} style={{ gap: 2 }}>
                      <AppText variant="labelMedium" style={{ color: '#FF3B30' }}>
                        {str(p.period, str(p.title, '주의 시기'))}
                      </AppText>
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {str(p.description, str(p.content, str(p.advice, '이 시기에는 신중하게.')))}
                      </AppText>
                    </View>
                  );
                })}
              </Card>
            </View>
          )}
        </View>
      ) : null}

      {/* ============================================================ */}
      {/*  Strengths / Risks side-by-side                               */}
      {/* ============================================================ */}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
        <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
          <Card
            style={{
              backgroundColor: '#34C75910',
              borderWidth: 1,
              borderColor: '#34C75925',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <AppText variant="heading4" style={{ color: '#34C759' }}>강점</AppText>
            {(recommendations.length > 0
              ? recommendations
              : [
                  '문제를 구조화해서 말할 때 신뢰가 빠르게 쌓입니다.',
                  '역할 범위를 명확히 잡으면 추진력이 커집니다.',
                ]
            ).map((item, i) => (
              <View key={`str-${i}`} style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ color: '#34C759', fontSize: 12 }}>{'●'}</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                  {item}
                </AppText>
              </View>
            ))}
          </Card>
        </View>
        <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
          <Card
            style={{
              backgroundColor: '#FF3B3010',
              borderWidth: 1,
              borderColor: '#FF3B3025',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <AppText variant="heading4" style={{ color: '#FF3B30' }}>리스크</AppText>
            {(warnings.length > 0
              ? warnings
              : [
                  '잘하는 일을 너무 많이 동시에 맡으면 집중력이 떨어집니다.',
                  '당장 눈에 띄는 제안보다 오래 남는 구조를 먼저 봐야 합니다.',
                ]
            ).map((item, i) => (
              <View key={`risk-${i}`} style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ color: '#FF3B30', fontSize: 12 }}>{'●'}</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                  {item}
                </AppText>
              </View>
            ))}
          </Card>
        </View>
      </View>

      {/* ============================================================ */}
      {/*  6. Industry Insight (InsetQuote with accent)                 */}
      {/* ============================================================ */}
      {hasRaw && rawIndustryInsights ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderLeftWidth: 4,
            borderLeftColor: '#FFCC00',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <AppText style={{ fontSize: 20, lineHeight: 26 }}>💡</AppText>
            <AppText variant="heading4">업계 인사이트</AppText>
          </View>
          <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
            {rawIndustryInsights}
          </AppText>
        </Card>
      ) : null}

      {/* --- Raw API: Networking Advice --- */}
      {hasRaw && rawNetworkingAdvice.length > 0 && (
        <SectionCard title="네트워킹 조언" description="커리어 성장을 위한 관계 전략입니다.">
          <BulletList items={rawNetworkingAdvice.slice(0, 5)} />
        </SectionCard>
      )}

      <SectionCard title="주간 아웃룩">
        <InsetQuote text={highlights[0] ?? '이번 커리어 운은 새로운 시작보다 \'정리된 신뢰\'를 쌓는 쪽에서 크게 열립니다.'} />
      </SectionCard>

      {/* --- Raw API: Career Keywords --- */}
      {hasRaw && rawCareerKeywords.length > 0 ? (
        <SectionCard title="커리어 키워드">
          <KeywordPills keywords={rawCareerKeywords.slice(0, 8)} />
        </SectionCard>
      ) : null}

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={luckyItems.length > 0
          ? luckyItems
          : ['월요일 오전', '정리된 문서', '차분한 블루', '짧은 보고']} />
      </SectionCard>
    </View>
  );
}

/* -------------------------------------------------------------------------- */
/*  LoveResult                                                                */
/* -------------------------------------------------------------------------- */

function LoveResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.love;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  const excitement = result.metrics[0]?.value ?? '89';
  const excitementNote = result.metrics[0]?.note ?? '분위기 형성이 좋음';
  const honesty = result.metrics[1]?.value ?? '73';
  const honestyNote = result.metrics[1]?.note ?? '말을 고르는 편이 안전';
  const timing = result.metrics[2]?.value ?? '85';
  const timingNote = result.metrics[2]?.note ?? '너무 늦지 않게 표현';

  const summary = result.hasApiData
    ? result.summary
    : '연애운은 밝지만, 감정보다 리듬을 맞추는 편이 더 중요합니다. 표현은 부드럽게, 기준은 분명하게 가야 합니다.';

  const highlights = result.hasApiData
    ? result.highlights
    : [
        '짧고 가벼운 제안이 오히려 더 큰 반응을 부릅니다.',
        '상대의 반응을 기다릴 때는 템포를 너무 끌지 않는 편이 좋습니다.',
      ];

  const recommendations = result.hasApiData
    ? result.recommendations
    : [
        '감정 확인을 지나치게 반복하는 것',
        '확답을 급하게 받으려는 태도',
      ];

  const luckyItems = result.hasApiData
    ? result.luckyItems
    : ['로즈 베이지', '조용한 카페', '짧은 안부', '20:30'];

  // --- Raw API: love profile (deep) ---
  const rawLoveProfile = obj(raw.loveProfile);
  const dominantStyle = str(rawLoveProfile.dominantStyle, str(rawLoveProfile.style, str(rawLoveProfile.type)));
  const personalityType = str(rawLoveProfile.personalityType);
  const communicationStyle = str(rawLoveProfile.communicationStyle);
  const conflictResolution = str(rawLoveProfile.conflictResolution);
  const hasLoveProfile = dominantStyle || personalityType || communicationStyle;

  // --- Raw API: detailed analysis (deep) ---
  const rawDetailedAnalysis = obj(raw.detailedAnalysis);
  const rawDetailedAnalysisStr = str(raw.detailedAnalysis); // fallback if it's a string
  const rawLoveStyle = obj(rawDetailedAnalysis.loveStyle);
  const loveStyleStrengths = strArr(rawLoveStyle.strengths);
  const loveStyleTendencies = strArr(rawLoveStyle.tendencies);
  const charmPoints = strArr(rawDetailedAnalysis.charmPoints);
  const improvementAreas = strArr(rawDetailedAnalysis.improvementAreas);
  const compatibilityInsights = str(rawDetailedAnalysis.compatibilityInsights);
  const hasDetailedAnalysis =
    loveStyleStrengths.length > 0 ||
    charmPoints.length > 0 ||
    improvementAreas.length > 0 ||
    rawDetailedAnalysisStr;

  // --- Raw API: predictions (timeline) ---
  const rawPredictions = obj(raw.predictions);
  const predThisWeek = str(rawPredictions.thisWeek);
  const predThisMonth = str(rawPredictions.thisMonth);
  const predNextThreeMonths = str(rawPredictions.nextThreeMonths);
  const hasPredictions = predThisWeek || predThisMonth || predNextThreeMonths;

  // --- Raw API: action plan ---
  const rawActionPlan = obj(raw.actionPlan);
  const actionImmediate = strArr(rawActionPlan.immediate);
  const actionShortTerm = strArr(rawActionPlan.shortTerm);
  const actionLongTerm = strArr(rawActionPlan.longTerm);
  // Fallback: single string values
  const actionImmediateStr = str(rawActionPlan.immediate);
  const actionShortTermStr = str(rawActionPlan.shortTerm);
  const actionLongTermStr = str(rawActionPlan.longTerm);
  const hasActionPlan =
    actionImmediate.length > 0 ||
    actionShortTerm.length > 0 ||
    actionLongTerm.length > 0 ||
    actionImmediateStr ||
    actionShortTermStr ||
    actionLongTermStr;

  // --- Raw API: recommendations (deep) ---
  const rawRecommendations = obj(raw.recommendations);

  // Date spots
  const rawDateSpots = obj(rawRecommendations.dateSpots);
  const dateSpotsSimple = strArr(rawRecommendations.dateSpots); // fallback if array of strings
  const primarySpot = obj(rawDateSpots.primary);
  const primarySpotName = str(primarySpot.name, str(primarySpot.place));
  const primarySpotDetail = str(primarySpot.description, str(primarySpot.reason, str(primarySpot.details)));
  const dateSpotAlternatives = strArr(rawDateSpots.alternatives);
  const hasDateSpots = primarySpotName || dateSpotsSimple.length > 0 || dateSpotAlternatives.length > 0;

  // Fashion
  const rawFashion = obj(rawRecommendations.fashion);
  const fashionSimple = strArr(rawRecommendations.fashion); // fallback if array of strings
  const fashionStyle = str(rawFashion.style);
  const fashionColors = strArr(rawFashion.colors);
  const fashionTopItems = strArr(rawFashion.topItems);
  const hasFashion = fashionStyle || fashionColors.length > 0 || fashionTopItems.length > 0 || fashionSimple.length > 0;

  // Accessories & grooming & fragrance
  const accessories = strArr(rawRecommendations.accessories);
  const grooming = strArr(rawRecommendations.grooming);
  const fragrance = str(rawRecommendations.fragrance);
  const hasPremiumTouch = accessories.length > 0 || grooming.length > 0 || fragrance;

  // Conversation
  const rawConversation = obj(rawRecommendations.conversation);
  const convSimple = strArr(rawRecommendations.conversationTopics ?? rawRecommendations.conversation); // fallback
  const convTopics = strArr(rawConversation.topics);
  const convOpeners = strArr(rawConversation.openers);
  const convAvoid = strArr(rawConversation.avoid);
  const hasConversation = convTopics.length > 0 || convOpeners.length > 0 || convAvoid.length > 0 || convSimple.length > 0;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="💗"
        title={meta.title}
        description={summary}
        chips={result.hasApiData && result.contextTags.length > 0
          ? result.contextTags
          : ['연애 프로필', '매력 포인트', '연애 전략']}
      />

      <SectionCard title="연애 에너지">
        <MetricGrid
          items={[
            { label: '설렘 지수', value: excitement, note: excitementNote },
            { label: '솔직함', value: honesty, note: honestyNote },
            { label: '타이밍 운', value: timing, note: timingNote },
          ]}
        />
      </SectionCard>

      {/* --- 1. 연애 프로필 --- */}
      {hasRaw && hasLoveProfile && (
        <SectionCard title="연애 프로필" description="당신만의 연애 DNA를 분석합니다.">
          <MetricGrid
            items={[
              ...(dominantStyle
                ? [{ label: '연애 스타일', value: dominantStyle, note: undefined as string | undefined }]
                : []),
              ...(personalityType
                ? [{ label: '연애 성격 유형', value: personalityType, note: undefined as string | undefined }]
                : []),
              ...(communicationStyle
                ? [{ label: '소통 방식', value: communicationStyle, note: undefined as string | undefined }]
                : []),
              ...(conflictResolution
                ? [{ label: '갈등 해결법', value: conflictResolution, note: undefined as string | undefined }]
                : []),
            ]}
          />
        </SectionCard>
      )}

      {/* --- 2. 매력 포인트 --- */}
      {hasRaw && charmPoints.length > 0 && (
        <SectionCard title="매력 포인트" description="상대가 끌리는 당신만의 매력입니다.">
          <KeywordPills keywords={charmPoints.slice(0, 6)} />
        </SectionCard>
      )}

      {/* --- Detailed analysis: love style strengths/tendencies --- */}
      {hasRaw && (loveStyleStrengths.length > 0 || loveStyleTendencies.length > 0) && (
        <DoDontPair
          data={{
            doTitle: '연애 강점',
            doItems: loveStyleStrengths.length > 0
              ? loveStyleStrengths
              : highlights,
            dontTitle: '연애 경향/습관',
            dontItems: loveStyleTendencies.length > 0
              ? loveStyleTendencies
              : recommendations,
          }}
        />
      )}

      {/* --- Improvement areas --- */}
      {hasRaw && improvementAreas.length > 0 && (
        <SectionCard title="성장 포인트" description="더 좋은 관계를 위한 발전 포인트입니다.">
          <BulletList items={improvementAreas.slice(0, 5)} accent="성장" />
        </SectionCard>
      )}

      {/* --- Compatibility insights --- */}
      {hasRaw && compatibilityInsights ? (
        <SectionCard title="궁합 인사이트">
          <InsetQuote text={compatibilityInsights} />
        </SectionCard>
      ) : null}

      {/* --- Fallback: string-type detailed analysis --- */}
      {hasRaw && !hasDetailedAnalysis && rawDetailedAnalysisStr ? (
        <SectionCard title="상세 분석">
          <InsetQuote text={rawDetailedAnalysisStr} />
        </SectionCard>
      ) : null}

      {/* --- Fallback DoDontPair when no deep loveStyle data --- */}
      {!(hasRaw && (loveStyleStrengths.length > 0 || loveStyleTendencies.length > 0)) && (
        <DoDontPair
          data={{
            doTitle: '지금 좋은 흐름',
            doItems: highlights.length > 0
              ? highlights
              : [
                  '짧고 가벼운 제안이 오히려 더 큰 반응을 부릅니다.',
                  '상대의 반응을 기다릴 때는 템포를 너무 끌지 않는 편이 좋습니다.',
                ],
            dontTitle: '지금 피할 흐름',
            dontItems: recommendations.length > 0
              ? recommendations
              : [
                  '감정 확인을 지나치게 반복하는 것',
                  '확답을 급하게 받으려는 태도',
                ],
          }}
        />
      )}

      {/* --- 3. 이번 주 / 이번 달 / 3개월 예측 --- */}
      {hasRaw && hasPredictions && (
        <SectionCard title="연애 타임라인" description="단기/중기 연애 흐름 예측입니다.">
          <Timeline
            items={[
              ...(predThisWeek
                ? [{ title: '이번 주', tag: '주간', body: predThisWeek }]
                : []),
              ...(predThisMonth
                ? [{ title: '이번 달', tag: '월간', body: predThisMonth }]
                : []),
              ...(predNextThreeMonths
                ? [{ title: '향후 3개월', tag: '전망', body: predNextThreeMonths }]
                : []),
            ]}
          />
        </SectionCard>
      )}

      {/* --- Action plan --- */}
      {hasRaw && hasActionPlan && (
        <SectionCard title="연애 액션 플랜" description="지금 바로 실행할 수 있는 연애 전략입니다.">
          <Timeline
            items={[
              ...(actionImmediate.length > 0
                ? [{ title: '지금 바로', tag: '즉시', body: actionImmediate.join(' / ') }]
                : actionImmediateStr
                  ? [{ title: '지금 바로', tag: '즉시', body: actionImmediateStr }]
                  : []),
              ...(actionShortTerm.length > 0
                ? [{ title: '이번 달 안에', tag: '단기', body: actionShortTerm.join(' / ') }]
                : actionShortTermStr
                  ? [{ title: '이번 달 안에', tag: '단기', body: actionShortTermStr }]
                  : []),
              ...(actionLongTerm.length > 0
                ? [{ title: '장기 전략', tag: '장기', body: actionLongTerm.join(' / ') }]
                : actionLongTermStr
                  ? [{ title: '장기 전략', tag: '장기', body: actionLongTermStr }]
                  : []),
            ]}
          />
        </SectionCard>
      )}

      {/* --- Fallback: static relationship timeline --- */}
      {!hasPredictions && !hasActionPlan && (
        <SectionCard title="관계 타임라인">
          <Timeline
            items={[
              { title: '초반', tag: '온도', body: '분위기는 빠르게 데워지지만, 속도 조절이 중요합니다.' },
              { title: '중반', tag: '대화', body: '서로의 기준을 말할수록 관계가 안정됩니다.' },
              { title: '후반', tag: '확인', body: '확답보다 일관된 태도가 더 큰 신뢰를 만듭니다.' },
            ]}
          />
        </SectionCard>
      )}

      {/* --- 4. 데이트 장소 추천 --- */}
      {hasRaw && hasDateSpots && (
        <SectionCard title="데이트 장소 추천" description="지금 분위기에 딱 맞는 장소입니다.">
          {primarySpotName ? (
            <MetricGrid
              items={[
                {
                  label: '추천 장소',
                  value: primarySpotName,
                  note: primarySpotDetail || undefined,
                },
              ]}
            />
          ) : null}
          {dateSpotAlternatives.length > 0 ? (
            <KeywordPills keywords={dateSpotAlternatives.slice(0, 5)} />
          ) : dateSpotsSimple.length > 0 ? (
            <KeywordPills keywords={dateSpotsSimple.slice(0, 6)} />
          ) : null}
        </SectionCard>
      )}

      {/* --- 5. 연애 패션 가이드 --- */}
      {hasRaw && hasFashion && (
        <SectionCard title="연애 패션 가이드" description="좋은 인상을 남길 스타일링 포인트입니다.">
          {fashionStyle ? (
            <MetricGrid
              items={[{ label: '추천 스타일', value: fashionStyle, note: undefined as string | undefined }]}
            />
          ) : null}
          {fashionColors.length > 0 && (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <KeywordPills keywords={fashionColors.slice(0, 5)} />
            </View>
          )}
          {fashionTopItems.length > 0 ? (
            <BulletList items={fashionTopItems.slice(0, 5)} accent="아이템" />
          ) : fashionSimple.length > 0 ? (
            <BulletList items={fashionSimple.slice(0, 5)} accent="패션" />
          ) : null}
        </SectionCard>
      )}

      {/* --- 6. 대화 전략 --- */}
      {hasRaw && hasConversation && (
        <SectionCard title="대화 전략" description="자연스럽게 대화를 이끄는 가이드입니다.">
          {convTopics.length > 0 && (
            <BulletList items={convTopics.slice(0, 4)} accent="주제" />
          )}
          {convOpeners.length > 0 && (
            <BulletList items={convOpeners.slice(0, 3)} accent="오프너" />
          )}
          {convAvoid.length > 0 && (
            <BulletList items={convAvoid.slice(0, 3)} accent="피하기" />
          )}
          {convSimple.length > 0 && convTopics.length === 0 && convOpeners.length === 0 && (
            <BulletList items={convSimple.slice(0, 5)} accent="대화" />
          )}
        </SectionCard>
      )}

      {/* --- 7. 향수/그루밍 팁 --- */}
      {hasRaw && hasPremiumTouch && (
        <SectionCard title="그루밍 & 향수" description="디테일이 매력을 완성합니다.">
          {fragrance ? (
            <MetricGrid
              items={[{ label: '추천 향수', value: fragrance, note: undefined as string | undefined }]}
            />
          ) : null}
          {grooming.length > 0 && (
            <BulletList items={grooming.slice(0, 4)} accent="그루밍" />
          )}
          {accessories.length > 0 && (
            <KeywordPills keywords={accessories.slice(0, 5)} />
          )}
        </SectionCard>
      )}

      <SectionCard title="주간 아웃룩">
        <InsetQuote text={highlights[0] ?? '짧고 가벼운 제안이 오히려 더 큰 반응을 부릅니다.'} />
      </SectionCard>

      <SectionCard title="행운 그리드">
        <MetricGrid
          items={
            result.hasApiData && result.metrics.length > 3
              ? result.metrics.slice(3, 7).map((m) => ({
                  label: m.label,
                  value: m.value,
                  note: m.note,
                }))
              : [
                  { label: '행운 시간', value: '20:30', note: '답장이 잘 오는 편' },
                  { label: '행운 장소', value: '조용한 카페', note: '시선 분산 적음' },
                  { label: '행운 컬러', value: '로즈 베이지', note: '부드러운 인상' },
                  { label: '행운 액션', value: '짧은 안부', note: '가볍게 시작' },
                ]
          }
        />
      </SectionCard>
    </View>
  );
}

/* -------------------------------------------------------------------------- */
/*  HealthResult                                                              */
/* -------------------------------------------------------------------------- */

/* ---- Health-specific helpers ---- */

const ELEMENT_CONFIG: Record<string, { label: string; hanja: string; color: string; organs: string }> = {
  wood:  { label: '목', hanja: '木', color: '#4CAF50', organs: '간, 담낭' },
  fire:  { label: '화', hanja: '火', color: '#F44336', organs: '심장, 소장' },
  earth: { label: '토', hanja: '土', color: '#FF9800', organs: '비장, 위' },
  metal: { label: '금', hanja: '金', color: '#C0C0C0', organs: '폐, 대장' },
  water: { label: '수', hanja: '水', color: '#2196F3', organs: '신장, 방광' },
};

const ORGAN_EMOJI: Record<string, string> = {
  '폐': '\uD83E\uDEC1', '심장': '\uD83E\uDEC0', '간': '\uD83E\uDDBB', '위': '\uD83E\uDDB7',
  '신장': '\uD83E\uDEB6', '방광': '\uD83D\uDCA7', '대장': '\uD83E\uDDE0', '소장': '\uD83E\uDDE0',
  '비장': '\uD83E\uDDE0', '담낭': '\uD83E\uDDE0', '눈': '\uD83D\uDC41\uFE0F',
  '피부': '\u2728', '뼈': '\uD83E\uDDB4', '관절': '\uD83E\uDDB4',
};

const ORGAN_TIPS: Record<string, string> = {
  '폐': '건조한 날씨에 호흡기 주의',
  '심장': '과도한 카페인 자제',
  '간': '과음과 야식 자제, 충분한 수면',
  '위': '불규칙한 식사 패턴 주의',
  '신장': '충분한 수분 섭취 필요',
  '방광': '찬 음식 자제, 하복부 보온',
  '대장': '식이섬유 섭취와 규칙적 배변',
  '소장': '과식 주의, 소화가 잘 되는 식사',
  '비장': '과로 피하고 규칙적 운동',
  '담낭': '기름진 음식 자제',
  '눈': '장시간 화면 노출 줄이기',
  '피부': '자외선 차단과 보습 관리',
  '뼈': '칼슘 섭취와 적절한 운동',
  '관절': '무리한 운동 자제, 스트레칭',
};

function getSeasonEmoji(): string {
  const month = new Date().getMonth() + 1;
  if (month >= 3 && month <= 5) return '\uD83C\uDF38';   // 🌸 봄
  if (month >= 6 && month <= 8) return '\u2600\uFE0F';   // ☀️ 여름
  if (month >= 9 && month <= 11) return '\uD83C\uDF42';  // 🍂 가을
  return '\u2744\uFE0F';                                   // ❄️ 겨울
}

function getSeasonLabel(): string {
  const month = new Date().getMonth() + 1;
  if (month >= 3 && month <= 5) return '봄';
  if (month >= 6 && month <= 8) return '여름';
  if (month >= 9 && month <= 11) return '가을';
  return '겨울';
}

function HealthResult(props: FortuneResultComponentProps) {
  const _meta = resultMetadataByKind.health;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  /* --- Metrics extraction (same as before) --- */
  const condition = num(result.metrics[0]?.value ?? raw.condition ?? raw.overall_condition, 78);
  const conditionNote = str(result.metrics[0]?.note, '무난하지만 과로 주의');
  const focus = num(result.metrics[1]?.value ?? raw.focus, 81);
  const focusNote = str(result.metrics[1]?.note, '오전 강세');
  const sleep = num(result.metrics[2]?.value ?? raw.sleep_recovery ?? raw.sleep, 66);
  const sleepNote = str(result.metrics[2]?.note, '저녁 루틴 보강 필요');
  const stress = num(result.metrics[3]?.value ?? raw.stress, 59);
  const stressNote = str(result.metrics[3]?.note, '쌓이기 전에 빼야 함');
  const stamina = num(raw.stamina ?? raw.physical_strength, 78);

  const overallScore = Math.round((condition + focus + sleep + (100 - stress)) / 4);

  const summary = result.hasApiData
    ? result.summary
    : '큰 이상보다 미세한 피로가 누적되기 쉬운 날입니다. 오늘의 건강운은 컨디션 조절과 회복 루틴에 강하게 반응합니다.';

  const recommendations = result.hasApiData
    ? result.recommendations
    : [
        '한 번 길게 쉬기보다 짧은 회복을 여러 번 넣으세요.',
        '수분과 식사 간격을 일정하게 유지하면 오후 피로가 덜합니다.',
      ];

  const warnings = result.hasApiData
    ? result.warnings
    : [
        '점심 이후 카페인 과다',
        '어깨, 목이 뻐근한 상태로 오래 앉아 있는 것',
      ];

  const specialTip = result.hasApiData && result.specialTip
    ? result.specialTip
    : '오늘은 참는다고 버티는 날이 아닙니다. 피로 신호가 느껴지면 일정을 조금 줄이는 편이 결과적으로 더 좋습니다.';

  /* --- Raw API fields --- */
  const rawElementBalance = obj(raw.element_balance);
  const rawWeakOrgans = strArr(raw.weak_organs);
  const rawHealthRecs = obj(raw.recommendations);
  const rawSeasonalAdvice = str(raw.seasonal_advice);
  const rawCautions = strArr(raw.cautions);

  const recDiet = strArr(rawHealthRecs.diet);
  const recExercise = strArr(rawHealthRecs.exercise);
  const recLifestyle = strArr(rawHealthRecs.lifestyle);

  /* --- Derived data --- */
  const scoreColor =
    overallScore >= 90 ? '#34C759'
      : overallScore >= 70 ? '#8FB8FF'
        : overallScore >= 50 ? '#FFCC00'
          : '#FF3B30';

  const scoreGrade =
    overallScore >= 90 ? '매우 좋음'
      : overallScore >= 70 ? '양호'
        : overallScore >= 50 ? '보통'
          : '주의 필요';

  const statBars: { emoji: string; label: string; value: number; note: string; color: string }[] = [
    { emoji: '\uD83E\uDDE0', label: '집중력', value: focus, note: focusNote, color: '#8FB8FF' },
    { emoji: '\uD83D\uDE34', label: '수면회복', value: sleep, note: sleepNote, color: '#A78BFA' },
    { emoji: '\uD83D\uDCAA', label: '체력', value: stamina, note: '신체 활동 에너지', color: '#34C759' },
    { emoji: '\uD83D\uDE30', label: '스트레스', value: stress, note: stressNote, color: '#FF9500' },
  ];

  const elementKeys = ['wood', 'fire', 'earth', 'metal', 'water'] as const;
  const elementBars = elementKeys
    .map((key) => {
      const val = rawElementBalance[key];
      if (val == null) return null;
      const cfg = ELEMENT_CONFIG[key]!;
      return { key, pct: num(val, 50), ...cfg };
    })
    .filter(Boolean) as Array<{ key: string; pct: number; label: string; hanja: string; color: string; organs: string }>;
  const hasElementBalance = elementBars.length > 0;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>

      {/* ====== 1. HERO — Health Checkup header (no chips/contextTags) ====== */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
        }}
      >
        <AppText style={{ fontSize: 48, textAlign: 'center' }}>{'\uD83C\uDFE5'}</AppText>
        <AppText variant="oracleTitle" style={{ textAlign: 'center' }}>
          건강 체크업 리포트
        </AppText>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center' }}
        >
          {summary}
        </AppText>
      </Card>

      {/* ====== 2. OVERALL HEALTH GAUGE ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">종합 컨디션</AppText>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          {/* Circular gauge */}
          <View
            style={{
              width: 140,
              height: 140,
              borderRadius: 70,
              borderWidth: 10,
              borderColor: scoreColor,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: `${scoreColor}15`,
            }}
          >
            <AppText style={{ fontSize: 44, fontWeight: '800', color: scoreColor }}>
              {overallScore}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              / 100
            </AppText>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: scoreColor }} />
            <AppText variant="labelLarge" style={{ color: scoreColor }}>
              {scoreGrade}
            </AppText>
          </View>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary} style={{ textAlign: 'center' }}>
            {conditionNote}
          </AppText>
          {/* Full-width progress bar */}
          <View
            style={{
              width: '100%',
              height: 12,
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.full,
              overflow: 'hidden',
            }}
          >
            <View
              style={{
                width: `${Math.min(overallScore, 100)}%`,
                height: '100%',
                backgroundColor: scoreColor,
                borderRadius: fortuneTheme.radius.full,
              }}
            />
          </View>
        </View>
      </Card>

      {/* ====== 3. BODY CONDITION DASHBOARD — 2x2 stat bars ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">신체 컨디션 대시보드</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {statBars.map((stat) => {
            const barColor = stat.label === '스트레스'
              ? (stat.value >= 70 ? '#FF3B30' : stat.value >= 50 ? '#FF9500' : '#34C759')
              : stat.color;
            return (
              <View
                key={stat.label}
                style={{
                  minWidth: '47%',
                  flexGrow: 1,
                  flexBasis: '47%',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <AppText style={{ fontSize: 18 }}>{stat.emoji}</AppText>
                  <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                    {stat.label}
                  </AppText>
                </View>
                <AppText variant="heading3" style={{ color: barColor }}>
                  {stat.value}%
                </AppText>
                {/* Progress bar */}
                <View
                  style={{
                    height: 8,
                    backgroundColor: fortuneTheme.colors.background,
                    borderRadius: fortuneTheme.radius.full,
                    overflow: 'hidden',
                  }}
                >
                  <View
                    style={{
                      width: `${Math.min(stat.value, 100)}%`,
                      height: '100%',
                      backgroundColor: barColor,
                      borderRadius: fortuneTheme.radius.full,
                    }}
                  />
                </View>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  {stat.note}
                </AppText>
              </View>
            );
          })}
        </View>
      </Card>

      {/* ====== 4. FIVE ELEMENTS BALANCE CHART ====== */}
      {hasRaw && hasElementBalance && (
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText variant="heading4">오행 건강 균형</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              다섯 기운의 균형 상태와 연관 장기입니다
            </AppText>
          </View>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {elementBars.map((el) => (
              <View key={el.key} style={{ gap: fortuneTheme.spacing.xs }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                    <View
                      style={{
                        width: 28,
                        height: 28,
                        borderRadius: 14,
                        backgroundColor: `${el.color}25`,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <AppText variant="caption" style={{ color: el.color, fontWeight: '700' }}>
                        {el.hanja}
                      </AppText>
                    </View>
                    <AppText variant="labelLarge">
                      {el.label}({el.hanja})
                    </AppText>
                  </View>
                  <AppText variant="labelLarge" style={{ color: el.color }}>
                    {el.pct}%
                  </AppText>
                </View>
                {/* Bar */}
                <View
                  style={{
                    height: 10,
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    borderRadius: fortuneTheme.radius.full,
                    overflow: 'hidden',
                  }}
                >
                  <View
                    style={{
                      width: `${Math.min(el.pct, 100)}%`,
                      height: '100%',
                      backgroundColor: el.color,
                      borderRadius: fortuneTheme.radius.full,
                    }}
                  />
                </View>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  {el.organs}
                </AppText>
              </View>
            ))}
          </View>
        </Card>
      )}

      {/* ====== 5. WEAK ORGANS — Warning cards ====== */}
      {hasRaw && rawWeakOrgans.length > 0 && (
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText variant="heading4">주의 장기</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              현재 기운 흐름에서 특히 관리가 필요한 부위
            </AppText>
          </View>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {rawWeakOrgans.slice(0, 6).map((organ) => {
              const emoji = ORGAN_EMOJI[organ] ?? '\u26A0\uFE0F';
              const tip = ORGAN_TIPS[organ] ?? '컨디션에 따라 주의가 필요합니다';
              return (
                <View
                  key={organ}
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: fortuneTheme.spacing.sm,
                    backgroundColor: 'rgba(255, 59, 48, 0.08)',
                    borderRadius: fortuneTheme.radius.md,
                    borderLeftWidth: 3,
                    borderLeftColor: '#FF3B30',
                    padding: fortuneTheme.spacing.md,
                  }}
                >
                  <AppText style={{ fontSize: 24 }}>{emoji}</AppText>
                  <View style={{ flex: 1, gap: 2 }}>
                    <AppText variant="labelLarge">{organ}</AppText>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {tip}
                    </AppText>
                  </View>
                </View>
              );
            })}
          </View>
        </Card>
      )}

      {/* ====== 6. WELLNESS PLAN — 3-column layout ====== */}
      {(recDiet.length > 0 || recExercise.length > 0 || recLifestyle.length > 0) ? (
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <AppText variant="heading4">웰니스 플랜</AppText>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
            {/* Diet column */}
            {recDiet.length > 0 && (
              <View
                style={{
                  minWidth: '30%',
                  flexGrow: 1,
                  flexBasis: '30%',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <AppText style={{ fontSize: 18 }}>{'\uD83E\uDD57'}</AppText>
                  <AppText variant="labelLarge">식단</AppText>
                </View>
                {recDiet.slice(0, 3).map((item, i) => (
                  <View key={`diet-${i}`} style={{ flexDirection: 'row', gap: 6 }}>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>{'·'}</AppText>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                      {item}
                    </AppText>
                  </View>
                ))}
              </View>
            )}
            {/* Exercise column */}
            {recExercise.length > 0 && (
              <View
                style={{
                  minWidth: '30%',
                  flexGrow: 1,
                  flexBasis: '30%',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <AppText style={{ fontSize: 18 }}>{'\uD83C\uDFC3'}</AppText>
                  <AppText variant="labelLarge">운동</AppText>
                </View>
                {recExercise.slice(0, 3).map((item, i) => (
                  <View key={`exercise-${i}`} style={{ flexDirection: 'row', gap: 6 }}>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>{'·'}</AppText>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                      {item}
                    </AppText>
                  </View>
                ))}
              </View>
            )}
            {/* Lifestyle column */}
            {recLifestyle.length > 0 && (
              <View
                style={{
                  minWidth: '30%',
                  flexGrow: 1,
                  flexBasis: '30%',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <AppText style={{ fontSize: 18 }}>{'\uD83C\uDF19'}</AppText>
                  <AppText variant="labelLarge">라이프스타일</AppText>
                </View>
                {recLifestyle.slice(0, 3).map((item, i) => (
                  <View key={`lifestyle-${i}`} style={{ flexDirection: 'row', gap: 6 }}>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>{'·'}</AppText>
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                      {item}
                    </AppText>
                  </View>
                ))}
              </View>
            )}
          </View>
        </Card>
      ) : (
        /* Fallback: simple DoDontPair when no raw API wellness data */
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <AppText variant="heading4">웰니스 플랜</AppText>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {recommendations.slice(0, 4).map((item, i) => (
              <View key={`rec-${i}`} style={{ flexDirection: 'row', gap: 8, alignItems: 'flex-start' }}>
                <AppText style={{ fontSize: 14, color: '#34C759' }}>{'\u2713'}</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                  {item}
                </AppText>
              </View>
            ))}
          </View>
        </Card>
      )}

      {/* ====== 7. SEASONAL ADVICE ====== */}
      {hasRaw && rawSeasonalAdvice ? (
        <Card
          style={{
            gap: fortuneTheme.spacing.md,
            borderLeftWidth: 3,
            borderLeftColor: fortuneTheme.colors.accentSecondary,
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <AppText style={{ fontSize: 24 }}>{getSeasonEmoji()}</AppText>
            <View style={{ gap: 2 }}>
              <AppText variant="heading4">{getSeasonLabel()} 건강 조언</AppText>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                계절 변화에 맞춘 건강 가이드
              </AppText>
            </View>
          </View>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {rawSeasonalAdvice}
          </AppText>
        </Card>
      ) : (
        <Card
          style={{
            gap: fortuneTheme.spacing.md,
            borderLeftWidth: 3,
            borderLeftColor: fortuneTheme.colors.accentSecondary,
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <AppText style={{ fontSize: 24 }}>{getSeasonEmoji()}</AppText>
            <AppText variant="heading4">{getSeasonLabel()} 건강 TIP</AppText>
          </View>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {specialTip}
          </AppText>
        </Card>
      )}

      {/* ====== 8. CAUTIONS — Red-tinted warning cards ====== */}
      {hasRaw && rawCautions.length > 0 && (
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <AppText style={{ fontSize: 18 }}>{'\u26A0\uFE0F'}</AppText>
            <AppText variant="heading4">건강 주의사항</AppText>
          </View>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {rawCautions.slice(0, 6).map((caution, i) => (
              <View
                key={`caution-${i}`}
                style={{
                  backgroundColor: 'rgba(255, 59, 48, 0.06)',
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  flexDirection: 'row',
                  gap: 8,
                  alignItems: 'flex-start',
                }}
              >
                <AppText variant="bodySmall" style={{ color: '#FF3B30' }}>{'\u2022'}</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                  {caution}
                </AppText>
              </View>
            ))}
          </View>
        </Card>
      )}

      {/* Fallback warnings when no raw cautions */}
      {(!hasRaw || rawCautions.length === 0) && warnings.length > 0 && (
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <AppText style={{ fontSize: 18 }}>{'\u26A0\uFE0F'}</AppText>
            <AppText variant="heading4">주의 포인트</AppText>
          </View>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {warnings.slice(0, 4).map((w, i) => (
              <View
                key={`warn-${i}`}
                style={{
                  backgroundColor: 'rgba(255, 59, 48, 0.06)',
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  flexDirection: 'row',
                  gap: 8,
                  alignItems: 'flex-start',
                }}
              >
                <AppText variant="bodySmall" style={{ color: '#FF3B30' }}>{'\u2022'}</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                  {w}
                </AppText>
              </View>
            ))}
          </View>
        </Card>
      )}

      {/* ====== 9. DISCLAIMER ====== */}
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.md,
          padding: fortuneTheme.spacing.md,
          flexDirection: 'row',
          alignItems: 'center',
          gap: 8,
        }}
      >
        <AppText style={{ fontSize: 14 }}>{'\u2139\uFE0F'}</AppText>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ flex: 1 }}>
          오락 목적의 AI 생성 콘텐츠입니다. 의료 진단이 아니며, 건강 문제는 반드시 전문의와 상담하세요.
        </AppText>
      </View>
    </View>
  );
}

/* -------------------------------------------------------------------------- */
/*  CoachingResult                                                            */
/* -------------------------------------------------------------------------- */

function CoachingResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.coaching;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  const rawExecScore = num(raw.executionScore);
  const rawPersistScore = num(raw.persistenceScore);
  const rawRecoveryScore = num(raw.recoveryScore);
  const executionPower = rawExecScore ? String(rawExecScore) : result.metrics[0]?.value ?? '87';
  const executionNote = str(raw.executionDescription) || result.metrics[0]?.note || '시작 버튼이 빠름';
  const persistence = rawPersistScore ? String(rawPersistScore) : result.metrics[1]?.value ?? '72';
  const persistenceNote = str(raw.persistenceDescription) || result.metrics[1]?.note || '중간 이탈을 경계';
  const recovery = rawRecoveryScore ? String(rawRecoveryScore) : result.metrics[2]?.value ?? '84';
  const recoveryNote = str(raw.recoveryDescription) || result.metrics[2]?.note || '한 번 흔들려도 복귀 빠름';

  const summary = result.hasApiData
    ? result.summary
    : '이번 코칭운은 동기부여보다 실행 구조에 반응합니다. 해야 할 일을 작게 쪼갤수록 결과가 빨라집니다.';

  const recommendations = result.hasApiData
    ? result.recommendations
    : [
        '오늘은 의욕보다 순서가 중요합니다.',
        '완벽하게 시작하려 하지 말고 70% 상태로 바로 시작하세요.',
        '작은 체크 표시가 동력을 유지해 줍니다.',
      ];

  // --- Raw API: extra coaching data ---
  const rawDetailedAnalysis = str(raw.detailedAnalysis);
  const rawActionPlanObj = obj(raw.actionPlan);
  const rawActionPlanArr = arr(raw.actionPlan);
  const rawMindsetTips = strArr(raw.mindsetTips);
  const rawDailyRoutineArr = strArr(raw.dailyRoutine);
  const rawDailyRoutineStr = str(raw.dailyRoutine);
  const rawMotivation = str(raw.motivation, str(raw.motivationQuote));
  const rawStrengths = strArr(raw.strengths);
  const rawGrowthAreas = strArr(raw.growthAreas);
  const rawBlockerAdvice = str(raw.blockerAdvice);
  const rawWarning = str(raw.warning);

  // Support both object format { immediate, shortTerm, longTerm } and array format [{ title, description }]
  const actionImmediate = str(rawActionPlanObj.immediate);
  const actionShortTerm = str(rawActionPlanObj.shortTerm);
  const actionLongTerm = str(rawActionPlanObj.longTerm);
  const hasRawActionPlanObj = actionImmediate || actionShortTerm || actionLongTerm;
  const hasRawActionPlanArr = rawActionPlanArr.length > 0;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🎯"
        title={meta.title}
        description={summary}
        chips={result.hasApiData && result.contextTags.length > 0
          ? result.contextTags
          : ['실행 계획', '작은 승리', '오늘의 동력']}
      />

      <SectionCard title="코칭 점수">
        <MetricGrid
          items={[
            { label: '실행력', value: executionPower, note: executionNote },
            { label: '지속력', value: persistence, note: persistenceNote },
            { label: '복구력', value: recovery, note: recoveryNote },
          ]}
        />
      </SectionCard>

      {/* --- Raw API: Strengths & Growth Areas --- */}
      {hasRaw && (rawStrengths.length > 0 || rawGrowthAreas.length > 0) && (
        <DoDontPair
          data={{
            doTitle: '핵심 강점',
            doItems: rawStrengths.length > 0
              ? rawStrengths.slice(0, 4)
              : ['분석과 구조화 능력이 뛰어남'],
            dontTitle: '성장 포인트',
            dontItems: rawGrowthAreas.length > 0
              ? rawGrowthAreas.slice(0, 4)
              : ['완벽주의를 내려놓는 연습이 필요'],
          }}
        />
      )}

      {/* --- Raw API: Detailed Analysis --- */}
      {hasRaw && rawDetailedAnalysis ? (
        <SectionCard title="상세 분석">
          <InsetQuote text={rawDetailedAnalysis} />
        </SectionCard>
      ) : null}

      {/* --- Raw API: Blocker Advice --- */}
      {hasRaw && rawBlockerAdvice ? (
        <SectionCard title="방해 요소 극복 전략">
          <InsetQuote text={rawBlockerAdvice} />
        </SectionCard>
      ) : null}

      {/* Use raw action plan if available, otherwise static 3-step */}
      {hasRaw && hasRawActionPlanArr ? (
        <SectionCard title="오늘의 액션 플랜" description="목표와 시간에 맞춘 실행 단계입니다.">
          <Timeline
            items={rawActionPlanArr.slice(0, 3).map((item, i) => {
              const step = obj(item);
              return {
                title: str(step.title, `${i + 1}단계`),
                tag: `Step ${i + 1}`,
                body: str(step.description, '실행하세요.'),
              };
            })}
          />
        </SectionCard>
      ) : hasRaw && hasRawActionPlanObj ? (
        <SectionCard title="3단계 액션 플랜" description="즉시 / 단기 / 장기 실행 전략입니다.">
          <Timeline
            items={[
              ...(actionImmediate
                ? [{ title: '즉시 실행', tag: '지금', body: actionImmediate }]
                : []),
              ...(actionShortTerm
                ? [{ title: '단기 목표', tag: '1-2주', body: actionShortTerm }]
                : []),
              ...(actionLongTerm
                ? [{ title: '장기 비전', tag: '1개월+', body: actionLongTerm }]
                : []),
            ]}
          />
        </SectionCard>
      ) : (
        <SectionCard title="3단계 액션 플랜">
          <Timeline
            items={[
              { title: '1단계', tag: '정의', body: '오늘 끝낼 목표를 한 문장으로 적습니다.' },
              { title: '2단계', tag: '분해', body: '10분 안에 시작할 수 있을 만큼 작게 쪼갭니다.' },
              { title: '3단계', tag: '확인', body: '마무리 후 바로 다음 행동을 하나 예약합니다.' },
            ]}
          />
        </SectionCard>
      )}

      <SectionCard title="코칭 스탯">
        <MetricGrid
          items={
            result.hasApiData && result.metrics.length > 3
              ? result.metrics.slice(3, 6).map((m) => ({
                  label: m.label,
                  value: m.value,
                  note: m.note,
                }))
              : [
                  { label: '집중도', value: '83', note: '짧은 몰입에 강함' },
                  { label: '우선순위', value: '78', note: '기준만 세우면 빨라짐' },
                  { label: '피드백 수용', value: '90', note: '수정이 성과로 이어짐' },
                ]
          }
        />
      </SectionCard>

      {/* --- Raw API: Mindset Tips --- */}
      {hasRaw && rawMindsetTips.length > 0 && (
        <SectionCard title="마인드셋 팁" description="오늘의 실행을 돕는 사고 전환 포인트입니다.">
          <BulletList items={rawMindsetTips.slice(0, 5)} />
        </SectionCard>
      )}

      {/* --- Raw API: Daily Routine (string or array) --- */}
      {hasRaw && rawDailyRoutineStr ? (
        <SectionCard title="추천 루틴">
          <InsetQuote text={rawDailyRoutineStr} />
        </SectionCard>
      ) : hasRaw && rawDailyRoutineArr.length > 0 ? (
        <SectionCard title="추천 루틴" description="지속적인 성장을 위한 일일 루틴입니다.">
          <BulletList items={rawDailyRoutineArr.slice(0, 5)} />
        </SectionCard>
      ) : null}

      {/* --- Raw API: Warning --- */}
      {hasRaw && rawWarning ? (
        <SectionCard title="오늘의 함정 주의">
          <InsetQuote text={rawWarning} />
        </SectionCard>
      ) : null}

      <SectionCard title="코칭 메모">
        <BulletList
          items={recommendations.length > 0
            ? recommendations
            : [
                '오늘은 의욕보다 순서가 중요합니다.',
                '완벽하게 시작하려 하지 말고 70% 상태로 바로 시작하세요.',
                '작은 체크 표시가 동력을 유지해 줍니다.',
              ]}
        />
      </SectionCard>

      {/* --- Raw API: Motivation Quote --- */}
      {hasRaw && rawMotivation ? (
        <SectionCard title="오늘의 동기 부여">
          <InsetQuote text={rawMotivation} />
        </SectionCard>
      ) : null}
    </View>
  );
}

export const ResultBatchB = {
  CareerResult,
  LoveResult,
  HealthResult,
  CoachingResult,
};

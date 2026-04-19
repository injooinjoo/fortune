import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
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
import HeroCompat from '../heroes/hero-compat';
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
/*  Emotion color palette (used by ExLoverResult + related screens)    */
/* ------------------------------------------------------------------ */

const EMOTION_PALETTE = {
  obsession: '#FF6B9D', // 집착
  avoidance: '#FF6B6B', // 회피
  anxiety: '#8B7BE8',   // 불안
  anger: '#FF3B30',     // 분노
  sadness: '#8FB8FF',   // 슬픔
  longing: '#E0A76B',   // 그리움
} as const;

/* ------------------------------------------------------------------ */
/*  1. ExamResult                                                      */
/* ------------------------------------------------------------------ */

/* ---------- Exam grade badge color helper ---------- */

function gradeColor(grade: string): string {
  const g = grade.toUpperCase().replace(/\s/g, '');
  if (g.startsWith('A+')) return '#FFD700';
  if (g.startsWith('A')) return fortuneTheme.colors.success;
  if (g.startsWith('B+')) return fortuneTheme.colors.accentSecondary;
  if (g.startsWith('B')) return fortuneTheme.colors.accentSecondary;
  if (g.startsWith('C+')) return fortuneTheme.colors.warning;
  if (g.startsWith('C')) return fortuneTheme.colors.warning;
  return fortuneTheme.colors.accentSecondary;
}

function gaugeColor(pct: number): string {
  if (pct >= 80) return fortuneTheme.colors.success;
  if (pct >= 60) return fortuneTheme.colors.accentSecondary;
  if (pct >= 40) return fortuneTheme.colors.warning;
  return fortuneTheme.colors.error;
}

function spiritAnimalEmoji(name: string): string {
  if (name.includes('호랑이') || name.includes('범')) return '🐯';
  if (name.includes('독수리') || name.includes('매')) return '🦅';
  if (name.includes('부엉이') || name.includes('올빼미')) return '🦉';
  if (name.includes('여우')) return '🦊';
  if (name.includes('용')) return '🐉';
  if (name.includes('거북')) return '🐢';
  if (name.includes('토끼')) return '🐰';
  if (name.includes('고양이')) return '🐱';
  return '🐾';
}

function ExamResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.exam;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract exam-specific data from raw API response ---
  const passPossibility = num(raw.pass_possibility ?? raw.passPossibility, 0);
  const passGrade = str(raw.pass_grade ?? raw.passGrade);
  const examStats = obj(raw.exam_stats ?? raw.examStats);
  const answerIntuition = num(examStats.answerIntuition ?? examStats.answer_intuition, 0);
  const mentalDefense = num(examStats.mentalDefense ?? examStats.mental_defense, 0);
  const memoryAcceleration = num(examStats.memoryAcceleration ?? examStats.memory_acceleration, 0);
  const todayStrategy = str(raw.today_strategy ?? raw.todayStrategy);
  const spiritAnimal = str(raw.spirit_animal ?? raw.spiritAnimal);
  const spiritAnimalDirection = str(raw.spirit_animal_direction ?? raw.spiritAnimalDirection);
  const examDate = str(raw.exam_date ?? raw.examDate);

  const displayGrade = passGrade || 'B+';
  const displayPossibility = passPossibility > 0 ? passPossibility : 78;
  const displayIntuition = answerIntuition > 0 ? answerIntuition : 84;
  const displayDefense = mentalDefense > 0 ? mentalDefense : 71;
  const displayMemory = memoryAcceleration > 0 ? memoryAcceleration : 88;

  const summary =
    result.summary ||
    '시험운은 실력보다 리듬 관리에서 점수 차이가 벌어지는 구간입니다. 막판 압축보다 실전 템포를 먼저 맞추는 편이 유리합니다.';

  const strategyText =
    todayStrategy ||
    '초반에는 익숙한 문제로 리듬을 잡고, 중반부터 어려운 문제에 집중하세요. 마지막 10분은 반드시 검토 시간으로 확보하세요.';

  const displayAnimal = spiritAnimal || '집중 부엉이';
  const displayDirection =
    spiritAnimalDirection ||
    '조용한 곳에서 집중력을 끌어올리세요. 시험 직전 5분 명상이 효과적입니다.';

  const highlights =
    result.highlights.length > 0
      ? result.highlights
      : [
          '익숙한 유형부터 빠르게 풀어 감각을 끌어올리세요.',
          '실수 노트를 마지막까지 한 장으로 압축해두세요.',
        ];

  const warnings =
    result.warnings.length > 0
      ? result.warnings
      : [
          '새로운 풀이법을 직전에 억지로 넣는 것',
          '불안해서 쉬는 시간 없이 계속 밀어붙이는 것',
        ];

  // --- D-day calculation ---
  let dDayNumber: number | null = null;
  if (examDate) {
    const target = new Date(examDate);
    const now = new Date();
    const diff = Math.ceil((target.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    if (!Number.isNaN(diff)) dDayNumber = diff;
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Hero: Report card header                                     */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>📝</AppText>
          <View style={{ flex: 1 }}>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              오늘의 성적표
            </AppText>
            <AppText variant="oracleTitle">{meta.title}</AppText>
          </View>
        </View>
        <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
          {summary}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  1. Grade badge + Pass gauge side by side                     */}
      {/* ============================================================ */}
      <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
        {/* Grade badge */}
        <View style={{ flex: 1 }}>
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              alignItems: 'center',
              justifyContent: 'center',
              gap: fortuneTheme.spacing.xs,
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              합격 예측 등급
            </AppText>
            <View
              style={{
                width: 80,
                height: 80,
                borderRadius: fortuneTheme.radius.full,
                borderWidth: 4,
                borderColor: gradeColor(displayGrade),
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: 'rgba(0,0,0,0.2)',
              }}
            >
              <AppText
                variant="displaySmall"
                style={{ color: gradeColor(displayGrade), fontWeight: '800' }}
              >
                {displayGrade}
              </AppText>
            </View>
          </Card>
        </View>

        {/* Pass gauge */}
        <View style={{ flex: 1 }}>
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              alignItems: 'center',
              justifyContent: 'center',
              gap: fortuneTheme.spacing.xs,
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              합격 확률
            </AppText>
            <View
              style={{
                width: 80,
                height: 80,
                borderRadius: fortuneTheme.radius.full,
                borderWidth: 4,
                borderColor: gaugeColor(displayPossibility),
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: 'rgba(0,0,0,0.2)',
              }}
            >
              <AppText
                variant="displaySmall"
                style={{ color: gaugeColor(displayPossibility), fontWeight: '800' }}
              >
                {displayPossibility}%
              </AppText>
            </View>
          </Card>
        </View>
      </View>

      {/* ============================================================ */}
      {/*  2. Exam stats as colored bars with icons                     */}
      {/* ============================================================ */}
      <SectionCard title="시험 스탯 레이더" description="오늘의 시험 관련 에너지 수치입니다.">
        <View style={{ gap: fortuneTheme.spacing.md }}>
          {([
            { icon: '🎯', label: '직감력', value: displayIntuition, color: EMOTION_PALETTE.avoidance, desc: '답이 보이는 감각' },
            { icon: '🛡️', label: '정신방어', value: displayDefense, color: fortuneTheme.colors.accentSecondary, desc: '압박 속 집중 유지력' },
            { icon: '⚡', label: '기억가속', value: displayMemory, color: fortuneTheme.colors.warning, desc: '암기와 떠올림 속도' },
          ] as const).map((stat) => {
            const clamped = Math.max(0, Math.min(100, stat.value));
            return (
              <View key={stat.label} style={{ gap: fortuneTheme.spacing.xs }}>
                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                  }}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                    <AppText style={{ fontSize: 18, lineHeight: 24 }}>{stat.icon}</AppText>
                    <AppText variant="labelLarge">{stat.label}</AppText>
                  </View>
                  <AppText variant="labelLarge" style={{ color: stat.color }}>
                    {clamped}
                  </AppText>
                </View>
                <View
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    borderRadius: fortuneTheme.radius.full,
                    height: 12,
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
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {stat.desc}
                </AppText>
              </View>
            );
          })}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  3. Today's strategy card                                     */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderLeftWidth: 4,
          borderLeftColor: fortuneTheme.colors.ctaBackground,
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText style={{ fontSize: 20, lineHeight: 26 }}>📋</AppText>
          <AppText variant="heading4">오늘의 전략</AppText>
        </View>
        <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
          {strategyText}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  4. Spirit animal                                             */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText style={{ fontSize: 20, lineHeight: 26 }}>🐾</AppText>
          <AppText variant="heading4">수호 동물</AppText>
        </View>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.md, alignItems: 'center' }}>
          <View
            style={{
              width: 64,
              height: 64,
              borderRadius: fortuneTheme.radius.full,
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <AppText style={{ fontSize: 36, lineHeight: 44 }}>
              {spiritAnimalEmoji(displayAnimal)}
            </AppText>
          </View>
          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <AppText variant="heading3">{displayAnimal}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {displayDirection}
            </AppText>
          </View>
        </View>
      </Card>

      {/* ============================================================ */}
      {/*  5. Do / Don't pair                                           */}
      {/* ============================================================ */}
      <DoDontPair
        data={{
          doTitle: '잘 맞는 전략',
          doItems: highlights,
          dontTitle: '피할 전략',
          dontItems: warnings,
        }}
      />

      {/* ============================================================ */}
      {/*  6. D-day timeline (only if examDate provided)                */}
      {/* ============================================================ */}
      {dDayNumber !== null && (
        <SectionCard title="D-day 타임라인">
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              alignItems: 'center',
              gap: fortuneTheme.spacing.sm,
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              시험까지
            </AppText>
            <AppText
              variant="displayMedium"
              style={{
                color:
                  dDayNumber <= 0
                    ? fortuneTheme.colors.error
                    : dDayNumber <= 3
                      ? fortuneTheme.colors.warning
                      : fortuneTheme.colors.accentSecondary,
              }}
            >
              {dDayNumber <= 0 ? 'D-Day' : `D-${dDayNumber}`}
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
              {examDate}
            </AppText>
          </Card>
          <Timeline
            items={
              dDayNumber > 7
                ? [
                    { title: 'D-7', tag: '정리', body: '점수 올리는 문제보다 틀리지 않을 문제를 먼저 고정합니다.' },
                    { title: 'D-1', tag: '회복', body: '새 범위 추가보다 루틴 유지와 컨디션 안정이 더 중요합니다.' },
                    { title: '시험 당일', tag: '실전', body: '초반 10분에 리듬을 잡고, 모르는 문제는 빠르게 넘기세요.' },
                  ]
                : dDayNumber > 1
                  ? [
                      { title: 'D-1', tag: '회복', body: '새 범위 추가보다 루틴 유지와 컨디션 안정이 더 중요합니다.' },
                      { title: '시험 당일', tag: '실전', body: '초반 10분에 리듬을 잡고, 모르는 문제는 빠르게 넘기세요.' },
                    ]
                  : [
                      { title: '시험 당일', tag: '실전', body: '초반 10분에 리듬을 잡고, 모르는 문제는 빠르게 넘기세요.' },
                    ]
            }
          />
        </SectionCard>
      )}

      {result.hasApiData && result.specialTip && (
        <SectionCard title="시험 팁">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}

      {result.hasApiData && result.recommendations.length > 0 && (
        <SectionCard title="추천 행동">
          <BulletList items={result.recommendations} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  2. CompatibilityResult                                             */
/* ------------------------------------------------------------------ */

function CompatibilityResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="compatibility" data={payload} progress={1}>
      <HeroCompat data={payload} progress={1} />
    </ResultCardFrame>
  );
}


/* ------------------------------------------------------------------ */
/*  3. BlindDateResult                                                 */
/* ------------------------------------------------------------------ */

function BlindDateResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['blind-date'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract blind-date specific data from raw API response ---
  const firstImpression = obj(raw.firstImpression ?? raw.first_impression);
  const conversationStrategy = obj(raw.conversationStrategy ?? raw.conversation_strategy);
  const outfitRec = obj(raw.outfitRecommendation ?? raw.outfit_recommendation ?? raw.outfit);
  const compatibilityData = obj(raw.compatibility ?? raw.compatibilityScore ?? raw.compatibility_score);
  const redFlagsData = obj(raw.redFlags ?? raw.red_flags);
  const afterDatePlan = obj(raw.afterDatePlan ?? raw.after_date_plan ?? raw.afterDate);
  const compatScore = num(
    compatibilityData.score ?? raw.compatibilityScore ?? raw.compatibility_score,
  );

  const hasConversation =
    strArr(conversationStrategy.topics ?? conversationStrategy.openers).length > 0 ||
    str(conversationStrategy.summary) !== '';
  const hasOutfit =
    str(outfitRec.summary ?? outfitRec.recommendation) !== '' ||
    strArr(outfitRec.items ?? outfitRec.tips).length > 0;
  const hasRedFlags =
    strArr(redFlagsData.items ?? redFlagsData.signals ?? raw.redFlags ?? raw.red_flags).length > 0;
  const hasAfterDate =
    strArr(afterDatePlan.steps ?? afterDatePlan.tips ?? afterDatePlan.items).length > 0 ||
    str(afterDatePlan.summary) !== '';

  const summary =
    result.summary ||
    str(raw.summary) ||
    '소개팅운은 첫 20분의 분위기가 전체 인상을 거의 결정합니다. 무리한 매력 어필보다 편안한 리듬을 만드는 편이 훨씬 유리합니다.';

  // Score for the big gauge (use API score or fallback from highlights)
  const mainScore = compatScore > 0 ? compatScore : num(result.highlights[0], 82);

  // Score color + label
  const scoreColor =
    mainScore >= 90
      ? fortuneTheme.colors.success
      : mainScore >= 70
        ? fortuneTheme.colors.ctaBackground
        : mainScore >= 50
          ? fortuneTheme.colors.warning
          : fortuneTheme.colors.error;
  const scoreLabel =
    mainScore >= 90
      ? '완벽한 조건!'
      : mainScore >= 70
        ? '좋은 흐름'
        : mainScore >= 50
          ? '노력 필요'
          : '신중하게';

  // Conversation strategy from API
  const convoTopics = strArr(conversationStrategy.topics);
  const convoOpeners = strArr(conversationStrategy.openers);
  const convoAvoid = strArr(conversationStrategy.avoid ?? conversationStrategy.avoidTopics);

  // Outfit recommendations — map to body-part rows
  const outfitItems = strArr(outfitRec.items ?? outfitRec.tips);
  const outfitSummary = str(outfitRec.summary ?? outfitRec.recommendation);
  const outfitSlots: { emoji: string; label: string; rec: string }[] = [];
  const slotMap: [string, string][] = [
    ['\uD83D\uDC55', '\uC0C1\uC758'],   // 👕 상의
    ['\uD83D\uDC56', '\uD558\uC758'],   // 👖 하의
    ['\uD83D\uDC5F', '\uC2E0\uBC1C'],   // 👟 신발
    ['\uD83E\uDDE5', '\uC544\uC6B0\uD130'], // 🧥 아우터
    ['\uD83D\uDC8D', '\uC561\uC138\uC11C\uB9AC'], // 💍 액세서리
    ['\uD83D\uDC87', '\uD5E4\uC5B4'],   // 💇 헤어
    ['\uD83E\uDDF4', '\uD5A5\uC218'],   // 🧴 향수
  ];
  // If API gave items, map them to slots
  if (outfitItems.length > 0) {
    outfitItems.forEach((item, i) => {
      const [emoji, label] = slotMap[i] ?? ['\u2728', '\uAE30\uD0C0']; // ✨ 기타
      outfitSlots.push({ emoji, label, rec: item });
    });
  } else if (outfitSummary) {
    // Parse summary text — just show it as first slot
    outfitSlots.push({ emoji: '\uD83D\uDC55', label: '\uCF54\uB514', rec: outfitSummary }); // 👕 코디
  }

  // Red flags from API
  const redFlagItems = strArr(
    redFlagsData.items ?? redFlagsData.signals ?? raw.redFlags ?? raw.red_flags,
  );

  // After-date action plan from API
  const afterDateItems = strArr(afterDatePlan.steps ?? afterDatePlan.tips ?? afterDatePlan.items);

  // First impression meter scores
  const likability = num(firstImpression.likability ?? firstImpression.호감도, 85);
  const trust = num(firstImpression.trust ?? firstImpression.신뢰감, 78);
  const charm = num(firstImpression.charm ?? firstImpression.매력도, 82);

  // After-date timeline defaults
  const afterTimeline = [
    {
      emoji: '\uD83D\uDCAC',
      time: '\uB2F9\uC77C',
      action: afterDateItems[0] ?? '\uAC10\uC0AC \uC778\uC0AC \uBA54\uC2DC\uC9C0 \uBCF4\uB0B4\uAE30',
    }, // 💬 당일 감사 인사 메시지 보내기
    {
      emoji: '\u2600\uFE0F',
      time: '\uB2E4\uC74C\uB0A0',
      action: afterDateItems[1] ?? '\uAC00\uBCBC\uC6B4 \uC548\uBD80 \uBB38\uC790',
    }, // ☀️ 다음날 가벼운 안부 문자
    {
      emoji: '\uD83D\uDCC5',
      time: '3\uC77C \uD6C4',
      action: afterDateItems[2] ?? '\uB2E4\uC74C \uB9CC\uB0A8 \uC81C\uC548',
    }, // 📅 3일 후 다음 만남 제안
  ];

  // Fun tip cards
  const tipCards = [
    {
      emoji: '\uD83D\uDEB6',
      tip: '\uB9CC\uB098\uAE30 30\uBD84 \uC804 \uAC00\uBCBC\uC6B4 \uC0B0\uCC45\uC73C\uB85C \uAE34\uC7A5\uC744 \uD480\uC5B4\uB450\uC138\uC694.',
    }, // 🚶 만나기 30분 전 가벼운 산책으로 긴장을 풀어두세요.
    {
      emoji: '\uD83D\uDE4B',
      tip: '\uCCAB \uC9C8\uBB38\uC740 "\uC624\uB298 \uC5B4\uB5BB\uAC8C \uC624\uC168\uC5B4\uC694?" \uAC19\uC740 \uAC00\uBCBC\uC6B4 \uAC83\uC73C\uB85C.',
    }, // 🙋 첫 질문은 "오늘 어떻게 오셨어요?" 같은 가벼운 것으로.
    {
      emoji: '\uD83E\uDD1D',
      tip: '\uACF5\uD1B5\uC810 \uBC1C\uACAC \uC2DC \uBC14\uB85C \uAE4A\uAC8C \uD30C\uACE0\uB4DC\uC138\uC694 - \uAC00\uC7A5 \uC790\uC5F0\uC2A4\uB7EC\uC6B4 \uD750\uB984!',
    }, // 🤝 공통점 발견 시 바로 깊게 파고드세요 - 가장 자연스러운 흐름!
    {
      emoji: '\uD83D\uDE0A',
      tip: '\uC0C1\uB300\uC758 \uB9D0\uC744 \uBC18\uBCF5\uD574\uC8FC\uB294 "\uBBF8\uB7EC\uB9C1"\uC774 \uD638\uAC10\uB3C4\uB97C \uB192\uC785\uB2C8\uB2E4.',
    }, // 😊 상대의 말을 반복해주는 "미러링"이 호감도를 높입니다.
    {
      emoji: '\uD83D\uDCE9',
      tip: '\uD5E4\uC5B4\uC9C4 \uD6C4 2\uC2DC\uAC04 \uC548\uC5D0 \uC9E7\uC740 \uAC10\uC0AC \uBA54\uC2DC\uC9C0\uB97C \uBCF4\uB0B4\uC138\uC694.',
    }, // 📩 헤어진 후 2시간 안에 짧은 감사 메시지를 보내세요.
  ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ---- 1. HERO: big emoji + score circle + summary ---- */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
        }}
      >
        <AppText style={{ fontSize: 48, textAlign: 'center' }}>{'\uD83D\uDC98'}</AppText>
        <AppText variant="oracleTitle" style={{ textAlign: 'center' }}>
          {meta.title}
        </AppText>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center' }}
        >
          {summary}
        </AppText>
      </Card>

      {/* ---- 2. SUCCESS GAUGE ---- */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uC131\uACF5 \uD655\uB960'}</AppText>
        {/* Circular-style score display */}
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
              backgroundColor: withAlpha(scoreColor, 0.08),
            }}
          >
            <AppText style={{ fontSize: 36, fontWeight: '800', color: scoreColor }}>
              {mainScore}
            </AppText>
          </View>
          <AppText variant="labelLarge" style={{ color: scoreColor }}>
            {scoreLabel}
          </AppText>
          {/* Progress bar */}
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
                width: `${Math.min(mainScore, 100)}%`,
                height: '100%',
                backgroundColor: scoreColor,
                borderRadius: fortuneTheme.radius.full,
              }}
            />
          </View>
        </View>
      </Card>

      {/* ---- 3. DRESS CODE GUIDE ---- */}
      {(outfitSlots.length > 0 || hasOutfit) && (
        <Card style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">
            {'\uD83D\uDC57 \uB4DC\uB808\uC2A4\uCF54\uB4DC \uAC00\uC774\uB4DC'}
          </AppText>
          {outfitSlots.length > 0 ? (
            outfitSlots.map((slot, i) => (
              <View
                key={`outfit-${i}`}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.sm,
                  backgroundColor: [
                    withAlpha(fortuneTheme.colors.ctaBackground, 0.12),
                    withAlpha(fortuneTheme.colors.success, 0.12),
                    withAlpha(fortuneTheme.colors.warning, 0.12),
                    withAlpha(fortuneTheme.colors.accentSecondary, 0.12),
                    withAlpha(fortuneTheme.colors.accentTertiary, 0.12),
                    withAlpha(fortuneTheme.colors.error, 0.12),
                    withAlpha(fortuneTheme.colors.ctaBackground, 0.12),
                  ][i % 7],
                  borderRadius: fortuneTheme.radius.md,
                  paddingVertical: fortuneTheme.spacing.sm,
                  paddingHorizontal: fortuneTheme.spacing.md,
                }}
              >
                <AppText style={{ fontSize: 22 }}>{slot.emoji}</AppText>
                <AppText variant="labelLarge" style={{ width: 64 }}>
                  {slot.label}
                </AppText>
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                  style={{ flex: 1 }}
                >
                  {slot.rec}
                </AppText>
              </View>
            ))
          ) : (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {outfitSummary || '\uCF54\uB514 \uCD94\uCC9C \uC815\uBCF4\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4.'}
            </AppText>
          )}
        </Card>
      )}

      {/* ---- 4. CONVERSATION STRATEGY CARDS ---- */}
      {hasConversation && (
        <Card style={{ gap: fortuneTheme.spacing.md }}>
          <AppText variant="heading4">
            {'\uD83D\uDCAC \uB300\uD654 \uC804\uB7B5'}
          </AppText>

          {/* Opening lines */}
          {convoOpeners.length > 0 && (
            <View
              style={{
                backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.08),
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.md,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="labelLarge">
                {'\uD83C\uDFAF \uC624\uD504\uB2DD \uBA58\uD2B8'}
              </AppText>
              {convoOpeners.map((opener, i) => (
                <AppText
                  key={`opener-${i}`}
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {`"${opener}"`}
                </AppText>
              ))}
            </View>
          )}

          {/* Recommended topics as pills */}
          {convoTopics.length > 0 && (
            <View
              style={{
                backgroundColor: withAlpha(fortuneTheme.colors.success, 0.08),
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.md,
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="labelLarge">
                {'\uD83D\uDCAC \uCD94\uCC9C \uB300\uD654 \uC8FC\uC81C'}
              </AppText>
              <KeywordPills keywords={convoTopics} />
            </View>
          )}

          {/* Topics to avoid */}
          {convoAvoid.length > 0 && (
            <View
              style={{
                backgroundColor: withAlpha(fortuneTheme.colors.error, 0.08),
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.md,
                gap: fortuneTheme.spacing.xs,
                borderLeftWidth: 3,
                borderLeftColor: fortuneTheme.colors.error,
              }}
            >
              <AppText variant="labelLarge" style={{ color: fortuneTheme.colors.error }}>
                {'\uD83D\uDEAB \uD53C\uD574\uC57C \uD560 \uC8FC\uC81C'}
              </AppText>
              {convoAvoid.map((topic, i) => (
                <AppText
                  key={`avoid-${i}`}
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {`\u2022 ${topic}`}
                </AppText>
              ))}
            </View>
          )}
        </Card>
      )}

      {/* ---- 5. FIRST IMPRESSION METER ---- */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">
          {'\u2728 \uCCAB\uC778\uC0C1 \uBBF8\uD130'}
        </AppText>
        {[
          {
            emoji: '\uD83D\uDE0A',
            label: '\uD638\uAC10\uB3C4',
            value: likability,
            color: fortuneTheme.colors.success,
          },
          {
            emoji: '\uD83E\uDD1D',
            label: '\uC2E0\uB8B0\uAC10',
            value: trust,
            color: fortuneTheme.colors.ctaBackground,
          },
          {
            emoji: '\u2728',
            label: '\uB9E4\uB825\uB3C4',
            value: charm,
            color: fortuneTheme.colors.warning,
          },
        ].map((meter) => (
          <View key={meter.label} style={{ gap: fortuneTheme.spacing.xs }}>
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center',
              }}
            >
              <AppText variant="labelLarge">
                {`${meter.emoji} ${meter.label}`}
              </AppText>
              <AppText variant="labelLarge" style={{ color: meter.color }}>
                {meter.value}
              </AppText>
            </View>
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
                  width: `${Math.min(meter.value, 100)}%`,
                  height: '100%',
                  backgroundColor: meter.color,
                  borderRadius: fortuneTheme.radius.full,
                }}
              />
            </View>
          </View>
        ))}
      </Card>

      {/* ---- 6. RED FLAG CHECKLIST ---- */}
      {hasRedFlags && (
        <Card
          style={{
            backgroundColor: withAlpha(fortuneTheme.colors.error, 0.06),
            borderColor: withAlpha(fortuneTheme.colors.error, 0.18),
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="heading4" style={{ color: fortuneTheme.colors.error }}>
            {'\u26A0\uFE0F \uC704\uD5D8 \uC2E0\uD638 \uCCB4\uD06C\uB9AC\uC2A4\uD2B8'}
          </AppText>
          {redFlagItems.map((flag, i) => (
            <View
              key={`flag-${i}`}
              style={{
                flexDirection: 'row',
                alignItems: 'flex-start',
                gap: fortuneTheme.spacing.sm,
                backgroundColor: withAlpha(fortuneTheme.colors.error, 0.08),
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.sm,
              }}
            >
              <AppText style={{ fontSize: 16 }}>{'\u26A0\uFE0F'}</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ flex: 1 }}
              >
                {flag}
              </AppText>
            </View>
          ))}
        </Card>
      )}

      {/* ---- 7. POST-DATE ACTION PLAN TIMELINE ---- */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">
          {'\uD83D\uDCC6 \uB9CC\uB0A8 \uD6C4 \uC561\uC158 \uD50C\uB79C'}
        </AppText>
        {afterTimeline.map((step, i) => (
          <View
            key={`after-${i}`}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            {/* Timeline dot */}
            <View style={{ alignItems: 'center', width: 36 }}>
              <AppText style={{ fontSize: 22 }}>{step.emoji}</AppText>
            </View>
            <View
              style={{
                flex: 1,
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.sm,
                gap: 2,
              }}
            >
              <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                {step.time}
              </AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {step.action}
              </AppText>
            </View>
          </View>
        ))}
      </Card>

      {/* ---- 8. FUN TIP CARDS ---- */}
      <Card style={{ gap: fortuneTheme.spacing.sm }}>
        <AppText variant="heading4">
          {'\uD83D\uDCA1 \uC18C\uAC1C\uD305 \uAFB8\uD301'}
        </AppText>
        {tipCards.map((card, i) => (
          <View
            key={`tip-${i}`}
            style={{
              flexDirection: 'row',
              alignItems: 'flex-start',
              gap: fortuneTheme.spacing.sm,
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.md,
              padding: fortuneTheme.spacing.sm,
            }}
          >
            <AppText style={{ fontSize: 20 }}>{card.emoji}</AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ flex: 1 }}
            >
              {card.tip}
            </AppText>
          </View>
        ))}
      </Card>

      {result.hasApiData && result.luckyItems.length > 0 && (
        <SectionCard title={'\uD83C\uDF40 \uD589\uC6B4 \uD3EC\uC778\uD2B8'}>
          <KeywordPills keywords={result.luckyItems} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  4. AvoidPeopleResult                                               */
/* ------------------------------------------------------------------ */

function AvoidPeopleResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['avoid-people'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract avoid-people specific data from raw API response ---
  const warningSignals = arr(raw.warning_signals ?? raw.warningSignals);
  const energyAnalysis = obj(raw.energy_analysis ?? raw.energyAnalysis);
  const energySummary = str(energyAnalysis.summary ?? energyAnalysis.description);
  const energyLevel = num(energyAnalysis.level ?? energyAnalysis.score, 0);
  const energyDrains = strArr(energyAnalysis.drains ?? energyAnalysis.drain_sources);
  const protectionMethods = strArr(raw.protection_methods ?? raw.protectionMethods);
  const avoidanceStrategy = obj(raw.avoidance_strategy ?? raw.avoidanceStrategy);
  const strategyTitle = str(avoidanceStrategy.title ?? avoidanceStrategy.name);
  const strategyDesc = str(avoidanceStrategy.description ?? avoidanceStrategy.detail);
  const strategySteps = strArr(avoidanceStrategy.steps ?? avoidanceStrategy.actions);
  const timingAdvice = obj(raw.timing_advice ?? raw.timingAdvice);
  const peakRiskTime = str(timingAdvice.peak_risk ?? timingAdvice.peakRisk);
  const safeTime = str(timingAdvice.safe_time ?? timingAdvice.safeTime);
  const timingNote = str(timingAdvice.note ?? timingAdvice.description);

  const hasWarningSignals = warningSignals.length > 0;
  const hasEnergyData = energySummary || energyLevel > 0 || energyDrains.length > 0;
  const hasProtection = protectionMethods.length > 0;
  const hasStrategy = strategyTitle || strategyDesc || strategySteps.length > 0;
  const hasTimingAdvice = peakRiskTime || safeTime || timingNote;

  const summary =
    result.summary ||
    '오늘은 관계를 넓히는 것보다 에너지를 새게 만드는 유형을 빠르게 구분하는 편이 좋습니다. 피해야 할 사람보다 피해야 할 패턴을 읽는 게 중요합니다.';

  const highlights =
    result.highlights.length > 0
      ? result.highlights
      : [
          '지나치게 급한 친밀감을 요구하는 사람',
          '내 기준보다 자신의 속도만 밀어붙이는 사람',
          '말보다 피로감이 먼저 느껴지는 관계',
        ];

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '감정 설명보다 일정과 기준을 먼저 말해 거리를 조절하세요.',
          '애매한 부탁은 바로 답하지 말고 시간을 두고 정리하세요.',
          '오늘은 "좋은 사람"보다 "편한 사람"을 기준으로 보세요.',
        ];

  /* ---- Shield gauge score ---- */
  const shieldScore = energyLevel > 0 ? energyLevel : 72;

  /* ---- Severity helpers ---- */
  function severityEmoji(sev: number): string {
    if (sev >= 80) return '\uD83D\uDD34';
    if (sev >= 50) return '\uD83D\uDFE1';
    return '\uD83D\uDFE2';
  }
  function severityBorderColor(sev: number): string {
    if (sev >= 80) return fortuneTheme.colors.error;
    if (sev >= 50) return fortuneTheme.colors.warning;
    return fortuneTheme.colors.success;
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  1. 방어력 게이지 — Shield-themed circular score               */}
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
            borderColor: fortuneTheme.colors.accentSecondary,
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'rgba(143,184,255,0.10)',
          }}
        >
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>{'\uD83D\uDEE1\uFE0F'}</AppText>
          <AppText
            variant="heading2"
            style={{ color: fortuneTheme.colors.accentSecondary }}
          >
            {shieldScore}
          </AppText>
        </View>
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          방어력 지수
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
      {/*  2. 경고 신호 카드 — Severity indicator + colored left border  */}
      {/* ============================================================ */}
      <SectionCard title="경고 신호" description="오늘 특히 주의해야 할 사람/행동 패턴입니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {(hasWarningSignals
            ? warningSignals.map((sig, index) => {
                const s = obj(sig);
                return {
                  name: str(s.name ?? s.label ?? s.signal ?? s.type, `신호 ${index + 1}`),
                  desc: str(s.description ?? s.detail ?? s.meaning),
                  severity: num(s.severity ?? s.level ?? s.risk, 50),
                  category: str(s.category ?? s.type),
                };
              })
            : highlights.map((h, i) => ({
                name: `경계 패턴 ${i + 1}`,
                desc: h,
                severity: [80, 60, 40][i] ?? 50,
                category: '',
              }))
          ).map((sig, index) => (
            <Card
              key={`warn-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderLeftWidth: 4,
                borderLeftColor: severityBorderColor(sig.severity),
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                  <AppText style={{ fontSize: 16, lineHeight: 20 }}>
                    {severityEmoji(sig.severity)}
                  </AppText>
                  <AppText variant="heading4">{sig.name}</AppText>
                </View>
                {sig.category ? (
                  <View
                    style={{
                      backgroundColor: withAlpha(severityBorderColor(sig.severity), 0.12),
                      paddingHorizontal: fortuneTheme.spacing.sm,
                      paddingVertical: 2,
                      borderRadius: fortuneTheme.radius.full,
                    }}
                  >
                    <AppText variant="labelMedium" color={severityBorderColor(sig.severity)}>
                      {sig.category}
                    </AppText>
                  </View>
                ) : null}
              </View>
              {sig.desc ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {sig.desc}
                </AppText>
              ) : null}
            </Card>
          ))}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  3. 에너지 분석 — Defense level bar + drain sources            */}
      {/* ============================================================ */}
      <SectionCard title="에너지 분석" description="오늘의 관계 에너지 상태입니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {/* Defense level bar */}
          <Card
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ fontSize: 18, lineHeight: 22 }}>{'\uD83D\uDD0B'}</AppText>
                <AppText variant="heading4">에너지 방어력</AppText>
              </View>
              <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                {shieldScore}%
              </AppText>
            </View>
            <View
              style={{
                backgroundColor: fortuneTheme.colors.background,
                borderRadius: fortuneTheme.radius.full,
                height: 12,
                overflow: 'hidden',
              }}
            >
              <View
                style={{
                  backgroundColor: shieldScore >= 70 ? fortuneTheme.colors.success : shieldScore >= 40 ? fortuneTheme.colors.warning : fortuneTheme.colors.error,
                  borderRadius: fortuneTheme.radius.full,
                  height: '100%',
                  width: `${Math.min(100, shieldScore)}%`,
                }}
              />
            </View>
            {energySummary ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {energySummary}
              </AppText>
            ) : null}
          </Card>
          {/* Drain sources */}
          {energyDrains.length > 0 && (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textTertiary}>
                에너지 소모 요인
              </AppText>
              {energyDrains.map((drain, i) => (
                <View
                  key={`drain-${i}`}
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: fortuneTheme.spacing.xs,
                    paddingVertical: fortuneTheme.spacing.xs,
                  }}
                >
                  <AppText style={{ fontSize: 14, lineHeight: 18 }}>{'\u26A1'}</AppText>
                  <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                    {drain}
                  </AppText>
                </View>
              ))}
            </View>
          )}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  4. 위험 시간대 — Red/green time slots                        */}
      {/* ============================================================ */}
      <SectionCard title="위험 시간대">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {/* Peak risk time */}
          <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
            <Card
              style={{
                backgroundColor: 'rgba(255,59,48,0.08)',
                borderWidth: 1,
                borderColor: fortuneTheme.colors.error,
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                paddingVertical: fortuneTheme.spacing.md,
              }}
            >
              <AppText style={{ fontSize: 22, lineHeight: 28 }}>{'\uD83D\uDD34'}</AppText>
              <AppText variant="heading3" color={EMOTION_PALETTE.avoidance}>
                {peakRiskTime || '오후 4시'}
              </AppText>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                위험 시간대
              </AppText>
            </Card>
          </View>
          {/* Safe time */}
          <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
            <Card
              style={{
                backgroundColor: 'rgba(52,199,89,0.08)',
                borderWidth: 1,
                borderColor: fortuneTheme.colors.success,
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                paddingVertical: fortuneTheme.spacing.md,
              }}
            >
              <AppText style={{ fontSize: 22, lineHeight: 28 }}>{'\uD83D\uDFE2'}</AppText>
              <AppText variant="heading3" color={fortuneTheme.colors.success}>
                {safeTime || '오전 10시'}
              </AppText>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                안전 시간대
              </AppText>
            </Card>
          </View>
        </View>
        {timingNote ? (
          <View style={{ marginTop: fortuneTheme.spacing.sm }}>
            <InsetQuote text={timingNote} />
          </View>
        ) : null}
      </SectionCard>

      {/* ============================================================ */}
      {/*  5. 보호 전략 — Shield-themed strategy cards                   */}
      {/* ============================================================ */}
      <SectionCard title="보호 전략" description="에너지를 지키기 위한 방어 전략입니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {(hasProtection
            ? protectionMethods
            : hasStrategy && strategySteps.length > 0
              ? strategySteps
              : recommendations
          ).slice(0, 5).map((strategy, index) => (
            <Card
              key={`protect-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderLeftWidth: 4,
                borderLeftColor: fortuneTheme.colors.accentSecondary,
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ fontSize: 16, lineHeight: 20 }}>{'\uD83D\uDEE1\uFE0F'}</AppText>
                <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                  방어 {index + 1}
                </AppText>
              </View>
              <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
                {strategy}
              </AppText>
            </Card>
          ))}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  Avoidance strategy timeline (if provided via raw API)         */}
      {/* ============================================================ */}
      {hasStrategy && strategySteps.length > 0 && hasProtection && (
        <SectionCard
          title={strategyTitle || '회피 전략'}
          description={strategyDesc || undefined}
        >
          <Timeline
            items={strategySteps.map((step, i) => ({
              title: `단계 ${i + 1}`,
              tag: i === 0 ? '시작' : i === strategySteps.length - 1 ? '완료' : '진행',
              body: step,
            }))}
          />
        </SectionCard>
      )}

      {result.hasApiData && result.specialTip && (
        <SectionCard title="오늘의 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  5. ExLoverResult                                                   */
/* ------------------------------------------------------------------ */

function ExLoverResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['ex-lover'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract ex-lover specific data from raw API response ---
  const emotionalPatterns = arr(raw.emotional_patterns ?? raw.emotionalPatterns);
  const screenshotAnalysis = obj(raw.screenshot_analysis ?? raw.screenshotAnalysis);
  const screenshotSummary = str(screenshotAnalysis.summary ?? screenshotAnalysis.description);
  const screenshotInsights = strArr(screenshotAnalysis.insights ?? screenshotAnalysis.patterns);
  const communicationStyle = obj(raw.communication_style ?? raw.communicationStyle);
  const commStyleDesc = str(communicationStyle.description ?? communicationStyle.summary);
  const commPatterns = strArr(communicationStyle.patterns ?? communicationStyle.traits);
  const reconciliationScore = num(raw.reconciliation_score ?? raw.reconciliationScore, 0);
  const emotionalDistance = str(raw.emotional_distance ?? raw.emotionalDistance);
  const coreIssue = str(raw.core_issue ?? raw.coreIssue);
  const growthAreas = strArr(raw.growth_areas ?? raw.growthAreas);

  const hasEmotionalData = emotionalPatterns.length > 0;
  const hasScreenshotData = screenshotSummary || screenshotInsights.length > 0;

  const summary =
    result.summary ||
    '재회운은 감정 폭발보다 정리된 태도에서 가능성이 살아나는 흐름입니다. 다시 만날 수 있느냐보다, 만나도 괜찮은 관계가 되느냐를 먼저 봐야 합니다.';

  const chips =
    result.contextTags.length > 0
      ? result.contextTags
      : ['재접점', '감정 정리', '타이밍'];

  const statItems =
    result.metrics.length > 0
      ? result.metrics.map((m, i) => ({
          label: m.label,
          value: Number(m.value) || [68, 74, 80][i] || 70,
          highlight: m.note || '',
        }))
      : [
          {
            label: '재회 가능성',
            value: 68,
            highlight: '감정은 남아 있지만, 방식이 정리되지 않으면 반복될 수 있습니다.',
          },
          {
            label: '감정 안정도',
            value: 74,
            highlight: '다시 연결되더라도 속도를 천천히 두는 편이 안전합니다.',
          },
          {
            label: '타이밍 적합도',
            value: 80,
            highlight: '급한 확인보다 한 번의 차분한 접점이 더 유효합니다.',
          },
        ];

  const highlights =
    result.highlights.length > 0
      ? result.highlights
      : [
          '기대보다 기준을 먼저 정리하고 접근하세요.',
          '좋았던 기억보다 지금 달라진 점을 확인하세요.',
        ];

  const warnings =
    result.warnings.length > 0
      ? result.warnings
      : [
          '과거 감정만으로 현재를 덮어보는 것',
          '재회를 "확답"으로만 판단하려는 것',
        ];

  /* --- Computed display values for thermometer --- */
  const thermoScore = reconciliationScore > 0
    ? reconciliationScore
    : (statItems[0]?.value ?? 68);
  const thermoColor =
    thermoScore >= 80
      ? EMOTION_PALETTE.obsession
      : thermoScore >= 60
        ? fortuneTheme.colors.accentTertiary
        : thermoScore >= 40
          ? fortuneTheme.colors.warning
          : fortuneTheme.colors.accentSecondary;
  const thermoLabel =
    thermoScore >= 80
      ? '가능성 높음'
      : thermoScore >= 60
        ? '조정하면 가능'
        : thermoScore >= 40
          ? '시간 필요'
          : '거리 유지 권장';

  /* Type badge mapping for emotional patterns */
  const patternTypeBadge = (type: string) => {
    const t = type.toLowerCase();
    if (t.includes('집착') || t.includes('obsess'))
      return { label: '집착', color: fortuneTheme.colors.error, bg: withAlpha(fortuneTheme.colors.error, 0.12) };
    if (t.includes('회피') || t.includes('avoid'))
      return { label: '회피', color: fortuneTheme.colors.accentSecondary, bg: withAlpha(fortuneTheme.colors.accentSecondary, 0.12) };
    if (t.includes('불안') || t.includes('anxi'))
      return { label: '불안', color: fortuneTheme.colors.warning, bg: withAlpha(fortuneTheme.colors.warning, 0.12) };
    if (t.includes('분노') || t.includes('anger'))
      return { label: '분노', color: EMOTION_PALETTE.avoidance, bg: withAlpha(EMOTION_PALETTE.avoidance, 0.12) };
    if (t.includes('슬픔') || t.includes('sad'))
      return { label: '슬픔', color: fortuneTheme.colors.ctaBackground, bg: withAlpha(fortuneTheme.colors.ctaBackground, 0.12) };
    if (t.includes('그리움') || t.includes('miss'))
      return { label: '그리움', color: fortuneTheme.colors.accentTertiary, bg: withAlpha(fortuneTheme.colors.accentTertiary, 0.12) };
    if (type)
      return { label: type, color: fortuneTheme.colors.accentSecondary, bg: withAlpha(fortuneTheme.colors.accentSecondary, 0.12) };
    return null;
  };

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Hero: Emotional healing report header                        */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>🌙</AppText>
          <View style={{ flex: 1 }}>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              감정 치유 리포트
            </AppText>
            <AppText variant="oracleTitle">{meta.title}</AppText>
          </View>
        </View>
        <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
          {summary}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  1. Emotion Thermometer (vertical visual)                     */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <AppText variant="heading4">감정 온도계</AppText>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.lg, alignItems: 'flex-end' }}>
          {/* Thermometer visual */}
          <View style={{ alignItems: 'center', width: 48 }}>
            {/* Top bulb label */}
            <AppText variant="labelMedium" style={{ color: thermoColor, marginBottom: 4 }}>
              {thermoScore}%
            </AppText>
            {/* Thermometer tube */}
            <View
              style={{
                width: 28,
                height: 140,
                borderRadius: 14,
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                overflow: 'hidden',
                justifyContent: 'flex-end',
              }}
            >
              <View
                style={{
                  width: '100%',
                  height: `${Math.max(10, Math.min(100, thermoScore))}%`,
                  backgroundColor: thermoColor,
                  borderRadius: 14,
                }}
              />
            </View>
            {/* Bottom bulb */}
            <View
              style={{
                width: 44,
                height: 44,
                borderRadius: 22,
                backgroundColor: thermoColor,
                marginTop: -8,
                alignItems: 'center',
                justifyContent: 'center',
                borderWidth: 3,
                borderColor: fortuneTheme.colors.backgroundTertiary,
              }}
            >
              <AppText style={{ fontSize: 18 }}>🌡️</AppText>
            </View>
          </View>
          {/* Right side info */}
          <View style={{ flex: 1, gap: fortuneTheme.spacing.sm }}>
            <View>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                재회 가능성
              </AppText>
              <AppText variant="heading3" style={{ color: thermoColor }}>
                {thermoLabel}
              </AppText>
            </View>
            {emotionalDistance ? (
              <View>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  감정 거리
                </AppText>
                <AppText variant="labelLarge">{emotionalDistance}</AppText>
              </View>
            ) : null}
            {/* Scale labels */}
            <View style={{ gap: 2 }}>
              {[
                { label: '80+', desc: '가능성 높음', color: EMOTION_PALETTE.obsession },
                { label: '60-79', desc: '조정하면 가능', color: fortuneTheme.colors.accentTertiary },
                { label: '40-59', desc: '시간 필요', color: fortuneTheme.colors.warning },
                { label: '~39', desc: '거리 유지', color: fortuneTheme.colors.accentSecondary },
              ].map((s) => (
                <View key={s.label} style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                  <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: s.color }} />
                  <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                    {s.label}: {s.desc}
                  </AppText>
                </View>
              ))}
            </View>
          </View>
        </View>
      </Card>

      {/* ============================================================ */}
      {/*  2. Emotional Pattern Cards (with intensity bar + type badge) */}
      {/* ============================================================ */}
      {hasEmotionalData && (
        <SectionCard title="감정 패턴 카드" description="관계에서 반복되는 감정의 흐름입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {emotionalPatterns.map((pat, index) => {
              const p = obj(pat);
              const patName = str(p.name ?? p.pattern ?? p.label, `패턴 ${index + 1}`);
              const patDesc = str(p.description ?? p.detail ?? p.meaning);
              const patIntensity = num(p.intensity ?? p.score ?? p.level, 0);
              const patType = str(p.type ?? p.category);
              const badge = patternTypeBadge(patType);
              const intensityColor =
                patIntensity >= 80
                  ? fortuneTheme.colors.error
                  : patIntensity >= 60
                    ? fortuneTheme.colors.accentTertiary
                    : patIntensity >= 40
                      ? fortuneTheme.colors.warning
                      : fortuneTheme.colors.accentSecondary;

              return (
                <Card
                  key={`pat-${index}`}
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
                    <AppText variant="heading4">{patName}</AppText>
                    {badge ? (
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
                    ) : null}
                  </View>
                  {patIntensity > 0 && (
                    <View style={{ gap: 2 }}>
                      <View
                        style={{
                          flexDirection: 'row',
                          justifyContent: 'space-between',
                          alignItems: 'center',
                        }}
                      >
                        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                          강도
                        </AppText>
                        <AppText variant="labelMedium" style={{ color: intensityColor }}>
                          {patIntensity}
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
                            backgroundColor: intensityColor,
                            borderRadius: fortuneTheme.radius.full,
                            height: '100%',
                            width: `${Math.min(100, patIntensity)}%`,
                          }}
                        />
                      </View>
                    </View>
                  )}
                  {patDesc ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {patDesc}
                    </AppText>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  3. Core Issue (large InsetQuote with accent)                  */}
      {/* ============================================================ */}
      {coreIssue ? (
        <Card
          style={{
            backgroundColor: withAlpha(fortuneTheme.colors.error, 0.05),
            borderLeftWidth: 4,
            borderLeftColor: EMOTION_PALETTE.obsession,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <AppText style={{ fontSize: 22, lineHeight: 28 }}>💔</AppText>
            <AppText variant="heading4">핵심 이슈</AppText>
          </View>
          <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
            {coreIssue}
          </AppText>
        </Card>
      ) : null}

      {/* ============================================================ */}
      {/*  Screenshot analysis summary (from raw API)                   */}
      {/* ============================================================ */}
      {hasScreenshotData && (
        <SectionCard title="대화 분석" description="스크린샷에서 읽은 대화 패턴입니다.">
          {screenshotSummary ? (
            <InsetQuote text={screenshotSummary} />
          ) : null}
          {screenshotInsights.length > 0 ? (
            <View style={{ marginTop: screenshotSummary ? fortuneTheme.spacing.sm : 0 }}>
              <BulletList items={screenshotInsights} accent="인사이트" />
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  4. Communication Style Analysis (pills)                      */}
      {/* ============================================================ */}
      {(commStyleDesc || commPatterns.length > 0) && (
        <SectionCard title="소통 스타일 분석" description="두 사람 사이의 대화 패턴입니다.">
          {commStyleDesc ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {commStyleDesc}
            </AppText>
          ) : null}
          {commPatterns.length > 0 ? (
            <View
              style={{
                flexDirection: 'row',
                flexWrap: 'wrap',
                gap: fortuneTheme.spacing.sm,
                marginTop: commStyleDesc ? fortuneTheme.spacing.sm : 0,
              }}
            >
              {commPatterns.map((pattern, i) => {
                const pillColors = [fortuneTheme.colors.ctaBackground, EMOTION_PALETTE.obsession, fortuneTheme.colors.accentTertiary, fortuneTheme.colors.accentSecondary, fortuneTheme.colors.success, fortuneTheme.colors.warning];
                const color = pillColors[i % pillColors.length]!;
                return (
                  <View
                    key={`comm-${i}`}
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      gap: 4,
                      backgroundColor: `${color}18`,
                      borderRadius: fortuneTheme.radius.full,
                      paddingHorizontal: fortuneTheme.spacing.md,
                      paddingVertical: fortuneTheme.spacing.xs,
                      borderWidth: 1,
                      borderColor: withAlpha(color, 0.2),
                    }}
                  >
                    <AppText style={{ fontSize: 12 }}>💬</AppText>
                    <AppText variant="labelMedium" style={{ color }}>
                      {pattern}
                    </AppText>
                  </View>
                );
              })}
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Stat rail (reconciliation metrics)                           */}
      {/* ============================================================ */}
      <SectionCard title="재회 지표">
        <StatRail items={statItems} />
      </SectionCard>

      {/* ============================================================ */}
      {/*  Recommendations / Warnings side-by-side                      */}
      {/* ============================================================ */}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
        <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
          <Card
            style={{
              backgroundColor: withAlpha(fortuneTheme.colors.success, 0.06),
              borderWidth: 1,
              borderColor: withAlpha(fortuneTheme.colors.success, 0.15),
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <AppText variant="heading4" style={{ color: fortuneTheme.colors.success }}>추천 행동</AppText>
            {highlights.map((item, i) => (
              <View key={`do-${i}`} style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ color: fortuneTheme.colors.success, fontSize: 12 }}>{'●'}</AppText>
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
              backgroundColor: withAlpha(fortuneTheme.colors.error, 0.06),
              borderWidth: 1,
              borderColor: withAlpha(fortuneTheme.colors.error, 0.15),
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <AppText variant="heading4" style={{ color: fortuneTheme.colors.error }}>주의 행동</AppText>
            {warnings.map((item, i) => (
              <View key={`dont-${i}`} style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
                <AppText style={{ color: fortuneTheme.colors.error, fontSize: 12 }}>{'●'}</AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ flex: 1 }}>
                  {item}
                </AppText>
              </View>
            ))}
          </Card>
        </View>
      </View>

      {/* ============================================================ */}
      {/*  5. Growth Areas (cards with plant emoji)                     */}
      {/* ============================================================ */}
      {growthAreas.length > 0 && (
        <SectionCard title="성장 영역" description="재회 전에 정리하면 좋은 부분입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {growthAreas.map((area, i) => (
              <View
                key={`growth-${i}`}
                style={{
                  flexDirection: 'row',
                  alignItems: 'flex-start',
                  gap: fortuneTheme.spacing.sm,
                  backgroundColor: withAlpha(fortuneTheme.colors.success, 0.06),
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.md,
                  borderWidth: 1,
                  borderColor: withAlpha(fortuneTheme.colors.success, 0.12),
                }}
              >
                <AppText style={{ fontSize: 20, lineHeight: 26 }}>🌱</AppText>
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                  style={{ flex: 1 }}
                >
                  {area}
                </AppText>
              </View>
            ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Healing timeline                                             */}
      {/* ============================================================ */}
      <SectionCard title="치유 타임라인">
        <Timeline
          items={[
            { title: '지금', tag: '정리', body: '내가 다시 원하는 관계의 기준을 먼저 적어두세요.' },
            { title: '접점', tag: '대화', body: '감정 확인보다 안부와 현실 대화를 먼저 여는 편이 좋습니다.' },
            { title: '이후', tag: '판단', body: '한 번의 반응이 아니라 2~3번의 태도를 보고 판단하세요.' },
          ]}
        />
      </SectionCard>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="재회 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  6. YearlyEncounterResult                                           */
/* ------------------------------------------------------------------ */

function YearlyEncounterResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['yearly-encounter'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract yearly-encounter specific data from raw API response ---
  const monthlyPredictions = arr(raw.monthly_predictions ?? raw.monthlyPredictions);
  const partnerProfile = obj(raw.ideal_partner ?? raw.idealPartner ?? raw.partner_profile ?? raw.partnerProfile);
  const partnerTraits = strArr(partnerProfile.traits ?? partnerProfile.characteristics);
  const partnerAge = str(partnerProfile.age_range ?? partnerProfile.ageRange);
  const partnerVibe = str(partnerProfile.vibe ?? partnerProfile.impression ?? partnerProfile.first_impression);
  const partnerDesc = str(partnerProfile.description ?? partnerProfile.summary);
  const meetingLocations = strArr(raw.meeting_locations ?? raw.meetingLocations ?? raw.locations);
  const meetingTiming = obj(raw.meeting_timing ?? raw.meetingTiming ?? raw.timing);
  const bestMonth = str(meetingTiming.best_month ?? meetingTiming.bestMonth ?? meetingTiming.peak);
  const bestSeason = str(meetingTiming.best_season ?? meetingTiming.bestSeason ?? meetingTiming.season);
  const timingNote = str(meetingTiming.note ?? meetingTiming.description);
  const compatibilityPredictions = arr(raw.compatibility_predictions ?? raw.compatibilityPredictions ?? raw.compatibility);
  const encounterScore = num(raw.encounter_score ?? raw.encounterScore ?? raw.score, 0);
  const yearSummary = str(raw.year_summary ?? raw.yearSummary);

  const hasMonthly = monthlyPredictions.length > 0;
  const hasPartnerProfile = partnerTraits.length > 0 || partnerVibe || partnerDesc;
  const hasMeetingLocations = meetingLocations.length > 0;
  const hasMeetingTiming = bestMonth || bestSeason || timingNote;
  const hasCompatibility = compatibilityPredictions.length > 0;

  const summary =
    result.summary ||
    '올해의 인연운은 한 번의 강한 이벤트보다, 반복해서 눈에 들어오는 신호에서 시작될 가능성이 큽니다. 인상과 장소, 시그널을 함께 읽는 결과예요.';

  const luckyItems =
    result.luckyItems.length > 0
      ? result.luckyItems
      : ['우디 향', '라이트 브라운', '정리된 셔츠', '낮은 목소리'];

  const specialTip =
    result.specialTip ||
    '이번 인연운은 \'한 번에 확신\'보다 \'자꾸 생각나는 사람\'을 기준으로 읽는 편이 더 정확합니다.';

  /* ---- Encounter gauge score ---- */
  const encounterGauge = encounterScore > 0 ? encounterScore : 78;

  /* ---- Monthly calendar helper: extract highlighted months from predictions ---- */
  const MONTH_LABELS = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
  const highlightedMonths = new Set<number>();
  if (hasMonthly) {
    monthlyPredictions.forEach((pred) => {
      const p = obj(pred);
      const monthStr = str(p.month ?? p.label ?? p.title, '');
      const monthNum = parseInt(monthStr.replace(/[^0-9]/g, ''), 10);
      if (monthNum >= 1 && monthNum <= 12) highlightedMonths.add(monthNum);
    });
  }
  if (bestMonth) {
    const bm = parseInt(bestMonth.replace(/[^0-9]/g, ''), 10);
    if (bm >= 1 && bm <= 12) highlightedMonths.add(bm);
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  1. 인연 점수 게이지 — Heart + star theme                     */}
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
            borderColor: '#E040FB',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'rgba(224,64,251,0.08)',
          }}
        >
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>{'\uD83D\uDCAB'}</AppText>
          <AppText
            variant="heading2"
            style={{ color: '#E040FB' }}
          >
            {encounterGauge}
          </AppText>
        </View>
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          인연 점수
        </AppText>
        <AppText variant="oracleTitle">{meta.title}</AppText>
        <AppText
          variant="oracleBody"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
        >
          {summary}
        </AppText>
        {yearSummary ? (
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textTertiary}
            style={{ textAlign: 'center', fontStyle: 'italic', paddingHorizontal: fortuneTheme.spacing.md }}
          >
            {yearSummary}
          </AppText>
        ) : null}
      </Card>

      {/* ============================================================ */}
      {/*  2. 이상형 프로필 카드 — Partner profile with traits pills     */}
      {/* ============================================================ */}
      <SectionCard title="이상형 프로필" description="올해 인연에서 나타날 가능성이 높은 상대입니다.">
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            gap: fortuneTheme.spacing.md,
            borderWidth: 1,
            borderColor: 'rgba(224,64,251,0.20)',
          }}
        >
          {/* Profile header */}
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.md }}>
            {/* Avatar placeholder */}
            <View
              style={{
                width: 64,
                height: 64,
                borderRadius: fortuneTheme.radius.full,
                backgroundColor: 'rgba(224,64,251,0.15)',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <AppText style={{ fontSize: 28, lineHeight: 36 }}>{'\u2764\uFE0F'}</AppText>
            </View>
            <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
              {partnerVibe ? (
                <AppText variant="heading3" color="#E040FB">
                  {partnerVibe}
                </AppText>
              ) : (
                <AppText variant="heading3" color="#E040FB">
                  차분한 따뜻함
                </AppText>
              )}
              {partnerAge ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                  예상 나이대: {partnerAge}
                </AppText>
              ) : null}
            </View>
          </View>
          {/* Description */}
          {partnerDesc ? (
            <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
              {partnerDesc}
            </AppText>
          ) : null}
          {/* Traits pills */}
          {(partnerTraits.length > 0 ? partnerTraits : luckyItems).length > 0 && (
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.xs }}>
              {(partnerTraits.length > 0 ? partnerTraits : luckyItems).map((trait, i) => (
                <View
                  key={`trait-${i}`}
                  style={{
                    backgroundColor: 'rgba(224,64,251,0.12)',
                    paddingHorizontal: fortuneTheme.spacing.sm + 2,
                    paddingVertical: fortuneTheme.spacing.xs + 1,
                    borderRadius: fortuneTheme.radius.full,
                  }}
                >
                  <AppText variant="labelMedium" color="#E040FB">
                    {trait}
                  </AppText>
                </View>
              ))}
            </View>
          )}
        </Card>
      </SectionCard>

      {/* ============================================================ */}
      {/*  3. 월별 인연 캘린더 — 12-month mini grid                     */}
      {/* ============================================================ */}
      <SectionCard title="월별 인연 캘린더" description="올해 인연 에너지가 높은 달을 확인하세요.">
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.xs,
          }}
        >
          {MONTH_LABELS.map((label, index) => {
            const monthNum = index + 1;
            const isHighlighted = highlightedMonths.has(monthNum);
            return (
              <View
                key={`month-${monthNum}`}
                style={{
                  width: '23%',
                  aspectRatio: 1.6,
                  borderRadius: fortuneTheme.radius.md,
                  backgroundColor: isHighlighted
                    ? 'rgba(224,64,251,0.20)'
                    : fortuneTheme.colors.surfaceSecondary,
                  borderWidth: isHighlighted ? 2 : 1,
                  borderColor: isHighlighted ? '#E040FB' : fortuneTheme.colors.border,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <AppText
                  variant={isHighlighted ? 'labelLarge' : 'labelMedium'}
                  color={isHighlighted ? '#E040FB' : fortuneTheme.colors.textTertiary}
                >
                  {label}
                </AppText>
                {isHighlighted && (
                  <AppText style={{ fontSize: 10, lineHeight: 12 }}>{'\u2764\uFE0F'}</AppText>
                )}
              </View>
            );
          })}
        </View>
        {hasMeetingTiming && (bestMonth || bestSeason) && (
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm, marginTop: fortuneTheme.spacing.sm }}>
            {bestMonth ? (
              <View
                style={{
                  backgroundColor: 'rgba(224,64,251,0.12)',
                  paddingHorizontal: fortuneTheme.spacing.md,
                  paddingVertical: fortuneTheme.spacing.xs + 2,
                  borderRadius: fortuneTheme.radius.full,
                }}
              >
                <AppText variant="labelMedium" color="#E040FB">
                  최적의 달: {bestMonth}
                </AppText>
              </View>
            ) : null}
            {bestSeason ? (
              <View
                style={{
                  backgroundColor: 'rgba(224,64,251,0.12)',
                  paddingHorizontal: fortuneTheme.spacing.md,
                  paddingVertical: fortuneTheme.spacing.xs + 2,
                  borderRadius: fortuneTheme.radius.full,
                }}
              >
                <AppText variant="labelMedium" color="#E040FB">
                  최적의 시즌: {bestSeason}
                </AppText>
              </View>
            ) : null}
          </View>
        )}
        {timingNote ? (
          <View style={{ marginTop: fortuneTheme.spacing.sm }}>
            <InsetQuote text={timingNote} />
          </View>
        ) : null}
      </SectionCard>

      {/* ============================================================ */}
      {/*  Monthly predictions detail (if available from raw API)        */}
      {/* ============================================================ */}
      {hasMonthly && (
        <SectionCard title="월별 상세 예측" description="달마다 달라지는 만남의 흐름입니다.">
          <Timeline
            items={monthlyPredictions.map((pred) => {
              const p = obj(pred);
              const month = str(p.month ?? p.label ?? p.title, '');
              const tag = str(p.tag ?? p.keyword ?? p.theme, '');
              const body = str(p.description ?? p.detail ?? p.body ?? p.prediction, '');
              return { title: month, tag, body };
            })}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  4. 만남 장소 — Location pills with pin emoji                  */}
      {/* ============================================================ */}
      <SectionCard title="만남 장소" description="인연이 시작될 가능성이 높은 장소입니다.">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {(hasMeetingLocations ? meetingLocations : ['단골 카페', '서점', '공원', '헬스장']).map(
            (loc, index) => (
              <View
                key={`loc-${index}`}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  paddingHorizontal: fortuneTheme.spacing.md,
                  paddingVertical: fortuneTheme.spacing.sm,
                  borderRadius: fortuneTheme.radius.full,
                  gap: fortuneTheme.spacing.xs,
                }}
              >
                <AppText style={{ fontSize: 14, lineHeight: 18 }}>{'\uD83D\uDCCD'}</AppText>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textPrimary}>
                  {loc}
                </AppText>
              </View>
            ),
          )}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  5. 궁합 예측 — Compatibility cards with score bars            */}
      {/* ============================================================ */}
      {hasCompatibility && (
        <SectionCard title="궁합 예측" description="올해 만날 가능성이 높은 유형과의 궁합입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {compatibilityPredictions.map((comp, index) => {
              const c = obj(comp);
              const compType = str(c.type ?? c.name ?? c.label, `유형 ${index + 1}`);
              const compScore = num(c.score ?? c.compatibility ?? c.level, 0);
              const compDesc = str(c.description ?? c.detail ?? c.note);
              const barColor = compScore >= 80 ? '#E040FB' : compScore >= 60 ? fortuneTheme.colors.accentSecondary : fortuneTheme.colors.warning;

              return (
                <Card
                  key={`compat-${index}`}
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
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                      <AppText style={{ fontSize: 16, lineHeight: 20 }}>{'\u2764\uFE0F'}</AppText>
                      <AppText variant="heading4">{compType}</AppText>
                    </View>
                    {compScore > 0 ? (
                      <AppText variant="labelLarge" color={barColor}>
                        {compScore}%
                      </AppText>
                    ) : null}
                  </View>
                  {compScore > 0 && (
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
                          backgroundColor: barColor,
                          borderRadius: fortuneTheme.radius.full,
                          height: '100%',
                          width: `${Math.min(100, compScore)}%`,
                        }}
                      />
                    </View>
                  )}
                  {compDesc ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {compDesc}
                    </AppText>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Special tip                                                   */}
      {/* ============================================================ */}
      <SectionCard title="올해의 메모">
        <InsetQuote text={specialTip} />
      </SectionCard>

      {result.hasApiData && result.highlights.length > 0 && (
        <SectionCard title="추가 인사이트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  7. DecisionResult                                                  */
/* ------------------------------------------------------------------ */

function DecisionResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.decision;
  const result = useResultData(props.payload);
  const raw = obj(props.payload?.rawApiResponse);
  const data = obj(raw.data ?? raw.fortune ?? raw);

  // Direct API fields
  const question = str(data.question);
  const decisionType = str(data.decisionType);
  const recommendation = str(data.recommendation);
  const rawOptions = arr(data.options) as R[];
  const confidenceFactors = strArr(data.confidenceFactors);
  const nextSteps = strArr(data.nextSteps);

  const summary = str(data.summary) || result.summary
    || '의사결정 인사이트는 정답을 찾기보다 기준을 선명하게 세우는 쪽에 반응합니다.';

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard emoji="🤔" title={meta.title} description={summary} />

      {/* 질문 표시 */}
      {question ? (
        <SectionCard title="고민">
          <InsetQuote text={question} />
        </SectionCard>
      ) : null}

      {/* 옵션별 장단점 분석 */}
      {rawOptions.length > 0 ? (
        <SectionCard title="선택지 분석">
          {rawOptions.map((opt, i) => {
            const optionName = str(opt.option) || str(opt.name) || `옵션 ${i + 1}`;
            const pros = strArr(opt.pros);
            const cons = strArr(opt.cons);
            return (
              <Card key={i} style={{ marginBottom: fortuneTheme.spacing.sm, gap: fortuneTheme.spacing.xs }}>
                <AppText variant="heading4">{optionName}</AppText>
                {pros.length > 0 ? (
                  <View>
                    <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>장점</AppText>
                    <BulletList items={pros} />
                  </View>
                ) : null}
                {cons.length > 0 ? (
                  <View style={{ marginTop: fortuneTheme.spacing.xs }}>
                    <AppText variant="labelLarge" color={fortuneTheme.colors.error}>단점</AppText>
                    <BulletList items={cons} />
                  </View>
                ) : null}
              </Card>
            );
          })}
        </SectionCard>
      ) : (
        <>
          <SectionCard title="결정 지표">
            <MetricGrid items={result.metrics.length > 0 ? result.metrics : [
              { label: '명확도', value: '86', note: '기준만 세우면 빠름' },
              { label: '확신도', value: '79', note: '막판 흔들림 관리 필요' },
            ]} />
          </SectionCard>
          <SectionCard title="3단계 판단 흐름">
            <Timeline items={[
              { title: '정의', tag: '기준', body: '이번 선택에서 절대 포기 못할 기준을 한 문장으로 적습니다.' },
              { title: '분기', tag: '비교', body: '좋은 점보다 위험 신호를 먼저 비교하면 판단이 빨라집니다.' },
              { title: '확정', tag: '실행', body: '결정 후 첫 행동을 바로 예약해야 후회가 줄어듭니다.' },
            ]} />
          </SectionCard>
        </>
      )}

      {/* 추천 */}
      {recommendation ? (
        <SectionCard title="추천">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{recommendation}</AppText>
        </SectionCard>
      ) : null}

      {/* 확신 요소 */}
      {confidenceFactors.length > 0 ? (
        <SectionCard title="확신을 높이는 요소">
          <BulletList items={confidenceFactors} />
        </SectionCard>
      ) : null}

      {/* 다음 단계 */}
      {nextSteps.length > 0 ? (
        <SectionCard title="다음 단계">
          <BulletList items={nextSteps} />
        </SectionCard>
      ) : result.recommendations.length > 0 ? (
        <SectionCard title="추천 행동">
          <BulletList items={result.recommendations} />
        </SectionCard>
      ) : null}

      {result.hasApiData && result.specialTip ? (
        <SectionCard title="결정 팁">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  8. DailyReviewResult                                               */
/* ------------------------------------------------------------------ */

function DailyReviewResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['daily-review'];
  const result = useResultData(props.payload);

  const summary =
    result.summary ||
    '하루 리뷰는 잘한 점을 부풀리는 것보다, 남길 것과 넘길 것을 분리하는 데서 힘이 생깁니다. 오늘은 정리의 밀도가 중요한 날입니다.';

  const chips =
    result.contextTags.length > 0
      ? result.contextTags
      : ['하루 정리', '감정 회수', '내일 연결'];

  const metrics =
    result.metrics.length > 0
      ? result.metrics
      : [
          { label: '에너지 회수', value: '81', note: '과한 소모는 줄인 편' },
          { label: '관계 만족도', value: '76', note: '짧은 피로 남음' },
          { label: '집중 완성도', value: '84', note: '핵심 한 건은 잘 끝냄' },
          { label: '회복 필요도', value: '69', note: '잠들기 전 정리 필요' },
        ];

  const highlights =
    result.highlights.length > 0
      ? result.highlights
      : [
          '잘된 한 가지를 문장으로 남겨 내일의 기준점으로 삼으세요.',
          '감정이 남는 대화는 해석보다 사실만 먼저 적어두세요.',
          '오늘 끝낸 일과 아직 열린 일을 따로 구분하세요.',
        ];

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '결정이 덜 선명한 일은 아침에 다시 보기',
          '피곤할 때 시작한 대화는 한 번 쉬고 이어가기',
          '오늘 떠오른 아이디어는 제목만 적고 과제화는 내일 하기',
        ];

  const specialTip =
    result.specialTip ||
    '좋은 하루 리뷰는 반성보다 정리에서 시작합니다. 오늘을 깔끔하게 접어야 내일의 에너지가 덜 새어 나갑니다.';

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard emoji="📋" title={meta.title} description={summary} chips={chips} />

      <SectionCard title="오늘의 요약 지표">
        <MetricGrid items={metrics} />
      </SectionCard>

      <SectionCard title="오늘 남길 메모">
        <BulletList items={highlights} />
      </SectionCard>

      <SectionCard title="내일로 넘길 것">
        <BulletList items={recommendations} />
      </SectionCard>

      <SectionCard title="마무리 메모">
        <InsetQuote text={specialTip} />
      </SectionCard>

      {result.hasApiData && result.luckyItems.length > 0 && (
        <SectionCard title="내일의 키워드">
          <KeywordPills keywords={result.luckyItems} />
        </SectionCard>
      )}
    </View>
  );
}

export const ResultBatchE = {
  ExamResult,
  CompatibilityResult,
  BlindDateResult,
  AvoidPeopleResult,
  ExLoverResult,
  YearlyEncounterResult,
  DecisionResult,
  DailyReviewResult,
};

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
  MetricGrid,
  SectionCard,
  Timeline,
} from '../primitives';
import HeroHealth from '../heroes/hero-health';
import HeroLine from '../heroes/hero-line';
import HeroOrbs from '../heroes/hero-orbs';
import { ResultCardFrame } from '../primitives/result-card-frame';
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

function CareerResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="career" data={payload} progress={1}>
      <HeroLine data={payload} progress={1} />
    </ResultCardFrame>
  );
}

/* -------------------------------------------------------------------------- */
/*  LoveResult                                                                */
/* -------------------------------------------------------------------------- */

function LoveResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="love" data={payload} progress={1}>
      <HeroOrbs data={payload} progress={1} />
    </ResultCardFrame>
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

function HealthResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="health" data={payload} progress={1}>
      <HeroHealth data={payload} progress={1} />
    </ResultCardFrame>
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

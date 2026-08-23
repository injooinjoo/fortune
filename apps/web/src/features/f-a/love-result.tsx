/**
 * 연애운 결과.
 *
 * 응답 계약 (`supabase/functions/fortune-love/index.ts`): 봉투는
 * `{ success, data, cached? }`. 서버가 `data` 를 조립하면서 거의 모든 필드에
 * 상태별 기본값(getStatusDefaults)을 채워 넣지만, cohort pool 히트 경로는
 * 저장돼 있던 payload 를 그대로 돌려주므로 하위 객체가 통째로 빌 수 있다.
 * 그래서 전부 optional 로 받는다.
 *
 * `recommendations`(데이트/패션/향수/대화)는 응답에서 가장 큰 덩어리인데
 * 웹 첫 방문 화면에서는 데이트 장소와 대화 주제만 남겼다 — 패션/그루밍/향수까지
 * 펼치면 결과가 스크롤 두세 배가 되고 정작 연애운 본문이 묻힌다.
 */

import {
  BulletList,
  CardList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  TextSection,
} from '@/features/fortune/result';

import { splitParagraphs } from './text';

interface LoveProfile {
  dominantStyle?: string;
  personalityType?: string;
  communicationStyle?: string;
  conflictResolution?: string;
}

interface LoveDetailedAnalysis {
  loveStyle?: { description?: string; strengths?: string[]; tendencies?: string[] };
  charmPoints?: { primary?: string; secondary?: string; details?: string[] };
  improvementAreas?: { main?: string; specific?: string[]; actionItems?: string[] };
  compatibilityInsights?: {
    bestMatch?: string;
    goodMatch?: string;
    challengingMatch?: string;
    avoidTypes?: string;
    relationshipTips?: string[];
  };
}

interface LoveRecommendations {
  dateSpots?: {
    primary?: string;
    alternatives?: string[];
    reason?: string;
    timeRecommendation?: string;
  };
  conversation?: { topics?: string[]; openers?: string[]; avoid?: string[]; tip?: string };
}

export interface LoveFortune {
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  loveProfile?: LoveProfile;
  detailedAnalysis?: LoveDetailedAnalysis;
  todaysAdvice?: {
    general?: string;
    specific?: string[];
    luckyAction?: string;
    warningArea?: string;
  };
  predictions?: {
    thisWeek?: string;
    thisMonth?: string;
    nextThreeMonths?: string;
    keyDates?: string[];
  };
  actionPlan?: { immediate?: string[]; shortTerm?: string[]; longTerm?: string[] };
  recommendations?: LoveRecommendations;
  percentile?: number | null;
  isPercentileValid?: boolean;
}

export interface LoveEnvelope {
  success?: boolean;
  data?: LoveFortune;
  cached?: boolean;
}

export function LoveResult({ fortune, cached }: { fortune: LoveFortune; cached: boolean }) {
  const analysis = fortune.detailedAnalysis ?? {};
  const insights = analysis.compatibilityInsights ?? {};
  const predictions = fortune.predictions ?? {};
  const profile = fortune.loveProfile ?? {};
  const dateSpots = fortune.recommendations?.dateSpots;
  const conversation = fortune.recommendations?.conversation;

  return (
    <section aria-label="연애운 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={`연애운${cached ? ' · 저장된 결과' : ''}`}
        note={
          fortune.isPercentileValid === true && typeof fortune.percentile === 'number'
            ? `오늘 연애운을 본 사람들 중 상위 ${fortune.percentile}%`
            : undefined
        }
        score={fortune.score}
        summary={fortune.summary}
      />

      <TextSection label="지금의 연애운" text={splitParagraphs(fortune.content)} />

      <KeyValueGrid
        label="연애 프로필"
        pairs={[
          { label: '연애 스타일', value: profile.dominantStyle },
          { label: '애착 유형', value: profile.personalityType },
          { label: '소통 방식', value: profile.communicationStyle },
          { label: '갈등 해결', value: profile.conflictResolution },
        ]}
      />

      <TextSection label="나의 연애 방식" text={splitParagraphs(analysis.loveStyle?.description)} />

      <BulletList items={analysis.loveStyle?.strengths} label="강점" />

      <TextSection
        label="매력 포인트"
        text={[analysis.charmPoints?.primary, analysis.charmPoints?.secondary]}
      />

      <TextSection label="이런 사람과 잘 맞아요" text={splitParagraphs(insights.bestMatch)} />

      <TextSection label="조심할 유형" text={splitParagraphs(insights.avoidTypes)} />

      <BulletList items={insights.relationshipTips} label="관계 조언" />

      <TextSection label="조언" text={splitParagraphs(fortune.advice ?? fortune.todaysAdvice?.general)} />

      <BulletList items={fortune.todaysAdvice?.specific} label="오늘 해볼 것" />

      {/* 예측은 문장이 길어 2열 정의목록(KeyValueGrid)에 넣으면 읽기 어렵다.
          CardList 는 제목만 있어도 항목을 그리므로 본문 없는 시기는 미리 뺀다. */}
      <CardList
        items={[
          { title: '이번 주', description: predictions.thisWeek },
          { title: '이번 달', description: predictions.thisMonth },
          { title: '앞으로 3개월', description: predictions.nextThreeMonths },
        ].filter((item) => Boolean(item.description))}
        label="흐름 예측"
      />

      <BulletList items={predictions.keyDates} label="주목할 시기" />

      <BulletList items={analysis.improvementAreas?.actionItems} label="실천 항목" />

      <TextSection
        label="추천 데이트"
        text={[dateSpots?.primary, dateSpots?.timeRecommendation, dateSpots?.reason]}
      />

      <BulletList items={dateSpots?.alternatives} label="다른 데이트 장소" />

      <BulletList items={conversation?.topics} label="대화 주제" />

      <Disclaimer />
    </section>
  );
}

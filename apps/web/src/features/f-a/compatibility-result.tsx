/**
 * 궁합 결과.
 *
 * 응답 계약 (`supabase/functions/fortune-compatibility/index.ts`): 봉투는
 * `{ success, data }`. `data` 는 LLM 이 만든 한국어 키를 서버가 영어 스네이크로
 * 옮겨 담은 것(`personality_match`, `love_match`, …)에 더해, 서버가 **직접 계산한**
 * 결정적 항목이 함께 온다 — 띠/별자리/운명수/나이차/계절/이름 궁합.
 * 이 결정적 항목들은 LLM 실패와 무관하게 늘 있으므로 결과가 비어 보이지 않는다.
 *
 * `detailed_advice` 는 `"• 첫째\n• 둘째"` 형태의 한 문자열이라 불릿으로 되돌린다.
 */

import {
  BulletList,
  CardList,
  Disclaimer,
  KeyValueGrid,
  ScoreHeadline,
  ScoreSection,
  TextSection,
} from '@/features/fortune/result';

import { splitBullets, splitParagraphs } from './text';

interface PairScore {
  person1?: string;
  person2?: string;
  score?: number;
  message?: string;
}

export interface CompatibilityFortune {
  person1?: { name?: string; birth_date?: string };
  person2?: { name?: string; birth_date?: string };
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  title?: string;
  overall_compatibility?: string;
  personality_match?: string;
  love_match?: string;
  marriage_match?: string;
  communication_match?: string;
  strengths?: string[];
  cautions?: string[];
  detailed_advice?: string;
  compatibility_keyword?: string;
  /** LLM 원본 키가 그대로 남는 자리 (`연애스타일`). 조합분석만 한국어 키다. */
  love_style?: { person1?: string; person2?: string; 조합분석?: string } | null;
  name_compatibility?: number;
  zodiac_animal?: PairScore;
  star_sign?: PairScore;
  destiny_number?: { number?: number; meaning?: string };
  age_difference?: { years?: number; message?: string };
  season?: PairScore;
  percentile?: number | null;
  isPercentileValid?: boolean;
}

export interface CompatibilityEnvelope {
  success?: boolean;
  data?: CompatibilityFortune;
}

/** '쥐 × 소 · 최고의 궁합 (90점)' 처럼 한 줄로. 값이 없으면 undefined. */
function pairLine(pair: PairScore | undefined): string | undefined {
  if (!pair) return undefined;
  const names = [pair.person1, pair.person2].filter(Boolean).join(' × ');
  const message =
    typeof pair.score === 'number' && pair.message
      ? `${pair.message} (${pair.score}점)`
      : pair.message;
  const parts = [names, message].filter(Boolean);
  return parts.length > 0 ? parts.join(' · ') : undefined;
}

export function CompatibilityResult({ fortune }: { fortune: CompatibilityFortune }) {
  const loveStyle = fortune.love_style ?? undefined;

  return (
    <section aria-label="궁합 결과" className="ondo-stack">
      <ScoreHeadline
        kicker={fortune.title ?? '궁합'}
        note={
          fortune.isPercentileValid === true && typeof fortune.percentile === 'number'
            ? `오늘 궁합을 본 사람들 중 상위 ${fortune.percentile}%`
            : undefined
        }
        score={fortune.score}
        summary={fortune.summary ?? fortune.compatibility_keyword}
      />

      <TextSection
        label="전반적인 궁합"
        text={splitParagraphs(fortune.overall_compatibility ?? fortune.content)}
      />

      <div className="ondo-grid-2">
        <ScoreSection label="성격 궁합" text={fortune.personality_match} />
        <ScoreSection label="애정 궁합" text={fortune.love_match} />
        <ScoreSection label="결혼 궁합" text={fortune.marriage_match} />
        <ScoreSection label="소통 궁합" text={fortune.communication_match} />
      </div>

      <KeyValueGrid
        label="사주로 본 두 사람"
        pairs={[
          { label: '띠 궁합', value: pairLine(fortune.zodiac_animal) },
          { label: '별자리 궁합', value: pairLine(fortune.star_sign) },
          { label: '운명수', value: fortune.destiny_number?.meaning },
          { label: '이름 궁합', value: fortune.name_compatibility },
          { label: '나이 차', value: fortune.age_difference?.message },
          { label: '태어난 계절', value: pairLine(fortune.season) },
        ]}
      />

      <BulletList items={fortune.strengths} label="이 조합의 강점" />

      <BulletList items={fortune.cautions} label="조심할 점" />

      {/* 스타일 문구만 나열하면 누구 것인지 알 수 없어 이름을 제목으로 붙인다.
          CardList 는 제목만 있어도 항목을 그리므로 본문 없는 쪽은 미리 뺀다. */}
      <CardList
        items={[
          {
            title: fortune.person1?.name ?? '첫 번째 사람',
            description: loveStyle?.person1,
          },
          {
            title: fortune.person2?.name ?? '두 번째 사람',
            description: loveStyle?.person2,
          },
        ].filter((item) => Boolean(item.description))}
        label="연애 스타일"
      />

      <TextSection label="둘이 만나면" text={splitParagraphs(loveStyle?.조합분석)} />

      <BulletList
        items={splitBullets(fortune.detailed_advice) ?? splitParagraphs(fortune.advice)}
        label="조언"
      />

      <Disclaimer />
    </section>
  );
}

/**
 * manseryeok-interpret — LLM 프롬프트 템플릿.
 *
 * 시스템 프롬프트: 전통 사주명리학 해석 전문가 페르소나 + JSON 강제.
 * 유저 프롬프트: SajuResult를 4주/오행/대운으로 요약해서 전달.
 */

import type { SajuDataLite } from "./types.ts";

export const SYSTEM_PROMPT =
  `당신은 전통 사주명리학 해석 전문가이며, 친근한 한국어로 운세를 풀이합니다.
입력된 4주(년/월/일/시)와 십성, 대운 정보를 바탕으로 성격, 직업, 재물, 애정, 건강, 오늘의 한 줄, 대운별 시기를 분석합니다.

해석 원칙:
- 단정적 표현 대신 "~하는 경향이 있어요" 같은 완곡한 어조
- 미신적 표현 대신 성향·패턴·조언 중심
- 각 섹션 summary는 2~3문장, 친근한 톤
- 반드시 유효한 JSON 형식으로만 응답 (마크다운·부연설명 없이)`;

/**
 * SajuDataLite를 바탕으로 유저 프롬프트 문자열을 생성한다.
 * LLM이 반환해야 할 JSON 스키마를 함께 박아넣어 일관된 응답을 유도한다.
 */
export function buildUserPrompt(saju: SajuDataLite): string {
  const p = saju.pillars;
  const tg = saju.tenGods;
  const el = saju.elements;
  const lc = saju.luckCycles;

  const cycleSummary = lc.cycles
    .map(
      (c) =>
        `${c.startAge}세: ${c.stem.korean}${c.branch.korean} (${c.tenGod})`,
    )
    .join(", ");

  const firstAge = lc.cycles[0]?.startAge ?? 0;
  const lastAge = (lc.cycles[lc.cycles.length - 1]?.startAge ?? 0) + 9;

  return `다음 사주 정보를 해석해주세요.

[4주]
년주: ${p.year.stem.korean}${p.year.branch.korean} (천간 십성: ${tg.year.stem}, 지지 십성: ${tg.year.branch})
월주: ${p.month.stem.korean}${p.month.branch.korean} (천간 십성: ${tg.month.stem}, 지지 십성: ${tg.month.branch})
일주: ${p.day.stem.korean}${p.day.branch.korean} (일간, 지지 십성: ${tg.day.branch})
시주: ${p.hour.stem.korean}${p.hour.branch.korean} (천간 십성: ${tg.hour.stem}, 지지 십성: ${tg.hour.branch})

[오행 분포]
목:${el.wood}, 화:${el.fire}, 토:${el.earth}, 금:${el.metal}, 수:${el.water}
${el.strongest ? `가장 강한 오행: ${el.strongest}` : ""}${el.weakest ? `, 가장 약한 오행: ${el.weakest}` : ""}

[대운 ${lc.direction}] 총 10개 (${firstAge}세 ~ ${lastAge}세)
${cycleSummary}

다음 JSON 스키마로만 응답:
{
  "overallSummary": "전체 종합 2~3문장",
  "personality": {
    "summary": "성격 2~3문장",
    "strengths": ["장점1", "장점2", "장점3"],
    "challenges": ["보완점1", "보완점2"]
  },
  "career": {
    "summary": "직업운 2~3문장",
    "suitableFields": ["분야1", "분야2", "분야3"],
    "advice": "직업 조언 1~2문장"
  },
  "wealth": {
    "summary": "재물운 2~3문장",
    "bestPeriods": ["호재 시기1", "호재 시기2"],
    "caution": "주의할 점 1문장"
  },
  "love": {
    "summary": "애정운 2~3문장",
    "compatibleTypes": ["잘 맞는 유형1", "유형2"],
    "advice": "관계 조언 1문장"
  },
  "health": {
    "summary": "건강 2~3문장",
    "weakPoints": ["주의 부위1", "부위2"],
    "advice": "건강 조언 1문장"
  },
  "daily": {
    "oneLiner": "오늘 하루 한 줄 문구",
    "luckyColor": "행운의 색 한 단어",
    "luckyDirection": "행운의 방향 (동/서/남/북/동남 등)"
  },
  "luckCycles": [
    ${lc.cycles.map((c) => `{ "ageRange": "${c.startAge}~${c.startAge + 9}세", "theme": "주제 키워드", "summary": "이 시기 2문장 해석" }`).join(",\n    ")}
  ]
}

luckCycles 배열은 정확히 10개, 위 나이 범위 그대로 유지.`;
}

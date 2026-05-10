// 운세 LLM 시스템 프롬프트에 강제 부착되는 안전/완곡 가드.
// App Store 1.4.1 (의료/금융 조언 회피) + 4.0 (misleading) + 1.1.4 (미성년자
// 보호) 동시 대응. 고위험 운세 카테고리에서 단정적 표현 / 의료 진단 / 구체
// 종목 추천 / 성적 표현 등이 LLM 응답에 포함되어 reject 되는 것 방지.
//
// 사용법:
//   import { withFortuneSafetyGuard } from '../_shared/fortune_safety_guard.ts'
//   const finalSystemPrompt = withFortuneSafetyGuard(originalPrompt, {
//     category: 'health',  // 'health' | 'wealth' | 'exam' | 'pregnancy' | 'love' | null
//   })
//
// 메시지 위치: 시스템 프롬프트의 맨 앞에 prepend. LLM이 이후 가이드를 무시
// 못하도록 [최우선] 표시. 기존 프롬프트의 "한국어 작성" 등 강제 룰과 충돌
// 없음 (안전 가드 + 한국어 룰 병존).

export type FortuneSafetyCategory =
  | 'health'
  | 'wealth'
  | 'exam'
  | 'pregnancy'
  | 'love'
  | null;

const SAFETY_PREAMBLE = `🛡️ [최우선 안전 룰 — 절대 위반 금지]
1. 이 서비스는 **엔터테인먼트 목적**의 운세입니다. 의료/법률/금융 진단·조언 아님.
2. **단정 표현 금지**. "~할 것입니다" / "~합니다" 대신 "~할 가능성이 있어요" / "~경향을 보입니다" / "참고삼아" 같은 완곡 어조 사용.
3. **미성년자가 사용 중일 수 있음을 항상 가정**. 성적 표현·신체 묘사·폭력 표현 금지.
4. 위반 시 응답 전체가 reject 됨. 모든 필드에 적용.
`;

const CATEGORY_RULES: Record<NonNullable<FortuneSafetyCategory>, string> = {
  health: `
🏥 [건강 카테고리 추가 룰]
- 의학적 진단(예: "당뇨가 의심됩니다", "심장이 약합니다")·치료법 금지.
- "취약 장기" / "건강점수" 같은 진단성 언어 대신 "균형 포인트" / "컨디션 톤" 등 비진단 표현 사용.
- 결과에 "정확한 진단/치료는 반드시 의료 전문가와 상담하세요" 톤 유지.
- 임신/출산 관련 단정("임신할 것입니다") 절대 금지.
`,
  wealth: `
💰 [재물/투자 카테고리 추가 룰]
- 구체 종목·코인·부동산 추천 금지 (예: "삼성전자 사세요", "비트코인 매수").
- "투자할 것입니다" 대신 "재물 흐름이 활발해 보여요" 같은 무드 표현.
- 결과에 "실제 투자 결정은 본인 판단/전문가 상담 필요" 톤 유지.
- 복권 당첨·로또 번호 추천 금지.
`,
  exam: `
📚 [시험/학업 카테고리 추가 룰]
- "합격할 것입니다" / "떨어집니다" 같은 단정 금지.
- "준비된 만큼 결과가 따라올 가능성이 높아요" 같은 격려 + 완곡 표현.
- 구체 학교/회사 합격 보장 표현 금지.
`,
  pregnancy: `
👶 [임신/가족 카테고리 추가 룰]
- 임신 가능성·시기를 단정하지 않음. "기다리는 마음이 결실로 이어질 수 있는 시기" 같은 정서적 표현.
- 의학적 임신 상담 대체 금지. "산부인과 전문의와 상담" 안내 톤.
- 출산·태아 건강 관련 단정 금지.
`,
  love: `
💕 [연애/궁합 카테고리 추가 룰]
- 미성년자 사용 가정 — 성적 표현·신체 묘사·성적 암시 절대 금지.
- 헤어진 연인/이별 주제도 위로 톤 유지, 보복·집착 조장 금지.
- "그 사람과 무조건 잘 됩니다" 같은 단정 금지.
- 자해·자살·우울 키워드 입력 시 운세 응답 자제하고 "전문 상담(자살예방 109)" 안내.
`,
};

export function withFortuneSafetyGuard(
  systemPrompt: string,
  opts: { category?: FortuneSafetyCategory } = {},
): string {
  const category = opts.category ?? null;
  const categoryBlock = category ? CATEGORY_RULES[category] : '';
  return `${SAFETY_PREAMBLE}${categoryBlock}\n${systemPrompt}`;
}

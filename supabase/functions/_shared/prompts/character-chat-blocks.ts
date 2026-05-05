/**
 * character-chat / proactive-message-dispatch 등 캐릭터 응답 LLM 호출에서
 * 재사용 가능한 정적 프롬프트 상수 모음.
 *
 * 추출 이유: character-chat/index.ts 가 3000+ 줄로 커진 상태에서 정적 상수가
 * 함수 정의 사이에 박혀 있어 가독성/재사용성이 떨어졌음. 신규 cron 워커
 * (selftalk, summarize 등) 가 같은 멀티버블/호감도 평가 패턴을 쓸 수 있도록
 * shared 로 끌어올림. 동작 변경 0 — 단순 위치 이동.
 *
 * prefix caching 친화성: 이 두 상수는 모두 static (사용자/세션 무관) 이라
 * 시스템 프롬프트의 prefix 부분에 항상 같은 위치로 들어가야 캐시 적중률이
 * 높아짐. character-chat/index.ts:2895/2912 가 systemPromptSections 배열의
 * 끝부분에 위치시키는 것은 의도된 동작.
 */

// 멀티버블 분할 지시 프롬프트 (카톡식 연속 메시지 느낌)
export const MULTI_BUBBLE_PROMPT = `
[카톡식 멀티버블 지침 — 중요]
실제 사람이 카톡 보내듯 자연스러운 문장 경계에서 응답을 2-4개 버블로 쪼개세요.
쪼개는 위치에 \`[SPLIT]\` 토큰을 정확히 삽입합니다.

규칙:
- 짧은 답변(1문장 이하, ~25자 미만)은 절대 쪼개지 마세요.
- 한 문단을 억지로 쪼개지 말고, 말의 호흡(쉼표/문장부호/감탄) 기준으로만 분할.
- 최대 4개까지. 대부분은 2-3개가 자연스러움.
- 이모지/느낌표 등은 각 버블 말미에 자연스럽게 붙여도 됨.
- \`[SPLIT]\` 앞뒤 공백/줄바꿈은 자유 (나중에 trim 처리됨).

예시:
"오 진짜?[SPLIT]나도 어제 그거 봤는데[SPLIT]너무 웃겨서 혼자 빵 터졌잖아ㅋㅋ"
"음...[SPLIT]그건 좀 서운하긴 한데[SPLIT]그래도 네 마음은 알 것 같아."
`;

// 호감도 평가 프롬프트 (사용자 메시지 평가용)
export const AFFINITY_EVALUATION_PROMPT = `
[호감도 평가 - 내부 시스템용]
사용자 메시지를 분석하여 응답 끝에 다음 JSON을 추가하세요:

<affinity>{"points":숫자,"reason":"이유","quality":"품질"}</affinity>

평가 기준:
- basic_chat (3~8점): 일반적인 대화, 인사, 간단한 질문
- quality_engagement (10~15점): 캐릭터에게 관심을 보이는 질문, 진심 어린 공감
- emotional_support (15~20점): 위로, 격려, 캐릭터의 고민을 들어주는 대화
- personal_disclosure (20~25점): 개인적인 이야기, 비밀 공유, 깊은 감정 표현
- disrespectful (-10점): 무례한 언어, 캐릭터 무시, 약올리기
- conflict_detected (-15~-30점): 싸움, 공격적 언어, 모욕
- spam_detected (0점): 의미 없는 반복, 스팸, 테스트 메시지

quality: negative(-점), neutral(0~5점), positive(6~15점), exceptional(16점+)
`;

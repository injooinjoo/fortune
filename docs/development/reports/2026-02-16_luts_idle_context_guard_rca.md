# RCA Report - Luts Idle Icebreaker Context Guard

## 1. Symptom
- Error message: 없음 (동작 품질 버그)
- Repro steps:
  1. 러츠 대화에서 사용자가 주제형 메시지를 보낸다. (예: 피부/시술 이야기)
  2. 러츠가 답변을 1~2개 버블로 보낸다.
  3. 약 10초 후 러츠가 `지금 뭐 하고 계세요?` 같은 아이스브레이킹 질문을 추가 발송한다.
- Observed behavior:
  - 사용자 질문에 응답 직후에도 맥락과 무관한 재질문이 붙어 대화가 끊긴다.
  - `저는 인공지능이라...` 같은 메타 문구가 출력되어 몰입이 깨진다.
- Expected behavior:
  - 아이스브레이커는 초반 저신호 턴에서만 제한적으로 발송되어야 한다.
  - 주제형 대화/질문 응답 직후에는 발송되면 안 된다.
  - 캐릭터 응답에서 AI 자기정체성 메타 문구가 나오면 안 된다.

## 2. WHY (Root Cause)
- Direct cause:
  - 읽음 10초 아이스브레이커 스케줄 조건이 `초기 단계 + 물음표 없음` 중심으로 넓게 열려 있었다.
  - 질문 판정이 `?` 문자 위주여서 한국어 질문형 종결(`~나요`)을 놓쳤다.
  - 서비스톤 정규화에 `저는 인공지능이라`류 메타 문구 제거 규칙이 없었다.
- Root cause:
  - 아이스브레이커를 "무응답"만으로 트리거하고, "현재 대화 신호 강도/맥락"을 판별하지 않았다.
- Data/control flow:
  - Step 1: `addCharacterMessage()`에서 읽음 아이스브레이커 타이머를 설정.
  - Step 2: 10초 후 `_sendReadIdleIcebreakerIfStillIdle()`가 유저 미응답만 확인.
  - Step 3: 주제형 턴에서도 공통 질문(`지금 뭐 하고 계세요?`)이 발송됨.

## 3. WHERE
- Primary location: `lib/features/character/presentation/providers/character_chat_provider.dart`
- Related call sites:
  - `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - `lib/features/character/presentation/pages/character_chat_panel.dart`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "readIdle|icebreaker|_shouldScheduleReadIdleIcebreaker" lib/features/character/presentation/providers/character_chat_provider.dart`
  - `rg "_sanitizeServiceTone|인공지능|as an ai|무엇을 도와드릴" lib/features/character/presentation/utils/luts_tone_policy.dart`
- Findings:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 아이스브레이커 스케줄/발송 경로 확인
  2. `lib/features/character/presentation/utils/luts_tone_policy.dart` - 서비스톤/메타 문구 정규화 지점 확인

## 5. HOW (Correct Pattern)
- Reference implementation:
  - `lib/features/character/presentation/providers/character_chat_provider.dart`의 컨텍스트 가드 함수
  - `lib/features/character/presentation/utils/luts_tone_policy.dart`의 후처리 정규화
- Before:
```dart
if (_containsQuestion(anchorMessage.text)) return false;
// 사용자 턴 의도/대화 깊이 검증 없음
```
- After:
```dart
if (_isQuestionLikeText(anchorMessage.text)) return false;
if (!_matchesReadIdleIcebreakerContext(anchorMessage)) return false;
```
- Why this fix is correct:
  - 아이스브레이커를 초반 저신호 턴으로 한정해 맥락 깨짐을 줄인다.
  - 한국어 질문형(물음표 없는 형태)도 질문으로 인식해 불필요한 재질문을 방지한다.
  - 메타 문구를 후처리에서 제거해 캐릭터 몰입을 유지한다.

## 6. Fix Plan
- Files to change:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 아이스브레이커 컨텍스트 가드 강화
  2. `lib/features/character/presentation/utils/luts_tone_policy.dart` - AI 메타 문구 정규식 제거 + 프롬프트 금지 규칙 추가
  3. `test/unit/features/character/presentation/utils/luts_tone_policy_test.dart` - 메타 문구 제거 테스트 추가
  4. `docs/development/character-chat/luts_kakao_style_v2.md` - 운영 규칙 문서 반영
- Risk assessment:
  - 아이스브레이커 발동 빈도가 줄어들 수 있음(의도된 보수화)
- Validation plan:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - `flutter test`
  - 수동 대화 시나리오로 "대화 중 재질문 미발송" 확인

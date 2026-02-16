# RCA Report - Luts 톤/카톡 대화 품질 이슈

## 1. Symptom
- Error message: 런타임 에러는 없음 (대화 품질 결함)
- Repro steps:
  1. `luts` 캐릭터 채팅방 최초 진입
  2. 첫 인사 확인
  3. 사용자 첫 응답 후 2~3턴 관찰
- Observed behavior:
  - 첫 인사가 반말/가정된 친밀 호칭으로 시작됨
  - 카톡 대화처럼 짧고 자연스러운 왕복이 아니라, 질문 강제형 문장으로 반복됨
  - follow-up/점심 선톡도 같은 톤 불일치가 발생함
- Expected behavior:
  - 사용자 톤을 따라 말투를 조정하고, 초기에는 과한 친밀 호칭 없이 자연스럽게 시작
  - 1버블 1~2문장 중심의 카톡형 응답
  - 실시간/후속/선톡 채널에서 동일한 톤 정책 유지

## 2. WHY (Root Cause)
- Direct cause:
  - 첫 인사 문구가 캐릭터별 미세 톤 정책 없이 고정 하드코딩됨
  - first-meet 프롬프트의 `1응답 1질문` 강제가 기계적 패턴을 유도함
  - follow-up/proactive 템플릿이 러츠 페르소나 원문에만 의존해 초기 톤 제어가 없음
- Root cause:
  - 러츠 전용 대화 정책(언어/격식 미러링, 애칭 게이트, 길이/질문 제한)이 구현되어 있지 않음
- Data/control flow:
  - Step 1: `startConversation()`이 하드코딩 인사 생성
  - Step 2: `sendMessage()`가 일반 프롬프트 + first-meet 규칙으로 Edge 호출
  - Step 3: follow-up/proactive 경로는 템플릿 원문을 거의 그대로 노출

## 3. WHERE
- Primary location: `lib/features/character/presentation/providers/character_chat_provider.dart:134`
- Related call sites:
  - `lib/features/character/presentation/providers/character_chat_provider.dart:651`
  - `lib/features/character/presentation/providers/character_chat_provider.dart:349`
  - `lib/features/character/data/default_characters.dart:127`
  - `lib/features/character/data/default_characters.dart:145`
  - `supabase/functions/character-chat/index.ts:532`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "_buildFirstMeetOpening|1응답 1질문|first_meet_v1" lib/ supabase/functions/`
  - `rg "followUpMessages|lunchProactiveConfig" lib/features/character/data/default_characters.dart`
  - `rg "RELATIONSHIP ADAPTATION|FIRST MEET MODE" supabase/functions/character-chat/index.ts`
- Findings:
  1. `character_chat_provider.dart` - first meet 시작/프롬프트 주입 지점 존재
  2. `default_characters.dart` - 러츠 follow-up/proactive 템플릿 존재
  3. `character-chat/index.ts` - 관계/첫만남 가이드 존재, 러츠 전용 출력가드 부재
  4. `character-follow-up/index.ts` - 서버 fallback 템플릿도 러츠 강한 반말 포함

## 5. HOW (Correct Pattern)
- Reference implementation: `supabase/functions/character-chat/index.ts:498` (관계 단계 기반 제약 프롬프트)
- Before:
```dart
// 캐릭터 페르소나 전체를 고정 톤으로 노출 + 채널별 톤 불일치
```
- After:
```dart
// 러츠 전용 톤 정책 유틸로 사용자 최근 발화를 분석
// 1) 말투 미러링 2) 애칭 게이트 3) 1버블 제약을 모든 채널에 동일 적용
```
- Why this fix is correct:
  - 사용자의 대화 맥락을 반영하여 자연스러운 응답을 유도
  - 출력 후처리로 길이/질문/중복을 강제해 품질 편차를 줄임
  - 실시간/후속/선톡을 동일 규칙으로 정렬해 경험 일관성 확보

## 6. Fix Plan
- Files to change:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 러츠 톤 정책 주입 및 채널 적용
  2. `lib/features/character/presentation/utils/luts_tone_policy.dart` - 신규 톤 정책 유틸
  3. `lib/features/character/data/default_characters.dart` - 러츠 템플릿 톤 정리
  4. `supabase/functions/character-chat/index.ts` - 러츠 전용 출력 가드 추가
  5. `supabase/functions/character-follow-up/index.ts` - 서버 fallback 러츠 템플릿 정렬
  6. `docs/development/character-chat/luts_kakao_style_v2.md` - 규칙 문서화
- Risk assessment:
  - 러츠 특유의 페르소나 강도가 낮아질 수 있음
  - 짧은 응답 강제로 정보량이 부족해질 수 있음
- Validation plan:
  - 정적 검사 + 단위 테스트 + 수동 시나리오(언어/말투/애칭/채널별)

# Discovery Report - Luts 카톡형 톤 개선

## 1. Goal
- Requested change:
  - 러츠(`luts`) 채팅의 반말 고정 시작 제거
  - 사용자 말투 미러링 + 애칭 게이트 + 카톡형 1버블 응답 적용
- Work type: Provider / Service / Model(utility) / Edge Function / Docs
- Scope:
  - 실시간 채팅 + follow-up + 점심 proactive + 서버 fallback

## 2. Search Strategy
- Keywords:
  - luts, first meet, tone, follow-up, proactive, character-chat
- Commands:
  - `rg "_buildFirstMeetOpening|first_meet_v1|1응답 1질문" lib/ supabase/functions/`
  - `rg "followUpMessages|lunchProactiveConfig" lib/features/character/data/default_characters.dart`
  - `rg "RELATIONSHIP ADAPTATION|FIRST MEET MODE" supabase/functions/character-chat/index.ts`
  - `rg "character-follow-up" supabase/functions/`

## 3. Similar Code Findings
- Reusable:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 채팅 생성/전송/후속 전체 진입점
  2. `supabase/functions/character-chat/index.ts` - 관계 단계 프롬프트 및 응답 후처리 파이프라인
  3. `lib/features/character/domain/models/behavior_pattern.dart` - follow-up/proactive 템플릿 구조
- Reference only:
  1. `supabase/functions/_shared/character_memory.ts` - PromptManager 기반 규칙성 주입 패턴
  2. `lib/features/chat/domain/services/intent_detector.dart` - 휴리스틱 분류 방식 참고

## 4. Reuse Decision
- Reuse as-is:
  - 기존 `characterChatProvider` 대화 수명주기/토큰/동기화 흐름
  - 기존 Edge 관계 단계 가이드 및 이모지 후처리
- Extend existing code:
  - 러츠 전용 스타일 가이드 프롬프트 주입
  - 러츠 전용 후처리(문장/질문/애칭 제한)
- New code required:
  - `luts_tone_policy.dart` (언어/말투/애칭 판별 + 텍스트 정규화)
- Duplicate prevention notes:
  - 러츠 전용 분기만 추가하고 공통 채팅 파이프라인은 유지

## 5. Planned Changes
- Files to edit:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart`
  2. `lib/features/character/data/default_characters.dart`
  3. `supabase/functions/character-chat/index.ts`
  4. `supabase/functions/character-follow-up/index.ts`
- Files to create:
  1. `lib/features/character/presentation/utils/luts_tone_policy.dart`
  2. `docs/development/character-chat/luts_kakao_style_v2.md`
  3. `test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - `deno check supabase/functions/character-chat/index.ts`
- Runtime checks:
  - 기존 러츠 대화방에서 즉시 반영 여부
  - follow-up/proactive 문구 톤 일관성
- Test cases:
  - 언어/격식 감지
  - 애칭 게이트
  - 1버블/질문 제한

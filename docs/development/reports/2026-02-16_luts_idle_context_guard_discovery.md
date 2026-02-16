# Discovery Report - Luts Idle Icebreaker Context Guard

## 1. Goal
- Requested change:
  - 대화가 막 진행된 맥락에서는 `지금 뭐 하고 계세요?`류 자동 질문이 나오지 않게 조정
  - `저는 인공지능이라` 같은 메타 문구 제거
- Work type: Provider / Utility / Test / Docs
- Scope: 러츠(`luts`) 채팅 톤 가드 및 읽음 아이스브레이커 정책

## 2. Search Strategy
- Keywords: `readIdle`, `icebreaker`, `sanitize`, `인공지능`, `서비스톤`
- Commands:
  - `rg "readIdle|icebreaker|_shouldScheduleReadIdleIcebreaker" lib/features/character/presentation/providers/character_chat_provider.dart`
  - `rg "_sanitizeServiceTone|인공지능|무엇을 도와드릴" lib/features/character/presentation/utils/luts_tone_policy.dart`
  - `rg "LutsTonePolicy read-idle icebreaker|서비스형 문구" test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`

## 3. Similar Code Findings
- Reusable:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 읽음 10초 타이머 및 발송 파이프라인 이미 존재
  2. `lib/features/character/presentation/utils/luts_tone_policy.dart` - 서비스톤 제거/1버블 정규화/의도 추론 유틸 존재
- Reference only:
  1. `docs/development/character-chat/luts_kakao_style_v2.md` - 정책 문서 기준점
  2. `test/unit/features/character/presentation/utils/luts_tone_policy_test.dart` - 톤 가드 테스트 패턴

## 4. Reuse Decision
- Reuse as-is:
  - 기존 아이스브레이커 타이머/중복 방지 구조
- Extend existing code:
  - 스케줄 조건에 "저신호 턴 + 초반 대화" 컨텍스트 가드 추가
  - 메타 문구 제거 정규식 확장
- New code required:
  - 질문형(물음표 없는 종결 포함) 보조 감지 헬퍼
- Duplicate prevention notes:
  - 새 타이머/새 경로 추가 없이 기존 경로의 조건만 강화

## 5. Planned Changes
- Files to edit:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart`
  2. `lib/features/character/presentation/utils/luts_tone_policy.dart`
  3. `test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`
  4. `docs/development/character-chat/luts_kakao_style_v2.md`
- Files to create:
  1. `docs/development/reports/2026-02-16_luts_idle_context_guard_rca.md`
  2. `docs/development/reports/2026-02-16_luts_idle_context_guard_discovery.md`
  3. `docs/development/reports/2026-02-16_luts_idle_context_guard_verify.md`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
- Runtime checks:
  - 러츠 대화에서 주제형 대화 직후 10초 재질문 미발송 확인
- Test cases:
  - AI 메타 문구 제거 단위 테스트

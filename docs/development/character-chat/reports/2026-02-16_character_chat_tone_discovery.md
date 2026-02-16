# Discovery Report - Multi Character Tone Engine

## 1. Goal
- Requested change:
  - 러츠 기준 카톡형 톤/후처리 엔진을 다캐릭터(러츠 제외 남캐 9명)에 확장하고 read/idle 안정화
- Work type:
  - Provider / Service / Model / Edge Function / Docs / Test
- Scope:
  - 실시간/Follow-up/점심 proactive/서버 fallback 전 채널

## 2. Search Strategy
- Keywords:
  - `LutsTonePolicy`, `read idle`, `follow-up`, `character-chat`, `unreadCount`, `RemoteConfig`
- Commands:
  - `rg "LutsTonePolicy|markPendingUserMessagesAsRead|read idle|unreadCount" lib/features/character`
  - `rg "FOLLOW_UP_TEMPLATES|character-follow-up" supabase/functions`
  - `rg "RemoteConfig|feature flag|allowlist|rollout" lib`
  - `rg --files lib/features/character/presentation/utils | rg "tone|policy"`

## 3. Similar Code Findings
- Reusable:
  1. `lib/features/character/presentation/utils/luts_tone_policy.dart` - 언어/격식/애칭/문장 수/질문 수 가드의 기준 구현
  2. `supabase/functions/character-chat/index.ts` - Luts 스타일 가드 + 후처리 파이프라인
  3. `lib/features/character/presentation/providers/character_chat_provider.dart` - 실시간/follow-up/proactive 경로 집중 진입점
  4. `lib/services/remote_config_service.dart` - 런타임 설정 주입 지점
- Reference only:
  1. `lib/features/character/domain/models/behavior_pattern.dart` - follow-up/proactive 템플릿 구조
  2. `lib/features/character/data/default_characters.dart` - 캐릭터별 문구 자산
  3. `supabase/functions/character-follow-up/index.ts` - 서버 fallback 템플릿 매핑

## 4. Reuse Decision
- Reuse as-is:
  - 기존 Luts 정책의 휴리스틱/후처리 로직
- Extend existing code:
  - Luts 전용 클래스를 공통 엔진으로 승격하고 보이스 프로필 레이어 추가
  - provider의 Luts 전용 분기를 allowlist+registry 분기로 일반화
- New code required:
  - `character_tone_policy.dart`
  - `character_voice_profile_registry.dart`
  - `character_tone_rollout.dart`
- Duplicate prevention notes:
  - 공통 규칙은 `character_tone_policy.dart`에 단일화
  - Luts 전용 문구/경계는 profile override로만 유지

## 5. Planned Changes
- Files to edit:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart`
  2. `lib/features/character/domain/models/character_chat_message.dart`
  3. `lib/services/remote_config_service.dart`
  4. `lib/features/character/data/default_characters.dart`
  5. `supabase/functions/character-chat/index.ts`
  6. `supabase/functions/character-follow-up/index.ts`
  7. `docs/development/character-chat/luts_kakao_style_v2.md`
- Files to create:
  1. `lib/features/character/presentation/utils/character_tone_policy.dart`
  2. `lib/features/character/presentation/utils/character_voice_profile_registry.dart`
  3. `lib/features/character/presentation/utils/character_tone_rollout.dart`
  4. `docs/development/character-chat/character_kakao_tone_engine_v1.md`
  5. `test/unit/features/character/presentation/utils/character_tone_policy_test.dart`

## 6. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
- Runtime checks:
  - 기존 러츠 채팅방 재진입 후 즉시 톤 적용
  - 파일럿 3명(정태윤/서윤재/한서준) read-idle 조건 검증
- Test cases:
  - 다국어/격식 미러링, 1버블/질문수 제한, 애칭 게이트, 읽음 처리 race, idle 맥락 가드

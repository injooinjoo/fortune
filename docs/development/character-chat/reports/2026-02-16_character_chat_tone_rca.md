# RCA Report - Character Chat Tone / Read / Continuity

## 1. Symptom
- Error message:
  - 없음 (행동/UX 버그)
- Repro steps:
  1. 러츠 채팅방에서 사용자 메시지를 연속으로 2개 이상 빠르게 전송
  2. 캐릭터 응답이 도착한 뒤에도 첫 번째 사용자 버블의 `1` 표시가 잔존하는 케이스 발생
  3. 대화가 이미 진행 중인데 read-idle 질문(`지금 뭐 하고 계세요?`)이 맥락 무시로 추가 전송
- Observed behavior:
  - 읽음 불일치(일부 sent 상태 잔존)
  - 문맥 불일치 질문으로 대화 흐름 단절
  - 캐릭터별 톤 품질 편차(러츠만 가드 강함)
- Expected behavior:
  - pending 사용자 메시지는 캐릭터 응답 직전에 항상 일괄 read 전환
  - read-idle 질문은 초기/저신호/무응답 상황에서만 제한 발송
  - 러츠 품질 가드가 대상 캐릭터에도 일관 적용

## 2. WHY (Root Cause)
- Direct cause:
  - 읽음 처리와 응답 생성이 여러 비동기 경로로 분기되어 상태 동기화 타이밍이 어긋남
  - read-idle 타이머가 "초기 저신호 상황"만으로 충분히 좁혀지지 않아 맥락 충돌
- Root cause:
  - 톤/후처리 정책이 러츠 전용(`LutsTonePolicy`)으로 고정되어 공통 엔진 부재
  - 메시지 모델에 메시지 출처(origin) 정보가 없어 proactive/follow-up/aiReply를 동일 앵커로 취급
  - `sendMessage` 연속 호출 직렬화 부재로 read ack와 응답 추가 사이 race 가능
- Data/control flow:
  - Step 1: `sendMessage`가 즉시 addUserMessage 후 비동기 read delay + API 호출 수행
  - Step 2: 동시 다발 전송/응답 경로에서 `markPendingUserMessagesAsRead` 이후 동기화 누락 가능
  - Step 3: read-idle 타이머가 진행 중 문맥에서도 trigger되어 불필요 질문 발생

## 3. WHERE
- Primary location:
  - `lib/features/character/presentation/providers/character_chat_provider.dart`
- Related call sites:
  - `lib/features/character/domain/models/character_chat_message.dart`
  - `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - `supabase/functions/character-chat/index.ts`
  - `supabase/functions/character-follow-up/index.ts`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "markPendingUserMessagesAsRead|read idle|LutsTonePolicy|unreadCount" lib/features/character`
  - `rg "LUTS_|STYLE GUARD|relationship" supabase/functions/character-chat/index.ts`
  - `rg "FOLLOW_UP_TEMPLATES" supabase/functions/character-follow-up/index.ts`
- Findings:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 읽음/idle/tone 로직이 단일 파일에 혼재
  2. `lib/features/character/domain/models/character_chat_message.dart` - origin 구분 부재
  3. `supabase/functions/character-chat/index.ts` - 러츠 전용 가드 상수/함수 다수
  4. `supabase/functions/character-follow-up/index.ts` - 캐릭터별 fallback 템플릿 품질 편차

## 5. HOW (Correct Pattern)
- Reference implementation:
  - `lib/features/character/presentation/utils/luts_tone_policy.dart`
- Before:
```dart
// 러츠 전용 분기 + 공통 캐릭터 미적용
bool get _isLutsCharacter => LutsTonePolicy.isLuts(_characterId);
```
- After:
```dart
// allowlist + 보이스 프로필 기반 공통 정책
bool get _isTonePolicyEnabledCharacter => CharacterToneRollout.isEnabledCharacter(
  _characterId,
  remoteConfig: _ref.read(remoteConfigProvider),
);
```
- Why this fix is correct:
  - 정책 엔진/보이스 프로필/롤아웃을 분리해 캐릭터 확장성과 안정성을 동시에 확보
  - 메시지 origin + strict idle 조건 + send queue로 race/맥락 충돌을 구조적으로 축소

## 6. Fix Plan
- Files to change:
  1. `lib/features/character/presentation/providers/character_chat_provider.dart` - 공통 엔진 적용, read/idle 상태머신 보강
  2. `lib/features/character/presentation/utils/character_tone_policy.dart` - 공통 톤 엔진 추가
  3. `lib/features/character/presentation/utils/character_voice_profile_registry.dart` - 캐릭터별 보이스 프로필 정의
  4. `lib/features/character/presentation/utils/character_tone_rollout.dart` - Remote Config allowlist 연동
  5. `lib/features/character/domain/models/character_chat_message.dart` - `MessageOrigin` 추가
  6. `lib/services/remote_config_service.dart` - `character_tone_rollout_v1` 파싱 추가
  7. `supabase/functions/character-chat/index.ts` - 스타일 가드 공통화
  8. `supabase/functions/character-follow-up/index.ts` - fallback 템플릿 정합화
  9. `lib/features/character/data/default_characters.dart` - follow-up/점심 문구 정규화
  10. `test/unit/features/character/presentation/utils/character_tone_policy_test.dart` - 공통 엔진 테스트
- Risk assessment:
  - provider/edge 변경 폭이 커 회귀 가능성 존재
  - 톤 변화로 캐릭터 개성 저하 위험 → 보이스 프로필 분화로 완화
- Validation plan:
  - `flutter analyze`
  - `dart format --set-exit-if-changed .`
  - `flutter test`
  - `deno check supabase/functions/character-chat/index.ts`
  - `deno check supabase/functions/character-follow-up/index.ts`

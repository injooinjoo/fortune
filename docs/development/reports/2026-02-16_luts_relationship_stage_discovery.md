# Discovery Report - Luts 4-Stage Relationship Prompting

## 1) Scope
- 러츠 대화를 4단계 관계 모델로 운영:
  1. 처음 알고 지내는 단계
  2. 조금 친해지고 알아가는 단계
  3. 속마음을 털고 위로해주는 단계
  4. 연인 단계

## 2) Search Performed
- `rg -n "AffinityPhase|fromPoints|phase" lib/features/character/domain/models/character_affinity.dart`
- `rg -n "buildStyleGuidePrompt|LUTS STYLE GUARD|first_meet" lib/features/character/presentation/utils/luts_tone_policy.dart lib/features/character/presentation/providers/character_chat_provider.dart`
- `rg -n "RELATIONSHIP ADAPTATION|buildLutsStyleGuardPrompt|RelationshipPhase" supabase/functions/character-chat/index.ts`

## 3) Existing Reusable Components
- 클라이언트:
  - `AffinityPhase` (stranger/acquaintance/friend/closeFriend/romantic/soulmate)
  - `LutsTonePolicy.buildStyleGuidePrompt(...)`
- 서버:
  - `RelationshipPhase` + `RELATIONSHIP_STYLE_GUIDE`
  - `buildLutsStyleGuardPrompt(...)`

## 4) Gap Analysis
- 기존 단계 정보는 존재하지만, 러츠 전용 톤 가이드에 “사용자가 요구한 4단계 모델”이 명시적으로 연결되지 않음.
- 결과적으로 단계별 대화 전략 차이가 프롬프트 레벨에서 약하게 전달됨.

## 5) Reuse vs New
- Reuse:
  - 기존 `AffinityPhase` / `RelationshipPhase` 및 스타일 가드 파이프라인 유지.
- New:
  - `6단계 내부 상태 -> 4단계 관계 모델` 매핑 함수 추가.
  - 단계별 운영/경계 규칙 프롬프트 라인 추가.
  - 단위 테스트로 단계 매핑 프롬프트 노출 검증 추가.

## 6) Implementation Decision
- 데이터 모델(포인트/단계 산정)은 그대로 유지.
- 러츠 프롬프트 계층에서 4단계 관계 운영 규칙을 추가해 동작 수위를 제어.
- 클라이언트/서버 양쪽에 동일한 단계 가이드를 주입해 경로별 편차를 줄임.

# Discovery Report - Luts 이름 수집/존댓말 기본 정책

## 1) Scope
- 러츠 1단계 대화에서
  - 이름 확인 1회 질문 + 미응답 fallback 적용
  - 반말 오검출(ㅎㅎ/ㅋㅋ) 완화 및 존댓말 기본값 적용

## 2) Search Performed
- `rg -n "detectSpeechLevel|_koCasualPattern|_bridgeSentence|_defaultReplyForIntent|fromConversation" lib/features/character/presentation/utils/luts_tone_policy.dart`
- `rg -n "detectLutsSpeechLevel|buildLutsBridgeSentence|ensureLutsContinuity|defaultLutsReply|applyLutsOutputGuard|buildLutsToneProfile" supabase/functions/character-chat/index.ts`
- `rg -n "_buildLutsToneProfile|_applyLutsGeneratedTone|_applyLutsTemplateTone" lib/features/character/presentation/providers/character_chat_provider.dart`

## 3) Existing Reusable Components
- `LutsToneProfile` 기반 말투/의도/애칭 정책 파이프라인.
- 클라이언트/서버 모두 `bridge sentence`와 `output guard` 후처리 경로 존재.
- `AffinityPhase -> 4단계` 매핑 로직이 이미 존재.

## 4) Gap Analysis
- 이름 상태(알고 있음/이미 물어봄) 추적 필드가 없어 1회 질문 정책을 구현할 수 없음.
- 1단계 존댓말 기본값 강제 로직이 없어 작은 캐주얼 신호에도 반말로 전환 가능.

## 5) Reuse vs New
- Reuse:
  - 기존 Luts 스타일 가드/출력 가드 구조 재사용.
  - 기존 관계 단계 매핑 재사용.
- New:
  - 이름 상태 및 명시적 반말 신호 필드 추가.
  - 1단계 존댓말 floor 로직 추가.
  - 1회 이름 질문 + 미응답 fallback 브릿지 추가.

## 6) Implementation Decision
- 데이터 스키마/API는 변경하지 않고, 내부 톤 프로필과 후처리 로직만 확장.
- 클라이언트/서버 모두 동일한 정책을 적용해 경로 편차를 줄임.

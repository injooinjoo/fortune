# Verify Report - Luts 이름/존댓말 초기 단계 정책

## 1. Change Summary
- What changed:
  - `ㅎㅎ/ㅋㅋ` 단독 신호로 반말 전환되지 않도록 말투 감지 규칙 보정.
  - 1단계(gettingToKnow)에서 명시적 반말 신호가 없으면 존댓말을 기본 유지.
  - 이름 상태(`nameKnown`, `nameAsked`) 추적 추가.
  - 이름 미확인 시 초반 1회 질문, 미응답 시 재질문 없이 중립 진행 로직 추가.
  - 클라이언트/서버 스타일 가드 및 출력 가드에 동일 정책 반영.
- Why changed:
  - 초반 대화에서 반말 전환과 어색한 연결 문장을 줄이고, 소개팅형 자연스러운 흐름을 만들기 위함.

## 2. Static Validation
- `flutter analyze`
  - Result: failed
  - Notes: 레포 기존 베이스라인 78건 이슈로 실패 (이번 변경 신규 이슈 아님).
- `flutter analyze lib/features/character/presentation/utils/luts_tone_policy.dart lib/features/character/presentation/providers/character_chat_provider.dart test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`
  - Result: passed
- `dart format --set-exit-if-changed .`
  - Result: passed

## 3. Tests and QA
- `flutter test test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`
  - Result: passed
  - Added coverage:
    - `ㅎㅎ` 단독 신호가 casual로 오검출되지 않음
    - 1단계 이름 미확인 시 1회 이름 질문
    - 이름 질문 이후 재질문 방지
- `flutter test`
  - Result: passed (`All tests passed!`)
- `deno check /Users/jacobmac/Desktop/Dev/fortune/supabase/functions/character-chat/index.ts`
  - Result: failed
  - Notes: `_shared` 베이스라인 타입 오류 6건 (기존 동일).

## 4. Manual Scenarios
1. 초기 대화에서 `반가워요 ㅎㅎ` 입력 시 러츠가 반말(`뭐야`)로 전환하지 않는지 확인.
2. 이름이 없는 사용자에서 초반 1회 `어떻게 불러드리면 될까요` 계열 질문이 나오는지 확인.
3. 이름 미응답 상태에서 다음 턴에 같은 질문을 반복하지 않는지 확인.
4. 사용자가 명시적 반말(`안녕 뭐해?`)을 쓰면 그때 반말 미러링이 가능한지 확인.

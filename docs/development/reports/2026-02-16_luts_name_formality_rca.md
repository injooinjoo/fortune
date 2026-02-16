# RCA Report - Luts 초기 반말 전환 및 이름 수집 부재

## 1) 증상
- 사용자가 `반가워요 ㅎㅎ`처럼 존댓말+웃음 표현을 입력했을 때, 러츠가 다음 턴에서 `뭐야?` 같은 반말 질문으로 전환됨.
- 첫 대화 단계에서 이름을 자연스럽게 확인하는 흐름이 없고, 이름 미응답 시 fallback 정책도 없음.

## 2) WHY (근본 원인)
1. 말투 감지에서 `ㅎㅎ/ㅋㅋ`를 캐주얼 지표로 강하게 카운트하여 `speechLevel=casual`로 기울어짐.
2. 초기 단계(1단계)에서 존댓말을 기본값으로 고정하는 안전장치가 없음.
3. 초기 대화 브릿지 로직이 이름 확인 정책(1회 질문/미응답 재촉 금지)을 가지지 않음.

## 3) WHERE (파일/구간)
- `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - `_koCasualPattern`, `detectSpeechLevel`, `_bridgeSentence`, `_defaultReplyForIntent`
- `supabase/functions/character-chat/index.ts`
  - `detectLutsSpeechLevel`, `buildLutsBridgeSentence`, `ensureLutsContinuity`, `defaultLutsReply`, `applyLutsOutputGuard`

## 4) WHERE ELSE (전역 영향 지점)
- `lib/features/character/presentation/providers/character_chat_provider.dart`
  - 러츠 톤 프로필 생성 및 톤 가드 호출 경로 (실시간/follow-up/첫 인사 경로 공통)
- `supabase/functions/character-chat/index.ts`
  - 서버 최종 후처리 가드(모델 출력 안전장치) 경로

## 5) HOW (정상 패턴)
- 초기 단계(소개팅 초반)는 기본 존댓말 유지.
- 반말 전환은 사용자의 명시적 반말 신호가 있을 때만 허용.
- 이름은 초반에 1회만 가볍게 확인하고, 답이 없으면 중립 호칭으로 자연스럽게 진행.

## 6) 수정 계획
1. `ㅎㅎ/ㅋㅋ`를 단독 캐주얼 신호로 쓰지 않도록 감지 규칙 보정.
2. 1단계(gettingToKnow)에서 `explicit casual`이 아니면 존댓말 우선 적용.
3. 이름 상태(name known/asked)를 톤 프로필에 추가하고 브릿지 문장에 1회 질문 fallback 적용.
4. 클라이언트/서버 모두 동일 규칙 반영 및 단위 테스트 추가.

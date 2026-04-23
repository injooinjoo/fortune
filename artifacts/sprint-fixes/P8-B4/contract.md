# P8 / B4 — Edge Function body.userId 신뢰 제거

## 문제
1. `supabase/functions/fortune-tarot/index.ts:419-427` — `userId`를 `body.userId || body.user_id || body.answers?.userId || body.answers?.user_id || 'anonymous'` 폴백 체인에서 파생. 임의 userId 주입 가능 → UsageLogger.log의 user_id 위조 (토큰 사용량 오귀속)
2. `supabase/functions/widget-cache/index.ts:49` — `.eq('user_id', userId)` 로 타인 위젯 fortune 캐시 읽기 가능 → **실 PII 유출 (overall_score, lotto numbers, lucky items, messages)**
3. `supabase/functions/fortune-birthstone/index.ts:258` — `userId: body.userId ?? null` 사용 (중간 위험)

## 대상 범위 (이 스프린트)
- **CRITICAL**: `widget-cache` — JWT 필수 (guest 허용 불가)
- **HIGH**: `fortune-tarot` — JWT 있으면 user.id, 없으면 'anonymous' (guest 보존)
- **HIGH**: `fortune-birthstone` — 동일 패턴

## 비수용 범위 (후속 스프린트)
- fortune-talent/wealth/investment/blind-date/avoid-people 등 cache-key 사용 — 별도 sweep (low PII risk, 입력 조합 의존)
- `fortune-past-life`, `fortune-yearly-encounter`, `speech-to-text` LLMFactory 우회 — P9+ (W4)

## 수용 기준
1. `_shared/auth.ts`에 `deriveUserIdFromJwt(req): Promise<string | null>` 유틸 추가 — JWT 유효 시 user.id, 그 외 null
2. fortune-tarot: `deriveUserIdFromJwt(req)` 결과 || 'anonymous' 사용. **body.userId 등 참조 전량 제거**
3. fortune-birthstone: 동일 패턴 (`body.userId ?? null` → `await deriveUserIdFromJwt(req)`)
4. widget-cache: `authenticateUser(req)` 사용 — JWT 없거나 유효하지 않으면 401. body에서 userId 읽지 않음. 필터는 `user.id` 고정.
5. RN 클라이언트: 변경 불필요 (`supabase.functions.invoke`가 JWT 자동 첨부 + body에 userId 넘겨도 무시되지만 regression은 아님)
6. Deno check 통과
7. 타 로직 변경 금지

## Quality Gate
- [ ] `deno check` 통과 (각 함수)
- [ ] Reviewer PASS (authenticateUser pattern 올바름)
- [ ] 보안 domain: impersonation / spoof 재발 가능성 0 확인

## RCA 요약
- WHY: 개발 초기 prototype에서 body.userId를 "로그인 안 된 유저도 fortune 쓸 수 있게" 라는 의도로 폴백 추가 → 이후 인증 도입됐으나 body 파스 코드 미수정
- WHERE ELSE: 위 3개 + cache-key 6개 (후속)
- HOW: Supabase Edge Function에서 user 파생은 JWT만 신뢰. `_shared/auth.ts::authenticateUser`가 이미 존재하는 레퍼런스 패턴.

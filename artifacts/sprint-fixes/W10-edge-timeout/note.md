# W10 — Edge Runtime 타임아웃 + Chat Retry UI

## 완료 (Part 1)
`apps/mobile-rn/src/features/chat-results/edge-runtime.ts`에 `AbortController` + 35s 타임아웃 추가. 오프라인/hanging 응답 시 "edge-runtime timeout (35s)" 에러로 전환 — 무한 스피너 방지.

## 후속 (Part 2, 별도 스프린트)
**에러 버블 + 재시도 UI**. 현재 Fortune 생성 실패(네트워크/타임아웃) 시 클라이언트 UX:
- 에러 throw → 상위 호출자가 console.warn 후 silent
- 유저에게 "실패" 표시 없음, 재시도 버튼 없음

### 권장 구현
1. `ChatShellMessage` discriminated union에 `kind: 'error-retry'` 추가
2. 메시지 payload: `{ kind, attemptedFortuneType, errorReason, onRetry: () => void }`
3. `chat-surface.tsx` `ChatThreadMessage` 분기에 error-retry 카드 추가
4. edge-runtime catch 블록에서 error-retry 메시지 enqueue
5. 재시도 버튼 → 동일 body 로 `runFortuneViaEdge` 재호출

### 영향 범위
- chat-shell.ts (타입 추가)
- chat-surface.tsx (렌더)
- chat-results/edge-runtime.ts (error surface)
- 기존 fortune runner 호출자 (story-chat-runtime.ts 등)

### 리젝 리스크
W10 단독: 심사 리뷰어가 네트워크 끊고 fortune 요청 시 무한 로딩 재현 가능. 리젝 가능성 **중간**. Part 2 가 필요한 엣지 케이스.

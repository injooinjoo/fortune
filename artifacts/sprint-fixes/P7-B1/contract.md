# P7 / B1 — iPad Sign-in 콜드스타트 레이스 (최우선 리젝 방지)

## 문제
`apps/mobile-rn/src/providers/app-bootstrap-provider.tsx` useEffect에서 `Linking.addEventListener('url', …)` 부착이 `void bootstrap()` 뒤(355줄)에 위치. 이론상 `void bootstrap()`은 fire-and-forget 이라 동기적으로 제어권이 반환돼 355줄에서 리스너가 같은 JS tick에 부착되지만, iPad Sign in with Apple에서 **이전 리젝 사유와 동일 카테고리**이므로 방어적 순서 재조정 필수.

이전 리젝 (2.1): iPad에서 native Apple Sign-In이 OAuth fallback으로 전환될 때 콜백 URL이 cold-start 경로로 들어오면서 listener 부착 전에 이벤트 발생 → silent drop.

## 수용 기준
1. `Linking.addEventListener('url', ...)` 를 `useEffect` 내 **가장 먼저** 부착 (어떤 async 호출보다도 전)
2. listener의 콜백은 기존 동작과 동일 (isAuthCallbackUrl → exchangeAuthCodeFromUrl → handleDeepLink)
3. 함수 선언 (`handleDeepLink`, `applyDebugChatOverride`, `syncProgress`, `bootstrap`) 위치는 그대로 두되 hoisting으로 리스너 콜백에서 참조 가능
4. `trackEvent('app_open')`, `void bootstrap()`, `authSubscription`, `removePushHandlers` 등 기존 setup은 리스너 부착 후 그대로
5. cleanup(`return () => { ... }`)에서 `linkSubscription.remove()` 호출 위치 유지
6. tsc 0 errors
7. `bootstrap()` 내부의 `getInitialURL()` 및 `handleDeepLink(initialUrl)` (269줄) 동작 변경 금지 — cold-start 초기 URL 처리 경로 그대로

## 비수용 기준
- bootstrap 로직 재작성 금지
- deep link 라우팅 규칙 변경 금지
- social-auth / Apple Sign-In 플로우 변경 금지
- `_layout.tsx`에 별도 listener 추가 금지 (provider 단일 소스)

## Quality Gate
- [ ] tsc --noEmit 0 errors
- [ ] Reviewer PASS (race 분석 자세히)
- [ ] iOS Domain: Apple Sign-In iPad 시나리오 재현 불가 확인
- [ ] cold-start / background-foreground / 앱 종료 상태 deep link 모두 커버 확인

## RCA required: yes
## Discovery required: no (단일 파일 재배치)

## 회귀 테스트 시나리오 (리뷰어 수동)
1. iPad에서 앱 설치/최초 실행 → Sign in with Apple 탭 → OAuth fallback 발생 → 로그인 완료 확인
2. iPhone에서 앱 종료 상태 → OAuth 콜백 URL(deep link) 수신 → 올바른 라우트 이동
3. 앱 백그라운드 상태에서 OAuth 콜백 수신 → 로그인 상태 갱신
4. 일반 내부 deep link (`com.beyond.fortune://chat?characterId=...`) → 채팅 진입

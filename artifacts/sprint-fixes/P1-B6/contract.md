# P1 / B6 — Splash `FORCE_WELCOME_FOR_DEV` 제거

## 문제
`apps/mobile-rn/src/screens/splash-screen.tsx:13`의 `FORCE_WELCOME_FOR_DEV = true`가 프로덕션으로 나가면 리뷰어가 **매 콜드스타트마다 7-scene welcome carousel 강제 통과**. App Store 리젝 위험(4.0 Design / reviewer 체험).

## 수용 기준
1. 프로덕션 빌드에서 콜드스타트 시 welcome carousel이 welcome-seen=false일 때만 노출되는 정상 gate 로직 복원
2. `FORCE_WELCOME_FOR_DEV` 상수 + 관련 dead branch 제거 (CLAUDE.md: feature flag/호환 shim 금지)
3. 기존 `readWelcomeSeen()` → `gate === 'auth-entry'` → `/welcome` or `/signup` 분기 보존
4. `gate === 'profile-flow'` → `/onboarding`, 기본 `/chat` 경로 보존
5. TypeScript `tsc --noEmit` 0 errors
6. 로그인 안 한 신규 유저 플로우 정상

## 비수용 기준 (밖의 것 금지)
- 테마/색상 토큰 마이그레이션은 이 phase 밖 (B8에서 처리)
- welcome carousel 콘텐츠 수정 금지
- AppText 마이그레이션 금지 (별도 리팩토링)

## Quality Gate
- [ ] `tsc --noEmit` pass
- [ ] Reviewer (codex) PASS
- [ ] iOS Domain: 4.0/2.1 review-path 저해 없음 확인

## RCA required: no (단순 플래그 제거)
## Discovery required: no (스코프 명확, 1 파일)

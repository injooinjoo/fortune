# P2 / B7 — App Store 리뷰어 이메일 화이트리스트 추가

## 문제
`apps/mobile-rn/src/lib/test-accounts.ts:2`의 `TEST_ACCOUNT_EMAILS`에 `ink595@g.harvard.edu` 하나만. 직전 리뷰 응답서(`APP_STORE_REVIEW_NOTE.md:18-19`)는 `test@zpzg.com`을 review test account로 제시. 이 계정이 화이트리스트에 없어 리뷰어가 프로필 화면의 "앱 초기화 (Factory Reset)" 도구를 못 써 재테스트를 못 함.

## 수용 기준
1. `'test@zpzg.com'` (lowercase)을 `TEST_ACCOUNT_EMAILS`에 추가
2. 기존 `'ink595@g.harvard.edu'` 엔트리 유지
3. 정렬은 알파벳 순 (가독성)
4. `tsc --noEmit` 0 errors
5. `isTestAccount` 게이트는 Factory Reset 카드(`profile-screen.tsx:781-794`)만 노출 — 리뷰어에게 합법적 도구

## 비수용 기준
- 새 이메일 추가 외 다른 변경 금지
- Factory Reset 로직 수정 금지

## Quality Gate
- [ ] tsc --noEmit pass
- [ ] Reviewer PASS
- [ ] 추가된 이메일이 APP_STORE_REVIEW_NOTE.md와 일치 확인

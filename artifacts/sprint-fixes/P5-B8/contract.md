# P5 / B8 — userInterfaceStyle 다크 전용으로 고정

## 문제
`apps/mobile-rn/app.config.ts:93`의 `userInterfaceStyle: 'automatic'`은 iOS에 "시스템 라이트/다크 설정을 따름"이라 선언. 실제로는:
- `apps/mobile-rn/src/lib/theme.ts:4` `createFortuneTheme('dark')` 하드코딩
- `apps/mobile-rn/app/_layout.tsx:55` `navigationTheme` = `DarkTheme` 고정
- `apps/mobile-rn/app/_layout.tsx:62` `<StatusBar style="light" />` 고정

→ manifest ↔ 실제 동작 불일치. 4.5/HIG 위반 리스크. 리뷰어가 라이트 모드로 시스템 전환 후 테스트 시 검은 배경에 검은 텍스트 등 contrast 이슈 가능성.

## 결정
**다크 전용으로 manifest 일치화** (옵션 A). 실제 light/dark 분기 구현(옵션 B)은 319개 하드코딩 hex 마이그레이션 + light 토큰 팔레트 필요 → 별도 리팩토링 스프린트. Ondo 브랜드는 "36.5°C 온기가 도는 검정" 정체성상 다크 고정이 의도.

## 수용 기준
1. `app.config.ts:93` `userInterfaceStyle: 'automatic'` → `'dark'`
2. prebuild 재생성 시 Info.plist `UIUserInterfaceStyle` = `Dark` (현재 `Automatic`)
3. `theme.ts`, `_layout.tsx`, StatusBar 코드 변경 금지
4. tsc 0 errors
5. 유저가 iOS 라이트 모드여도 앱은 다크로 일관 표시

## 비수용 기준
- light mode 대응 코드 추가 금지 (리팩토링 스프린트 밖)
- 디자인 토큰 변경 금지
- 테마 훅 도입 금지

## Quality Gate
- [ ] tsc --noEmit
- [ ] Reviewer PASS (HIG 4.5 부합 확인)
- [ ] iOS Domain: 라이트/다크 스위치 시나리오에서 contrast 이슈 없음 확인

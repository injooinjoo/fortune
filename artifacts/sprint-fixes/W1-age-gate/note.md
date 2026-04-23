# W1 — 연령 게이트 + 서버 tier clamp

## 완료 (Client 연령 게이트)
`apps/mobile-rn/app/onboarding/birth.tsx` 에서 `MIN_AGE_YEARS = 14` 미만 입력 시 Alert + 온보딩 차단. 한국 정보통신망법 14세 기준 + Apple 12+ 등급 + 로맨스 페르소나 대화 기능 고려.

## 후속 (서버측 Content Tier Clamp)
audit 03-ai-content-safety.md D 항목: "클라이언트가 `maxContentTier` 를 제어 → 서버측 검증 없음" 해결 안 됨.

`supabase/functions/character-chat/index.ts:764-766` 의 `CONTENT_TIER_GUIDE.t4_intimate` ("스킨십 암시") 가 사용자 요청만으로 unlock 됨. 악의적 클라이언트가 `maxContentTier: 't4_intimate'` 강제 전송 가능.

### 권장 구현
1. `user_profiles` 또는 `user_saju` 에 `age_years` (계산된 값) 저장
2. character-chat 에서 `deriveUserIdFromJwt(req)` → user.id → DB 조회 → 실제 연령 확인
3. 연령 기반 서버측 tier ceiling:
   - `age < 14` : 아예 차단 (연령 게이트 우회 방지)
   - `14 <= age < 18` : `maxContentTier` 를 `t3_romantic` 으로 clamp (스킨십 암시 차단)
   - `age >= 18` : 클라 요청 그대로 허용

### 영향 범위
- supabase/migrations/ 신규 (age_years 컬럼 또는 view)
- character-chat/index.ts: clamp 로직 삽입
- 기존 유저 데이터 백필 (birthDate 에서 age 계산)

### 리젝 리스크
- **W1 완료 (client 연령 게이트)**: 온보딩 차단으로 Apple 리뷰어가 under-14 테스트 계정 만들 수 없음. 기본 준수.
- **W1 Part 2 (서버 clamp) 미완료**: jailbroken client + 연령 위조 가능. Apple 은 이 수준 검증 안 하는 경우가 일반적. 위험도 **낮음~중간**.

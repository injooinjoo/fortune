# P9 / B3 — Kakao OAuth 계정 탈취 차단

## 문제
`supabase/functions/kakao-oauth/index.ts:56-128`가 public endpoint(`supabase/config.toml` `verify_jwt=false`)에서:
1. request body로부터 `access_token`, `user_info.{id,email,nickname}` 수령
2. **access_token을 카카오에 검증하지 않음**
3. body.user_info.email을 그대로 Supabase `auth.admin.createUser`/`generateLink`로 전달
→ 공격자가 `{access_token:"anything", user_info:{email:"victim@example.com"}}` POST하면 victim 계정 세션 탈취 가능

RN 앱은 이 엔드포인트를 호출하지 않지만 legacy Flutter 클라이언트 및 외부 공격 노출. Supabase DB에 존재하는 kakao-linked 계정 전체 위험.

## 수용 기준
1. body에서 `access_token`만 읽고 `user_info`는 무시 (또는 존재 여부만 ignore)
2. `fetchKakaoUser(accessToken)` 함수 추가 — `https://kapi.kakao.com/v2/user/me`에 `Authorization: Bearer <access_token>` 호출
3. Kakao 응답이 200 아니면 401 반환
4. Kakao 응답에서 **server-verified** 정보만 사용:
   - `id` (number → string)
   - `kakao_account.email` (옵셔널, 없으면 `kakao_${id}@kakao.local` fallback 유지)
   - `kakao_account.profile.nickname` or `properties.nickname`
   - `kakao_account.profile.profile_image_url` or `properties.profile_image`
5. Supabase upsert/session 생성 로직은 기존 재사용
6. 정상 케이스 기능 동작 그대로 (legacy Flutter 호환)
7. 에러 메시지는 클라이언트에 원인 leak 하지 말 것 (일반화된 "카카오 인증 실패")
8. Sentry/로그에는 상세 남김

## 비수용 기준
- Supabase 세션 생성 로직 구조 변경 금지 (magicLink + verifyOtp 패턴 유지)
- `verify_jwt` 설정 변경 금지 (public endpoint는 유지 — 로그인 전이라 JWT 없음)
- user_profiles 테이블 스키마 변경 금지
- RN client 변경 없음 (호출하지도 않음)

## Quality Gate
- [ ] Reviewer PASS (security + regression)
- [ ] 카카오 API 응답 schema 매핑 정확성
- [ ] impersonation 재현 불가 확인

## RCA
- WHY: 초기 구현이 RN/Flutter 공용 "토큰 + 사용자 정보를 client가 전달하는 단순 프로토콜" 로 설계됨. 보안 검증 누락.
- WHERE: `kakao-oauth/index.ts:56-128`.
- WHERE ELSE: naver-oauth는 이미 검증함 (레퍼런스).
- HOW: Resource owner token validation — 토큰으로 provider API 호출해 사용자 identity 재확인 후 그 결과만 신뢰.

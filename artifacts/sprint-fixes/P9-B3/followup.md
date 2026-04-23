# P9-B3 후속 조치 (별도 티켓)

이 스프린트 범위 밖. iOS 심사와 무관하되 배포 전 정리 권고.

## FU1. kakao_id / naver_id 스왑 공격 (중간 심각도)

**시나리오**: 두 Kakao 계정이 동일 이메일(verified)을 공유할 때, 두 번째 로그인이 기존 `user_metadata.kakao_id`를 덮어쓰며 상대 계정 세션에 접근.

**대상 파일**:
- `supabase/functions/kakao-oauth/index.ts:140` 근방 `updateUserById`
- `supabase/functions/naver-oauth/index.ts:234` 근방 (동일 패턴)

**Fix**: 기존 user_metadata의 kakao_id/naver_id가 Kakao/Naver가 현재 반환한 id와 다르면 409 Conflict로 거절.

```ts
if (existingUser.user_metadata?.kakao_id && existingUser.user_metadata.kakao_id !== kakaoUser.id) {
  return new Response(
    JSON.stringify({ error: '다른 카카오 계정으로 이미 연결되어 있어요.' }),
    { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}
```

## FU2. Public edge function rate limiting

`kakao-oauth`, `naver-oauth`는 `verify_jwt=false` public endpoint. 공격자가 Kakao/Naver API에 request 증폭 가능.

**Fix 옵션**:
- Supabase `rate_limit` 설정 (config.toml)
- Upstash Redis 기반 per-IP 카운터 (shared/rate-limit.ts 신설)

## FU3. LLMFactory 우회 4건 (W4 원본)

- `supabase/functions/fortune-past-life/index.ts:2181`
- `supabase/functions/fortune-yearly-encounter/index.ts:584,693`
- `supabase/functions/speech-to-text/index.ts:57`
- `supabase/functions/generate-talisman/index.ts:230`

`generativelanguage.googleapis.com` / `new OpenAIProvider()` 직접 호출 → `LLMFactory.createFromConfig(...)`로 통합.

## FU4. cache-key body.userId sweep (P8 후속)

- `fortune-talent`, `fortune-wealth`, `fortune-investment`, `fortune-blind-date`, `fortune-avoid-people`, `fortune-daily`
- 모두 `${userId || 'anonymous'}_...` 캐시 키 패턴. Cross-user cache poisoning 저위험.
- `deriveUserIdFromJwt(req)`로 교체.

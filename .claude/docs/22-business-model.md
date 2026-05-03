# 비즈니스 모델 가이드 (BM v2.2)

> 최종 업데이트: 2026.05.03

## 개요

Ondo 앱의 수익화 모델을 정의한 문서입니다. **모든 AI 기능은 토큰을 소비합니다.** 단, 채팅은 **LLM 호출당 1 토큰** (5초 idle 윈도우 내 배칭됨), Free 사용자는 **streak 기반 일일 메시지 한도** 제공.

---

## 1. 통화 체계 (단일 토큰)

| 토큰 | 용도 |
|---|---|
| 1 | 채팅 1턴 (배칭됨), daily, lucky 시리즈, MBTI 등 light 운세 |
| 5 | 타로/궁합/연애/관상/손금 등 mid 운세 (vision input 포함) |
| 12 | 사주/talent/timeline/network 등 heavy (장문 6K+ 출력) |
| 25 | 부적/새해/사업운/투자 — premium (이미지 1장 OR 헤비 보고서) |
| 50 | 전생/이상형/yearly — ultra (이미지 + 장문 통합) |

원가 기반 책정. gemini-2.5-flash-image 출력 가격 $30/1M = 이미지 1장 ~₩52 → 25~50 토큰으로 마진 95%+ 확보.

상세 매핑은 `supabase/functions/_shared/types.ts` 의 `FORTUNE_POINT_COSTS`.

---

## 2. 구독 (4 티어)

| 플랜 | 가격(KRW) | 보너스토큰/월 | 일일 채팅 한도 | 추가 혜택 |
|---|---:|---:|---:|---|
| **Free** | 0 | 매일 streak grant + 광고 1회당 1토큰 | streak: 30/100/200/400 | 광고 노출 |
| **Lite** | ₩4,400 | 200 | 무제한 (구독자) | 광고 제거 |
| **Pro** ⭐ | ₩9,900 | 500 | 무제한 | + 캐릭터 무제한, 메모리 확장 |
| **Max** | ₩19,000 | 2,000 | 무제한 | + 음성 무제한, 우선응답, TTS 보너스 |

연간: 월 × 10 (~17% 할인). Apple Small Business Program 시 수수료 15%.

**구독자 단위경제 (1K DAU, 광고 제외)**:

| 플랜 | 매출 (실수령) | 평균 LLM 비용/월 | 마진 |
|---|---:|---:|---:|
| Lite ₩3,749 | 200 토큰 ≈ 200 호출 ₩226 | 94% |
| Pro ₩7,574 | 500 호출 ₩565 | 93% |
| Max ₩15,224 | 2,000 호출 ₩2,260 | 85% |

---

## 3. Free 사용자 — Streak 일일 채팅 한도

```
Day 1 (가입/끊김 후 첫 로그인): 30 메시지/일
Day 2 연속:  100 메시지/일
Day 3 연속:  200 메시지/일
Day 4+ 연속: 400 메시지/일
연속 끊기면 Day 1 (30) 으로 리셋.
```

DB: `user_chat_streak` 테이블 + `consume_chat_streak(user_id)` RPC.

**손익**: 1K DAU 기준 광고 매출 +₩636K vs LLM 비용 ₩94K = **+₩542K 흑자**. 실측 헤비 유저도 일 9~20 메시지로 한도 도달 거의 없음 — retention hook 으로 작동.

---

## 4. 토큰 패키지 (단건 결제)

| 패키지 | 가격 | 토큰 | ₩/토큰 |
|---|---:|---:|---:|
| Starter | ₩1,100 | 30 | 37 |
| Basic | ₩4,400 | 150 | 29 |
| Popular | ₩9,900 | 400 | 25 |
| Heavy | ₩22,000 | 1,000 | 22 |

**첫구매 50% 보너스 (1회 한정)**.

평생 소장: 상세 사주명리서 ₩39,000 (premium_saju_lifetime). Family Sharing 비활성화 필수 (App Store Connect).

---

## 5. 무료 토큰 흐름 (retention)

| 트리거 | 토큰 | 빈도 |
|---|---:|---|
| 가입 보너스 | 50 | 1회 (BM v2.2) |
| 출석 체크 | 2 | 매일 |
| 7일 연속 출석 | 10 | 주 1회 |
| 광고 시청 | 1 | 일 5회 max (`grant-ad-reward`) |
| 친구 초대 (가입 완료) | 10 | 무제한 |
| 운세 공유 | 1 | 일 3회 |

Free 헤비 유저 일 max ~17 토큰, 월 ~250 토큰 무료 획득 가능.

---

## 6. 적자 차단 가드

1. **payment-verify-purchase 화이트리스트**: 정의되지 않은 product_id 차단 (이전 87 건 DB 오염 사례 차단).
2. **이미지 생성 자동 트리거 토큰 차감**:
   - 캐릭터 선톡 사진 (`generate-character-proactive-image`): 50 토큰
   - 친구 아바타 (`generate-friend-avatar`): 1회 무료, 재시도 25 토큰
   - 모든 이미지 생성은 LLM 호출 + storage upload 까지 try 블록으로 감싸 어디서 실패해도 환불 보장 (`_shared/token_charge.ts`)
3. **character-chat → llm_usage_logs 로깅**: 가장 비싼 기능 비용 가시화.
4. **fortune_type 정규화**: 카멜/스네이크/케밥 혼재 → soul-consume 진입점에서 kebab 통일.
5. **Streak 한도**: 무제한 채팅 abuse 방지 + 적자 cap.

---

## 7. KPI 모니터링 (Supabase SQL)

### 7.1 일일 매출 / LLM 비용 / 마진

```sql
SELECT
  DATE(created_at) AS day,
  COUNT(*) FILTER (WHERE transaction_type = 'purchase') AS purchases,
  SUM(amount) FILTER (WHERE transaction_type = 'purchase') AS tokens_purchased,
  COUNT(*) FILTER (WHERE transaction_type = 'consumption') AS consumptions,
  SUM(-amount) FILTER (WHERE transaction_type = 'consumption') AS tokens_spent
FROM token_transactions
WHERE created_at > now() - interval '30 days'
GROUP BY 1 ORDER BY 1 DESC;
```

### 7.2 LLM 비용 추이 (기능별)

```sql
SELECT
  DATE(created_at) AS day,
  fortune_type,
  COUNT(*) AS calls,
  SUM(estimated_cost)::numeric(10,4) AS usd_cost,
  AVG(prompt_tokens)::int AS avg_in,
  AVG(completion_tokens)::int AS avg_out
FROM llm_usage_logs
WHERE success = true AND created_at > now() - interval '7 days'
GROUP BY 1, 2 ORDER BY 1 DESC, 4 DESC;
```

### 7.3 구독 분포

```sql
SELECT product_id, status, COUNT(*) AS n,
       MIN(created_at) AS first_seen,
       MAX(expires_at) AS latest_expiry
FROM subscriptions GROUP BY 1, 2 ORDER BY 3 DESC;
```

### 7.4 Streak 분포 (Free 사용자 retention)

```sql
SELECT streak_days, COUNT(*) AS users, AVG(today_count) AS avg_today
FROM user_chat_streak GROUP BY 1 ORDER BY 1;
```

---

## 8. 사용자 작업 (BM v2.2 런칭 전 체크)

- [x] **App Store Connect**: 신규 7개 IAP 등록 (tokens.starter/basic/popular/heavy + subscription.lite/pro/max)
- [x] **Google Play Console**: 동일
- [ ] **Apple Family Sharing 비활성화** (premium_saju_lifetime)
- [ ] **Legacy product_id 비활성화** (tokens10/50/100/200, subscription.monthly) — restore 만 허용
- [x] **AdMob 계정** + iOS/Android Rewarded ad unit ID 발급
  - iOS App ID: `ca-app-pub-2803643717997352~5970615545`
  - Android App ID: `ca-app-pub-2803643717997352~8320790178`
  - iOS Rewarded Unit: `ca-app-pub-2803643717997352/7422204375`
  - Android Rewarded Unit: `ca-app-pub-2803643717997352/9908766911`
- [ ] **AdMob SSV 검증 로직** grant-ad-reward 에 추가 (ECDSA P-256, gstatic.com 동적 키 조회)
- [ ] **AdMob SSV 콜백 URL 등록**: grant-ad-reward 배포 후 양 ad unit 에 등록
- [ ] **expo-ads-admob / react-native-google-mobile-ads** 통합 (네이티브 빌드 필요)

---

## 9. 관련 파일

- `supabase/functions/_shared/types.ts` — FORTUNE_POINT_COSTS (단가표) + normalizeFortuneType
- `supabase/functions/_shared/token_charge.ts` — chargeTokens / refundTokens / hasUnlimitedSubscription
- `supabase/functions/character-chat/index.ts` — 한도 체크 + LLM 로깅
- `supabase/functions/payment-verify-purchase/index.ts` — 화이트리스트 + PRODUCT_TOKENS
- `supabase/functions/grant-ad-reward/index.ts` — 광고 보상
- `packages/product-contracts/src/products.ts` — product catalog (4티어 + 패키지)
- `apps/mobile-rn/src/screens/premium-screen.tsx` — 결제 UI
- `apps/mobile-rn/src/screens/chat-screen.tsx` — 채팅 한도 paywall
- `supabase/migrations/20260503190100_user_chat_streak.sql` — streak 테이블 + RPC
- `supabase/migrations/20260503191000_chat_streak_negative_guard.sql` — 음수 가드 패치
- `supabase/migrations/20260503192000_signup_bonus_50.sql` — 가입 보너스 30 → 50
- `supabase/migrations/20260503193000_ad_reward_log.sql` — 광고 시청 로그

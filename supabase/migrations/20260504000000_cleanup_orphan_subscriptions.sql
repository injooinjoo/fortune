-- 화이트리스트 (Sprint 1.1) 도입 전 진입한 미정의 product_id 14건 정리.
-- premium_yearly_test, com.beyond.fortune.subscription.yearly 가 active 상태로 남아
-- BM v2.2 단위경제 분석 / 구독자 분포 통계를 오염시킴. 명시적으로 cancelled 처리.

UPDATE subscriptions
SET status = 'cancelled',
    updated_at = now()
WHERE status = 'active'
  AND product_id IN (
    'premium_yearly_test',
    'com.beyond.fortune.subscription.yearly'
  );

-- expired 상태로 남은 같은 ID 들 (5+4 건) 은 이미 만료됐으므로 이력으로 보존.
-- 진짜 정상 active 구독자 (subscription.monthly 5 건) 은 grandfather — 만료 시까지
-- 토큰 충전 그대로 받음 (PRODUCT_TOKENS 에 legacy 매핑 유지됨).

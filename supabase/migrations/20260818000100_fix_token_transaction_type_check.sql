-- P0 / 프로덕션 장애 수정: 토큰 차감이 전부 실패하고 있다.
--
-- 라이브 DB 실측 (2026-08-18, project hayjukwfcsdmppairazc):
--   CHECK ((transaction_type = ANY (ARRAY['earn','spend','purchase','refund'])))  -- convalidated=true
--   consume_token_atomic() 은 마지막에 transaction_type='consumption' 을 INSERT 한다.
--   → 매 호출이 SQLSTATE 23514 (check_violation) 으로 실패하고 함수 전체가 롤백된다.
--     (balance 차감 UPDATE 도 같은 트랜잭션이므로 함께 되돌아간다)
--
-- 파급:
--   _shared/token_charge.ts chargeTokens 는 P0001(잔액부족)만 처리하고 나머지는 throw.
--   soul-consume 은 500 'Failed to consume token' 을 반환.
--   apps/mobile-rn/src/screens/chat-screen.tsx:2215 는 그 에러를 Sentry 로만 보내고
--   shouldRenderResult 를 유지 → 운세 결과를 그대로 렌더한다 (fail-open).
--   = 토큰을 차감하지 않은 채 유료 운세가 제공되어 왔다.
--
-- 원장 증거: token_transactions 에 'consumption'/'spend' 행 0건.
--            purchase 17 / earn 8 / refund 6 만 존재.
--            token_balance.total_spent 합계 775 는 _shared/auth.ts deductTokens 의
--            레거시 직접 쓰기 경로에서 나온 값이며 거래 이력이 없다.
--
-- 해결: 'consumption' 을 허용값에 추가한다.
--   RPC 쪽을 'spend' 로 바꾸지 않는 이유 — refund_token_atomic 의 원거래 조회,
--   soul-refund, token_charge.ts 가 전부 'consumption' 을 기준으로 삼고 있어
--   값을 바꾸면 환불 경로가 동시에 깨진다. 허용값 확장이 최소 변경이다.
--
-- 'chargeback' 은 웹 PG 결제의 환불/차지백 보상 트랜잭션용으로 함께 예약한다
--   (plans/web-first-pivot.md §7.2 revoke_purchase_tokens_atomic).

ALTER TABLE token_transactions
  DROP CONSTRAINT IF EXISTS token_transactions_transaction_type_check;

ALTER TABLE token_transactions
  ADD CONSTRAINT token_transactions_transaction_type_check
  CHECK (transaction_type IN (
    'earn',         -- 무료 지급 (출석, 광고, 프로필 보너스, 초대)
    'spend',        -- 레거시 소비 (현행 코드는 사용하지 않음, 과거 행 보존용)
    'purchase',     -- 결제/구독 지급
    'refund',       -- 생성 실패 환불 (refund_token_atomic)
    'consumption',  -- 소비 (consume_token_atomic) ← 이 값이 빠져 있어 장애가 났다
    'chargeback'    -- 결제 취소/차지백 회수 (웹 PG)
  ));

COMMENT ON CONSTRAINT token_transactions_transaction_type_check ON token_transactions IS
  'consume_token_atomic 이 INSERT 하는 값과 반드시 일치해야 한다. 값을 추가/변경할 때는 '
  'refund_token_atomic 의 원거래 조회 조건(transaction_type=''consumption'')도 함께 확인할 것.';

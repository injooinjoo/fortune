-- 운세 생성 결과 캐시 — 서버 주도 idempotency 의 저장소.
--
-- 배경: fortune-* Edge Function 이 클라이언트의 soul-consume 호출에 의존해
-- 브라우저에서 직접 호출하면 무과금 LLM 사용이 가능했다. _shared/fortune_charge.ts
-- 가 서버에서 차감하도록 바뀌면서, "같은 요청을 다시 보내면 다시 과금되는" 문제와
-- "클라가 idempotency key 를 고정해 공짜 재생성을 노리는" 구멍을 동시에 막기 위해
-- 서버가 만든 키(user + fortuneType + 정규화 body 해시)로 결과를 캐싱한다.
--
-- 키는 24h 윈도우 인덱스를 포함한다: fortune:<uid>:<type>:<bodyHash>:<floor(now/24h)>.
--
-- 처음에는 "TTL 이 유일한 시간 축" 으로 설계했으나 그건 영구 무료 구멍이었다:
-- consume_token_atomic 은 같은 멱등키에 대해 **영원히** replayed=true 를 돌려주고
-- _shared/token_charge.ts 는 replayed 를 charged:true 로 매핑해 차감을 건너뛴다.
-- 반면 이 테이블의 row 는 24h 뒤 사라진다. 결과적으로
--   1회 과금 → 24h 대기 → 캐시 미스 + 차감 replay → LLM 무료 실행 → 무한 반복
-- 이 성립했다. 키와 캐시가 같은 주기로 만료돼야 이 창이 닫힌다.
-- storeFortuneResult 도 expires_at 을 컬럼 기본값이 아니라 **윈도우 종료 시각**으로
-- 명시해 둘의 수명을 정확히 일치시킨다.
--
-- 잔여(경계 있음): 같은 윈도우 안에서 캐시 저장이 실패했거나 생성 실패 후 환불된
-- 요청이 재시도되면 차감 replay 로 1회 무료 생성이 가능하다. 원장이 "환불된 consume"
-- 을 구분하지 못해 스키마 변경 없이는 못 막는다. 발생 시
-- '[fortune_charge] 차감 replay (무차감 생성)' 경고가 함수 로그에 남는다.
--
-- service_role 전용 테이블. payload 에 사용자 운세 본문이 그대로 들어가므로
-- anon / authenticated 에게는 self-read 조차 열지 않는다 (Edge Function 만 접근).

CREATE TABLE IF NOT EXISTS fortune_result_cache (
  idempotency_key TEXT PRIMARY KEY,
  user_id UUID NOT NULL,
  fortune_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT now() + interval '24 hours'
);

CREATE INDEX IF NOT EXISTS idx_fortune_result_cache_user_created
  ON fortune_result_cache (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_fortune_result_cache_expires
  ON fortune_result_cache (expires_at);

ALTER TABLE fortune_result_cache ENABLE ROW LEVEL SECURITY;

-- service_role 만 읽기/쓰기. 사용자 직접 조회 경로 없음.
DROP POLICY IF EXISTS "fortune_result_cache_service_all" ON fortune_result_cache;
CREATE POLICY "fortune_result_cache_service_all" ON fortune_result_cache
  FOR ALL USING (auth.role() = 'service_role');

REVOKE ALL ON TABLE fortune_result_cache FROM anon, authenticated;

COMMENT ON TABLE fortune_result_cache IS
  '운세 생성 결과 캐시 (서버 주도 idempotency). service_role 전용. TTL 24시간.';

-- 만료 row 정리 — pg_cron 매일 03:10 (UTC).
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 기존 잡 제거 (재배포 시 중복 방지)
DO $$
BEGIN
  PERFORM cron.unschedule('cleanup-fortune-result-cache-daily');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END $$;

SELECT cron.schedule(
  'cleanup-fortune-result-cache-daily',
  '10 3 * * *',
  $$
  DELETE FROM fortune_result_cache WHERE expires_at < now();
  $$
);

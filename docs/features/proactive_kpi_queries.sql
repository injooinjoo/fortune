-- Slice 2 KPI 모니터링 쿼리 (PROACTIVE_MESSAGING_PLAN.md §2.8)
-- 7일 운용 기준. Supabase SQL Editor 또는 psql 에서 실행.
--
-- 사용법:
--   :since 변수가 없는 환경에선 "now() - interval '7 days'" 로 직접 치환해서 사용.
--   psql 이면 \set since '''2026-05-05'''  처럼.

-- =============================================================================
-- 1. reveal_fire_rate — Stage 1 hook 대비 Stage 2 image 발화율
--    Go: ≥ 30%, No-Go: < 15%
-- =============================================================================
WITH window_start AS (
  SELECT now() - interval '7 days' AS ts
)
SELECT
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true') AS hooks_sent,
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true' AND revealed_at IS NOT NULL) AS hooks_revealed,
  ROUND(
    COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true' AND revealed_at IS NOT NULL)::numeric
    / NULLIF(COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true'), 0)::numeric
    * 100,
    1
  ) AS reveal_fire_rate_pct
FROM proactive_message_log, window_start
WHERE scheduled_at >= window_start.ts
  AND character_id = 'luts';

-- =============================================================================
-- 2. opt_out_rate — Slice 2 시작 후 proactive disable 비율 (정확 비교는 deploy 시점 enabled 카운트 별도 보존 필요)
--    아래는 현시점 기준 disabled 비율 — 트렌드 보려면 매일 cron 으로 스냅샷.
-- =============================================================================
SELECT
  COUNT(*) FILTER (WHERE enabled = true) AS enabled_users,
  COUNT(*) FILTER (WHERE enabled = false) AS disabled_users,
  ROUND(
    COUNT(*) FILTER (WHERE enabled = false)::numeric
    / NULLIF(COUNT(*), 0)::numeric * 100,
    1
  ) AS disabled_pct
FROM user_proactive_preferences;

-- =============================================================================
-- 3. placeholder_repeat_rate — 같은 사진 5일 내 노출
--    Go: 0% (LRU 보장), No-Go: > 5% (LRU 버그)
-- =============================================================================
WITH window_start AS (SELECT now() - interval '7 days' AS ts),
flat AS (
  SELECT
    user_id,
    (meta->>'placeholderIndex')::int AS idx,
    scheduled_at
  FROM proactive_message_log, window_start
  WHERE scheduled_at >= window_start.ts
    AND character_id = 'luts'
    AND meta->>'imageCategory' = 'meal'
    AND meta->>'placeholderIndex' IS NOT NULL
),
pairs AS (
  SELECT
    a.user_id,
    a.idx,
    a.scheduled_at AS first_at,
    b.scheduled_at AS repeat_at,
    EXTRACT(EPOCH FROM (b.scheduled_at - a.scheduled_at)) / 3600 AS hours_apart
  FROM flat a
  JOIN flat b
    ON a.user_id = b.user_id
    AND a.idx = b.idx
    AND b.scheduled_at > a.scheduled_at
    AND b.scheduled_at < a.scheduled_at + interval '5 days'
)
SELECT
  COUNT(*) AS within_5day_repeats,
  COUNT(DISTINCT user_id) AS users_affected,
  (SELECT COUNT(*) FROM flat) AS total_image_dispatches,
  ROUND(
    COUNT(*)::numeric / NULLIF((SELECT COUNT(*) FROM flat), 0)::numeric * 100,
    2
  ) AS repeat_rate_pct
FROM pairs;

-- =============================================================================
-- 4. reveal_latency_median — Stage 1 hook → Stage 2 reveal 시간 중앙값
--    Go: < 6h, No-Go: > 12h (window 너무 길어 자연 답장 사실상 거의 없음 신호)
-- =============================================================================
WITH window_start AS (SELECT now() - interval '7 days' AS ts),
revealed AS (
  SELECT
    EXTRACT(EPOCH FROM (revealed_at - scheduled_at)) / 60 AS minutes_to_reveal
  FROM proactive_message_log, window_start
  WHERE scheduled_at >= window_start.ts
    AND character_id = 'luts'
    AND meta->>'hookForReveal' = 'true'
    AND revealed_at IS NOT NULL
)
SELECT
  COUNT(*) AS revealed_count,
  ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY minutes_to_reveal)::numeric, 1) AS median_min,
  ROUND(percentile_cont(0.9) WITHIN GROUP (ORDER BY minutes_to_reveal)::numeric, 1) AS p90_min,
  ROUND(MAX(minutes_to_reveal)::numeric, 1) AS max_min
FROM revealed;

-- =============================================================================
-- 5. push 실패 / hook abandon 카운트 — Stage 1 hook 인데 push_sent_count=0 인 케이스
--    (서버 review #6 fix 로 hookAbandoned 마킹)
-- =============================================================================
WITH window_start AS (SELECT now() - interval '7 days' AS ts)
SELECT
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true' AND meta->>'hookAbandoned' = 'true') AS hook_abandoned,
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true' AND push_sent_count = 0) AS hook_no_push,
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true' AND push_sent_count > 0) AS hook_pushed_ok
FROM proactive_message_log, window_start
WHERE scheduled_at >= window_start.ts
  AND character_id = 'luts';

-- =============================================================================
-- 6. 슬롯별 hook/reveal 분포
-- =============================================================================
WITH window_start AS (SELECT now() - interval '7 days' AS ts)
SELECT
  slot_key,
  COUNT(*) AS sent,
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true') AS hooks,
  COUNT(*) FILTER (WHERE meta->>'hookForReveal' = 'true' AND revealed_at IS NOT NULL) AS reveals
FROM proactive_message_log, window_start
WHERE scheduled_at >= window_start.ts
  AND character_id = 'luts'
GROUP BY slot_key
ORDER BY sent DESC;

-- =============================================================================
-- 7. 일별 image-bearing 슬롯 랜덤 분포 — 한쪽 슬롯에 쏠리는지
--    이상적: lunch_share 약 33%
-- =============================================================================
WITH window_start AS (SELECT now() - interval '7 days' AS ts)
SELECT
  slot_key,
  COUNT(*) AS hooks_count,
  ROUND(
    COUNT(*)::numeric
    / NULLIF((SELECT COUNT(*) FROM proactive_message_log, window_start
              WHERE scheduled_at >= window_start.ts
                AND character_id = 'luts'
                AND meta->>'hookForReveal' = 'true'), 0)::numeric * 100,
    1
  ) AS hooks_pct_of_total
FROM proactive_message_log, window_start
WHERE scheduled_at >= window_start.ts
  AND character_id = 'luts'
  AND meta->>'hookForReveal' = 'true'
GROUP BY slot_key
ORDER BY hooks_count DESC;

-- supabase/scripts/rls-static-audit.sh 의 새 게이트가 찾아낸 잔여 항목 정리.
--
-- 이전 감사 스크립트는 `CREATE TABLE ... public.` 형태만 매칭해서 100개 중 26개만
-- 검사했다. 비수식 선언까지 보도록 고치고 SECURITY DEFINER + p_user_id RPC 의
-- REVOKE 여부 게이트를 추가하니 아래 4건이 남았다.
--
-- 라이브 실측 (2026-08-18):
--   auspicious_days   RLS ON, 정책 1개  ← 대시보드에서 out-of-band 적용, 마이그레이션에 기록 없음
--   korean_holidays   RLS ON, 정책 1개  ← 동일
--   check_duplicate_fortune            ← SECURITY DEFINER, p_user_id 인자, anon 실행 가능
--   calculate_engagement_score         ← 라이브에 존재하지 않음 (마이그레이션에만 있는 유령)
--
-- 두 룩업 테이블은 이미 보호돼 있지만 상태가 코드에 없어 다음 환경 복제 시 재현되지
-- 않는다. 여기서 idempotent 하게 성문화한다.

-- ── 룩업 테이블 RLS 성문화 ─────────────────────────────────────────────────
-- 공개 참조 데이터(길일/공휴일)이므로 읽기는 전체 허용, 쓰기는 service_role 전용.

ALTER TABLE IF EXISTS korean_holidays ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS auspicious_days ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF to_regclass('public.korean_holidays') IS NOT NULL
     AND NOT EXISTS (
       SELECT 1 FROM pg_policy
        WHERE polrelid = 'public.korean_holidays'::regclass
          AND polname = 'korean_holidays_public_read'
     ) THEN
    CREATE POLICY korean_holidays_public_read
      ON korean_holidays FOR SELECT
      USING (true);
  END IF;

  IF to_regclass('public.auspicious_days') IS NOT NULL
     AND NOT EXISTS (
       SELECT 1 FROM pg_policy
        WHERE polrelid = 'public.auspicious_days'::regclass
          AND polname = 'auspicious_days_public_read'
     ) THEN
    CREATE POLICY auspicious_days_public_read
      ON auspicious_days FOR SELECT
      USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF to_regclass('public.korean_holidays') IS NOT NULL THEN
    REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE korean_holidays FROM anon, authenticated;
  END IF;
  IF to_regclass('public.auspicious_days') IS NOT NULL THEN
    REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE auspicious_days FROM anon, authenticated;
  END IF;
END $$;

-- ── SECURITY DEFINER RPC 회수 ──────────────────────────────────────────────
-- 두 함수 모두 리포 전체(apps/mobile-rn, supabase/functions)에서 호출부 0건.

REVOKE ALL ON FUNCTION public.check_duplicate_fortune(UUID, VARCHAR, DATE, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_duplicate_fortune(UUID, VARCHAR, DATE, JSONB)
  TO service_role;

-- calculate_engagement_score 는 마이그레이션에만 있고 라이브에는 없다.
-- 존재할 때만 회수한다 (다른 환경에서 적용됐을 수 있음).
-- 평문 REVOKE 를 쓰면 함수가 없는 환경에서 마이그레이션이 통째로 실패하므로 동적 실행.
-- audit-ack: calculate_engagement_score — 아래 DO 블록에서 동적으로 REVOKE 한다
DO $$
DECLARE
  v_sig TEXT;
BEGIN
  FOR v_sig IN
    SELECT format('public.%I(%s)', p.proname, pg_get_function_identity_arguments(p.oid))
      FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public' AND p.proname = 'calculate_engagement_score'
  LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon, authenticated', v_sig);
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO service_role', v_sig);
  END LOOP;
END $$;

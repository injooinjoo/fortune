-- RLS 경화: USING(true) + WITH CHECK(true) 패턴 제거 (audit W3)
-- 현재 service_role 전용으로 의도된 정책이 실제로는 anon 포함 모두에게 열려
-- 있어, 임의 클라이언트가 쓰기 가능. service_role 한정으로 수정.

-- === celebrity_master_list (실존 연예인 마스터 DB, 시스템 관리) ===
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.celebrity_master_list;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.celebrity_master_list;
CREATE POLICY "celebrity_master_list_service_write"
  ON public.celebrity_master_list
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
-- SELECT 정책은 유지 (앱이 공개 마스터 DB로 사용)

-- === widget_fortune_cache (사용자별 위젯 캐시) ===
DROP POLICY IF EXISTS "Service can manage widget cache" ON public.widget_fortune_cache;
CREATE POLICY "widget_fortune_cache_service_write"
  ON public.widget_fortune_cache
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
-- 사용자 본인 SELECT 정책은 유지

-- === popular_regions (인기 지역 마스터) ===
-- 기존 "Service role can insert" / "Service role can update" 이미 TO service_role 으로
-- 선언돼 있는지 확인. 확인 안 된 경우 ALTER 필요. 우선 DROP + 재생성.
DROP POLICY IF EXISTS "Service role can insert" ON public.popular_regions;
DROP POLICY IF EXISTS "Service role can update" ON public.popular_regions;
DROP POLICY IF EXISTS "Service role can delete" ON public.popular_regions;
CREATE POLICY "popular_regions_service_write"
  ON public.popular_regions
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
-- 공개 읽기(Anyone can read popular regions) 정책은 유지

-- === fcm_tokens (service_role 전용 관리) ===
DROP POLICY IF EXISTS "Service role can manage all FCM tokens" ON public.fcm_tokens;
CREATE POLICY "fcm_tokens_service_write"
  ON public.fcm_tokens
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
-- 사용자 본인 관리 정책("Users can manage own FCM tokens") 은 유지

-- === user_notification_preferences ===
DROP POLICY IF EXISTS "Service role can manage all notification preferences"
  ON public.user_notification_preferences;
CREATE POLICY "user_notification_preferences_service_write"
  ON public.user_notification_preferences
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
-- 사용자 본인 관리 정책 유지

-- === talisman_pool (공개 풀 설정) ===
-- "Anyone can view pool settings" USING(true) — SELECT 만이라면 OK (public read).
-- WRITE 정책이 별도로 있고 제한적인지 확인 필요. 확인 전까지는 no-op.
-- 필요 시 후속 migration 에서 WRITE 정책 경화.

COMMENT ON POLICY "celebrity_master_list_service_write"
  ON public.celebrity_master_list IS
  'W3: service_role 만 celebrity 마스터 DB 쓰기. Edge function 서버 측 관리.';
COMMENT ON POLICY "widget_fortune_cache_service_write"
  ON public.widget_fortune_cache IS
  'W3: service_role 만 widget 캐시 쓰기. 서버 백그라운드 갱신 전용.';

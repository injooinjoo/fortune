-- Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant usage on cron schema to postgres
GRANT USAGE ON SCHEMA cron TO postgres;

-- Create a function to call the zodiac scheduler edge function
CREATE OR REPLACE FUNCTION trigger_zodiac_age_fortune_generation()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  service_role_key text;
  supabase_url text;
  response jsonb;
BEGIN
  -- Get service role key and URL from vault
  SELECT decrypted_secret INTO service_role_key 
  FROM vault.decrypted_secrets 
  WHERE name = 'service_role_key';
  
  -- Get Supabase URL from app settings
  supabase_url := current_setting('app.settings.supabase_url');
  
  -- Call the edge function
  SELECT content::jsonb INTO response
  FROM http_post(
    supabase_url || '/functions/v1/fortune-zodiac-scheduler',
    jsonb_build_object(
      'action', 'generate_daily',
      'year', EXTRACT(YEAR FROM CURRENT_DATE)
    )::text,
    'application/json',
    jsonb_build_object(
      'Authorization', 'Bearer ' || service_role_key
    )::text
  );
  
  -- Log the response
  INSERT INTO cron_logs (job_name, status, response, executed_at)
  VALUES (
    'generate_zodiac_age_fortunes',
    CASE 
      WHEN response->>'success' = 'true' THEN 'success'
      ELSE 'failed'
    END,
    response,
    NOW()
  );
  
  -- Raise notice for monitoring
  RAISE NOTICE 'Zodiac age fortune generation completed: %', response;
END;
$$;

-- Schedule the cron job to run daily at midnight KST (15:00 UTC)
SELECT cron.schedule(
  'generate-zodiac-age-fortunes',  -- job name
  '0 15 * * *',                     -- cron expression (daily at 15:00 UTC = 00:00 KST)
  $$SELECT trigger_zodiac_age_fortune_generation();$$
);

-- Create an alternative cron job using net extension (if http_post is not available)
-- This is a fallback option
SELECT cron.schedule(
  'generate-zodiac-age-fortunes-net',
  '0 15 * * *',
  $$
  DO $$
  DECLARE
    service_role_key text;
    supabase_url text;
    response jsonb;
  BEGIN
    -- Get credentials
    SELECT decrypted_secret INTO service_role_key 
    FROM vault.decrypted_secrets 
    WHERE name = 'service_role_key';
    
    supabase_url := current_setting('app.settings.supabase_url');
    
    -- Make HTTP request using net extension
    SELECT 
      net.http_post(
        url := supabase_url || '/functions/v1/fortune-zodiac-scheduler',
        headers := jsonb_build_object(
          'Authorization', 'Bearer ' || service_role_key,
          'Content-Type', 'application/json'
        ),
        body := jsonb_build_object(
          'action', 'generate_daily',
          'year', EXTRACT(YEAR FROM CURRENT_DATE)
        )
      ) INTO response;
    
    -- Log the result
    INSERT INTO cron_logs (job_name, status, response, executed_at)
    VALUES (
      'generate_zodiac_age_fortunes',
      'completed',
      response,
      NOW()
    );
  END $$;
  $$
);

-- Create a manual trigger function for testing
CREATE OR REPLACE FUNCTION manual_trigger_zodiac_fortunes()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT trigger_zodiac_age_fortune_generation();
  SELECT response INTO result 
  FROM cron_logs 
  WHERE job_name = 'generate_zodiac_age_fortunes'
  ORDER BY executed_at DESC
  LIMIT 1;
  
  RETURN result;
END;
$$;

-- Grant execute permission to authenticated users for manual testing
GRANT EXECUTE ON FUNCTION manual_trigger_zodiac_fortunes() TO authenticated;

-- Comment on the cron job
COMMENT ON FUNCTION trigger_zodiac_age_fortune_generation() IS 'Triggers daily generation of age-based zodiac fortunes at midnight KST';

-- Create index on cron_logs for efficient querying
CREATE INDEX IF NOT EXISTS idx_cron_logs_job_name_executed 
ON cron_logs(job_name, executed_at DESC);
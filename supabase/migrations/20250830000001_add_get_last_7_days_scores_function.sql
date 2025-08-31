-- Create function to get last 7 days scores for a user
CREATE OR REPLACE FUNCTION get_last_7_days_scores(target_user_id UUID)
RETURNS TABLE(
  day_offset INT,
  score INT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  WITH date_series AS (
    SELECT 
      generate_series(0, 6) AS day_offset
  ),
  scores AS (
    SELECT 
      DATE_PART('day', CURRENT_DATE - created_at::date)::INT AS day_offset,
      (summary->>'score')::INT AS score
    FROM fortune_history
    WHERE 
      user_id = target_user_id
      AND fortune_type = 'daily'
      AND created_at >= CURRENT_DATE - INTERVAL '6 days'
      AND created_at < CURRENT_DATE + INTERVAL '1 day'
      AND summary->>'score' IS NOT NULL
  )
  SELECT 
    ds.day_offset,
    COALESCE(s.score, 0) AS score
  FROM date_series ds
  LEFT JOIN scores s ON ds.day_offset = s.day_offset
  ORDER BY ds.day_offset;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_last_7_days_scores(UUID) TO authenticated;

-- Add comment to explain the function
COMMENT ON FUNCTION get_last_7_days_scores(UUID) IS 'Returns the fortune scores for the last 7 days for a given user, with day_offset 0 being today';
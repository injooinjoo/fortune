-- Token usage statistics function
CREATE OR REPLACE FUNCTION get_token_usage_stats(
  p_user_id UUID,
  p_start_date TIMESTAMP,
  p_end_date TIMESTAMP
)
RETURNS TABLE(
  total_used BIGINT,
  total_purchased BIGINT,
  total_bonus BIGINT,
  most_used_fortune TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(SUM(CASE WHEN transaction_type = 'usage' THEN ABS(amount) ELSE 0 END), 0) as total_used,
    COALESCE(SUM(CASE WHEN transaction_type = 'purchase' THEN amount ELSE 0 END), 0) as total_purchased,
    COALESCE(SUM(CASE WHEN transaction_type IN ('bonus', 'subscription') THEN amount ELSE 0 END), 0) as total_bonus,
    (
      SELECT fortune_type 
      FROM token_transactions 
      WHERE user_id = p_user_id 
        AND transaction_type = 'usage'
        AND created_at BETWEEN p_start_date AND p_end_date
        AND fortune_type IS NOT NULL
      GROUP BY fortune_type 
      ORDER BY COUNT(*) DESC 
      LIMIT 1
    ) as most_used_fortune
  FROM token_transactions
  WHERE user_id = p_user_id
    AND created_at BETWEEN p_start_date AND p_end_date;
END;
$$ LANGUAGE plpgsql;
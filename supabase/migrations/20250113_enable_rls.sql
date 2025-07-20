-- Enable Row Level Security on all user tables
-- This ensures users can only access their own data

-- 1. Enable RLS on user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own profile
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. Enable RLS on user_tokens table
ALTER TABLE user_tokens ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own tokens
CREATE POLICY "Users can view own tokens" ON user_tokens
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Service role can manage all tokens
CREATE POLICY "Service role can manage tokens" ON user_tokens
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 3. Enable RLS on fortunes table
ALTER TABLE fortunes ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own fortunes
CREATE POLICY "Users can view own fortunes" ON fortunes
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can insert their own fortunes
CREATE POLICY "Users can insert own fortunes" ON fortunes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. Enable RLS on token_transactions table
ALTER TABLE token_transactions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON token_transactions
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Service role can manage all transactions
CREATE POLICY "Service role can manage transactions" ON token_transactions
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 5. Enable RLS on payment_transactions table
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own payments
CREATE POLICY "Users can view own payments" ON payment_transactions
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Service role can manage all payments
CREATE POLICY "Service role can manage payments" ON payment_transactions
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 6. Enable RLS on user_subscriptions table
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions" ON user_subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Service role can manage all subscriptions
CREATE POLICY "Service role can manage subscriptions" ON user_subscriptions
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 7. Enable RLS on fortune_batches table (if exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'fortune_batches') THEN
        ALTER TABLE fortune_batches ENABLE ROW LEVEL SECURITY;
        
        -- Policy: Users can view their own batches
        CREATE POLICY "Users can view own batches" ON fortune_batches
            FOR SELECT USING (auth.uid() = user_id);
            
        -- Policy: Users can insert their own batches
        CREATE POLICY "Users can insert own batches" ON fortune_batches
            FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
END $$;

-- 8. Enable RLS on daily_fortunes table (if exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'daily_fortunes') THEN
        ALTER TABLE daily_fortunes ENABLE ROW LEVEL SECURITY;
        
        -- Policy: Users can view their own daily fortunes
        CREATE POLICY "Users can view own daily fortunes" ON daily_fortunes
            FOR SELECT USING (auth.uid() = user_id);
    END IF;
END $$;

-- 9. Enable RLS on shared_fortunes table (if exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'shared_fortunes') THEN
        ALTER TABLE shared_fortunes ENABLE ROW LEVEL SECURITY;
        
        -- Policy: Anyone can view shared fortunes (public)
        CREATE POLICY "Anyone can view shared fortunes" ON shared_fortunes
            FOR SELECT USING (true);
            
        -- Policy: Users can share their own fortunes
        CREATE POLICY "Users can share own fortunes" ON shared_fortunes
            FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
END $$;

-- Note: This migration adds RLS policies to protect user data
-- Ensure that all API calls use proper authentication
-- Service role key should only be used on the server side
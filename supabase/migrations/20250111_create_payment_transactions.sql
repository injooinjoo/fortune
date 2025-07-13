-- Create payment_transactions table for tracking in-app purchases
CREATE TABLE IF NOT EXISTS public.payment_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    transaction_id TEXT NOT NULL UNIQUE,
    platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    product_id TEXT NOT NULL,
    amount INTEGER NOT NULL, -- in smallest currency unit (e.g., cents for USD, won for KRW)
    currency TEXT DEFAULT 'KRW',
    tokens_purchased INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_payment_transactions_user_id ON public.payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_transaction_id ON public.payment_transactions(transaction_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status);
CREATE INDEX idx_payment_transactions_created_at ON public.payment_transactions(created_at DESC);

-- Enable RLS
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- RLS policies
-- Users can only view their own transactions
CREATE POLICY "Users can view their own payment transactions"
    ON public.payment_transactions FOR SELECT
    USING (auth.uid() = user_id);

-- Only service role can insert/update transactions
CREATE POLICY "Service role can manage payment transactions"
    ON public.payment_transactions FOR ALL
    USING (auth.role() = 'service_role');

-- Create updated_at trigger
CREATE TRIGGER update_payment_transactions_updated_at
    BEFORE UPDATE ON public.payment_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comment
COMMENT ON TABLE public.payment_transactions IS 'Tracks all payment transactions including in-app purchases and subscriptions';
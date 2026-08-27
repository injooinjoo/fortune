-- Toss web payment order ledger and atomic token grant boundary.

CREATE TABLE public.web_payment_orders (
  order_id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  order_name TEXT NOT NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  base_tokens INTEGER NOT NULL CHECK (base_tokens > 0),
  granted_tokens INTEGER NOT NULL DEFAULT 0 CHECK (granted_tokens >= 0),
  currency TEXT NOT NULL DEFAULT 'KRW' CHECK (currency = 'KRW'),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'paid', 'cancel_requested', 'cancelled', 'failed')
  ),
  payment_key TEXT UNIQUE,
  toss_transaction_key TEXT UNIQUE,
  payment_method TEXT,
  failure_code TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  paid_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  CHECK (order_id ~ '^ondo_[0-9a-f-]{36}$'),
  CHECK (char_length(product_id) BETWEEN 1 AND 100),
  CHECK (char_length(order_name) BETWEEN 1 AND 100)
);

CREATE TABLE public.web_payment_refund_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id TEXT NOT NULL REFERENCES public.web_payment_orders(order_id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL CHECK (amount > 0),
  reason TEXT NOT NULL CHECK (char_length(reason) BETWEEN 2 AND 200),
  status TEXT NOT NULL DEFAULT 'requested' CHECK (
    status IN ('requested', 'reviewing', 'approved', 'processing', 'completed', 'rejected', 'failed')
  ),
  toss_transaction_key TEXT UNIQUE,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_web_payment_refund_one_active_per_order
  ON public.web_payment_refund_requests(order_id)
  WHERE status IN ('requested', 'reviewing', 'approved', 'processing', 'completed');
CREATE INDEX idx_web_payment_orders_user_created
  ON public.web_payment_orders(user_id, created_at DESC);

ALTER TABLE public.web_payment_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.web_payment_refund_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY web_payment_orders_self_read
  ON public.web_payment_orders FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY web_payment_refunds_self_read
  ON public.web_payment_refund_requests FOR SELECT TO authenticated
  USING (user_id = auth.uid());

REVOKE ALL ON TABLE public.web_payment_orders FROM anon, authenticated;
REVOKE ALL ON TABLE public.web_payment_refund_requests FROM anon, authenticated;
GRANT SELECT ON TABLE public.web_payment_orders TO authenticated;
GRANT SELECT ON TABLE public.web_payment_refund_requests TO authenticated;
GRANT ALL ON TABLE public.web_payment_orders TO service_role;
GRANT ALL ON TABLE public.web_payment_refund_requests TO service_role;

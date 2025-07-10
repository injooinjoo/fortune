import { NextRequest, NextResponse } from 'next/server';
import { constructWebhookEvent } from '@/lib/payment/stripe-client';
import { createClient } from '@supabase/supabase-js';
import Stripe from 'stripe';
import { logger } from '@/lib/logger';
import { captureException } from '@/lib/error-monitor';

// Supabase Admin 클라이언트
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function POST(request: NextRequest) {
  logger.info('[Stripe Webhook] Received webhook request');
  
  const body = await request.text();
  const signature = request.headers.get('stripe-signature')!;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

  if (!signature) {
    logger.error('[Stripe Webhook] Missing stripe-signature header');
    return NextResponse.json(
      { error: 'Missing signature' },
      { status: 400 }
    );
  }

  if (!webhookSecret) {
    logger.error('[Stripe Webhook] STRIPE_WEBHOOK_SECRET not configured');
    return NextResponse.json(
      { error: 'Webhook not configured' },
      { status: 500 }
    );
  }

  let event: Stripe.Event;

  try {
    event = constructWebhookEvent(body, signature, webhookSecret);
    logger.info(`[Stripe Webhook] Event received: ${event.type}`, { eventId: event.id });
  } catch (err: any) {
    logger.error('[Stripe Webhook] Signature verification failed:', err.message);
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    );
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        await handleCheckoutSessionCompleted(session);
        break;
      }

      case 'invoice.payment_succeeded': {
        const invoice = event.data.object as Stripe.Invoice;
        await handleInvoicePaymentSucceeded(invoice);
        break;
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription;
        await handleSubscriptionDeleted(subscription);
        break;
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription;
        await handleSubscriptionUpdated(subscription);
        break;
      }

      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await handlePaymentIntentSucceeded(paymentIntent);
        break;
      }

      default:
        logger.info(`[Stripe Webhook] Unhandled event type: ${event.type}`);
    }

    logger.info(`[Stripe Webhook] Successfully processed event: ${event.type}`);
    return NextResponse.json({ received: true });
  } catch (error) {
    logger.error('[Stripe Webhook] Error processing webhook:', error);
    
    // 에러 모니터링에 보고
    captureException(error, {
      webhook: 'stripe',
      eventType: event.type,
      eventId: event.id
    });
    
    return NextResponse.json(
      { error: 'Webhook processing failed' },
      { status: 500 }
    );
  }
}

async function handleCheckoutSessionCompleted(session: Stripe.Checkout.Session) {
  logger.info('[Stripe Webhook] Processing checkout.session.completed', {
    sessionId: session.id,
    customerId: session.customer,
    mode: session.mode
  });
  
  const userId = session.metadata?.userId;
  if (!userId) {
    logger.warn('[Stripe Webhook] No userId in session metadata', { sessionId: session.id });
    return;
  }

  // 결제 거래 기록
  const { error: txError } = await supabaseAdmin.from('payment_transactions').insert({
    user_id: userId,
    transaction_id: session.payment_intent as string,
    payment_provider: 'stripe',
    payment_method: session.payment_method_types?.[0] || 'card',
    amount: session.amount_total || 0,
    currency: session.currency?.toUpperCase() || 'KRW',
    status: 'succeeded',
    product_type: session.mode === 'subscription' ? 'subscription' : 'token_package',
    product_id: session.metadata?.productId,
    metadata: session.metadata,
    webhook_received_at: new Date().toISOString(),
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  });

  if (txError) {
    logger.error('[Stripe Webhook] Failed to record payment transaction:', txError);
    throw txError;
  }

  if (session.mode === 'subscription') {
    // 구독 활성화
    const subscriptionId = session.subscription as string;
    logger.info('[Stripe Webhook] Activating subscription', { userId, subscriptionId });
    
    const planType = session.metadata?.planType || 'premium';
    const monthlyTokenQuota = parseInt(session.metadata?.monthlyTokens || '100');
    
    const { error: subError } = await supabaseAdmin.from('subscription_status').upsert({
      user_id: userId,
      subscription_id: subscriptionId,
      plan_type: planType,
      status: 'active',
      current_period_start: new Date().toISOString(),
      current_period_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      monthly_token_quota: monthlyTokenQuota,
      tokens_used_this_period: 0,
      features: {
        unlimited_daily_fortunes: planType === 'premium' || planType === 'enterprise',
        advanced_fortunes: planType !== 'free',
        priority_support: planType === 'enterprise'
      },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    if (subError) {
      logger.error('[Stripe Webhook] Failed to upsert subscription:', subError);
      throw subError;
    }
    
    // 월간 토큰 지급
    await creditMonthlyTokens(userId, monthlyTokenQuota);
    
    logger.info('[Stripe Webhook] Successfully activated subscription for user', { userId });
  } else if (session.mode === 'payment') {
    // 일회성 토큰 구매
    const tokens = parseInt(session.metadata?.tokens || '0');
    if (tokens > 0) {
      await creditTokens(userId, tokens, session.payment_intent as string);
      logger.info('[Stripe Webhook] Successfully credited tokens', { userId, tokens });
    }
  }
}

async function handleInvoicePaymentSucceeded(invoice: Stripe.Invoice) {
  const subscriptionId = invoice.subscription as string;
  const customerId = invoice.customer as string;

  // 사용자 ID 찾기
  const { data: subscription } = await supabaseAdmin
    .from('subscription_status')
    .select('user_id, plan_type, monthly_token_quota')
    .eq('subscription_id', subscriptionId)
    .single();

  if (!subscription) {
    logger.warn('[Stripe Webhook] Subscription not found for invoice', { subscriptionId });
    return;
  }

  // 결제 기록 저장
  await supabaseAdmin.from('payment_transactions').insert({
    user_id: subscription.user_id,
    transaction_id: invoice.payment_intent as string,
    payment_provider: 'stripe',
    payment_method: 'card',
    amount: invoice.amount_paid,
    currency: invoice.currency.toUpperCase(),
    status: 'succeeded',
    product_type: 'subscription',
    product_id: subscription.plan_type,
    metadata: {
      invoice_id: invoice.id,
      subscription_id: subscriptionId,
      billing_period: {
        start: invoice.period_start,
        end: invoice.period_end
      }
    },
    webhook_received_at: new Date().toISOString(),
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  });

  // 구독 갱신: 토큰 재설정
  await supabaseAdmin.from('subscription_status').update({
    tokens_used_this_period: 0,
    current_period_start: new Date(invoice.period_start! * 1000).toISOString(),
    current_period_end: new Date(invoice.period_end! * 1000).toISOString(),
    updated_at: new Date().toISOString()
  }).eq('subscription_id', subscriptionId);

  // 월간 토큰 지급
  await creditMonthlyTokens(subscription.user_id, subscription.monthly_token_quota);

  logger.info('[Stripe Webhook] Invoice payment processed', {
    userId: subscription.user_id,
    amount: invoice.amount_paid,
    tokens: subscription.monthly_token_quota
  });
}

async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  // 구독 취소 처리
  const { data: sub } = await supabaseAdmin
    .from('subscription_status')
    .select('user_id')
    .eq('subscription_id', subscription.id)
    .single();

  if (sub) {
    await supabaseAdmin.from('subscription_status').update({
      status: 'canceled',
      canceled_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }).eq('subscription_id', subscription.id);

    logger.info('[Stripe Webhook] Subscription canceled', {
      userId: sub.user_id,
      subscriptionId: subscription.id
    });
  }
}

async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  // 구독 상태 업데이트
  await supabaseAdmin.from('subscription_status').update({
    status: subscription.status === 'active' ? 'active' : 
            subscription.status === 'past_due' ? 'past_due' : 
            subscription.status === 'canceled' ? 'canceled' : 'unpaid',
    current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
    current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
    cancel_at_period_end: subscription.cancel_at_period_end,
    updated_at: new Date().toISOString()
  }).eq('subscription_id', subscription.id);

  logger.info('[Stripe Webhook] Subscription updated', {
    subscriptionId: subscription.id,
    status: subscription.status,
    cancelAtPeriodEnd: subscription.cancel_at_period_end
  });
}

async function handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  const userId = paymentIntent.metadata?.userId;
  const tokens = parseInt(paymentIntent.metadata?.tokens || '0');
  const productId = paymentIntent.metadata?.productId;

  if (userId && tokens > 0) {
    // 결제 거래 기록 (중복 처리 방지)
    const { data: existingTx } = await supabaseAdmin
      .from('payment_transactions')
      .select('id')
      .eq('transaction_id', paymentIntent.id)
      .single();

    if (!existingTx) {
      await supabaseAdmin.from('payment_transactions').insert({
        user_id: userId,
        transaction_id: paymentIntent.id,
        payment_provider: 'stripe',
        payment_method: paymentIntent.payment_method_types?.[0] || 'card',
        amount: paymentIntent.amount,
        currency: paymentIntent.currency.toUpperCase(),
        status: 'succeeded',
        product_type: 'token_package',
        product_id: productId,
        metadata: { tokens },
        webhook_received_at: new Date().toISOString(),
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

      // 토큰 추가
      await creditTokens(userId, tokens, paymentIntent.id);
      
      logger.info('[Stripe Webhook] Payment intent processed', {
        userId,
        tokens,
        amount: paymentIntent.amount
      });
    } else {
      logger.info('[Stripe Webhook] Payment intent already processed', {
        paymentIntentId: paymentIntent.id
      });
    }
  }
}

// 토큰 지급 함수
async function creditTokens(userId: string, amount: number, transactionId: string) {
  // 현재 토큰 잔액 확인
  const { data: userTokens } = await supabaseAdmin
    .from('user_tokens')
    .select('balance')
    .eq('user_id', userId)
    .single();

  const currentBalance = userTokens?.balance || 0;
  const newBalance = currentBalance + amount;

  // user_tokens 테이블 업데이트 (없으면 생성)
  const { error: tokenError } = await supabaseAdmin
    .from('user_tokens')
    .upsert({
      user_id: userId,
      balance: newBalance,
      total_purchased: (userTokens?.total_purchased || 0) + amount,
      last_recharged_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

  if (tokenError) {
    logger.error('[Stripe Webhook] Failed to update user tokens:', tokenError);
    throw tokenError;
  }

  // 토큰 거래 내역 기록
  await supabaseAdmin.from('token_transactions').insert({
    user_id: userId,
    transaction_type: 'purchase',
    amount: amount,
    balance_after: newBalance,
    payment_transaction_id: transactionId,
    description: `토큰 ${amount}개 구매`,
    created_at: new Date().toISOString()
  });
}

// 월간 토큰 지급 함수
async function creditMonthlyTokens(userId: string, amount: number) {
  // 현재 토큰 잔액 확인
  const { data: userTokens } = await supabaseAdmin
    .from('user_tokens')
    .select('balance')
    .eq('user_id', userId)
    .single();

  const currentBalance = userTokens?.balance || 0;
  const newBalance = currentBalance + amount;

  // user_tokens 테이블 업데이트
  await supabaseAdmin
    .from('user_tokens')
    .upsert({
      user_id: userId,
      balance: newBalance,
      updated_at: new Date().toISOString()
    });

  // 토큰 거래 내역 기록
  await supabaseAdmin.from('token_transactions').insert({
    user_id: userId,
    transaction_type: 'bonus',
    amount: amount,
    balance_after: newBalance,
    description: `월간 구독 토큰 ${amount}개 지급`,
    created_at: new Date().toISOString()
  });
}
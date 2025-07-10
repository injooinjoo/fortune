import Stripe from 'stripe';

// Stripe 클라이언트 초기화 (API 키가 있을 때만)
export const stripe = process.env.STRIPE_SECRET_KEY 
  ? new Stripe(process.env.STRIPE_SECRET_KEY, {
      apiVersion: '2024-11-20.acacia',
      typescript: true,
    })
  : null;

// 가격 설정 (KRW)
export const PRICE_CONFIG = {
  PREMIUM_MONTHLY: {
    priceId: process.env.STRIPE_PREMIUM_MONTHLY_PRICE_ID!,
    amount: 9900, // ₩9,900
    name: '프리미엄 월간 구독',
    features: [
      '모든 운세 무제한 이용',
      '광고 제거',
      '프리미엄 전용 운세',
      '우선 지원',
      '토큰 사용량 분석'
    ]
  },
  PREMIUM_YEARLY: {
    priceId: process.env.STRIPE_PREMIUM_YEARLY_PRICE_ID!,
    amount: 99000, // ₩99,000 (2개월 무료)
    name: '프리미엄 연간 구독',
    features: [
      '모든 프리미엄 혜택',
      '2개월 무료 혜택',
      '연간 운세 리포트',
      'VIP 전용 이벤트'
    ]
  },
  ONE_TIME_TOKENS: {
    SMALL: {
      priceId: process.env.STRIPE_TOKENS_SMALL_PRICE_ID!,
      amount: 1000, // ₩1,000
      tokens: 10,
      name: '토큰 10개'
    },
    MEDIUM: {
      priceId: process.env.STRIPE_TOKENS_MEDIUM_PRICE_ID!,
      amount: 5000, // ₩5,000
      tokens: 60,
      name: '토큰 60개 (20% 보너스)'
    },
    LARGE: {
      priceId: process.env.STRIPE_TOKENS_LARGE_PRICE_ID!,
      amount: 10000, // ₩10,000
      tokens: 150,
      name: '토큰 150개 (50% 보너스)'
    }
  }
};

// 구독 생성
export async function createSubscription(
  customerId: string,
  priceId: string
): Promise<Stripe.Subscription> {
  return await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: 'default_incomplete',
    expand: ['latest_invoice.payment_intent'],
    metadata: {
      app: 'fortune',
      type: 'subscription'
    }
  });
}

// 일회성 결제 생성
export async function createPaymentIntent(
  amount: number,
  customerId: string,
  metadata: Record<string, string>
): Promise<Stripe.PaymentIntent> {
  return await stripe.paymentIntents.create({
    amount,
    currency: 'krw',
    customer: customerId,
    metadata: {
      app: 'fortune',
      ...metadata
    }
  });
}

// 고객 생성 또는 업데이트
export async function createOrUpdateCustomer(
  email: string,
  userId: string,
  name?: string
): Promise<Stripe.Customer & { ephemeralKey?: string }> {
  // 기존 고객 확인
  const existingCustomers = await stripe.customers.list({
    email,
    limit: 1
  });

  let customer: Stripe.Customer;
  
  if (existingCustomers.data.length > 0) {
    // 기존 고객 업데이트
    customer = await stripe.customers.update(existingCustomers.data[0].id, {
      metadata: {
        userId,
        app: 'fortune'
      },
      name
    });
  } else {
    // 새 고객 생성
    customer = await stripe.customers.create({
      email,
      name,
      metadata: {
        userId,
        app: 'fortune'
      }
    });
  }
  
  // Ephemeral Key 생성 (모바일 SDK용)
  const ephemeralKey = await stripe.ephemeralKeys.create(
    { customer: customer.id },
    { apiVersion: '2024-11-20.acacia' }
  );
  
  return {
    ...customer,
    ephemeralKey: ephemeralKey.secret
  };
}

// 구독 취소
export async function cancelSubscription(
  subscriptionId: string,
  immediately = false
): Promise<Stripe.Subscription> {
  if (immediately) {
    return await stripe.subscriptions.cancel(subscriptionId);
  }
  
  // 기간 종료 시 취소
  return await stripe.subscriptions.update(subscriptionId, {
    cancel_at_period_end: true
  });
}

// 결제 방법 연결
export async function attachPaymentMethod(
  paymentMethodId: string,
  customerId: string
): Promise<Stripe.PaymentMethod> {
  const paymentMethod = await stripe.paymentMethods.attach(paymentMethodId, {
    customer: customerId
  });

  // 기본 결제 방법으로 설정
  await stripe.customers.update(customerId, {
    invoice_settings: {
      default_payment_method: paymentMethodId
    }
  });

  return paymentMethod;
}

// 인보이스 조회
export async function getInvoices(
  customerId: string,
  limit = 10
): Promise<Stripe.Invoice[]> {
  const invoices = await stripe.invoices.list({
    customer: customerId,
    limit
  });

  return invoices.data;
}

// 웹훅 시그니처 검증
export function constructWebhookEvent(
  payload: string | Buffer,
  signature: string,
  webhookSecret: string
): Stripe.Event {
  return stripe.webhooks.constructEvent(payload, signature, webhookSecret);
}
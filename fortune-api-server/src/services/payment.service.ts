import { google } from 'googleapis';
import logger from '../utils/logger';
import { supabaseAdmin } from '../config/supabase';

interface VerificationResult {
  valid: boolean;
  purchaseInfo: any;
}

interface AppleReceiptVerificationResponse {
  status: number;
  receipt: any;
  latest_receipt_info?: any[];
  pending_renewal_info?: any[];
}

export class PaymentService {
  private static instance: PaymentService;
  private androidPublisher: any;

  private constructor() {
    this.initializeGoogleClient();
  }

  static getInstance(): PaymentService {
    if (!PaymentService.instance) {
      PaymentService.instance = new PaymentService();
    }
    return PaymentService.instance;
  }

  private async initializeGoogleClient() {
    try {
      const auth = new google.auth.GoogleAuth({
        keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH,
        scopes: ['https://www.googleapis.com/auth/androidpublisher'],
      });

      this.androidPublisher = google.androidpublisher({
        version: 'v3',
        auth,
      });
    } catch (error) {
      logger.error('[PaymentService] Failed to initialize Google client:', error);
    }
  }

  // Google Play 구매 검증
  async verifyGooglePurchase(
    purchaseToken: string,
    productId: string
  ): Promise<VerificationResult> {
    try {
      // 소모성 상품 검증
      if (productId.includes('tokens')) {
        const response = await this.androidPublisher.purchases.products.get({
          packageName: 'com.fortune.fortune_flutter',
          productId,
          token: purchaseToken,
        });

        const purchase = response.data;
        const isValid = purchase.purchaseState === 0; // 0 = purchased

        return {
          valid: isValid,
          purchaseInfo: {
            transactionId: purchase.orderId,
            purchaseDate: new Date(parseInt(purchase.purchaseTimeMillis || '0')),
            amount: purchase.priceAmountMicros ? parseInt(purchase.priceAmountMicros) / 1000000 : 0,
            currency: purchase.priceCurrencyCode,
            platform: 'android',
            ...purchase,
          },
        };
      }

      // 구독 상품 검증
      const response = await this.androidPublisher.purchases.subscriptions.get({
        packageName: 'com.fortune.fortune_flutter',
        subscriptionId: productId,
        token: purchaseToken,
      });

      const subscription = response.data;
      const isValid = subscription.paymentState === 1; // 1 = payment received

      return {
        valid: isValid,
        purchaseInfo: {
          transactionId: subscription.orderId,
          purchaseDate: new Date(parseInt(subscription.startTimeMillis || '0')),
          expiryDate: new Date(parseInt(subscription.expiryTimeMillis || '0')),
          amount: subscription.priceAmountMicros ? parseInt(subscription.priceAmountMicros) / 1000000 : 0,
          currency: subscription.priceCurrencyCode,
          platform: 'android',
          ...subscription,
        },
      };

    } catch (error) {
      logger.error('[PaymentService] Google purchase verification failed', error);
      return { valid: false, purchaseInfo: {} };
    }
  }

  // Apple 영수증 검증
  async verifyAppleReceipt(
    receiptData: string,
    productId: string
  ): Promise<VerificationResult> {
    try {
      // 프로덕션 환경 먼저 시도
      let response = await this.verifyWithAppleServer(
        receiptData,
        'https://buy.itunes.apple.com/verifyReceipt'
      );

      // Sandbox 환경에서 재시도 (status 21007)
      if (response.status === 21007) {
        logger.info('[PaymentService] Retrying with sandbox environment');
        response = await this.verifyWithAppleServer(
          receiptData,
          'https://sandbox.itunes.apple.com/verifyReceipt'
        );
      }

      // 영수증 유효성 검사
      if (response.status !== 0) {
        logger.error('[PaymentService] Invalid receipt status:', response.status);
        return { valid: false, purchaseInfo: {} };
      }

      // 최신 영수증 정보 찾기
      const latestReceiptInfo = response.latest_receipt_info || [];
      const matchingReceipt = latestReceiptInfo.find(
        (receipt) => receipt.product_id === productId
      );

      if (!matchingReceipt) {
        logger.error('[PaymentService] No matching receipt found for product:', productId);
        return { valid: false, purchaseInfo: {} };
      }

      // 구매 정보 추출
      const purchaseInfo: any = {
        transactionId: matchingReceipt.transaction_id,
        originalTransactionId: matchingReceipt.original_transaction_id,
        productId: matchingReceipt.product_id,
        purchaseDate: new Date(parseInt(matchingReceipt.purchase_date_ms)),
        quantity: parseInt(matchingReceipt.quantity || '1'),
        platform: 'ios',
      };

      // 구독 상품인 경우 추가 정보
      if (productId.includes('subscription')) {
        purchaseInfo.expiresDate = matchingReceipt.expires_date_ms
          ? new Date(parseInt(matchingReceipt.expires_date_ms))
          : undefined;
        purchaseInfo.isTrialPeriod = matchingReceipt.is_trial_period === 'true';
        purchaseInfo.isInIntroOfferPeriod = matchingReceipt.is_in_intro_offer_period === 'true';
        purchaseInfo.webOrderLineItemId = matchingReceipt.web_order_line_item_id;
      }

      // 만료 확인 (구독의 경우)
      if (purchaseInfo.expiresDate) {
        const now = new Date();
        if (purchaseInfo.expiresDate < now) {
          logger.warn('[PaymentService] Subscription expired', {
            productId,
            expiresDate: purchaseInfo.expiresDate,
          });
          return { valid: false, purchaseInfo };
        }
      }

      logger.info('[PaymentService] Receipt verified successfully', {
        productId,
        transactionId: purchaseInfo.transactionId,
      });

      return { valid: true, purchaseInfo };

    } catch (error) {
      logger.error('[PaymentService] Apple verification error:', error);
      return { valid: false, purchaseInfo: {} };
    }
  }

  // Apple 서버로 영수증 검증 요청
  private async verifyWithAppleServer(
    receiptData: string,
    endpoint: string
  ): Promise<AppleReceiptVerificationResponse> {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        'receipt-data': receiptData,
        'password': process.env.APPLE_IAP_SHARED_SECRET,
        'exclude-old-transactions': true,
      }),
    });

    if (!response.ok) {
      throw new Error(`Apple server responded with status: ${response.status}`);
    }

    return response.json() as Promise<AppleReceiptVerificationResponse>;
  }

  // 구독 활성화
  async activateSubscription(
    userId: string,
    productId: string,
    purchaseInfo: any
  ): Promise<void> {
    const isMonthly = productId.includes('monthly');
    const subscriptionType = isMonthly ? 'monthly' : 'yearly';
    
    const startDate = new Date();
    const endDate = new Date();
    
    if (isMonthly) {
      endDate.setMonth(endDate.getMonth() + 1);
    } else {
      endDate.setFullYear(endDate.getFullYear() + 1);
    }

    const { error } = await supabaseAdmin
      .from('subscriptions')
      .upsert({
        user_id: userId,
        type: subscriptionType,
        status: 'active',
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString(),
        product_id: productId,
        transaction_id: purchaseInfo.transactionId,
        platform: purchaseInfo.platform,
        auto_renew: true,
        updated_at: new Date().toISOString(),
      }, {
        onConflict: 'user_id',
      });

    if (error) {
      logger.error('[PaymentService] Failed to activate subscription', error);
      throw new Error('구독 활성화 실패');
    }

    logger.info('[PaymentService] Subscription activated', {
      userId,
      type: subscriptionType,
      endDate: endDate.toISOString(),
    });
  }

  // 활성 구독 조회
  async getActiveSubscription(userId: string): Promise<any> {
    const { data, error } = await supabaseAdmin
      .from('subscriptions')
      .select('*')
      .eq('user_id', userId)
      .eq('status', 'active')
      .single();

    if (error) {
      if (error.code === 'PGRST116') { // No rows found
        return null;
      }
      throw error;
    }

    return data;
  }

  // 구독 만료 처리
  async expireSubscription(userId: string): Promise<void> {
    const { error } = await supabaseAdmin
      .from('subscriptions')
      .update({
        status: 'expired',
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', userId);

    if (error) {
      logger.error('[PaymentService] Failed to expire subscription', error);
      throw error;
    }
  }

  // 구매 내역 조회
  async getPurchaseHistory(userId: string, limit: number = 20): Promise<any[]> {
    const { data, error } = await supabaseAdmin
      .from('purchases')
      .select('*')
      .eq('user_id', userId)
      .order('purchase_date', { ascending: false })
      .limit(limit);

    if (error) {
      logger.error('[PaymentService] Failed to get purchase history', error);
      throw error;
    }

    return data || [];
  }
}
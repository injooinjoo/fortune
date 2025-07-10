import { logger } from '@/lib/logger';

interface AppleReceiptVerificationResponse {
  status: number;
  receipt: any;
  latest_receipt_info?: any[];
  pending_renewal_info?: any[];
}

interface VerificationResult {
  valid: boolean;
  purchaseInfo: any;
}

// Apple 영수증 검증
export async function verifyAppleReceipt(
  receiptData: string,
  productId: string
): Promise<VerificationResult> {
  try {
    // 프로덕션 환경 먼저 시도
    let response = await verifyWithAppleServer(
      receiptData,
      'https://buy.itunes.apple.com/verifyReceipt'
    );

    // Sandbox 환경에서 재시도 (status 21007)
    if (response.status === 21007) {
      logger.info('[Apple IAP] Retrying with sandbox environment');
      response = await verifyWithAppleServer(
        receiptData,
        'https://sandbox.itunes.apple.com/verifyReceipt'
      );
    }

    // 영수증 유효성 검사
    if (response.status !== 0) {
      logger.error('[Apple IAP] Invalid receipt status:', response.status);
      return { valid: false, purchaseInfo: {} };
    }

    // 최신 영수증 정보 찾기
    const latestReceiptInfo = response.latest_receipt_info || [];
    const matchingReceipt = latestReceiptInfo.find(
      (receipt) => receipt.product_id === productId
    );

    if (!matchingReceipt) {
      logger.error('[Apple IAP] No matching receipt found for product:', productId);
      return { valid: false, purchaseInfo: {} };
    }

    // 구매 정보 추출
    const purchaseInfo = {
      transactionId: matchingReceipt.transaction_id,
      originalTransactionId: matchingReceipt.original_transaction_id,
      productId: matchingReceipt.product_id,
      purchaseDate: new Date(parseInt(matchingReceipt.purchase_date_ms)),
      quantity: parseInt(matchingReceipt.quantity || '1'),
      platform: 'ios',
    };

    // 구독 상품인 경우 추가 정보
    if (productId.includes('subscription')) {
      purchaseInfo['expiresDate'] = matchingReceipt.expires_date_ms
        ? new Date(parseInt(matchingReceipt.expires_date_ms))
        : undefined;
      purchaseInfo['isTrialPeriod'] = matchingReceipt.is_trial_period === 'true';
      purchaseInfo['isInIntroOfferPeriod'] = matchingReceipt.is_in_intro_offer_period === 'true';
      purchaseInfo['webOrderLineItemId'] = matchingReceipt.web_order_line_item_id;
    }

    // 만료 확인 (구독의 경우)
    if (purchaseInfo['expiresDate']) {
      const now = new Date();
      if (purchaseInfo['expiresDate'] < now) {
        logger.warn('[Apple IAP] Subscription expired', {
          productId,
          expiresDate: purchaseInfo['expiresDate'],
        });
        return { valid: false, purchaseInfo };
      }
    }

    logger.info('[Apple IAP] Receipt verified successfully', {
      productId,
      transactionId: purchaseInfo.transactionId,
    });

    return { valid: true, purchaseInfo };

  } catch (error) {
    logger.error('[Apple IAP] Verification error:', error);
    return { valid: false, purchaseInfo: {} };
  }
}

// Apple 서버로 영수증 검증 요청
async function verifyWithAppleServer(
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

  return response.json();
}

// Apple 영수증 상태 코드 설명
export const APPLE_RECEIPT_STATUS_CODES: Record<number, string> = {
  0: 'Valid receipt',
  21000: 'App Store could not read the JSON',
  21002: 'Receipt data property was malformed',
  21003: 'Receipt could not be authenticated',
  21004: 'Shared secret does not match',
  21005: 'Receipt server is not currently available',
  21006: 'Receipt is valid but subscription has expired',
  21007: 'Receipt is from test environment',
  21008: 'Receipt is from production environment',
  21009: 'Internal data access error',
  21010: 'User account not found',
};

// 구독 갱신 정보 처리
export function processSubscriptionRenewalInfo(
  pendingRenewalInfo: any[]
): {
  willAutoRenew: boolean;
  expirationIntent?: string;
  isInBillingRetryPeriod?: boolean;
} {
  if (!pendingRenewalInfo || pendingRenewalInfo.length === 0) {
    return { willAutoRenew: true };
  }

  const info = pendingRenewalInfo[0];
  
  return {
    willAutoRenew: info.auto_renew_status === '1',
    expirationIntent: info.expiration_intent,
    isInBillingRetryPeriod: info.is_in_billing_retry_period === '1',
  };
}

// 환불 상태 확인
export function checkRefundStatus(receipt: any): boolean {
  return receipt.cancellation_date_ms !== undefined;
}

// 구매 타입 확인
export function getPurchaseType(productId: string): 'consumable' | 'subscription' {
  if (productId.includes('subscription')) {
    return 'subscription';
  }
  return 'consumable';
}
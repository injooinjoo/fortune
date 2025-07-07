import axios from 'axios';
import { Buffer } from 'buffer';

// 토스페이먼츠 API 클라이언트
class TossPaymentsClient {
  private apiKey: string;
  private secretKey: string;
  private baseURL = 'https://api.tosspayments.com/v1';
  
  constructor() {
    this.apiKey = process.env.TOSS_CLIENT_KEY!;
    this.secretKey = process.env.TOSS_SECRET_KEY!;
  }

  private getAuthHeader() {
    const credentials = Buffer.from(`${this.secretKey}:`).toString('base64');
    return `Basic ${credentials}`;
  }

  // 결제 승인
  async confirmPayment(paymentKey: string, orderId: string, amount: number) {
    try {
      const response = await axios.post(
        `${this.baseURL}/payments/${paymentKey}`,
        {
          orderId,
          amount
        },
        {
          headers: {
            Authorization: this.getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error: any) {
      throw new Error(`결제 승인 실패: ${error.response?.data?.message || error.message}`);
    }
  }

  // 결제 조회
  async getPayment(paymentKey: string) {
    try {
      const response = await axios.get(
        `${this.baseURL}/payments/${paymentKey}`,
        {
          headers: {
            Authorization: this.getAuthHeader()
          }
        }
      );
      return response.data;
    } catch (error: any) {
      throw new Error(`결제 조회 실패: ${error.response?.data?.message || error.message}`);
    }
  }

  // 결제 취소
  async cancelPayment(paymentKey: string, cancelReason: string, cancelAmount?: number) {
    try {
      const response = await axios.post(
        `${this.baseURL}/payments/${paymentKey}/cancel`,
        {
          cancelReason,
          cancelAmount
        },
        {
          headers: {
            Authorization: this.getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error: any) {
      throw new Error(`결제 취소 실패: ${error.response?.data?.message || error.message}`);
    }
  }

  // 빌링키 발급 (정기 결제용)
  async issueBillingKey(customerKey: string, authKey: string) {
    try {
      const response = await axios.post(
        `${this.baseURL}/billing/authorizations/issue`,
        {
          authKey,
          customerKey
        },
        {
          headers: {
            Authorization: this.getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error: any) {
      throw new Error(`빌링키 발급 실패: ${error.response?.data?.message || error.message}`);
    }
  }

  // 빌링키로 결제
  async payWithBillingKey(
    billingKey: string,
    customerKey: string,
    amount: number,
    orderId: string,
    orderName: string
  ) {
    try {
      const response = await axios.post(
        `${this.baseURL}/billing/${billingKey}`,
        {
          customerKey,
          amount,
          orderId,
          orderName
        },
        {
          headers: {
            Authorization: this.getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error: any) {
      throw new Error(`빌링 결제 실패: ${error.response?.data?.message || error.message}`);
    }
  }
}

export const tossPayments = new TossPaymentsClient();

// 가격 설정 (토스페이먼츠용)
export const TOSS_PRICE_CONFIG = {
  PREMIUM_MONTHLY: {
    amount: 9900,
    orderName: 'Fortune 프리미엄 월간 구독',
    taxFreeAmount: 0
  },
  PREMIUM_YEARLY: {
    amount: 99000,
    orderName: 'Fortune 프리미엄 연간 구독',
    taxFreeAmount: 0
  },
  COINS: {
    PACK_100: {
      amount: 1000,
      orderName: '코인 100개',
      coins: 100
    },
    PACK_550: {
      amount: 5000,
      orderName: '코인 550개 (10% 보너스)',
      coins: 550
    },
    PACK_1200: {
      amount: 10000,
      orderName: '코인 1200개 (20% 보너스)',
      coins: 1200
    },
    PACK_3000: {
      amount: 20000,
      orderName: '코인 3000개 (50% 보너스)',
      coins: 3000
    }
  }
};

// 주문 ID 생성 (토스페이먼츠 규격)
export function generateOrderId(userId: string, type: string): string {
  const timestamp = Date.now();
  // Payment order IDs need to be unique but don't affect fortune generation
  // Using timestamp + counter is sufficient for uniqueness
  const counter = (globalThis as any).__orderCounter = ((globalThis as any).__orderCounter || 0) + 1;
  return `${type}_${userId}_${timestamp}_${counter.toString(36)}`;
}

// 웹훅 검증
export function verifyTossWebhook(request: Request): boolean {
  // 토스페이먼츠는 IP 기반 검증 사용
  const allowedIPs = [
    '52.78.5.241',
    '52.79.115.82',
    '54.180.166.224',
    '54.180.176.244'
  ];
  
  const clientIP = request.headers.get('x-forwarded-for') || 
                   request.headers.get('x-real-ip') || 
                   '';
  
  return allowedIPs.includes(clientIP.split(',')[0].trim());
}
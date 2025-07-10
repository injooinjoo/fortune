import { logger } from '@/lib/logger';

/**
 * 결제 라이브러리 모킹 (실제 라이브러리 설치 전 임시)
 */

// Stripe 모킹
export const loadStripe = () => {
  logger.warn('Stripe is mocked. Install @stripe/stripe-js for production');
  return Promise.resolve(null);
};

// Toss Payments 모킹
export const loadTossPayments = () => {
  logger.warn('Toss Payments is mocked. Install @tosspayments/payment-sdk for production');
  return Promise.resolve({
    requestPayment: () => Promise.reject(new Error('Payment SDK not installed')),
  });
};

// Canvas Confetti 모킹
export const confetti = () => {
  logger.warn('Confetti is mocked. Install canvas-confetti for production');
  return Promise.resolve();
};
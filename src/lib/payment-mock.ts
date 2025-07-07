/**
 * 결제 라이브러리 모킹 (실제 라이브러리 설치 전 임시)
 */

// Stripe 모킹
export const loadStripe = () => {
  console.warn('Stripe is mocked. Install @stripe/stripe-js for production');
  return Promise.resolve(null);
};

// Toss Payments 모킹
export const loadTossPayments = () => {
  console.warn('Toss Payments is mocked. Install @tosspayments/payment-sdk for production');
  return Promise.resolve({
    requestPayment: () => Promise.reject(new Error('Payment SDK not installed')),
  });
};

// Canvas Confetti 모킹
export const confetti = () => {
  console.warn('Confetti is mocked. Install canvas-confetti for production');
  return Promise.resolve();
};
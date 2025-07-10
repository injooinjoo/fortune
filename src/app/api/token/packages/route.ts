import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';

// Token packages configuration
const TOKEN_PACKAGES = [
  {
    id: 'tokens_10',
    name: '10 토큰',
    tokens: 10,
    price: 1000,
    currency: 'KRW',
    description: '기본 패키지'
  },
  {
    id: 'tokens_50',
    name: '50 토큰',
    tokens: 50,
    price: 4500,
    originalPrice: 5000,
    currency: 'KRW',
    badge: '10% 할인',
    description: '인기 패키지',
    isPopular: true
  },
  {
    id: 'tokens_100',
    name: '100 토큰',
    tokens: 100,
    price: 8000,
    originalPrice: 10000,
    currency: 'KRW',
    badge: '20% 할인',
    bonusTokens: 10,
    description: '베스트 밸류'
  },
  {
    id: 'tokens_200',
    name: '200 토큰',
    tokens: 200,
    price: 15000,
    originalPrice: 20000,
    currency: 'KRW',
    badge: '25% 할인',
    bonusTokens: 30,
    description: '프리미엄 패키지'
  },
  {
    id: 'unlimited_monthly',
    name: '무제한 이용권',
    tokens: 999999,
    price: 9900,
    currency: 'KRW',
    badge: '월간 구독',
    description: '한 달 동안 무제한 이용',
    isPopular: true
  }
];

export async function GET(request: NextRequest) {
  try {
    return createSuccessResponse({
      packages: TOKEN_PACKAGES
    });
  } catch (error) {
    logger.error('Token packages API error:', error);
    return createErrorResponse('Failed to load token packages', undefined, undefined, 500);
  }
}
export type ProductId =
  | 'com.beyond.fortune.tokens10'
  | 'com.beyond.fortune.tokens50'
  | 'com.beyond.fortune.tokens100'
  | 'com.beyond.fortune.tokens200'
  | 'com.beyond.fortune.points300'
  | 'com.beyond.fortune.points600'
  | 'com.beyond.fortune.points1200'
  | 'com.beyond.fortune.points3000'
  | 'com.beyond.fortune.subscription.monthly'
  | 'com.beyond.fortune.subscription.max'
  | 'com.beyond.fortune.premium_saju_lifetime';

export interface ProductInfo {
  id: ProductId;
  title: string;
  description: string;
  price: number;
  points: number;
  basePoints?: number;
  bonusPoints?: number;
  isSubscription: boolean;
  subscriptionPeriod?: 'monthly' | 'max';
  isNonConsumable?: boolean;
}

export const productCatalog = {
  'com.beyond.fortune.tokens10': {
    id: 'com.beyond.fortune.tokens10',
    title: '10 토큰',
    description: '기본 운세를 가볍게 체험할 수 있는 스타터 패키지',
    price: 1100,
    points: 10,
    basePoints: 10,
    isSubscription: false,
  },
  'com.beyond.fortune.tokens50': {
    id: 'com.beyond.fortune.tokens50',
    title: '50 토큰',
    description: '자주 사용하는 분들을 위한 50 토큰 패키지',
    price: 4500,
    points: 50,
    basePoints: 50,
    bonusPoints: 5,
    isSubscription: false,
  },
  'com.beyond.fortune.tokens100': {
    id: 'com.beyond.fortune.tokens100',
    title: '100 토큰',
    description: '다양한 운세와 깊이 있는 인사이트를 위한 알찬 패키지',
    price: 8000,
    points: 100,
    basePoints: 100,
    bonusPoints: 15,
    isSubscription: false,
  },
  'com.beyond.fortune.tokens200': {
    id: 'com.beyond.fortune.tokens200',
    title: '200 토큰',
    description: '헤비 유저를 위한 최대 가성비 토큰 패키지',
    price: 14000,
    points: 200,
    basePoints: 200,
    bonusPoints: 30,
    isSubscription: false,
  },
  'com.beyond.fortune.points300': {
    id: 'com.beyond.fortune.points300',
    title: '기존 350 토큰',
    description: '이전 결제 복원용 토큰 패키지',
    price: 3300,
    points: 350,
    basePoints: 300,
    bonusPoints: 50,
    isSubscription: false,
  },
  'com.beyond.fortune.points600': {
    id: 'com.beyond.fortune.points600',
    title: '기존 700 토큰',
    description: '이전 결제 복원용 토큰 패키지',
    price: 5500,
    points: 700,
    basePoints: 600,
    bonusPoints: 100,
    isSubscription: false,
  },
  'com.beyond.fortune.points1200': {
    id: 'com.beyond.fortune.points1200',
    title: '기존 1,650 토큰',
    description: '이전 결제 복원용 토큰 패키지',
    price: 11000,
    points: 1650,
    basePoints: 1500,
    bonusPoints: 150,
    isSubscription: false,
  },
  'com.beyond.fortune.points3000': {
    id: 'com.beyond.fortune.points3000',
    title: '기존 4,400 토큰',
    description: '이전 결제 복원용 토큰 패키지',
    price: 22000,
    points: 4400,
    basePoints: 4000,
    bonusPoints: 400,
    isSubscription: false,
  },
  'com.beyond.fortune.subscription.monthly': {
    id: 'com.beyond.fortune.subscription.monthly',
    title: 'Pro 구독',
    description: '매월 토큰이 자동 충전되는 기본 구독 플랜',
    price: 4500,
    points: 30000,
    isSubscription: true,
    subscriptionPeriod: 'monthly',
  },
  'com.beyond.fortune.subscription.max': {
    id: 'com.beyond.fortune.subscription.max',
    title: 'Max 구독',
    description: '모든 기능을 넉넉하게 쓰는 고급 구독 플랜',
    price: 12900,
    points: 100000,
    isSubscription: true,
    subscriptionPeriod: 'max',
  },
  'com.beyond.fortune.premium_saju_lifetime': {
    id: 'com.beyond.fortune.premium_saju_lifetime',
    title: '상세 사주명리서',
    description: '215페이지 상세 사주 분석서 (평생 소유)',
    price: 39000,
    points: 0,
    isSubscription: false,
    isNonConsumable: true,
  },
} as const satisfies Record<ProductId, ProductInfo>;

export const consumableProductIds = [
  'com.beyond.fortune.tokens10',
  'com.beyond.fortune.tokens50',
  'com.beyond.fortune.tokens100',
  'com.beyond.fortune.tokens200',
] as const satisfies readonly ProductId[];

// Customer-facing consumables that should appear in the store UI.
export const storefrontConsumableProductIds = consumableProductIds;

export const legacyConsumableProductIds = [
  'com.beyond.fortune.points300',
  'com.beyond.fortune.points600',
  'com.beyond.fortune.points1200',
  'com.beyond.fortune.points3000',
] as const satisfies readonly ProductId[];

export const subscriptionProductIds = [
  'com.beyond.fortune.subscription.monthly',
  'com.beyond.fortune.subscription.max',
] as const satisfies readonly ProductId[];

export const nonConsumableProductIds = [
  'com.beyond.fortune.premium_saju_lifetime',
] as const satisfies readonly ProductId[];

export const storefrontSubscriptionProductIds = subscriptionProductIds;

export const storefrontNonConsumableProductIds = nonConsumableProductIds;

export const allProductIds = [
  ...consumableProductIds,
  ...legacyConsumableProductIds,
  ...subscriptionProductIds,
  ...nonConsumableProductIds,
] as const satisfies readonly ProductId[];

export function isLegacyConsumableProductId(productId: ProductId): boolean {
  return (legacyConsumableProductIds as readonly ProductId[]).includes(productId);
}

export function getProductDisplayTitle(productId: ProductId): string {
  switch (productId) {
    case 'com.beyond.fortune.tokens10':
      return '토큰 10개';
    case 'com.beyond.fortune.tokens50':
      return '토큰 50개';
    case 'com.beyond.fortune.tokens100':
      return '토큰 100개';
    case 'com.beyond.fortune.tokens200':
      return '토큰 200개';
    case 'com.beyond.fortune.points300':
      return '레거시 토큰 350개';
    case 'com.beyond.fortune.points600':
      return '레거시 토큰 700개';
    case 'com.beyond.fortune.points1200':
      return '레거시 토큰 1,650개';
    case 'com.beyond.fortune.points3000':
      return '레거시 토큰 4,400개';
    case 'com.beyond.fortune.subscription.monthly':
      return '프로 구독';
    case 'com.beyond.fortune.subscription.max':
      return '맥스 구독';
    case 'com.beyond.fortune.premium_saju_lifetime':
      return '상세 사주명리서';
  }
}

export function getSubscriptionPeriodLabel(productId: ProductId): string | null {
  switch (productId) {
    case 'com.beyond.fortune.subscription.monthly':
    case 'com.beyond.fortune.subscription.max':
      return '매월 결제';
    default:
      return null;
  }
}

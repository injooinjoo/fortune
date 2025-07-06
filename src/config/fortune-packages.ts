export const FORTUNE_PACKAGES = {
  TRADITIONAL_PACKAGE: {
    name: 'traditional_package',
    fortunes: ['saju', 'traditional-saju', 'tojeong', 'salpuli', 'past-life'],
    cacheDuration: 365 * 24 * 60 * 60 * 1000, // 1년
    description: '생년월일시 기반 전통 운명학 종합 분석'
  },
  DAILY_PACKAGE: {
    name: 'daily_package', 
    fortunes: ['daily', 'hourly', 'today', 'tomorrow'],
    cacheDuration: 24 * 60 * 60 * 1000, // 24시간
    description: '일일 종합 운세'
  },
  LOVE_PACKAGE_SINGLE: {
    name: 'love_package_single',
    fortunes: ['love', 'destiny', 'blind-date', 'celebrity-match'],
    cacheDuration: 72 * 60 * 60 * 1000, // 72시간
    description: '솔로를 위한 연애운 패키지'
  },
  CAREER_WEALTH_PACKAGE: {
    name: 'career_wealth_package',
    fortunes: ['career', 'wealth', 'business', 'lucky-investment'],
    cacheDuration: 168 * 60 * 60 * 1000, // 7일
    description: '커리어와 재물운 종합'
  },
  LUCKY_ITEMS_PACKAGE: {
    name: 'lucky_items_package',
    fortunes: ['lucky-color', 'lucky-number', 'lucky-items', 'lucky-outfit', 'lucky-food'],
    cacheDuration: 720 * 60 * 60 * 1000, // 30일
    description: '행운 아이템 종합 패키지'
  }
} as const;

export type FortunePackageName = keyof typeof FORTUNE_PACKAGES;
export type FortunePackageConfig = typeof FORTUNE_PACKAGES[FortunePackageName];

export function selectModelForPackage(packageName: string): string {
  switch(packageName) {
    case 'traditional_package':
      return 'gpt-4-turbo-preview'; // 전문적 분석 필요
    case 'daily_package':
    case 'lucky_items_package':
      return 'gpt-4o-mini'; // 비용 효율적
    default:
      return 'gpt-3.5-turbo'; // 일반 용도
  }
}

export function getAllFortuneTypes(): string[] {
  return Object.values(FORTUNE_PACKAGES).flatMap(pkg => pkg.fortunes);
}

export function findPackageByFortuneTypes(fortuneTypes: string[]): FortunePackageConfig | null {
  for (const [, config] of Object.entries(FORTUNE_PACKAGES)) {
    const matchCount = fortuneTypes.filter(f => 
      (config.fortunes as readonly string[]).includes(f)
    ).length;
    if (matchCount >= config.fortunes.length * 0.6) {
      return {
        name: config.name,
        fortunes: [...config.fortunes],
        cacheDuration: config.cacheDuration,
        description: config.description
      };
    }
  }
  return null;
}
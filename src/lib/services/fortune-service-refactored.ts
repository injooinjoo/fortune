// Refactored Fortune Service using Composition
import {
  FortuneCategory,
  FortuneGroupType,
  UserProfile,
  FortuneData,
  FortuneResponse,
  LifeProfileData,
  DailyComprehensiveData,
  InteractiveInput,
} from '../types/fortune-system';
import { logger } from '@/lib/logger';
import { FortuneService } from './fortune-service';

export class FortuneServiceRefactored {
  private originalService: FortuneService;

  constructor() {
    this.originalService = new FortuneService();
    logger.debug("FortuneService is now refactored using Composition!");
  }

  // getOrCreateFortune는 Refactored 버전의 핵심이므로 새로 작성
  public async getOrCreateFortune<T = any>(
    userId: string,
    fortuneCategory: FortuneCategory,
    userProfile?: UserProfile,
    interactiveInput?: InteractiveInput
  ): Promise<FortuneResponse<T>> {
    const groupType = this.getFortuneCategoryGroup(fortuneCategory);
    
    // 캐시 로직 등은 originalService의 것을 재활용하거나 새로 구현할 수 있습니다.
    // 여기서는 패키지 생성 로직에 집중합니다.
    const cacheKey = `refactored:${userId}:${groupType}`;
    
    // (간략화된 캐시 확인)
    const cachedData = await this.originalService['memoryCache'].get(cacheKey);
    if(cachedData) {
        return { success: true, data: this.extractCategoryData(cachedData.data, fortuneCategory), cached: true, generated_at: new Date().toISOString() };
    }

    // userProfile이 없는 경우 에러 처리
    if (!userProfile) {
      throw new Error(`User profile is required to generate new fortune package for group ${groupType}`);
    }

    // 패키지 데이터 생성
    const packageData = await this.generateFortunePackage(groupType, userProfile);
    
    // (간략화된 캐시 저장)
    this.originalService['memoryCache'].set(cacheKey, { data: packageData, expiresAt: null, cacheType: 'memory' });

    return {
        success: true,
        data: this.extractCategoryData(packageData, fortuneCategory),
        cached: false,
        generated_at: new Date().toISOString()
      };
  }
  
  // 패키지 생성 로직을 담당하는 private 헬퍼
  private async generateFortunePackage(groupType: FortuneGroupType, userProfile: UserProfile): Promise<any> {
     switch (groupType) {
      case 'LIFE_PROFILE':
        return this.generateLifeProfilePackage(userProfile);
      case 'DAILY_COMPREHENSIVE':
        return this.generateDailyComprehensivePackage(userProfile);
      default:
        // 다른 패키지들은 여기서 처리하거나, 원래 서비스의 로직을 사용
        return {}; 
    }
  }

  // --- 패키지 단위 생성 함수들 (내부 구현은 동일) ---
  private async generateLifeProfilePackage(userProfile: UserProfile): Promise<any> {
    logger.debug(`[Package] Generating LIFE_PROFILE_PACKAGE for ${userProfile.name}`);
    const sajuData = this.originalService['generateSajuFromGPT'](userProfile);
    return { saju: sajuData };
  }

  private async generateDailyComprehensivePackage(userProfile: UserProfile): Promise<any> {
     logger.debug(`[Package] Generating DAILY_COMPREHENSIVE_PACKAGE for ${userProfile.name}`);
     const dailyData = await this.originalService['generateMbtiDailyFromGPT'](userProfile);
     return { daily: dailyData };
  }
  
  // --- 유틸리티 함수들 (내부 구현은 동일) ---
  private extractCategoryData(packageData: any, category: FortuneCategory): any {
      if(packageData && packageData[category]) {
          return packageData[category];
      }
      return packageData; // Fallback
  }

  private getFortuneCategoryGroup(category: FortuneCategory): FortuneGroupType {
    const lifeProfileCategories = ['saju', 'traditional-saju', 'personality'];
    const dailyCategories = ['daily', 'hourly', 'today'];
    
    if (lifeProfileCategories.includes(category)) return 'LIFE_PROFILE';
    if (dailyCategories.includes(category)) return 'DAILY_COMPREHENSIVE';
    return 'CLIENT_BASED';
  }
} 
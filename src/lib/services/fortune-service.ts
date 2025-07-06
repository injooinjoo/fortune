// 운세 서비스 - 핵심 데이터 관리 로직
// 작성일: 2024-12-19

import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';
import { 
  FortuneCategory, 
  FortuneGroupType, 
  UserProfile, 
  FortuneData, 
  FortuneResponse,
  LifeProfileData,
  DailyComprehensiveData,
  InteractiveInput,
  FortuneCategoryGroup
} from '../types/fortune-system';
import { FortuneServiceError } from '../fortune-utils';
import { centralizedFortuneService } from './centralized-fortune-service';
import { FORTUNE_PACKAGES } from '@/config/fortune-packages';

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
export class FortuneService {
  private static instance: FortuneService;
  private supabase: any;
  private redis: any = null; // Redis 클라이언트 (선택적)

  private constructor() {
    console.log('FortuneService 초기화 - DB 전용 모드');
    
    // Supabase 클라이언트 초기화
    if (process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY) {
      this.supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
      );
      console.log('✅ Supabase 연결 활성화');
    } else {
      console.error('❌ Supabase 환경변수 누락 - DB 저장 불가');
      throw new Error('Supabase 환경변수가 설정되지 않았습니다.');
    }
  }

  // 싱글톤 인스턴스 생성
  public static getInstance(): FortuneService {
    if (!FortuneService.instance) {
      FortuneService.instance = new FortuneService();
    }
    return FortuneService.instance;
  }

  /**
   * 메인 진입점: 운세 데이터 조회 또는 생성
   */
  async getOrCreateFortune<T = any>(
    userId: string,
    fortuneCategory: FortuneCategory,
    userProfile?: UserProfile,
    interactiveInput?: InteractiveInput
  ): Promise<FortuneResponse<T>> {
    const startTime = Date.now();
    
    try {
      console.log('FortuneService.getOrCreateFortune 시작:', { userId, fortuneCategory });

      // 운세 타입 결정
      const fortuneType = this.getFortuneCategoryGroup(fortuneCategory);
      
      // Rate limiting 체크 (간단한 메모리 기반)
      if (this.isRateLimited(userId, fortuneCategory)) {
        return {
          success: false,
          error: '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.',
          cached: false,
          generated_at: new Date().toISOString()
        };
      }
      
      // 1. 캐시 확인 (개발 모드에서는 메모리 캐시, 프로덕션에서는 DB+Redis)
      const cachedData = await this.getCachedFortune(userId, fortuneType, fortuneCategory, interactiveInput);
      
      if (cachedData) {
        console.log(`💾 캐시 히트 - ${fortuneCategory}:`, { 
          cached: true, 
          cacheSource: cachedData._cache_source || 'memory' 
        });
        
        return {
          success: true,
          data: cachedData,
          cached: true,
          cache_source: cachedData._cache_source || 'memory',
          generated_at: cachedData.generated_at || new Date().toISOString()
        };
      }

      console.log(`🔄 캐시 미스 - 새 데이터 생성: ${fortuneCategory}`);

      // 2. 새 데이터 생성
      const newData = await this.generateFortuneByGroup(
        fortuneType, 
        fortuneCategory, 
        userId, 
        userProfile, 
        interactiveInput
      );

      // 3. DB에 저장
      await this.saveToDatabase(userId, fortuneType, fortuneCategory, newData, interactiveInput);

      const endTime = Date.now();
      console.log(`⚡ 운세 생성 완료 (${endTime - startTime}ms): ${fortuneCategory}`);
      
      return {
        success: true,
        data: newData,
        cached: false,
        cache_source: 'fresh',
        generated_at: new Date().toISOString()
      };

    } catch (error) {
      const endTime = Date.now();
      console.error(`❌ FortuneService 오류 (${endTime - startTime}ms):`, error);
      
      return {
        success: false,
        error: error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다.',
        cached: false,
        generated_at: new Date().toISOString()
      };
    }
  }
  
  // Rate limiting을 위한 메모리 저장소
  private rateLimitStore: Map<string, number[]> = new Map();
  
  /**
   * Rate limiting 체크 (사용자별 분당 요청 수 제한)
   */
  private isRateLimited(userId: string, category: FortuneCategory): boolean {
    const key = `${userId}:${category}`;
    const now = Date.now();
    const windowMs = 60 * 1000; // 1분
    const maxRequests = 10; // 분당 최대 10개 요청
    
    if (!this.rateLimitStore.has(key)) {
      this.rateLimitStore.set(key, []);
    }
    
    const requests = this.rateLimitStore.get(key)!;
    
    // 오래된 요청 제거
    const validRequests = requests.filter(time => now - time < windowMs);
    
    if (validRequests.length >= maxRequests) {
      console.warn(`🚫 Rate limit 초과: ${key} (${validRequests.length}/${maxRequests})`);
      return true;
    }
    
    // 현재 요청 기록
    validRequests.push(now);
    this.rateLimitStore.set(key, validRequests);
    
    return false;
  }

  /**
   * DB에서 데이터 조회
   */
  private async getCachedFortune(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    interactiveInput?: InteractiveInput
  ): Promise<any | null> {
    try {
      // 1. Redis 캐시 확인 (선택적)
      if (this.redis) {
        const redisKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
        const cached = await this.redis.get(redisKey);
        if (cached) {
          console.log(`🚀 Redis 캐시 히트: ${fortuneCategory}`);
          const data = JSON.parse(cached);
          data._cache_source = 'redis';
          return data;
        }
      }

      // 2. DB 조회
      let query = this.supabase
        .from('fortunes')
        .select('*')
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .eq('fortune_category', fortuneCategory);

      // 그룹 3 (실시간 상호작용)의 경우 입력값 해시도 확인
      if (interactiveInput) {
        const inputHash = this.generateInputHash(interactiveInput);
        query = query.eq('input_hash', inputHash);
      }

      // 만료되지 않은 데이터만 조회
      query = query.or('expires_at.is.null,expires_at.gt.' + new Date().toISOString());

      const { data, error } = await query.single();

      if (error || !data) {
        console.log(`❌ DB 캐시 미스: ${fortuneCategory}`);
        return null;
      }

      console.log(`🚀 DB 캐시 히트: ${fortuneCategory}`);

      // Redis에 백업 저장 (있는 경우)
      if (this.redis) {
        const redisKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
        await this.redis.setex(redisKey, 3600, JSON.stringify(data.data)); // 1시간 캐시
      }

      data.data._cache_source = 'database';
      return data.data;

    } catch (error) {
      console.error('캐시 조회 중 오류:', error);
      return null;
    }
  }

  /**
   * 운세 그룹별 데이터 생성 - AI 호출
   */
  private async generateFortuneByGroup(
    groupType: FortuneGroupType, 
    category: FortuneCategory,
    userId: string,
    userProfile?: UserProfile,
    interactiveInput?: InteractiveInput
  ): Promise<any> {
    try {
      console.log(`🤖 AI 운세 생성 시작: ${category} (그룹: ${groupType})`);

      // 관련 운세들을 함께 요청할지 결정
      const relatedFortunes = this.getRelatedFortunes(category);
      
      if (relatedFortunes.length > 1 && !interactiveInput) {
        // 묶음 요청을 통한 최적화
        console.log(`📦 묶음 운세 생성: ${relatedFortunes.join(', ')}`);
        
        const batchResponse = await centralizedFortuneService.callGenkitFortuneAPI({
          request_type: 'user_direct_request',
          user_profile: {
            id: userId,
            name: userProfile?.name || '사용자',
            birth_date: userProfile?.birth_date || '1990-01-01',
            birth_time: userProfile?.birth_time,
            gender: userProfile?.gender,
            mbti: userProfile?.mbti,
            zodiac_sign: userProfile?.zodiac_sign
          },
          fortune_types: relatedFortunes,
          target_date: new Date().toISOString().split('T')[0],
          generation_context: {
            is_user_initiated: true,
            cache_duration_hours: this.getCacheDuration(category) / 3600000
          }
        });
        
        // 요청된 운세 데이터 추출
        const result = batchResponse.analysis_results[category];
        
        console.log(`✅ 묶음 운세 생성 완료: ${category}`);
        
        // 메타데이터 추가
        return {
          ...result,
          category,
          groupType,
          generated_at: batchResponse.generated_at,
          user_id: userId,
          ai_source: 'centralized_batch',
          batch_id: batchResponse.request_id
        };
        
      } else {
        // 단일 운세 생성 (기존 방식 유지)
        const { generateSingleFortune } = await import('../../ai/openai-client');
        
        const defaultProfile = {
          name: userProfile?.name || '사용자',
          birthDate: userProfile?.birth_date || '1990-01-01',
          gender: userProfile?.gender || 'unknown',
          mbti: userProfile?.mbti || null
        };

        const result = await generateSingleFortune(category, defaultProfile, interactiveInput);

        console.log(`✅ AI 운세 생성 완료: ${category}`);
        
        // 메타데이터 추가
        return {
          ...result,
          category,
          groupType,
          generated_at: new Date().toISOString(),
          user_id: userId,
          ai_source: 'openai_gpt'
        };
      }

    } catch (error) {
      console.error(`❌ AI 운세 생성 실패 (${category}):`, error);
      
      // AI 실패 시 fallback 데이터 생성
      return this.generateFallbackFortune(category, groupType, userProfile);
    }
  }

  /**
   * AI 실패 시 fallback 운세 데이터 생성
   */
  private generateFallbackFortune(
    category: FortuneCategory,
    groupType: FortuneGroupType,
    userProfile?: UserProfile
  ): any {
    console.log(`🔄 Fallback 운세 생성: ${category}`);
    
    const userName = userProfile?.name || '사용자';
    const baseData = {
      category,
      groupType,
      generated_at: new Date().toISOString(),
      ai_source: 'fallback',
      overall_score: /* TODO: Use rng.randomInt(0, 40) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 41) + 60, // 60-100점 (UI 기대 필드명)
      summary: `${userName}님의 ${category} 운세가 준비되었습니다. 더 정확한 분석을 위해 잠시 후 다시 시도해보세요.`,
      advice: "긍정적인 마음가짐으로 하루를 시작하세요.",
      lucky_items: [["파란색 아이템", "행운의 펜", "작은 선물"][/* TODO: Use rng.randomInt(0, 2) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 3)]],
      lucky_color: ["파란색", "초록색", "금색"][/* TODO: Use rng.randomInt(0, 2) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 3)],
      lucky_number: /* TODO: Use rng.randomInt(0, 8) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 9) + 1
    };

    // 그룹별 특화 데이터 추가
    switch (groupType) {
      case 'DAILY_COMPREHENSIVE':
        return {
          ...baseData,
          love_score: /* TODO: Use rng.randomInt(0, 40) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 41) + 60,    // UI 기대 필드명
          money_score: /* TODO: Use rng.randomInt(0, 40) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 41) + 60,   // UI 기대 필드명
          health_score: /* TODO: Use rng.randomInt(0, 40) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 41) + 60,  // UI 기대 필드명
          career_score: /* TODO: Use rng.randomInt(0, 40) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 41) + 60   // UI 기대 필드명 (work_luck -> career_score)
        };
        
      case 'LIFE_PROFILE':
        return {
          ...baseData,
          personality: `${userName}님은 창의적이고 성실한 분입니다.`,
          strengths: ["창의성", "성실함", "배려심"],
          challenges: ["완벽주의", "걱정 많음"]
        };
        
      default:
        return baseData;
    }
  }

  /**
   * DB에 운세 데이터 저장
   */
  private async saveToDatabase(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    data: any,
    interactiveInput?: InteractiveInput
  ): Promise<void> {
    try {
      const expiresAt = this.calculateExpiration(fortuneType);
      const inputHash = interactiveInput ? this.generateInputHash(interactiveInput) : null;
      
      // DB에 저장 (upsert 방식으로 중복 방지)
      const fortuneRecord = {
        user_id: userId,
        fortune_type: fortuneType,
        fortune_category: fortuneCategory,
        data: { ...data, _cache_source: 'database' },
        input_hash: inputHash,
        expires_at: expiresAt?.toISOString() || null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      const { error } = await this.supabase
        .from('fortunes')
        .upsert(fortuneRecord, {
          onConflict: 'user_id,fortune_category,input_hash',
          ignoreDuplicates: false
        });

      if (error) {
        console.error('DB 저장 실패:', error);
        throw error;
      }

      console.log(`💾 DB 저장 완료: ${fortuneCategory} (만료: ${expiresAt?.toLocaleString() || '무제한'})`);

      // Redis 캐시에도 저장 (선택적)
      if (this.redis) {
        const cacheKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
        await this.redis.setex(cacheKey, 3600, JSON.stringify(data)); // 1시간 캐시
        console.log(`💾 Redis 캐시 저장: ${fortuneCategory}`);
      }
      
    } catch (error) {
      console.error('DB 저장 중 오류:', error);
      throw error;
    }
  }

  /**
   * 캐시 키 생성
   */
  private generateCacheKey(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    interactiveInput?: InteractiveInput
  ): string {
    let baseKey = `fortune:${userId}:${fortuneType}:${fortuneCategory}`;
    
    if (interactiveInput) {
      const inputHash = this.generateInputHash(interactiveInput);
      baseKey += `:${inputHash}`;
    }
    
    return baseKey;
  }

  /**
   * 입력값 해시 생성
   */
  private generateInputHash(input: InteractiveInput): string {
    const inputString = JSON.stringify(input);
    return crypto.createHash('md5').update(inputString).digest('hex').substring(0, 8);
  }

  /**
   * 만료 시간 계산
   */
  private calculateExpiration(fortuneType: FortuneGroupType): Date | null {
    const now = new Date();
    
    switch (fortuneType) {
      case 'DAILY_COMPREHENSIVE':
        // 일일 운세: 자정까지
        const tomorrow = new Date(now);
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(0, 0, 0, 0);
        return tomorrow;
        
      case 'INTERACTIVE':
        // 상호작용 운세: 1시간
        return new Date(now.getTime() + 60 * 60 * 1000);
        
      case 'LIFE_PROFILE':
      case 'LOVE_PACKAGE':
      case 'CAREER_WEALTH_PACKAGE':
      case 'LUCKY_ITEMS_PACKAGE':
      case 'LIFE_CAREER_PACKAGE':
      case 'CLIENT_BASED':
        // 장기 운세: 만료 없음
        return null;
        
      default:
        // 기본: 24시간
        return new Date(now.getTime() + 24 * 60 * 60 * 1000);
    }
  }

  /**
   * 운세 카테고리의 그룹 타입 결정
   */
  private getFortuneCategoryGroup(category: FortuneCategory): FortuneGroupType {
    const categoryGroups: Record<FortuneCategory, FortuneGroupType> = {
      // 그룹 1: 평생 운세 (LIFE_PROFILE)
      'saju': 'LIFE_PROFILE',
      'talent': 'LIFE_PROFILE',
      'traditional-saju': 'LIFE_PROFILE',
      'saju-psychology': 'LIFE_PROFILE',
      'network-report': 'LIFE_PROFILE',
      'tojeong': 'LIFE_PROFILE',
      'past-life': 'LIFE_PROFILE',
      'destiny': 'LIFE_PROFILE',
      'salpuli': 'LIFE_PROFILE',
      'five-blessings': 'LIFE_PROFILE',
      'traditional-compatibility': 'LIFE_PROFILE',

      // 그룹 2: 일일 종합 운세 (DAILY_COMPREHENSIVE)  
      'daily': 'DAILY_COMPREHENSIVE',
      'today': 'DAILY_COMPREHENSIVE',
      'tomorrow': 'DAILY_COMPREHENSIVE',
      'hourly': 'DAILY_COMPREHENSIVE',
      'new-year': 'DAILY_COMPREHENSIVE',
      'timeline': 'DAILY_COMPREHENSIVE',

      // 그룹 3: 실시간 상호작용 (INTERACTIVE)
      'dream-interpretation': 'INTERACTIVE',
      'tarot': 'INTERACTIVE',
      'worry-bead': 'INTERACTIVE',
      'physiognomy': 'INTERACTIVE',

      // 그룹 4: 연애 패키지 (LOVE_PACKAGE)
      'love': 'LOVE_PACKAGE',
      'marriage': 'LOVE_PACKAGE',
      'compatibility': 'LOVE_PACKAGE',
      'couple-match': 'LOVE_PACKAGE',
      'chemistry': 'LOVE_PACKAGE',
      'ex-lover': 'LOVE_PACKAGE',
      'blind-date': 'LOVE_PACKAGE',
      'celebrity-match': 'LOVE_PACKAGE',

      // 그룹 5: 직업/재물 패키지 (CAREER_WEALTH_PACKAGE)
      'career': 'CAREER_WEALTH_PACKAGE',
      'employment': 'CAREER_WEALTH_PACKAGE',
      'business': 'CAREER_WEALTH_PACKAGE',
      'startup': 'CAREER_WEALTH_PACKAGE',
      'wealth': 'CAREER_WEALTH_PACKAGE',
      'lucky-investment': 'CAREER_WEALTH_PACKAGE',
      'lucky-realestate': 'CAREER_WEALTH_PACKAGE',
      'lucky-sidejob': 'CAREER_WEALTH_PACKAGE',

      // 그룹 6: 행운 아이템 패키지 (LUCKY_ITEMS_PACKAGE)
      'lucky-color': 'LUCKY_ITEMS_PACKAGE',
      'lucky-number': 'LUCKY_ITEMS_PACKAGE',
      'lucky-food': 'LUCKY_ITEMS_PACKAGE',
      'lucky-outfit': 'LUCKY_ITEMS_PACKAGE',
      'lucky-items': 'LUCKY_ITEMS_PACKAGE',
      'birthstone': 'LUCKY_ITEMS_PACKAGE',
      'talisman': 'LUCKY_ITEMS_PACKAGE',

      // 그룹 7: 인생/커리어 패키지 (LIFE_CAREER_PACKAGE)
      'lucky-hiking': 'LIFE_CAREER_PACKAGE',
      'lucky-baseball': 'LIFE_CAREER_PACKAGE',
      'lucky-tennis': 'LIFE_CAREER_PACKAGE',
      'lucky-fishing': 'LIFE_CAREER_PACKAGE',
      'lucky-golf': 'LIFE_CAREER_PACKAGE',
      'lucky-cycling': 'LIFE_CAREER_PACKAGE',
      'lucky-swim': 'LIFE_CAREER_PACKAGE',
      'lucky-running': 'LIFE_CAREER_PACKAGE',
      'lucky-exam': 'LIFE_CAREER_PACKAGE',
      'lucky-job': 'LIFE_CAREER_PACKAGE',

      // 그룹 8: 클라이언트 기반 (CLIENT_BASED)
      'palmistry': 'CLIENT_BASED',
      'biorhythm': 'CLIENT_BASED',
      'moving': 'CLIENT_BASED',
      'moving-date': 'CLIENT_BASED',
      'avoid-people': 'CLIENT_BASED',
      'birthdate': 'CLIENT_BASED',
      'birth-season': 'CLIENT_BASED',
      'blood-type': 'CLIENT_BASED',
      'mbti': 'CLIENT_BASED',
      'zodiac': 'CLIENT_BASED',
      'zodiac-animal': 'CLIENT_BASED',
      'wish': 'CLIENT_BASED'
    };

    return categoryGroups[category] || 'INTERACTIVE';
  }

  /**
   * 관련 운세 찾기
   */
  private getRelatedFortunes(fortuneCategory: FortuneCategory): string[] {
    // 패키지 설정에서 관련 운세 찾기
    for (const config of Object.values(FORTUNE_PACKAGES)) {
      if (config.fortunes.includes(fortuneCategory)) {
        return config.fortunes;
      }
    }
    return [fortuneCategory];
  }

  /**
   * 캐시 지속 시간 가져오기
   */
  private getCacheDuration(fortuneCategory: FortuneCategory): number {
    // 패키지 설정에서 캐시 기간 찾기
    for (const config of Object.values(FORTUNE_PACKAGES)) {
      if (config.fortunes.includes(fortuneCategory)) {
        return config.cacheDuration;
      }
    }
    
    // 기본 캐시 시간 (24시간)
    return 24 * 60 * 60 * 1000;
  }
}

// Export both named and default exports for compatibility
export const fortuneService = FortuneService.getInstance();
export default FortuneService;
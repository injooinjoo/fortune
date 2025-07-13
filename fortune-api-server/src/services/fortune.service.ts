import logger from '../utils/logger';
import { supabaseAdmin } from '../config/supabase';
import { cache, rateLimiter } from '../lib/redis';
import { getOpenAIService } from '../lib/openai';
import crypto from 'crypto';

// Type definitions
export type FortuneCategory = 
  | 'saju' | 'talent' | 'traditional-saju' | 'saju-psychology' | 'network-report' 
  | 'tojeong' | 'past-life' | 'destiny' | 'salpuli' | 'five-blessings' | 'traditional-compatibility'
  | 'daily' | 'today' | 'tomorrow' | 'hourly' | 'new-year' | 'timeline'
  | 'dream-interpretation' | 'tarot' | 'worry-bead' | 'physiognomy'
  | 'love' | 'marriage' | 'compatibility' | 'couple-match' | 'chemistry' 
  | 'ex-lover' | 'blind-date' | 'celebrity-match'
  | 'career' | 'employment' | 'business' | 'startup' | 'wealth' 
  | 'lucky-investment' | 'lucky-realestate' | 'lucky-sidejob'
  | 'lucky-color' | 'lucky-number' | 'lucky-food' | 'lucky-outfit' 
  | 'lucky-items' | 'birthstone' | 'talisman'
  | 'lucky-hiking' | 'lucky-baseball' | 'lucky-tennis' | 'lucky-fishing' 
  | 'lucky-golf' | 'lucky-cycling' | 'lucky-swim' | 'lucky-running' 
  | 'lucky-exam' | 'lucky-job'
  | 'palmistry' | 'biorhythm' | 'moving' | 'moving-date' | 'avoid-people' 
  | 'birthdate' | 'birth-season' | 'blood-type' | 'mbti' | 'zodiac' 
  | 'zodiac-animal' | 'wish';

export type FortuneGroupType = 
  | 'DAILY_COMPREHENSIVE' 
  | 'LIFE_PROFILE' 
  | 'INTERACTIVE' 
  | 'LOVE_PACKAGE'
  | 'CAREER_WEALTH_PACKAGE'
  | 'LUCKY_ITEMS_PACKAGE'
  | 'LIFE_CAREER_PACKAGE'
  | 'CLIENT_BASED';

export interface UserProfile {
  id: string;
  name: string;
  birth_date?: string;
  birth_time?: string;
  gender?: 'male' | 'female' | 'other';
  mbti?: string;
  blood_type?: 'A' | 'B' | 'AB' | 'O';
  zodiac_sign?: string;
  chinese_zodiac?: string;
  job?: string;
  location?: string;
}

export interface InteractiveInput {
  type?: string;
  data?: any;
  [key: string]: any;
}

export interface FortuneResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  cached: boolean;
  cache_source?: 'redis' | 'database' | 'fresh';
  generated_at: string;
}

export class FortuneService {
  private static instance: FortuneService;

  private constructor() {
    logger.info('FortuneService initialized');
  }

  public static getInstance(): FortuneService {
    if (!FortuneService.instance) {
      FortuneService.instance = new FortuneService();
    }
    return FortuneService.instance;
  }

  /**
   * Main entry point: Get or create fortune
   */
  async getOrCreateFortune<T = any>(
    userId: string,
    fortuneCategory: FortuneCategory,
    userProfile?: UserProfile,
    interactiveInput?: InteractiveInput
  ): Promise<FortuneResponse<T>> {
    const startTime = Date.now();
    
    try {
      logger.debug('FortuneService.getOrCreateFortune:', { userId, fortuneCategory });

      // Determine fortune type
      const fortuneType = this.getFortuneCategoryGroup(fortuneCategory);
      
      // Rate limiting check
      const rateLimitKey = `rate_limit:fortune:${userId}:${fortuneCategory}`;
      const { allowed, remaining } = await rateLimiter.checkAndIncrement(rateLimitKey, 10, 60);
      
      if (!allowed) {
        return {
          success: false,
          error: '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.',
          cached: false,
          generated_at: new Date().toISOString()
        };
      }
      
      // 1. Check cache
      const cachedData = await this.getCachedFortune(userId, fortuneType, fortuneCategory, interactiveInput);
      
      if (cachedData) {
        logger.debug(`Cache hit - ${fortuneCategory}:`, { 
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

      logger.debug(`Cache miss - generating new data: ${fortuneCategory}`);

      // 2. Generate new data
      const newData = await this.generateFortuneByGroup(
        fortuneType, 
        fortuneCategory, 
        userId, 
        userProfile, 
        interactiveInput
      );

      // 3. Save to database
      await this.saveToDatabase(userId, fortuneType, fortuneCategory, newData, interactiveInput);

      const endTime = Date.now();
      logger.debug(`Fortune generation completed (${endTime - startTime}ms): ${fortuneCategory}`);
      
      return {
        success: true,
        data: newData,
        cached: false,
        cache_source: 'fresh',
        generated_at: new Date().toISOString()
      };

    } catch (error) {
      const endTime = Date.now();
      logger.error(`FortuneService error (${endTime - startTime}ms):`, error);
      
      return {
        success: false,
        error: error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다.',
        cached: false,
        generated_at: new Date().toISOString()
      };
    }
  }

  /**
   * Get cached fortune from Redis or Database
   */
  private async getCachedFortune(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    interactiveInput?: InteractiveInput
  ): Promise<any | null> {
    try {
      // 1. Check Redis cache first
      const cacheKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
      const redisData = await cache.get(cacheKey);
      
      if (redisData) {
        logger.debug(`Redis cache hit: ${fortuneCategory}`);
        return { ...redisData, _cache_source: 'redis' };
      }

      // 2. Check database
      let query = supabaseAdmin
        .from('fortunes')
        .select('*')
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .eq('fortune_category', fortuneCategory);

      // For interactive fortunes, check input hash
      if (interactiveInput) {
        const inputHash = this.generateInputHash(interactiveInput);
        query = query.eq('input_hash', inputHash);
      }

      // Only get non-expired data
      query = query.or('expires_at.is.null,expires_at.gt.' + new Date().toISOString());

      const { data, error } = await query.single();

      if (error || !data) {
        logger.debug(`DB cache miss: ${fortuneCategory}`);
        return null;
      }

      logger.debug(`DB cache hit: ${fortuneCategory}`);

      // Save to Redis for faster access
      await cache.set(cacheKey, data.data, 3600); // 1 hour cache

      return { ...data.data, _cache_source: 'database' };

    } catch (error) {
      logger.error('Cache retrieval error:', error);
      return null;
    }
  }

  /**
   * Generate fortune data using AI
   */
  private async generateFortuneByGroup(
    groupType: FortuneGroupType, 
    category: FortuneCategory,
    userId: string,
    userProfile?: UserProfile,
    interactiveInput?: InteractiveInput
  ): Promise<any> {
    try {
      logger.debug(`Generating AI fortune: ${category} (group: ${groupType})`);

      const openaiService = getOpenAIService();
      
      // Prepare user profile for AI
      const aiProfile = {
        name: userProfile?.name || '사용자',
        birthDate: userProfile?.birth_date || '1990-01-01',
        gender: userProfile?.gender || 'unknown',
        mbti: userProfile?.mbti || null
      };

      // Generate prompt based on category
      const prompt = this.buildFortunePrompt(category, aiProfile, interactiveInput);

      // Call OpenAI
      const result = await openaiService.generateFortune({
        prompt,
        requireJson: true,
        maxTokens: 1500,
        temperature: 0.7
      });

      logger.debug(`AI fortune generated: ${category}`);
      
      // Add metadata
      return {
        ...result.parsed,
        category,
        groupType,
        generated_at: new Date().toISOString(),
        user_id: userId,
        ai_source: 'openai_gpt',
        token_usage: result.tokenUsage
      };

    } catch (error) {
      logger.error(`AI fortune generation failed (${category}):`, error);
      
      // Return fallback data
      return this.generateFallbackFortune(category, groupType, userProfile);
    }
  }

  /**
   * Build prompt for fortune generation
   */
  private buildFortunePrompt(
    category: FortuneCategory, 
    userProfile: any, 
    interactiveInput?: InteractiveInput
  ): string {
    const basePrompt = `
사용자 정보:
- 이름: ${userProfile.name}
- 생년월일: ${userProfile.birthDate}
- 성별: ${userProfile.gender || '미지정'}
- MBTI: ${userProfile.mbti || '미지정'}
- 날짜: ${new Date().toISOString().split('T')[0]}

운세 종류: ${category}
`;

    // Add category-specific prompts
    switch (category) {
      case 'daily':
      case 'today':
        return basePrompt + `
오늘의 종합 운세를 다음 JSON 형식으로 제공해주세요:
{
  "overall_score": 85,
  "summary": "오늘의 전체적인 운세 요약",
  "love_score": 80,
  "money_score": 75,
  "health_score": 90,
  "career_score": 85,
  "advice": "구체적인 조언",
  "lucky_color": "행운의 색깔",
  "lucky_number": 7,
  "lucky_items": ["행운의 아이템 1", "행운의 아이템 2"],
  "detailed_analysis": "상세한 분석 내용"
}`;

      case 'love':
        return basePrompt + `
연애운을 다음 JSON 형식으로 제공해주세요:
{
  "overall_score": 85,
  "summary": "연애운 요약",
  "single_advice": "싱글을 위한 조언",
  "couple_advice": "커플을 위한 조언",
  "compatibility_tips": "인연을 만날 수 있는 팁",
  "warning_signs": "주의해야 할 점",
  "lucky_spots": ["데이트 장소 1", "데이트 장소 2"]
}`;

      case 'career':
        return basePrompt + `
직업운을 다음 JSON 형식으로 제공해주세요:
{
  "overall_score": 85,
  "summary": "직업운 요약",
  "work_environment": "업무 환경 운세",
  "colleague_relations": "동료 관계",
  "promotion_chance": "승진/성과 가능성",
  "advice": "경력 개발 조언",
  "avoid_actions": ["피해야 할 행동"],
  "opportunity_areas": ["기회가 있는 분야"]
}`;

      default:
        return basePrompt + `
${category} 운세를 JSON 형식으로 자세히 분석해주세요. 
점수(0-100), 요약, 조언, 행운 요소 등을 포함해주세요.`;
    }
  }

  /**
   * Generate fallback fortune when AI fails
   */
  private generateFallbackFortune(
    category: FortuneCategory,
    groupType: FortuneGroupType,
    userProfile?: UserProfile
  ): any {
    logger.debug(`Generating fallback fortune: ${category}`);
    
    const userName = userProfile?.name || '사용자';
    const baseScore = Math.floor(Math.random() * 30) + 60; // 60-90
    
    const baseData = {
      category,
      groupType,
      generated_at: new Date().toISOString(),
      ai_source: 'fallback',
      overall_score: baseScore,
      summary: `${userName}님의 ${category} 운세가 준비되었습니다. 더 정확한 분석을 위해 잠시 후 다시 시도해보세요.`,
      advice: "긍정적인 마음가짐으로 하루를 시작하세요.",
      lucky_color: "파란색",
      lucky_number: 7
    };

    // Add group-specific data
    switch (groupType) {
      case 'DAILY_COMPREHENSIVE':
        return {
          ...baseData,
          love_score: Math.floor(Math.random() * 30) + 60,
          money_score: Math.floor(Math.random() * 30) + 60,
          health_score: Math.floor(Math.random() * 30) + 60,
          career_score: Math.floor(Math.random() * 30) + 60
        };
        
      default:
        return baseData;
    }
  }

  /**
   * Save fortune to database
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
      
      // 1. Save to fortunes table (for caching)
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

      const { error: fortuneError } = await supabaseAdmin
        .from('fortunes')
        .upsert(fortuneRecord, {
          onConflict: 'user_id,fortune_category,input_hash',
          ignoreDuplicates: false
        });

      if (fortuneError) {
        logger.error('Failed to save to fortunes table:', fortuneError);
        throw fortuneError;
      }

      // 2. Save to fortune_history table (permanent record)
      const tokenCost = this.getTokenCostForCategory(fortuneCategory);
      const historyRecord = {
        user_id: userId,
        fortune_type: fortuneCategory,
        fortune_data: data,
        request_data: interactiveInput || {},
        token_cost: tokenCost,
        response_time: data._response_time || null,
        model_used: data.ai_source || 'unknown',
        is_cached: false,
        created_at: new Date().toISOString()
      };

      const { error: historyError } = await supabaseAdmin
        .from('fortune_history')
        .insert(historyRecord);

      if (historyError) {
        logger.error('Failed to save to fortune_history table:', historyError);
        // Continue even if history save fails
      }

      logger.debug(`DB save completed: ${fortuneCategory}`);

      // Save to Redis cache
      const cacheKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
      await cache.set(cacheKey, data, 3600); // 1 hour cache
      
    } catch (error) {
      logger.error('Database save error:', error);
      throw error;
    }
  }

  /**
   * Generate cache key
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
   * Generate hash for input data
   */
  private generateInputHash(input: InteractiveInput): string {
    const inputString = JSON.stringify(input);
    return crypto.createHash('md5').update(inputString).digest('hex').substring(0, 8);
  }

  /**
   * Calculate expiration time
   */
  private calculateExpiration(fortuneType: FortuneGroupType): Date | null {
    const now = new Date();
    
    switch (fortuneType) {
      case 'DAILY_COMPREHENSIVE':
        // Daily fortunes: expire at midnight
        const tomorrow = new Date(now);
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(0, 0, 0, 0);
        return tomorrow;
        
      case 'INTERACTIVE':
        // Interactive fortunes: 1 hour
        return new Date(now.getTime() + 60 * 60 * 1000);
        
      case 'LIFE_PROFILE':
      case 'LOVE_PACKAGE':
      case 'CAREER_WEALTH_PACKAGE':
      case 'LUCKY_ITEMS_PACKAGE':
      case 'LIFE_CAREER_PACKAGE':
      case 'CLIENT_BASED':
        // Long-term fortunes: no expiration
        return null;
        
      default:
        // Default: 24 hours
        return new Date(now.getTime() + 24 * 60 * 60 * 1000);
    }
  }

  /**
   * Get fortune category group type
   */
  private getFortuneCategoryGroup(category: FortuneCategory): FortuneGroupType {
    const categoryGroups: Record<FortuneCategory, FortuneGroupType> = {
      // Group 1: Life Profile
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

      // Group 2: Daily Comprehensive
      'daily': 'DAILY_COMPREHENSIVE',
      'today': 'DAILY_COMPREHENSIVE',
      'tomorrow': 'DAILY_COMPREHENSIVE',
      'hourly': 'DAILY_COMPREHENSIVE',
      'new-year': 'DAILY_COMPREHENSIVE',
      'timeline': 'DAILY_COMPREHENSIVE',

      // Group 3: Interactive
      'dream-interpretation': 'INTERACTIVE',
      'tarot': 'INTERACTIVE',
      'worry-bead': 'INTERACTIVE',
      'physiognomy': 'INTERACTIVE',

      // Group 4: Love Package
      'love': 'LOVE_PACKAGE',
      'marriage': 'LOVE_PACKAGE',
      'compatibility': 'LOVE_PACKAGE',
      'couple-match': 'LOVE_PACKAGE',
      'chemistry': 'LOVE_PACKAGE',
      'ex-lover': 'LOVE_PACKAGE',
      'blind-date': 'LOVE_PACKAGE',
      'celebrity-match': 'LOVE_PACKAGE',

      // Group 5: Career/Wealth Package
      'career': 'CAREER_WEALTH_PACKAGE',
      'employment': 'CAREER_WEALTH_PACKAGE',
      'business': 'CAREER_WEALTH_PACKAGE',
      'startup': 'CAREER_WEALTH_PACKAGE',
      'wealth': 'CAREER_WEALTH_PACKAGE',
      'lucky-investment': 'CAREER_WEALTH_PACKAGE',
      'lucky-realestate': 'CAREER_WEALTH_PACKAGE',
      'lucky-sidejob': 'CAREER_WEALTH_PACKAGE',

      // Group 6: Lucky Items Package
      'lucky-color': 'LUCKY_ITEMS_PACKAGE',
      'lucky-number': 'LUCKY_ITEMS_PACKAGE',
      'lucky-food': 'LUCKY_ITEMS_PACKAGE',
      'lucky-outfit': 'LUCKY_ITEMS_PACKAGE',
      'lucky-items': 'LUCKY_ITEMS_PACKAGE',
      'birthstone': 'LUCKY_ITEMS_PACKAGE',
      'talisman': 'LUCKY_ITEMS_PACKAGE',

      // Group 7: Life/Career Package
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

      // Group 8: Client Based
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
   * Get token cost for category
   */
  private getTokenCostForCategory(fortuneCategory: FortuneCategory): number {
    const tokenCosts: Partial<Record<FortuneCategory, number>> = {
      // Simple fortunes (1 token)
      'daily': 1,
      'today': 1,
      'tomorrow': 1,
      'lucky-color': 1,
      'lucky-number': 1,
      'lucky-food': 1,
      
      // Medium complexity (2 tokens)
      'love': 2,
      'career': 2,
      'wealth': 2,
      'compatibility': 2,
      'tarot': 2,
      'dream-interpretation': 2,
      
      // Complex fortunes (3 tokens)
      'saju': 3,
      'traditional-saju': 3,
      'saju-psychology': 3,
      'tojeong': 3,
      'past-life': 3,
      'destiny': 3,
      
      // Premium fortunes (5 tokens)
      'startup': 5,
      'business': 5,
      'lucky-investment': 5,
      'lucky-realestate': 5
    };
    
    return tokenCosts[fortuneCategory] || 1; // Default 1 token
  }
}

// Export singleton instance
export const fortuneService = FortuneService.getInstance();
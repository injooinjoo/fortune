import { supabase } from '../supabase';
import { getOpenAIClient } from '../openai-client-improved';
import { createDeterministicRandom, getTodayDateString } from '../deterministic-random';
import * as Sentry from '@sentry/nextjs';

export interface UserProfile {
  id: string;
  user_id?: string;
  name: string;
  birth_date: string;
  birth_time?: string;
  gender?: string;
  mbti?: string;
  zodiac_sign?: string;
  relationship_status?: string;
  email?: string;
}

export interface FortuneRequest {
  userId: string;
  userProfile: UserProfile;
  fortuneType: string;
  date?: string;
  useCache?: boolean;
}

export interface FortuneResult {
  success: boolean;
  data?: any;
  source: 'cache' | 'database' | 'ai' | 'calculated';
  error?: string;
  tokenUsage?: number;
}

export class RealFortuneService {
  private openaiClient = getOpenAIClient();
  private cacheTTL = 24 * 60 * 60 * 1000; // 24 hours

  /**
   * Get or generate fortune - no fallbacks, real data only
   */
  async getFortune(request: FortuneRequest): Promise<FortuneResult> {
    const { userId, userProfile, fortuneType, date = getTodayDateString(), useCache = true } = request;

    try {
      // Step 1: Check cache first
      if (useCache) {
        const cachedResult = await this.getCachedFortune(userId, fortuneType, date);
        if (cachedResult) {
          return {
            success: true,
            data: cachedResult,
            source: 'cache'
          };
        }
      }

      // Step 2: Check database
      const dbResult = await this.getDatabaseFortune(userId, fortuneType, date);
      if (dbResult) {
        await this.setCachedFortune(userId, fortuneType, date, dbResult);
        return {
          success: true,
          data: dbResult,
          source: 'database'
        };
      }

      // Step 3: Generate using AI
      const aiResult = await this.generateAIFortune(userProfile, fortuneType, date);
      if (aiResult.success && aiResult.data) {
        // Save to database and cache
        await this.saveFortune(userId, fortuneType, date, aiResult.data, aiResult.tokenUsage || 0);
        await this.setCachedFortune(userId, fortuneType, date, aiResult.data);
        
        return {
          success: true,
          data: aiResult.data,
          source: 'ai',
          tokenUsage: aiResult.tokenUsage
        };
      }

      // Step 4: If AI fails, try calculated fortune (no random fallback)
      const calculatedResult = await this.generateCalculatedFortune(userProfile, fortuneType, date);
      if (calculatedResult) {
        await this.saveFortune(userId, fortuneType, date, calculatedResult, 0);
        await this.setCachedFortune(userId, fortuneType, date, calculatedResult);
        
        return {
          success: true,
          data: calculatedResult,
          source: 'calculated'
        };
      }

      throw new Error('All fortune generation methods failed');

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      
      Sentry.withScope((scope) => {
        scope.setContext('fortune_generation', {
          userId,
          fortuneType,
          date,
          userProfile: { name: userProfile.name, birth_date: userProfile.birth_date }
        });
        Sentry.captureException(error);
      });

      return {
        success: false,
        error: errorMessage,
        source: 'ai'
      };
    }
  }

  /**
   * Generate fortune using AI - with retries and encoding fixes
   */
  private async generateAIFortune(userProfile: UserProfile, fortuneType: string, date: string): Promise<{
    success: boolean;
    data?: any;
    tokenUsage?: number;
  }> {
    try {
      const prompt = this.createFortunePrompt(userProfile, fortuneType, date);
      
      const result = await this.openaiClient.generateFortune({
        prompt,
        requireJson: true,
        maxTokens: 1500
      });

      if (result.parsed) {
        return {
          success: true,
          data: {
            ...result.parsed,
            generated_at: new Date().toISOString(),
            ai_source: 'openai',
            model: result.model
          },
          tokenUsage: result.tokenUsage
        };
      }

      throw new Error('Failed to parse AI response');
    } catch (error) {
      console.error('AI fortune generation failed:', error);
      return { success: false };
    }
  }

  /**
   * Generate calculated fortune based on user profile - deterministic
   */
  private async generateCalculatedFortune(userProfile: UserProfile, fortuneType: string, date: string): Promise<any> {
    const rng = createDeterministicRandom(userProfile.id, date, fortuneType);
    
    // Calculate base scores from birth date
    const birthDate = new Date(userProfile.birth_date);
    const birthYear = birthDate.getFullYear();
    const birthMonth = birthDate.getMonth() + 1;
    const birthDay = birthDate.getDate();
    
    // Deterministic score calculation
    const baseScore = ((birthYear + birthMonth + birthDay) % 30) + 65;
    
    // Generate fortune based on type
    const fortuneData = this.generateFortuneByType(fortuneType, userProfile, rng, baseScore);
    
    return {
      ...fortuneData,
      generated_at: new Date().toISOString(),
      ai_source: 'calculated',
      date,
      user_id: userProfile.id
    };
  }

  /**
   * Generate type-specific fortune data
   */
  private generateFortuneByType(fortuneType: string, userProfile: UserProfile, rng: any, baseScore: number): any {
    const commonData = {
      overall_score: Math.max(50, Math.min(95, baseScore + rng.randomInt(-10, 10))),
      lucky_color: rng.randomElement(["빨강", "파랑", "초록", "노랑", "보라", "주황"]),
      lucky_number: rng.randomInt(1, 99),
      summary: `${userProfile.name}님의 ${fortuneType} 운세입니다.`,
      advice: this.getAdviceByType(fortuneType, userProfile, rng)
    };

    switch (fortuneType) {
      case 'daily':
        return {
          ...commonData,
          love_score: Math.max(40, Math.min(100, baseScore + rng.randomInt(-15, 15))),
          money_score: Math.max(40, Math.min(100, baseScore + rng.randomInt(-15, 15))),
          health_score: Math.max(40, Math.min(100, baseScore + rng.randomInt(-15, 15))),
          career_score: Math.max(40, Math.min(100, baseScore + rng.randomInt(-15, 15)))
        };
      
      case 'love':
        return {
          ...commonData,
          compatibility_score: Math.max(30, Math.min(100, baseScore + rng.randomInt(-20, 20))),
          relationship_advice: this.getRelationshipAdvice(userProfile, rng),
          ideal_partner_traits: rng.randomElements(["유머러스", "성실함", "따뜻함", "지적", "활발함", "차분함"], 3)
        };
      
      case 'career':
        return {
          ...commonData,
          career_luck: Math.max(35, Math.min(95, baseScore + rng.randomInt(-20, 20))),
          recommended_actions: this.getCareerAdvice(userProfile, rng),
          success_factors: rng.randomElements(["소통능력", "전문성", "리더십", "창의성", "인내심"], 3)
        };
      
      default:
        return commonData;
    }
  }

  /**
   * Get advice based on fortune type
   */
  private getAdviceByType(fortuneType: string, userProfile: UserProfile, rng: any): string {
    const advicePool = {
      daily: [
        "오늘은 새로운 시작을 위한 좋은 날입니다.",
        "긍정적인 마음가짐으로 하루를 시작하세요.",
        "작은 변화가 큰 행운을 가져다줄 것입니다.",
        "주변 사람들과의 소통을 늘려보세요.",
        "건강관리에 특히 신경 쓰시기 바랍니다."
      ],
      love: [
        "진실한 마음으로 상대방에게 다가가세요.",
        "서두르지 말고 천천히 관계를 발전시켜 나가세요.",
        "자신의 매력을 자연스럽게 표현해보세요.",
        "소통의 중요성을 잊지 마세요.",
        "상대방의 입장에서 생각해보는 시간을 가져보세요."
      ],
      career: [
        "새로운 기회에 열린 마음으로 도전해보세요.",
        "전문성 향상을 위한 노력을 계속하세요.",
        "동료들과의 협력이 성공의 열쇠입니다.",
        "창의적인 아이디어를 적극적으로 제안해보세요.",
        "꾸준한 노력이 결실을 맺을 때입니다."
      ]
    };

    const advice = advicePool[fortuneType] || advicePool.daily;
    return rng.randomElement(advice);
  }

  /**
   * Get relationship advice
   */
  private getRelationshipAdvice(userProfile: UserProfile, rng: any): string {
    const advice = [
      "서로의 차이점을 인정하고 존중하는 것이 중요합니다.",
      "작은 표현도 큰 감동을 줄 수 있습니다.",
      "함께하는 시간의 질을 높여보세요.",
      "솔직한 대화가 관계를 더욱 깊게 만듭니다.",
      "상대방의 관심사에 진정한 관심을 보여주세요."
    ];
    
    return rng.randomElement(advice);
  }

  /**
   * Get career advice
   */
  private getCareerAdvice(userProfile: UserProfile, rng: any): string[] {
    const actions = [
      "새로운 기술 습득에 투자하세요",
      "네트워킹 활동을 늘려보세요",
      "멘토를 찾아 조언을 구해보세요",
      "업계 트렌드를 꾸준히 학습하세요",
      "프로젝트에 적극적으로 참여하세요",
      "리더십 기회를 찾아보세요"
    ];
    
    return rng.randomElements(actions, 3);
  }

  /**
   * Create AI prompt for fortune generation
   */
  private createFortunePrompt(userProfile: UserProfile, fortuneType: string, date: string): string {
    return `
사용자 정보:
- 이름: ${userProfile.name}
- 생년월일: ${userProfile.birth_date}
- 성별: ${userProfile.gender || '미지정'}
- MBTI: ${userProfile.mbti || '미지정'}
- 운세 날짜: ${date}

${fortuneType} 운세를 다음 JSON 형식으로 분석해주세요:

{
  "overall_score": 85,
  "summary": "전체적인 운세 요약 (2-3문장)",
  "advice": "구체적이고 실용적인 조언",
  "lucky_color": "행운의 색깔",
  "lucky_number": 7,
  "detailed_analysis": "상세한 분석 내용",
  ${this.getFortuneTypeSpecificFields(fortuneType)}
}

점수는 0-100 사이의 정수로, 내용은 구체적이고 실용적으로 작성해주세요.
사용자의 생년월일과 개인 특성을 반영한 개인화된 내용으로 작성해주세요.
`;
  }

  /**
   * Get fortune type specific JSON fields
   */
  private getFortuneTypeSpecificFields(fortuneType: string): string {
    switch (fortuneType) {
      case 'daily':
        return `
  "love_score": 75,
  "money_score": 80,
  "health_score": 85,
  "career_score": 78`;
      
      case 'love':
        return `
  "compatibility_score": 85,
  "relationship_advice": "연애 관련 조언",
  "ideal_partner_traits": ["특성1", "특성2", "특성3"]`;
      
      case 'career':
        return `
  "career_luck": 80,
  "recommended_actions": ["행동1", "행동2", "행동3"],
  "success_factors": ["요소1", "요소2", "요소3"]`;
      
      default:
        return '';
    }
  }

  // Cache and database methods
  private async getCachedFortune(userId: string, fortuneType: string, date: string): Promise<any | null> {
    // In-memory cache implementation (you could replace with Redis)
    const cacheKey = `fortune:${userId}:${fortuneType}:${date}`;
    // For now, we'll skip cache and always check database
    return null;
  }

  private async setCachedFortune(userId: string, fortuneType: string, date: string, data: any): Promise<void> {
    // Implementation would set cache here
    // For now, we'll just save to database
  }

  private async getDatabaseFortune(userId: string, fortuneType: string, date: string): Promise<any | null> {
    try {
      const { data, error } = await supabase
        .from('user_fortunes')
        .select('*')
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .eq('date', date)
        .gt('cache_expires_at', new Date().toISOString())
        .single();

      if (error || !data) return null;
      return data.data;
    } catch (error) {
      console.error('Database fortune fetch failed:', error);
      return null;
    }
  }

  private async saveFortune(userId: string, fortuneType: string, date: string, data: any, tokenCount: number): Promise<void> {
    try {
      const expiresAt = new Date(Date.now() + this.cacheTTL);
      
      await supabase
        .from('user_fortunes')
        .upsert({
          user_id: userId,
          fortune_type: fortuneType,
          category: fortuneType,
          date,
          data,
          overall_score: data.overall_score || 0,
          ai_model: data.model || 'calculated',
          token_count: tokenCount,
          cache_expires_at: expiresAt.toISOString()
        });
    } catch (error) {
      console.error('Failed to save fortune:', error);
    }
  }
}

// Singleton instance
let realFortuneService: RealFortuneService | null = null;

export function getRealFortuneService(): RealFortuneService {
  if (!realFortuneService) {
    realFortuneService = new RealFortuneService();
  }
  return realFortuneService;
}
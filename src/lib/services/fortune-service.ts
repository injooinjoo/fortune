// 운세 서비스 - 핵심 데이터 관리 로직
// 작성일: 2024-12-19

// import { createClient } from '@supabase/supabase-js'; // 개발 단계에서는 비활성화
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

export class FortuneService {
  private supabase: any = null;
  private redis: any = null; // Redis 클라이언트 (선택적)

  constructor() {
    // 개발 단계에서는 DB 연결 없이 목 데이터만 사용
    console.log('FortuneService 초기화 - 개발 모드 (DB 연결 없음)');
    
    // 실제 프로덕션에서는 아래 코드 활성화
    // if (process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY) {
    //   this.supabase = createClient(
    //     process.env.NEXT_PUBLIC_SUPABASE_URL,
    //     process.env.SUPABASE_SERVICE_ROLE_KEY
    //   );
    // }
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
    try {
      console.log('FortuneService.getOrCreateFortune 시작:', { userId, fortuneCategory });

      // 개발 단계에서는 DB 연결 없이 직접 데이터 생성
      const newData = await this.generateFortuneByGroup(
        'LIFE_PROFILE', // 사주는 LIFE_PROFILE 그룹
        fortuneCategory,
        userId,
        userProfile,
        interactiveInput
      );

      console.log('FortuneService 데이터 생성 완료:', { success: true, dataKeys: Object.keys(newData) });

      return {
        success: true,
        data: newData,
        cached: false,
        cache_source: 'fresh',
        generated_at: new Date().toISOString()
      };

    } catch (error) {
      console.error('FortuneService.getOrCreateFortune 오류:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다.',
        cached: false,
        generated_at: new Date().toISOString()
      };
    }
  }

  /**
   * 다층 캐시에서 데이터 조회
   */
  private async getCachedFortune(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    interactiveInput?: InteractiveInput
  ): Promise<any | null> {
    try {
      // 1. Redis 캐시 확인 (가장 빠름)
      if (this.redis) {
        const redisKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
        const cached = await this.redis.get(redisKey);
        if (cached) {
          const data = JSON.parse(cached);
          data._cache_source = 'redis';
          return data;
        }
      }

      // 2. DB 캐시 확인
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
        return null;
      }

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
   * 운세 그룹별 데이터 생성
   */
  private async generateFortuneByGroup(
    groupType: FortuneGroupType,
    category: FortuneCategory,
    userId: string,
    userProfile?: UserProfile,
    interactiveInput?: InteractiveInput
  ): Promise<any> {
    switch (groupType) {
      case 'LIFE_PROFILE':
        return await this.generateLifeProfile(userId, userProfile);
      
      case 'DAILY_COMPREHENSIVE':
        return await this.generateDailyComprehensive(userId, userProfile);
      
      case 'INTERACTIVE':
        if (!interactiveInput) {
          throw new Error('실시간 상호작용 운세에는 입력 데이터가 필요합니다.');
        }
        return await this.generateInteractiveFortune(interactiveInput);
      
      case 'CLIENT_BASED':
        // 클라이언트에서 처리되므로 서버에서는 기본 데이터만 반환
        return this.generateClientBasedData(category, userProfile);
      
      default:
        throw new Error(`지원하지 않는 운세 그룹: ${groupType}`);
    }
  }

  /**
   * 그룹 1: 평생 운세 생성 (모든 항목 통합)
   */
  private async generateLifeProfile(userId: string, userProfile?: UserProfile): Promise<LifeProfileData> {
    if (!userProfile) {
      throw new Error('평생 운세 생성에는 사용자 프로필이 필요합니다.');
    }

    // 실제로는 AI Flow 호출
    // const result = await generateLifeProfileFlow({ 
    //   birthDate: userProfile.birth_date,
    //   birthTime: userProfile.birth_time,
    //   gender: userProfile.gender 
    // });

    // 임시 목 데이터 (실제 구현에서는 AI 호출)
    return {
      saju: {
        basic_info: {
          birth_year: userProfile.birth_date.split('-')[0] + '년',
          birth_month: userProfile.birth_date.split('-')[1] + '월',
          birth_day: userProfile.birth_date.split('-')[2] + '일',
          birth_time: userProfile.birth_time || '시간 미상'
        },
        four_pillars: {
          year_pillar: { heavenly: '갑', earthly: '자' },
          month_pillar: { heavenly: '을', earthly: '축' },
          day_pillar: { heavenly: '병', earthly: '인' },
          time_pillar: userProfile.birth_time ? { heavenly: '정', earthly: '묘' } : undefined
        },
        ten_gods: ['정관', '편재', '식신'],
        five_elements: { wood: 3, fire: 2, earth: 1, metal: 2, water: 2 },
        personality_analysis: `${userProfile.gender}이며 ${userProfile.mbti || 'MBTI 미상'}인 당신은 성실하고 책임감이 강한 성격입니다.`,
        life_fortune: '중년 이후 운세가 상승합니다.',
        career_fortune: '전문직이나 관리직에 적합합니다.',
        wealth_fortune: '꾸준한 저축으로 재물을 모을 수 있습니다.',
        love_fortune: '진실한 사랑을 만날 운명입니다.',
        health_fortune: '소화기 계통을 조심하세요.'
      },
      traditionalSaju: {
        lucky_gods: ['천을귀인', '태극귀인'],
        unlucky_gods: ['겁살', '망신살'],
        life_phases: [
          { age_range: '0-20세', description: '학업에 집중하는 시기', fortune_level: 7 },
          { age_range: '21-40세', description: '사회 진출과 기반 구축', fortune_level: 8 },
          { age_range: '41-60세', description: '성공과 안정의 시기', fortune_level: 9 }
        ],
        major_events: [
          { age: 25, event_type: '결혼', description: '좋은 배우자를 만날 시기' },
          { age: 35, event_type: '승진', description: '직장에서 큰 발전이 있을 것' }
        ]
      },
      tojeong: {
        yearly_fortune: '올해는 새로운 시작의 해입니다.',
        monthly_fortunes: [
          { month: 1, fortune: '새로운 계획을 세우기 좋은 달', advice: '목표를 명확히 하세요' },
          { month: 2, fortune: '인간관계에 변화가 있을 달', advice: '소통에 신경 쓰세요' }
        ],
        major_cautions: ['성급한 투자 주의', '건강 관리 필요'],
        opportunities: ['새로운 인맥 형성', '기술 습득 기회']
      },
      pastLife: {
        past_identity: '조선시대 학자',
        past_location: '한양',
        past_era: '조선 중기',
        karmic_lessons: ['겸손함 배우기', '타인을 돕는 마음'],
        soul_mission: '지식을 나누고 후학을 양성하는 것',
        past_relationships: ['스승과 제자 관계', '동료 학자들과의 우정']
      },
      personality: {
        core_traits: ['성실함', '책임감', '완벽주의'],
        strengths: ['분석력', '집중력', '신뢰성'],
        weaknesses: ['고집', '완고함', '스트레스 취약'],
        communication_style: '논리적이고 체계적',
        decision_making: '신중하고 분석적',
        stress_response: '혼자서 해결하려 함',
        ideal_career: ['연구원', '교수', '전문직'],
        relationship_style: '진실하고 헌신적'
      },
      destiny: {
        life_purpose: '지식과 지혜를 나누는 것',
        major_challenges: ['완벽주의 극복', '유연성 기르기'],
        key_opportunities: ['40대 이후 큰 성공', '해외 진출 기회'],
        spiritual_growth: '명상과 성찰을 통한 내적 성장',
        material_success: '꾸준한 노력으로 안정적 성공',
        relationship_destiny: '평생 함께할 동반자를 만남'
      },
      salpuli: {
        detected_sal: ['겁살'],
        sal_effects: [
          {
            sal_name: '겁살',
            description: '재물 손실 위험',
            severity: 3,
            remedy: '꾸준한 저축과 신중한 투자'
          }
        ],
        purification_methods: ['소금 정화', '향 피우기'],
        protection_advice: ['붉은 옷 피하기', '북쪽 방향 주의']
      },
      fiveBlessings: {
        longevity: { score: 85, description: '장수할 운명입니다' },
        wealth: { score: 75, description: '중간 정도의 재물운' },
        health: { score: 80, description: '전반적으로 건강한 편' },
        virtue: { score: 90, description: '덕이 높은 사람' },
        peaceful_death: { score: 85, description: '평안한 임종' },
        overall_blessing: '전체적으로 복이 많은 인생'
      },
      talent: {
        innate_talents: ['분석력', '언어 능력', '리더십'],
        hidden_abilities: ['예술적 감각', '직감력'],
        development_potential: [
          {
            skill: '글쓰기',
            potential_level: 9,
            development_advice: '꾸준한 연습으로 전문가 수준까지 가능'
          }
        ],
        career_recommendations: ['작가', '교수', '컨설턴트'],
        learning_style: '체계적이고 단계적 학습 선호'
      }
    };
  }

  /**
   * 그룹 2: 일일 종합 운세 생성
   */
  private async generateDailyComprehensive(userId: string, userProfile?: UserProfile): Promise<DailyComprehensiveData> {
    const today = new Date().toISOString().split('T')[0];
    
    // 실제로는 AI Flow 호출
    // const result = await generateDailyComprehensiveFlow({
    //   date: today,
    //   userProfile
    // });

    // 임시 목 데이터
    return {
      date: today,
      overall_fortune: {
        score: 78,
        summary: '전반적으로 좋은 하루가 될 것입니다.',
        key_points: ['새로운 기회 발견', '인간관계 개선', '건강 주의'],
        energy_level: 8,
        mood_forecast: '긍정적이고 활기찬 기분'
      },
      detailed_fortunes: {
        wealth: {
          score: 75,
          description: '작은 수익이 있을 수 있습니다.',
          investment_advice: '안전한 투자 위주로',
          spending_caution: ['충동구매 주의', '큰 지출 피하기']
        },
        love: {
          score: 82,
          description: '연인과의 관계가 더욱 깊어질 것입니다.',
          single_advice: '새로운 만남의 기회가 있습니다',
          couple_advice: '솔직한 대화를 나누세요',
          meeting_probability: 70
        },
        career: {
          score: 80,
          description: '업무에서 좋은 성과를 낼 수 있습니다.',
          work_focus: ['팀워크', '창의적 아이디어'],
          meeting_luck: '중요한 회의에서 좋은 결과',
          decision_timing: '오후 시간대가 좋음'
        },
        health: {
          score: 70,
          description: '전반적으로 양호하나 피로 주의',
          body_care: ['충분한 수분 섭취', '목과 어깨 스트레칭'],
          mental_care: ['명상', '충분한 휴식'],
          exercise_recommendation: '가벼운 산책이나 요가'
        }
      },
      lucky_elements: {
        numbers: [7, 14, 23],
        colors: ['파란색', '흰색'],
        foods: ['생선', '견과류'],
        items: ['은 액세서리', '푸른 돌'],
        directions: ['동쪽', '남동쪽'],
        times: ['오전 10시', '오후 3시']
      },
      hourly_fortune: [
        { hour: '06-08', fortune_level: 6, activity_recommendation: '가벼운 운동' },
        { hour: '08-10', fortune_level: 8, activity_recommendation: '중요한 업무 처리' },
        { hour: '10-12', fortune_level: 9, activity_recommendation: '회의나 상담' }
      ],
      biorhythm: {
        physical: 75,
        emotional: 80,
        intellectual: 85,
        intuitive: 70
      },
      zodiac_compatibility: {
        best_matches: ['용', '원숭이'],
        avoid_signs: ['호랑이', '뱀'],
        daily_interaction: '용띠 사람과 좋은 협력 관계'
      },
      mbti_daily: {
        energy_focus: '외향적 활동에 집중',
        decision_style: '직감을 믿고 결정하세요',
        social_recommendation: '새로운 사람들과 만남',
        productivity_tip: '오전에 집중력이 높음'
      }
    };
  }

  /**
   * 그룹 3: 실시간 상호작용 운세 생성
   */
  private async generateInteractiveFortune(input: InteractiveInput): Promise<any> {
    // 실제로는 각 타입별 AI Flow 호출
    switch (input.type) {
      case 'dream':
        // return await interpretDreamFlow(input.data);
        return { interpretation: '꿈 해몽 결과', symbols: ['물', '산'], meaning: '새로운 시작' };
      
      case 'tarot':
        // return await tarotReadingFlow(input.data);
        return { cards: ['마법사', '연인', '별'], reading: '타로 해석 결과' };
      
      case 'compatibility':
        // return await calculateCompatibilityFlow(input.data);
        return { score: 85, analysis: '궁합 분석 결과' };
      
      case 'worry':
        // return await worryBeadFlow(input.data);
        return { advice: '고민 해결 조언', action_plan: ['단계1', '단계2'] };
      
      default:
        throw new Error(`지원하지 않는 상호작용 타입: ${input.type}`);
    }
  }

  /**
   * 그룹 4: 클라이언트 기반 데이터 생성
   */
  private generateClientBasedData(category: FortuneCategory, userProfile?: UserProfile): any {
    // 클라이언트에서 처리할 기본 데이터만 반환
    return {
      category,
      processing_type: 'client',
      user_data: userProfile ? {
        birth_date: userProfile.birth_date,
        mbti: userProfile.mbti
      } : null,
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 운세 데이터 저장
   */
  private async saveFortune(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    data: any,
    expiresHours?: number,
    interactiveInput?: InteractiveInput
  ): Promise<void> {
    const expiresAt = expiresHours 
      ? new Date(Date.now() + expiresHours * 60 * 60 * 1000).toISOString()
      : null;

    const inputHash = interactiveInput 
      ? this.generateInputHash(interactiveInput)
      : null;

    const { error } = await this.supabase
      .from('fortunes')
      .insert({
        user_id: userId,
        fortune_type: fortuneType,
        fortune_category: fortuneCategory,
        data: data,
        input_hash: inputHash,
        expires_at: expiresAt
      });

    if (error) {
      throw new Error(`운세 데이터 저장 실패: ${error.message}`);
    }
  }

  /**
   * 운세 조회 히스토리 기록
   */
  private async recordFortuneHistory(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    data: any
  ): Promise<void> {
    try {
      await this.supabase
        .from('fortune_history')
        .insert({
          user_id: userId,
          fortune_type: fortuneType,
          fortune_category: fortuneCategory,
          data_snapshot: data
        });
    } catch (error) {
      // 히스토리 기록 실패는 전체 프로세스를 중단시키지 않음
      console.warn('히스토리 기록 실패:', error);
    }
  }

  /**
   * 운세 카테고리 그룹 정보 조회
   */
  private async getCategoryGroup(category: FortuneCategory): Promise<FortuneCategoryGroup | null> {
    const { data, error } = await this.supabase
      .from('fortune_category_groups')
      .select('*')
      .eq('category', category)
      .single();

    if (error || !data) {
      return null;
    }

    return data;
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
    let key = `fortune:${userId}:${fortuneType}:${fortuneCategory}`;
    
    if (interactiveInput) {
      const inputHash = this.generateInputHash(interactiveInput);
      key += `:${inputHash}`;
    }

    return key;
  }

  /**
   * 입력값 해시 생성
   */
  private generateInputHash(input: InteractiveInput): string {
    const inputString = JSON.stringify(input.data);
    return crypto.createHash('md5').update(inputString).digest('hex');
  }

  /**
   * 만료된 운세 데이터 정리
   */
  async cleanupExpiredFortunes(): Promise<void> {
    try {
      const { error } = await this.supabase.rpc('cleanup_expired_fortunes');
      if (error) {
        throw error;
      }
      console.log('만료된 운세 데이터 정리 완료');
    } catch (error) {
      console.error('데이터 정리 중 오류:', error);
    }
  }
}

// 싱글톤 인스턴스 생성
export const fortuneService = new FortuneService(); 
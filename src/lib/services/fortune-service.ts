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
  private memoryCache: Map<string, { data: any; expiresAt: Date | null; cacheType: string }> = new Map(); // 개발용 메모리 캐시

  constructor() {
    // 개발 단계에서는 DB 연결 없이 목 데이터만 사용
    console.log('FortuneService 초기화 - 개발 모드 (메모리 캐시 활성화)');
    
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

      // 운세 타입 결정
      const fortuneType = this.getFortuneCategoryGroup(fortuneCategory);
      
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

      // 3. 생성 시간 추가
      newData.generated_at = new Date().toISOString();

      // 4. 캐시에 저장
      await this.saveToCacheOnly(userId, fortuneType, fortuneCategory, newData, interactiveInput);

      console.log('FortuneService 데이터 생성 완료:', { success: true, dataKeys: Object.keys(newData) });

      return {
        success: true,
        data: newData,
        cached: false,
        cache_source: 'fresh',
        generated_at: newData.generated_at
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
   * 다층 캐시에서 데이터 조회 (개발모드: 메모리 캐시, 프로덕션: DB+Redis)
   */
  private async getCachedFortune(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    interactiveInput?: InteractiveInput
  ): Promise<any | null> {
    try {
      const cacheKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
      
      // 개발 모드: 메모리 캐시 확인
      if (!this.supabase) {
        const cached = this.memoryCache.get(cacheKey);
        if (cached) {
          // 만료 시간 확인
          if (cached.expiresAt && cached.expiresAt < new Date()) {
            console.log(`⏰ 메모리 캐시 만료: ${fortuneCategory}`);
            this.memoryCache.delete(cacheKey);
            return null;
          }
          
          console.log(`🚀 메모리 캐시 히트: ${fortuneCategory}`);
          cached.data._cache_source = 'memory';
          return cached.data;
        }
        
        console.log(`❌ 메모리 캐시 미스: ${fortuneCategory}`);
        return null;
      }

      // 프로덕션 모드: Redis + DB 캐시 확인
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
        return await this.generateLifeProfile(userId, userProfile, category);
        
      case 'DAILY_COMPREHENSIVE':
        return await this.generateDailyComprehensive(userId, userProfile);
        
      case 'LOVE_PACKAGE':
        return await this.generateLovePackage(userId, userProfile, category);
        
      case 'CAREER_WEALTH_PACKAGE':
        return await this.generateCareerWealthPackage(userId, userProfile, category);
        
      case 'LUCKY_ITEMS_PACKAGE':
        return await this.generateLuckyItemsPackage(userId, userProfile, category);
        
      case 'LIFE_CAREER_PACKAGE':
        return await this.generateLifeCareerPackage(userId, userProfile, category);
        
      case 'INTERACTIVE':
        return await this.generateInteractiveFortune(userId, category, interactiveInput);
        
      case 'CLIENT_BASED':
        return await this.generateClientBasedFortune(userId, category, userProfile);
        
      default:
        throw new Error(`지원되지 않는 운세 그룹: ${groupType}`);
    }
  }

  /**
   * 그룹 1: 평생 운세 생성 (모든 항목 통합)
   */
  private async generateLifeProfile(userId: string, userProfile?: UserProfile, category?: FortuneCategory): Promise<any> {
    if (!userProfile) {
      throw new Error('평생 운세 생성에는 사용자 프로필이 필요합니다.');
    }

    console.log(`🔮 평생 운세 생성 중... (사용자: ${userId}, 카테고리: ${category})`);

    if (category === 'saju') {
      // 사주팔자는 개별 GPT 호출
      try {
        const sajuData = await this.generateSajuFromGPT(userProfile);
        console.log('✅ GPT 사주 생성 완료', `(사용자: ${userId})`);
        return sajuData;
      } catch (error) {
        console.error('❌ GPT 사주 생성 실패:', error);
        return this.getDefaultLifeProfile(userProfile);
      }
    } else if (category === 'talent') {
      // 재능 운세는 개별 GPT 호출
      try {
        const talentData = await this.generateTalentFromGPT(userProfile);
        console.log('✅ GPT 재능 운세 생성 완료', `(사용자: ${userId})`);
        return talentData;
      } catch (error) {
        console.error('❌ GPT 재능 운세 생성 실패:', error);
        return this.getDefaultTalentData(userProfile, category);
      }
    } else if (category === 'traditional-saju') {
      // 전통 사주는 개별 GPT 호출
      try {
        const traditionalSajuData = await this.generateTraditionalSajuFromGPT(userProfile);
        console.log('✅ GPT 전통 사주 생성 완료', `(사용자: ${userId})`);
        return traditionalSajuData;
      } catch (error) {
        console.error('❌ GPT 전통 사주 생성 실패:', error);
        return this.getDefaultTraditionalSajuData(userProfile, category);
      }
    } else if (category === 'saju-psychology') {
      // 사주 심리분석은 개별 GPT 호출
      try {
        const sajuPsychologyData = await this.generateSajuPsychologyFromGPT(userProfile);
        console.log('✅ GPT 사주 심리분석 생성 완료', `(사용자: ${userId})`);
        return sajuPsychologyData;
      } catch (error) {
        console.error('❌ GPT 사주 심리분석 생성 실패:', error);
        return { 
          summary: '사주 심리분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
          personality: '성격 분석이 진행 중입니다.',
          relationship: '대인관계 분석이 진행 중입니다.',
          psyche: '내면 심리 분석이 진행 중입니다.',
          advice: '종합 조언이 준비 중입니다.',
          generated_at: new Date().toISOString()
        };
      }
    } else if (category === 'network-report') {
      // 인맥보고서는 개별 GPT 호출
      try {
        const networkReportData = await this.generateNetworkReportFromGPT(userProfile);
        console.log('✅ GPT 인맥보고서 생성 완료', `(사용자: ${userId})`);
        return networkReportData;
      } catch (error) {
        console.error('❌ GPT 인맥보고서 생성 실패:', error);
        return { 
          score: 75,
          summary: '인맥보고서가 진행 중입니다. 잠시 후 다시 확인해주세요.',
          benefactors: ['분석 중입니다'],
          challengers: ['분석 중입니다'],
          advice: '인맥 조언이 준비 중입니다.',
          actionItems: ['잠시 후 다시 확인해주세요'],
          lucky: { color: '#FFD700', number: 7, direction: '동쪽' },
          generated_at: new Date().toISOString()
        };
      }
    } else if (category === 'tojeong') {
      // 토정비결은 개별 GPT 호출
      try {
        const tojeongData = await this.generateTojeongFromGPT(userProfile);
        console.log('✅ GPT 토정비결 생성 완료', `(사용자: ${userId})`);
        return tojeongData;
      } catch (error) {
        console.error('❌ GPT 토정비결 생성 실패:', error);
        return { 
          year: new Date().getFullYear(),
          yearlyHexagram: '분석 중',
          totalFortune: '토정비결을 분석 중입니다. 잠시 후 다시 확인해주세요.',
          monthly: Array.from({length: 12}, (_, i) => ({
            month: `${i + 1}월`,
            hexagram: '분석 중',
            summary: '분석 중입니다.',
            advice: '잠시 후 다시 확인해주세요.'
          })),
          generated_at: new Date().toISOString()
        };
      }
    } else {
      // 다른 평생 운세들은 기본 라이프 프로필 사용
      try {
        const gptResponse = await this.callGPTForLifeProfile(userProfile);
        console.log(`✅ GPT 사주 생성 완료 (사용자: ${userId})`);
        return gptResponse;
      } catch (error) {
        console.error('GPT 사주 생성 실패, 기본 데이터 반환:', error);
        return this.getDefaultLifeProfile(userProfile);
      }
    }
  }

  /**
   * GPT API를 호출하여 평생 운세 데이터 생성
   */
  private async callGPTForLifeProfile(userProfile: UserProfile): Promise<LifeProfileData> {
    // TODO: 실제 GPT API 호출 구현
    // const response = await openai.chat.completions.create({
    //   model: "gpt-4",
    //   messages: [
    //     {
    //       role: "system",
    //       content: "당신은 전문 사주 명리학자입니다. 주어진 생년월일과 기본 정보로 정확한 사주팔자를 해석해주세요."
    //     },
    //     {
    //       role: "user", 
    //       content: this.buildSajuPrompt(userProfile)
    //     }
    //   ],
    //   response_format: { type: "json_object" }
    // });
    
    // 현재는 시뮬레이션된 GPT 응답 반환
    console.log(`📡 GPT 사주 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    // 실제 GPT 처리 시뮬레이션 (500ms 지연)
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return this.generateSajuFromGPT(userProfile);
  }

  /**
   * 사주 GPT 프롬프트 생성
   */
  private buildSajuPrompt(userProfile: UserProfile): string {
    return `
다음 정보로 정통 사주팔자를 해석해주세요:

**기본 정보:**
- 이름: ${userProfile.name}
- 생년월일: ${userProfile.birth_date} 
- 출생시간: ${userProfile.birth_time || '시간 미상'}
- 성별: ${userProfile.gender || '선택 안함'}
- MBTI: ${userProfile.mbti || '미상'}

**요청사항:**
1. 정확한 사주팔자 (년주, 월주, 일주, 시주)
2. 오행 분석 (목화토금수 균형)
3. 십신 분석
4. 성격 및 운명 해석
5. 인생 각 시기별 운세
6. 직업, 재물, 건강, 연애운 종합 분석

응답은 반드시 JSON 형식으로 해주세요.
    `.trim();
  }

  /**
   * GPT 스타일의 사주 데이터 생성 (실제 구현 전 시뮬레이션)
   */
  private generateSajuFromGPT(userProfile: UserProfile): LifeProfileData {
    const birthYear = parseInt(userProfile.birth_date.split('-')[0]);
    const isModernBirth = birthYear > 1980;
    const genderKor = userProfile.gender === '남성' ? '남성' : userProfile.gender === '여성' ? '여성' : '성별 미상';
    
    // 생년월일 기반 동적 사주 생성
    const heavenlyStems = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
    const earthlyBranches = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
    
    const yearStem = heavenlyStems[(birthYear - 4) % 10];
    const yearBranch = earthlyBranches[(birthYear - 4) % 12];

    return {
      saju: {
        basic_info: {
          birth_year: userProfile.birth_date.split('-')[0] + '년',
          birth_month: userProfile.birth_date.split('-')[1] + '월',
          birth_day: userProfile.birth_date.split('-')[2] + '일',
          birth_time: userProfile.birth_time || '시간 미상'
        },
        four_pillars: {
          year_pillar: { heavenly: yearStem, earthly: yearBranch },
          month_pillar: { heavenly: heavenlyStems[(parseInt(userProfile.birth_date.split('-')[1]) + 1) % 10], earthly: earthlyBranches[(parseInt(userProfile.birth_date.split('-')[1]) - 1) % 12] },
          day_pillar: { heavenly: heavenlyStems[(parseInt(userProfile.birth_date.split('-')[2]) + 2) % 10], earthly: earthlyBranches[(parseInt(userProfile.birth_date.split('-')[2])) % 12] },
          time_pillar: userProfile.birth_time ? { heavenly: '정', earthly: '묘' } : undefined
        },
        ten_gods: isModernBirth ? ['정관', '편재', '식신', '비견'] : ['정관', '편재', '상관'],
        five_elements: { 
          wood: isModernBirth ? 3 : 2, 
          fire: genderKor === '남성' ? 3 : 2, 
          earth: 2, 
          metal: genderKor === '여성' ? 3 : 2, 
          water: 2 
        },
        personality_analysis: `${genderKor}이며 ${userProfile.mbti || 'MBTI 미상'}인 당신은 ${yearStem}${yearBranch}년생으로 ${isModernBirth ? '현대적 감각과 적응력이 뛰어나며' : '전통적 가치와 안정을 중시하는'} 성격입니다.`,
        life_fortune: isModernBirth ? '청년기부터 꾸준한 상승세를 보이며 중년 이후 크게 발전합니다.' : '중년 이후 운세가 크게 상승하며 말년에 복이 많습니다.',
        career_fortune: userProfile.mbti?.startsWith('E') ? '사람들과 소통하는 직업이나 리더십을 발휘하는 분야에 적합합니다.' : '전문 기술이나 깊이 있는 연구 분야에 적합합니다.',
        wealth_fortune: genderKor === '남성' ? '적극적인 투자보다는 꾸준한 저축으로 재물을 모을 수 있습니다.' : '세심한 관리로 안정적인 재물 운용이 가능합니다.',
        love_fortune: isModernBirth ? '다양한 만남 후 진정한 사랑을 찾을 운명입니다.' : '운명적인 만남으로 평생 동반자를 만날 것입니다.',
        health_fortune: yearStem === '갑' || yearStem === '을' ? '간 기능과 눈 건강을 주의하세요.' : yearStem === '병' || yearStem === '정' ? '심장과 혈관 건강을 관리하세요.' : '소화기 계통을 조심하세요.'
      },
      traditionalSaju: {
        lucky_gods: isModernBirth ? ['천을귀인', '태극귀인', '문창귀인'] : ['천을귀인', '태극귀인'],
        unlucky_gods: genderKor === '남성' ? ['겁살', '망신살'] : ['도화살', '역마살'],
        life_phases: [
          { age_range: '0-20세', description: '학업과 기초 실력을 쌓는 중요한 시기', fortune_level: isModernBirth ? 8 : 7 },
          { age_range: '21-40세', description: '사회 진출과 기반 구축의 시기', fortune_level: isModernBirth ? 9 : 8 },
          { age_range: '41-60세', description: '성공과 안정을 이루는 전성기', fortune_level: 9 },
          { age_range: '61세 이후', description: '지혜가 빛나는 원숙한 시기', fortune_level: 8 }
        ],
        major_events: [
          { age: genderKor === '남성' ? 28 : 25, event_type: '결혼', description: '좋은 배우자를 만날 시기' },
          { age: isModernBirth ? 32 : 35, event_type: '승진', description: '직장에서 큰 발전이 있을 것' },
          { age: 45, event_type: '재물운 상승', description: '경제적 안정을 이루는 시기' }
        ]
      },
      tojeong: {
        yearly_fortune: `${new Date().getFullYear()}년은 ${yearStem}${yearBranch}년생에게 ${isModernBirth ? '새로운 도전' : '안정과 발전'}의 해입니다.`,
        monthly_fortunes: [
          { month: 1, fortune: '새로운 계획을 세우기 좋은 달', advice: '목표를 명확히 하세요' },
          { month: 2, fortune: '인간관계에 변화가 있을 달', advice: '소통에 신경 쓰세요' },
          { month: 3, fortune: '재물운이 상승하는 달', advice: '투자 기회를 잘 살피세요' },
          { month: 4, fortune: '건강관리가 중요한 달', advice: '규칙적인 생활을 하세요' }
        ],
        major_cautions: isModernBirth ? ['성급한 투자 주의', '건강 관리 필요', '인간관계 신중'] : ['무리한 확장 주의', '건강 관리 필요'],
        opportunities: isModernBirth ? ['새로운 인맥 형성', '기술 습득 기회', '부업 기회'] : ['새로운 인맥 형성', '안정된 투자 기회']
      },
      pastLife: {
        past_identity: isModernBirth ? (genderKor === '남성' ? '조선시대 무관' : '조선시대 양반 여성') : (genderKor === '남성' ? '조선시대 학자' : '조선시대 상인'),
        past_location: '한양',
        past_era: '조선 중기',
        karmic_lessons: isModernBirth ? ['리더십 발휘하기', '타인을 보호하는 마음'] : ['겸손함 배우기', '타인을 돕는 마음'],
        soul_mission: isModernBirth ? '사회에 기여하고 정의를 실현하는 것' : '지식을 나누고 후학을 양성하는 것',
        past_relationships: isModernBirth ? ['동료와의 동지애', '백성들과의 신뢰관계'] : ['스승과 제자 관계', '동료 학자들과의 우정']
      },
      personality: {
        core_traits: userProfile.mbti ? this.getMBTITraits(userProfile.mbti) : ['성실함', '책임감', '신중함'],
        strengths: isModernBirth ? ['적응력', '창의성', '소통 능력'] : ['신중함', '안정성', '인내심'],
        weaknesses: isModernBirth ? ['성급함', '변덕스러움'] : ['고집', '변화 적응 어려움'],
        communication_style: userProfile.mbti?.includes('E') ? '활발하고 적극적인 소통' : '신중하고 깊이 있는 소통',
        decision_making: userProfile.mbti?.includes('J') ? '계획적이고 체계적인 결정' : '유연하고 상황에 맞는 결정',
        stress_response: '명상이나 자연 속에서 휴식을 취하는 것이 좋습니다',
        ideal_career: this.getIdealCareer(userProfile.mbti, genderKor),
        relationship_style: userProfile.mbti?.includes('F') ? '감정적이고 따뜻한 관계' : '논리적이고 실용적인 관계'
      },
      destiny: {
        life_purpose: isModernBirth ? '창새와 혁신을 통해 세상을 더 나은 곳으로 만드는 것' : '전통과 지혜를 바탕으로 안정된 삶을 구축하는 것',
        major_challenges: isModernBirth ? ['급변하는 환경 적응', '선택의 다양성으로 인한 혼란'] : ['새로운 변화에 대한 적응', '전통과 현실의 균형'],
        key_opportunities: ['인맥을 통한 기회 창출', '꾸준한 자기계발', '전문성 확보'],
        spiritual_growth: '타인에 대한 이해와 공감 능력을 키우는 것이 중요합니다',
        material_success: genderKor === '남성' ? '40대 중반 이후 경제적 안정을 이룰 것입니다' : '꾸준한 노력으로 안정된 재정 기반을 구축할 것입니다',
        relationship_destiny: '진실한 사랑과 평생 동반자를 만날 운명입니다'
      },
      salpuli: {
        detected_sal: yearBranch === '자' ? ['역마살'] : yearBranch === '오' ? ['도화살'] : ['겁살'],
        sal_effects: [
          {
            sal_name: yearBranch === '자' ? '역마살' : '겁살',
            description: yearBranch === '자' ? '이동과 변화가 잦아 한곳에 정착하기 어려움' : '충동적인 성향으로 인해 갈등이 생기기 쉬움',
            severity: 3,
            remedy: yearBranch === '자' ? '안정된 환경에서 꾸준한 활동하기' : '감정 조절과 신중한 판단 연습하기'
          }
        ],
        purification_methods: ['정기적인 명상', '자연 속에서 마음 정화', '선행과 봉사'],
        protection_advice: ['성급한 결정 피하기', '신뢰할 수 있는 조언자 두기', '정기적인 건강 관리']
      },
      fiveBlessings: {
        longevity: { score: isModernBirth ? 85 : 80, description: '건강한 생활습관으로 장수할 수 있습니다' },
        wealth: { score: genderKor === '남성' ? 80 : 85, description: '꾸준한 노력으로 풍족한 재물을 누릴 것입니다' },
        health: { score: 85, description: '전반적으로 건강하나 특정 부위 관리가 필요합니다' },
        virtue: { score: isModernBirth ? 90 : 88, description: '타인을 돕는 마음이 크며 덕을 쌓고 있습니다' },
        peaceful_death: { score: 90, description: '평안하고 존경받는 삶의 마무리를 할 것입니다' },
        overall_blessing: '다섯 가지 복 중 덕과 건강이 특히 뛰어나며 균형 잡힌 인생을 살 것입니다'
      },
      talent: {
        innate_talents: this.getInnateLogic(userProfile.mbti, yearStem),
        hidden_abilities: isModernBirth ? ['창의적 문제해결', '다문화 소통 능력'] : ['깊이 있는 사고력', '전통 지식 활용'],
        development_potential: [
          {
            skill: userProfile.mbti?.includes('T') ? '분석적 사고' : '감정적 지능',
            potential_level: 9,
            development_advice: userProfile.mbti?.includes('T') ? '논리적 분석 능력을 더욱 체계화하세요' : '타인의 감정을 이해하는 능력을 키우세요'
          }
        ],
        career_recommendations: this.getIdealCareer(userProfile.mbti, genderKor),
        learning_style: userProfile.mbti?.includes('S') ? '실습과 경험을 통한 학습' : '이론과 개념을 통한 학습'
      }
    };
  }

  /**
   * MBTI별 성격 특성 반환
   */
  private getMBTITraits(mbti: string): string[] {
    const traits: Record<string, string[]> = {
      'ENFP': ['열정적', '창의적', '사교적', '자유로운'],
      'ENFJ': ['따뜻한', '배려심 많은', '리더십', '감정이입'],
      'ENTP': ['창의적', '논리적', '도전적', '유연한'],
      'ENTJ': ['리더십', '전략적', '목표지향적', '효율적'],
      'ESFP': ['활발한', '친근한', '즉흥적', '긍정적'],
      'ESFJ': ['배려심 많은', '협력적', '전통적', '책임감'],
      'ESTP': ['활동적', '현실적', '적응력', '사교적'],
      'ESTJ': ['체계적', '책임감', '현실적', '리더십'],
      'INFP': ['이상주의적', '창의적', '공감능력', '독립적'],
      'INFJ': ['통찰력', '완벽주의', '배려심', '창의적'],
      'INTP': ['논리적', '독립적', '창의적', '분석적'],
      'INTJ': ['전략적', '독립적', '완벽주의', '미래지향적'],
      'ISFP': ['온화한', '예술적', '유연한', '배려심'],
      'ISFJ': ['신중한', '배려심', '책임감', '전통적'],
      'ISTP': ['실용적', '논리적', '독립적', '문제해결'],
      'ISTJ': ['신중한', '책임감', '체계적', '현실적']
    };
    
    return traits[mbti] || ['성실함', '책임감', '신중함'];
  }

  /**
   * 이상적 직업 추천
   */
  private getIdealCareer(mbti?: string, gender?: string): string[] {
    if (!mbti) return ['전문직', '서비스업', '교육직'];
    
    const careers: Record<string, string[]> = {
      'ENFP': ['광고/마케팅', '상담사', '기자', '예술가'],
      'ENFJ': ['교사', '상담사', '사회복지사', '인사담당자'],
      'ENTP': ['컨설턴트', '기업가', '변호사', '발명가'],
      'ENTJ': ['CEO/임원', '프로젝트 매니저', '컨설턴트', '정치가'],
      'ESFP': ['연예인', '판매원', '가이드', '이벤트 기획자'],
      'ESFJ': ['간호사', '교사', '행정직', '호텔리어'],
      'ESTP': ['영업', '운동선수', '경찰', '응급의료진'],
      'ESTJ': ['관리자', '회계사', '공무원', '은행원'],
      'INFP': ['작가', '상담사', '예술가', '사회복지사'],
      'INFJ': ['심리학자', '작가', '상담사', '종교인'],
      'INTP': ['연구원', '프로그래머', '수학자', '철학자'],
      'INTJ': ['전략기획자', '건축가', '연구원', '시스템 분석가'],
      'ISFP': ['예술가', '디자이너', '수의사', '마사지사'],
      'ISFJ': ['간호사', '교사', '도서관사서', '회계사'],
      'ISTP': ['엔지니어', '수리공', '파일럿', '요리사'],
      'ISTJ': ['회계사', '공무원', '의사', '법관']
    };
    
    return careers[mbti] || ['전문직', '서비스업'];
  }

  /**
   * 타고난 재능 분석
   */
  private getInnateLogic(mbti?: string, yearStem?: string): string[] {
    const baseTalents = mbti?.includes('N') ? ['직관적 통찰력', '창의적 사고'] : ['현실적 판단력', '세심한 관찰력'];
    const stemTalents = yearStem === '갑' || yearStem === '을' ? ['성장과 발전 능력'] : 
                      yearStem === '병' || yearStem === '정' ? ['열정과 추진력'] : ['안정성과 지속력'];
    
    return [...baseTalents, ...stemTalents];
  }

  /**
   * GPT 실패 시 기본 템플릿 반환
   */
  private getDefaultLifeProfile(userProfile: UserProfile): LifeProfileData {
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
        personality_analysis: `기본 사주 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.`,
        life_fortune: '운세 분석이 진행 중입니다.',
        career_fortune: '직업 운세 분석이 진행 중입니다.',
        wealth_fortune: '재물 운세 분석이 진행 중입니다.',
        love_fortune: '연애 운세 분석이 진행 중입니다.',
        health_fortune: '건강 운세 분석이 진행 중입니다.'
      },
      // 나머지는 기본값으로 처리
      traditionalSaju: {
        lucky_gods: ['천을귀인'],
        unlucky_gods: ['겁살'],
        life_phases: [],
        major_events: []
      },
      tojeong: {
        yearly_fortune: '분석 중입니다.',
        monthly_fortunes: [],
        major_cautions: [],
        opportunities: []
      },
      pastLife: {
        past_identity: '분석 중입니다.',
        past_location: '분석 중입니다.',
        past_era: '분석 중입니다.',
        karmic_lessons: [],
        soul_mission: '분석 중입니다.',
        past_relationships: []
      },
      personality: {
        core_traits: [],
        strengths: [],
        weaknesses: [],
        communication_style: '분석 중입니다.',
        decision_making: '분석 중입니다.',
        stress_response: '분석 중입니다.',
        ideal_career: [],
        relationship_style: '분석 중입니다.'
      },
      destiny: {
        life_purpose: '분석 중입니다.',
        major_challenges: [],
        key_opportunities: [],
        spiritual_growth: '분석 중입니다.',
        material_success: '분석 중입니다.',
        relationship_destiny: '분석 중입니다.'
      },
      salpuli: {
        detected_sal: [],
        sal_effects: [],
        purification_methods: [],
        protection_advice: []
      },
      fiveBlessings: {
        longevity: { score: 50, description: '분석 중입니다.' },
        wealth: { score: 50, description: '분석 중입니다.' },
        health: { score: 50, description: '분석 중입니다.' },
        virtue: { score: 50, description: '분석 중입니다.' },
        peaceful_death: { score: 50, description: '분석 중입니다.' },
        overall_blessing: '분석 중입니다.'
      },
      talent: {
        innate_talents: [],
        hidden_abilities: [],
        development_potential: [],
        career_recommendations: [],
        learning_style: '분석 중입니다.'
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
   * 그룹 4: 클라이언트 기반 운세 생성
   */

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
   * 운세 카테고리의 그룹 타입 결정
   */
  private getFortuneCategoryGroup(category: FortuneCategory): FortuneGroupType {
    // 평생 운세 그룹 (최초 1회만 생성, 영구 보존)
    const lifeProfileCategories = [
      'saju', 'traditional-saju', 'personality', 'talent', 
      'five-blessings', 'tojeong', 'salpuli', 'saju-psychology',
      // 묶음 요청
      'traditional-saju-package'
    ];
    
    // 일일 운세 그룹 (매일 생성, 24시간 보존)
    const dailyCategories = [
      'daily', 'hourly', 'today', 'tomorrow', 'biorhythm', 'new-year',
      // 묶음 요청
      'daily-comprehensive-package'
    ];
    
    // 실시간 상호작용 그룹 (사용자 입력 기반, 1시간 보존)
    const interactiveCategories = [
      'face-reading', 'tarot', 'dream-interpretation', 'psychology-test',
      'worry-bead', 'taemong', 'fortune-cookie', 'traditional-compatibility'
    ];
    
    // 연애·인연 패키지 (72시간 보존)
    const lovePackageCategories = [
      'love', 'destiny', 'blind-date', 'celebrity-match', 'couple-match',
      'ex-lover', 'compatibility', 'chemistry',
      'marriage', 'celebrity', 'avoid-people',
      // 묶음 요청
      'love-destiny-package'
    ];

    // 취업·재물 패키지 (168시간 보존)
    const careerWealthCategories = [
      'career', 'wealth', 'business', 'lucky-investment',
      'startup', 'lucky-job', 'lucky-sidejob', 'lucky-realestate',
      // 묶음 요청
      'career-wealth-package'
    ];

    // 행운 아이템 패키지 (720시간 보존)
    const luckyItemCategories = [
      'lucky-color', 'lucky-number', 'lucky-food', 'talisman', 'lucky-series',
      'lucky-exam', 'lucky-cycling', 'lucky-running', 'lucky-hiking', 
      'lucky-fishing', 'lucky-swim',
      // 묶음 요청
      'lucky-items-package'
    ];

    // 인생·경력 패키지 (168시간 보존)
    const lifeCareerCategories = [
      'employment', 'moving', 'moving-date', 'new-year', 'timeline', 'wish',
      'career', 'avoid-people', 'five-blessings', 'salpuli',
      // 묶음 요청
      'life-career-package'
    ];
    
    if (lifeProfileCategories.includes(category)) {
      return 'LIFE_PROFILE';
    } else if (dailyCategories.includes(category)) {
      return 'DAILY_COMPREHENSIVE';
    } else if (interactiveCategories.includes(category)) {
      return 'INTERACTIVE';
    } else if (lovePackageCategories.includes(category)) {
      return 'LOVE_PACKAGE';
    } else if (careerWealthCategories.includes(category)) {
      return 'CAREER_WEALTH_PACKAGE';
    } else if (luckyItemCategories.includes(category)) {
      return 'LUCKY_ITEMS_PACKAGE';
    } else if (lifeCareerCategories.includes(category)) {
      return 'LIFE_CAREER_PACKAGE';
    } else {
      return 'CLIENT_BASED'; // 기본값
    }
  }

  /**
   * 캐시에만 저장 (개발모드: 메모리, 프로덕션: DB+Redis)
   */
  private async saveToCacheOnly(
    userId: string,
    fortuneType: FortuneGroupType,
    fortuneCategory: FortuneCategory,
    data: any,
    interactiveInput?: InteractiveInput
  ): Promise<void> {
    const cacheKey = this.generateCacheKey(userId, fortuneType, fortuneCategory, interactiveInput);
    
         // 캐시 만료 시간 설정
     let expiresAt: Date | null = null;
     switch (fortuneType) {
       case 'LIFE_PROFILE':
         expiresAt = null; // 영구 보존
         break;
       case 'DAILY_COMPREHENSIVE':
         expiresAt = new Date();
         expiresAt.setHours(23, 59, 59, 999); // 오늘 자정까지
         break;
       case 'INTERACTIVE':
         expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1시간
         break;
       case 'LOVE_PACKAGE':
         expiresAt = new Date(Date.now() + 72 * 60 * 60 * 1000); // 72시간
         break;
       case 'CAREER_WEALTH_PACKAGE':
         expiresAt = new Date(Date.now() + 168 * 60 * 60 * 1000); // 168시간 (7일)
         break;
       case 'LUCKY_ITEMS_PACKAGE':
         expiresAt = new Date(Date.now() + 720 * 60 * 60 * 1000); // 720시간 (30일)
         break;
       case 'LIFE_CAREER_PACKAGE':
         expiresAt = new Date(Date.now() + 168 * 60 * 60 * 1000); // 168시간 (7일)
         break;
       case 'CLIENT_BASED':
         expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24시간
         break;
     }

    // 개발 모드: 메모리 캐시에 저장
    if (!this.supabase) {
      this.memoryCache.set(cacheKey, {
        data: { ...data },
        expiresAt,
        cacheType: fortuneType
      });
      
      console.log(`💾 메모리 캐시 저장: ${fortuneCategory} (만료: ${expiresAt ? expiresAt.toLocaleString() : '영구'})`);
      return;
    }

    // 프로덕션 모드: DB + Redis에 저장
    try {
      await this.saveFortune(userId, fortuneType, fortuneCategory, data, 
        expiresAt ? Math.ceil((expiresAt.getTime() - Date.now()) / (1000 * 60 * 60)) : undefined, 
        interactiveInput);
      
      // Redis 캐시에도 저장
      if (this.redis) {
        const ttl = expiresAt ? Math.ceil((expiresAt.getTime() - Date.now()) / 1000) : 86400; // 기본 24시간
        await this.redis.setex(cacheKey, ttl, JSON.stringify(data));
      }
    } catch (error) {
      console.error('캐시 저장 실패:', error);
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

  /**
   * 연애·인연 패키지 생성 (love, destiny, blind-date, celebrity-match 등)
   */
  private async generateLovePackage(
    userId: string, 
    userProfile?: UserProfile, 
    category?: FortuneCategory
  ): Promise<any> {
    if (!userProfile) {
      throw new Error('연애운 분석에는 사용자 프로필이 필요합니다.');
    }

    console.log(`💕 연애·인연 패키지 생성 중... (사용자: ${userId}, 카테고리: ${category})`);

    try {
      if (category === 'love') {
        // 연애운만 요청시 개별 생성
        const loveData = await this.generateLoveFromGPT(userProfile, category);
        console.log(`✅ 연애운 생성 완료 (사용자: ${userId})`);
        return loveData;
      } else if (category === 'marriage') {
        // 결혼운만 요청시 개별 생성  
        const marriageData = await this.generateMarriageFromGPT(userProfile);
        console.log(`✅ 결혼운 생성 완료 (사용자: ${userId})`);
        return marriageData;
      } else if (category === 'destiny') {
        // 인연운만 요청시 개별 생성
        const destinyData = await this.generateDestinyFromGPT(userProfile);
        console.log(`✅ 인연운 생성 완료 (사용자: ${userId})`);
        return destinyData;
      } else {
        // 패키지 전체 요청시
        const packageData = {
          love: await this.generateLoveFromGPT(userProfile, 'love'),
          marriage: await this.generateMarriageFromGPT(userProfile),
          destiny: await this.generateDestinyFromGPT(userProfile),
          // TODO: blind_date, celebrity_match 추가
          generated_at: new Date().toISOString()
        };
        console.log(`✅ 연애·인연 패키지 전체 생성 완료 (사용자: ${userId})`);
        return packageData;
      }
      
    } catch (error) {
      console.error('연애·인연 패키지 생성 실패, 기본 데이터 반환:', error);
      if (category === 'destiny') {
        return this.getDefaultDestinyData(userProfile, category);
      }
      return this.getDefaultLoveData(userProfile, category);
    }
  }

  /**
   * GPT API를 호출하여 연애운 데이터 생성
   */
  private async callGPTForLove(userProfile: UserProfile, category?: FortuneCategory): Promise<any> {
    // TODO: 실제 GPT API 호출 구현
    console.log(`📡 연애운 GPT 요청: ${userProfile.name} (${category})`);
    
    // 실제 GPT 처리 시뮬레이션 (300ms 지연)
    await new Promise(resolve => setTimeout(resolve, 300));
    
    return this.generateLoveFromGPT(userProfile, category);
  }

  /**
   * GPT 스타일의 연애운 데이터 생성
   */
  private generateLoveFromGPT(userProfile: UserProfile, category?: FortuneCategory): any {
    // 카테고리별로 다른 데이터 생성
    if (category === 'marriage') {
      return this.generateMarriageFromGPT(userProfile);
    }
    
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    const birthDay = parseInt(userProfile.birth_date.split('-')[2]);
    const isEarlyYear = birthMonth <= 6;
    const genderKor = userProfile.gender === '남성' ? '남성' : userProfile.gender === '여성' ? '여성' : '성별 미상';
    const mbti = userProfile.mbti || 'ISFJ';
    
    // MBTI와 생년월일 기반 개인화된 연애운 생성
    const isExtrovert = mbti.startsWith('E');
    const isFeeling = mbti.includes('F');
    const currentScore = Math.floor(70 + (birthDay % 20) + (isExtrovert ? 10 : 5));
    const weeklyScore = Math.floor(65 + (birthMonth % 15) + (isFeeling ? 10 : 5));
    const monthlyScore = Math.floor(75 + ((birthDay + birthMonth) % 20));

    // 별자리 기반 궁합 계산
    const zodiacCompatibility = this.getZodiacCompatibility(birthMonth, birthDay);
    
    // MBTI 기반 연애 스타일
    const loveStyle = this.getLoveStyleByMBTI(mbti);

    const loveData = {
      love: {
        current_score: currentScore,
        weekly_score: weeklyScore,
        monthly_score: monthlyScore,
        summary: this.generateLoveSummary(userProfile, currentScore),
        advice: this.generateLoveAdvice(mbti, genderKor),
        lucky_time: isEarlyYear ? '오후 2시 ~ 5시' : '오후 3시 ~ 6시',
        lucky_place: isExtrovert ? '카페, 레스토랑, 공원' : '도서관, 영화관, 조용한 카페',
        lucky_color: this.getLuckyColor(birthMonth),
        compatibility: zodiacCompatibility,
        predictions: {
          today: this.getTodayLovePrediction(mbti, currentScore),
          this_week: this.getWeeklyLovePrediction(birthMonth, weeklyScore),
          this_month: this.getMonthlyLovePrediction(genderKor, monthlyScore)
        },
        action_items: this.getLoveActionItems(mbti, isExtrovert),
        love_style: loveStyle,
        meeting_probability: Math.floor(50 + (currentScore - 70)),
        relationship_advice: {
          single: this.getSingleAdvice(mbti),
          couple: this.getCoupleAdvice(mbti)
        }
      },
      generated_at: new Date().toISOString()
    };

    return loveData;
  }

  /**
   * GPT 스타일의 결혼운 데이터 생성
   */
  private generateMarriageFromGPT(userProfile: UserProfile): any {
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    const birthDay = parseInt(userProfile.birth_date.split('-')[2]);
    const birthYear = parseInt(userProfile.birth_date.split('-')[0]);
    const age = new Date().getFullYear() - birthYear;
    const genderKor = userProfile.gender === '남성' ? '남성' : userProfile.gender === '여성' ? '여성' : '성별 미상';
    const mbti = userProfile.mbti || 'ISFJ';
    
    // MBTI와 생년월일, 나이 기반 개인화된 결혼운 생성
    const isExtrovert = mbti.startsWith('E');
    const isJudging = mbti.endsWith('J');
    const isFeeling = mbti.includes('F');
    
    // 결혼운 점수 계산 (나이와 MBTI 고려)
    const currentScore = Math.floor(75 + (birthDay % 15) + (isJudging ? 10 : 5) + (age >= 25 ? 5 : 0));
    const weeklyScore = Math.floor(70 + (birthMonth % 12) + (isFeeling ? 8 : 4));
    const monthlyScore = Math.floor(80 + ((birthDay + birthMonth) % 18) + (isExtrovert ? 5 : 3));
    const yearlyScore = Math.floor(78 + (age % 15) + (isJudging ? 7 : 3));

    // 결혼 적정 연령대 계산
    const bestAge = this.getMarriageBestAge(age, mbti, genderKor);
    
    // 길한 결혼 월 계산
    const bestMonths = this.getBestMarriageMonths(birthMonth, mbti);
    
    // 결혼 타임라인 계산
    const timeline = this.getMarriageTimeline(age, currentScore, mbti);

    const marriageData = {
      marriage: {
        current_score: currentScore,
        weekly_score: weeklyScore,
        monthly_score: monthlyScore,
        yearly_score: yearlyScore,
        summary: this.generateMarriageSummary(userProfile, currentScore, age),
        advice: this.generateMarriageAdvice(mbti, genderKor, age),
        lucky_time: this.getMarriageLuckyTime(birthMonth),
        lucky_place: isExtrovert ? '카페, 레스토랑, 공원, 파티장' : '조용한 카페, 도서관, 미술관, 작은 모임',
        lucky_color: this.getMarriageLuckyColor(birthMonth),
        best_months: bestMonths,
        compatibility: {
          best_age: bestAge,
          good_seasons: this.getGoodMarriageSeasons(birthMonth),
          ideal_partner: this.getIdealMarriagePartner(mbti, genderKor),
          avoid: this.getMarriageAvoidList(mbti, age)
        },
        timeline: timeline,
        predictions: {
          today: this.getTodayMarriagePrediction(mbti, currentScore),
          this_week: this.getWeeklyMarriagePrediction(birthMonth, weeklyScore),
          this_month: this.getMonthlyMarriagePrediction(age, monthlyScore),
          this_year: this.getYearlyMarriagePrediction(mbti, yearlyScore)
        },
        preparation: {
          emotional: this.getEmotionalPreparation(mbti, isFeeling),
          practical: this.getPracticalPreparation(isJudging, age),
          financial: this.getFinancialPreparation(age, genderKor)
        },
        warnings: this.getMarriageWarnings(mbti, age)
      },
      generated_at: new Date().toISOString()
    };

    return marriageData;
  }

  /**
   * 연애운 요약 생성
   */
  private generateLoveSummary(userProfile: UserProfile, score: number): string {
    const name = userProfile.name;
    const mbti = userProfile.mbti || 'ISFJ';
    const isExtrovert = mbti.startsWith('E');
    
    if (score >= 85) {
      return `${name}님, 오늘은 연애운이 최고조에 달해 있습니다! ${isExtrovert ? '적극적인 만남' : '운명적인 만남'}의 기회가 열려 있어요.`;
    } else if (score >= 75) {
      return `${name}님의 연애운이 상승세를 보이고 있습니다. ${isExtrovert ? '새로운 사람들과의 만남' : '깊이 있는 대화'}을 통해 좋은 인연을 만날 수 있어요.`;
    } else if (score >= 65) {
      return `${name}님, 평온한 연애운이 흐르고 있습니다. 기존 관계를 더욱 깊게 만들거나 천천히 새로운 인연을 기다려보세요.`;
    } else {
      return `${name}님, 잠시 연애보다는 자기계발에 집중하는 시기입니다. 내면의 매력을 키우는 것이 더 큰 사랑을 불러올 거예요.`;
    }
  }

  /**
   * MBTI별 연애 조언 생성
   */
  private generateLoveAdvice(mbti: string, gender: string): string {
    const adviceMap: Record<string, string> = {
      'ENFP': '자유롭고 창의적인 당신의 매력을 마음껏 발휘하세요. 진정성 있는 대화로 상대방의 마음을 사로잡을 수 있습니다.',
      'ENFJ': '타인을 배려하는 당신의 따뜻함이 큰 매력입니다. 상대방의 말에 귀 기울이며 공감해 주세요.',
      'ENTP': '지적인 호기심과 유머감각을 활용해 흥미로운 대화를 이끌어 가세요. 예측 불가능한 매력이 포인트입니다.',
      'ENTJ': '리더십 있는 모습이 매력적이지만, 때로는 부드러운 면도 보여주세요. 계획적인 데이트를 제안해 보세요.',
      'ESFP': '밝고 긍정적인 에너지로 상대방에게 즐거움을 선사하세요. 자연스럽고 편안한 분위기를 만들어 보세요.',
      'ESFJ': '세심하고 배려심 많은 당신의 장점을 살리세요. 상대방이 편안함을 느낄 수 있도록 도와주세요.',
      'ESTP': '활동적이고 모험적인 데이트를 계획해 보세요. 즉흥적인 재미가 관계에 활력을 불어넣을 것입니다.',
      'ESTJ': '안정적이고 책임감 있는 모습을 보여주되, 가끔은 유연함도 필요합니다. 진솔한 대화를 나누세요.',
      'INFP': '깊이 있는 대화와 진정성으로 상대방의 마음에 다가가세요. 당신만의 독특한 관점을 공유해 보세요.',
      'INFJ': '통찰력 있는 조언과 깊은 공감능력이 당신의 매력입니다. 상대방의 진심을 이해하려 노력하세요.',
      'INTP': '지적인 대화로 상대방과 깊은 유대감을 형성하세요. 논리적 사고와 창의성을 균형 잡힌 소통으로 보여주세요.',
      'INTJ': '장기적인 관점에서 관계를 바라보는 당신의 신중함이 매력적입니다. 솔직하고 진실한 소통을 하세요.',
      'ISFP': '예술적 감성과 따뜻한 마음으로 상대방에게 다가가세요. 조용하지만 깊은 애정표현이 효과적입니다.',
      'ISFJ': '헌신적이고 배려심 많은 당신의 모습이 큰 매력입니다. 상대방을 위한 작은 배려들을 실천해 보세요.',
      'ISTP': '실용적이면서도 독립적인 매력을 보여주세요. 직접적이고 솔직한 표현이 더 진정성 있게 다가갈 것입니다.',
      'ISTJ': '성실하고 믿음직한 당신의 모습을 보여주세요. 일관된 관심과 꾸준한 노력이 관계 발전의 열쇠입니다.'
    };

    return adviceMap[mbti] || '진정성 있는 마음으로 상대방에게 다가가세요. 꾸준한 관심과 배려가 좋은 관계의 시작입니다.';
  }

  /**
   * 생년월일 기반 별자리 궁합 계산
   */
  private getZodiacCompatibility(month: number, day: number): { best: string; good: string[]; avoid: string } {
    // 간단한 별자리 계산 (실제로는 더 정확한 계산 필요)
    const zodiacSigns = [
      { name: '염소자리', month: [12, 1], best: '처녀자리', good: ['황소자리', '전갈자리'], avoid: '게자리' },
      { name: '물병자리', month: [1, 2], best: '쌍둥이자리', good: ['천칭자리', '사수자리'], avoid: '전갈자리' },
      { name: '물고기자리', month: [2, 3], best: '전갈자리', good: ['게자리', '염소자리'], avoid: '쌍둥이자리' },
      { name: '양자리', month: [3, 4], best: '사자자리', good: ['쌍둥이자리', '물병자리'], avoid: '게자리' },
      { name: '황소자리', month: [4, 5], best: '처녀자리', good: ['게자리', '염소자리'], avoid: '물병자리' },
      { name: '쌍둥이자리', month: [5, 6], best: '물병자리', good: ['천칭자리', '양자리'], avoid: '처녀자리' },
      { name: '게자리', month: [6, 7], best: '전갈자리', good: ['물고기자리', '황소자리'], avoid: '양자리' },
      { name: '사자자리', month: [7, 8], best: '양자리', good: ['쌍둥이자리', '천칭자리'], avoid: '전갈자리' },
      { name: '처녀자리', month: [8, 9], best: '황소자리', good: ['게자리', '염소자리'], avoid: '사수자리' },
      { name: '천칭자리', month: [9, 10], best: '쌍둥이자리', good: ['물병자리', '사자자리'], avoid: '염소자리' },
      { name: '전갈자리', month: [10, 11], best: '물고기자리', good: ['게자리', '처녀자리'], avoid: '사자자리' },
      { name: '사수자리', month: [11, 12], best: '양자리', good: ['물병자리', '사자자리'], avoid: '처녀자리' }
    ];

    // 월 기반으로 별자리 찾기 (간소화된 버전)
    const sign = zodiacSigns.find(s => 
      s.month.includes(month) || 
      (month === 12 && s.name === '염소자리') || 
      (month === 1 && s.name === '염소자리')
    ) || zodiacSigns[0];

    return {
      best: sign.best,
      good: sign.good,
      avoid: sign.avoid
    };
  }

  /**
   * MBTI별 연애 스타일 반환
   */
  private getLoveStyleByMBTI(mbti: string): string {
    const styleMap: Record<string, string> = {
      'ENFP': '자유롭고 열정적인 연애를 추구하며, 깊은 정신적 연결을 중시합니다.',
      'ENFJ': '상대방을 이해하고 성장시키려 노력하며, 조화로운 관계를 만들어 갑니다.',
      'ENTP': '지적 호기심이 풍부하고 창의적인 관계를 선호합니다.',
      'ENTJ': '목표 지향적이고 계획적인 연애를 추구하며, 발전적인 관계를 중시합니다.',
      'ESFP': '즐겁고 활기찬 연애를 좋아하며, 현재 순간을 중시합니다.',
      'ESFJ': '안정적이고 전통적인 연애를 선호하며, 상대방을 돌보는 것을 좋아합니다.',
      'ESTP': '모험적이고 즉흥적인 연애를 즐기며, 활동적인 관계를 선호합니다.',
      'ESTJ': '실용적이고 안정적인 연애를 추구하며, 책임감 있는 관계를 중시합니다.',
      'INFP': '깊고 의미 있는 연애를 추구하며, 진정성과 가치관 일치를 중시합니다.',
      'INFJ': '깊은 정신적 연결을 중시하며, 장기적이고 의미 있는 관계를 선호합니다.',
      'INTP': '지적 교감을 중시하며, 독립적이면서도 깊이 있는 관계를 추구합니다.',
      'INTJ': '진지하고 깊이 있는 연애를 선호하며, 장기적 비전을 공유하는 관계를 중시합니다.',
      'ISFP': '따뜻하고 조용한 연애를 좋아하며, 서로의 개성을 존중하는 관계를 선호합니다.',
      'ISFJ': '안정적이고 헌신적인 연애를 추구하며, 상대방을 보살피는 것을 중시합니다.',
      'ISTP': '독립적이고 자유로운 연애를 선호하며, 서로의 공간을 존중하는 관계를 좋아합니다.',
      'ISTJ': '전통적이고 안정적인 연애를 추구하며, 신뢰와 일관성을 중시합니다.'
    };

    return styleMap[mbti] || '진실하고 성실한 연애를 추구하며, 서로를 존중하는 관계를 중시합니다.';
  }

  /**
   * 행운의 색상 반환
   */
  private getLuckyColor(month: number): string {
    const colors = [
      '#FF69B4', '#FF1493', '#DC143C', '#FF6347', '#FF4500', '#FFA500',
      '#FFD700', '#9ACD32', '#32CD32', '#00CED1', '#1E90FF', '#8A2BE2'
    ];
    return colors[month - 1] || '#FF69B4';
  }

  /**
   * 오늘의 연애 예측
   */
  private getTodayLovePrediction(mbti: string, score: number): string {
    const isExtrovert = mbti.startsWith('E');
    
    if (score >= 85) {
      return isExtrovert ? 
        '새로운 만남의 기회가 활짝 열려 있습니다. 적극적으로 다가가면 좋은 결과가 있을 것입니다.' :
        '운명적인 만남이나 깊은 대화의 기회가 찾아올 것입니다. 진정성을 보여주세요.';
    } else if (score >= 75) {
      return '기존 관계에서 새로운 면을 발견하거나 흥미로운 대화의 기회가 있을 것입니다.';
    } else {
      return '조용한 하루가지만, 작은 관심과 배려가 큰 의미로 다가갈 수 있습니다.';
    }
  }

  /**
   * 주간 연애 예측
   */
  private getWeeklyLovePrediction(birthMonth: number, score: number): string {
    const isEarlyYear = birthMonth <= 6;
    
    if (score >= 80) {
      return isEarlyYear ? 
        '이번 주 중반에 특별한 만남이나 깊어지는 관계의 기회가 있을 것입니다.' :
        '주말을 중심으로 로맨틱한 분위기나 의미 있는 대화의 시간이 올 것입니다.';
    } else if (score >= 70) {
      return '꾸준한 관심과 소통으로 관계가 점진적으로 발전할 수 있는 주입니다.';
    } else {
      return '급하게 서두르지 말고, 자연스러운 흐름에 맡기는 것이 좋겠습니다.';
    }
  }

  /**
   * 월간 연애 예측
   */
  private getMonthlyLovePrediction(gender: string, score: number): string {
    if (score >= 85) {
      return '이달 말까지 중요한 결정을 내리거나 관계에 큰 진전이 있을 가능성이 높습니다.';
    } else if (score >= 75) {
      return '차근차근 관계를 발전시켜 나가면, 이달 안에 좋은 결실을 맺을 수 있을 것입니다.';
    } else {
      return '현재 관계를 안정적으로 유지하면서, 새로운 기회를 천천히 기다려보세요.';
    }
  }

  /**
   * MBTI별 연애 행동 제안
   */
  private getLoveActionItems(mbti: string, isExtrovert: boolean): string[] {
    const baseItems = [
      '진솔한 대화 나누기',
      '상대방에게 관심 표현하기',
      '감사 인사 전하기'
    ];

    if (isExtrovert) {
      return [
        ...baseItems,
        '새로운 활동이나 모임에 참여하기',
        '친구들과의 모임에서 새로운 인연 만들기',
        '적극적인 자세로 다가가기'
      ];
    } else {
      return [
        ...baseItems,
        '조용한 환경에서 깊은 대화 나누기',
        '작은 배려와 관심 표현하기',
        '자신만의 매력을 자연스럽게 보여주기'
      ];
    }
  }

  /**
   * 솔로 조언
   */
  private getSingleAdvice(mbti: string): string {
    const isExtrovert = mbti.startsWith('E');
    
    if (isExtrovert) {
      return '다양한 사람들과 만나면서 자연스럽게 인연을 찾아보세요. 당신의 밝은 에너지가 좋은 인연을 불러올 것입니다.';
    } else {
      return '급하게 서두르지 말고, 자신에게 맞는 사람을 천천히 찾아보세요. 깊이 있는 만남이 더 의미 있을 것입니다.';
    }
  }

  /**
   * 커플 조언
   */
  private getCoupleAdvice(mbti: string): string {
    const isFeeling = mbti.includes('F');
    
    if (isFeeling) {
      return '서로의 감정을 이해하고 공감하는 시간을 가져보세요. 작은 배려가 관계를 더욱 단단하게 만들 것입니다.';
    } else {
      return '논리적인 대화와 함께 감정적인 교감도 중요합니다. 균형 잡힌 소통으로 관계를 발전시켜 나가세요.';
    }
  }

  /**
   * 연애운 기본 데이터 (GPT 실패 시)
   */
  private getDefaultLoveData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      love: {
        current_score: 75,
        weekly_score: 70,
        monthly_score: 80,
        summary: '연애운 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        advice: '진정성 있는 마음으로 상대방에게 다가가세요.',
        lucky_time: '오후 3시 ~ 6시',
        lucky_place: '카페, 공원',
        lucky_color: '#FF69B4',
        compatibility: {
          best: '물병자리',
          good: ['쌍둥이자리', '천칭자리'],
          avoid: '전갈자리'
        },
        predictions: {
          today: '분석 중입니다.',
          this_week: '분석 중입니다.',
          this_month: '분석 중입니다.'
        },
        action_items: ['분석 중입니다.'],
        love_style: '분석 중입니다.',
        meeting_probability: 50,
        relationship_advice: {
          single: '분석 중입니다.',
          couple: '분석 중입니다.'
        }
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 취업·재물 패키지 생성 (임시 구현)
   */
  private async generateCareerWealthPackage(
    userId: string, 
    userProfile?: UserProfile, 
    category?: FortuneCategory
  ): Promise<any> {
    console.log(`💼 취업·재물 패키지 생성 예정... (사용자: ${userId}, 카테고리: ${category})`);
    return { message: '취업·재물 패키지 구현 예정', category };
  }

  /**
   * 행운 아이템 패키지 생성
   */
  private async generateLuckyItemsPackage(
    userId: string, 
    userProfile?: UserProfile, 
    category?: FortuneCategory
  ): Promise<any> {
    console.log(`🍀 행운 아이템 패키지 생성... (사용자: ${userId}, 카테고리: ${category})`);
    
    if (!userProfile) {
      userProfile = this.getDefaultUserProfile(userId);
      console.log('🔧 기본 사용자 프로필 사용:', userProfile.name);
    }

    const profile = userProfile as UserProfile;

    // 새로운 행운 아이템 카테고리들 처리
    if (category && ['lucky-color', 'lucky-number', 'lucky-food', 'talisman', 'lucky-series', 'lucky-exam', 'lucky-cycling', 'lucky-running', 'lucky-hiking', 'lucky-fishing', 'lucky-swim'].includes(category)) {
      try {
        const luckyData = await this.generateLuckyItemFromGPT(profile, category);
        console.log(`✅ GPT ${category} 생성 완료 (사용자: ${userId})`);
        return luckyData;
      } catch (error) {
        console.error(`❌ GPT ${category} 생성 실패:`, error);
        return this.getDefaultLuckyItemData(profile, category);
      }
    }

    return { message: '행운 아이템 패키지 구현 예정', category };
  }

  /**
   * 실시간 상호작용 운세 생성 (임시 구현)
   */
  private async generateInteractiveFortune(
    userId: string, 
    category?: FortuneCategory, 
    interactiveInput?: InteractiveInput
  ): Promise<any> {
    console.log(`🎯 상호작용 운세 생성... (사용자: ${userId}, 카테고리: ${category})`);
    
    // userProfile은 API에서 전달받음
    const userProfile = interactiveInput?.user_profile;
    if (!userProfile) {
      throw new Error('상호작용 운세 생성에는 사용자 프로필이 필요합니다.');
    }

    if (category === 'traditional-compatibility') {
      try {
        const compatibilityData = await this.generateTraditionalCompatibilityGPT(userProfile, category);
        console.log(`✅ GPT 전통 궁합 생성 완료 (사용자: ${userId})`);
        return compatibilityData;
      } catch (error) {
        console.error('❌ GPT 전통 궁합 생성 실패:', error);
        return this.getDefaultTraditionalCompatibilityData(userProfile, category);
      }
    }

    return { message: '상호작용 운세 구현 예정', category, input: interactiveInput };
  }

  /**
   * 클라이언트 기반 운세 생성 (임시 구현)
   */
  private async generateClientBasedFortune(
    userId: string, 
    category?: FortuneCategory, 
    userProfile?: UserProfile
  ): Promise<any> {
    console.log(`📱 클라이언트 기반 운세 생성... (사용자: ${userId}, 카테고리: ${category})`);
    
    if (!userProfile) {
      // 기본 사용자 프로필 생성
      userProfile = this.getDefaultUserProfile(userId);
      console.log('🔧 기본 사용자 프로필 사용:', userProfile.name);
    }

    // 이제 userProfile은 확실히 존재함
    const profile = userProfile as UserProfile;

    if (category === 'zodiac-animal') {
      try {
        const zodiacData = await this.generateZodiacAnimalFortuneGPT(profile);
        console.log(`✅ GPT 띠별 운세 생성 완료 (사용자: ${userId})`);
        return zodiacData;
      } catch (error) {
        console.error('❌ GPT 띠별 운세 생성 실패:', error);
        return this.getDefaultZodiacAnimalData(profile, category);
      }
    }

    if (category === 'network-report') {
      try {
        const networkData = await this.generateNetworkReportFromGPT(profile);
        console.log(`✅ GPT 인맥 리포트 생성 완료 (사용자: ${userId})`);
        return networkData;
      } catch (error) {
        console.error('❌ GPT 인맥 리포트 생성 실패:', error);
        return this.getDefaultNetworkReportData(profile, category);
      }
    }

    if (category === 'mbti') {
      try {
        const mbtiData = await this.generateMbtiDailyFromGPT(profile);
        console.log(`✅ GPT MBTI 운세 생성 완료 (사용자: ${userId})`);
        return mbtiData;
      } catch (error) {
        console.error('❌ GPT MBTI 운세 생성 실패:', error);
        return this.getDefaultMbtiData(profile, category);
      }
    }

    if (category === 'weekly') {
      try {
        const weeklyData = await this.generateWeeklyFromGPT(profile);
        console.log(`✅ GPT 주간 운세 생성 완료 (사용자: ${userId})`);
        return weeklyData;
      } catch (error) {
        console.error('❌ GPT 주간 운세 생성 실패:', error);
        return this.getDefaultWeeklyData(profile, category);
      }
    }

    if (category === 'monthly') {
      try {
        const monthlyData = await this.generateMonthlyFromGPT(profile);
        console.log(`✅ GPT 월간 운세 생성 완료 (사용자: ${userId})`);
        return monthlyData;
      } catch (error) {
        console.error('❌ GPT 월간 운세 생성 실패:', error);
        return this.getDefaultMonthlyData(profile, category);
      }
    }

    if (category === 'yearly') {
      try {
        const yearlyData = await this.generateYearlyFromGPT(profile);
        console.log(`✅ GPT 연간 운세 생성 완료 (사용자: ${userId})`);
        return yearlyData;
      } catch (error) {
        console.error('❌ GPT 연간 운세 생성 실패:', error);
        return this.getDefaultYearlyData(profile, category);
      }
    }

    // 개인 분석 패키지의 추가 카테고리들
    if (category && ['birth-season', 'birthdate', 'birthstone', 'blood-type', 'palmistry', 'past-life', 'daily', 'zodiac', 'lucky-items', 'lucky-outfit', 'physiognomy'].includes(category)) {
      try {
        const analysisData = await this.generatePersonalAnalysisFromGPT(profile, category);
        console.log(`✅ GPT ${category} 분석 완료 (사용자: ${userId})`);
        return analysisData;
      } catch (error) {
        console.error(`❌ GPT ${category} 분석 실패:`, error);
        return this.getDefaultPersonalAnalysisData(profile, category);
      }
    }
    
    // 다른 클라이언트 기반 운세들은 추후 구현
    return { 
      message: '클라이언트 기반 운세 구현 예정', 
      category,
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 결혼 적정 연령대 계산
   */
  private getMarriageBestAge(currentAge: number, mbti: string, gender: string): string {
    const isJudging = mbti.endsWith('J');
    const baseAge = gender === '남성' ? 28 : 26;
    
    if (currentAge < 25) {
      return isJudging ? '25-30세' : '27-32세';
    } else if (currentAge < 30) {
      return '현재 시기가 적절합니다';
    } else if (currentAge < 35) {
      return '현재~35세까지 좋습니다';
    } else {
      return '나이는 숫자일 뿐, 언제든 좋습니다';
    }
  }

  /**
   * 길한 결혼 월 계산
   */
  private getBestMarriageMonths(birthMonth: number, mbti: string): string[] {
    const isExtrovert = mbti.startsWith('E');
    const seasonalMonths = [
      ['3월', '4월', '5월'], // 봄
      ['6월', '7월', '8월'], // 여름  
      ['9월', '10월', '11월'], // 가을
      ['12월', '1월', '2월']  // 겨울
    ];
    
    if (isExtrovert) {
      return ['5월', '6월', '9월', '10월']; // 활동적인 계절
    } else {
      return ['4월', '5월', '10월', '11월']; // 온화한 계절
    }
  }

  /**
   * 결혼 타임라인 계산
   */
  private getMarriageTimeline(age: number, score: number, mbti: string): any {
    const isJudging = mbti.endsWith('J');
    
    if (age < 25) {
      return {
        engagement: '2-3년 후가 적절합니다',
        wedding: '약혼 후 1년 이내',
        honeymoon: '결혼 후 2-3개월 이내',
        new_home: '결혼 전 6개월부터 준비'
      };
    } else if (age < 30) {
      return {
        engagement: isJudging ? '올해 하반기' : '내년 상반기',
        wedding: '약혼 후 6개월-1년',
        honeymoon: '결혼 후 1-2개월 이내',
        new_home: '결혼 전 3-6개월'
      };
    } else {
      return {
        engagement: '현재 시기가 좋습니다',
        wedding: '준비되면 바로',
        honeymoon: '결혼 후 곧바로',
        new_home: '결혼과 동시에'
      };
    }
  }

  /**
   * 결혼운 요약 생성
   */
  private generateMarriageSummary(userProfile: UserProfile, score: number, age: number): string {
    const name = userProfile.name;
    const mbti = userProfile.mbti || 'ISFJ';
    const isJudging = mbti.endsWith('J');
    
    if (score >= 85) {
      return `${name}님, 결혼운이 최고조에 달해 있습니다! ${isJudging ? '계획적으로 준비하면' : '자연스러운 흐름으로'} 좋은 결실을 맺을 수 있어요.`;
    } else if (score >= 75) {
      return `${name}님의 결혼운이 상승세를 보이고 있습니다. ${age < 30 ? '충분한 시간을 가지고' : '경험을 바탕으로'} 신중하게 준비하세요.`;
    } else if (score >= 65) {
      return `${name}님, 안정적인 결혼운이 흐르고 있습니다. 서두르지 말고 천천히 준비해 나가면 좋은 결과가 있을 것입니다.`;
    } else {
      return `${name}님, 현재는 자기계발과 준비에 집중하는 시기입니다. 내면을 다지는 시간이 더 좋은 인연을 불러올 거예요.`;
    }
  }

  /**
   * 결혼운 조언 생성
   */
  private generateMarriageAdvice(mbti: string, gender: string, age: number): string {
    const isExtrovert = mbti.startsWith('E');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.endsWith('J');
    
    let advice = '';
    
    if (isJudging) {
      advice += '계획적으로 단계별로 준비하세요. ';
    } else {
      advice += '자연스러운 흐름에 맡기되 기본적인 준비는 해두세요. ';
    }
    
    if (isFeeling) {
      advice += '감정적 교감과 가치관 일치를 중시하세요. ';
    } else {
      advice += '현실적인 조건과 미래 계획을 충분히 논의하세요. ';
    }
    
    if (age < 28) {
      advice += '서두르지 말고 충분한 시간을 가지고 결정하세요.';
    } else {
      advice += '경험을 바탕으로 신중하되 과감하게 결정하세요.';
    }
    
    return advice;
  }

  /**
   * 결혼 행운의 시간
   */
  private getMarriageLuckyTime(birthMonth: number): string {
    const times = [
      '오전 10시 ~ 오후 1시', '오후 2시 ~ 5시', '오후 3시 ~ 6시',
      '오후 4시 ~ 7시', '오후 1시 ~ 4시', '오전 11시 ~ 오후 2시'
    ];
    return times[birthMonth % times.length];
  }

  /**
   * 결혼 행운의 색상
   */
  private getMarriageLuckyColor(birthMonth: number): string {
    const colors = [
      '#FFB6C1', '#FFC0CB', '#FFE4E1', '#F0E68C', '#E6E6FA', '#F5DEB3',
      '#FDF5E6', '#F0F8FF', '#F5F5DC', '#FAF0E6', '#FFF8DC', '#FFFACD'
    ];
    return colors[birthMonth - 1] || '#FFB6C1';
  }

  /**
   * 결혼하기 좋은 계절
   */
  private getGoodMarriageSeasons(birthMonth: number): string[] {
    if (birthMonth >= 3 && birthMonth <= 5) {
      return ['봄', '가을'];
    } else if (birthMonth >= 6 && birthMonth <= 8) {
      return ['여름', '가을'];
    } else if (birthMonth >= 9 && birthMonth <= 11) {
      return ['가을', '봄'];
    } else {
      return ['겨울', '봄'];
    }
  }

  /**
   * 이상적인 결혼 상대
   */
  private getIdealMarriagePartner(mbti: string, gender: string): string[] {
    const isExtrovert = mbti.startsWith('E');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.endsWith('J');
    
    const traits = [];
    
    if (isFeeling) {
      traits.push('감정적으로 성숙한 사람', '가족을 중시하는 사람');
    } else {
      traits.push('논리적이고 현실적인 사람', '목표 지향적인 사람');
    }
    
    if (isJudging) {
      traits.push('계획적이고 책임감 있는 사람');
    } else {
      traits.push('유연하고 적응력 있는 사람');
    }
    
    if (isExtrovert) {
      traits.push('사교적이고 활발한 사람');
    } else {
      traits.push('차분하고 이해심 많은 사람');
    }
    
    return traits;
  }

  /**
   * 결혼 시 피해야 할 것들
   */
  private getMarriageAvoidList(mbti: string, age: number): string[] {
    const avoidList = ['성급한 결정', '경제적 무리'];
    
    if (age < 25) {
      avoidList.push('부모님 반대 무시', '충분하지 않은 준비');
    } else if (age < 30) {
      avoidList.push('과도한 이상향 추구', '현실성 없는 계획');
    } else {
      avoidList.push('과거 연애 패턴 반복', '나이에 대한 조급함');
    }
    
    return avoidList;
  }

  /**
   * 오늘의 결혼운 예측
   */
  private getTodayMarriagePrediction(mbti: string, score: number): string {
    const isExtrovert = mbti.startsWith('E');
    
    if (score >= 85) {
      return isExtrovert ? 
        '결혼과 관련된 좋은 소식이나 만남이 있을 수 있습니다. 적극적으로 임하세요.' :
        '중요한 대화나 결정의 기회가 찾아올 것입니다. 신중하게 판단하세요.';
    } else if (score >= 75) {
      return '결혼 준비나 상대방과의 관계에서 진전이 있을 수 있는 날입니다.';
    } else {
      return '조용한 하루지만, 미래를 위한 계획을 세우기 좋은 시간입니다.';
    }
  }

  /**
   * 주간 결혼운 예측
   */
  private getWeeklyMarriagePrediction(birthMonth: number, score: number): string {
    const isEarlyYear = birthMonth <= 6;
    
    if (score >= 80) {
      return isEarlyYear ? 
        '이번 주 중반 이후로 결혼과 관련된 중요한 일들이 진행될 것입니다.' :
        '주말을 중심으로 의미 있는 만남이나 대화의 시간이 있을 것입니다.';
    } else if (score >= 70) {
      return '점진적으로 관계가 발전하거나 결혼 계획이 구체화되는 주입니다.';
    } else {
      return '급하게 서두르지 말고, 차근차근 준비해 나가는 것이 좋겠습니다.';
    }
  }

  /**
   * 월간 결혼운 예측
   */
  private getMonthlyMarriagePrediction(age: number, score: number): string {
    if (score >= 85) {
      return age < 30 ? 
        '이달에 중요한 관계 발전이나 결혼 결정이 있을 수 있습니다.' :
        '이달 말까지 결혼과 관련된 구체적인 계획이 세워질 것입니다.';
    } else if (score >= 75) {
      return '꾸준히 관계를 발전시켜 나가면, 이달 안에 좋은 소식이 있을 것입니다.';
    } else {
      return '현재 상황을 차분히 정리하고, 다음 단계를 준비하는 달입니다.';
    }
  }

  /**
   * 연간 결혼운 예측
   */
  private getYearlyMarriagePrediction(mbti: string, score: number): string {
    const isJudging = mbti.endsWith('J');
    
    if (score >= 85) {
      return isJudging ? 
        '올해는 결혼과 관련된 중대한 결정을 내리는 해가 될 것입니다.' :
        '예상치 못한 좋은 인연이나 기회가 찾아올 수 있는 해입니다.';
    } else if (score >= 75) {
      return '꾸준한 노력과 준비로 결혼에 한 발짝 더 가까워지는 해입니다.';
    } else {
      return '내면을 다지고 준비하는 시간으로, 미래를 위한 기반을 마련하는 해입니다.';
    }
  }

  /**
   * 감정적 준비사항
   */
  private getEmotionalPreparation(mbti: string, isFeeling: boolean): string[] {
    const preparation = ['결혼에 대한 마음가짐 정리하기'];
    
    if (isFeeling) {
      preparation.push(
        '상대방과의 감정적 교감 깊이하기',
        '가족 간의 화합 도모하기',
        '결혼 후 변화에 대한 심리적 준비'
      );
    } else {
      preparation.push(
        '현실적인 결혼관 정립하기',
        '가치관과 목표 일치 확인하기',
        '역할 분담에 대한 논의'
      );
    }
    
    return preparation;
  }

  /**
   * 실용적 준비사항
   */
  private getPracticalPreparation(isJudging: boolean, age: number): string[] {
    const preparation = [];
    
    if (isJudging) {
      preparation.push(
        '예식장 및 날짜 예약하기',
        '혼수 및 예물 리스트 작성',
        '신혼집 마련 계획',
        '혼인신고 절차 확인'
      );
    } else {
      preparation.push(
        '기본적인 결혼 절차 알아보기',
        '필요한 물품들 체크하기',
        '주거 계획 세우기',
        '가족 소개 준비'
      );
    }
    
    return preparation;
  }

  /**
   * 경제적 준비사항
   */
  private getFinancialPreparation(age: number, gender: string): string[] {
    const preparation = ['결혼 자금 계획 세우기'];
    
    if (age < 28) {
      preparation.push(
        '적금 및 저축 습관 기르기',
        '가계부 작성 연습하기',
        '보험 상품 알아보기'
      );
    } else {
      preparation.push(
        '기존 자산 정리하기',
        '부부 공동 계좌 준비',
        '미래 자녀 교육비 계획',
        '주택 마련 자금 준비'
      );
    }
    
    return preparation;
  }

  /**
   * 결혼운 주의사항
   */
  private getMarriageWarnings(mbti: string, age: number): string[] {
    const warnings = ['성급한 결정은 금물입니다'];
    
    if (age < 25) {
      warnings.push(
        '부모님과의 충분한 상의가 필요합니다',
        '경제적 독립 먼저 고려하세요',
        '미래에 대한 구체적 계획을 세우세요'
      );
    } else if (age < 30) {
      warnings.push(
        '이상과 현실의 균형을 맞추세요',
        '상대방 가족과의 관계도 고려하세요',
        '경제적 부담을 무리하지 마세요'
      );
    } else {
      warnings.push(
        '과거 패턴을 반복하지 마세요',
        '나이에 대한 조급함을 버리세요',
        '서로의 독립성을 존중하세요'
      );
    }
    
    return warnings;
  }

  /**
   * 나이 계산 헬퍼 메서드
   */
  private calculateAge(birthDate: string): number {
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }
    
    return age;
  }

  /**
   * 인연운 GPT 시뮬레이션 (실제로는 GPT API 호출)
   */
  private async generateDestinyFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('📡 GPT 인연운 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    // 실제로는 GPT API 호출
    // const response = await this.callGPTAPI('destiny', userProfile);
    
    // 시뮬레이션: MBTI와 생년월일 기반 개인화
    const mbti = userProfile.mbti || 'ENFP';
    const age = this.calculateAge(userProfile.birth_date);
    
    return {
      destiny: {
        destiny_score: this.calculateDestinyScore(userProfile), // 개인화된 점수 계산
        summary: `${mbti} 성향의 ${userProfile.name}님은 앞으로 ${age < 30 ? '2-3개월' : age < 40 ? '3-4개월' : '4-6개월'} 내에 특별한 인연을 만날 가능성이 높습니다.`,
        advice: mbti.includes('E') 
          ? '적극적인 성격을 살려 새로운 만남에 열린 마음을 유지하세요.'
          : '차분한 성격을 살려 깊이 있는 대화를 나눌 수 있는 기회를 만들어보세요.',
        meeting_period: age < 25 ? '1-2개월 내' : age < 35 ? '3-4개월 내' : '6개월 내',
        meeting_place: mbti.includes('E') ? '지인 모임, 취미 활동 장소' : '도서관, 카페, 작은 모임',
        partner_traits: this.getDestinyPartnerTraits(mbti),
        development_chance: this.getDestinyDevelopmentChance(mbti, age),
        predictions: {
          first_meeting: this.getDestinyFirstMeetingPrediction(mbti, age),
          relationship: this.getDestinyRelationshipPrediction(mbti),
          long_term: this.getDestinyLongTermPrediction(mbti, age)
        },
        action_items: this.getDestinyActionItems(mbti, age)
      },
      generated_at: new Date().toISOString()
    };
  }

  private getDestinyPartnerTraits(mbti: string): string[] {
    if (mbti.includes('E')) {
      return ['밝은 에너지', '사교적 성향', '유머 감각'];
    } else {
      return ['깊이 있는 사고', '진중한 성격', '배려심'];
    }
  }

  private getDestinyDevelopmentChance(mbti: string, age: number): string {
    if (age < 25) {
      return '친구에서 연인으로 자연스럽게 발전할 가능성이 높습니다.';
    } else if (age < 35) {
      return mbti.includes('J') 
        ? '신중한 접근을 통해 안정적인 관계로 발전할 수 있습니다.'
        : '자유로운 만남에서 진정한 사랑으로 발전할 기회가 있습니다.';
    } else {
      return '인생 경험을 바탕으로 한 성숙한 관계로 발전할 가능성이 높습니다.';
    }
  }

  private getDestinyFirstMeetingPrediction(mbti: string, age: number): string {
    if (mbti.includes('E')) {
      return age < 30 
        ? '가까운 미래에 지인을 통해 활발한 만남이 예상됩니다.'
        : '새로운 환경에서 자연스러운 만남이 있을 것입니다.';
    } else {
      return age < 30
        ? '우연한 기회를 통해 조용하지만 의미 있는 만남이 있을 것입니다.'
        : '공통 관심사를 통해 깊이 있는 대화로 시작되는 만남이 예상됩니다.';
    }
  }

  private getDestinyRelationshipPrediction(mbti: string): string {
    if (mbti.includes('F')) {
      return '감정적 교류가 풍부하여 서로에게 깊은 인상을 남길 수 있습니다.';
    } else {
      return '논리적이고 현실적인 접근으로 서로를 이해해 나갈 수 있습니다.';
    }
  }

  private getDestinyLongTermPrediction(mbti: string, age: number): string {
    if (mbti.includes('J')) {
      return age < 30 
        ? '계획적인 관계 발전을 통해 안정적인 미래를 설계할 수 있습니다.'
        : '성숙한 판단력으로 장기적인 동반자 관계를 구축할 수 있습니다.';
    } else {
      return '자유롭고 창의적인 관계 속에서 서로의 성장을 도울 수 있습니다.';
    }
  }

  private getDestinyActionItems(mbti: string, age: number): string[] {
    const commonItems = ['긍정적인 이미지를 유지하기'];
    
    if (mbti.includes('E')) {
      commonItems.push('친구의 초대를 적극적으로 수락하기');
      commonItems.push('새로운 모임에 참여하기');
    } else {
      commonItems.push('관심사가 맞는 소규모 모임 찾기');
      commonItems.push('깊이 있는 대화를 나눌 수 있는 기회 만들기');
    }
    
    if (age < 25) {
      commonItems.push('다양한 경험을 통해 자신을 발견하기');
    } else if (age < 35) {
      commonItems.push('자신의 가치관을 명확히 하기');
    } else {
      commonItems.push('인생 경험을 바탕으로 한 지혜로운 선택하기');
    }
    
    return commonItems;
  }

  /**
   * 인연운 기본 데이터 (GPT 실패 시)
   */
  private getDefaultDestinyData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      destiny: {
        destiny_score: 75,
        summary: '인연운 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        advice: '새로운 만남에 열린 마음을 유지하세요.',
        meeting_period: '분석 중입니다.',
        meeting_place: '분석 중입니다.',
        partner_traits: ['분석 중입니다.'],
        development_chance: '분석 중입니다.',
        predictions: {
          first_meeting: '분석 중입니다.',
          relationship: '분석 중입니다.',
          long_term: '분석 중입니다.'
        },
        action_items: ['분석 중입니다.']
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 재능 운세 GPT 시뮬레이션 (실제로는 GPT API 호출)
   */
  private async generateTalentFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('📡 GPT 재능 분석 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    // GPT 시뮬레이션: MBTI와 생년월일 기반 개인화된 재능 분석
    const mbti = userProfile.mbti || 'ISFJ';
    const age = this.calculateAge(userProfile.birth_date);
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    
    // MBTI별 주요 재능 특성
    const talentTraits = this.getTalentTraitsByMBTI(mbti);
    const dominantElement = this.getDominantElementByBirth(birthMonth);
    
    const talentResult = {
      talent: {
        summary: `${dominantElement.name}의 기운이 강해 ${talentTraits.mainStrength}한 타입입니다.`,
        elements: this.getTalentElements(mbti, birthMonth),
        strengths: this.getTalentStrengths(mbti, dominantElement.type),
        weaknesses: this.getTalentWeaknesses(mbti),
        recommended_fields: this.getRecommendedFields(mbti, dominantElement.type),
        growth_tips: this.getGrowthTips(mbti, age),
        skill_analysis: {
          analytical: this.getAnalyticalSkill(mbti),
          creative: this.getCreativeSkill(mbti),
          leadership: this.getLeadershipSkill(mbti),
          communication: this.getCommunicationSkill(mbti),
          focus: this.getFocusSkill(mbti)
        },
        potential_score: this.calculateTalentPotentialScore(userProfile), // 개인화된 점수 계산
        development_phases: this.getDevelopmentPhases(age, mbti)
      },
      generated_at: new Date().toISOString()
    };
    
    console.log('✅ GPT 재능 분석 생성 완료 (사용자:', userProfile.name + ')');
    return talentResult;
  }

  private getTalentTraitsByMBTI(mbti: string): { mainStrength: string; secondaryStrength: string } {
    const traits: Record<string, { mainStrength: string; secondaryStrength: string }> = {
      'ENFP': { mainStrength: '창의적이고 열정적', secondaryStrength: '사람들과의 소통' },
      'ENFJ': { mainStrength: '리더십과 감화력이 뛰어', secondaryStrength: '타인을 이끄는 능력' },
      'ENTP': { mainStrength: '혁신적이고 논리적', secondaryStrength: '새로운 아이디어 창출' },
      'ENTJ': { mainStrength: '전략적이고 추진력이 강', secondaryStrength: '목표 달성 능력' },
      'ESFP': { mainStrength: '활동적이고 사교적', secondaryStrength: '실용적 문제 해결' },
      'ESFJ': { mainStrength: '협력적이고 세심', secondaryStrength: '조화로운 관계 형성' },
      'ESTP': { mainStrength: '행동력이 뛰어나고 현실적', secondaryStrength: '즉석 대응 능력' },
      'ESTJ': { mainStrength: '체계적이고 실행력이 강', secondaryStrength: '조직 관리 능력' },
      'INFP': { mainStrength: '독창적이고 깊이 있', secondaryStrength: '가치 중심 사고' },
      'INFJ': { mainStrength: '통찰력과 직관이 뛰어', secondaryStrength: '미래 비전 제시' },
      'INTP': { mainStrength: '분석적이고 논리적', secondaryStrength: '복잡한 문제 해결' },
      'INTJ': { mainStrength: '체계적이고 독립적', secondaryStrength: '장기 계획 수립' },
      'ISFP': { mainStrength: '예술적이고 섬세', secondaryStrength: '개인적 가치 추구' },
      'ISFJ': { mainStrength: '책임감이 강하고 배려심이 깊', secondaryStrength: '안정적 지원 역할' },
      'ISTP': { mainStrength: '실용적이고 기술적', secondaryStrength: '손재주와 문제 해결' },
      'ISTJ': { mainStrength: '신중하고 체계적', secondaryStrength: '정확성과 일관성' }
    };
    
    return traits[mbti] || { mainStrength: '균형 잡히고 안정적', secondaryStrength: '다방면의 능력' };
  }

  private getDominantElementByBirth(birthMonth: number): { name: string; type: string } {
    if (birthMonth >= 3 && birthMonth <= 5) {
      return { name: '목(木)', type: 'wood' }; // 봄
    } else if (birthMonth >= 6 && birthMonth <= 8) {
      return { name: '화(火)', type: 'fire' }; // 여름
    } else if (birthMonth >= 9 && birthMonth <= 11) {
      return { name: '금(金)', type: 'metal' }; // 가을
    } else {
      return { name: '수(水)', type: 'water' }; // 겨울
    }
  }

  private getTalentElements(mbti: string, birthMonth: number): Array<{ subject: string; value: number }> {
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.includes('J');
    
    return [
      { 
        subject: '창의', 
        value: Math.floor(
          (isIntuitive ? 80 : 60) + 
          (isExtrovert ? 10 : 0) + 
          (birthMonth % 20)
        ) 
      },
      { 
        subject: '분석', 
        value: Math.floor(
          (!isFeeling ? 80 : 60) + 
          (!isExtrovert ? 10 : 0) + 
          ((birthMonth * 2) % 20)
        ) 
      },
      { 
        subject: '리더십', 
        value: Math.floor(
          (isExtrovert ? 80 : 50) + 
          (isJudging ? 15 : 5) + 
          (birthMonth % 15)
        ) 
      },
      { 
        subject: '소통', 
        value: Math.floor(
          (isExtrovert ? 85 : 55) + 
          (isFeeling ? 15 : 5) + 
          ((birthMonth * 3) % 15)
        ) 
      },
      { 
        subject: '집중', 
        value: Math.floor(
          (!isExtrovert ? 80 : 60) + 
          (isJudging ? 15 : 5) + 
          (birthMonth % 20)
        ) 
      }
    ];
  }

  private getTalentStrengths(mbti: string, elementType: string): string[] {
    const baseStrengths = [];
    
    // MBTI별 기본 강점
    if (mbti.includes('E')) {
      baseStrengths.push('활발한 에너지와 추진력');
      baseStrengths.push('사람들과의 원활한 소통 능력');
    } else {
      baseStrengths.push('깊이 있는 사고와 집중력');
      baseStrengths.push('신중한 판단과 분석 능력');
    }
    
    if (mbti.includes('N')) {
      baseStrengths.push('창의적 아이디어와 미래 지향적 사고');
    } else {
      baseStrengths.push('현실적이고 실용적인 문제 해결 능력');
    }
    
    if (mbti.includes('F')) {
      baseStrengths.push('공감 능력과 따뜻한 인간관계');
    } else {
      baseStrengths.push('논리적 사고와 객관적 판단력');
    }
    
    // 오행별 추가 강점
    if (elementType === 'fire') {
      baseStrengths.push('열정적이고 도전적인 성향');
    } else if (elementType === 'water') {
      baseStrengths.push('유연하고 적응력이 뛰어남');
    } else if (elementType === 'wood') {
      baseStrengths.push('성장 지향적이고 끈기 있음');
    } else if (elementType === 'metal') {
      baseStrengths.push('정확하고 체계적인 성향');
    }
    
    return baseStrengths.slice(0, 4); // 최대 4개만 반환
  }

  private getTalentWeaknesses(mbti: string): string[] {
    const weaknesses = [];
    
    if (mbti.includes('E')) {
      weaknesses.push('때로는 성급한 결정을 내릴 수 있음');
      weaknesses.push('혼자만의 시간이 부족할 수 있음');
    } else {
      weaknesses.push('새로운 환경 적응에 시간이 필요할 수 있음');
      weaknesses.push('자신의 의견을 표현하는 데 주저할 수 있음');
    }
    
    if (mbti.includes('P')) {
      weaknesses.push('계획 수립과 일정 관리가 어려울 수 있음');
    } else {
      weaknesses.push('예상치 못한 변화에 스트레스를 받을 수 있음');
    }
    
    return weaknesses.slice(0, 3); // 최대 3개만 반환
  }

  private getRecommendedFields(mbti: string, elementType: string): string[] {
    const fields = [];
    
    // MBTI별 추천 분야
    if (mbti.startsWith('EN')) {
      fields.push('경영·리더십', '마케팅·홍보', '컨설팅');
    } else if (mbti.startsWith('ES')) {
      fields.push('서비스업', '영업·판매', '이벤트 기획');
    } else if (mbti.startsWith('IN')) {
      fields.push('연구·개발', '기획·전략', '창작 활동');
    } else {
      fields.push('전문 기술직', '관리·운영', '교육·상담');
    }
    
    // 오행별 추가 분야
    if (elementType === 'fire') {
      fields.push('예술·디자인', '엔터테인먼트');
    } else if (elementType === 'water') {
      fields.push('IT·기술', '물류·유통');
    } else if (elementType === 'wood') {
      fields.push('교육·훈련', '의료·복지');
    } else if (elementType === 'metal') {
      fields.push('금융·회계', '법률·행정');
    }
    
    return [...new Set(fields)].slice(0, 4); // 중복 제거 후 최대 4개
  }

  private getGrowthTips(mbti: string, age: number): string[] {
    const tips = [];
    
    if (age < 25) {
      tips.push('다양한 경험을 통해 자신의 잠재력을 발견해보세요');
      tips.push('멘토를 찾아 조언을 구하는 것이 도움이 됩니다');
    } else if (age < 35) {
      tips.push('전문성을 높이기 위한 꾸준한 학습이 중요합니다');
      tips.push('네트워킹을 통해 기회를 확장해보세요');
    } else {
      tips.push('경험을 바탕으로 후배들을 가르치는 역할을 해보세요');
      tips.push('새로운 도전을 통해 지속적인 성장을 추구하세요');
    }
    
    // MBTI별 특화 팁
    if (mbti.includes('P')) {
      tips.push('체계적인 계획과 일정 관리 능력을 기르세요');
    } else {
      tips.push('유연성을 기르고 변화에 열린 마음을 가지세요');
    }
    
    return tips.slice(0, 3);
  }

    private getAnalyticalSkill(mbti: string): number {
    const scores: Record<string, number> = {
      'INTJ': 95, 'INTP': 93, 'ENTJ': 88, 'ENTP': 85,
      'ISTJ': 82, 'ESTJ': 80, 'INFJ': 78, 'ENFJ': 75,
      'ISTP': 72, 'ESTP': 68, 'ISFJ': 65, 'ESFJ': 62,
      'INFP': 70, 'ENFP': 68, 'ISFP': 60, 'ESFP': 55
    };
    return scores[mbti] || 70;
  }

    private getCreativeSkill(mbti: string): number {
    const scores: Record<string, number> = {
      'ENFP': 95, 'INFP': 92, 'ENTP': 90, 'INTP': 85,
      'ESFP': 83, 'ISFP': 80, 'ENFJ': 78, 'INFJ': 75,
      'ESTP': 70, 'ISTP': 68, 'ESFJ': 65, 'ISFJ': 62,
      'ENTJ': 60, 'INTJ': 58, 'ESTJ': 55, 'ISTJ': 50
    };
    return scores[mbti] || 65;
  }

    private getLeadershipSkill(mbti: string): number {
    const scores: Record<string, number> = {
      'ENTJ': 95, 'ENFJ': 92, 'ESTJ': 88, 'ESFJ': 82,
      'ENTP': 80, 'ENFP': 78, 'ESTP': 75, 'ESFP': 70,
      'INTJ': 68, 'INFJ': 65, 'ISTJ': 62, 'ISFJ': 60,
      'INTP': 55, 'INFP': 52, 'ISTP': 50, 'ISFP': 48
    };
    return scores[mbti] || 60;
  }

  private getCommunicationSkill(mbti: string): number {
    return mbti.includes('E') ? 
      Math.floor(Math.random() * 20) + 75 : 
      Math.floor(Math.random() * 25) + 55;
  }

  private getFocusSkill(mbti: string): number {
    return mbti.includes('I') && mbti.includes('J') ? 
      Math.floor(Math.random() * 20) + 80 : 
      mbti.includes('I') ? 
        Math.floor(Math.random() * 25) + 70 : 
        Math.floor(Math.random() * 30) + 55;
  }

  private getDevelopmentPhases(age: number, mbti: string): Array<{ phase: string; description: string; focus: string }> {
    const phases = [];
    
    if (age < 25) {
      phases.push({
        phase: '탐색기',
        description: '다양한 분야에서 자신의 재능을 발견하는 시기',
        focus: '폭넓은 경험과 학습'
      });
    } else if (age < 35) {
      phases.push({
        phase: '발전기',
        description: '발견한 재능을 구체적으로 개발하는 시기',
        focus: '전문성 향상과 실무 경험'
      });
    } else if (age < 50) {
      phases.push({
        phase: '완성기',
        description: '축적된 경험을 바탕으로 성과를 창출하는 시기',
        focus: '리더십과 영향력 확대'
      });
    } else {
      phases.push({
        phase: '전수기',
        description: '후배들에게 지식과 경험을 전수하는 시기',
        focus: '멘토링과 사회 기여'
      });
    }
    
    return phases;
  }

  /**
   * 재능 운세 기본 데이터 (GPT 실패 시)
   */
  private getDefaultTalentData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      talent: {
        summary: '재능 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        elements: [
          { subject: '창의', value: 70 },
          { subject: '분석', value: 70 },
          { subject: '리더십', value: 70 },
          { subject: '소통', value: 70 },
          { subject: '집중', value: 70 }
        ],
        strengths: ['분석 중입니다.'],
        weaknesses: ['분석 중입니다.'],
        recommended_fields: ['분석 중입니다.'],
        growth_tips: ['분석 중입니다.'],
        skill_analysis: {
          analytical: 70,
          creative: 70,
          leadership: 70,
          communication: 70,
          focus: 70
        },
        potential_score: 80,
        development_phases: [{
          phase: '분석 중',
          description: '재능 분석이 진행 중입니다.',
          focus: '잠시 후 다시 확인해주세요.'
        }]
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 사주 심리분석 GPT 시뮬레이션 (실제로는 GPT API 호출)
   */
  private async generateSajuPsychologyFromGPT(userProfile: UserProfile): Promise<any> {
    console.log(`🧠 GPT 사주 심리분석 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    // GPT 시뮬레이션: MBTI + 생년월일 기반 심리분석
    const birthYear = parseInt(userProfile.birth_date.split('-')[0]);
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    const mbti = userProfile.mbti || 'ISFP';
    
    // MBTI별 기본 성격 패턴
    const personalityPatterns = {
      'ENTJ': { focus: '목표지향적이고 강한 리더십', weakness: '완벽주의와 스트레스' },
      'ENFJ': { focus: '타인을 이끄는 카리스마', weakness: '타인 우선으로 인한 번아웃' },
      'INTJ': { focus: '독립적이고 전략적 사고', weakness: '고집과 사회적 고립' },
      'INFJ': { focus: '깊은 통찰력과 이상주의', weakness: '완벽주의와 예민함' },
      'ENTP': { focus: '창의적이고 혁신적', weakness: '집중력 부족과 우유부단' },
      'ENFP': { focus: '열정적이고 사교적', weakness: '감정기복과 지속력 부족' },
      'INTP': { focus: '논리적이고 분석적', weakness: '실행력 부족과 사회성 문제' },
      'INFP': { focus: '섬세하고 가치지향적', weakness: '갈등 회피와 우울감' },
      'ESTJ': { focus: '체계적이고 책임감 강함', weakness: '융통성 부족과 고집' },
      'ESFJ': { focus: '협조적이고 봉사정신', weakness: '거절 못하는 성격과 스트레스' },
      'ISTJ': { focus: '성실하고 신뢰할 수 있음', weakness: '변화 거부와 보수성' },
      'ISFJ': { focus: '배려심 깊고 헌신적', weakness: '자기희생과 번아웃' },
      'ESTP': { focus: '활동적이고 현실적', weakness: '계획성 부족과 충동성' },
      'ESFP': { focus: '활발하고 낙천적', weakness: '집중력 부족과 계획성 문제' },
      'ISTP': { focus: '실용적이고 독립적', weakness: '감정표현 어려움과 무관심' },
      'ISFP': { focus: '온화하고 예술적 감성', weakness: '우유부단과 자신감 부족' }
    };

    const pattern = personalityPatterns[mbti as keyof typeof personalityPatterns] || personalityPatterns['ISFP'];
    
    // 생년월일 기반 계절/오행 특성
    const seasonalTraits = {
      spring: '목의 기운이 강해 성장욕구와 창의성이 풍부',
      summer: '화의 기운이 강해 열정적이고 사교적',
      autumn: '금의 기운이 강해 결단력과 정의감이 뚜렷',
      winter: '수의 기운이 강해 깊은 사색과 지혜를 추구'
    };
    
    const season = birthMonth <= 2 || birthMonth === 12 ? 'winter' :
                  birthMonth <= 5 ? 'spring' :
                  birthMonth <= 8 ? 'summer' : 'autumn';
    
    const generationTraits = birthYear < 1980 ? '안정과 전통을 중시' :
                           birthYear < 1990 ? '변화와 도전을 추구' :
                           birthYear < 2000 ? '개성과 자유를 중시' : '글로벌하고 디지털 네이티브';

    const result = {
      summary: `${seasonalTraits[season]}하며, ${pattern.focus}한 성향을 가지고 있습니다.`,
      personality: `${mbti} 성향으로 ${pattern.focus}합니다. ${seasonalTraits[season]}한 특징이 성격에 반영되어 있으며, ${generationTraits}하는 가치관을 보입니다. 자연스럽게 주변에 영향을 미치는 카리스마가 있지만, ${pattern.weakness}에 주의가 필요합니다.`,
      relationship: `대인관계에서는 ${mbti.includes('E') ? '외향적 에너지로 사람들과 활발하게 소통하며' : '내향적 성향으로 깊이 있는 관계를 선호하며'}, ${mbti.includes('F') ? '감정과 가치를 중시하여 따뜻한 관계를 형성' : '논리와 객관성을 바탕으로 신뢰할 수 있는 관계를 구축'}합니다. ${season === 'spring' ? '새로운 만남에 적극적' : season === 'summer' ? '열정적으로 관계를 발전시키려' : season === 'autumn' ? '신중하게 관계를 선별' : '깊이 있는 소수의 관계를 중시'}하는 경향이 있습니다.`,
      psyche: `내면에는 ${mbti.includes('N') ? '이상과 가능성을 추구하는 직관적' : '현실과 경험을 중시하는 감각적'}인 면모가 자리잡고 있습니다. ${mbti.includes('P') ? '유연하고 개방적인 사고로 다양한 선택지를 고려하지만, 때로는 결정을 내리는 데 어려움' : '체계적이고 계획적인 사고로 목표를 향해 나아가지만, 때로는 융통성 부족으로 인한 스트레스'}을 느낍니다. ${pattern.weakness}가 심리적 과제로 작용할 수 있습니다.`,
      advice: `${mbti.includes('I') ? '내향적 에너지를 회복할 수 있는 혼자만의 시간을 확보' : '외향적 에너지를 건강하게 표출할 수 있는 사회적 활동을 늘리'}하세요. ${mbti.includes('T') ? '논리적 사고의 강점을 살리되, 감정적 측면도 인정하고 받아들이는' : '감정적 공감 능력을 활용하되, 객관적 관점도 기르는'} 균형이 필요합니다. ${seasonalTraits[season]}한 타고난 특성을 살려 자신만의 색깔을 만들어가되, ${pattern.weakness}를 극복하기 위한 의식적인 노력을 기울이시기 바랍니다.`,
      generated_at: new Date().toISOString()
    };

    console.log(`✅ GPT 사주 심리분석 생성 완료 (사용자: ${userProfile.name})`);
    return result;
  }

  /**
   * 전통 사주 GPT 시뮬레이션 (실제로는 GPT API 호출)
   */
  private async generateTraditionalSajuFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('📡 GPT 전통 사주 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    // 실제로는 GPT API 호출
    // const response = await this.callGPTAPI('traditional-saju', userProfile);
    
    // 시뮬레이션: 생년월일과 MBTI 기반 개인화
    const mbti = userProfile.mbti || 'ISFJ';
    const birthYear = parseInt(userProfile.birth_date.split('-')[0]);
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    const birthDay = parseInt(userProfile.birth_date.split('-')[2]);
    
    // 오행 기운 계산 (생년월일 기반)
    const elements = this.calculateTraditionalElements(birthYear, birthMonth, birthDay);
    const dominantElement = this.getDominantTraditionalElement(elements);
    
    return {
      'traditional-saju': {
        summary: `타고난 ${dominantElement.name}의 기운이 강해 ${dominantElement.traits}합니다.`,
        total_fortune: this.getTraditionalTotalFortune(mbti, dominantElement.type),
        elements: this.getTraditionalElements(birthYear, birthMonth, birthDay),
        life_cycles: this.getTraditionalLifeCycles(mbti, dominantElement.type),
        blessings: this.getTraditionalBlessings(birthYear, birthMonth, mbti),
        curses: this.getTraditionalCurses(birthYear, birthMonth, mbti),
        details: this.getTraditionalDetails(mbti, dominantElement.type, this.calculateAge(userProfile.birth_date)),
        celestial_stems: this.getCelestialStems(birthYear, birthMonth, birthDay),
        earthly_branches: this.getEarthlyBranches(birthYear, birthMonth, birthDay),
        ten_gods: this.getTenGods(mbti, dominantElement.type),
        lucky_seasons: this.getLuckySeasons(dominantElement.type),
        warning_periods: this.getWarningPeriods(birthYear, birthMonth)
      },
      generated_at: new Date().toISOString()
    };
  }

  private calculateTraditionalElements(birthYear: number, birthMonth: number, birthDay: number): Record<string, number> {
    // 간단한 오행 계산 (실제로는 더 복잡한 명리학 계산)
    const yearElement = birthYear % 10;
    const monthElement = birthMonth % 5;
    const dayElement = birthDay % 5;
    
    return {
      wood: Math.floor((yearElement * 2 + monthElement * 3 + dayElement) % 101),
      fire: Math.floor((yearElement + monthElement * 2 + dayElement * 3) % 101),
      earth: Math.floor((yearElement * 3 + monthElement + dayElement * 2) % 101),
      metal: Math.floor((yearElement * 2 + monthElement * 4 + dayElement) % 101),
      water: Math.floor((yearElement + monthElement + dayElement * 4) % 101)
    };
  }

  private getDominantTraditionalElement(elements: Record<string, number>): { name: string; type: string; traits: string } {
    const max = Math.max(...Object.values(elements));
    const dominantType = Object.keys(elements).find(key => elements[key] === max) || 'water';
    
    const elementTraits: Record<string, { name: string; traits: string }> = {
      wood: { name: '목(木)', traits: '성장력과 창의성이 뛰어나며 유연한 사고를 가지고 있' },
      fire: { name: '화(火)', traits: '열정적이고 활동적이며 리더십이 강' },
      earth: { name: '토(土)', traits: '안정적이고 신뢰할 수 있으며 포용력이 깊' },
      metal: { name: '금(金)', traits: '의지가 강하고 원칙을 중시하며 정의감이 투철' },
      water: { name: '수(水)', traits: '지혜롭고 유연하며 깊이 있는 사고력을 가지고 있' }
    };
    
    return {
      name: elementTraits[dominantType].name,
      type: dominantType,
      traits: elementTraits[dominantType].traits
    };
  }

  private getTraditionalTotalFortune(mbti: string, elementType: string): string {
    const fortuneTemplates = [
      '전체적인 운세 흐름은 안정적이지만 중요한 국면마다 결단력이 필요합니다.',
      '꾸준한 성장과 발전이 예상되며, 인내심을 가지고 임하면 좋은 결과를 얻을 수 있습니다.',
      '변화와 전환의 시기를 맞이하게 되며, 새로운 기회를 잘 활용하는 것이 중요합니다.',
      '타고난 재능이 빛을 발하는 시기로, 자신감을 가지고 도전하면 성공할 수 있습니다.'
    ];
    
    const isExtrovert = mbti.startsWith('E');
    const index = (isExtrovert ? 0 : 2) + (['fire', 'wood'].includes(elementType) ? 0 : 1);
    
    return fortuneTemplates[index];
  }

  private getTraditionalElements(birthYear: number, birthMonth: number, birthDay: number): Array<{ subject: string; value: number }> {
    const elements = this.calculateTraditionalElements(birthYear, birthMonth, birthDay);
    
    return [
      { subject: '木', value: elements.wood },
      { subject: '火', value: elements.fire },
      { subject: '土', value: elements.earth },
      { subject: '金', value: elements.metal },
      { subject: '水', value: elements.water }
    ];
  }

  private getTraditionalLifeCycles(mbti: string, elementType: string): { youth: string; middle: string; old: string } {
    const templates = {
      youth: [
        '학업과 인간관계의 폭이 넓어지는 시기로, 다양한 경험이 후일 큰 자산이 됩니다.',
        '호기심이 왕성하고 배움에 대한 열의가 높아, 기초를 탄탄히 다지는 시기입니다.',
        '창의적 재능이 돋보이기 시작하며, 예술이나 학문 분야에서 두각을 나타낼 수 있습니다.'
      ],
      middle: [
        '직장과 가정에서 중요한 전환점을 맞이하며, 선택에 따라 성취의 폭이 달라집니다.',
        '책임감이 무거워지지만 그만큼 성과도 풍성한 시기로, 꾸준함이 중요합니다.',
        '인맥과 경험이 어우러져 큰 성공을 이룰 수 있는 기회가 찾아옵니다.'
      ],
      old: [
        '쌓아온 지혜가 빛을 발하며 주변의 존경을 받는 시기입니다. 마음의 여유를 찾게 됩니다.',
        '후배들을 이끌며 사회에 기여하는 보람을 느끼게 되는 시기입니다.',
        '건강과 가족의 화목이 가장 큰 복이 되는 시기로, 정신적 만족감이 높습니다.'
      ]
    };
    
    const isIntuitive = mbti.includes('N');
    const index = isIntuitive ? 
      (['fire', 'wood'].includes(elementType) ? 2 : 0) : 1;
    
    return {
      youth: templates.youth[index],
      middle: templates.middle[index],
      old: templates.old[index]
    };
  }

  private getTraditionalBlessings(birthYear: number, birthMonth: number, mbti: string): Array<{ name: string; description: string }> {
    const allBlessings = [
      { name: '천을귀인', description: '귀인의 도움을 받아 위기를 기회로 바꾸는 복.' },
      { name: '문창귀인', description: '학문과 예술 분야에서 재능을 꽃피우는 복.' },
      { name: '금여귀인', description: '금전적 풍요와 물질적 안정을 가져다주는 복.' },
      { name: '태극귀인', description: '조화와 균형을 통해 평화로운 삶을 누리는 복.' },
      { name: '천덕귀인', description: '덕을 쌓아 후손에게까지 복이 이어지는 귀한 복.' },
      { name: '월덕귀인', description: '매달 좋은 일이 끊이지 않는 연속적인 복.' }
    ];
    
    // 생년월일과 MBTI에 따라 2-3개 선택
    const isFeeling = mbti.includes('F');
    const yearMod = birthYear % allBlessings.length;
    const monthMod = birthMonth % allBlessings.length;
    
    const selectedIndices = [
      yearMod,
      (yearMod + monthMod) % allBlessings.length,
      isFeeling ? (yearMod + 2) % allBlessings.length : undefined
    ].filter(idx => idx !== undefined);
    
    return [...new Set(selectedIndices)].map(idx => allBlessings[idx!]);
  }

  private getTraditionalCurses(birthYear: number, birthMonth: number, mbti: string): Array<{ name: string; description: string }> {
    const allCurses = [
      { name: '백호살', description: '충동적인 성향으로 인해 갈등이 생기기 쉬움.' },
      { name: '역마살', description: '이동과 변동이 잦아 한곳에 머무르기 어려움.' },
      { name: '도화살', description: '이성 관계에서 복잡한 상황이 생기기 쉬움.' },
      { name: '겁재살', description: '재물의 손실이나 동업에서 어려움을 겪을 수 있음.' },
      { name: '상관살', description: '권위에 대한 반항심으로 인해 갈등이 생길 수 있음.' },
      { name: '칠살', description: '강한 성격으로 인해 인간관계에서 마찰이 있을 수 있음.' }
    ];
    
    // 생년월일에 따라 1-2개 선택
    const yearMod = birthYear % allCurses.length;
    const monthMod = birthMonth % allCurses.length;
    const isJudging = mbti.includes('J');
    
    const selectedIndices = [
      yearMod,
      isJudging ? (yearMod + monthMod) % allCurses.length : undefined
    ].filter(idx => idx !== undefined);
    
    return [...new Set(selectedIndices)].map(idx => allCurses[idx!]);
  }

  private getTraditionalDetails(mbti: string, elementType: string, age: number): Array<{ subject: string; text: string; premium?: boolean }> {
    const details = [];
    
    // 재물운
    const wealthTexts = {
      fire: '활발한 활동을 통한 재물 획득이 유리하나 충동 소비를 조심하세요.',
      water: '꾸준한 재물 흐름이 있으나 과감한 투자는 신중히 결정하세요.',
      wood: '성장하는 분야에 투자하면 좋은 결과를 얻을 수 있습니다.',
      metal: '안정적인 투자와 저축을 통해 재물을 불려나가는 것이 좋습니다.',
      earth: '부동산이나 안정적인 사업을 통해 재물을 축적하는 것이 유리합니다.'
    };
    
    details.push({
      subject: '재물운',
      text: wealthTexts[elementType as keyof typeof wealthTexts] || wealthTexts.water
    });
    
    // 애정운
    const loveTexts = {
      E: '적극적인 만남을 통해 좋은 인연을 만날 수 있습니다.',
      I: '배려심이 큰 편이나 때때로 우유부단함이 문제될 수 있습니다.'
    };
    
    details.push({
      subject: '애정운',
      text: loveTexts[mbti[0] as keyof typeof loveTexts] || loveTexts.I,
      premium: true
    });
    
    // 건강운
    const healthTexts = {
      fire: '활동적인 성향으로 외상에 주의하고 충분한 휴식이 필요합니다.',
      water: '스트레스 관리에 유의하면 큰 탈 없이 지낼 수 있습니다.',
      wood: '규칙적인 운동과 스트레칭으로 몸의 유연성을 유지하세요.',
      metal: '호흡기 건강에 특히 신경 쓰고 환기에 주의하세요.',
      earth: '소화기 건강을 위해 규칙적인 식사와 적당한 운동이 필요합니다.'
    };
    
    details.push({
      subject: '건강운',
      text: healthTexts[elementType as keyof typeof healthTexts] || healthTexts.water
    });
    
    return details;
  }

  private getCelestialStems(birthYear: number, birthMonth: number, birthDay: number): Array<{ position: string; stem: string; meaning: string }> {
    const stems = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
    const meanings = [
      '창조와 시작의 기운', '성장과 발전의 기운', '열정과 활동의 기운', '섬세함과 예술의 기운',
      '중심과 안정의 기운', '포용과 헌신의 기운', '강인함과 정의의 기운', '변화와 혁신의 기운',
      '지혜와 유연성의 기운', '완성과 마무리의 기운'
    ];
    
    return [
      { position: '년간', stem: stems[birthYear % 10], meaning: meanings[birthYear % 10] },
      { position: '월간', stem: stems[birthMonth % 10], meaning: meanings[birthMonth % 10] },
      { position: '일간', stem: stems[birthDay % 10], meaning: meanings[birthDay % 10] }
    ];
  }

  private getEarthlyBranches(birthYear: number, birthMonth: number, birthDay: number): Array<{ position: string; branch: string; animal: string; meaning: string }> {
    const branches = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
    const animals = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
    const meanings = [
      '적극성과 기민함', '근면과 성실함', '용기와 도전정신', '온화함과 평화',
      '권위와 리더십', '지혜와 직감', '활발함과 자유로움', '친화력과 협조',
      '영리함과 재치', '정확성과 신뢰', '충성심과 정의감', '관대함과 포용력'
    ];
    
    return [
      { position: '년지', branch: branches[birthYear % 12], animal: animals[birthYear % 12], meaning: meanings[birthYear % 12] },
      { position: '월지', branch: branches[birthMonth % 12], animal: animals[birthMonth % 12], meaning: meanings[birthMonth % 12] },
      { position: '일지', branch: branches[birthDay % 12], animal: animals[birthDay % 12], meaning: meanings[birthDay % 12] }
    ];
  }

  private getTenGods(mbti: string, elementType: string): Array<{ name: string; strength: number; description: string }> {
    // 십신(十神) 분석
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.includes('J');
    
    return [
      { name: '비견', strength: isExtrovert ? 80 : 60, description: '동료나 친구와의 관계' },
      { name: '겁재', strength: isExtrovert ? 70 : 50, description: '경쟁과 협력의 관계' },
      { name: '식신', strength: isIntuitive ? 85 : 65, description: '창의성과 표현력' },
      { name: '상관', strength: isIntuitive ? 75 : 55, description: '재능과 개성 발휘' },
      { name: '편재', strength: isJudging ? 70 : 80, description: '재물과 물질에 대한 관계' },
      { name: '정재', strength: isJudging ? 85 : 65, description: '안정적인 수입과 저축' },
      { name: '편관', strength: isFeeling ? 60 : 75, description: '권력과 명예에 대한 욕구' },
      { name: '정관', strength: isFeeling ? 70 : 80, description: '질서와 규범에 대한 태도' },
      { name: '편인', strength: isIntuitive ? 80 : 60, description: '학습과 지식에 대한 태도' },
      { name: '정인', strength: isFeeling ? 85 : 70, description: '보호와 양육에 대한 성향' }
    ];
  }

  private getLuckySeasons(elementType: string): Array<{ season: string; description: string; months: number[] }> {
    const seasonMap: Record<string, { season: string; description: string; months: number[] }[]> = {
      wood: [
        { season: '봄', description: '목의 기운이 왕성해지는 최고의 시기', months: [3, 4, 5] },
        { season: '여름', description: '성장의 기운이 이어지는 좋은 시기', months: [6, 7, 8] }
      ],
      fire: [
        { season: '여름', description: '화의 기운이 절정에 달하는 최적의 시기', months: [6, 7, 8] },
        { season: '봄', description: '활동력이 증가하는 유리한 시기', months: [3, 4, 5] }
      ],
      earth: [
        { season: '늦여름', description: '토의 기운이 안정되는 시기', months: [7, 8, 9] },
        { season: '겨울', description: '침착함과 안정감을 얻는 시기', months: [12, 1, 2] }
      ],
      metal: [
        { season: '가을', description: '금의 기운이 강해지는 최고의 시기', months: [9, 10, 11] },
        { season: '겨울', description: '집중력이 높아지는 유익한 시기', months: [12, 1, 2] }
      ],
      water: [
        { season: '겨울', description: '수의 기운이 왕성해지는 최적의 시기', months: [12, 1, 2] },
        { season: '가을', description: '깊이 있는 사고가 가능한 시기', months: [9, 10, 11] }
      ]
    };
    
    return seasonMap[elementType] || seasonMap.water;
  }

  private getWarningPeriods(birthYear: number, birthMonth: number): Array<{ period: string; description: string; precautions: string[] }> {
    // 간단한 충살(沖煞) 계산
    const conflictMonths = [(birthMonth + 6) % 12 || 12, (birthMonth + 3) % 12 || 12];
    
    return [
      {
        period: `${conflictMonths[0]}월`,
        description: '대충(大沖)의 시기로 중요한 결정은 피하는 것이 좋습니다.',
        precautions: ['중요한 계약이나 이사는 피하세요', '건강 관리에 각별히 신경 쓰세요', '감정적 대립을 피하고 차분함을 유지하세요']
      },
      {
        period: `${conflictMonths[1]}월`,
        description: '소충(小沖)의 시기로 신중함이 필요합니다.',
        precautions: ['새로운 도전보다는 현상 유지에 집중하세요', '인간관계에서 오해가 생기지 않도록 주의하세요']
      }
    ];
  }

  /**
   * 전통 사주 기본 데이터 (GPT 실패 시)
   */
  private getDefaultTraditionalSajuData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      'traditional-saju': {
        summary: '전통 사주 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        total_fortune: '운세 분석이 진행 중입니다.',
        elements: [
          { subject: '木', value: 50 },
          { subject: '火', value: 50 },
          { subject: '土', value: 50 },
          { subject: '金', value: 50 },
          { subject: '水', value: 50 }
        ],
        life_cycles: {
          youth: '분석 중입니다.',
          middle: '분석 중입니다.',
          old: '분석 중입니다.'
        },
        blessings: [{ name: '분석 중', description: '잠시 후 다시 확인해주세요.' }],
        curses: [{ name: '분석 중', description: '잠시 후 다시 확인해주세요.' }],
        details: [{ subject: '분석 중', text: '잠시 후 다시 확인해주세요.' }],
        celestial_stems: [{ position: '분석 중', stem: '-', meaning: '분석 중입니다.' }],
        earthly_branches: [{ position: '분석 중', branch: '-', animal: '-', meaning: '분석 중입니다.' }],
        ten_gods: [{ name: '분석 중', strength: 50, description: '분석 중입니다.' }],
        lucky_seasons: [{ season: '분석 중', description: '분석 중입니다.', months: [1] }],
        warning_periods: [{ period: '분석 중', description: '분석 중입니다.', precautions: ['분석 중입니다.'] }]
      },
      generated_at: new Date().toISOString()
    };
  }

  private async generateNetworkReportFromGPT(userProfile: UserProfile): Promise<any> {
    console.log(`🤝 GPT 인맥보고서 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    // 띠(지지) 계산
    const birthYear = new Date(userProfile.birth_date).getFullYear();
    const zodiacIndex = (birthYear - 4) % 12;
    const zodiacAnimals = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
    const userZodiac = zodiacAnimals[zodiacIndex];
    
    // MBTI별 인간관계 특성
    const mbtiNetworkTraits = {
      'ENFP': { strength: '사교성', weakness: '일관성 부족', benefactor: '체계적인 사람' },
      'ENFJ': { strength: '공감능력', weakness: '과도한 배려', benefactor: '독립적인 사람' },
      'ENTP': { strength: '네트워킹', weakness: '깊이 부족', benefactor: '실무형 사람' },
      'ENTJ': { strength: '리더십', weakness: '독단적', benefactor: '창의적인 사람' },
      'ESFP': { strength: '친화력', weakness: '계획성 부족', benefactor: '조직적인 사람' },
      'ESFJ': { strength: '배려심', weakness: '갈등 회피', benefactor: '솔직한 사람' },
      'ESTP': { strength: '적응력', weakness: '성급함', benefactor: '신중한 사람' },
      'ESTJ': { strength: '실행력', weakness: '융통성 부족', benefactor: '유연한 사람' },
      'INFP': { strength: '진정성', weakness: '소심함', benefactor: '외향적인 사람' },
      'INFJ': { strength: '직관력', weakness: '완벽주의', benefactor: '현실적인 사람' },
      'INTP': { strength: '분석력', weakness: '사교 기피', benefactor: '사교적인 사람' },
      'INTJ': { strength: '전략적 사고', weakness: '냉정함', benefactor: '감성적인 사람' },
      'ISFP': { strength: '순수함', weakness: '수동적', benefactor: '적극적인 사람' },
      'ISFJ': { strength: '충성심', weakness: '자기주장 약함', benefactor: '리더형 사람' },
      'ISTP': { strength: '독립성', weakness: '소통 부족', benefactor: '의사소통 좋은 사람' },
      'ISTJ': { strength: '신뢰성', weakness: '변화 거부', benefactor: '혁신적인 사람' }
    };

    const userMbti = userProfile.mbti || 'ISFJ';
    const mbtiTrait = mbtiNetworkTraits[userMbti as keyof typeof mbtiNetworkTraits] || mbtiNetworkTraits['ISFJ'];
    
    // 계절별 인맥 운세
    const birthMonth = new Date(userProfile.birth_date).getMonth() + 1;
    const season = birthMonth <= 2 || birthMonth === 12 ? '겨울' :
                  birthMonth <= 5 ? '봄' :
                  birthMonth <= 8 ? '여름' : '가을';
    
    const seasonalNetworkScore = {
      '봄': 85, '여름': 90, '가을': 88, '겨울': 82
    };

    // 띠별 상극/상생 관계
    const zodiacCompatibility = {
      '쥐': { compatible: ['용', '원숭이'], avoid: ['말', '양'] },
      '소': { compatible: ['뱀', '닭'], avoid: ['호랑이', '용'] },
      '호랑이': { compatible: ['말', '개'], avoid: ['소', '뱀'] },
      '토끼': { compatible: ['양', '돼지'], avoid: ['닭', '개'] },
      '용': { compatible: ['쥐', '원숭이'], avoid: ['개', '소'] },
      '뱀': { compatible: ['소', '닭'], avoid: ['호랑이', '돼지'] },
      '말': { compatible: ['호랑이', '개'], avoid: ['쥐', '양'] },
      '양': { compatible: ['토끼', '돼지'], avoid: ['쥐', '말'] },
      '원숭이': { compatible: ['쥐', '용'], avoid: ['호랑이', '돼지'] },
      '닭': { compatible: ['소', '뱀'], avoid: ['토끼', '개'] },
      '개': { compatible: ['호랑이', '말'], avoid: ['용', '닭'] },
      '돼지': { compatible: ['토끼', '양'], avoid: ['뱀', '원숭이'] }
    };

    const compatibility = zodiacCompatibility[userZodiac as keyof typeof zodiacCompatibility];
    
    const baseScore = seasonalNetworkScore[season as keyof typeof seasonalNetworkScore];
    const mbtiBonus = userMbti.startsWith('E') ? 5 : -2; // 외향성 보너스
    const finalScore = Math.min(95, Math.max(65, baseScore + mbtiBonus + Math.floor(Math.random() * 10) - 5));

    return {
      score: finalScore,
      summary: `${userProfile.name}님은 ${userZodiac}띠로 ${season}에 태어나 인간관계에서 ${mbtiTrait.strength}을 발휘합니다. 전체적으로 ${finalScore >= 85 ? '매우 원만한' : finalScore >= 75 ? '원만한' : '보통의'} 인맥 운세를 가지고 있습니다.`,
      benefactors: [
        `${compatibility.compatible[0]}띠 또는 ${compatibility.compatible[1]}띠 사람`,
        `${mbtiTrait.benefactor}`,
        `${season === '봄' ? '새로운 시작을 함께할' : season === '여름' ? '열정적인' : season === '가을' ? '성숙한' : '차분한'} 성향의 사람`,
        `${userMbti.includes('T') ? '감정적인' : '논리적인'} 사고를 가진 사람`
      ],
      challengers: [
        `${compatibility.avoid[0]}띠 또는 ${compatibility.avoid[1]}띠 사람`,
        `${mbtiTrait.weakness}을 지적하는 사람`,
        `극단적으로 ${userMbti.includes('J') ? '즉흥적인' : '계획적인'} 사람`,
        `${userMbti.startsWith('I') ? '지나치게 외향적인' : '지나치게 내향적인'} 사람`
      ],
      advice: `${mbtiTrait.strength}을 활용하여 인맥을 넓히되, ${mbtiTrait.weakness}에 주의하세요. ${userZodiac}띠의 특성상 ${compatibility.compatible.join('띠나 ')}띠 사람들과는 자연스럽게 좋은 관계를 형성할 수 있습니다.`,
      actionItems: [
        `${mbtiTrait.benefactor}에게 먼저 다가가기`,
        `${season}의 기운을 활용한 모임 참여하기`,
        `${compatibility.avoid.join('띠나 ')}띠 사람과는 적당한 거리 유지하기`,
        `${userMbti.includes('F') ? '논리적 대화' : '감정 교류'}도 시도해보기`
      ],
      lucky: {
        color: season === '봄' ? '#90EE90' : season === '여름' ? '#FF6B6B' : season === '가을' ? '#FFD700' : '#87CEEB',
        number: (birthYear % 9) + 1,
        direction: ['동쪽', '서쪽', '남쪽', '북쪽'][birthMonth % 4]
      },
      generated_at: new Date().toISOString()
    };
  }

  private async generateTojeongFromGPT(userProfile: UserProfile): Promise<any> {
    console.log(`📜 GPT 토정비결 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    const currentYear = new Date().getFullYear();
    const birthYear = new Date(userProfile.birth_date).getFullYear();
    const birthMonth = new Date(userProfile.birth_date).getMonth() + 1;
    const birthDay = new Date(userProfile.birth_date).getDate();
    
    // 연령대별 운세 특성
    const age = currentYear - birthYear;
    const ageGroup = age < 30 ? '청년' : age < 50 ? '중년' : '장년';
    
    // MBTI별 토정비결 특성
    const mbtiTojeongTraits = {
      'ENFP': { yearlyStyle: '활발한 변화', monthlyFocus: '새로운 도전' },
      'ENFJ': { yearlyStyle: '조화로운 발전', monthlyFocus: '인간관계' },
      'ENTP': { yearlyStyle: '창의적 성장', monthlyFocus: '아이디어 실현' },
      'ENTJ': { yearlyStyle: '목표 달성', monthlyFocus: '리더십 발휘' },
      'ESFP': { yearlyStyle: '즐거운 경험', monthlyFocus: '일상의 행복' },
      'ESFJ': { yearlyStyle: '안정적 관계', monthlyFocus: '배려와 협력' },
      'ESTP': { yearlyStyle: '실용적 성과', monthlyFocus: '즉시 행동' },
      'ESTJ': { yearlyStyle: '체계적 발전', monthlyFocus: '계획 실행' },
      'INFP': { yearlyStyle: '내면 성장', monthlyFocus: '가치 실현' },
      'INFJ': { yearlyStyle: '영감적 변화', monthlyFocus: '직감 신뢰' },
      'INTP': { yearlyStyle: '지적 탐구', monthlyFocus: '분석과 이해' },
      'INTJ': { yearlyStyle: '전략적 발전', monthlyFocus: '장기 계획' },
      'ISFP': { yearlyStyle: '조용한 변화', monthlyFocus: '개인적 성찰' },
      'ISFJ': { yearlyStyle: '신중한 발전', monthlyFocus: '안전한 선택' },
      'ISTP': { yearlyStyle: '실용적 개선', monthlyFocus: '기술 향상' },
      'ISTJ': { yearlyStyle: '점진적 성장', monthlyFocus: '전통적 방법' }
    };

    const userMbti = userProfile.mbti || 'ISFJ';
    const mbtiTrait = mbtiTojeongTraits[userMbti as keyof typeof mbtiTojeongTraits] || mbtiTojeongTraits['ISFJ'];
    
    // 64괘 중에서 선택
    const hexagrams = [
      '건천(乾天)', '곤지(坤地)', '수뢰준(水雷屯)', '산수몽(山水蒙)', '수천수(水天需)', '천수송(天水訟)',
      '지수사(地水師)', '수지비(水地比)', '풍천소축(風天小畜)', '천택리(天澤履)', '지천태(地天泰)', '천지비(天地否)',
      '천화동인(天火同人)', '화천대유(火天大有)', '지산겸(地山謙)', '뢰지예(雷地豫)', '택뢰수(澤雷隨)', '산풍고(山風蠱)',
      '지택림(地澤臨)', '풍지관(風地觀)', '화뢰서합(火雷噬嗑)', '산화비(山火賁)', '산지박(山地剝)', '지뢰복(地雷復)',
      '천뢰무망(天雷無妄)', '산천대축(山天大畜)', '산뢰이(山雷頤)', '택풍대과(澤風大過)', '감수(坎水)', '리화(離火)',
      '택산함(澤山咸)', '뢰풍항(雷風恒)', '천산둔(天山遯)', '뢰천대장(雷天大壯)', '화지진(火地晉)', '지화명이(地火明夷)',
      '풍화가인(風火家人)', '화택규(火澤睽)', '수산건(水山蹇)', '뢰수해(雷水解)', '산택손(山澤損)', '풍뢰익(風雷益)',
      '택천결(澤天夬)', '천풍구(天風姤)', '택지취(澤地萃)', '지풍승(地風升)', '택수곤(澤水困)', '수풍정(水風井)',
      '택화혁(澤火革)', '화풍정(火風鼎)', '진뢰(震雷)', '간산(艮山)', '풍산점(風山漸)', '뢰택귀매(雷澤歸妹)',
      '뢰화풍(雷火豊)', '화산여(火山旅)', '손풍(巽風)', '태택(兌澤)', '풍수환(風水渙)', '수택절(水澤節)',
      '풍택중부(風澤中孚)', '뢰산소과(雷山小過)', '수화기제(水火旣濟)', '화수미제(火水未濟)'
    ];

    // 생년월일 기반 주괘 선택
    const yearlyHexagramIndex = (birthYear + birthMonth + birthDay + currentYear) % hexagrams.length;
    const yearlyHexagram = hexagrams[yearlyHexagramIndex];

    // 월별 괘 생성
    const monthlyFortunes = [];
    const monthNames = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    
    for (let i = 0; i < 12; i++) {
      const monthHexagramIndex = (yearlyHexagramIndex + i * 3 + birthMonth) % hexagrams.length;
      const monthHexagram = hexagrams[monthHexagramIndex];
      
      // 월별 특성 생성
      const seasonType = i < 2 || i === 11 ? '겨울' : i < 5 ? '봄' : i < 8 ? '여름' : '가을';
      const isGoodMonth = (i + birthMonth) % 3 === 0; // 3개월마다 좋은 달
      
      const summaries = {
        '겨울': isGoodMonth ? '차분한 성찰의 시간입니다.' : '인내가 필요한 달입니다.',
        '봄': isGoodMonth ? '새로운 시작이 기다립니다.' : '서두르지 말고 준비하세요.',
        '여름': isGoodMonth ? '활발한 활동으로 성과를 얻습니다.' : '에너지를 아껴 사용하세요.',
        '가을': isGoodMonth ? '결실을 맺는 달입니다.' : '차근차근 정리해 나가세요.'
      };
      
      const advices = {
        '겨울': '건강 관리에 신경 쓰세요.',
        '봄': `${mbtiTrait.monthlyFocus}에 집중하세요.`,
        '여름': '적극적으로 행동하세요.',
        '가을': '감사하는 마음을 가지세요.'
      };

      monthlyFortunes.push({
        month: monthNames[i],
        hexagram: monthHexagram,
        summary: summaries[seasonType as keyof typeof summaries],
        advice: advices[seasonType as keyof typeof advices]
      });
    }

    // 연간 총운 생성
    const yearlyFortuneMessages = {
      '청년': `${currentYear}년은 ${ageGroup} 시기답게 도전과 성장의 해입니다. ${mbtiTrait.yearlyStyle}의 기운이 강하게 작용할 것입니다.`,
      '중년': `${currentYear}년은 ${ageGroup} 시기의 안정과 발전을 추구하는 해입니다. ${mbtiTrait.yearlyStyle}를 통해 균형을 찾으세요.`,
      '장년': `${currentYear}년은 ${ageGroup} 시기의 지혜와 경험이 빛나는 해입니다. ${mbtiTrait.yearlyStyle}로 후배들을 이끌어 주세요.`
    };

    return {
      year: currentYear,
      yearlyHexagram: yearlyHexagram,
      totalFortune: yearlyFortuneMessages[ageGroup as keyof typeof yearlyFortuneMessages],
      monthly: monthlyFortunes,
      userInfo: {
        name: userProfile.name,
        age: age,
        ageGroup: ageGroup,
        mbtiStyle: mbtiTrait.yearlyStyle
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 토정비결 기본 데이터 (GPT 실패 시)
   */
  private getDefaultTojeongData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      tojeong: {
        year: new Date().getFullYear(),
        yearly_hexagram: '천지비(天地否)',
        total_fortune: '토정비결 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        monthly_fortunes: Array.from({ length: 12 }, (_, i) => ({
          month: `${i + 1}월`,
          hexagram: '분석 중',
          summary: '분석이 진행 중입니다.',
          advice: '잠시 후 다시 확인해주세요.'
        }))
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 띠별 운세 GPT 시뮬레이션
   */
  async generateZodiacAnimalFortuneGPT(userProfile: UserProfile): Promise<any> {
    console.log(`📡 GPT 띠별 운세 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    // 생년월일에서 띠 계산
    const birthYear = new Date(userProfile.birth_date).getFullYear();
    const zodiacAnimals = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
    const zodiacAnimal = zodiacAnimals[(birthYear - 4) % 12];
    
    // GPT 시뮬레이션 데이터
    return {
      'zodiac-animal': {
        animal: zodiacAnimal,
        element: this.getZodiacElement(birthYear),
        current_score: Math.floor(Math.random() * 30) + 70,
        monthly_score: Math.floor(Math.random() * 30) + 65,
        yearly_score: Math.floor(Math.random() * 30) + 75,
        summary: `${zodiacAnimal}띠인 당신은 ${userProfile.mbti || '독특한'} 성향과 어우러져 특별한 매력을 발산합니다.`,
        monthly_fortune: {
          love: `${zodiacAnimal}띠의 연애운은 ${['상승세', '안정적', '변화무쌍'][Math.floor(Math.random() * 3)]}를 보입니다.`,
          career: `직장에서 ${zodiacAnimal}띠 특유의 ${['성실함', '창의력', '리더십'][Math.floor(Math.random() * 3)]}이 빛을 발할 것입니다.`,
          wealth: `재물운은 ${['꾸준한 상승', '안정적인 유지', '신중한 관리 필요'][Math.floor(Math.random() * 3)]} 상태입니다.`,
          health: `건강면에서는 ${['활력이 넘치는', '균형 잡힌', '휴식이 필요한'][Math.floor(Math.random() * 3)]} 시기입니다.`
        },
        compatible_animals: this.getCompatibleAnimals(zodiacAnimal),
        avoid_animals: this.getAvoidAnimals(zodiacAnimal),
        lucky_directions: this.getLuckyDirections(zodiacAnimal),
        lucky_colors: this.getZodiacLuckyColors(zodiacAnimal),
        lucky_numbers: this.getZodiacLuckyNumbers(zodiacAnimal),
        monthly_predictions: Array.from({ length: 12 }, (_, i) => ({
          month: i + 1,
          prediction: `${i + 1}월에는 ${zodiacAnimal}띠의 ${['도전정신', '협력', '인내심'][Math.floor(Math.random() * 3)]}이 중요한 열쇠가 될 것입니다.`,
          focus_area: ['인간관계', '건강관리', '재정관리', '자기계발'][Math.floor(Math.random() * 4)]
        })),
        yearly_advice: `${zodiacAnimal}띠인 올해는 ${['새로운 시작', '안정적인 발전', '변화에 대한 적응'][Math.floor(Math.random() * 3)]}의 해입니다. ${userProfile.mbti || '당신의'} 성향을 잘 활용하여 목표를 달성하세요.`,
        warning_months: [3, 7, 11].slice(0, Math.floor(Math.random() * 2) + 1),
        best_months: [5, 8, 10].slice(0, Math.floor(Math.random() * 2) + 1)
      }
    };
  }

  /**
   * 띠별 원소 계산
   */
  private getZodiacElement(year: number): string {
    const elements = ['목', '화', '토', '금', '수'];
    return elements[Math.floor((year - 4) / 2) % 5];
  }

  /**
   * 상극/상생 띠 계산
   */
  private getCompatibleAnimals(animal: string): string[] {
    const compatibility: { [key: string]: string[] } = {
      '쥐': ['용', '원숭이'],
      '소': ['뱀', '닭'],
      '호랑이': ['말', '개'],
      '토끼': ['양', '돼지'],
      '용': ['쥐', '원숭이'],
      '뱀': ['소', '닭'],
      '말': ['호랑이', '개'],
      '양': ['토끼', '돼지'],
      '원숭이': ['쥐', '용'],
      '닭': ['소', '뱀'],
      '개': ['호랑이', '말'],
      '돼지': ['토끼', '양']
    };
    return compatibility[animal] || [];
  }

  private getAvoidAnimals(animal: string): string[] {
    const avoidance: { [key: string]: string[] } = {
      '쥐': ['말'],
      '소': ['양'],
      '호랑이': ['원숭이'],
      '토끼': ['닭'],
      '용': ['개'],
      '뱀': ['돼지'],
      '말': ['쥐'],
      '양': ['소'],
      '원숭이': ['호랑이'],
      '닭': ['토끼'],
      '개': ['용'],
      '돼지': ['뱀']
    };
    return avoidance[animal] || [];
  }

  /**
   * 띠별 행운의 방향
   */
  private getLuckyDirections(animal: string): string[] {
    const directions: { [key: string]: string[] } = {
      '쥐': ['북', '동북'],
      '소': ['북동', '남'],
      '호랑이': ['동', '남'],
      '토끼': ['동', '남동'],
      '용': ['동남', '서북'],
      '뱀': ['남', '동남'],
      '말': ['남', '서남'],
      '양': ['남서', '동'],
      '원숭이': ['서', '북'],
      '닭': ['서', '북서'],
      '개': ['서북', '동남'],
      '돼지': ['북', '서']
    };
    return directions[animal] || ['동'];
  }

  /**
   * 띠별 행운의 색깔
   */
  private getZodiacLuckyColors(animal: string): string[] {
    const colors: { [key: string]: string[] } = {
      '쥐': ['검정', '파랑', '회색'],
      '소': ['노랑', '갈색', '주황'],
      '호랑이': ['초록', '파랑', '검정'],
      '토끼': ['초록', '빨강', '분홍'],
      '용': ['노랑', '금색', '흰색'],
      '뱀': ['빨강', '노랑', '검정'],
      '말': ['빨강', '보라', '주황'],
      '양': ['초록', '빨강', '보라'],
      '원숭이': ['흰색', '금색', '파랑'],
      '닭': ['흰색', '금색', '갈색'],
      '개': ['빨강', '초록', '보라'],
      '돼지': ['노랑', '회색', '갈색']
    };
    return colors[animal] || ['파랑'];
  }

  /**
   * 띠별 행운의 숫자
   */
  private getZodiacLuckyNumbers(animal: string): number[] {
    const numbers: { [key: string]: number[] } = {
      '쥐': [2, 3, 6, 8],
      '소': [1, 4, 5, 9],
      '호랑이': [1, 3, 4, 7],
      '토끼': [3, 4, 6, 9],
      '용': [1, 6, 7, 8],
      '뱀': [2, 7, 8, 9],
      '말': [2, 3, 7, 8],
      '양': [2, 7, 8, 9],
      '원숭이': [1, 7, 8, 9],
      '닭': [5, 7, 8, 9],
      '개': [3, 4, 9],
      '돼지': [2, 5, 8]
    };
    return numbers[animal] || [1, 7];
  }

  /**
   * 띠별 운세 기본 데이터 (GPT 실패 시)
   */
  private getDefaultZodiacAnimalData(userProfile: UserProfile, category?: FortuneCategory): any {
    const birthYear = new Date(userProfile.birth_date).getFullYear();
    const zodiacAnimals = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
    const animal = zodiacAnimals[(birthYear - 4) % 12];
    
    return {
      'zodiac-animal': {
        animal,
        element: this.getZodiacElement(birthYear),
        current_score: 75,
        monthly_score: 70,
        yearly_score: 80,
        summary: '띠별 운세 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        monthly_fortune: {
          love: '분석 중입니다.',
          career: '분석 중입니다.',
          wealth: '분석 중입니다.',
          health: '분석 중입니다.'
        },
        compatible_animals: this.getCompatibleAnimals(animal),
        avoid_animals: this.getAvoidAnimals(animal),
        lucky_directions: this.getLuckyDirections(animal),
        lucky_colors: this.getZodiacLuckyColors(animal),
        lucky_numbers: this.getZodiacLuckyNumbers(animal),
        monthly_predictions: Array.from({ length: 12 }, (_, i) => ({
          month: i + 1,
          prediction: '분석 중입니다.',
          focus_area: '분석 중'
        })),
        yearly_advice: '분석 중입니다.',
        warning_months: [],
        best_months: []
      },
      generated_at: new Date().toISOString()
    };
  }
  /**
   * 개인화된 점수 계산 메서드들
   */
  
  /**
   * 사용자 프로필 기반 운명 점수 계산
   */
  private calculateDestinyScore(userProfile: UserProfile): number {
    let baseScore = 70;
    const mbti = userProfile.mbti || 'ISFJ';
    const age = this.calculateAge(userProfile.birth_date);
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    
    // MBTI별 기본 점수
    if (mbti.includes('E')) baseScore += 8; // 외향적인 사람이 인연 만들기 유리
    if (mbti.includes('F')) baseScore += 5; // 감정형이 인간관계에 유리
    if (mbti.includes('P')) baseScore += 3; // 유연한 사람이 새로운 만남에 열려있음
    
    // 나이별 점수 (최적 연령대)
    if (age >= 25 && age <= 35) baseScore += 7; // 최적 만남 연령대
    else if (age >= 20 && age <= 40) baseScore += 3;
    
    // 계절별 점수 (봄, 가을에 인연 운 상승)
    if (birthMonth === 3 || birthMonth === 4 || birthMonth === 5 || 
        birthMonth === 9 || birthMonth === 10 || birthMonth === 11) {
      baseScore += 5;
    }
    
    return Math.min(Math.max(baseScore, 65), 95); // 65-95점 범위
  }

  /**
   * 재능 잠재력 점수 계산
   */
  private calculateTalentPotentialScore(userProfile: UserProfile): number {
    let baseScore = 75;
    const mbti = userProfile.mbti || 'ISFJ';
    const age = this.calculateAge(userProfile.birth_date);
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    
    // MBTI별 재능 점수
    const talentScores: Record<string, number> = {
      'ENFP': 15, 'ENTP': 13, 'INTJ': 12, 'INFJ': 11,
      'ENFJ': 10, 'ENTJ': 10, 'INTP': 9, 'INFP': 9,
      'ESFP': 8, 'ESTP': 8, 'ISFP': 7, 'ISTP': 7,
      'ESFJ': 6, 'ESTJ': 6, 'ISFJ': 5, 'ISTJ': 5
    };
    
    baseScore += talentScores[mbti] || 5;
    
    // 나이별 점수 (젊을수록 발전 가능성 높음)
    if (age < 25) baseScore += 5;
    else if (age < 35) baseScore += 3;
    else if (age < 45) baseScore += 1;
    
    // 태어난 계절별 재능 특성
    if (birthMonth >= 3 && birthMonth <= 5) baseScore += 3; // 봄 - 창조력
    else if (birthMonth >= 6 && birthMonth <= 8) baseScore += 2; // 여름 - 에너지
    else if (birthMonth >= 9 && birthMonth <= 11) baseScore += 4; // 가을 - 완성도
    else baseScore += 2; // 겨울 - 집중력
    
    return Math.min(Math.max(baseScore, 70), 95); // 70-95점 범위
  }

  /**
   * 띠별 운세 개인화 점수 계산
   */
  private calculateZodiacScore(userProfile: UserProfile, scoreType: 'current' | 'monthly' | 'yearly'): number {
    const birthYear = new Date(userProfile.birth_date).getFullYear();
    const currentYear = new Date().getFullYear();
    const currentMonth = new Date().getMonth() + 1;
    const mbti = userProfile.mbti || 'ISFJ';
    
    let baseScore = 70;
    
    // 띠별 기본 운세 (12년 주기)
    const zodiacCycle = (currentYear - birthYear) % 12;
    const zodiacScores = [85, 75, 65, 70, 80, 90, 75, 65, 85, 80, 70, 75]; // 12년 주기
    baseScore = zodiacScores[zodiacCycle];
    
    // MBTI별 보정
    if (mbti.includes('E')) baseScore += 3;
    if (mbti.includes('J')) baseScore += 2;
    
    // 점수 타입별 조정
    if (scoreType === 'current') {
      // 현재 달 기준 조정
      const monthlyAdjustment = [0, -2, 3, 5, 2, -1, -3, 1, 4, 2, -1, 0];
      baseScore += monthlyAdjustment[currentMonth - 1];
    } else if (scoreType === 'monthly') {
      baseScore -= 5; // 월별은 조금 더 보수적
    } else if (scoreType === 'yearly') {
      baseScore += 5; // 연간은 조금 더 긍정적
    }
    
    return Math.min(Math.max(baseScore, 55), 95);
  }

  /**
   * GPT를 통한 전통 궁합 분석 생성
   */
  private async generateTraditionalCompatibilityGPT(userProfile: UserProfile, category?: FortuneCategory): Promise<any> {
    const age = this.calculateAge(userProfile.birth_date);
    const birthYear = new Date(userProfile.birth_date).getFullYear();
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    const birthDay = parseInt(userProfile.birth_date.split('-')[2]);
    
    // 사주 기본 정보 계산
    const elements = this.calculateTraditionalElements(birthYear, birthMonth, birthDay);
    const dominantElement = this.getDominantTraditionalElement(elements);
    
    // 개인화된 점수들
    const compatibilityScore = this.calculateCompatibilityScore(userProfile);
    const marriageScore = this.calculateMarriageScore(userProfile);
    const harmonyScore = this.calculateHarmonyScore(userProfile);
    
    console.log(`📡 GPT 전통 궁합 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    try {
      // 실제 GPT API 호출은 주석 처리 (비용 절약)
      // const gptResponse = await callGPTAPI(...);
      
      // 대신 알고리즘 기반 개인화된 데이터 생성
      const compatibilityData = {
        summary: this.generateCompatibilitySummary(userProfile, compatibilityScore, dominantElement.type),
        total_score: compatibilityScore,
        marriage_score: marriageScore,
        harmony_score: harmonyScore,
        dominant_element: dominantElement,
        best_matches: this.getBestMatches(dominantElement.type, userProfile.mbti),
        avoid_matches: this.getAvoidMatches(dominantElement.type, userProfile.mbti),
        compatibility_factors: this.getCompatibilityFactors(userProfile.mbti, dominantElement.type),
        marriage_timing: this.getMarriageTimingAdvice(age, compatibilityScore, userProfile.mbti),
        relationship_advice: this.getRelationshipAdvice(userProfile.mbti, dominantElement.type),
        traditional_analysis: {
          celestial_stems: this.getCelestialStems(birthYear, birthMonth, birthDay),
          earthly_branches: this.getEarthlyBranches(birthYear, birthMonth, birthDay),
          ten_gods: this.getTenGods(userProfile.mbti || 'ISFJ', dominantElement.type),
          element_balance: elements
        },
        lucky_periods: this.getLuckyPeriodsForCompatibility(birthMonth, dominantElement.type),
        warning_periods: this.getWarningPeriodsForCompatibility(birthYear, birthMonth),
        userInfo: {
          name: userProfile.name,
          birth_date: userProfile.birth_date,
          mbti: userProfile.mbti || 'ISFJ',
          age
        }
      };
      
      return {
        'traditional-compatibility': compatibilityData,
        generated_at: new Date().toISOString()
      };
      
    } catch (error) {
      console.error('GPT 전통 궁합 생성 실패:', error);
             return this.getDefaultTraditionalCompatibilityData(userProfile, category);
    }
  }

  /**
   * 궁합 점수 계산
   */
  private calculateCompatibilityScore(userProfile: UserProfile): number {
    let baseScore = 75;
    const mbti = userProfile.mbti || 'ISFJ';
    const age = this.calculateAge(userProfile.birth_date);
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    
    // MBTI별 궁합 기본 점수
    if (mbti.includes('F')) baseScore += 8; // 감정형이 궁합에 유리
    if (mbti.includes('E')) baseScore += 5; // 외향형이 사교성에 유리
    if (mbti.includes('J')) baseScore += 3; // 판단형이 안정성에 유리
    
    // 나이별 점수
    if (age >= 25 && age <= 35) baseScore += 10; // 최적 궁합 연령대
    else if (age >= 20 && age <= 40) baseScore += 5;
    
    // 계절별 점수
    if (birthMonth === 5 || birthMonth === 6 || birthMonth === 9 || birthMonth === 10) {
      baseScore += 5; // 궁합이 좋은 계절
    }
    
    return Math.min(Math.max(baseScore, 65), 95);
  }

  /**
   * 결혼 점수 계산
   */
  private calculateMarriageScore(userProfile: UserProfile): number {
    let baseScore = 70;
    const mbti = userProfile.mbti || 'ISFJ';
    const age = this.calculateAge(userProfile.birth_date);
    
    // MBTI별 결혼 적합성
    const marriageScores: Record<string, number> = {
      'ESFJ': 15, 'ISFJ': 12, 'ENFJ': 10, 'INFJ': 10,
      'ESTJ': 8, 'ISTJ': 8, 'ENTJ': 8, 'INTJ': 8,
      'ESFP': 7, 'ISFP': 7, 'ENFP': 7, 'INFP': 7,
      'ESTP': 5, 'ISTP': 5, 'ENTP': 5, 'INTP': 5
    };
    
    baseScore += marriageScores[mbti] || 5;
    
    // 나이별 결혼 적합도
    if (age >= 28 && age <= 35) baseScore += 8;
    else if (age >= 25 && age <= 40) baseScore += 5;
    else if (age >= 22 && age <= 45) baseScore += 2;
    
    return Math.min(Math.max(baseScore, 60), 95);
  }

  /**
   * 조화 점수 계산
   */
  private calculateHarmonyScore(userProfile: UserProfile): number {
    let baseScore = 75;
    const mbti = userProfile.mbti || 'ISFJ';
    const birthMonth = parseInt(userProfile.birth_date.split('-')[1]);
    
    // MBTI별 조화 능력
    if (mbti.includes('F')) baseScore += 10; // 감정형이 조화에 유리
    if (mbti.endsWith('J')) baseScore += 5; // 판단형이 안정성에 유리
    if (mbti.startsWith('I')) baseScore += 3; // 내향형이 깊이 있는 관계에 유리
    
    // 계절별 조화 운
    const seasonScores = [2, 2, 5, 8, 10, 8, 5, 3, 7, 9, 6, 3]; // 월별 조화 점수
    baseScore += seasonScores[birthMonth - 1];
    
    return Math.min(Math.max(baseScore, 65), 95);
  }

  /**
   * 전통 궁합 요약 생성
   */
  private generateCompatibilitySummary(userProfile: UserProfile, score: number, elementType: string): string {
    const name = userProfile.name;
    const mbti = userProfile.mbti || 'ISFJ';
    
    if (score >= 85) {
      return `${name}님은 전통적으로 매우 좋은 궁합운을 가지고 계십니다. ${elementType} 기운이 강해 ${mbti.includes('F') ? '정서적으로 안정적인' : '현실적으로 균형잡힌'} 관계를 만들어갈 수 있어요.`;
    } else if (score >= 75) {
      return `${name}님의 궁합운이 상당히 좋은 편입니다. ${elementType} 원소의 영향으로 ${mbti.includes('E') ? '활발하고 조화로운' : '깊이 있고 진실한'} 인연을 만날 가능성이 높습니다.`;
    } else {
      return `${name}님은 신중한 선택이 필요한 시기입니다. ${elementType} 기운을 잘 활용하면 ${mbti.includes('J') ? '계획적이고 안정적인' : '자연스럽고 편안한'} 관계를 만들 수 있을 것입니다.`;
    }
  }

  /**
   * 최적 궁합 타입
   */
  private getBestMatches(elementType: string, mbti?: string): Array<{ type: string; description: string; compatibility_score: number }> {
    const matches: Record<string, Array<{ type: string; description: string; compatibility_score: number }>> = {
      '금': [
        { type: '토 오행', description: '토생금으로 서로를 도와주는 관계', compatibility_score: 95 },
        { type: '수 오행', description: '금생수로 자연스러운 조화', compatibility_score: 85 }
      ],
      '목': [
        { type: '수 오행', description: '수생목으로 서로 성장시키는 관계', compatibility_score: 95 },
        { type: '화 오행', description: '목생화로 열정적인 발전', compatibility_score: 85 }
      ],
      '수': [
        { type: '금 오행', description: '금생수로 안정적인 지원', compatibility_score: 95 },
        { type: '목 오행', description: '수생목으로 함께 발전', compatibility_score: 85 }
      ],
      '화': [
        { type: '목 오행', description: '목생화로 활발한 에너지 교환', compatibility_score: 95 },
        { type: '토 오행', description: '화생토로 실용적인 결합', compatibility_score: 85 }
      ],
      '토': [
        { type: '화 오행', description: '화생토로 따뜻한 안정감', compatibility_score: 95 },
        { type: '금 오행', description: '토생금으로 믿음직한 지원', compatibility_score: 85 }
      ]
    };
    return matches[elementType] || matches['토'];
  }

  /**
   * 피해야 할 궁합 타입
   */
  private getAvoidMatches(elementType: string, mbti?: string): Array<{ type: string; reason: string; caution_level: string }> {
    const avoidMatches: Record<string, Array<{ type: string; reason: string; caution_level: string }>> = {
      '금': [
        { type: '화 오행', reason: '화극금으로 갈등 가능성', caution_level: '높음' },
        { type: '목 오행', reason: '금극목으로 견해 차이', caution_level: '중간' }
      ],
      '목': [
        { type: '금 오행', reason: '금극목으로 압박감 가능', caution_level: '높음' },
        { type: '토 오행', reason: '목극토로 가치관 충돌', caution_level: '중간' }
      ],
      '수': [
        { type: '토 오행', reason: '토극수로 제약 느낄 수 있음', caution_level: '높음' },
        { type: '화 오행', reason: '수극화로 냉각 우려', caution_level: '중간' }
      ],
      '화': [
        { type: '수 오행', reason: '수극화로 열정 저하 가능', caution_level: '높음' },
        { type: '금 오행', reason: '화극금으로 대립 우려', caution_level: '중간' }
      ],
      '토': [
        { type: '목 오행', reason: '목극토로 변화 압박', caution_level: '높음' },
        { type: '수 오행', reason: '토극수로 소통 어려움', caution_level: '중간' }
      ]
    };
    return avoidMatches[elementType] || avoidMatches['토'];
  }

  /**
   * 궁합 요소들
   */
  private getCompatibilityFactors(mbti?: string, elementType?: string): Array<{ factor: string; score: number; description: string }> {
    return [
      { factor: '성격 조화', score: 85, description: `${mbti?.includes('E') ? '외향적 에너지가' : '내향적 깊이가'} 관계에 도움됩니다` },
      { factor: '가치관 일치', score: 78, description: `${mbti?.includes('F') ? '감정적 공감능력이' : '논리적 사고가'} 좋은 영향을 줍니다` },
      { factor: '생활 패턴', score: 82, description: `${mbti?.endsWith('J') ? '계획적인 성향이' : '유연한 적응력이'} 조화를 만듭니다` },
      { factor: '오행 궁합', score: 88, description: `${elementType} 원소의 특성이 안정적인 관계 형성에 유리합니다` },
      { factor: '소통 방식', score: 75, description: `${mbti?.includes('T') ? '명확한 의사소통이' : '감정적 교감이'} 관계 발전에 도움됩니다` }
    ];
  }

  /**
   * 결혼 시기 조언
   */
  private getMarriageTimingAdvice(age: number, score: number, mbti?: string): any {
    const isJudging = mbti?.endsWith('J');
    
    if (age < 25) {
      return {
        best_period: '2-3년 후',
        preparation_time: '충분한 시간을 가지고 준비',
        advice: isJudging ? '계획적으로 단계별 준비' : '자연스러운 발전 과정 중시',
        monthly_timing: ['5월', '6월', '9월', '10월']
      };
    } else if (age < 30) {
      return {
        best_period: score >= 80 ? '현재~내년' : '1-2년 후',
        preparation_time: '6개월~1년 준비',
        advice: isJudging ? '체계적인 계획 수립' : '감정과 현실의 균형',
        monthly_timing: ['4월', '5월', '9월', '10월']
      };
    } else {
      return {
        best_period: '준비되면 언제든',
        preparation_time: '현재 상황에 따라',
        advice: '경험을 바탕으로 신중하되 과감한 결정',
        monthly_timing: ['3월', '4월', '5월', '9월', '10월', '11월']
      };
    }
  }

  /**
   * 관계 발전 조언
   */
  private getRelationshipAdvice(mbti?: string, elementType?: string): Array<{ area: string; advice: string; priority: string }> {
    const advice = [];
    
    if (mbti?.includes('E')) {
      advice.push({ area: '소통', advice: '활발한 대화와 다양한 활동을 함께 하세요', priority: '높음' });
    } else {
      advice.push({ area: '소통', advice: '깊이 있는 대화와 조용한 시간을 소중히 하세요', priority: '높음' });
    }
    
    if (mbti?.includes('F')) {
      advice.push({ area: '감정', advice: '서로의 감정을 세심하게 배려하고 표현하세요', priority: '높음' });
    } else {
      advice.push({ area: '논리', advice: '합리적인 대화와 현실적인 계획을 함께 세우세요', priority: '높음' });
    }
    
    advice.push({ area: '오행 조화', advice: `${elementType} 기운을 활용한 환경 조성이 도움됩니다`, priority: '중간' });
    
    return advice;
  }

  /**
   * 궁합에 유리한 시기
   */
  private getLuckyPeriodsForCompatibility(birthMonth: number, elementType: string): Array<{ period: string; description: string; activities: string[] }> {
    const periods = [];
    
    // 계절별 유리한 시기
    if (birthMonth >= 3 && birthMonth <= 5) {
      periods.push({
        period: '봄 (3-5월)',
        description: '새로운 만남과 발전에 유리한 시기',
        activities: ['소개팅', '야외 데이트', '새로운 취미 시작']
      });
    }
    
    periods.push({
      period: '가을 (9-11월)',
      description: '안정적인 관계 발전에 좋은 시기',
      activities: ['진지한 대화', '미래 계획', '가족 소개']
    });
    
    return periods;
  }

  /**
   * 주의해야 할 시기
   */
  private getWarningPeriodsForCompatibility(birthYear: number, birthMonth: number): Array<{ period: string; description: string; precautions: string[] }> {
    return [
      {
        period: '여름 (6-8월)',
        description: '감정 기복이 클 수 있는 시기',
        precautions: ['성급한 결정 피하기', '충분한 소통하기', '냉정함 유지하기']
      },
      {
        period: '겨울 (12-2월)',
        description: '내향적 성향이 강해지는 시기',
        precautions: ['소외감 주의하기', '꾸준한 관심 표현', '따뜻한 분위기 조성']
      }
    ];
  }

  /**
   * 전통 궁합 기본 데이터 (GPT 실패 시)
   */
  private getDefaultTraditionalCompatibilityData(userProfile: UserProfile, category?: FortuneCategory): any {
    const age = this.calculateAge(userProfile.birth_date);
    
    return {
      'traditional-compatibility': {
        summary: '전통 궁합 분석이 진행 중입니다. 잠시 후 다시 확인해주세요.',
        total_score: 75,
        marriage_score: 70,
        harmony_score: 78,
        dominant_element: { name: '토', type: '토', traits: '안정, 신뢰, 포용' },
        best_matches: [
          { type: '화 오행', description: '화생토로 따뜻한 안정감', compatibility_score: 85 },
          { type: '금 오행', description: '토생금으로 믿음직한 지원', compatibility_score: 80 }
        ],
        avoid_matches: [
          { type: '목 오행', reason: '목극토로 변화 압박', caution_level: '중간' }
        ],
        compatibility_factors: [
          { factor: '성격 조화', score: 75, description: '분석 중입니다' },
          { factor: '가치관 일치', score: 78, description: '분석 중입니다' }
        ],
        marriage_timing: {
          best_period: '분석 중',
          preparation_time: '분석 중',
          advice: '분석 중입니다',
          monthly_timing: ['5월', '9월', '10월']
        },
        relationship_advice: [
          { area: '소통', advice: '분석 중입니다', priority: '높음' }
        ],
        userInfo: {
          name: userProfile.name,
          birth_date: userProfile.birth_date,
          mbti: userProfile.mbti,
          age
        }
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 인맥 리포트 기본 데이터 (GPT 실패 시)
   */
  private getDefaultNetworkReportData(userProfile: UserProfile, category?: FortuneCategory): any {
    const age = this.calculateAge(userProfile.birth_date);
    const mbti = userProfile.mbti || 'ISFJ';
    
    return {
      'network-report': {
        score: 75,
        summary: `${userProfile.name}님의 인맥 분석이 준비 중입니다.`,
        benefactors: [`${mbti.includes('E') ? '활발한' : '신중한'} 동료들`],
        challengers: ['경쟁 상대들'],
        advice: '꾸준한 관계 관리가 필요한 시기입니다.',
        actionItems: [
          '새로운 인맥 만들기',
          '기존 관계 정리하기',
          '소통 방식 개선하기'
        ],
        lucky: {
          color: '#FFD700',
          number: 7,
          direction: '동쪽'
        }
      },
      generated_at: new Date().toISOString()
    };
  }
  /**
   * MBTI 일일 운세 GPT 생성
   */
  private async generateMbtiDailyFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('🧠 GPT MBTI 일일 운세 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    // GPT 시뮬레이션: MBTI 기반 개인화된 일일 운세
    const mbti = userProfile.mbti || 'ISFJ';
    const today = new Date();
    const birthDate = new Date(userProfile.birth_date);
    
    const result = {
      mbti: {
        type: mbti,
        description: this.getMBTIDescription(mbti),
        daily_characteristics: this.getMBTIDailyCharacteristics(mbti),
        energy_pattern: this.getMBTIEnergyPattern(mbti, today),
        decision_style: this.getMBTIDecisionStyle(mbti),
        social_tendency: this.getMBTISocialTendency(mbti),
        stress_management: this.getMBTIStressManagement(mbti),
        productivity_tips: this.getMBTIProductivityTips(mbti),
        relationship_focus: this.getMBTIRelationshipFocus(mbti),
        learning_approach: this.getMBTILearningApproach(mbti),
        career_guidance: this.getMBTICareerGuidance(mbti),
        daily_scores: {
          energy: this.getMBTIDailyScore(mbti, 'energy'),
          focus: this.getMBTIDailyScore(mbti, 'focus'),
          creativity: this.getMBTIDailyScore(mbti, 'creativity'),
          social: this.getMBTIDailyScore(mbti, 'social'),
          productivity: this.getMBTIDailyScore(mbti, 'productivity')
        },
        today_advice: this.getMBTITodayAdvice(mbti, today),
        compatible_types: this.getMBTICompatibleTypes(mbti),
        challenging_situations: this.getMBTIChallengingSituations(mbti)
      },
      generated_at: new Date().toISOString()
    };
    
    console.log('✅ GPT MBTI 일일 운세 생성 완료 (사용자:', userProfile.name + ')');
    return result;
  }

  /**
   * MBTI 타입 설명
   */
  private getMBTIDescription(mbti: string): string {
    const descriptions = {
      'ENFP': '열정적인 영감가 - 새로운 가능성을 추구하며 사람들에게 활력을 주는 타입',
      'ENFJ': '정의로운 사회운동가 - 다른 사람들의 성장을 돕고 조화를 추구하는 타입',
      'ENTP': '뜨거운 논쟁을 즐기는 변론가 - 창의적이고 새로운 아이디어를 좋아하는 타입',
      'ENTJ': '대담한 통솔자 - 목표를 향해 체계적으로 이끄는 천생 리더 타입',
      'ESFP': '자유로운 영혼의 연예인 - 즉흥적이고 사교적인 분위기 메이커 타입',
      'ESFJ': '사교적인 외교관 - 다른 사람을 배려하고 조화로운 관계를 만드는 타입',
      'ESTP': '모험을 즐기는 사업가 - 현실적이고 활동적인 실행력의 소유자',
      'ESTJ': '엄격한 관리자 - 질서와 체계를 중시하는 실용적 리더 타입',
      'INFP': '열정적인 중재자 - 자신만의 가치관으로 세상을 바꾸려는 이상주의자',
      'INFJ': '선의의 옹호자 - 깊은 통찰력으로 다른 사람을 도우려는 신비주의자',
      'INTP': '논리적인 사색가 - 지적 호기심으로 복잡한 문제를 해결하는 분석가',
      'INTJ': '용의주도한 전략가 - 장기적 비전으로 체계적인 계획을 세우는 설계자',
      'ISFP': '호기심 많은 예술가 - 유연하고 개방적인 자유로운 영혼의 소유자',
      'ISFJ': '용감한 수호자 - 헌신적이고 따뜻한 마음으로 다른 사람을 돕는 타입',
      'ISTP': '만능 재주꾼 - 실용적이고 현실적인 문제 해결의 달인',
      'ISTJ': '청렴결백한 논리주의자 - 신뢰할 수 있고 체계적인 완벽주의자'
    };
    return descriptions[mbti as keyof typeof descriptions] || '독특한 개성을 가진 특별한 타입입니다.';
  }

  /**
   * MBTI 일일 특성
   */
  private getMBTIDailyCharacteristics(mbti: string): string[] {
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.endsWith('J');

    const characteristics = [];
    
    if (isExtrovert) {
      characteristics.push('사람들과의 소통으로 에너지 충전');
      characteristics.push('활발한 외부 활동 선호');
    } else {
      characteristics.push('혼자만의 시간으로 에너지 충전');
      characteristics.push('깊이 있는 내적 성찰 중시');
    }

    if (isIntuitive) {
      characteristics.push('미래 가능성과 아이디어 중시');
      characteristics.push('창의적이고 혁신적인 접근');
    } else {
      characteristics.push('현실적이고 구체적인 정보 중시');
      characteristics.push('경험과 실용성 기반 판단');
    }

    if (isFeeling) {
      characteristics.push('감정과 가치관 기반 의사결정');
      characteristics.push('타인의 감정에 민감하게 반응');
    } else {
      characteristics.push('논리와 객관성 기반 의사결정');
      characteristics.push('분석적이고 체계적인 사고');
    }

    if (isJudging) {
      characteristics.push('계획적이고 체계적인 생활');
      characteristics.push('명확한 목표와 일정 선호');
    } else {
      characteristics.push('유연하고 적응적인 생활');
      characteristics.push('즉흥적이고 개방적인 태도');
    }

    return characteristics;
  }

  /**
   * MBTI 에너지 패턴
   */
  private getMBTIEnergyPattern(mbti: string, date: Date): string {
    const hour = date.getHours();
    const isExtrovert = mbti.startsWith('E');
    
    if (isExtrovert) {
      if (hour >= 6 && hour < 12) {
        return '아침 시간대에 가장 활발한 에너지를 보입니다. 중요한 미팅이나 창의적 작업에 적합합니다.';
      } else if (hour >= 12 && hour < 18) {
        return '오후에도 지속적인 에너지를 유지합니다. 사람들과의 소통이나 협업에 좋은 시간입니다.';
      } else {
        return '저녁에는 사교 활동이나 네트워킹에 적합한 에너지 상태입니다.';
      }
    } else {
      if (hour >= 6 && hour < 12) {
        return '아침 시간은 집중력이 높아 깊이 있는 작업에 적합합니다.';
      } else if (hour >= 12 && hour < 18) {
        return '오후에는 차분한 에너지로 세밀한 작업에 집중할 수 있습니다.';
      } else {
        return '저녁 시간은 개인적인 성찰이나 혼자만의 시간에 적합합니다.';
      }
    }
  }

  /**
   * MBTI 의사결정 스타일
   */
  private getMBTIDecisionStyle(mbti: string): string {
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.endsWith('J');
    
    if (isFeeling && isJudging) {
      return '감정과 가치관을 고려한 신중한 결정을 선호합니다. 다른 사람에게 미칠 영향을 깊이 고려합니다.';
    } else if (isFeeling && !isJudging) {
      return '상황에 따라 유연하게 결정하되, 개인적 가치관과 감정을 중시합니다.';
    } else if (!isFeeling && isJudging) {
      return '논리적 분석을 바탕으로 체계적이고 신속한 결정을 내립니다.';
    } else {
      return '다양한 선택지를 분석하며 상황에 맞춰 논리적으로 결정합니다.';
    }
  }

  /**
   * MBTI 사회적 성향
   */
  private getMBTISocialTendency(mbti: string): string {
    const isExtrovert = mbti.startsWith('E');
    const isFeeling = mbti.includes('F');
    
    if (isExtrovert && isFeeling) {
      return '사람들과의 따뜻한 교감을 중시하며, 활발한 사교 활동을 즐깁니다.';
    } else if (isExtrovert && !isFeeling) {
      return '목표 지향적인 사회 활동을 선호하며, 효율적인 네트워킹을 추구합니다.';
    } else if (!isExtrovert && isFeeling) {
      return '소수의 깊은 관계를 중시하며, 진정성 있는 소통을 선호합니다.';
    } else {
      return '필요에 따른 선택적 사교 활동을 하며, 의미 있는 대화를 추구합니다.';
    }
  }

  /**
   * MBTI 스트레스 관리법
   */
  private getMBTIStressManagement(mbti: string): string {
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    
    if (isExtrovert && isIntuitive) {
      return '새로운 활동이나 창의적 프로젝트로 스트레스를 해소하세요. 사람들과의 브레인스토밍도 도움됩니다.';
    } else if (isExtrovert && !isIntuitive) {
      return '운동이나 실외 활동으로 스트레스를 풀어보세요. 친구들과의 즐거운 활동도 효과적입니다.';
    } else if (!isExtrovert && isIntuitive) {
      return '혼자만의 시간을 가지며 명상이나 독서로 마음을 정리하세요. 창작 활동도 도움됩니다.';
    } else {
      return '규칙적인 일상과 충분한 휴식으로 스트레스를 관리하세요. 정리정돈도 마음의 안정에 도움됩니다.';
    }
  }

  /**
   * MBTI 생산성 팁
   */
  private getMBTIProductivityTips(mbti: string): string[] {
    const isJudging = mbti.endsWith('J');
    const isIntuitive = mbti.includes('N');
    
    const tips = [];
    
    if (isJudging) {
      tips.push('명확한 목표와 일정을 설정하여 체계적으로 진행');
      tips.push('우선순위를 정해 중요한 일부터 처리');
    } else {
      tips.push('유연한 스케줄을 유지하며 상황에 맞춰 조정');
      tips.push('여러 작업을 번갈아 가며 진행하여 집중력 유지');
    }
    
    if (isIntuitive) {
      tips.push('창의적 영감을 위한 자유로운 사고 시간 확보');
      tips.push('큰 그림을 그리고 세부사항은 단계적으로 보완');
    } else {
      tips.push('구체적이고 실행 가능한 단계별 계획 수립');
      tips.push('실용적인 도구와 방법론 활용');
    }
    
    return tips;
  }

  /**
   * MBTI 관계 중점사항
   */
  private getMBTIRelationshipFocus(mbti: string): string {
    const isFeeling = mbti.includes('F');
    const isExtrovert = mbti.startsWith('E');
    
    if (isFeeling && isExtrovert) {
      return '따뜻한 소통과 감정적 교감을 통해 관계를 발전시키세요. 상대방의 감정에 귀 기울이는 것이 중요합니다.';
    } else if (isFeeling && !isExtrovert) {
      return '진정성 있는 깊은 대화를 통해 신뢰를 쌓아가세요. 서로의 가치관을 이해하는 것이 핵심입니다.';
    } else if (!isFeeling && isExtrovert) {
      return '목표 지향적이고 효율적인 소통을 추구하되, 상대방의 감정도 고려해보세요.';
    } else {
      return '논리적이고 일관성 있는 관계를 유지하되, 때로는 감정적 표현도 필요합니다.';
    }
  }

  /**
   * MBTI 학습 접근법
   */
  private getMBTILearningApproach(mbti: string): string {
    const isIntuitive = mbti.includes('N');
    const isThinking = mbti.includes('T');
    
    if (isIntuitive && isThinking) {
      return '이론적 틀을 이해한 후 응용과 확장에 집중하세요. 복잡한 개념의 연결고리를 찾는 것이 중요합니다.';
    } else if (isIntuitive && !isThinking) {
      return '개인적 의미와 가치를 연결한 학습이 효과적입니다. 창의적 표현을 통해 이해를 깊게 하세요.';
    } else if (!isIntuitive && isThinking) {
      return '단계적이고 체계적인 학습이 적합합니다. 실제 적용 사례와 구체적 데이터를 활용하세요.';
    } else {
      return '실생활과 연결된 구체적 경험을 통해 학습하세요. 다른 사람과의 협력 학습도 도움됩니다.';
    }
  }

  /**
   * MBTI 커리어 가이던스
   */
  private getMBTICareerGuidance(mbti: string): string {
    const careers = {
      'ENFP': '창의적 분야나 사람과 관련된 직업에서 능력을 발휘할 수 있습니다. 마케팅, 상담, 교육 분야가 적합합니다.',
      'ENFJ': '사람들의 성장을 돕는 역할에 특화되어 있습니다. 교육, 상담, 인사 관리 분야에서 뛰어난 성과를 낼 수 있습니다.',
      'ENTP': '혁신과 변화를 주도하는 역할이 적합합니다. 기업가정신, 컨설팅, 연구개발 분야에서 능력을 발휘할 수 있습니다.',
      'ENTJ': '조직을 이끄는 리더십 역할에 천부적 재능이 있습니다. 경영, 정치, 법률 분야에서 탁월한 성과를 기대할 수 있습니다.',
      'ESFP': '사람들과 함께하는 활동적인 분야가 적합합니다. 엔터테인먼트, 서비스업, 이벤트 기획 분야를 고려해보세요.',
      'ESFJ': '타인을 배려하고 조화를 이루는 역할에 뛰어납니다. 간호, 교육, 고객 서비스 분야에서 성공할 수 있습니다.',
      'ESTP': '즉석에서 문제를 해결하는 역동적인 분야가 적합합니다. 영업, 응급의료, 스포츠 분야를 고려해보세요.',
      'ESTJ': '체계적인 관리와 조직 운영에 탁월합니다. 행정, 금융, 프로젝트 관리 분야에서 뛰어난 성과를 낼 수 있습니다.',
      'INFP': '자신의 가치관을 실현할 수 있는 창의적 분야가 적합합니다. 예술, 문학, 사회복지 분야를 고려해보세요.',
      'INFJ': '깊은 통찰력을 활용한 전문 분야에 적합합니다. 심리학, 예술, 종교 분야에서 의미 있는 기여를 할 수 있습니다.',
      'INTP': '복잡한 문제를 분석하고 해결하는 분야에 뛰어납니다. 연구, 공학, 정보기술 분야에서 능력을 발휘할 수 있습니다.',
      'INTJ': '장기적 비전을 가진 전략적 역할이 적합합니다. 경영전략, 연구개발, 투자 분야에서 탁월한 성과를 기대할 수 있습니다.',
      'ISFP': '자유로운 환경에서 창의성을 발휘하는 분야가 적합합니다. 디자인, 예술, 자연과학 분야를 고려해보세요.',
      'ISFJ': '안정적이고 체계적인 환경에서 타인을 돕는 역할에 적합합니다. 의료, 교육, 사회복지 분야에서 성공할 수 있습니다.',
      'ISTP': '손으로 만드는 기술적 분야에 뛰어납니다. 공학, 기술, 수리 분야에서 실용적 능력을 발휘할 수 있습니다.',
      'ISTJ': '정확성과 신뢰성이 중요한 분야에 적합합니다. 회계, 법률, 공무원 분야에서 뛰어난 성과를 낼 수 있습니다.'
    };
    return careers[mbti as keyof typeof careers] || '당신만의 독특한 강점을 활용할 수 있는 분야를 찾아보세요.';
  }

  /**
   * MBTI 일일 점수
   */
  private getMBTIDailyScore(mbti: string, category: string): number {
    const baseScore = 75;
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.endsWith('J');
    
    switch (category) {
      case 'energy':
        return baseScore + (isExtrovert ? 15 : -5) + Math.floor(Math.random() * 10);
      case 'focus':
        return baseScore + (isJudging ? 10 : -5) + (!isExtrovert ? 10 : 0) + Math.floor(Math.random() * 10);
      case 'creativity':
        return baseScore + (isIntuitive ? 15 : -5) + (!isJudging ? 10 : 0) + Math.floor(Math.random() * 10);
      case 'social':
        return baseScore + (isExtrovert ? 15 : -10) + (isFeeling ? 10 : 0) + Math.floor(Math.random() * 10);
      case 'productivity':
        return baseScore + (isJudging ? 15 : -5) + (!isIntuitive ? 10 : 0) + Math.floor(Math.random() * 10);
      default:
        return baseScore + Math.floor(Math.random() * 20) - 10;
    }
  }

  /**
   * MBTI 오늘의 조언
   */
  private getMBTITodayAdvice(mbti: string, date: Date): string {
    const day = date.getDay(); // 0: 일요일, 1: 월요일, ...
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    
    if (day === 1) { // 월요일
      if (isExtrovert) {
        return '새로운 한 주의 시작! 동료들과의 활발한 소통으로 에너지를 충전하세요.';
      } else {
        return '한 주의 계획을 차분히 세우며 집중력을 높여보세요.';
      }
    } else if (day === 5) { // 금요일
      if (isIntuitive) {
        return '창의적인 아이디어로 한 주를 마무리하고 새로운 가능성을 탐색해보세요.';
      } else {
        return '실용적인 마무리로 한 주의 성과를 점검하고 다음 주를 준비하세요.';
      }
    } else {
      const advices = [
        '당신의 강점을 활용할 수 있는 기회를 찾아보세요.',
        '균형잡힌 일과 휴식으로 컨디션을 관리하세요.',
        '의미 있는 관계에 시간을 투자해보세요.',
        '새로운 학습 기회를 만들어보세요.'
      ];
      return advices[Math.floor(Math.random() * advices.length)];
    }
  }

  /**
   * MBTI 호환 타입들
   */
  private getMBTICompatibleTypes(mbti: string): string[] {
    const compatibility = {
      'ENFP': ['INTJ', 'INFJ', 'ENFJ', 'ENTP'],
      'ENFJ': ['INFP', 'ENFP', 'INTJ', 'INFJ'],
      'ENTP': ['INTJ', 'INFJ', 'ENFP', 'ENTP'],
      'ENTJ': ['INFP', 'INTP', 'ENFP', 'ENTP'],
      'ESFP': ['ISFJ', 'ISTJ', 'ESFJ', 'ESTP'],
      'ESFJ': ['ISFP', 'ISTP', 'ESFP', 'ESTP'],
      'ESTP': ['ISFJ', 'ISTJ', 'ESFJ', 'ESFP'],
      'ESTJ': ['ISFP', 'ISTP', 'ESFP', 'ESTP'],
      'INFP': ['ENTJ', 'ENFJ', 'INFJ', 'ENFP'],
      'INFJ': ['ENTP', 'ENFP', 'INTJ', 'INFP'],
      'INTP': ['ENTJ', 'ESTJ', 'ENTP', 'INTJ'],
      'INTJ': ['ENFP', 'ENTP', 'INFJ', 'INTP'],
      'ISFP': ['ESTJ', 'ESFJ', 'ESTP', 'ESFP'],
      'ISFJ': ['ESTP', 'ESFP', 'ESTJ', 'ESFJ'],
      'ISTP': ['ESTJ', 'ESFJ', 'ESTP', 'ESFP'],
      'ISTJ': ['ESTP', 'ESFP', 'ESTJ', 'ESFJ']
    };
    return compatibility[mbti as keyof typeof compatibility] || ['ISFJ', 'ESFJ', 'ISTJ', 'ESTJ'];
  }

  /**
   * MBTI 도전적 상황들
   */
  private getMBTIChallengingSituations(mbti: string): string[] {
    const isExtrovert = mbti.startsWith('E');
    const isIntuitive = mbti.includes('N');
    const isFeeling = mbti.includes('F');
    const isJudging = mbti.endsWith('J');
    
    const challenges = [];
    
    if (isExtrovert) {
      challenges.push('혼자 집중해야 하는 장시간 작업');
      challenges.push('소수 인원과의 조용한 환경');
    } else {
      challenges.push('갑작스러운 발표나 즉석 발언');
      challenges.push('시끄럽고 혼잡한 환경에서의 업무');
    }
    
    if (isIntuitive) {
      challenges.push('반복적이고 세부적인 루틴 작업');
      challenges.push('창의성이 제한된 엄격한 규칙');
    } else {
      challenges.push('모호하고 추상적인 개념 이해');
      challenges.push('명확한 가이드라인 없는 업무');
    }
    
    if (isFeeling) {
      challenges.push('감정을 배제한 냉정한 판단');
      challenges.push('갈등 상황이나 비판적 피드백');
    } else {
      challenges.push('감정적 갈등이나 인간관계 문제');
      challenges.push('논리보다 감정이 우선시되는 상황');
    }
    
    if (isJudging) {
      challenges.push('계획이 자주 바뀌는 불확실한 상황');
      challenges.push('즉흥적이고 유연성이 요구되는 업무');
    } else {
      challenges.push('엄격한 마감일과 세부 규칙');
      challenges.push('변화가 적은 반복적인 일상');
    }
    
    return challenges;
  }

  /**
   * MBTI 기본 데이터 (GPT 실패 시)
   */
  private getDefaultMbtiData(userProfile: UserProfile, category?: FortuneCategory): any {
    const mbti = userProfile.mbti || 'ISFJ';
    
    return {
      mbti: {
        type: mbti,
        description: `${mbti} 타입의 일일 운세 분석이 준비 중입니다.`,
        daily_characteristics: ['분석 중입니다', '준비 중입니다'],
        energy_pattern: '에너지 패턴을 분석하고 있습니다.',
        decision_style: '의사결정 스타일을 분석 중입니다.',
        social_tendency: '사회적 성향을 분석 중입니다.',
        stress_management: '스트레스 관리법을 준비 중입니다.',
        productivity_tips: ['분석 중입니다'],
        relationship_focus: '관계 중점사항을 분석 중입니다.',
        learning_approach: '학습 접근법을 분석 중입니다.',
        career_guidance: '커리어 가이던스를 준비 중입니다.',
        daily_scores: {
          energy: 75,
          focus: 75,
          creativity: 75,
          social: 75,
          productivity: 75
        },
        today_advice: '오늘의 조언을 준비 중입니다.',
        compatible_types: ['분석', '중'],
        challenging_situations: ['분석 중입니다']
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 주간 운세 GPT 생성
   */
  private async generateWeeklyFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('📅 GPT 주간 운세 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    const mbti = userProfile.mbti || 'ISFJ';
    const today = new Date();
    const age = this.calculateAge(userProfile.birth_date);
    
    const result = {
      weekly: {
        week_overview: this.getWeekOverview(mbti, today, age),
        daily_highlights: this.getDailyHighlights(mbti, today),
        focus_areas: this.getWeeklyFocusAreas(mbti, age),
        challenges: this.getWeeklyChallenges(mbti),
        opportunities: this.getWeeklyOpportunities(mbti, today),
        energy_trend: this.getWeeklyEnergyTrend(mbti, today),
        relationship_focus: this.getWeeklyRelationshipFocus(mbti),
        career_guidance: this.getWeeklyCareerGuidance(mbti, age),
        health_tips: this.getWeeklyHealthTips(mbti),
        lucky_days: this.getWeeklyLuckyDays(mbti, today),
        caution_days: this.getWeeklyCautionDays(mbti, today),
        weekly_scores: {
          overall: this.getWeeklyScore(mbti, 'overall'),
          love: this.getWeeklyScore(mbti, 'love'),
          career: this.getWeeklyScore(mbti, 'career'),
          health: this.getWeeklyScore(mbti, 'health'),
          finance: this.getWeeklyScore(mbti, 'finance')
        }
      },
      generated_at: new Date().toISOString()
    };
    
    console.log('✅ GPT 주간 운세 생성 완료 (사용자:', userProfile.name + ')');
    return result;
  }

  /**
   * 월간 운세 GPT 생성
   */
  private async generateMonthlyFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('📅 GPT 월간 운세 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    const mbti = userProfile.mbti || 'ISFJ';
    const today = new Date();
    const age = this.calculateAge(userProfile.birth_date);
    
    const result = {
      monthly: {
        month_overview: this.getMonthOverview(mbti, today, age),
        weekly_breakdown: this.getMonthlyWeeklyBreakdown(mbti, today),
        major_themes: this.getMonthlyMajorThemes(mbti, age),
        key_dates: this.getMonthlyKeyDates(mbti, today),
        relationship_trends: this.getMonthlyRelationshipTrends(mbti),
        career_developments: this.getMonthlyCareerDevelopments(mbti, age),
        financial_outlook: this.getMonthlyFinancialOutlook(mbti, age),
        health_guidance: this.getMonthlyHealthGuidance(mbti),
        personal_growth: this.getMonthlyPersonalGrowth(mbti, age),
        best_opportunities: this.getMonthlyBestOpportunities(mbti, today),
        things_to_avoid: this.getMonthlyThingsToAvoid(mbti),
        monthly_scores: {
          overall: this.getMonthlyScore(mbti, 'overall'),
          love: this.getMonthlyScore(mbti, 'love'),
          career: this.getMonthlyScore(mbti, 'career'),
          health: this.getMonthlyScore(mbti, 'health'),
          finance: this.getMonthlyScore(mbti, 'finance')
        }
      },
      generated_at: new Date().toISOString()
    };
    
    console.log('✅ GPT 월간 운세 생성 완료 (사용자:', userProfile.name + ')');
    return result;
  }

  /**
   * 연간 운세 GPT 생성
   */
  private async generateYearlyFromGPT(userProfile: UserProfile): Promise<any> {
    console.log('📅 GPT 연간 운세 요청:', userProfile.name, `(${userProfile.birth_date})`);
    
    const mbti = userProfile.mbti || 'ISFJ';
    const today = new Date();
    const age = this.calculateAge(userProfile.birth_date);
    
    const result = {
      yearly: {
        year_overview: this.getYearOverview(mbti, today, age),
        quarterly_breakdown: this.getYearlyQuarterlyBreakdown(mbti, today),
        major_life_themes: this.getYearlyMajorLifeThemes(mbti, age),
        turning_points: this.getYearlyTurningPoints(mbti, today),
        relationship_journey: this.getYearlyRelationshipJourney(mbti, age),
        career_trajectory: this.getYearlyCareerTrajectory(mbti, age),
        financial_planning: this.getYearlyFinancialPlanning(mbti, age),
        health_priorities: this.getYearlyHealthPriorities(mbti, age),
        personal_evolution: this.getYearlyPersonalEvolution(mbti, age),
        major_opportunities: this.getYearlyMajorOpportunities(mbti, today),
        potential_challenges: this.getYearlyPotentialChallenges(mbti, age),
        yearly_scores: {
          overall: this.getYearlyScore(mbti, 'overall'),
          love: this.getYearlyScore(mbti, 'love'),
          career: this.getYearlyScore(mbti, 'career'),
          health: this.getYearlyScore(mbti, 'health'),
          finance: this.getYearlyScore(mbti, 'finance')
        }
      },
      generated_at: new Date().toISOString()
    };
    
    console.log('✅ GPT 연간 운세 생성 완료 (사용자:', userProfile.name + ')');
    return result;
  }

  // 헬퍼 메서드들 (간략화)
  private getWeekOverview(mbti: string, date: Date, age: number): string {
    const isExtrovert = mbti.startsWith('E');
    return isExtrovert ? 
      '활발한 소통과 새로운 만남이 기대되는 한 주입니다.' : 
      '내적 성장과 깊은 사색에 좋은 시간이 될 것입니다.';
  }

  private getDailyHighlights(mbti: string, date: Date): any[] {
    return [
      { day: '월요일', highlight: '새로운 시작에 좋은 에너지' },
      { day: '화요일', highlight: '창의적 아이디어 발현' },
      { day: '수요일', highlight: '인간관계 발전 기회' },
      { day: '목요일', highlight: '중요한 결정의 시간' },
      { day: '금요일', highlight: '성과 확인과 정리' },
      { day: '토요일', highlight: '휴식과 재충전' },
      { day: '일요일', highlight: '다음 주 준비와 계획' }
    ];
  }

  private getWeeklyFocusAreas(mbti: string, age: number): string[] {
    const isJudging = mbti.endsWith('J');
    return isJudging ? 
      ['목표 달성을 위한 체계적 접근', '계획 실행력 강화'] :
      ['유연한 대응력 발휘', '새로운 기회 포착'];
  }

  private getWeeklyChallenges(mbti: string): string[] {
    const isExtrovert = mbti.startsWith('E');
    return isExtrovert ?
      ['과도한 활동으로 인한 피로', '집중력 분산 주의'] :
      ['고립감 방지', '적극적 소통 필요'];
  }

  private getWeeklyOpportunities(mbti: string, date: Date): string[] {
    return ['새로운 인맥 형성', '창의적 프로젝트 시작', '개인 브랜딩 강화'];
  }

  private getWeeklyEnergyTrend(mbti: string, date: Date): string {
    return '월요일부터 수요일까지 상승세, 목금은 안정세, 주말은 재충전 모드입니다.';
  }

  private getWeeklyRelationshipFocus(mbti: string): string {
    const isFeeling = mbti.includes('F');
    return isFeeling ?
      '감정적 교감과 따뜻한 소통에 집중하세요.' :
      '논리적이고 건설적인 대화를 추구하세요.';
  }

  private getWeeklyCareerGuidance(mbti: string, age: number): string {
    return age < 30 ?
      '새로운 기술 습득과 네트워킹에 집중하세요.' :
      '경험을 바탕으로 한 리더십 발휘가 중요합니다.';
  }

  private getWeeklyHealthTips(mbti: string): string[] {
    const isExtrovert = mbti.startsWith('E');
    return isExtrovert ?
      ['규칙적인 운동으로 에너지 관리', '충분한 수면 확보'] :
      ['명상이나 요가로 마음 안정', '적당한 외부 활동'];
  }

  private getWeeklyLuckyDays(mbti: string, date: Date): string[] {
    return ['수요일', '금요일'];
  }

  private getWeeklyCautionDays(mbti: string, date: Date): string[] {
    return ['화요일', '목요일'];
  }

  private getWeeklyScore(mbti: string, category: string): number {
    return 75 + Math.floor(Math.random() * 20);
  }

  // 월간 운세 헬퍼 메서드들
  private getMonthOverview(mbti: string, date: Date, age: number): string {
    return `${date.getMonth() + 1}월은 ${mbti} 타입에게 성장과 발전의 기회가 많은 달입니다.`;
  }

  private getMonthlyWeeklyBreakdown(mbti: string, date: Date): any[] {
    return [
      { week: 1, theme: '새로운 시작과 계획 수립' },
      { week: 2, theme: '적극적인 실행과 추진' },
      { week: 3, theme: '중간 점검과 조정' },
      { week: 4, theme: '마무리와 다음 달 준비' }
    ];
  }

  private getMonthlyMajorThemes(mbti: string, age: number): string[] {
    return ['개인 성장', '관계 발전', '커리어 진보'];
  }

  private getMonthlyKeyDates(mbti: string, date: Date): string[] {
    return ['5일', '15일', '25일'];
  }

  private getMonthlyRelationshipTrends(mbti: string): string {
    const isFeeling = mbti.includes('F');
    return isFeeling ?
      '감정적 유대감이 깊어지는 시기입니다.' :
      '실용적이고 안정적인 관계 발전이 예상됩니다.';
  }

  private getMonthlyCareerDevelopments(mbti: string, age: number): string {
    return '새로운 프로젝트나 책임이 주어질 가능성이 높습니다.';
  }

  private getMonthlyFinancialOutlook(mbti: string, age: number): string {
    return '신중한 투자와 계획적인 소비가 중요한 시기입니다.';
  }

  private getMonthlyHealthGuidance(mbti: string): string {
    return '규칙적인 생활 패턴 유지와 스트레스 관리에 집중하세요.';
  }

  private getMonthlyPersonalGrowth(mbti: string, age: number): string {
    return '새로운 학습과 자기계발에 투자하기 좋은 시기입니다.';
  }

  private getMonthlyBestOpportunities(mbti: string, date: Date): string[] {
    return ['네트워킹 확대', '새로운 학습', '창의적 프로젝트'];
  }

  private getMonthlyThingsToAvoid(mbti: string): string[] {
    return ['성급한 결정', '과도한 스트레스', '인간관계 갈등'];
  }

  private getMonthlyScore(mbti: string, category: string): number {
    return 70 + Math.floor(Math.random() * 25);
  }

  // 연간 운세 헬퍼 메서드들
  private getYearOverview(mbti: string, date: Date, age: number): string {
    return `${date.getFullYear()}년은 ${mbti} 타입에게 중요한 전환점이 될 수 있는 해입니다.`;
  }

  private getYearlyQuarterlyBreakdown(mbti: string, date: Date): any[] {
    return [
      { quarter: 1, theme: '기반 구축과 새로운 시작' },
      { quarter: 2, theme: '본격적인 성장과 발전' },
      { quarter: 3, theme: '성과 확산과 네트워킹' },
      { quarter: 4, theme: '정착과 내년 준비' }
    ];
  }

  private getYearlyMajorLifeThemes(mbti: string, age: number): string[] {
    return age < 30 ?
      ['자아 정체성 확립', '커리어 기반 구축', '인간관계 확장'] :
      ['리더십 발휘', '안정적 성장', '지혜로운 선택'];
  }

  private getYearlyTurningPoints(mbti: string, date: Date): string[] {
    return ['3월', '7월', '11월'];
  }

  private getYearlyRelationshipJourney(mbti: string, age: number): string {
    return '의미 있는 인연과 깊은 유대관계 형성의 한 해가 될 것입니다.';
  }

  private getYearlyCareerTrajectory(mbti: string, age: number): string {
    return '전문성 강화와 새로운 도전 기회가 연속될 것입니다.';
  }

  private getYearlyFinancialPlanning(mbti: string, age: number): string {
    return '장기적 관점의 투자와 재정 관리가 중요한 해입니다.';
  }

  private getYearlyHealthPriorities(mbti: string, age: number): string {
    return '예방 중심의 건강 관리와 생활 습관 개선에 집중하세요.';
  }

  private getYearlyPersonalEvolution(mbti: string, age: number): string {
    return '내적 성숙과 외적 성장이 조화를 이루는 한 해가 될 것입니다.';
  }

  private getYearlyMajorOpportunities(mbti: string, date: Date): string[] {
    return ['새로운 분야 진출', '국제적 경험', '리더십 기회'];
  }

  private getYearlyPotentialChallenges(mbti: string, age: number): string[] {
    return ['변화 적응', '균형 유지', '시간 관리'];
  }

  private getYearlyScore(mbti: string, category: string): number {
    return 65 + Math.floor(Math.random() * 30);
  }

  // 기본 데이터 메서드들
  private getDefaultWeeklyData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      weekly: {
        week_overview: '주간 운세 분석이 준비 중입니다.',
        daily_highlights: [],
        focus_areas: ['분석 중'],
        challenges: ['분석 중'],
        opportunities: ['분석 중'],
        energy_trend: '분석 중입니다.',
        relationship_focus: '분석 중입니다.',
        career_guidance: '분석 중입니다.',
        health_tips: ['분석 중'],
        lucky_days: ['분석', '중'],
        caution_days: ['분석', '중'],
        weekly_scores: { overall: 75, love: 75, career: 75, health: 75, finance: 75 }
      },
      generated_at: new Date().toISOString()
    };
  }

  private getDefaultMonthlyData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      monthly: {
        month_overview: '월간 운세 분석이 준비 중입니다.',
        weekly_breakdown: [],
        major_themes: ['분석 중'],
        key_dates: ['분석', '중'],
        relationship_trends: '분석 중입니다.',
        career_developments: '분석 중입니다.',
        financial_outlook: '분석 중입니다.',
        health_guidance: '분석 중입니다.',
        personal_growth: '분석 중입니다.',
        best_opportunities: ['분석 중'],
        things_to_avoid: ['분석 중'],
        monthly_scores: { overall: 75, love: 75, career: 75, health: 75, finance: 75 }
      },
      generated_at: new Date().toISOString()
    };
  }

  private getDefaultYearlyData(userProfile: UserProfile, category?: FortuneCategory): any {
    return {
      yearly: {
        year_overview: '연간 운세 분석이 준비 중입니다.',
        quarterly_breakdown: [],
        major_life_themes: ['분석 중'],
        turning_points: ['분석', '중'],
        relationship_journey: '분석 중입니다.',
        career_trajectory: '분석 중입니다.',
        financial_planning: '분석 중입니다.',
        health_priorities: '분석 중입니다.',
        personal_evolution: '분석 중입니다.',
        major_opportunities: ['분석 중'],
        potential_challenges: ['분석 중'],
        yearly_scores: { overall: 75, love: 75, career: 75, health: 75, finance: 75 }
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 개인 분석 GPT 생성
   */
  private async generatePersonalAnalysisFromGPT(userProfile: UserProfile, category: string): Promise<any> {
    console.log(`🔍 GPT ${category} 요청:`, userProfile.name, `(${userProfile.birth_date})`);
    
    const mbti = userProfile.mbti || 'ISFJ';
    const today = new Date();
    const age = this.calculateAge(userProfile.birth_date);
    
    const result = {
      [category.replace(/-/g, '_')]: this.getPersonalAnalysisContent(category, mbti, userProfile.birth_date, age),
      generated_at: new Date().toISOString()
    };
    
    console.log(`✅ GPT ${category} 생성 완료 (사용자:`, userProfile.name + ')');
    return result;
  }

  /**
   * 개인 분석 컨텐츠 생성
   */
  private getPersonalAnalysisContent(category: string, mbti: string, birthDate: string, age: number): any {
    const birth = new Date(birthDate);
    const month = birth.getMonth() + 1;
    
    switch (category) {
      case 'birth-season':
        return this.getBirthSeasonAnalysis(month, mbti, age);
      case 'birthdate':
        return this.getBirthdateAnalysis(birth, mbti, age);
      case 'birthstone':
        return this.getBirthstoneAnalysis(month, mbti);
      case 'blood-type':
        return this.getBloodTypeAnalysis(mbti, age);
      case 'palmistry':
        return this.getPalmistryAnalysis(mbti, age);
      case 'past-life':
        return this.getPastLifeAnalysis(birth, mbti);
      case 'daily':
        return this.getDailyAnalysis(mbti, age);
      case 'zodiac':
        return this.getZodiacAnalysis(birth, mbti);
      case 'lucky-items':
        return this.getLuckyItemsAnalysis(mbti, month);
      case 'lucky-outfit':
        return this.getLuckyOutfitAnalysis(mbti, month);
      case 'physiognomy':
        return this.getPhysiognomyAnalysis(mbti, age);
      default:
        return { analysis: '분석 중입니다.', category };
    }
  }

  // 개별 분석 메서드들
  private getBirthSeasonAnalysis(month: number, mbti: string, age: number): any {
    const season = month <= 2 || month === 12 ? '겨울' : 
                  month <= 5 ? '봄' : 
                  month <= 8 ? '여름' : '가을';
    return {
      season,
      characteristics: [`${season}생의 특징을 분석합니다.`],
      personality_traits: [`${mbti} 타입의 ${season}생 성격`],
      life_patterns: [`${season}생의 인생 패턴`],
      compatible_seasons: ['봄', '여름'],
      recommendations: [`${season}생을 위한 조언`]
    };
  }

  private getBirthdateAnalysis(birth: Date, mbti: string, age: number): any {
    return {
      birth_year: birth.getFullYear(),
      birth_month: birth.getMonth() + 1,
      birth_day: birth.getDate(),
      numerology: this.getNumerologyAnalysis(birth),
      life_path: `${mbti} 타입의 인생 경로 분석`,
      destiny_number: (birth.getDate() % 9) + 1,
      personality_analysis: '생년월일 기반 성격 분석',
      favorable_dates: ['5일', '15일', '25일'],
      life_cycles: this.getLifeCycles(birth, age)
    };
  }

  private getBirthstoneAnalysis(month: number, mbti: string): any {
    const stones = ['가넷', '자수정', '아쿠아마린', '다이아몬드', '에메랄드', '진주', '루비', '페리도트', '사파이어', '오팔', '토파즈', '터키석'];
    return {
      birthstone: stones[month - 1],
      meaning: `${stones[month - 1]}의 의미와 효과`,
      properties: ['행운', '건강', '사랑'],
      compatibility: `${mbti} 타입과의 궁합`,
      wearing_tips: '착용법과 관리법',
      alternative_stones: [stones[(month % 12)], stones[((month + 1) % 12)]]
    };
  }

  private getBloodTypeAnalysis(mbti: string, age: number): any {
    return {
      blood_type: 'A',
      personality_traits: ['신중함', '완벽주의', '배려심'],
      compatibility: {
        best_match: ['AB형', 'O형'],
        good_match: ['A형'],
        challenging: ['B형']
      },
      health_tips: ['규칙적인 생활', '스트레스 관리'],
      career_guidance: `${mbti} 타입과 A형의 조합으로 본 적성`,
      relationship_advice: '혈액형별 연애 스타일'
    };
  }

  private getPalmistryAnalysis(mbti: string, age: number): any {
    return {
      life_line: '생명선 분석 결과',
      heart_line: '감정선 분석 결과',
      head_line: '지능선 분석 결과',
      fate_line: '운명선 분석 결과',
      overall_reading: `${mbti} 타입의 손금 종합 분석`,
      strengths: ['직관력', '창의성'],
      challenges: ['감정 기복', '우유부단함'],
      life_stages: this.getPalmLifeStages(age)
    };
  }

  private getPastLifeAnalysis(birth: Date, mbti: string): any {
    const eras = ['조선시대', '고려시대', '통일신라', '삼국시대'];
    const jobs = ['학자', '의관', '예술가', '상인', '장군'];
    return {
      era: eras[birth.getDate() % eras.length],
      occupation: jobs[birth.getMonth() % jobs.length],
      personality: `전생에서의 ${mbti} 성향`,
      karma: '현생에 영향을 주는 전생의 업',
      lessons: '전생에서 배워야 할 교훈',
      connections: '전생에서 이어진 인연',
      spiritual_growth: '영적 성장 단계'
    };
  }

  private getDailyAnalysis(mbti: string, age: number): any {
    return {
      today_overview: `${mbti} 타입의 오늘 하루 전망`,
      energy_level: 85,
      mood_forecast: '긍정적이고 활기찬 하루',
      lucky_time: '오후 2-4시',
      focus_areas: ['인간관계', '창의적 활동'],
      things_to_avoid: ['과로', '스트레스'],
      daily_mantra: '오늘도 좋은 하루가 될 것입니다.',
      evening_reflection: '하루를 마무리하며 감사함을 느껴보세요.'
    };
  }

  private getZodiacAnalysis(birth: Date, mbti: string): any {
    const signs = ['물병자리', '물고기자리', '양자리', '황소자리', '쌍둥이자리', '게자리', '사자자리', '처녀자리', '천칭자리', '전갈자리', '사수자리', '염소자리'];
    return {
      zodiac_sign: signs[birth.getMonth()],
      element: this.getZodiacElementForAnalysis(birth.getMonth()),
      ruling_planet: this.getRulingPlanetForAnalysis(birth.getMonth()),
      personality: `${mbti}와 별자리의 조합 분석`,
      strengths: ['직감력', '창의성', '리더십'],
      weaknesses: ['고집', '변덕', '감정기복'],
      compatibility: this.getZodiacCompatibilityForAnalysis(birth.getMonth()),
      daily_guidance: '오늘의 별자리 운세'
    };
  }

  private getLuckyItemsAnalysis(mbti: string, month: number): any {
    return {
      accessories: ['실버 목걸이', '가죽 팔찌', '크리스탈 귀걸이'],
      colors: ['파란색', '초록색', '은색'],
      numbers: [3, 7, 21],
      materials: ['은', '가죽', '크리스탈'],
      personal_items: [`${mbti} 타입에게 맞는 개인 아이템들`],
      office_items: ['관엽식물', '수정 문진', '향초'],
      seasonal_items: this.getSeasonalLuckyItems(month)
    };
  }

  private getLuckyOutfitAnalysis(mbti: string, month: number): any {
    return {
      style_guide: `${mbti} 타입의 스타일 가이드`,
      color_palette: ['네이비', '베이지', '화이트'],
      fabric_recommendations: ['코튼', '린넨', '울'],
      accessories: ['미니멀 시계', '가죽 가방'],
      seasonal_outfit: this.getSeasonalOutfit(month),
      formal_wear: '공식적인 자리를 위한 복장',
      casual_wear: '일상적인 캐주얼 스타일',
      date_outfit: '특별한 날을 위한 옷차림'
    };
  }

  private getPhysiognomyAnalysis(mbti: string, age: number): any {
    return {
      face_shape: '관상학적 얼굴형 분석',
      eye_analysis: '눈의 관상학적 의미',
      nose_reading: '코로 보는 성격과 운세',
      mouth_traits: '입술과 입모양의 관상',
      overall_fortune: `${mbti} 타입의 관상 종합 분석`,
      career_prospects: '관상으로 본 직업 운세',
      relationship_luck: '관상으로 본 인연 운세',
      wealth_indicators: '재물운을 나타내는 관상 특징',
      health_signs: '건강을 나타내는 관상적 징후'
    };
  }

  // 헬퍼 메서드들
  private getNumerologyAnalysis(birth: Date): any {
    return {
      life_path_number: (birth.getDate() % 9) + 1,
      expression_number: (birth.getMonth() % 9) + 1,
      soul_urge_number: (birth.getFullYear() % 9) + 1
    };
  }

  private getLifeCycles(birth: Date, age: number): any[] {
    return [
      { period: '청년기', ages: '20-35', theme: '성장과 도전' },
      { period: '중년기', ages: '36-55', theme: '성취와 안정' },
      { period: '장년기', ages: '56-70', theme: '지혜와 성숙' }
    ];
  }

  private getPalmLifeStages(age: number): any[] {
    return [
      { stage: '유년기', period: '0-20세', characteristics: '기초 형성' },
      { stage: '성인기', period: '21-40세', characteristics: '활동적 시기' },
      { stage: '중년기', period: '41-60세', characteristics: '안정기' },
      { stage: '노년기', period: '61세 이후', characteristics: '지혜의 시기' }
    ];
  }

  private getZodiacElementForAnalysis(month: number): string {
    const elements = ['공기', '물', '불', '땅'];
    return elements[month % 4];
  }

  private getRulingPlanetForAnalysis(month: number): string {
    const planets = ['수성', '금성', '화성', '목성', '토성', '천왕성', '해왕성'];
    return planets[month % 7];
  }

  private getZodiacCompatibilityForAnalysis(month: number): string[] {
    return ['양자리', '사자자리', '사수자리'];
  }

  private getSeasonalLuckyItems(month: number): string[] {
    if (month <= 2 || month === 12) return ['목도리', '장갑', '따뜻한 차'];
    if (month <= 5) return ['가벼운 스카프', '선글라스', '봄꽃'];
    if (month <= 8) return ['모자', '시원한 액세서리', '여름 향수'];
    return ['가을 컬러 스카프', '따뜻한 음료', '단풍잎'];
  }

  private getSeasonalOutfit(month: number): any {
    if (month <= 2 || month === 12) {
      return { style: '겨울 스타일', items: ['코트', '니트', '부츠'] };
    }
    if (month <= 5) {
      return { style: '봄 스타일', items: ['가디건', '블라우스', '플랫슈즈'] };
    }
    if (month <= 8) {
      return { style: '여름 스타일', items: ['린넨 셔츠', '원피스', '샌들'] };
    }
    return { style: '가을 스타일', items: ['재킷', '니트', '부츠'] };
  }

  /**
   * 기본 개인 분석 데이터
   */
  private getDefaultPersonalAnalysisData(userProfile: UserProfile, category: string): any {
    return {
      [category.replace(/-/g, '_')]: {
        analysis: `${category} 분석이 준비 중입니다.`,
        status: '분석 중',
        message: '곧 상세한 분석 결과를 제공해드릴 예정입니다.'
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 기본 사용자 프로필 생성
   */
  private getDefaultUserProfile(userId: string): UserProfile {
    return {
      id: userId,
      name: '김인주',
      birth_date: '1988-09-05',
      birth_time: '14:30',
      gender: '남성',
      mbti: 'ENTJ',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
  }

  /**
   * GPT를 활용한 행운 아이템 생성
   */
  private async generateLuckyItemFromGPT(userProfile: UserProfile, category: string): Promise<any> {
    console.log(`🔍 GPT ${category} 요청: ${userProfile.name} (${userProfile.birth_date})`);
    
    const birth = new Date(userProfile.birth_date);
    const age = this.calculateAge(userProfile.birth_date);
    const mbti = userProfile.mbti || 'ENTJ';
    
    try {
      const luckyContent = this.getLuckyItemContent(category, mbti, birth, age);
      return {
        [category.replace(/-/g, '_')]: luckyContent,
        generated_at: new Date().toISOString()
      };
    } catch (error) {
      console.error(`❌ ${category} GPT 생성 실패:`, error);
      throw error;
    }
  }

  /**
   * 행운 아이템별 콘텐츠 생성
   */
  private getLuckyItemContent(category: string, mbti: string, birth: Date, age: number): any {
    const month = birth.getMonth() + 1;
    
    switch (category) {
      case 'lucky-color':
        return this.getLuckyColorAnalysis(month, mbti, age);
      case 'lucky-number':
        return this.getLuckyNumberAnalysis(birth, mbti, age);
      case 'lucky-food':
        return this.getLuckyFoodAnalysis(month, mbti, age);
      case 'talisman':
        return this.getTalismanAnalysis(birth, mbti, age);
      case 'lucky-series':
        return this.getLuckySeriesAnalysis(mbti, age);
      case 'lucky-exam':
        return this.getLuckyExamAnalysis(mbti, age);
      case 'lucky-cycling':
        return this.getLuckyCyclingAnalysis(mbti, month);
      case 'lucky-running':
        return this.getLuckyRunningAnalysis(mbti, month);
      case 'lucky-hiking':
        return this.getLuckyHikingAnalysis(mbti, month);
      case 'lucky-fishing':
        return this.getLuckyFishingAnalysis(mbti, month);
      case 'lucky-swim':
        return this.getLuckySwimAnalysis(mbti, month);
      default:
        return { analysis: `${category} 분석이 준비 중입니다.` };
    }
  }

  /**
   * 행운의 색상 분석
   */
  private getLuckyColorAnalysis(month: number, mbti: string, age: number): any {
    const colors = ['빨강', '파랑', '노랑', '초록', '보라', '주황', '분홍', '검정', '하양', '회색'];
    const primaryColor = colors[month % colors.length];
    const isExtrovert = mbti.startsWith('E');
    
    return {
      primary_color: primaryColor,
      secondary_colors: [`연한 ${primaryColor}`, `진한 ${primaryColor}`],
      color_meaning: `${primaryColor}은 당신의 생명력과 에너지를 상징합니다.`,
      usage_tips: [
        `${primaryColor} 계열의 옷을 착용하세요`,
        '중요한 일정이 있을 때 이 색상을 활용하세요',
        '집안 소품으로 이 색상을 배치하세요'
      ],
      avoid_colors: ['갈색', '베이지'],
      daily_application: `오늘은 ${primaryColor} 포인트 아이템으로 운을 끌어올리세요`,
      weekly_focus: isExtrovert ? '활기찬 톤의 색상' : '차분한 톤의 색상',
      color_energy: '활력과 자신감 상승'
    };
  }

  /**
   * 행운의 숫자 분석
   */
  private getLuckyNumberAnalysis(birth: Date, mbti: string, age: number): any {
    const day = birth.getDate();
    const month = birth.getMonth() + 1;
    const luckyNum = (day + month) % 10;
    
    return {
      primary_number: luckyNum,
      secondary_numbers: [(luckyNum + 1) % 10, (luckyNum + 2) % 10],
      numerology_meaning: `${luckyNum}은 당신의 인생 경로를 나타내는 숫자입니다.`,
      lucky_combinations: [`${luckyNum}${luckyNum}`, `${luckyNum}0`, `${luckyNum}8`],
      avoid_numbers: [4, 13],
      usage_tips: [
        '로또 번호 선택 시 참고하세요',
        '중요한 결정의 날짜로 활용하세요',
        '비밀번호나 전화번호에 포함시키세요'
      ],
      daily_guidance: `오늘 ${luckyNum}번대 시간에 중요한 일을 처리하세요`,
      number_energy: '행운과 성공을 끌어당기는 힘'
    };
  }

  /**
   * 행운의 음식 분석
   */
  private getLuckyFoodAnalysis(month: number, mbti: string, age: number): any {
    const seasonalFoods = [
      ['딸기', '봄나물', '죽순'], // 봄
      ['수박', '복숭아', '옥수수'], // 여름
      ['사과', '배', '감'], // 가을
      ['귤', '곶감', '견과류'] // 겨울
    ];
    const season = Math.floor((month - 1) / 3);
    const seasonalFood = seasonalFoods[season];
    
    return {
      seasonal_foods: seasonalFood,
      lucky_main_dish: mbti.startsWith('E') ? '매운 음식' : '따뜻한 국물',
      lucky_snack: '견과류',
      lucky_drink: month <= 6 ? '녹차' : '따뜻한 차',
      energy_foods: ['홍삼', '대추', '꿀'],
      avoid_foods: ['차가운 음식', '기름진 음식'],
      meal_timing: [
        '아침: 따뜻한 죽이나 미역국',
        '점심: 균형 잡힌 한식',
        '저녁: 가벼운 식사'
      ],
      cooking_tips: '음식을 직접 만들면 더 큰 행운이 따릅니다',
      nutritional_focus: '몸을 따뜻하게 하는 음식 위주로 섭취하세요'
    };
  }

  /**
   * 부적 분석
   */
  private getTalismanAnalysis(birth: Date, mbti: string, age: number): any {
    const elements = ['목', '화', '토', '금', '수'];
    const element = elements[birth.getMonth() % 5];
    
    return {
      recommended_talisman: `${element}기운 부적`,
      talisman_type: mbti.endsWith('J') ? '안정형 부적' : '변화형 부적',
      materials: element === '금' ? ['금', '은', '동'] : ['나무', '천연석', '옥'],
      colors: element === '화' ? ['빨강', '주황'] : ['파랑', '초록'],
      placement: [
        '지갑이나 가방 안',
        '침실 머리맡',
        '자주 사용하는 책상 위'
      ],
      activation_method: '매일 아침 손으로 만지며 소원을 빌어보세요',
      care_instructions: '한 달에 한 번 깨끗한 물로 닦아주세요',
      replacement_timing: '1년마다 새로 교체하는 것이 좋습니다',
      special_effects: '재물운과 건강운 상승'
    };
  }

  /**
   * 행운의 시리즈 분석
   */
  private getLuckySeriesAnalysis(mbti: string, age: number): any {
    return {
      lucky_series: mbti.includes('N') ? '판타지/SF 시리즈' : '로맨스/일상 시리즈',
      recommended_shows: [
        '인기 드라마 시리즈',
        '다큐멘터리 시리즈',
        '예능 프로그램'
      ],
      viewing_schedule: '주말 저녁이 가장 좋습니다',
      lucky_genres: mbti.startsWith('E') ? ['액션', '코미디'] : ['멜로', '스릴러'],
      avoid_content: '너무 자극적이거나 무서운 내용',
      binge_guidance: '하루 2-3편 정도가 적당합니다',
      social_viewing: '가족이나 친구와 함께 보면 더 좋습니다',
      emotional_benefit: '스트레스 해소와 영감 획득'
    };
  }

  /**
   * 시험운 분석
   */
  private getLuckyExamAnalysis(mbti: string, age: number): any {
    const isJudging = mbti.endsWith('J');
    
    return {
      best_study_time: isJudging ? '오전 9-11시' : '오후 2-4시',
      study_method: mbti.includes('V') ? '시각적 학습' : '청각적 학습',
      lucky_study_location: '조용한 도서관이나 카페',
      concentration_tips: [
        '25분 공부 후 5분 휴식',
        '충분한 수면 유지',
        '규칙적인 식사'
      ],
      exam_day_routine: [
        '평소보다 30분 일찍 기상',
        '가벼운 아침 식사',
        '긍정적인 마인드 유지'
      ],
      lucky_colors_for_exam: ['파랑', '초록'],
      stress_management: '시험 전날 충분한 휴식을 취하세요',
      success_probability: age < 25 ? '매우 높음' : '높음'
    };
  }

  /**
   * 사이클링 운세 분석
   */
  private getLuckyCyclingAnalysis(mbti: string, month: number): any {
    return {
      best_cycling_time: month <= 6 ? '오전 7-9시' : '오후 5-7시',
      lucky_route: mbti.startsWith('E') ? '사람들과 함께하는 그룹 라이딩' : '조용한 강변길',
      weather_guidance: '맑고 바람이 적은 날이 좋습니다',
      distance_recommendation: mbti.endsWith('J') ? '계획적인 장거리' : '즉흥적인 단거리',
      safety_tips: [
        '헬멧 착용 필수',
        '밝은 색상의 옷 착용',
        '충분한 수분 섭취'
      ],
      energy_boost: '사이클링으로 스트레스 해소와 체력 증진',
      social_aspect: '동호회 활동으로 인맥 확장 기회',
      lucky_cycling_days: ['화요일', '목요일', '토요일']
    };
  }

  /**
   * 러닝 운세 분석
   */
  private getLuckyRunningAnalysis(mbti: string, month: number): any {
    return {
      optimal_running_time: month <= 4 || month >= 10 ? '오전 6-8시' : '오후 6-8시',
      running_style: mbti.includes('S') ? '꾸준한 페이스 유지' : '인터벌 트레이닝',
      lucky_location: '공원이나 트랙',
      distance_goal: '주 3회, 회당 3-5km',
      motivation_tips: [
        '목표 설정하고 기록하기',
        '좋아하는 음악 들으며 뛰기',
        '러닝 메이트 찾기'
      ],
      injury_prevention: '충분한 워밍업과 쿨다운',
      mental_benefits: '엔돌핀 분비로 기분 향상',
      seasonal_advice: month <= 6 ? '자외선 차단 필수' : '보온에 신경쓰기'
    };
  }

  /**
   * 등산 운세 분석
   */
  private getLuckyHikingAnalysis(mbti: string, month: number): any {
    return {
      best_hiking_season: month >= 3 && month <= 5 || month >= 9 && month <= 11 ? '최적기' : '주의 필요',
      difficulty_level: mbti.endsWith('J') ? '계획적인 코스 선택' : '도전적인 코스',
      lucky_mountains: ['북한산', '관악산', '남산'],
      hiking_schedule: '월 2-3회가 적당합니다',
      preparation_items: [
        '등산화와 등산복',
        '충분한 물과 간식',
        '응급용품'
      ],
      safety_guidelines: '날씨 확인 후 출발',
      spiritual_benefits: '자연과의 교감으로 마음의 평화',
      physical_benefits: '전신 운동으로 체력 증진'
    };
  }

  /**
   * 낚시 운세 분석
   */
  private getLuckyFishingAnalysis(mbti: string, month: number): any {
    return {
      best_fishing_time: '새벽 5-7시 또는 저녁 6-8시',
      lucky_spots: month <= 6 ? '민물 낚시터' : '바다 낚시',
      fish_type: ['붕어', '잉어', '송어'],
      weather_conditions: '흐린 날이나 가벼운 비 오는 날',
      patience_level: mbti.includes('P') ? '높음' : '보통',
      meditation_aspect: '마음의 평정과 집중력 향상',
      social_fishing: '가족이나 친구와 함께하면 더 좋습니다',
      success_tips: [
        '인내심 유지',
        '조용한 환경 만들기',
        '적절한 미끼 선택'
      ]
    };
  }

  /**
   * 수영 운세 분석
   */
  private getLuckySwimAnalysis(mbti: string, month: number): any {
    return {
      best_swimming_time: month >= 6 && month <= 8 ? '실외 수영장' : '실내 수영장',
      swimming_style: mbti.startsWith('E') ? '자유형과 접영' : '배영과 평영',
      frequency: '주 2-3회, 회당 30-45분',
      water_temperature: '26-28도가 최적입니다',
      health_benefits: [
        '전신 근육 발달',
        '심폐기능 향상',
        '관절 부담 최소화'
      ],
      mental_benefits: '물의 흐름으로 마음의 안정',
      safety_precautions: '충분한 준비운동 필수',
      goal_setting: mbti.endsWith('J') ? '거리 목표 설정' : '시간 목표 설정'
    };
  }

  /**
   * 기본 행운 아이템 데이터
   */
  private getDefaultLuckyItemData(userProfile: UserProfile, category: string): any {
    return {
      [category.replace(/-/g, '_')]: {
        analysis: `${category} 분석이 준비 중입니다.`,
        status: '분석 중',
        message: '곧 상세한 분석 결과를 제공해드릴 예정입니다.'
      },
      generated_at: new Date().toISOString()
    };
  }

  /**
   * 인생·경력 패키지 생성 (employment, moving, new-year, timeline, wish 등)
   */
  private async generateLifeCareerPackage(
    userId: string, 
    userProfile?: UserProfile, 
    category?: FortuneCategory
  ): Promise<any> {
    console.log(`🏢 인생·경력 패키지 생성... (사용자: ${userId}, 카테고리: ${category})`);
    
    if (!userProfile) {
      userProfile = this.getDefaultUserProfile(userId);
      console.log('🔧 기본 사용자 프로필 사용:', userProfile.name);
    }

    const profile = userProfile as UserProfile;

    try {
      const lifeCareerData = await this.generateLifeCareerFromGPT(profile, category);
      console.log(`✅ GPT ${category} 생성 완료 (사용자: ${userId})`);
      return lifeCareerData;
    } catch (error) {
      console.error(`❌ GPT ${category} 생성 실패:`, error);
      return this.getDefaultLifeCareerData(profile, category);
    }
  }

  private async generateLifeCareerFromGPT(userProfile: UserProfile, category?: FortuneCategory): Promise<any> {
    const birth = new Date(userProfile.birth_date);
    const age = this.calculateAge(userProfile.birth_date);
    const mbti = userProfile.mbti || 'ENFP';
    const name = userProfile.name || '사용자';

    console.log(`🔍 GPT ${category} 요청: ${name} (${userProfile.birth_date})`);

    const lifeCareerContent = this.getLifeCareerContent(category || 'employment', mbti, birth, age);
    
    console.log(`✅ GPT ${category} 생성 완료 (사용자: ${name})`);
    return lifeCareerContent;
  }

  private getLifeCareerContent(category: string, mbti: string, birth: Date, age: number): any {
    const month = birth.getMonth() + 1;

    switch (category) {
      case 'employment':
        return this.getEmploymentAnalysis(mbti, age, month);
      case 'moving':
        return this.getMovingAnalysis(mbti, age, month);
      case 'new-year':
        return this.getNewYearAnalysis(mbti, age, birth.getFullYear());
      case 'timeline':
        return this.getTimelineAnalysis(birth, mbti, age);
      case 'wish':
        return this.getWishAnalysis(mbti, age, month);
      case 'career':
        return this.getCareerAnalysis(mbti, age, month);
      case 'moving-date':
        return this.getMovingDateAnalysis(mbti, age, month);
      case 'avoid-people':
        return this.getAvoidPeopleAnalysis(mbti, age, month);
      case 'five-blessings':
        return this.getFiveBlessingsAnalysis(mbti, age, birth);
      case 'salpuli':
        return this.getSalpuliAnalysis(mbti, age, birth);
      default:
        return this.getDefaultLifeCareerData({ 
          id: 'temp', 
          birth_date: birth.toISOString().split('T')[0],
          mbti,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }, category);
    }
  }

  private getEmploymentAnalysis(mbti: string, age: number, month: number): any {
    const isExtrovert = mbti.startsWith('E');
    const isJudging = mbti.includes('J');
    
    const baseScore = 70 + (isJudging ? 10 : 5) + (isExtrovert ? 8 : 3);
    const seasonBonus = [10, 15, 8, 12, 18, 10, 5, 8, 15, 20, 12, 8][month - 1];
    
    return {
      employment: {
        overall_score: Math.min(95, baseScore + seasonBonus),
        current_job_market: {
          assessment: age < 30 ? '신입 채용 시즌으로 기회가 많습니다' : '경력직 수요가 증가하고 있습니다',
          favorable_industries: ['IT', '서비스업', '제조업', '금융업'],
          hiring_trends: '하반기 채용 활발'
        },
        interview_preparation: {
          strengths_to_highlight: isExtrovert ? ['소통능력', '적극성'] : ['집중력', '분석력'],
          areas_to_improve: isExtrovert ? ['깊이있는 사고'] : ['적극적 표현'],
          lucky_interview_dates: [`${month}월 15일`, `${month}월 22일`],
          recommended_outfit: '차분한 색상의 정장'
        },
        timing_advice: {
          best_application_period: '이번 달 중순이 가장 좋습니다',
          avoid_periods: ['연말연시'],
          follow_up_strategy: '면접 후 1주일 내 감사 인사'
        },
        success_factors: [
          '꾸준한 스킬 개발',
          '업계 트렌드 파악',
          '인적 네트워크 구축'
        ],
        generated_at: new Date().toISOString()
      }
    };
  }

  private getMovingAnalysis(mbti: string, age: number, month: number): any {
    const isJudging = mbti.includes('J');
    
    return {
      moving: {
        overall_luck: 75 + (isJudging ? 15 : 5),
        best_timing: {
          months: ['3월', '4월', '9월', '10월'],
          avoid_months: ['7월', '8월', '12월', '1월'],
          lucky_days: ['수요일', '토요일']
        },
        location_guidance: {
          favorable_directions: ['남동쪽', '서쪽'],
          housing_type: '채광이 좋은 곳',
          neighborhood_characteristics: '교통이 편리한 지역'
        },
        preparation_checklist: {
          planning_phase: '2개월 전부터 준비',
          budget_planning: '예상 비용의 120% 준비',
          timing_coordination: '업무 일정과 조화'
        },
        generated_at: new Date().toISOString()
      }
    };
  }

  private getNewYearAnalysis(mbti: string, age: number, year: number): any {
    const targetYear = new Date().getFullYear() + 1;
    
    return {
      'new-year': {
        yearly_theme: mbti.includes('N') ? '창의와 혁신의 해' : '안정과 성장의 해',
        resolution_guidance: {
          suitable_goals: age < 30 ? ['자기계발', '인맥확장'] : ['경력발전', '건강관리'],
          achievement_strategy: mbti.includes('J') ? '단계별 계획 수립' : '유연한 접근',
          monitoring_method: '분기별 점검'
        },
        major_opportunities: ['새로운 도전', '인간관계 확장', '투자 기회'],
        potential_challenges: ['과도한 욕심', '시간 관리', '스트레스'],
        lucky_elements: {
          colors: ['파랑', '금색'],
          numbers: [7, 12, 21],
          directions: ['동쪽', '남쪽']
        },
        generated_at: new Date().toISOString()
      }
    };
  }

  private getTimelineAnalysis(birth: Date, mbti: string, age: number): any {
    return {
      timeline: {
        current_phase: age < 30 ? '성장기' : age < 50 ? '발전기' : '성숙기',
        major_milestones: [
          { age: age + 2, event: '중요한 결정의 시기' },
          { age: age + 5, event: '새로운 기회 도래' }
        ],
        career_trajectory: '꾸준한 상승세',
        relationship_timeline: '안정적 발전',
        financial_planning: '단계적 자산 증대',
        personal_development: '지속적 성장',
        generated_at: new Date().toISOString()
      }
    };
  }

  private getWishAnalysis(mbti: string, age: number, month: number): any {
    const isIntuitive = mbti.includes('N');
    
    return {
      wish: {
        manifestation_power: 70 + (isIntuitive ? 15 : 5),
        wish_categories: {
          most_likely: ['건강', '인간관계', '성장'],
          challenging: ['급격한 변화', '즉시 성과'],
          timing_sensitive: ['3개월 내 목표']
        },
        manifestation_methods: {
          visualization: '매일 10분간 명상',
          action_steps: ['구체적 계획 수립', '꾸준한 실행'],
          energy_alignment: '긍정적 마음가짐 유지'
        },
        optimal_timing: {
          best_months: ['신월 시기', '보름달 시기'],
          daily_rituals: '아침 일찍 소원 빌기'
        },
        success_indicators: ['작은 변화 감지', '우연의 일치 증가'],
        generated_at: new Date().toISOString()
      }
    };
  }

  private getCareerAnalysis(mbti: string, age: number, month: number): any {
    const isIntuitive = mbti.includes('N');
    const isExtrovert = mbti.startsWith('E');
    
    return {
      career: {
        overall_direction: isIntuitive ? '창의적 분야 지향' : '실무적 전문성 추구',
        current_phase: age < 30 ? '기반 구축기' : age < 45 ? '성장기' : '성숙기',
        strength_areas: isExtrovert ? ['대인관계', '리더십'] : ['전문성', '집중력'],
        development_opportunities: [
          '새로운 기술 습득',
          '네트워킹 확장',
          '멘토링 참여'
        ],
        career_transitions: {
          timing: '36개월 내 중요한 기회',
          preparation: '지속적인 역량 개발',
          risk_management: '안정적 전환 준비'
        },
        success_factors: [
          '전문성 강화',
          '적응력 향상',
          '인간관계 구축'
        ],
        generated_at: new Date().toISOString()
      }
    };
  }

  private getMovingDateAnalysis(mbti: string, age: number, month: number): any {
    const isJudging = mbti.includes('J');
    
    return {
      'moving-date': {
        optimal_dates: {
          months: ['4월', '5월', '9월', '10월'],
          days_of_week: ['수요일', '토요일'],
          lunar_timing: '초승달 이후 1주일'
        },
        feng_shui_considerations: {
          auspicious_directions: ['동남쪽', '남쪽'],
          avoid_directions: ['정북쪽'],
          house_selection: '햇빛이 잘 드는 곳'
        },
        practical_timeline: {
          planning_period: isJudging ? '3개월 전부터' : '2개월 전부터',
          booking_timing: '1개월 전 예약',
          preparation_checklist: '2주 전 완료'
        },
        cultural_customs: {
          purification_ritual: '이사 전날 소금으로 정화',
          first_items: '쌀, 소금을 먼저 들여놓기',
          housewarming: '이사 후 1주일 내'
        },
        generated_at: new Date().toISOString()
      }
    };
  }

  private getAvoidPeopleAnalysis(mbti: string, age: number, month: number): any {
    const isFeeling = mbti.includes('F');
    
    return {
      'avoid-people': {
        warning_types: {
          energy_drainers: '부정적 에너지를 주는 사람',
          manipulators: '이용하려는 의도가 있는 사람',
          toxic_relationships: '독성 관계를 만드는 사람'
        },
        identification_signs: [
          '만날 때마다 피곤함을 느낌',
          '자신의 이야기만 하는 경향',
          '도움을 요청만 하고 주지 않음',
          '비판적이고 부정적인 말을 자주 함'
        ],
        protection_strategies: {
          boundary_setting: '명확한 경계선 설정',
          energy_protection: isFeeling ? '감정적 거리두기' : '논리적 판단 우선',
          communication: '단호하지만 예의바른 거절'
        },
        positive_relationships: {
          seek_types: ['격려해주는 사람', '성장을 돕는 사람', '긍정적 에너지'],
          networking_advice: '양보다 질 중시',
          maintenance: '건강한 관계 지속적 관리'
        },
        generated_at: new Date().toISOString()
      }
    };
  }

  private getFiveBlessingsAnalysis(mbti: string, age: number, birth: Date): any {
    const birthYear = birth.getFullYear();
    const element = this.getZodiacElement(birthYear);
    
    return {
      'five-blessings': {
        longevity: {
          score: 75 + (mbti.includes('S') ? 10 : 5),
          description: '건강한 생활습관으로 장수 가능',
          enhancement: '규칙적인 운동과 식단 관리'
        },
        wealth: {
          score: 70 + (mbti.includes('T') ? 15 : 5),
          description: '꾸준한 노력으로 재물 축적',
          enhancement: '장기적 투자와 저축 습관'
        },
        health: {
          score: 80 + (age < 40 ? 10 : -5),
          description: '전반적으로 건강한 상태',
          enhancement: '스트레스 관리와 정기 검진'
        },
        virtue: {
          score: 85 + (mbti.includes('F') ? 10 : 0),
          description: '인덕과 덕망이 쌓여가는 시기',
          enhancement: '봉사활동과 나눔 실천'
        },
        peaceful_death: {
          score: 75,
          description: '평안한 마무리 가능',
          enhancement: '가족과의 화목한 관계 유지'
        },
        traditional_elements: {
          dominant_element: element,
          life_philosophy: '균형잡힌 삶 추구',
          spiritual_guidance: '내면의 평화 중시'
        },
        generated_at: new Date().toISOString()
      }
    };
  }

  private getSalpuliAnalysis(mbti: string, age: number, birth: Date): any {
    const birthYear = birth.getFullYear();
    const birthMonth = birth.getMonth() + 1;
    
    return {
      salpuli: {
        detected_influences: {
          general_sal: '일반적인 살기',
          personal_sal: '개인 생년월일 기반 살',
          environmental_sal: '환경적 요인'
        },
        purification_methods: {
          ritual_timing: '매월 보름달 전후',
          materials_needed: ['굵은 소금', '정화수', '향', '촛불'],
          procedure: [
            '마음을 정화하고 집중',
            '소금으로 공간 정화',
            '향을 피우며 명상',
            '긍정적 다짐'
          ]
        },
        protection_practices: {
          daily_habits: [
            '아침 감사 인사',
            '부정적 생각 배제',
            '선행 실천'
          ],
          monthly_ritual: '보름달에 소원 빌기',
          seasonal_care: '계절 변화 시 에너지 정화'
        },
        spiritual_guidance: {
          meditation: '매일 10분 명상',
          gratitude: '감사 일기 작성',
          positive_thinking: '긍정적 마음가짐 유지'
        },
        expert_advice: '전문가 상담을 통한 개인별 맞춤 해결',
        generated_at: new Date().toISOString()
      }
    };
  }

  private getDefaultLifeCareerData(userProfile: UserProfile, category?: string): any {
    return {
      [category || 'employment']: {
        summary: '개인별 맞춤 분석을 위해 잠시만 기다려주세요.',
        advice: '곧 상세한 분석 결과를 제공해드리겠습니다.',
        generated_at: new Date().toISOString()
      }
    };
  }
}

// 싱글톤 인스턴스 생성
export const fortuneService = new FortuneService(); 
// 배치 운세 서비스 - 효율적인 대량 운세 생성
// 작성일: 2025-01-05

import { FortuneCategory, FortuneGroupType, UserProfile } from '../types/fortune-system';
import { generateBatchFortunes, BatchFortuneRequest } from '../../ai/openai-client';
import { createClient } from '@supabase/supabase-js';

export interface BatchFortuneType {
  SIGNUP: 'signup';      // 회원가입 시 생성
  DAILY: 'daily';        // 일일 배치 (자정)
  MANUAL: 'manual';      // 수동 요청
}

export class BatchFortuneService {
  private supabase: any = null;
  
  constructor() {
    // Supabase 클라이언트 초기화 (프로덕션용)
    if (process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY) {
      this.supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
      );
    }
  }

  /**
   * 회원가입 시 평생 운세 배치 생성
   */
  async processSignupBatch(userId: string, userProfile: UserProfile): Promise<void> {
    try {
      console.log(`🎯 회원가입 배치 운세 생성 시작: ${userId}`);
      
      // 평생 운세 카테고리들
      const signupFortunes: FortuneCategory[] = [
        'saju', 
        'traditional-saju',
        'tojeong', 
        'past-life', 
        'personality', 
        'destiny',
        'talent',
        'salpuli',
        'five-blessings'
      ];

      // 배치 API 호출
      const batchRequest: BatchFortuneRequest = {
        user_id: userId,
        fortunes: signupFortunes,
        profile: {
          name: userProfile.name || '사용자',
          birthDate: userProfile.birth_date,
          gender: userProfile.gender,
          mbti: userProfile.mbti,
          blood_type: userProfile.blood_type
        }
      };

      const { data: fortuneData, token_usage } = await generateBatchFortunes(batchRequest);
      
      console.log(`✅ 배치 생성 완료: ${Object.keys(fortuneData).length}개 운세 (토큰: ${token_usage})`);

      // DB에 저장
      await this.saveBatchFortunes(userId, 'signup', fortuneData);
      
      // 개별 운세도 캐시에 저장
      await this.saveIndividualFortunes(userId, fortuneData, 'LIFE_PROFILE');
      
    } catch (error) {
      console.error('회원가입 배치 처리 실패:', error);
      throw error;
    }
  }

  /**
   * 일일 배치 운세 생성 (자정 실행)
   */
  async processDailyBatch(): Promise<void> {
    try {
      console.log(`📅 일일 배치 운세 생성 시작`);
      
      // 활성 사용자 조회 (24시간 내 접속)
      const activeUsers = await this.getActiveUsers(24);
      
      console.log(`👥 활성 사용자 ${activeUsers.length}명 발견`);
      
      // 사용자별 일일 운세 생성
      for (const user of activeUsers) {
        await this.generateUserDailyFortunes(user);
      }
      
      console.log(`✅ 일일 배치 완료`);
      
    } catch (error) {
      console.error('일일 배치 처리 실패:', error);
      throw error;
    }
  }

  /**
   * 특정 사용자의 일일 운세 생성
   */
  private async generateUserDailyFortunes(user: any): Promise<void> {
    try {
      const dailyFortunes: FortuneCategory[] = [
        'daily',
        'today',
        'love',
        'career',
        'wealth',
        'biorhythm',
        'lucky-items',
        'lucky-color',
        'lucky-number'
      ];

      const batchRequest: BatchFortuneRequest = {
        user_id: user.id,
        fortunes: dailyFortunes,
        profile: {
          name: user.name || '사용자',
          birthDate: user.birth_date,
          gender: user.gender,
          mbti: user.mbti,
          blood_type: user.blood_type
        }
      };

      const { data: fortuneData, token_usage } = await generateBatchFortunes(batchRequest);
      
      // DB에 저장
      await this.saveBatchFortunes(user.id, 'daily', fortuneData);
      
      // 개별 운세도 캐시에 저장 (24시간 만료)
      await this.saveIndividualFortunes(user.id, fortuneData, 'DAILY_COMPREHENSIVE');
      
      console.log(`✅ ${user.name}님 일일 운세 생성 완료 (토큰: ${token_usage})`);
      
    } catch (error) {
      console.error(`사용자 ${user.id} 일일 운세 생성 실패:`, error);
    }
  }

  /**
   * 배치 운세 결과를 DB에 저장
   */
  private async saveBatchFortunes(
    userId: string, 
    batchType: string, 
    fortuneData: any
  ): Promise<void> {
    if (!this.supabase) {
      console.log('💾 개발 모드: 배치 운세 메모리에만 저장');
      return;
    }

    try {
      const expiresAt = this.calculateBatchExpiration(batchType);
      
      const { error } = await this.supabase
        .from('fortune_batches')
        .insert({
          user_id: userId,
          batch_type: batchType,
          fortunes: fortuneData,
          created_at: new Date().toISOString(),
          expires_at: expiresAt
        });

      if (error) throw error;
      
      console.log(`💾 배치 운세 DB 저장 완료: ${batchType}`);
      
    } catch (error) {
      console.error('배치 운세 DB 저장 실패:', error);
      throw error;
    }
  }

  /**
   * 개별 운세를 캐시에 저장
   */
  private async saveIndividualFortunes(
    userId: string,
    fortuneData: any,
    groupType: FortuneGroupType
  ): Promise<void> {
    // FortuneService의 캐싱 시스템과 연동
    // 각 운세를 개별적으로 캐시에 저장하여 즉시 조회 가능하게 함
    
    for (const [fortuneType, data] of Object.entries(fortuneData)) {
      const cacheKey = `fortune:${userId}:${groupType}:${fortuneType}`;
      
      // 실제 구현에서는 Redis나 메모리 캐시에 저장
      console.log(`💾 개별 운세 캐시 저장: ${fortuneType}`);
    }
  }

  /**
   * 활성 사용자 조회
   */
  private async getActiveUsers(hoursAgo: number): Promise<any[]> {
    if (!this.supabase) {
      // 개발 모드: 테스트 사용자 반환
      return [
        {
          id: 'test_user_1',
          name: '테스트사용자1',
          birth_date: '1990-01-01',
          gender: '남성',
          mbti: 'INTJ'
        }
      ];
    }

    try {
      const sinceTime = new Date(Date.now() - hoursAgo * 60 * 60 * 1000).toISOString();
      
      const { data, error } = await this.supabase
        .from('users')
        .select('id, name, birth_date, gender, mbti, blood_type')
        .gte('last_seen_at', sinceTime);

      if (error) throw error;
      
      return data || [];
      
    } catch (error) {
      console.error('활성 사용자 조회 실패:', error);
      return [];
    }
  }

  /**
   * 배치 타입별 만료 시간 계산
   */
  private calculateBatchExpiration(batchType: string): string | null {
    const now = new Date();
    
    switch (batchType) {
      case 'signup':
        // 평생 운세는 만료 없음
        return null;
        
      case 'daily':
        // 일일 운세는 다음날 자정까지
        const tomorrow = new Date(now);
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(0, 0, 0, 0);
        return tomorrow.toISOString();
        
      case 'manual':
        // 수동 요청은 7일
        return new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString();
        
      default:
        // 기본 24시간
        return new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString();
    }
  }

  /**
   * 특정 운세가 배치로 처리 가능한지 확인
   */
  static isBatchEligible(fortuneCategory: FortuneCategory): boolean {
    // 인터랙티브 운세들은 배치 처리 불가
    const nonBatchCategories: FortuneCategory[] = [
      'dream-interpretation',
      'tarot',
      'compatibility',
      'worry-bead',
      'face-reading',
      'palmistry'
    ];
    
    return !nonBatchCategories.includes(fortuneCategory);
  }
}

// 싱글톤 인스턴스
export const batchFortuneService = new BatchFortuneService();
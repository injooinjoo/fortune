import { supabase } from './supabase';
import { DailyFortuneData, FortuneResult } from './schemas';
import { format } from 'date-fns';

export class DailyFortuneService {
  /**
   * 개발 모드인지 확인
   */
  private static isDevelopmentMode(): boolean {
    return process.env.NODE_ENV === 'development' || !process.env.NEXT_PUBLIC_SUPABASE_URL;
  }

  /**
   * 로컬 스토리지에서 운세 데이터 가져오기 (개발 모드용)
   */
  private static getLocalFortune(userId: string, fortuneType: string): DailyFortuneData | null {
    if (typeof window === 'undefined') return null;
    
    const today = format(new Date(), 'yyyy-MM-dd');
    const key = `daily_fortune_${userId}_${fortuneType}_${today}`;
    const stored = localStorage.getItem(key);
    
    if (stored) {
      try {
        return JSON.parse(stored);
      } catch (error) {
        console.error('로컬 운세 데이터 파싱 실패:', error);
        return null;
      }
    }
    
    return null;
  }

  /**
   * 로컬 스토리지에 운세 데이터 저장 (개발 모드용)
   */
  private static saveLocalFortune(userId: string, fortuneType: string, fortuneData: FortuneResult): DailyFortuneData {
    const today = format(new Date(), 'yyyy-MM-dd');
    const dailyFortuneData: DailyFortuneData = {
      id: `local_${Date.now()}`,
      user_id: userId,
      fortune_type: fortuneType,
      fortune_data: fortuneData,
      created_date: today,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    if (typeof window !== 'undefined') {
      const key = `daily_fortune_${userId}_${fortuneType}_${today}`;
      localStorage.setItem(key, JSON.stringify(dailyFortuneData));
    }
    
    return dailyFortuneData;
  }

  /**
   * 오늘 날짜의 운세가 이미 존재하는지 확인
   */
  static async getTodayFortune(userId: string, fortuneType: string): Promise<DailyFortuneData | null> {
    // 개발 모드에서는 로컬 스토리지 사용
    if (this.isDevelopmentMode()) {
      return this.getLocalFortune(userId, fortuneType);
    }

    const today = format(new Date(), 'yyyy-MM-dd');
    
    try {
      const { data, error } = await supabase
        .from('daily_fortunes')
        .select('*')
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .eq('created_date', today)
        .single();

      if (error && error.code !== 'PGRST116') { // PGRST116은 "no rows returned" 에러
        console.error('오늘 운세 조회 실패:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('오늘 운세 조회 중 예외 발생:', error);
      return null;
    }
  }

/**
   * 새로운 운세 결과를 저장
   */
  static async saveTodayFortune(
    userId: string, 
    fortuneType: string, 
    fortuneData: FortuneResult
  ): Promise<DailyFortuneData | null> {
    // 개발 모드에서는 로컬 스토리지 사용
    if (this.isDevelopmentMode()) {
      return this.saveLocalFortune(userId, fortuneType, fortuneData);
    }

    const today = format(new Date(), 'yyyy-MM-dd');
    
    try {
      const { data, error } = await supabase
        .from('daily_fortunes')
        .insert({
          user_id: userId,
          fortune_type: fortuneType,
          fortune_data: fortuneData,
          created_date: today
        })
        .select()
        .single();

      if (error) {
        console.error('운세 저장 실패:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('운세 저장 중 예외 발생:', error);
      return null;
    }
  }

/**
   * 기존 운세 업데이트 (같은 날 다시 생성하는 경우)
   */
  static async updateTodayFortune(
    id: string,
    fortuneData: FortuneResult
  ): Promise<DailyFortuneData | null> {
    // 개발 모드에서는 로컬 스토리지를 다시 저장
    if (this.isDevelopmentMode()) {
      // ID에서 userId와 fortuneType 추출 (로컬 데이터 처리)
      if (typeof window !== 'undefined') {
        const keys = Object.keys(localStorage).filter(key => key.startsWith('daily_fortune_'));
        for (const key of keys) {
          const stored = localStorage.getItem(key);
          if (stored) {
            try {
              const data = JSON.parse(stored);
              if (data.id === id) {
                data.fortune_data = fortuneData;
                data.updated_at = new Date().toISOString();
                localStorage.setItem(key, JSON.stringify(data));
                return data;
              }
            } catch (error) {
              console.error('로컬 데이터 업데이트 실패:', error);
            }
          }
        }
      }
      return null;
    }

    try {
      const { data, error } = await supabase
        .from('daily_fortunes')
        .update({
          fortune_data: fortuneData,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        console.error('운세 업데이트 실패:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('운세 업데이트 중 예외 발생:', error);
      return null;
    }
  }

  /**
   * 사용자의 운세 기록 조회 (최근 N일)
   */
  static async getFortuneHistory(
    userId: string, 
    fortuneType?: string, 
    limit: number = 10
  ): Promise<DailyFortuneData[]> {
    try {
      let query = supabase
        .from('daily_fortunes')
        .select('*')
        .eq('user_id', userId)
        .order('created_date', { ascending: false })
        .limit(limit);

      if (fortuneType) {
        query = query.eq('fortune_type', fortuneType);
      }

      const { data, error } = await query;

      if (error) {
        console.error('운세 기록 조회 실패:', error);
        return [];
      }

      return data || [];
    } catch (error) {
      console.error('운세 기록 조회 중 예외 발생:', error);
      return [];
    }
  }

  /**
   * 운세 타입에 따른 키 생성 (캐싱 등에 사용)
   */
  static generateFortuneKey(userId: string, fortuneType: string, date?: Date): string {
    const targetDate = date || new Date();
    const dateStr = format(targetDate, 'yyyy-MM-dd');
    return `${userId}-${fortuneType}-${dateStr}`;
  }

  /**
   * 현재 사용자 ID 가져오기 (Supabase Auth 또는 게스트)
   */
  static async getCurrentUserId(): Promise<string | null> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      return user?.id || null;
    } catch (error) {
      console.error('사용자 ID 조회 실패:', error);
      return null;
    }
  }

  /**
   * 게스트 사용자를 위한 임시 ID 생성 (로컬 스토리지 기반)
   */
  static getGuestUserId(): string {
    if (typeof window === 'undefined') {
      return `temp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    const guestId = localStorage.getItem('guest_user_id');
    if (guestId) {
      return guestId;
    }

    const newGuestId = `guest_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    localStorage.setItem('guest_user_id', newGuestId);
    return newGuestId;
  }

  /**
   * 사용자 ID 가져오기 (인증된 사용자 우선, 없으면 게스트)
   */
  static async getUserId(): Promise<string> {
    const authUserId = await this.getCurrentUserId();
    return authUserId || this.getGuestUserId();
  }

  /**
   * Genkit 백엔드로 운세 생성 요청을 보냅니다.
   * @param payload Genkit API에 보낼 요청 페이로드
   * @returns Genkit API 응답 데이터
   */
  static async callGenkitFortuneAPI(payload: any): Promise<any> {
    try {
      const response = await fetch('/api/fortune/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorData = await response.json();
        console.error('Genkit API 호출 실패:', errorData);
        throw new Error(`Genkit API error: ${errorData.message || response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Genkit API 호출 중 예외 발생:', error);
      throw error;
    }
  }
} 
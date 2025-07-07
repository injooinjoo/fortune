// import { 
//   generateGroupFortune, 
// } from '@/ai/flows/generate-specialized-fortune';
import { 
  GroupFortuneInputSchema,
  GroupFortuneOutputSchema 
} from '@/lib/types/fortune-schemas';
import { z } from 'zod';

export type SharedFortuneData = {
  id: number;
  created_at: string;
  group_key: string;
  fortune_type: string;
  date: string;
  fortune_data: z.infer<typeof GroupFortuneOutputSchema>;
};

export class SharedFortuneService {
  /**
   * 로컬 스토리지에서 특정 그룹의 운세를 가져옵니다.
   */
  static getSharedFortune(
    groupKey: string,
    fortuneType: string,
    date: string
  ): SharedFortuneData | null {
    try {
      const key = `shared_fortune_${groupKey}_${fortuneType}_${date}`;
      const stored = localStorage.getItem(key);
      
      if (stored) {
        return JSON.parse(stored);
      }
      
      return null;
    } catch (error) {
      console.error('로컬 공유 운세 조회 오류:', error);
      return null;
    }
  }

  /**
   * 생성된 그룹 운세를 로컬 스토리지에 저장합니다.
   */
  static saveSharedFortune(
    groupKey: string,
    fortuneType: string,
    date: string,
    fortuneData: z.infer<typeof GroupFortuneOutputSchema>
  ): SharedFortuneData | null {
    try {
      const sharedFortuneData: SharedFortuneData = {
        id: Date.now(),
        created_at: new Date().toISOString(),
        group_key: groupKey,
        fortune_type: fortuneType,
        date: date,
        fortune_data: fortuneData
      };
      
      const key = `shared_fortune_${groupKey}_${fortuneType}_${date}`;
      localStorage.setItem(key, JSON.stringify(sharedFortuneData));
      
      console.log('✅ 공유 운세를 로컬 스토리지에 저장했습니다.');
      return sharedFortuneData;
    } catch (error) {
      console.error('로컬 공유 운세 저장 오류:', error);
      return null;
    }
  }

  /**
   * 그룹 운세를 가져오거나, 없으면 새로 생성하고 저장합니다.
   */
  static async getOrGenerateFortune(
    input: z.infer<typeof GroupFortuneInputSchema>
  ): Promise<z.infer<typeof GroupFortuneOutputSchema>> {
    
    const { groupKey, fortuneType, date } = input;
    
    // 1. 로컬 스토리지에서 캐시 확인
    const existingFortune = this.getSharedFortune(groupKey, fortuneType, date);
    if (existingFortune) {
      console.log('🔄 캐시된 공유 운세를 반환합니다.');
      return existingFortune.fortune_data;
    }

    // 2. 캐시 없으면 API로 생성
    const response = await fetch('/api/fortune/group', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(input),
    });
    
    if (!response.ok) {
      throw new Error('Failed to generate group fortune');
    }
    
    const newFortuneData = await response.json();

    // 3. 생성된 운세 로컬 스토리지에 저장
    try {
        this.saveSharedFortune(groupKey, fortuneType, date, newFortuneData);
    } catch (e) {
        console.error("공유 운세 저장 실패(진행에 영향 없음):", e);
    }

    return newFortuneData;
  }
} 
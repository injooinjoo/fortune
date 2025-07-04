import { supabase } from './supabase';
import { 
  generateGroupFortune, 
} from '@/ai/flows/generate-specialized-fortune';
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
   * DB에서 특정 그룹의 오늘 운세를 가져옵니다.
   */
  static async getSharedFortune(
    groupKey: string,
    fortuneType: string,
    date: string
  ): Promise<SharedFortuneData | null> {
    const { data, error } = await supabase
      .from('shared_fortunes')
      .select('*')
      .eq('group_key', groupKey)
      .eq('fortune_type', fortuneType)
      .eq('date', date)
      .single();

    if (error && error.code !== 'PGRST116') { // PGRST116: no rows found
      console.error('Error fetching shared fortune:', error);
      throw new Error('공유 운세 조회 중 오류가 발생했습니다.');
    }
    
    return data;
  }

  /**
   * 생성된 그룹 운세를 DB에 저장합니다.
   */
  static async saveSharedFortune(
    groupKey: string,
    fortuneType: string,
    date: string,
    fortuneData: z.infer<typeof GroupFortuneOutputSchema>
  ): Promise<SharedFortuneData | null> {
    const { data, error } = await supabase
      .from('shared_fortunes')
      .insert({
        group_key: groupKey,
        fortune_type: fortuneType,
        date: date,
        fortune_data: fortuneData,
      })
      .select()
      .single();

    if (error) {
      console.error('Error saving shared fortune:', error);
      throw new Error('공유 운세 저장 중 오류가 발생했습니다.');
    }

    return data;
  }

  /**
   * 그룹 운세를 가져오거나, 없으면 새로 생성하고 저장합니다.
   */
  static async getOrGenerateFortune(
    input: z.infer<typeof GroupFortuneInputSchema>
  ): Promise<z.infer<typeof GroupFortuneOutputSchema>> {
    
    const { groupKey, fortuneType, date } = input;
    
    // 1. DB에서 캐시 확인
    const existingFortune = await this.getSharedFortune(groupKey, fortuneType, date);
    if (existingFortune) {
      return existingFortune.fortune_data;
    }

    // 2. 캐시 없으면 AI로 생성
    const newFortuneData = await generateGroupFortune(input);

    // 3. 생성된 운세 DB에 저장 (오류가 발생해도 무시하고 결과는 반환)
    try {
        await this.saveSharedFortune(groupKey, fortuneType, date, newFortuneData);
    } catch (e) {
        console.error("공유 운세 저장 실패(진행에 영향 없음):", e);
    }

    return newFortuneData;
  }
} 
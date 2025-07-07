/**
 * 운세 관련 공통 유틸리티 함수들
 */

import { createDeterministicRandom, getTodayDateString } from './deterministic-random';

/**
 * 가짜 운세 데이터 생성을 방지하는 에러 클래스
 */
export class FortuneServiceError extends Error {
  constructor(fortuneType: string) {
    super(`${fortuneType} 운세 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다.`);
    this.name = 'FortuneServiceError';
  }
}

/**
 * GPT API 호출 - 실제 AI 분석
 */
export async function callGPTFortuneAPI(params: {
  type: string;
  userInfo: any;
  prompt?: string;
}): Promise<any> {
  try {
    console.log(`🤖 GPT 운세 분석 시작: ${params.type}`);
    
    // OpenAI 클라이언트 동적 import (서버 환경에서만)
    const { generateSingleFortune } = await import('../ai/openai-client');
    
    // 기본 사용자 프로필 구성
    const userProfile = {
      name: params.userInfo?.name || '사용자',
      birthDate: params.userInfo?.birthDate || params.userInfo?.birth_date || '1990-01-01',
      gender: params.userInfo?.gender || 'unknown',
      mbti: params.userInfo?.mbti || null,
      blood_type: params.userInfo?.blood_type || null
    };

    // 운세 타입에 따른 적절한 플로우 선택
    let result: any;
    
    // 일일/종합 운세 타입들
    const dailyTypes = ['daily', 'today', 'tomorrow', 'hourly', 'weekly', 'monthly', 'yearly'];
    // 인터랙티브 운세 타입들  
    const interactiveTypes = ['dream', 'tarot', 'fortune-cookie', 'worry-bead', 'taemong', 'psychology-test', 'physiognomy', 'face-reading'];
    // 평생 운세 타입들
    const lifeProfileTypes = ['saju', 'traditional-saju', 'talent', 'destiny', 'past-life', 'tojeong'];

    // OpenAI를 사용한 운세 생성
    result = await generateSingleFortune(params.type, userProfile, params.userInfo);

    console.log(`✅ GPT 운세 분석 완료: ${params.type}`);
    
    return {
      success: true,
      type: params.type,
      result: result,
      generated_at: new Date().toISOString(),
      source: 'gpt_genkit'
    };

  } catch (error) {
    console.error(`❌ GPT 운세 분석 실패 (${params.type}):`, error);
    
    // AI 실패 시 기본 응답 반환 - deterministic random 사용
    const userId = params.userInfo?.id || 'fallback-user';
    const rng = createDeterministicRandom(userId, getTodayDateString(), `${params.type}-fallback`);
    
    return {
      success: false,
      type: params.type,
      result: {
        overall_luck: rng.randomInt(70, 100), // 70-100점
        summary: `${params.userInfo?.name || '사용자'}님의 ${params.type} 운세 분석을 준비 중입니다.`,
        advice: "잠시 후 다시 시도해보세요.",
        generated_at: new Date().toISOString(),
        source: 'fallback'
      },
      error: error instanceof Error ? error.message : '분석 중 오류 발생',
      generated_at: new Date().toISOString()
    };
  }
}

/**
 * 사용자 입력 검증
 */
export function validateUserInput(input: any, requiredFields: string[]): boolean {
  if (!input || typeof input !== 'object') {
    return false;
  }
  
  return requiredFields.every(field => 
    input[field] !== undefined && 
    input[field] !== null && 
    input[field] !== ''
  );
}

/**
 * 운세 결과 타입 정의
 */
export interface FortuneResult {
  type: string;
  score?: number;
  analysis: string;
  advice?: string;
  timestamp: number;
  isRealData: boolean;
}

/**
 * 안전한 운세 결과 생성 (실제 API 연동까지의 임시 처리)
 */
export function createSafeFortuneResult(type: string): FortuneResult {
  return {
    type,
    analysis: `${type} 운세 분석은 현재 개발 중입니다. 곧 실제 AI 기반 분석을 제공할 예정입니다.`,
    advice: "잠시 후 다시 시도해주세요.",
    timestamp: Date.now(),
    isRealData: false
  };
}

/**
 * Math.random() 사용을 방지하는 함수
 * DeterministicRandom을 사용하여 일관된 결과 생성
 */
export function generateSecureScore(): never {
  throw new FortuneServiceError('점수 생성');
}

/**
 * 하드코딩된 배열 사용을 방지하는 함수
 */
export function getStaticFortuneData(type: string): never {
  throw new FortuneServiceError(`${type} 데이터`);
}

/**
 * 운세 타입별 필수 입력 필드 정의
 */
export const FORTUNE_REQUIRED_FIELDS: Record<string, string[]> = {
  'blood-type': ['bloodType', 'name'],
  'dream': ['dreamContent', 'name'],
  'face-reading': ['name'],
  'fortune-cookie': ['name'],
  'lucky-hiking': ['name', 'experience'],
  'psychology-test': ['answers', 'name'],
  'taemong': ['taemongContent', 'name'],
  'tarot': ['question', 'name'],
  'worry-bead': ['worry', 'name'],
  'physiognomy': ['name']
};

/**
 * 입력 값 정규화
 */
export function sanitizeInput(input: string): string {
  if (!input || typeof input !== 'string') {
    return '';
  }
  
  return input.trim().slice(0, 1000); // 최대 1000자로 제한
}

/**
 * 개발 모드에서만 디버그 정보 로깅
 */
export function debugLog(message: string, data?: any): void {
  if (process.env.NODE_ENV === 'development') {
    console.log(`[Fortune Debug] ${message}`, data || '');
  }
}
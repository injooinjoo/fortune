import { z } from 'zod';

// 사용자 프로필 스키마: 더 구체적인 정보 포함
export const UserProfileSchema = z.object({
  name: z.string().describe('사용자 이름'),
  gender: z.enum(['male', 'female']).describe('성별'),
  birthDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'YYYY-MM-DD 형식이어야 합니다.').describe('생년월일'),
  mbti: z.string().optional().describe('MBTI 유형'),
});

// 공통 운세 결과 스키마
export const FortuneResultSchema = z.object({
  summary: z.string().describe('한 줄 요약'),
  details: z.string().describe('상세 설명'),
  keywords: z.array(z.string()).describe('핵심 키워드 (3-5개)'),
});

// 평생 운세 결과 스키마
export const LifeProfileResultSchema = z.object({
  saju: FortuneResultSchema.describe('전통 사주'),
  pastLife: FortuneResultSchema.describe('전생 운세'),
  talent: FortuneResultSchema.describe('타고난 재능'),
});

// 일일 운세 결과 스키마
export const DailyFortuneResultSchema = z.object({
  overall: FortuneResultSchema.describe('오늘의 총운'),
  love: FortuneResultSchema.describe('오늘의 애정운'),
  wealth: FortuneResultSchema.describe('오늘의 재물운'),
  work: FortuneResultSchema.describe('오늘의 직업운'),
});

export const DailyFortuneInputSchema = z.object({
  userProfile: UserProfileSchema,
  lifeProfileResult: LifeProfileResultSchema.optional().describe('미리 생성된 평생 운세 데이터'),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

// 인터랙티브 운세 생성 플로우 (예: 타로)
export const InteractiveFortuneInputSchema = z.object({
  userProfile: UserProfileSchema,
  category: z.enum(['tarot', 'dreamInterpretation']),
  question: z.string().describe('타로 질문 또는 꿈 내용'),
});

export const InteractiveFortuneOutputSchema = z.object({
  interpretation: z.string().describe('해석 결과'),
  advice: z.string().describe('조언'),
  relatedTarotCards: z.array(z.string()).optional().describe('관련 타로 카드 (타로인 경우)'),
});

// 그룹 운세 생성 플로우 (예: 띠별, 혈액형별)
export const GroupFortuneInputSchema = z.object({
  fortuneType: z.enum(['zodiac', 'bloodType', 'zodiacAnimal']).describe('운세 종류'),
  groupKey: z.string().describe('운세 그룹 키 (예: "dragon", "a", "rat")'),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).describe('요청 날짜'),
});

// 그룹 운세 결과는 간단하게 단일 FortuneResultSchema를 사용.
// 필요시 DailyFortuneResultSchema처럼 확장 가능.
export const GroupFortuneOutputSchema = FortuneResultSchema; 
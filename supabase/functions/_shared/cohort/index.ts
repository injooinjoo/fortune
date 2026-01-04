/**
 * Cohort Pool 유틸리티
 *
 * Edge Function에서 cohort pool을 조회/저장하기 위한 헬퍼
 * API 비용 90% 절감 목표
 */

import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Cohort 데이터 타입
export interface CohortData {
  [key: string]: string;
}

// Cohort Pool 결과 타입
export interface CohortResult {
  id: string;
  result_template: Record<string, unknown>;
  usage_count: number;
}

/**
 * SHA-256 해시 생성 (Web Crypto API)
 * Note: MD5는 Web Crypto API에서 지원하지 않음
 */
async function generateHash(input: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(input);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Cohort 해시 생성
 */
export async function generateCohortHash(cohortData: CohortData): Promise<string> {
  const sortedKeys = Object.keys(cohortData).sort();
  const normalized = sortedKeys.map(k => `${k}:${cohortData[k]}`).join('|');
  return generateHash(normalized);
}

/**
 * 나잇대 계산
 */
export function getAgeGroup(birthDate: string | Date): string {
  const birth = typeof birthDate === 'string' ? new Date(birthDate) : birthDate;
  const today = new Date();
  const age = today.getFullYear() - birth.getFullYear();

  if (age < 20) return '10대';
  if (age < 30) return '20대';
  if (age < 40) return '30대';
  if (age < 50) return '40대';
  return '50대+';
}

/**
 * 12지지 (띠) 계산
 */
export function getZodiacName(year: number): string {
  const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
  return animals[year % 12];
}

/**
 * 오행 계산 (천간 기반)
 */
export function getElement(year: number): string {
  const stemIndex = (year - 4) % 10;
  if (stemIndex < 2) return '목';
  if (stemIndex < 4) return '화';
  if (stemIndex < 6) return '토';
  if (stemIndex < 8) return '금';
  return '수';
}

/**
 * 시간대 분류
 */
export function getPeriod(hour: number): string {
  if (hour < 6) return '새벽';
  if (hour < 12) return '아침';
  if (hour < 18) return '오후';
  if (hour < 21) return '저녁';
  return '밤';
}

/**
 * 계절 분류
 */
export function getSeason(month: number): string {
  if (month >= 3 && month <= 5) return '봄';
  if (month >= 6 && month <= 8) return '여름';
  if (month >= 9 && month <= 11) return '가을';
  return '겨울';
}

/**
 * Daily 운세 Cohort 추출
 */
export function extractDailyCohort(input: {
  birthDate: string;
  now?: Date;
}): CohortData {
  const birth = new Date(input.birthDate);
  const now = input.now || new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Seoul" }));

  return {
    period: getPeriod(now.getHours()),
    zodiac: getZodiacName(birth.getFullYear()),
    element: getElement(birth.getFullYear()),
  };
}

/**
 * Love 운세 Cohort 추출
 */
export function extractLoveCohort(input: {
  birthDate: string;
  gender: string;
  relationshipStatus?: string;
}): CohortData {
  const birth = new Date(input.birthDate);

  return {
    ageGroup: getAgeGroup(input.birthDate),
    gender: input.gender === 'male' ? '남' : input.gender === 'female' ? '여' : '기타',
    relationshipStatus: input.relationshipStatus || '솔로',
    zodiac: getZodiacName(birth.getFullYear()),
  };
}

/**
 * MBTI Cohort 추출
 */
export function extractMbtiCohort(input: {
  mbti: string;
}): CohortData {
  return {
    mbti: (input.mbti || 'INFP').toUpperCase(),
  };
}

/**
 * Lucky Items Cohort 추출
 */
export function extractLuckyItemsCohort(input: {
  category?: string;
  interests?: string[];
}): CohortData {
  // interests[0]이 category 역할
  const category = input.category || input.interests?.[0] || 'fashion';
  return {
    category: category,
  };
}

/**
 * Career Cohort 추출
 */
export function extractCareerCohort(input: {
  birthDate?: string;
  age?: number;
  gender?: string;
  industry?: string;
}): CohortData {
  let ageGroup = '30대';
  if (input.age) {
    ageGroup = getAgeGroup(new Date(new Date().getFullYear() - input.age, 0, 1));
  } else if (input.birthDate) {
    ageGroup = getAgeGroup(input.birthDate);
  }

  return {
    ageGroup: ageGroup,
    gender: input.gender === 'male' ? '남' : input.gender === 'female' ? '여' : '기타',
    industry: classifyIndustry(input.industry),
  };
}

/**
 * 산업 분류
 */
function classifyIndustry(industry?: string): string {
  if (!industry) return '기타';
  if (/IT|개발|소프트웨어|테크|프로그래밍/.test(industry)) return 'IT';
  if (/금융|은행|보험|증권|투자/.test(industry)) return '금융';
  if (/의료|병원|의사|간호|헬스케어/.test(industry)) return '의료';
  if (/교육|학교|강사|교수|학원/.test(industry)) return '교육';
  if (/서비스|요식|호텔|관광/.test(industry)) return '서비스';
  if (/제조|공장|생산|엔지니어링/.test(industry)) return '제조';
  if (/예술|디자인|음악|미술|콘텐츠/.test(industry)) return '예술';
  if (/공공|공무원|정부|행정/.test(industry)) return '공공';
  if (/스타트업|창업|벤처/.test(industry)) return '스타트업';
  return '기타';
}

/**
 * Health Cohort 추출
 */
export function extractHealthCohort(input: {
  birthDate: string;
  age?: number;
  gender?: string;
}): CohortData {
  const birth = new Date(input.birthDate);
  const now = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Seoul" }));

  return {
    ageGroup: getAgeGroup(input.birthDate),
    gender: input.gender === 'male' ? '남' : input.gender === 'female' ? '여' : '기타',
    season: getSeason(now.getMonth() + 1),
    element: getElement(birth.getFullYear()),
  };
}

/**
 * Dream Cohort 추출
 */
export function extractDreamCohort(input: {
  birthDate?: string;
  dream_content?: string;
  dream?: string;
}): CohortData {
  const dreamContent = input.dream_content || input.dream || '';
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  return {
    dreamCategory: classifyDreamCategory(dreamContent),
    emotion: classifyDreamEmotion(dreamContent),
    zodiac: getZodiacName(birthYear),
  };
}

/**
 * 꿈 카테고리 분류
 */
function classifyDreamCategory(dreamContent: string): string {
  if (/날다|하늘|비행|새|떠오르|공중/.test(dreamContent)) return '날기';
  if (/떨어|추락|절벽|높은곳|낙하/.test(dreamContent)) return '떨어짐';
  if (/쫓기|도망|쫓아오|따라오|도망/.test(dreamContent)) return '추격';
  if (/시험|테스트|문제|답안|학교|학원/.test(dreamContent)) return '시험';
  if (/늦|지각|놓치|기차|비행기|버스/.test(dreamContent)) return '늦음';
  if (/죽|장례|시체|묘지|사망/.test(dreamContent)) return '죽음';
  if (/돈|지갑|금|보물|복권|로또/.test(dreamContent)) return '돈';
  if (/개|고양이|뱀|호랑이|동물|사자|곰/.test(dreamContent)) return '동물';
  if (/바다|강|호수|수영|익사|물|비/.test(dreamContent)) return '물';
  return '사람';
}

/**
 * 꿈 감정 분류
 */
function classifyDreamEmotion(dreamContent: string): string {
  if (/무섭|두렵|겁|공포|소름/.test(dreamContent)) return '공포';
  if (/불안|걱정|초조|긴장/.test(dreamContent)) return '불안';
  if (/기쁘|행복|좋|웃|즐거/.test(dreamContent)) return '기쁨';
  if (/슬프|울|눈물|서러|아프/.test(dreamContent)) return '슬픔';
  return '중립';
}

/**
 * Wealth Cohort 추출 (45개 = 5 × 3 × 3)
 */
export function extractWealthCohort(input: {
  goal?: string;
  risk?: string;
  urgency?: string;
}): CohortData {
  // goal: saving, house, expense, investment, income (5)
  const goalMap: Record<string, string> = {
    'saving': '목돈',
    'house': '내집',
    'expense': '지출',
    'investment': '투자',
    'income': '수입',
  };

  // risk: safe, balanced, aggressive (3)
  const riskMap: Record<string, string> = {
    'safe': '안전',
    'balanced': '균형',
    'aggressive': '공격',
  };

  // urgency: urgent, thisYear, longTerm (3)
  const urgencyMap: Record<string, string> = {
    'urgent': '급함',
    'thisYear': '올해',
    'longTerm': '장기',
  };

  return {
    goal: goalMap[input.goal || ''] || '목돈',
    risk: riskMap[input.risk || ''] || '균형',
    urgency: urgencyMap[input.urgency || ''] || '장기',
  };
}

/**
 * Compatibility Cohort 추출
 */
export function extractCompatibilityCohort(input: {
  person1_birth_date: string;
  person2_birth_date: string;
  person1_gender?: string;
  person2_gender?: string;
}): CohortData {
  const birth1 = new Date(input.person1_birth_date);
  const birth2 = new Date(input.person2_birth_date);
  const gender1 = input.person1_gender || 'male';
  const gender2 = input.person2_gender || 'female';

  return {
    zodiac1: getZodiacName(birth1.getFullYear()),
    zodiac2: getZodiacName(birth2.getFullYear()),
    genderPair: classifyGenderPair(gender1, gender2),
  };
}

/**
 * 성별쌍 분류
 */
function classifyGenderPair(gender1: string, gender2: string): string {
  const isMale1 = gender1 === 'male' || gender1 === '남';
  const isMale2 = gender2 === 'male' || gender2 === '남';

  if (isMale1 && !isMale2) return '남녀';
  if (!isMale1 && isMale2) return '남녀';
  if (isMale1 && isMale2) return '남남';
  return '여여';
}

/**
 * 운세 타입별 Cohort 추출
 */
export function extractCohort(fortuneType: string, input: Record<string, unknown>): CohortData | null {
  try {
    switch (fortuneType) {
      case 'daily':
        return extractDailyCohort({
          birthDate: input.birthDate as string,
          now: input.date ? new Date(input.date as string) : undefined,
        });

      case 'love':
        return extractLoveCohort({
          birthDate: input.birthDate as string,
          gender: input.gender as string,
          relationshipStatus: input.relationshipStatus as string,
        });

      case 'mbti':
        return extractMbtiCohort({
          mbti: input.mbti as string,
        });

      case 'lucky-items':
        return extractLuckyItemsCohort({
          category: input.category as string,
          interests: input.interests as string[],
        });

      case 'career':
        return extractCareerCohort({
          birthDate: input.birthDate as string,
          age: input.age as number,
          gender: input.gender as string,
          industry: input.industry as string,
        });

      case 'health':
        return extractHealthCohort({
          birthDate: input.birthDate as string,
          age: input.age as number,
          gender: input.gender as string,
        });

      case 'dream':
        return extractDreamCohort({
          birthDate: input.birthDate as string,
          dream_content: input.dream_content as string,
          dream: input.dream as string,
        });

      case 'compatibility':
        return extractCompatibilityCohort({
          person1_birth_date: input.person1_birth_date as string,
          person2_birth_date: input.person2_birth_date as string,
          person1_gender: input.person1_gender as string,
          person2_gender: input.person2_gender as string,
        });

      case 'talent':
        return extractTalentCohort({
          birthDate: input.birthDate as string,
          age: input.age as number,
          gender: input.gender as string,
          talentArea: input.talentArea as string,
        });

      case 'investment':
        return extractInvestmentCohort({
          birthDate: input.birthDate as string,
          age: input.age as number,
          sajuData: input.sajuData as { dayMaster?: { element?: string } },
        });

      case 'wealth':
        return extractWealthCohort({
          goal: input.goal as string,
          risk: input.risk as string,
          urgency: input.urgency as string,
        });

      case 'ex-lover':
        return extractExLoverCohort({
          emotionState: input.emotionState as string,
          timeElapsed: input.timeElapsed as string,
          contactStatus: input.contactStatus as string,
        });

      case 'blind-date':
        return extractBlindDateCohort({
          birthDate: input.birthDate as string,
          age: input.age as number,
          gender: input.gender as string,
          dateGoal: input.dateGoal as string,
        });

      case 'avoid-people':
        return extractAvoidPeopleCohort({
          birthDate: input.birthDate as string,
          context: input.context as string,
        });

      case 'saju':
      case 'traditional-saju':
        return extractSajuCohort({
          birthDate: input.birthDate as string,
          question: input.question as string,
          sajuData: input.sajuData as {
            dayPillar?: { gan?: string };
            elementBalance?: string;
          },
        });

      case 'tarot':
        return extractTarotCohort({
          spreadType: input.spreadType as string,
          question: input.question as string,
          birthDate: input.birthDate as string,
        });

      case 'face-reading':
      case 'face':
        return extractFaceReadingCohort({
          faceShape: input.faceShape as string,
          gender: input.gender as string,
          birthDate: input.birthDate as string,
          age: input.age as number,
        });

      case 'family-relationship':
      case 'family-change':
      case 'family-children':
      case 'family-health':
      case 'family-wealth':
        return extractFamilyCohort({
          relationship: input.relationship as string,
          detailed_questions: input.detailed_questions as string[],
          concern_label: input.concern_label as string,
        });

      case 'new-year':
      case 'new_year':
        return extractNewYearCohort({
          goal: input.goal as string,
          birthDate: input.birthDate as string,
          zodiacAnimal: input.zodiacAnimal as string,
        });

      case 'talisman':
        return extractTalismanCohort({
          birthDate: input.birthDate as string,
        });

      case 'pet-compatibility':
      case 'pet':
        return extractPetCompatibilityCohort({
          petType: input.petType as string,
          birthDate: input.birthDate as string,
        });

      case 'exam':
        return extractExamCohort({
          examType: input.examType as string,
          birthDate: input.birthDate as string,
        });

      case 'moving':
        return extractMovingCohort({
          direction: input.direction as string,
          birthDate: input.birthDate as string,
        });

      default:
        return null;
    }
  } catch (e) {
    console.error(`[Cohort] 추출 실패 (${fortuneType}):`, e);
    return null;
  }
}

/**
 * Cohort Pool에서 결과 조회
 *
 * @param supabase - Supabase 클라이언트
 * @param fortuneType - 운세 타입
 * @param cohortHash - 미리 생성된 cohort 해시
 * @returns 결과 템플릿 또는 null (pool에 없으면)
 */
export async function getFromCohortPool(
  supabase: SupabaseClient,
  fortuneType: string,
  cohortHash: string
): Promise<Record<string, unknown> | null> {
  try {
    console.log(`[Cohort] ${fortuneType} 조회: ${cohortHash.slice(0, 8)}...`);

    const { data, error } = await supabase.rpc('get_random_cohort_result', {
      p_fortune_type: fortuneType,
      p_cohort_hash: cohortHash,
    });

    if (error) {
      console.error('[Cohort] RPC 오류:', error);
      return null;
    }

    if (!data) {
      console.log('[Cohort] Pool에 결과 없음');
      return null;
    }

    console.log('[Cohort] ✅ Pool에서 결과 반환');
    return data as Record<string, unknown>;
  } catch (e) {
    console.error('[Cohort] 조회 실패:', e);
    return null;
  }
}

/**
 * Cohort Pool에 결과 저장
 *
 * @param supabase - Supabase 클라이언트
 * @param fortuneType - 운세 타입
 * @param cohortHash - 미리 생성된 cohort 해시
 * @param cohortData - 원본 cohort 데이터 (참조용 저장)
 * @param resultTemplate - LLM 생성 결과 템플릿
 */
export async function saveToCohortPool(
  supabase: SupabaseClient,
  fortuneType: string,
  cohortHash: string,
  cohortData: CohortData,
  resultTemplate: Record<string, unknown>
): Promise<boolean> {
  try {
    // Pool 크기 확인
    const { data: poolSize } = await supabase.rpc('get_cohort_pool_size', {
      p_fortune_type: fortuneType,
      p_cohort_hash: cohortHash,
    });

    // 최대 50개 유지
    if ((poolSize as number) >= 50) {
      console.log('[Cohort] Pool이 이미 가득 참');
      return false;
    }

    const { error } = await supabase.from('cohort_fortune_pool').insert({
      fortune_type: fortuneType,
      cohort_hash: cohortHash,
      cohort_data: cohortData,
      result_template: resultTemplate,
      quality_score: 1.0,
    });

    if (error) {
      console.error('[Cohort] 저장 실패:', error);
      return false;
    }

    console.log('[Cohort] ✅ Pool에 저장 완료');
    return true;
  } catch (e) {
    console.error('[Cohort] 저장 오류:', e);
    return false;
  }
}

/**
 * 결과 템플릿에 개인 정보 삽입
 */
export function personalize(
  template: Record<string, unknown>,
  personalData: Record<string, unknown>
): Record<string, unknown> {
  let jsonStr = JSON.stringify(template);

  // 플레이스홀더 치환
  const replacements: Record<string, string> = {
    '{{userName}}': (personalData.name || personalData.userName || '회원님') as string,
    '{{age}}': personalData.age ? String(personalData.age) : '20',
    '{{birthYear}}': extractBirthYear(personalData.birthDate as string),
    '{{person1_name}}': (personalData.person1_name || '본인') as string,
    '{{person2_name}}': (personalData.person2_name || '상대방') as string,
    '{{question}}': (personalData.question || '') as string,
    '{{dreamContent}}': (personalData.dream_content || '') as string,
    '{{exName}}': (personalData.exName || '그분') as string,
  };

  for (const [placeholder, value] of Object.entries(replacements)) {
    jsonStr = jsonStr.split(placeholder).join(value);
  }

  return JSON.parse(jsonStr);
}

function extractBirthYear(birthDate: string | undefined): string {
  if (!birthDate) return '2000';
  try {
    return String(new Date(birthDate).getFullYear());
  } catch {
    return '2000';
  }
}

/**
 * Talent Cohort 추출 (120개 = 5 × 3 × 8)
 */
export function extractTalentCohort(input: {
  birthDate?: string;
  age?: number;
  gender?: string;
  talentArea?: string;
}): CohortData {
  let ageGroup = '30대';
  if (input.age) {
    ageGroup = getAgeGroup(new Date(new Date().getFullYear() - input.age, 0, 1));
  } else if (input.birthDate) {
    ageGroup = getAgeGroup(input.birthDate);
  }

  return {
    ageGroup: ageGroup,
    gender: input.gender === 'male' ? '남' : input.gender === 'female' ? '여' : '기타',
    talentArea: classifyTalentArea(input.talentArea),
  };
}

function classifyTalentArea(area?: string): string {
  if (!area) return '기타';
  if (/예술|창작|표현|디자인|미술|음악/.test(area)) return '예술';
  if (/기술|개발|IT|엔지니어|프로그래밍/.test(area)) return '기술';
  if (/리더십|관리|통솔|경영|기획/.test(area)) return '리더십';
  if (/분석|데이터|연구|논리/.test(area)) return '분석';
  if (/창의|아이디어|혁신|마케팅/.test(area)) return '창의';
  if (/사회|소통|상담|대인|영업/.test(area)) return '사회';
  if (/실무|행정|운영|사무/.test(area)) return '실무';
  if (/학문|교육|연구|교수/.test(area)) return '학문';
  return '기타';
}

/**
 * Investment Cohort 추출 (75개 = 5 × 3 × 5)
 */
export function extractInvestmentCohort(input: {
  birthDate?: string;
  age?: number;
  sajuData?: { dayMaster?: { element?: string } };
}): CohortData {
  let ageGroup = '30대';
  if (input.age) {
    ageGroup = getAgeGroup(new Date(new Date().getFullYear() - input.age, 0, 1));
  } else if (input.birthDate) {
    ageGroup = getAgeGroup(input.birthDate);
  }

  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;
  const element = getElement(birthYear);
  const riskTolerance = classifyRiskTolerance(element);

  return {
    ageGroup: ageGroup,
    riskTolerance: riskTolerance,
    element: element,
  };
}

function classifyRiskTolerance(element: string): string {
  if (element === '금' || element === '수') return '보수적';
  if (element === '토') return '중립';
  return '공격적'; // 목, 화
}

/**
 * Ex-lover Cohort 추출 (60개 = 5 × 4 × 3)
 */
export function extractExLoverCohort(input: {
  emotionState?: string;
  timeElapsed?: string;
  contactStatus?: string;
}): CohortData {
  return {
    emotionState: classifyEmotionState(input.emotionState),
    timeElapsed: classifyTimeElapsed(input.timeElapsed),
    contactStatus: classifyContactStatus(input.contactStatus),
  };
}

function classifyEmotionState(state?: string): string {
  if (!state) return '혼란';
  if (/미련|그리움|보고싶/.test(state)) return '미련';
  if (/분노|화|억울/.test(state)) return '분노';
  if (/무덤덤|괜찮|아무렇지/.test(state)) return '무덤덤';
  if (/그리움|추억|좋았/.test(state)) return '그리움';
  return '혼란';
}

function classifyTimeElapsed(time?: string): string {
  if (!time) return '1-6개월';
  if (/1개월|한달|최근/.test(time)) return '1개월내';
  if (/6개월|반년/.test(time)) return '1-6개월';
  if (/1년|12개월/.test(time)) return '6-12개월';
  return '1년이상';
}

function classifyContactStatus(status?: string): string {
  if (!status) return '연락끊김';
  if (/연락중|가끔|소통/.test(status)) return '연락중';
  if (/차단|블록/.test(status)) return '차단';
  return '연락끊김';
}

/**
 * Blind Date Cohort 추출 (45개 = 5 × 3 × 3)
 */
export function extractBlindDateCohort(input: {
  birthDate?: string;
  age?: number;
  gender?: string;
  dateGoal?: string;
}): CohortData {
  let ageGroup = '20대';
  if (input.age) {
    ageGroup = getAgeGroup(new Date(new Date().getFullYear() - input.age, 0, 1));
  } else if (input.birthDate) {
    ageGroup = getAgeGroup(input.birthDate);
  }

  return {
    ageGroup: ageGroup,
    gender: input.gender === 'male' ? '남' : input.gender === 'female' ? '여' : '기타',
    dateGoal: classifyDateGoal(input.dateGoal),
  };
}

function classifyDateGoal(goal?: string): string {
  if (!goal) return '진지한만남';
  if (/진지|결혼|장기|오래/.test(goal)) return '진지한만남';
  if (/가벼|친구|재미|캐주얼/.test(goal)) return '가벼운만남';
  return '친구먼저';
}

/**
 * Avoid People Cohort 추출 (300개 = 12 × 5 × 5)
 */
export function extractAvoidPeopleCohort(input: {
  birthDate?: string;
  context?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  return {
    zodiac: getZodiacName(birthYear),
    element: getElement(birthYear),
    context: classifyContext(input.context),
  };
}

function classifyContext(context?: string): string {
  if (!context) return '일반';
  if (/직장|회사|업무|상사|동료/.test(context)) return '직장';
  if (/학교|학생|교수|선배|후배/.test(context)) return '학교';
  if (/가족|부모|형제|친척/.test(context)) return '가족';
  if (/연애|애인|이성|데이트/.test(context)) return '연애';
  return '일반';
}

/**
 * Saju Cohort 추출 (250개 = 10 × 5 × 5)
 */
export function extractSajuCohort(input: {
  birthDate?: string;
  question?: string;
  sajuData?: {
    dayPillar?: { gan?: string };
    elementBalance?: string;
  };
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  // 일주 천간 (간지에서 추출)
  const dayMaster = input.sajuData?.dayPillar?.gan || getDayMasterFromYear(birthYear);
  const elementBalance = input.sajuData?.elementBalance || getElement(birthYear) + '과다';

  return {
    dayMaster: dayMaster,
    elementBalance: elementBalance,
    questionCategory: classifyQuestionCategory(input.question),
  };
}

function getDayMasterFromYear(year: number): string {
  const gans = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  return gans[(year - 4) % 10];
}

function classifyQuestionCategory(question?: string): string {
  if (!question) return '대인';
  if (/연애|사랑|결혼|이성|짝|소개팅/.test(question)) return '연애';
  if (/취업|직장|일|커리어|승진|이직/.test(question)) return '취업';
  if (/건강|아프|병|몸|다이어트/.test(question)) return '건강';
  if (/돈|재물|투자|금전|사업|매출/.test(question)) return '금전';
  return '대인';
}

/**
 * Tarot Cohort 추출 (75개 = 3 × 5 × 5)
 */
export function extractTarotCohort(input: {
  spreadType?: string;
  question?: string;
  birthDate?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  return {
    spreadType: input.spreadType || 'single',
    questionCategory: classifyQuestionCategory(input.question),
    element: getElement(birthYear),
  };
}

/**
 * Family Cohort 추출 (80개 = 4 × 5 × 4)
 * fortune-family-* 공통 사용
 */
export function extractFamilyCohort(input: {
  relationship?: string;
  detailed_questions?: string[];
  concern_label?: string;
}): CohortData {
  const now = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Seoul" }));

  return {
    relationship: classifyFamilyRelationship(input.relationship),
    concernCategory: classifyFamilyConcern(input.detailed_questions, input.concern_label),
    season: getSeason(now.getMonth() + 1),
  };
}

function classifyFamilyRelationship(relationship?: string): string {
  if (!relationship) return '가족';
  if (/parent|부모/.test(relationship)) return '부모';
  if (/child|자녀/.test(relationship)) return '자녀';
  if (/spouse|배우자/.test(relationship)) return '배우자';
  if (/sibling|형제/.test(relationship)) return '형제';
  return '가족';
}

function classifyFamilyConcern(questions?: string[], label?: string): string {
  const combined = (questions || []).join(' ') + ' ' + (label || '');
  if (/couple|부부|배우자/.test(combined)) return '부부';
  if (/parent|child|부모|자녀/.test(combined)) return '부모자녀';
  if (/sibling|형제/.test(combined)) return '형제';
  if (/in_law|시댁|친정/.test(combined)) return '시댁친정';
  if (/conflict|갈등/.test(combined)) return '갈등';
  return '전체';
}

/**
 * Face Reading Cohort 추출 (120개 = 8 × 3 × 5)
 */
export function extractFaceReadingCohort(input: {
  faceShape?: string;
  gender?: string;
  birthDate?: string;
  age?: number;
}): CohortData {
  let ageGroup = '30대';
  if (input.age) {
    ageGroup = getAgeGroup(new Date(new Date().getFullYear() - input.age, 0, 1));
  } else if (input.birthDate) {
    ageGroup = getAgeGroup(input.birthDate);
  }

  return {
    faceShape: classifyFaceShape(input.faceShape),
    gender: input.gender === 'male' ? '남' : input.gender === 'female' ? '여' : '기타',
    ageGroup: ageGroup,
  };
}

function classifyFaceShape(shape?: string): string {
  if (!shape) return '타원형';
  if (/타원|oval/i.test(shape)) return '타원형';
  if (/둥근|round/i.test(shape)) return '둥근형';
  if (/각진|square/i.test(shape)) return '각진형';
  if (/긴|long/i.test(shape)) return '긴형';
  if (/하트|heart/i.test(shape)) return '하트형';
  if (/마름모|diamond/i.test(shape)) return '마름모형';
  if (/삼각|triangle/i.test(shape)) return '삼각형';
  if (/역삼각|inverted/i.test(shape)) return '역삼각형';
  return '타원형';
}

/**
 * New Year Cohort 추출 (84개 = 7 × 12)
 */
export function extractNewYearCohort(input: {
  goal?: string;
  birthDate?: string;
  zodiacAnimal?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;
  const zodiac = input.zodiacAnimal || getZodiacName(birthYear);

  // goal 정규화
  const goalMap: Record<string, string> = {
    'success': '성공',
    'love': '사랑',
    'wealth': '부자',
    'health': '건강',
    'growth': '성장',
    'travel': '여행',
    'peace': '평화',
  };

  return {
    goal: goalMap[input.goal || ''] || '성공',
    zodiac: zodiac,
  };
}

/**
 * Talisman Cohort 추출 (60개 = 12 × 5)
 */
export function extractTalismanCohort(input: {
  birthDate?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  return {
    zodiac: getZodiacName(birthYear),
    element: getElement(birthYear),
  };
}

/**
 * Pet Compatibility Cohort 추출 (180개 = 3 × 12 × 5)
 */
export function extractPetCompatibilityCohort(input: {
  petType?: string;
  birthDate?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  // petType 정규화
  const petMap: Record<string, string> = {
    'dog': '강아지',
    'cat': '고양이',
    'bird': '새',
    'fish': '물고기',
    'hamster': '햄스터',
    'rabbit': '토끼',
  };

  const pet = petMap[input.petType || ''] || input.petType || '강아지';
  const petCategory = /강아지|개|dog/i.test(pet) ? '개' :
                      /고양이|cat/i.test(pet) ? '고양이' : '기타';

  return {
    petCategory: petCategory,
    zodiac: getZodiacName(birthYear),
    element: getElement(birthYear),
  };
}

/**
 * Exam Cohort 추출 (180개 = 3 × 12 × 5)
 */
export function extractExamCohort(input: {
  examType?: string;
  birthDate?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  // examType 정규화
  const examMap: Record<string, string> = {
    'college': '수능',
    'job': '취업',
    'certification': '자격증',
    'promotion': '승진',
    'interview': '면접',
  };

  const examCategory = examMap[input.examType || ''] ||
    (/수능|대학|입시/.test(input.examType || '') ? '수능' :
     /취업|입사|면접/.test(input.examType || '') ? '취업' : '자격증');

  return {
    examCategory: examCategory,
    zodiac: getZodiacName(birthYear),
    element: getElement(birthYear),
  };
}

/**
 * Moving Cohort 추출 (240개 = 4 × 12 × 5)
 */
export function extractMovingCohort(input: {
  direction?: string;
  birthDate?: string;
}): CohortData {
  const birthYear = input.birthDate ? new Date(input.birthDate).getFullYear() : 2000;

  // 방향 정규화
  const directionCategory = /동|east/i.test(input.direction || '') ? '동' :
                            /서|west/i.test(input.direction || '') ? '서' :
                            /남|south/i.test(input.direction || '') ? '남' :
                            /북|north/i.test(input.direction || '') ? '북' : '동';

  return {
    direction: directionCategory,
    zodiac: getZodiacName(birthYear),
    element: getElement(birthYear),
  };
}

/**
 * Cohort 통계 조회
 */
export async function getCohortStats(
  supabase: SupabaseClient,
  fortuneType?: string
): Promise<Array<{ fortune_type: string; total_cohorts: number; total_results: number }>> {
  try {
    const { data, error } = await supabase.rpc('get_cohort_pool_stats', {
      p_fortune_type: fortuneType || null,
    });

    if (error) {
      console.error('[Cohort] 통계 조회 실패:', error);
      return [];
    }

    return data as Array<{ fortune_type: string; total_cohorts: number; total_results: number }>;
  } catch (e) {
    console.error('[Cohort] 통계 오류:', e);
    return [];
  }
}

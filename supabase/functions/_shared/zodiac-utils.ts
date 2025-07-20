// Zodiac animal utilities for age-based fortune generation

export const ZODIAC_ANIMALS = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'] as const;
export type ZodiacAnimal = typeof ZODIAC_ANIMALS[number];

// Get zodiac animal based on birth year
export function getZodiacAnimal(year: number): ZodiacAnimal {
  // 1900년이 쥐띠 기준
  const baseYear = 1900;
  const index = (year - baseYear) % 12;
  return ZODIAC_ANIMALS[index];
}

// Get all birth years for a specific zodiac animal within a range
export function getZodiacYears(zodiacAnimal: ZodiacAnimal, currentYear: number, minAge: number = 10, maxAge: number = 80): number[] {
  const zodiacIndex = ZODIAC_ANIMALS.indexOf(zodiacAnimal);
  const years: number[] = [];
  
  const minYear = currentYear - maxAge;
  const maxYear = currentYear - minAge;
  
  for (let year = minYear; year <= maxYear; year++) {
    if (getZodiacAnimal(year) === zodiacAnimal) {
      years.push(year);
    }
  }
  
  return years.sort((a, b) => b - a); // 최신 연도부터 정렬
}

// Get age group based on age
export function getAgeGroup(age: number): string {
  if (age < 10) return '10대 미만';
  if (age >= 10 && age < 20) return '10대';
  if (age >= 20 && age < 30) return '20대';
  if (age >= 30 && age < 40) return '30대';
  if (age >= 40 && age < 50) return '40대';
  if (age >= 50 && age < 60) return '50대';
  if (age >= 60 && age < 70) return '60대';
  if (age >= 70 && age < 80) return '70대';
  return '80대 이상';
}

// Get life concerns based on age group
export function getAgeConcerns(ageGroup: string): string {
  const concerns: Record<string, string> = {
    '10대 미만': '성장과 발달, 학습 습관 형성, 가족과의 유대',
    '10대': '학업 성적, 진로 탐색, 친구 관계, 대학 입시, 정체성 형성',
    '20대': '취업 준비, 첫 직장 적응, 연애와 결혼, 경제적 독립, 자아실현',
    '30대': '결혼과 출산, 육아, 커리어 성장, 내 집 마련, 자산 형성',
    '40대': '자녀 교육, 승진과 리더십, 건강 관리 시작, 노후 준비, 부모 부양',
    '50대': '은퇴 준비, 자녀 독립, 갱년기 건강, 제2의 인생 설계, 재테크',
    '60대': '은퇴 생활 적응, 건강 유지, 손주 돌봄, 여가 활동, 사회 공헌',
    '70대': '건강 관리 중심, 가족 화목, 여생 계획, 유산 정리, 정신적 안정',
    '80대 이상': '건강과 안전, 가족과의 시간, 편안한 노후, 인생 회고'
  };
  
  return concerns[ageGroup] || '일반적인 생활과 건강';
}

// Get age-specific fortune data structure
export interface AgeSpecificFortune {
  birthYear: number;
  age: number;
  ageGroup: string;
  concerns: string;
  zodiacAnimal: ZodiacAnimal;
}

// Get all age groups for a zodiac animal
export function getAgeGroupsForZodiac(zodiacAnimal: ZodiacAnimal, currentYear: number): AgeSpecificFortune[] {
  const years = getZodiacYears(zodiacAnimal, currentYear);
  
  return years.map(year => {
    const age = currentYear - year;
    const ageGroup = getAgeGroup(age);
    
    return {
      birthYear: year,
      age,
      ageGroup,
      concerns: getAgeConcerns(ageGroup),
      zodiacAnimal
    };
  });
}

// Generate cache key for zodiac age fortune
export function generateZodiacAgeCacheKey(zodiacAnimal: ZodiacAnimal, currentYear: number, date: Date): string {
  const dateStr = date.toISOString().split('T')[0];
  return `zodiac_age_${zodiacAnimal}_${currentYear}_${dateStr}`;
}

// Get major age groups for efficient generation (대표 연령대만 선택)
export function getMajorAgeGroupsForZodiac(zodiacAnimal: ZodiacAnimal, currentYear: number): AgeSpecificFortune[] {
  const allAgeGroups = getAgeGroupsForZodiac(zodiacAnimal, currentYear);
  const majorGroups: AgeSpecificFortune[] = [];
  const seenAgeGroups = new Set<string>();
  
  // 각 연령대별로 대표 연도 하나씩만 선택
  for (const group of allAgeGroups) {
    if (!seenAgeGroups.has(group.ageGroup)) {
      majorGroups.push(group);
      seenAgeGroups.add(group.ageGroup);
    }
  }
  
  return majorGroups;
}

// Format zodiac age key for fortune storage
export function formatZodiacAgeKey(zodiacAnimal: ZodiacAnimal, age: number): string {
  return `${zodiacAnimal}띠_${age}세`;
}

// Parse zodiac age key
export function parseZodiacAgeKey(key: string): { zodiac: string; age: number } | null {
  const match = key.match(/(.+)띠_(\d+)세/);
  if (match) {
    return {
      zodiac: match[1],
      age: parseInt(match[2], 10)
    };
  }
  return null;
}
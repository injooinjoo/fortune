import { UserInfo } from './user-storage';
import { FortuneCategory } from './types/fortune-system';

// 운세별 필수 필드 매핑
export const FORTUNE_REQUIRED_FIELDS: Record<FortuneCategory, (keyof UserInfo)[]> = {
  // 그룹 1: 평생 고정 정보
  'saju': ['name', 'birthDate', 'birthTime'],
  'traditional-saju': ['name', 'birthDate', 'birthTime'],
  'tojeong': ['name', 'birthDate', 'birthTime'],
  'past-life': ['name', 'birthDate'],
  'personality': ['name', 'birthDate', 'mbti'],
  'destiny': ['name', 'birthDate'],
  'talent': ['name', 'birthDate', 'mbti'],
  'saju-psychology': ['name', 'birthDate', 'mbti'],
  'network-report': ['name', 'birthDate', 'job'],
  
  // 그룹 2: 일일 정보
  'daily': ['name', 'birthDate'],
  'today': ['name', 'birthDate'],
  'tomorrow': ['name', 'birthDate'],
  'hourly': ['name', 'birthDate', 'birthTime'],
  'wealth': ['name', 'birthDate'],
  'love': ['name', 'birthDate', 'gender'],
  'career': ['name', 'birthDate', 'job'],
  'biorhythm': ['name', 'birthDate'],
  'zodiac-animal': ['name', 'birthDate'],
  'mbti': ['name', 'mbti'],
  'birth-season': ['name', 'birthDate'],
  'birthdate': ['name', 'birthDate'],
  'birthstone': ['name', 'birthDate'],
  'blood-type': ['name', 'bloodType'],
  'palmistry': ['name', 'birthDate'],
  'weekly': ['name', 'birthDate'],
  'monthly': ['name', 'birthDate'],
  'yearly': ['name', 'birthDate'],
  'zodiac': ['name', 'birthDate'],
  'lucky-items': ['name', 'birthDate'],
  'lucky-outfit': ['name', 'birthDate', 'gender'],
  'physiognomy': ['name', 'birthDate'],
  
  // 그룹 3: 실시간 상호작용
  'dream-interpretation': ['name', 'birthDate'],
  'tarot': ['name', 'birthDate'],
  'compatibility': ['name', 'birthDate', 'gender'],
  'worry-bead': ['name', 'birthDate'],
  
  // 그룹 5: 연애·인연 패키지
  'marriage': ['name', 'birthDate', 'birthTime', 'gender'],
  'blind-date': ['name', 'birthDate', 'gender', 'job', 'location'],
  'celebrity-match': ['name', 'birthDate', 'gender'],
  'couple-match': ['name', 'birthDate', 'gender'],
  'ex-lover': ['name', 'birthDate', 'gender'],
  'traditional-compatibility': ['name', 'birthDate', 'birthTime', 'gender'],
  'chemistry': ['name', 'birthDate', 'gender', 'mbti'],
  'celebrity': ['name', 'birthDate', 'gender'],
  'avoid-people': ['name', 'birthDate'],
  
  // 그룹 7: 행운 아이템 패키지
  'lucky-number': ['name', 'birthDate'],
  'lucky-color': ['name', 'birthDate'],
  'lucky-food': ['name', 'birthDate'],
  'talisman': ['name', 'birthDate'],
  'lucky-series': ['name', 'birthDate'],
  'lucky-exam': ['name', 'birthDate', 'job'],
  'lucky-cycling': ['name', 'birthDate', 'location'],
  'lucky-running': ['name', 'birthDate', 'location'],
  'lucky-hiking': ['name', 'birthDate', 'location'],
  'lucky-fishing': ['name', 'birthDate', 'location'],
  'lucky-swim': ['name', 'birthDate', 'location'],
  
  // 그룹 8: 인생·경력 패키지
  'employment': ['name', 'birthDate', 'job', 'mbti'],
  'moving': ['name', 'birthDate', 'location'],
  'moving-date': ['name', 'birthDate', 'location'],
  'new-year': ['name', 'birthDate'],
  'timeline': ['name', 'birthDate'],
  'wish': ['name', 'birthDate'],
  'five-blessings': ['name', 'birthDate', 'birthTime'],
  'salpuli': ['name', 'birthDate', 'birthTime']
};

// 모든 가능한 프로필 필드
export const ALL_PROFILE_FIELDS: (keyof UserInfo)[] = [
  'name',
  'birthDate', 
  'birthTime',
  'gender',
  'mbti',
  'bloodType',
  'zodiacSign',
  'job',
  'location'
];

// 필드 한국어 라벨
export const FIELD_LABELS: Record<keyof UserInfo, string> = {
  name: '이름',
  birthDate: '생년월일',
  birthTime: '출생시간',
  gender: '성별',
  mbti: 'MBTI',
  bloodType: '혈액형',
  zodiacSign: '별자리',
  job: '직업',
  location: '거주지'
};

// 프로필 완성도 체크 결과
export interface ProfileCompletenessResult {
  isComplete: boolean;
  missingFields: (keyof UserInfo)[];
  completionPercentage: number;
  requiredFieldsCount: number;
  completedFieldsCount: number;
}

// 특정 운세에 대한 프로필 완성도 체크
export function checkFortuneProfileCompleteness(
  userInfo: UserInfo,
  fortuneCategory: FortuneCategory
): ProfileCompletenessResult {
  const requiredFields = FORTUNE_REQUIRED_FIELDS[fortuneCategory] || [];
  
  const missingFields = requiredFields.filter(field => {
    const value = userInfo[field];
    return !value || value.trim() === '';
  });
  
  const completedFieldsCount = requiredFields.length - missingFields.length;
  const completionPercentage = requiredFields.length > 0 
    ? Math.round((completedFieldsCount / requiredFields.length) * 100)
    : 100;
  
  return {
    isComplete: missingFields.length === 0,
    missingFields,
    completionPercentage,
    requiredFieldsCount: requiredFields.length,
    completedFieldsCount
  };
}

// 전체 프로필 완성도 체크 (모든 필드 기준)
export function checkOverallProfileCompleteness(userInfo: UserInfo): ProfileCompletenessResult {
  const missingFields = ALL_PROFILE_FIELDS.filter(field => {
    const value = userInfo[field];
    return !value || value.trim() === '';
  });
  
  const completedFieldsCount = ALL_PROFILE_FIELDS.length - missingFields.length;
  const completionPercentage = Math.round((completedFieldsCount / ALL_PROFILE_FIELDS.length) * 100);
  
  return {
    isComplete: missingFields.length === 0,
    missingFields,
    completionPercentage,
    requiredFieldsCount: ALL_PROFILE_FIELDS.length,
    completedFieldsCount
  };
}

// 필수 필드만 완성도 체크 (이름, 생년월일)
export function checkEssentialProfileCompleteness(userInfo: UserInfo): ProfileCompletenessResult {
  const essentialFields: (keyof UserInfo)[] = ['name', 'birthDate'];
  
  const missingFields = essentialFields.filter(field => {
    const value = userInfo[field];
    return !value || value.trim() === '';
  });
  
  const completedFieldsCount = essentialFields.length - missingFields.length;
  const completionPercentage = Math.round((completedFieldsCount / essentialFields.length) * 100);
  
  return {
    isComplete: missingFields.length === 0,
    missingFields,
    completionPercentage,
    requiredFieldsCount: essentialFields.length,
    completedFieldsCount
  };
}

// 부족한 필드들의 한국어 라벨 반환
export function getMissingFieldLabels(missingFields: (keyof UserInfo)[]): string[] {
  return missingFields.map(field => FIELD_LABELS[field]);
}

// 운세 카테고리별 필요한 필드 가져오기
export function getRequiredFields(fortuneCategory: FortuneCategory): (keyof UserInfo)[] {
  return FORTUNE_REQUIRED_FIELDS[fortuneCategory] || [];
}

// 운세 카테고리별 필요한 필드의 한국어 라벨 가져오기
export function getRequiredFieldLabels(fortuneCategory: FortuneCategory): string[] {
  const fields = getRequiredFields(fortuneCategory);
  return fields.map(field => FIELD_LABELS[field]);
}

// 프로필 진행률에 따른 상태 메시지
export function getCompletionStatusMessage(percentage: number): string {
  if (percentage === 100) return '프로필이 완성되었습니다!';
  if (percentage >= 80) return '거의 완성되었습니다';
  if (percentage >= 60) return '프로필을 더 채워보세요';
  if (percentage >= 40) return '기본 정보를 입력해주세요';
  if (percentage >= 20) return '프로필 작성을 시작해보세요';
  return '프로필을 작성해주세요';
}

// 특정 운세를 이용하기 위한 가이드 메시지
export function getFortuneGuideMessage(
  fortuneCategory: FortuneCategory,
  missingFields: (keyof UserInfo)[]
): string {
  const missingLabels = getMissingFieldLabels(missingFields);
  
  if (missingLabels.length === 0) {
    return '모든 필수 정보가 입력되었습니다. 운세를 확인해보세요!';
  }
  
  if (missingLabels.length === 1) {
    return `${missingLabels[0]}을(를) 입력하면 ${FORTUNE_LABELS[fortuneCategory] || fortuneCategory} 운세를 확인할 수 있습니다.`;
  }
  
  return `${missingLabels.slice(0, -1).join(', ')} 및 ${missingLabels[missingLabels.length - 1]}을(를) 입력하면 ${FORTUNE_LABELS[fortuneCategory] || fortuneCategory} 운세를 확인할 수 있습니다.`;
}

// 운세 카테고리 한국어 라벨
const FORTUNE_LABELS: Partial<Record<FortuneCategory, string>> = {
  'saju': '사주',
  'traditional-saju': '전통 사주',
  'tojeong': '토정비결',
  'past-life': '전생',
  'personality': '성격분석',
  'destiny': '운명',
  'talent': '재능',
  'daily': '오늘의 운세',
  'today': '오늘',
  'tomorrow': '내일',
  'love': '연애운',
  'career': '직업운',
  'wealth': '재물운',
  'marriage': '결혼운',
  'blood-type': '혈액형',
  'mbti': 'MBTI',
  'lucky-hiking': '등산 행운',
  // 필요에 따라 더 추가...
};
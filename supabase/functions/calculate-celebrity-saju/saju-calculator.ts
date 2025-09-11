// 사주팔자 계산 TypeScript 함수

// 천간 (Heavenly Stems)
const HEAVENLY_STEMS = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
const HEAVENLY_STEMS_HANJA = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

// 지지 (Earthly Branches)  
const EARTHLY_BRANCHES = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
const EARTHLY_BRANCHES_HANJA = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

// 12지 동물
const ZODIAC_ANIMALS = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];

// 오행 (Five Elements)
const STEM_ELEMENTS: Record<string, string> = {
  '갑': '목', '을': '목',
  '병': '화', '정': '화',
  '무': '토', '기': '토',
  '경': '금', '신': '금',
  '임': '수', '계': '수'
};

const BRANCH_ELEMENTS: Record<string, string> = {
  '자': '수', '축': '토', '인': '목', '묘': '목',
  '진': '토', '사': '화', '오': '화', '미': '토',
  '신': '금', '유': '금', '술': '토', '해': '수'
};

interface SajuPillar {
  stem: string;
  branch: string;
  stemHanja: string;
  branchHanja: string;
  stemIndex: number;
  branchIndex: number;
}

interface SajuResult {
  year: SajuPillar;
  month: SajuPillar;
  day: SajuPillar;
  hour: SajuPillar | null;
  elementBalance: Record<string, number>;
  yearPillarString: string;
  monthPillarString: string;
  dayPillarString: string;
  hourPillarString: string | null;
  sajuString: string;
  dominantElement: string;
}

export function calculateSaju(
  birthDate: Date,
  birthTime: string | null = null
): SajuResult {
  // 년주 계산
  const yearPillar = calculateYearPillar(birthDate);
  
  // 월주 계산 (절기 고려)
  const monthPillar = calculateMonthPillar(birthDate, yearPillar.stemIndex);
  
  // 일주 계산
  const dayPillar = calculateDayPillar(birthDate);
  
  // 시주 계산
  const hourPillar = birthTime ? calculateHourPillar(birthTime, dayPillar.stemIndex) : null;
  
  // 오행 분석
  const elementBalance = analyzeElements(yearPillar, monthPillar, dayPillar, hourPillar);
  
  // 지배적인 오행 찾기
  const dominantElement = Object.entries(elementBalance)
    .reduce((a, b) => a[1] > b[1] ? a : b)[0];
  
  // 사주 문자열 생성
  const yearPillarString = yearPillar.stem + yearPillar.branch;
  const monthPillarString = monthPillar.stem + monthPillar.branch;
  const dayPillarString = dayPillar.stem + dayPillar.branch;
  const hourPillarString = hourPillar ? hourPillar.stem + hourPillar.branch : null;
  
  const sajuString = hourPillar
    ? `${yearPillarString} ${monthPillarString} ${dayPillarString} ${hourPillarString}`
    : `${yearPillarString} ${monthPillarString} ${dayPillarString}`;
  
  return {
    year: yearPillar,
    month: monthPillar,
    day: dayPillar,
    hour: hourPillar,
    elementBalance,
    yearPillarString,
    monthPillarString,
    dayPillarString,
    hourPillarString,
    sajuString,
    dominantElement
  };
}

// 년주 계산
function calculateYearPillar(date: Date): SajuPillar {
  // 입춘 기준으로 년도 조정 (대략 2월 4일)
  const lichun = new Date(date.getFullYear(), 1, 4); // 2월 4일
  const year = date < lichun ? date.getFullYear() - 1 : date.getFullYear();
  
  // 60갑자 순환
  const stemIndex = (year - 4) % 10;
  const branchIndex = (year - 4) % 12;
  
  // 음수 처리
  const finalStemIndex = stemIndex < 0 ? stemIndex + 10 : stemIndex;
  const finalBranchIndex = branchIndex < 0 ? branchIndex + 12 : branchIndex;
  
  return {
    stem: HEAVENLY_STEMS[finalStemIndex],
    branch: EARTHLY_BRANCHES[finalBranchIndex],
    stemHanja: HEAVENLY_STEMS_HANJA[finalStemIndex],
    branchHanja: EARTHLY_BRANCHES_HANJA[finalBranchIndex],
    stemIndex: finalStemIndex,
    branchIndex: finalBranchIndex
  };
}

// 월주 계산 (절기 기준)
function calculateMonthPillar(date: Date, yearStemIndex: number): SajuPillar {
  // 절기에 따른 월 계산
  const monthIndex = getMonthIndexBySolarTerm(date);
  
  // 월간 계산 공식: 년간에 따라 결정
  let monthStemStartIndex: number;
  switch (yearStemIndex % 5) {
    case 0: // 갑, 기
      monthStemStartIndex = 2; // 병
      break;
    case 1: // 을, 경
      monthStemStartIndex = 4; // 무
      break;
    case 2: // 병, 신
      monthStemStartIndex = 6; // 경
      break;
    case 3: // 정, 임
      monthStemStartIndex = 8; // 임
      break;
    case 4: // 무, 계
      monthStemStartIndex = 0; // 갑
      break;
    default:
      monthStemStartIndex = 0;
  }
  
  const stemIndex = (monthStemStartIndex + monthIndex) % 10;
  const branchIndex = (monthIndex + 2) % 12; // 인월부터 시작
  
  return {
    stem: HEAVENLY_STEMS[stemIndex],
    branch: EARTHLY_BRANCHES[branchIndex],
    stemHanja: HEAVENLY_STEMS_HANJA[stemIndex],
    branchHanja: EARTHLY_BRANCHES_HANJA[branchIndex],
    stemIndex,
    branchIndex
  };
}

// 절기에 따른 월 인덱스 계산
function getMonthIndexBySolarTerm(date: Date): number {
  const month = date.getMonth() + 1;
  const day = date.getDate();
  
  if (month === 1 || (month === 2 && day < 4)) {
    return 11; // 축월 (12월)
  } else if (month === 2 || (month === 3 && day < 6)) {
    return 0; // 인월 (1월)
  } else if (month === 3 || (month === 4 && day < 5)) {
    return 1; // 묘월 (2월)
  } else if (month === 4 || (month === 5 && day < 6)) {
    return 2; // 진월 (3월)
  } else if (month === 5 || (month === 6 && day < 6)) {
    return 3; // 사월 (4월)
  } else if (month === 6 || (month === 7 && day < 7)) {
    return 4; // 오월 (5월)
  } else if (month === 7 || (month === 8 && day < 8)) {
    return 5; // 미월 (6월)
  } else if (month === 8 || (month === 9 && day < 8)) {
    return 6; // 신월 (7월)
  } else if (month === 9 || (month === 10 && day < 8)) {
    return 7; // 유월 (8월)
  } else if (month === 10 || (month === 11 && day < 8)) {
    return 8; // 술월 (9월)
  } else if (month === 11 || (month === 12 && day < 7)) {
    return 9; // 해월 (10월)
  } else {
    return 10; // 자월 (11월)
  }
}

// 일주 계산 (만세력 기준)
function calculateDayPillar(date: Date): SajuPillar {
  // 기준일: 1900년 1월 1일은 갑진일
  const baseDate = new Date(1900, 0, 1);
  const daysDiff = Math.floor((date.getTime() - baseDate.getTime()) / (1000 * 60 * 60 * 24));
  
  // 60갑자 순환
  const dayNumber = (daysDiff + 40) % 60; // 갑진일이 40번째
  const stemIndex = dayNumber % 10;
  const branchIndex = dayNumber % 12;
  
  return {
    stem: HEAVENLY_STEMS[stemIndex],
    branch: EARTHLY_BRANCHES[branchIndex],
    stemHanja: HEAVENLY_STEMS_HANJA[stemIndex],
    branchHanja: EARTHLY_BRANCHES_HANJA[branchIndex],
    stemIndex,
    branchIndex
  };
}

// 시주 계산
function calculateHourPillar(birthTime: string, dayStemIndex: number): SajuPillar | null {
  // 시간 파싱
  const parts = birthTime.split(':');
  if (parts.length < 2) return null;
  
  const hour = parseInt(parts[0]) || 0;
  const minute = parseInt(parts[1]) || 0;
  
  // 시진 계산 (2시간 단위)
  const hourIndex = getHourIndex(hour, minute);
  
  // 시간 계산 공식: 일간에 따라 결정
  let hourStemStartIndex: number;
  switch (dayStemIndex % 5) {
    case 0: // 갑, 기
      hourStemStartIndex = 0; // 갑
      break;
    case 1: // 을, 경
      hourStemStartIndex = 2; // 병
      break;
    case 2: // 병, 신
      hourStemStartIndex = 4; // 무
      break;
    case 3: // 정, 임
      hourStemStartIndex = 6; // 경
      break;
    case 4: // 무, 계
      hourStemStartIndex = 8; // 임
      break;
    default:
      hourStemStartIndex = 0;
  }
  
  const stemIndex = (hourStemStartIndex + hourIndex) % 10;
  
  return {
    stem: HEAVENLY_STEMS[stemIndex],
    branch: EARTHLY_BRANCHES[hourIndex],
    stemHanja: HEAVENLY_STEMS_HANJA[stemIndex],
    branchHanja: EARTHLY_BRANCHES_HANJA[hourIndex],
    stemIndex,
    branchIndex: hourIndex
  };
}

// 시진 인덱스 계산
function getHourIndex(hour: number, minute: number): number {
  // 자시(23:00-01:00)부터 시작
  if (hour >= 23 || hour < 1) return 0;  // 자시
  if (hour >= 1 && hour < 3) return 1;   // 축시
  if (hour >= 3 && hour < 5) return 2;   // 인시
  if (hour >= 5 && hour < 7) return 3;   // 묘시
  if (hour >= 7 && hour < 9) return 4;   // 진시
  if (hour >= 9 && hour < 11) return 5;  // 사시
  if (hour >= 11 && hour < 13) return 6; // 오시
  if (hour >= 13 && hour < 15) return 7; // 미시
  if (hour >= 15 && hour < 17) return 8; // 신시
  if (hour >= 17 && hour < 19) return 9; // 유시
  if (hour >= 19 && hour < 21) return 10;// 술시
  if (hour >= 21 && hour < 23) return 11;// 해시
  return 0;
}

// 오행 분석
function analyzeElements(
  year: SajuPillar,
  month: SajuPillar,
  day: SajuPillar,
  hour: SajuPillar | null
): Record<string, number> {
  const elements: Record<string, number> = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};
  
  // 년주 오행
  elements[STEM_ELEMENTS[year.stem]]++;
  elements[BRANCH_ELEMENTS[year.branch]]++;
  
  // 월주 오행
  elements[STEM_ELEMENTS[month.stem]]++;
  elements[BRANCH_ELEMENTS[month.branch]]++;
  
  // 일주 오행
  elements[STEM_ELEMENTS[day.stem]]++;
  elements[BRANCH_ELEMENTS[day.branch]]++;
  
  // 시주 오행
  if (hour) {
    elements[STEM_ELEMENTS[hour.stem]]++;
    elements[BRANCH_ELEMENTS[hour.branch]]++;
  }
  
  return elements;
}
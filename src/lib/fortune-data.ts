export const FORTUNE_TYPES = [
  // 데일리 운세
  "daily", "today", "tomorrow", "hourly",
  
  // 전통 사주
  "saju", "traditional-saju", "saju-psychology", "tojeong", "salpuli", "palmistry",
  
  // MBTI & 성격 분석
  "mbti", "personality", "blood-type", 
  
  // 별자리 & 띠 운세
  "zodiac", "zodiac-animal", "birth-season", "birthstone", "birthdate",
  
  // 연애 & 인연
  "love", "destiny", "marriage", "couple-match", "compatibility", "traditional-compatibility", 
  "blind-date", "ex-lover", "celebrity-match", "chemistry",
  
  // 취업 & 사업
  "career", "employment", "business", "startup", "lucky-job",
  
  // 재물 & 투자
  "wealth", "lucky-investment", "lucky-realestate", "lucky-sidejob",
  
  // 건강 & 라이프
  "biorhythm", "moving", "moving-date", "avoid-people",
  
  // 스포츠 & 액티비티
  "lucky-hiking", "lucky-cycling", "lucky-running", "lucky-swim", 
  "lucky-tennis", "lucky-golf", "lucky-baseball", "lucky-fishing",
  
  // 행운 아이템
  "lucky-color", "lucky-number", "lucky-items", "lucky-outfit", 
  "lucky-food", "lucky-exam", "talisman",
  
  // 특별 운세
  "new-year", "past-life", "talent", "five-blessings", "network-report", 
  "timeline", "wish"
] as const;

export type FortuneType = typeof FORTUNE_TYPES[number];

export const FORTUNE_CATEGORIES = [
  { id: 'all', name: '전체', icon: 'Star', color: 'purple' },
  { id: 'daily', name: '데일리', icon: 'Calendar', color: 'blue' },
  { id: 'love', name: '연애·인연', icon: 'Heart', color: 'pink' },
  { id: 'career', name: '취업·사업', icon: 'Briefcase', color: 'blue' },
  { id: 'money', name: '재물·투자', icon: 'Coins', color: 'yellow' },
  { id: 'health', name: '건강·라이프', icon: 'Sparkles', color: 'green' },
  { id: 'traditional', name: '전통·사주', icon: 'ScrollText', color: 'amber' },
  { id: 'lifestyle', name: '생활·운세', icon: 'Calendar', color: 'teal' },
  { id: 'lucky-items', name: '행운 아이템', icon: 'Crown', color: 'purple' },
  { id: 'interactive', name: '인터랙티브', icon: 'Wand2', color: 'indigo' }
] as const;

export type FortuneCategoryType = typeof FORTUNE_CATEGORIES[number]['id'];

export const FORTUNE_METADATA: Record<FortuneType, {
  title: string;
  description: string;
  category: FortuneCategoryType;
  icon: string;
  color: string;
  difficulty: 'easy' | 'medium' | 'hard';
  timeToComplete: string;
  tags: string[];
}> = {
  // 데일리 운세
  "daily": {
    title: "오늘의 운세",
    description: "총운, 애정운, 재물운, 건강운을 한 번에",
    category: "daily",
    icon: "Star",
    color: "emerald",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["데일리", "종합운세", "인기"]
  },
  "today": {
    title: "오늘 총운",
    description: "오늘 하루의 전반적인 운세를 확인하세요",
    category: "daily", 
    icon: "Sun",
    color: "yellow",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["오늘", "총운", "기본"]
  },
  "tomorrow": {
    title: "내일의 운세",
    description: "내일의 흐름을 미리 살펴보세요",
    category: "daily",
    icon: "Sunrise",
    color: "sky",
    difficulty: "easy", 
    timeToComplete: "1분",
    tags: ["내일", "미리보기"]
  },
  "hourly": {
    title: "시간별 운세",
    description: "하루 24시간의 운세 변화를 확인하세요",
    category: "daily",
    icon: "Clock",
    color: "blue",
    difficulty: "medium",
    timeToComplete: "2분",
    tags: ["시간별", "상세분석"]
  },

  // 전통 사주
  "saju": {
    title: "사주팔자",
    description: "정통 사주로 인생의 큰 흐름을 파악하세요",
    category: "traditional",
    icon: "Calendar",
    color: "purple",
    difficulty: "hard",
    timeToComplete: "5분",
    tags: ["전통", "심층분석", "정통"]
  },
  "traditional-saju": {
    title: "전통 사주",
    description: "고전적인 방식의 사주 해석",
    category: "traditional",
    icon: "ScrollText", 
    color: "amber",
    difficulty: "hard",
    timeToComplete: "7분",
    tags: ["전통", "고전", "상세"]
  },
  "saju-psychology": {
    title: "사주 심리분석",
    description: "타고난 성격과 관계를 심층 탐구",
    category: "traditional",
    icon: "Brain",
    color: "teal",
    difficulty: "medium",
    timeToComplete: "4분",
    tags: ["심리", "성격분석", "신규"]
  },
  "tojeong": {
    title: "토정비결",
    description: "144괘로 풀이하는 신년 길흉",
    category: "traditional",
    icon: "ScrollText",
    color: "amber",
    difficulty: "medium", 
    timeToComplete: "3분",
    tags: ["전통", "신년", "괘"]
  },
  "salpuli": {
    title: "살풀이",
    description: "흉살을 알고 대비하는 길을 찾아보세요",
    category: "traditional",
    icon: "ShieldAlert",
    color: "red",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["살풀이", "대비", "조화"]
  },
  "palmistry": {
    title: "손금",
    description: "손에 새겨진 인생의 지도를 읽어보세요",
    category: "traditional", 
    icon: "Hand",
    color: "amber",
    difficulty: "medium",
    timeToComplete: "4분",
    tags: ["손금", "전통", "인생"]
  },

  // MBTI & 성격
  "mbti": {
    title: "MBTI 운세",
    description: "성격 유형별 맞춤 운세를 받아보세요",
    category: "lifestyle",
    icon: "User",
    color: "violet",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["MBTI", "성격", "맞춤"]
  },
  "personality": {
    title: "성격 분석",
    description: "나의 성격 유형과 특성을 알아보세요",
    category: "lifestyle",
    icon: "Brain",
    color: "purple",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["성격", "분석", "자아"]
  },
  "blood-type": {
    title: "혈액형 궁합",
    description: "혈액형으로 보는 성격 궁합",
    category: "love",
    icon: "Droplet",
    color: "red",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["혈액형", "궁합", "간단"]
  },

  // 별자리 & 띠
  "zodiac": {
    title: "별자리 운세",
    description: "12별자리로 보는 이달의 운세",
    category: "lifestyle",
    icon: "Stars",
    color: "indigo",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["별자리", "서양점성술"]
  },
  "zodiac-animal": {
    title: "띠 운세",
    description: "12간지로 보는 이달의 운세를 확인하세요",
    category: "lifestyle",
    icon: "Crown",
    color: "orange",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["띠", "12간지", "전통"]
  },
  "birth-season": {
    title: "태어난 계절 운세",
    description: "태어난 계절로 알아보는 성격과 운세",
    category: "lifestyle",
    icon: "Leaf",
    color: "green",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["계절", "성격", "간단"]
  },
  "birthstone": {
    title: "탄생석 운세",
    description: "탄생월 보석이 가져다주는 행운",
    category: "lucky-items",
    icon: "Gem",
    color: "pink",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["탄생석", "보석", "행운"]
  },
  "birthdate": {
    title: "생년월일 운세",
    description: "간단한 생년월일 운세를 확인하세요",
    category: "lifestyle",
    icon: "Cake",
    color: "cyan",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["생년월일", "간단", "기본"]
  },

  // 연애 & 인연  
  "love": {
    title: "연애운",
    description: "사랑과 인연의 흐름을 확인하세요",
    category: "love",
    icon: "Heart",
    color: "pink",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["연애", "사랑", "인기"]
  },
  "destiny": {
    title: "인연운",
    description: "앞으로 만나게 될 인연의 흐름을 알아보세요",
    category: "love",
    icon: "Users",
    color: "fuchsia",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["인연", "만남", "NEW"]
  },
  "marriage": {
    title: "결혼운",
    description: "평생의 동반자와의 인연을 확인하세요",
    category: "love",
    icon: "Heart",
    color: "rose",
    difficulty: "medium",
    timeToComplete: "4분",
    tags: ["결혼", "동반자", "특별"]
  },
  "couple-match": {
    title: "커플 궁합",
    description: "현재 연인의 관계 흐름과 미래를 알아보세요",
    category: "love",
    icon: "Heart",
    color: "rose",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["커플", "궁합", "NEW"]
  },
  "compatibility": {
    title: "궁합",
    description: "두 사람의 궁합을 확인하세요",
    category: "love",
    icon: "Users",
    color: "pink",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["궁합", "관계"]
  },
  "traditional-compatibility": {
    title: "전통 궁합",
    description: "정통 방식으로 보는 궁합",
    category: "love",
    icon: "ScrollText",
    color: "amber",
    difficulty: "hard",
    timeToComplete: "5분",
    tags: ["전통", "궁합", "정통"]
  },
  "blind-date": {
    title: "소개팅운",
    description: "새로운 만남의 가능성을 확인하세요",
    category: "love",
    icon: "Coffee",
    color: "orange",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["소개팅", "만남"]
  },
  "ex-lover": {
    title: "전 연인 관계",
    description: "과거 관계와의 정리 방법을 알아보세요",
    category: "love",
    icon: "RotateCcw",
    color: "gray",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["전연인", "정리", "상담"]
  },
  "celebrity-match": {
    title: "연예인 궁합",
    description: "좋아하는 연예인과의 궁합을 확인하세요",
    category: "love",
    icon: "Star",
    color: "gold",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["연예인", "재미", "특별"]
  },
  "chemistry": {
    title: "케미스트리",
    description: "상대방과의 화학적 궁합을 분석하세요",
    category: "love",
    icon: "Zap",
    color: "electric",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["케미", "궁합", "분석"]
  },

  // 취업 & 사업
  "career": {
    title: "취업운",
    description: "커리어와 성공의 길을 찾아보세요",
    category: "career",
    icon: "Briefcase",
    color: "blue",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["취업", "커리어"]
  },
  "employment": {
    title: "취업 운세",
    description: "시즌별 취업 성공 가능성을 살펴보세요",
    category: "career",
    icon: "Briefcase",
    color: "indigo",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["취업", "성공", "시즌"]
  },
  "business": {
    title: "사업운",
    description: "성공적인 창업과 사업 운영을 위한 운세를 확인하세요",
    category: "career",
    icon: "TrendingUp",
    color: "indigo",
    difficulty: "hard",
    timeToComplete: "5분",
    tags: ["사업", "창업", "추천"]
  },
  "startup": {
    title: "창업운",
    description: "어떤 업종이 잘 맞는지, 시작 시기를 알아보세요",
    category: "career",
    icon: "Rocket",
    color: "orange",
    difficulty: "hard",
    timeToComplete: "5분",
    tags: ["창업", "업종", "NEW"]
  },
  "lucky-job": {
    title: "행운의 직업",
    description: "나에게 맞는 직업과 업무 환경을 찾아보세요",
    category: "career",
    icon: "Target",
    color: "blue",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["직업", "적성", "행운"]
  },

  // 재물 & 투자
  "wealth": {
    title: "금전운",
    description: "재물과 투자의 운을 살펴보세요",
    category: "money",
    icon: "Coins",
    color: "yellow",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["금전", "재물"]
  },
  "lucky-investment": {
    title: "행운의 투자",
    description: "투자 성공을 위한 운세를 확인하세요",
    category: "money",
    icon: "TrendingUp",
    color: "green",
    difficulty: "hard",
    timeToComplete: "4분",
    tags: ["투자", "재테크", "행운"]
  },
  "lucky-realestate": {
    title: "행운의 부동산",
    description: "부동산 투자와 거래의 운을 확인하세요",
    category: "money",
    icon: "Home",
    color: "emerald",
    difficulty: "hard",
    timeToComplete: "4분",
    tags: ["부동산", "투자", "거래"]
  },
  "lucky-sidejob": {
    title: "행운의 부업",
    description: "나에게 맞는 부업과 수익 창출 방법을 알아보세요",
    category: "money",
    icon: "PlusCircle",
    color: "green",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["부업", "수익", "NEW"]
  },

  // 건강 & 라이프
  "biorhythm": {
    title: "바이오리듬",
    description: "신체, 감정, 지적 리듬을 확인하세요",
    category: "health",
    icon: "Activity",
    color: "green",
    difficulty: "medium",
    timeToComplete: "2분",
    tags: ["바이오리듬", "건강", "리듬"]
  },
  "moving": {
    title: "이사운",
    description: "새로운 보금자리로의 행복한 이주를 확인하세요",
    category: "health",
    icon: "Home",
    color: "emerald",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["이사", "주거", "인기"]
  },
  "moving-date": {
    title: "이사 날짜",
    description: "이사하기 좋은 날짜를 찾아보세요",
    category: "health",
    icon: "Calendar",
    color: "blue",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["이사날짜", "택일"]
  },
  "avoid-people": {
    title: "꺼려야 할 사람",
    description: "피해야 할 인물 유형을 알아보세요",
    category: "health",
    icon: "UserX",
    color: "red",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["인간관계", "주의", "조심"]
  },

  // 스포츠 & 액티비티
  "lucky-hiking": {
    title: "행운의 등산",
    description: "등산을 통해 보는 당신의 운세와 안전한 완주의 비결",
    category: "health",
    icon: "Mountain",
    color: "green",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["등산", "건강", "자연"]
  },
  "lucky-cycling": {
    title: "행운의 자전거",
    description: "자전거로 만나는 행운과 건강한 라이딩 코스",
    category: "health",
    icon: "Bike",
    color: "blue",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["자전거", "라이딩", "건강"]
  },
  "lucky-running": {
    title: "행운의 러닝",
    description: "달리기를 통한 건강과 행운을 찾아보세요",
    category: "health",
    icon: "Footprints",
    color: "orange",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["러닝", "달리기", "건강"]
  },
  "lucky-swim": {
    title: "행운의 수영",
    description: "수영으로 얻는 건강과 정신적 안정",
    category: "health",
    icon: "Waves",
    color: "blue",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["수영", "물", "건강"]
  },
  "lucky-tennis": {
    title: "행운의 테니스",
    description: "테니스를 통한 사교와 건강 운세",
    category: "health",
    icon: "Target",
    color: "green",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["테니스", "사교", "스포츠"]
  },
  "lucky-golf": {
    title: "행운의 골프",
    description: "골프를 통한 비즈니스와 인맥 확장",
    category: "health",
    icon: "Target",
    color: "emerald",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["골프", "비즈니스", "인맥"]
  },
  "lucky-baseball": {
    title: "행운의 야구",
    description: "야구를 통한 팀워크와 승부운",
    category: "health",
    icon: "Circle",
    color: "blue",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["야구", "팀워크", "스포츠"]
  },
  "lucky-fishing": {
    title: "행운의 낚시",
    description: "낚시를 통한 평온과 인내심",
    category: "health",
    icon: "Fish",
    color: "teal",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["낚시", "평온", "자연"]
  },

  // 행운 아이템
  "lucky-color": {
    title: "행운의 색깔",
    description: "마음을 위로하는 당신만의 색깔을 찾아보세요",
    category: "lucky-items",
    icon: "Palette",
    color: "purple",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["색깔", "치유", "심리"]
  },
  "lucky-number": {
    title: "행운의 숫자",
    description: "당신에게 행운을 가져다주는 숫자를 찾아보세요",
    category: "lucky-items",
    icon: "Hash",
    color: "blue",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["숫자", "행운", "기본"]
  },
  "lucky-items": {
    title: "행운의 아이템",
    description: "당신에게 필요한 행운의 물건을 찾아보세요",
    category: "lucky-items",
    icon: "Gift",
    color: "purple",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["아이템", "물건", "행운"]
  },
  "lucky-outfit": {
    title: "행운의 옷차림",
    description: "오늘 입으면 좋은 옷 스타일을 추천받으세요",
    category: "lucky-items",
    icon: "Shirt",
    color: "pink",
    difficulty: "easy",
    timeToComplete: "1분",
    tags: ["패션", "옷차림", "스타일"]
  },
  "lucky-food": {
    title: "행운의 음식",
    description: "건강과 행운을 가져다주는 음식을 알아보세요",
    category: "lucky-items",
    icon: "UtensilsCrossed",
    color: "orange",
    difficulty: "easy",
    timeToComplete: "2분",
    tags: ["음식", "건강", "영양"]
  },
  "lucky-exam": {
    title: "행운의 시험",
    description: "시험과 면접에서 성공하는 방법을 알아보세요",
    category: "lucky-items",
    icon: "BookOpen",
    color: "blue",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["시험", "공부", "성공"]
  },
  "talisman": {
    title: "행운의 부적",
    description: "원하는 소망을 담은 부적을 만들어보세요",
    category: "lucky-items",
    icon: "Shield",
    color: "gold",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["부적", "소망", "신규"]
  },

  // 특별 운세
  "new-year": {
    title: "신년운세",
    description: "새해 한 해의 흐름을 미리 확인하세요",
    category: "lifestyle",
    icon: "PartyPopper",
    color: "indigo",
    difficulty: "hard",
    timeToComplete: "5분",
    tags: ["신년", "새해", "2025"]
  },
  "past-life": {
    title: "전생운",
    description: "과거 생의 직업과 성격을 알아보세요",
    category: "lifestyle",
    icon: "History",
    color: "indigo",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["전생", "과거", "신비"]
  },
  "talent": {
    title: "재능 운세",
    description: "사주로 알아보는 나의 숨은 재능",
    category: "lifestyle",
    icon: "Star",
    color: "green",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["재능", "능력", "신규"]
  },
  "five-blessings": {
    title: "오복운",
    description: "타고난 오복의 균형을 살펴보세요",
    category: "lifestyle",
    icon: "Crown",
    color: "teal",
    difficulty: "medium",
    timeToComplete: "4분",
    tags: ["오복", "균형", "추천"]
  },
  "network-report": {
    title: "인맥 리포트",
    description: "사회적 관계와 네트워킹 능력을 분석하세요",
    category: "lifestyle",
    icon: "Users",
    color: "blue",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["인맥", "네트워킹", "관계"]
  },
  "timeline": {
    title: "인생 타임라인",
    description: "인생의 중요한 전환점들을 미리 확인하세요",
    category: "lifestyle",
    icon: "Timeline",
    color: "purple",
    difficulty: "hard",
    timeToComplete: "5분",
    tags: ["인생", "타임라인", "미래"]
  },
  "wish": {
    title: "소원 운세",
    description: "간절한 소원이 이뤄질 가능성을 확인하세요",
    category: "lifestyle",
    icon: "Heart",
    color: "pink",
    difficulty: "medium",
    timeToComplete: "3분",
    tags: ["소원", "꿈", "희망"]
  }
};

export const MBTI_TYPES = [
  "ISTJ", "ISFJ", "INFJ", "INTJ",
  "ISTP", "ISFP", "INFP", "INTP",
  "ESTP", "ESFP", "ENFP", "ENTP",
  "ESTJ", "ESFJ", "ENFJ", "ENTJ"
] as const;

export type MbtiType = typeof MBTI_TYPES[number];

export const GENDERS = [
  { value: "여성", label: "여성" },
  { value: "남성", label: "남성" },
  { value: "선택 안함", label: "선택 안함" },
] as const;

export type GenderValue = typeof GENDERS[number]['value'];

export const BIRTH_TIMES = [
  { value: "모름", label: "모름" },
  { value: "자시 (23:30 ~ 01:29)", label: "자시 (23:30 ~ 01:29)" },
  { value: "축시 (01:30 ~ 03:29)", label: "축시 (01:30 ~ 03:29)" },
  { value: "인시 (03:30 ~ 05:29)", label: "인시 (03:30 ~ 05:29)" },
  { value: "묘시 (05:30 ~ 07:29)", label: "묘시 (05:30 ~ 07:29)" },
  { value: "진시 (07:30 ~ 09:29)", label: "진시 (07:30 ~ 09:29)" },
  { value: "사시 (09:30 ~ 11:29)", label: "사시 (09:30 ~ 11:29)" },
  { value: "오시 (11:30 ~ 13:29)", label: "오시 (11:30 ~ 13:29)" },
  { value: "미시 (13:30 ~ 15:29)", label: "미시 (13:30 ~ 15:29)" },
  { value: "신시 (15:30 ~ 17:29)", label: "신시 (15:30 ~ 17:29)" },
  { value: "유시 (17:30 ~ 19:29)", label: "유시 (17:30 ~ 19:29)" },
  { value: "술시 (19:30 ~ 21:29)", label: "술시 (19:30 ~ 21:29)" },
  { value: "해시 (21:30 ~ 23:29)", label: "해시 (21:30 ~ 23:29)" },
] as const;

export type BirthTimeValue = typeof BIRTH_TIMES[number]['value'];

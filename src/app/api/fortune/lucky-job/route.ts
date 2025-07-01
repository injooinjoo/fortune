import { NextRequest, NextResponse } from 'next/server';

interface JobInfo {
  name: string;
  birth_date: string;
  mbti?: string;
  current_position?: string;
  job_experience?: string;
  preferred_fields?: string[];
  work_style?: string;
  salary_expectations?: string;
  career_goals?: string;
  skills?: string[];
  education?: string;
  location_preference?: string;
}

interface JobFortune {
  overall_luck: number;
  career_luck: number;
  interview_luck: number;
  networking_luck: number;
  learning_luck: number;
  recommended_jobs: {
    best_match: {
      field: string;
      position: string;
      compatibility: number;
      reasons: string[];
    };
    good_matches: Array<{
      field: string;
      position: string;
      compatibility: number;
      strengths: string;
    }>;
    challenging_fields: Array<{
      field: string;
      compatibility: number;
      challenges: string;
    }>;
  };
  lucky_elements: {
    time: string;
    day: string;
    color: string;
    keyword: string;
    network_person: string;
  };
  mbti_analysis?: {
    strengths: string[];
    suitable_environments: string[];
    leadership_style: string;
    communication_style: string;
  };
  skill_recommendations: string[];
  timing_advice: {
    job_search: string;
    interview_period: string;
    career_change: string;
  };
  personalized_advice: {
    strengths: string;
    development_areas: string;
    networking_tips: string;
    interview_tips: string;
  };
  success_factors: string[];
  warning_signs: string[];
}

export async function POST(request: NextRequest) {
  try {
    const jobInfo: JobInfo = await request.json();
    
    // 필수 필드 검증
    if (!jobInfo.name || !jobInfo.birth_date) {
      return NextResponse.json(
        { error: '이름과 생년월일은 필수 항목입니다.' },
        { status: 400 }
      );
    }

    // MBTI 검증
    if (jobInfo.mbti && !/^[EINT][SN][TF][JP]$/i.test(jobInfo.mbti)) {
      return NextResponse.json(
        { error: 'MBTI는 올바른 형식으로 입력해주세요. (예: ENFP)' },
        { status: 400 }
      );
    }

    const jobFortune = await analyzeJobFortune(jobInfo);
    return NextResponse.json(jobFortune);
    
  } catch (error) {
    console.error('Lucky job API error:', error);
    return NextResponse.json(
      { error: '직업 운세 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

async function analyzeJobFortune(info: JobInfo): Promise<JobFortune> {
  // 생년월일 기반 기본 점수 계산
  const birthYear = parseInt(info.birth_date.substring(0, 4));
  const birthMonth = parseInt(info.birth_date.substring(5, 7));
  const birthDay = parseInt(info.birth_date.substring(8, 10));
  
  const baseScore = ((birthYear + birthMonth + birthDay) % 30) + 60;
  
  // 경력별 점수 조정
  let experienceBonus = 0;
  switch (info.job_experience) {
    case '10년 이상':
      experienceBonus = 15;
      break;
    case '5-10년':
      experienceBonus = 10;
      break;
    case '3-5년':
      experienceBonus = 5;
      break;
    case '1-3년':
      experienceBonus = 0;
      break;
    case '신입':
      experienceBonus = -5;
      break;
    default:
      experienceBonus = 0;
  }

  // MBTI 기반 점수 조정
  let mbtiBonus = 0;
  if (info.mbti) {
    const mbtiUpper = info.mbti.toUpperCase();
    // E형: 네트워킹 유리, I형: 깊이 있는 업무 유리
    if (mbtiUpper.startsWith('E')) mbtiBonus += 5;
    if (mbtiUpper.startsWith('I')) mbtiBonus += 3;
    // N형: 창의적 직종 유리
    if (mbtiUpper.includes('N')) mbtiBonus += 8;
    // T형: 논리적 업무 유리, F형: 사람 중심 업무 유리
    if (mbtiUpper.includes('T')) mbtiBonus += 5;
    if (mbtiUpper.includes('F')) mbtiBonus += 6;
    // J형: 체계적 업무 유리
    if (mbtiUpper.endsWith('J')) mbtiBonus += 4;
  }

  // 선호 분야 다양성 보너스
  const fieldBonus = info.preferred_fields ? Math.min(info.preferred_fields.length * 2, 10) : 0;

  // 스킬 보유 보너스
  const skillBonus = info.skills ? Math.min(info.skills.length * 3, 15) : 0;

  const overallLuck = Math.max(45, Math.min(98, baseScore + experienceBonus + mbtiBonus + fieldBonus + skillBonus));

  // MBTI 기반 직업 분석
  const mbtiAnalysis = info.mbti ? analyzeMBTIForJob(info.mbti) : undefined;

  // 추천 직업 생성
  const recommendedJobs = generateJobRecommendations(info, overallLuck);

  // 행운 요소 계산
  const luckyElements = calculateLuckyElements(birthDay, birthMonth);

  // 타이밍 조언
  const timingAdvice = generateTimingAdvice(birthMonth, info.job_experience);

  return {
    overall_luck: overallLuck,
    career_luck: Math.max(40, Math.min(95, overallLuck + Math.floor(Math.random() * 10) - 5)),
    interview_luck: Math.max(50, Math.min(100, overallLuck + Math.floor(Math.random() * 15) - 7)),
    networking_luck: Math.max(45, Math.min(95, overallLuck + Math.floor(Math.random() * 12) - 6)),
    learning_luck: Math.max(55, Math.min(100, overallLuck + Math.floor(Math.random() * 8) - 4)),
    recommended_jobs: recommendedJobs,
    lucky_elements: luckyElements,
    mbti_analysis: mbtiAnalysis,
    skill_recommendations: generateSkillRecommendations(info),
    timing_advice: timingAdvice,
    personalized_advice: generatePersonalizedAdvice(info, overallLuck),
    success_factors: generateSuccessFactors(info),
    warning_signs: generateWarningSignsForJob(info)
  };
}

function analyzeMBTIForJob(mbti: string): JobFortune['mbti_analysis'] {
  const mbtiUpper = mbti.toUpperCase();
  
  const analyses: Record<string, JobFortune['mbti_analysis']> = {
    'ENFP': {
      strengths: ['창의성', '열정적 소통', '아이디어 생성', '동기부여'],
      suitable_environments: ['스타트업', '창작 분야', '교육업', '컨설팅'],
      leadership_style: '영감을 주는 리더십',
      communication_style: '열정적이고 자유로운 소통'
    },
    'INTJ': {
      strengths: ['전략적 사고', '독립성', '체계적 계획', '혁신'],
      suitable_environments: ['연구소', 'IT 기업', '전략 기획', '분석 업무'],
      leadership_style: '비전을 제시하는 리더십',
      communication_style: '논리적이고 명확한 소통'
    },
    'ESFJ': {
      strengths: ['팀워크', '배려심', '조직 관리', '안정성'],
      suitable_environments: ['대기업', '공공기관', '서비스업', '의료분야'],
      leadership_style: '서번트 리더십',
      communication_style: '따뜻하고 배려하는 소통'
    },
    'ISTP': {
      strengths: ['문제해결', '실용성', '기술적 능력', '유연성'],
      suitable_environments: ['제조업', '엔지니어링', '기술직', '프리랜서'],
      leadership_style: '실무형 리더십',
      communication_style: '간결하고 실용적 소통'
    }
  };

  return analyses[mbtiUpper] || {
    strengths: ['개인 특성에 맞는 강점', '고유한 능력', '성장 잠재력'],
    suitable_environments: ['적성에 맞는 환경', '성장 가능한 조직'],
    leadership_style: '개인 스타일에 맞는 리더십',
    communication_style: '자신만의 소통 방식'
  };
}

function generateJobRecommendations(info: JobInfo, luck: number): JobFortune['recommended_jobs'] {
  const jobFields = [
    { field: 'IT/소프트웨어', positions: ['소프트웨어 엔지니어', '데이터 분석가', 'UX/UI 디자이너', '프로덕트 매니저'] },
    { field: '경영/기획', positions: ['경영기획', '전략기획', '마케팅 매니저', '사업개발'] },
    { field: '금융/투자', positions: ['애널리스트', '펀드매니저', '투자상담사', '리스크관리사'] },
    { field: '교육/연구', positions: ['연구원', '교수', '강사', '교육 컨설턴트'] },
    { field: '창작/예술', positions: ['콘텐츠 크리에이터', '그래픽 디자이너', '영상 편집자', '카피라이터'] },
    { field: '의료/건강', positions: ['의사', '간호사', '물리치료사', '영양사'] },
    { field: '법률/공공', positions: ['변호사', '공무원', '법무사', '노무사'] },
    { field: '제조/기술', positions: ['엔지니어', '품질관리', '생산관리', '기술영업'] }
  ];

  // 선호 분야가 있으면 우선 고려
  const preferredJobs = info.preferred_fields ? 
    jobFields.filter(field => 
      info.preferred_fields!.some(pref => 
        field.field.includes(pref) || field.positions.some(pos => pos.includes(pref))
      )
    ) : jobFields;

  const selectedFields = preferredJobs.length > 0 ? preferredJobs : jobFields;
  const shuffledFields = selectedFields.sort(() => 0.5 - Math.random());

  const bestMatch = shuffledFields[0];
  const bestPosition = bestMatch.positions[Math.floor(Math.random() * bestMatch.positions.length)];

  return {
    best_match: {
      field: bestMatch.field,
      position: bestPosition,
      compatibility: Math.max(85, Math.min(98, luck + Math.floor(Math.random() * 10))),
      reasons: [
        '개인 성향과 높은 적합성',
        '시장 전망이 밝은 분야',
        '성장 잠재력이 큰 직종',
        '안정적인 수익 구조'
      ]
    },
    good_matches: shuffledFields.slice(1, 4).map(field => ({
      field: field.field,
      position: field.positions[Math.floor(Math.random() * field.positions.length)],
      compatibility: Math.max(70, Math.min(90, luck + Math.floor(Math.random() * 8) - 5)),
      strengths: '전문성을 키울 수 있는 분야'
    })),
    challenging_fields: shuffledFields.slice(4, 6).map(field => ({
      field: field.field,
      compatibility: Math.max(50, Math.min(75, luck - Math.floor(Math.random() * 15))),
      challenges: '추가 역량 개발이 필요한 분야'
    }))
  };
}

function calculateLuckyElements(day: number, month: number): JobFortune['lucky_elements'] {
  const times = ['오전 9-11시', '오후 2-4시', '저녁 6-8시', '오후 1-3시', '오전 10-12시'];
  const days = ['월요일', '화요일', '수요일', '목요일', '금요일'];
  const colors = ['네이비 블루', '그레이', '화이트', '베이지', '블랙'];
  const keywords = ['전문성', '신뢰성', '소통력', '리더십', '창의성'];
  const networkPersons = ['선배', '동료', '멘토', '클라이언트', '업계 전문가'];

  return {
    time: times[day % times.length],
    day: days[month % days.length],
    color: colors[(day + month) % colors.length],
    keyword: keywords[(day * month) % keywords.length],
    network_person: networkPersons[(day + month * 2) % networkPersons.length]
  };
}

function generateTimingAdvice(birthMonth: number, experience?: string): JobFortune['timing_advice'] {
  const isExperienced = experience === '5-10년' || experience === '10년 이상';
  
  return {
    job_search: isExperienced ? 
      '하반기가 좋은 기회의 시기입니다. 연말 조직 개편 시즌을 노려보세요.' :
      '상반기에 적극적으로 준비하여 하반기에 결실을 맺으세요.',
    interview_period: birthMonth <= 6 ? 
      '봄과 여름이 면접에 유리한 시기입니다.' :
      '가을과 겨울이 면접 성공률이 높은 시기입니다.',
    career_change: '3-5월 또는 9-11월이 전직에 적합한 시기입니다.'
  };
}

function generateSkillRecommendations(info: JobInfo): string[] {
  const baseSkills = ['커뮤니케이션', '문제해결', '시간관리', '팀워크'];
  const additionalSkills = ['데이터 분석', '디지털 마케팅', '프로젝트 관리', '외국어', '프레젠테이션', '리더십'];
  
  // 현재 스킬을 제외하고 추천
  const currentSkills = info.skills || [];
  const recommendedSkills = additionalSkills
    .filter(skill => !currentSkills.includes(skill))
    .sort(() => 0.5 - Math.random())
    .slice(0, 3);

  return [...baseSkills.slice(0, 2), ...recommendedSkills];
}

function generatePersonalizedAdvice(info: JobInfo, luck: number): JobFortune['personalized_advice'] {
  const isHighLuck = luck >= 80;
  const hasExperience = info.job_experience && info.job_experience !== '신입';

  return {
    strengths: hasExperience ? 
      '경력을 바탕으로 한 실무 역량과 네트워킹이 강점입니다.' :
      '새로운 시각과 학습 의욕, 그리고 적응력이 큰 장점입니다.',
    development_areas: isHighLuck ?
      '리더십과 전략적 사고를 더욱 발전시키면 큰 성장을 이룰 수 있습니다.' :
      '기본기를 탄탄히 하고 전문성을 꾸준히 쌓아가는 것이 중요합니다.',
    networking_tips: '업계 세미나와 온라인 커뮤니티를 적극 활용하여 인맥을 넓히세요.',
    interview_tips: '구체적인 경험담과 성과를 준비하여 신뢰감을 주는 것이 핵심입니다.'
  };
}

function generateSuccessFactors(info: JobInfo): string[] {
  const factors = [
    '지속적인 학습과 자기계발',
    '전문성 강화를 위한 노력',
    '긍정적인 대인관계 구축',
    '목표 설정과 체계적 준비',
    '시장 트렌드에 대한 관심',
    '건강한 워라밸 유지',
    '멘토링과 코칭 활용',
    '실패를 통한 학습'
  ];

  return factors.sort(() => 0.5 - Math.random()).slice(0, 5);
}

function generateWarningSignsForJob(info: JobInfo): string[] {
  return [
    '급하게 결정하지 말고 충분히 고민하세요',
    '연봉만 보고 선택하면 후회할 수 있습니다',
    '회사 문화와 개인 가치관 불일치 주의',
    '과도한 업무량으로 인한 번아웃 방지',
    '동료들과의 갈등 상황 미리 대비',
    '지나친 완벽주의로 인한 스트레스 관리',
    '부정적인 소문이나 평판에 흔들리지 마세요'
  ];
} 
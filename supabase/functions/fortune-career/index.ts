/**
 * 커리어 인사이트 (Career Fortune) Edge Function
 *
 * @description 사주와 직업 정보를 기반으로 경력/취업 인사이트를 분석합니다.
 *
 * @endpoint POST /fortune-career
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간
 * - gender: string - 성별
 * - currentJob?: string - 현재 직업
 * - careerGoal?: string - 희망 직종/목표
 *
 * @response CareerFortuneResponse
 * - overall_score: number - 직업운 점수
 * - career_aptitude: { strengths, suitable_fields } - 적성 분석
 * - current_luck: { job, promotion, income } - 현재 운세
 * - timing: { best_month, action_period } - 최적 시기
 * - advice: string - 경력 조언
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-career \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","birthDate":"1990-01-01","gender":"male"}'
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import { parseAndValidateLLMResponse, v } from '../_shared/llm/validation.ts'
import {
  extractCareerCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// 커리어 분야 매핑 (15개+ 직업군 지원)
const careerFieldsMap = {
  // === 기존 분야 (개선) ===
  'IT/개발': {
    skills: ['기술 전문성', '혁신/창의성', '데이터 분석', '전략적 사고'],
    growthPaths: ['시니어 개발자', 'CTO', '아키텍트', '테크 리드'],
    keyFactors: ['기술 트렌드', '지속적 학습', '문제 해결 능력', '커뮤니케이션']
  },
  '경영/관리': {
    skills: ['리더십', '전략적 사고', '커뮤니케이션', '네트워킹'],
    growthPaths: ['팀장', '부서장', 'C레벨', '임원'],
    keyFactors: ['리더십', '의사결정력', '조직 관리', '성과 창출']
  },
  '마케팅/세일즈': {
    skills: ['커뮤니케이션', '네트워킹', '데이터 분석', '혁신/창의성'],
    growthPaths: ['마케팅 매니저', 'CMO', '세일즈 디렉터', '사업 개발'],
    keyFactors: ['시장 이해력', '고객 관계', '브랜딩', '수익성']
  },
  '컨설팅': {
    skills: ['전략적 사고', '커뮤니케이션', '데이터 분석', '글로벌 역량'],
    growthPaths: ['시니어 컨설턴트', '프린시펄', '파트너', '독립 컨설턴트'],
    keyFactors: ['문제 해결', '클라이언트 관계', '전문성', '네트워킹']
  },
  '창업': {
    skills: ['리더십', '혁신/창의성', '전략적 사고', '네트워킹'],
    growthPaths: ['창업자', '시리얼 앙트러프레너', '투자자', '멘토'],
    keyFactors: ['비전', '실행력', '자금 조달', '팀 빌딩']
  },
  // === 신규 분야 추가 ===
  '의료/보건': {
    skills: ['전문성', '커뮤니케이션', '판단력', '책임감'],
    growthPaths: ['전문의', '과장', '원장', '의료원 경영'],
    keyFactors: ['임상 경험', '환자 관계', '최신 의료 지식', '팀 협업']
  },
  '약학': {
    skills: ['전문성', '정확성', '고객 상담', '경영 능력'],
    growthPaths: ['전문약사', '약국장', '제약사 연구원', '제약사 임원'],
    keyFactors: ['약학 지식', '복약 상담', '재고 관리', '고객 신뢰']
  },
  '법률': {
    skills: ['논리적 사고', '커뮤니케이션', '전문성', '협상력'],
    growthPaths: ['선임변호사', '파트너', '로펌 대표', '법무 임원'],
    keyFactors: ['법률 전문성', '클라이언트 관계', '승소율', '명성 구축']
  },
  '금융/회계': {
    skills: ['분석력', '정확성', '리스크 관리', '커뮤니케이션'],
    growthPaths: ['선임회계사', '팀장', '파트너', 'CFO'],
    keyFactors: ['재무 전문성', '규정 준수', '전략적 조언', '신뢰 구축']
  },
  '교육': {
    skills: ['커뮤니케이션', '인내심', '창의성', '리더십'],
    growthPaths: ['수석교사', '교감', '교장', '교육 컨설턴트'],
    keyFactors: ['교수법', '학생 관계', '교육과정 개발', '행정 능력']
  },
  '디자인/예술': {
    skills: ['창의성', '미적 감각', '기술 활용', '커뮤니케이션'],
    growthPaths: ['리드 디자이너', 'CD', '디자인 디렉터', '스튜디오 대표'],
    keyFactors: ['포트폴리오', '트렌드 감각', '클라이언트 소통', '브랜딩']
  },
  '미디어/콘텐츠': {
    skills: ['창의성', '커뮤니케이션', '기획력', '트렌드 감각'],
    growthPaths: ['PD', '편집장', '콘텐츠 디렉터', '미디어 임원'],
    keyFactors: ['콘텐츠 기획', '오디언스 이해', '플랫폼 활용', '팀 리드']
  },
  '공공/행정': {
    skills: ['기획력', '커뮤니케이션', '정책 이해', '조직 관리'],
    growthPaths: ['주무관', '팀장', '국장', '기관장'],
    keyFactors: ['행정 역량', '정책 기획', '이해관계자 조율', '청렴성']
  },
  '서비스/판매': {
    skills: ['커뮤니케이션', '고객 응대', '판매 기술', '문제 해결'],
    growthPaths: ['점장', '지역장', '본부장', '서비스 임원'],
    keyFactors: ['고객 만족', '매출 성과', '팀 관리', '브랜드 대표']
  },
  '제조/생산': {
    skills: ['기술력', '품질 관리', '프로세스 개선', '리더십'],
    growthPaths: ['반장', '공장장', '생산본부장', 'COO'],
    keyFactors: ['생산 효율', '품질 관리', '안전 관리', '원가 절감']
  },
  '물류/유통': {
    skills: ['시스템 이해', '효율화', '커뮤니케이션', '위기 관리'],
    growthPaths: ['물류팀장', '센터장', '운영본부장', 'SCM 임원'],
    keyFactors: ['물류 최적화', '파트너 관계', '비용 관리', '시스템 활용']
  },
  '연구/R&D': {
    skills: ['전문성', '분석력', '창의성', '논문 작성'],
    growthPaths: ['선임연구원', '책임연구원', '연구소장', 'CTO'],
    keyFactors: ['연구 성과', '논문/특허', '자금 유치', '팀 빌딩']
  },
  'HR/인사': {
    skills: ['커뮤니케이션', '판단력', '공정성', '전략적 사고'],
    growthPaths: ['HR매니저', '인사팀장', 'HR디렉터', 'CHRO'],
    keyFactors: ['인재 관리', '조직 문화', '노무 관리', '전략적 HR']
  },
  // === 일반 분야 (Fallback용) ===
  '일반': {
    skills: ['전문성', '리더십', '커뮤니케이션', '문제해결'],
    growthPaths: ['팀 리더', '매니저', '디렉터', '임원'],
    keyFactors: ['경력 개발', '네트워킹', '지속 학습', '성과 관리']
  }
}

// 시기별 예측 가중치
const timeHorizonWeights = {
  '1년 후': { 현실성: 0.8, 도전성: 0.2, 불확실성: 0.1 },
  '3년 후': { 현실성: 0.6, 도전성: 0.4, 불확실성: 0.3 },
  '5년 후': { 현실성: 0.4, 도전성: 0.6, 불확실성: 0.5 },
  '10년 후': { 현실성: 0.2, 도전성: 0.8, 불확실성: 0.7 }
}

// 요청 인터페이스
interface CareerFortuneRequest {
  fortuneType: 'career-future' | 'career-change' | 'career-coaching'
  currentRole?: string
  careerGoal?: string
  timeHorizon?: string
  careerPath?: string
  skills?: string[]
  experience?: string
  industry?: string
  challenges?: string[]
  strengths?: string[]
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
  primaryConcern?: string  // ✅ 핵심 고민 (growth|direction|transition|balance|compensation|relationship)
  shortTermGoal?: string   // ✅ 단기 목표
  coreValue?: string       // ✅ 핵심 가치
  primary_concern?: string // ✅ Flutter에서 snake_case로 전달되는 경우
  short_term_goal?: string
  core_value?: string
}

// 커리어 예측 데이터
interface CareerPrediction {
  timeframe: string
  probability: number // 0-100
  keyMilestones: string[]
  requiredActions: string[]
  potentialChallenges: string[]
  successFactors: string[]
}

// 스킬 분석 데이터
interface SkillAnalysis {
  skill: string
  currentLevel: number // 1-10 추정
  targetLevel: number // 1-10
  developmentPlan: string
  timeToMaster: string
  importanceScore: number // 1-10
}

// 응답 인터페이스 (✅ 표준화된 필드명 사용)
interface CareerFortuneResponse {
  success: boolean
  data: {
    fortuneType: string
    score: number           // ✅ 표준화: careerScore → score
    content: string         // ✅ 표준화: overallOutlook → content
    summary: string         // ✅ 표준화: 한줄 요약 추가
    advice: string          // ✅ 표준화: 조언 추가
    currentRole: string
    timeHorizon: string
    careerPath: string
    predictions: CareerPrediction[]
    skillAnalysis: SkillAnalysis[]
    strengthsAssessment: string[]
    improvementAreas: string[]
    actionPlan: {
      immediate: string[] // 1-3개월
      shortTerm: string[] // 3-12개월
      longTerm: string[] // 1-3년
    }
    industryInsights: string
    networkingAdvice: string[]
    luckyPeriods: string[]
    cautionPeriods: string[]
    careerKeywords: string[]
    mentorshipAdvice: string
    timestamp: string
  }
  error?: string
}

// ✅ 핵심 고민 라벨 매핑
function getConcernLabel(concern: string): string {
  const labels: Record<string, string> = {
    'growth': '성장 정체',
    'direction': '방향성 고민',
    'transition': '이직/전직',
    'balance': '워라벨',
    'compensation': '보상',
    'relationship': '직장 내 인간관계'
  }
  return labels[concern] || concern
}

// ✅ 핵심 고민별 프롬프트 섹션 생성
function getConcernPromptSection(concern: string): string {
  const concernPrompts: Record<string, string> = {
    'relationship': `
## 직장 내 인간관계 집중 분석 (반드시 포함)
사용자의 핵심 고민: 직장 내 인간관계
다음 내용을 반드시 결과에 포함해주세요:
- 동료와의 관계 개선 전략 (소통 방법, 신뢰 구축)
- 상사와의 관계 관리법 (보고 스킬, 기대치 조율)
- 부하직원/후배와의 관계 (리더십, 멘토링)
- 갈등 상황 대처법 및 해결 전략
- 맞지 않는 사람과 협업하는 방법
- 팀 내 정치적 상황 대응법
- 네트워킹 및 관계 확장 전략`,

    'growth': `
## 성장 정체 돌파 전략 (반드시 포함)
사용자의 핵심 고민: 성장 정체
다음 내용을 반드시 결과에 포함해주세요:
- 현재 정체 원인 분석
- 새로운 스킬 습득 로드맵
- 승진/성장 기회 포착 전략
- 가시적 성과 창출 방법
- 멘토/스폰서 확보 전략`,

    'direction': `
## 커리어 방향성 설정 (반드시 포함)
사용자의 핵심 고민: 방향성 고민
다음 내용을 반드시 결과에 포함해주세요:
- 강점 기반 커리어 방향 제안
- 업계 트렌드와 기회 분석
- 의사결정 프레임워크
- 단계별 탐색 계획
- 다양한 경로 비교 분석`,

    'transition': `
## 이직/전직 전략 (반드시 포함)
사용자의 핵심 고민: 이직/전직
다음 내용을 반드시 결과에 포함해주세요:
- 이직 적기 판단 기준
- 타겟 회사/포지션 분석
- 이력서/면접 전략
- 연봉 협상 팁
- 온보딩 성공 전략`,

    'balance': `
## 워라벨 개선 전략 (반드시 포함)
사용자의 핵심 고민: 워라벨
다음 내용을 반드시 결과에 포함해주세요:
- 업무 효율화 방법
- 경계 설정 전략
- 번아웃 예방법
- 지속 가능한 업무 패턴
- 에너지 관리 전략`,

    'compensation': `
## 보상/처우 개선 전략 (반드시 포함)
사용자의 핵심 고민: 보상
다음 내용을 반드시 결과에 포함해주세요:
- 연봉 협상 타이밍과 전략
- 가치 증명 방법
- 대안적 보상 협상 (복지, 유연근무 등)
- 시장가치 파악법
- 장기적 재정 계획`
  }

  return concernPrompts[concern] || ''
}

// 커리어 분야 추정 함수 (15개+ 직업군 지원)
function estimateCareerField(currentRole: string): string {
  const role = currentRole.toLowerCase()

  // 의료/보건 (가장 먼저 체크 - 특수 직업군)
  if (/의사|간호|치료|임상|의료|병원|한의|치과|수의|물리치료|작업치료|방사선|의학/.test(role)) {
    return '의료/보건'
  }

  // 약학
  if (/약사|약국|제약|조제|약학/.test(role)) {
    return '약학'
  }

  // 법률
  if (/변호사|법무|법률|검사|판사|변리사|법조|로펌/.test(role)) {
    return '법률'
  }

  // 금융/회계
  if (/회계|세무|재무|금융|은행|증권|보험|애널리스트|펀드|자산|투자|cpa|cfa/.test(role)) {
    return '금융/회계'
  }

  // 교육
  if (/교사|교수|강사|선생|교육|학원|튜터|코치|트레이너/.test(role)) {
    return '교육'
  }

  // 디자인/예술
  if (/디자인|디자이너|아트|예술|그래픽|ui|ux|일러스트|사진|영상|작가/.test(role)) {
    return '디자인/예술'
  }

  // 미디어/콘텐츠
  if (/pd|기자|편집|콘텐츠|미디어|방송|유튜브|크리에이터|출판|언론/.test(role)) {
    return '미디어/콘텐츠'
  }

  // 공공/행정
  if (/공무원|행정|공공|정부|지자체|공단|공사|기관/.test(role)) {
    return '공공/행정'
  }

  // 서비스/판매
  if (/서비스|판매|매장|점장|고객|상담|cs|영업|retail|store/.test(role)) {
    return '서비스/판매'
  }

  // 제조/생산
  if (/제조|생산|공장|품질|qc|qa|조립|기계|엔지니어링/.test(role)) {
    return '제조/생산'
  }

  // 물류/유통
  if (/물류|유통|배송|창고|scm|구매|소싱|무역/.test(role)) {
    return '물류/유통'
  }

  // 연구/R&D
  if (/연구|연구원|r&d|박사|과학|실험|랩|lab/.test(role)) {
    return '연구/R&D'
  }

  // HR/인사
  if (/인사|hr|채용|교육|조직|노무|복지|급여/.test(role)) {
    return 'HR/인사'
  }

  // IT/개발 (일반적인 용어 체크)
  if (/개발|프로그래|엔지니어|dev|소프트웨어|it|tech|코딩|백엔드|프론트|풀스택|데이터|ai|ml/.test(role)) {
    return 'IT/개발'
  }

  // 경영/관리
  if (/매니저|관리|팀장|부장|차장|과장|사장|이사|임원|ceo|coo|cfo/.test(role)) {
    return '경영/관리'
  }

  // 마케팅/세일즈
  if (/마케팅|세일즈|영업|sales|marketing|브랜드|광고|pr|홍보/.test(role)) {
    return '마케팅/세일즈'
  }

  // 컨설팅
  if (/컨설턴트|컨설팅|어드바이저|전략|기획/.test(role)) {
    return '컨설팅'
  }

  // 창업
  if (/창업|대표|founder|ceo|스타트업|사업/.test(role)) {
    return '창업'
  }

  // 일반 (fallback) - IT/개발이 아닌 범용 경로 제공
  return '일반'
}

// 스킬 분석 함수
function analyzeSkills(skills: string[], careerField: string, currentRole: string): SkillAnalysis[] {
  const fieldData = careerFieldsMap[careerField as keyof typeof careerFieldsMap] || careerFieldsMap['일반']
  const analyses: SkillAnalysis[] = []

  skills.forEach(skill => {
    const isFieldRelevant = fieldData.skills.includes(skill)
    const currentLevel = Math.floor(Math.random() * 3) + 4 // 4-6 (현재 수준)
    const targetLevel = Math.floor(Math.random() * 2) + 8 // 8-9 (목표 수준)

    const developmentPlans: { [key: string]: string } = {
      '리더십': '리더십 교육 프로그램 참여, 멘토링, 팀 프로젝트 리드 경험 축적',
      '기술 전문성': '지속적인 기술 학습, 인증 취득, 실무 프로젝트 적용, 커뮤니티 활동',
      '커뮤니케이션': '프레젠테이션 교육, 글쓰기 연습, 네트워킹 이벤트 참여',
      '전략적 사고': '비즈니스 케이스 스터디, MBA 또는 전략 교육, 시장 분석 연습',
      '혁신/창의성': '디자인 씽킹 워크숍, 브레인스토밍 세션 참여, 창의적 프로젝트 도전',
      '데이터 분석': '통계학 학습, 분석 도구 마스터, 실제 데이터로 인사이트 도출 연습',
      '네트워킹': '업계 행사 참여, LinkedIn 활용, 멘토/멘티 관계 구축',
      '글로벌 역량': '어학 실력 향상, 국제 프로젝트 참여, 문화적 감수성 개발'
    }

    const timeToMaster = targetLevel - currentLevel > 3 ? '2-3년' :
                        targetLevel - currentLevel > 1 ? '1-2년' : '6-12개월'

    analyses.push({
      skill,
      currentLevel,
      targetLevel,
      developmentPlan: developmentPlans[skill] || `${skill} 관련 전문 교육과 실무 경험을 통한 체계적 개발`,
      timeToMaster,
      importanceScore: isFieldRelevant ? Math.floor(Math.random() * 2) + 8 : Math.floor(Math.random() * 3) + 5
    })
  })

  return analyses.sort((a, b) => b.importanceScore - a.importanceScore)
}

// 커리어 예측 생성 함수
function generateCareerPredictions(
  timeHorizon: string,
  careerPath: string,
  careerField: string,
  currentRole: string
): CareerPrediction[] {
  const weights = timeHorizonWeights[timeHorizon as keyof typeof timeHorizonWeights] || timeHorizonWeights['3년 후']
  const fieldData = careerFieldsMap[careerField as keyof typeof careerFieldsMap] || careerFieldsMap['일반']

  const baseSuccess = 70 + (weights.현실성 * 20) - (weights.불확실성 * 15)
  const probability = Math.max(40, Math.min(95, Math.floor(baseSuccess)))

  const milestones = fieldData.growthPaths.slice(0, 2).map(path => `${path}으(로) 승진 또는 이직`)
  milestones.push(`${careerField} 분야 전문성 강화`)
  if (weights.도전성 > 0.5) {
    milestones.push('새로운 비즈니스 영역 진출 기회')
  }

  const actions = [
    `${fieldData.keyFactors[0]} 역량 강화`,
    `${fieldData.keyFactors[1]} 경험 축적`,
    '업계 네트워크 확장',
    '지속적 학습과 자기계발'
  ]

  const challenges = [
    '경쟁 심화로 인한 차별화 필요',
    '빠른 기술/시장 변화 적응',
    '일과 삶의 균형 유지'
  ]

  if (weights.불확실성 > 0.4) {
    challenges.push('예측 불가능한 시장 변화')
  }

  return [{
    timeframe: timeHorizon,
    probability,
    keyMilestones: milestones,
    requiredActions: actions,
    potentialChallenges: challenges,
    successFactors: fieldData.keyFactors
  }]
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    // 요청 데이터 파싱
    const requestData: CareerFortuneRequest & {
      current_role?: string
      career_goal?: string
      time_horizon?: string
      fortune_type?: string
    } = await req.json()
    const {
      fortuneType = 'career-future',
      fortune_type = '',
      currentRole = '',
      current_role = '',
      careerGoal = '',
      career_goal = '',
      timeHorizon = '3년 후',
      time_horizon = '',
      careerPath = '전문가 (기술 심화)',
      skills = [],
      experience = '',
      industry = '',
      challenges = [],
      strengths = [],
      isPremium = false, // ✅ 프리미엄 사용자 여부
      // ✅ 핵심 고민 관련 필드 (camelCase 또는 snake_case 모두 지원)
      primaryConcern = '',
      primary_concern = '',
      shortTermGoal = '',
      short_term_goal = '',
      coreValue = '',
      core_value = ''
    } = requestData

    // ✅ snake_case → camelCase 통합 (Flutter에서 snake_case로 전달됨)
    const actualFortuneType = fortuneType || fortune_type || 'career-future'
    const actualCurrentRole = currentRole || current_role || ''
    const actualCareerGoal = careerGoal || career_goal || ''
    const actualTimeHorizon = timeHorizon || time_horizon || '3년 후'
    const concern = primaryConcern || primary_concern || ''
    const shortGoal = shortTermGoal || short_term_goal || ''
    const value = coreValue || core_value || ''

    if (!actualCurrentRole && !actualCareerGoal) {
      throw new Error('현재 직무 또는 커리어 목표를 입력해주세요.')
    }

    console.log('Career fortune request:', {
      fortuneType: actualFortuneType,
      currentRole: actualCurrentRole.substring(0, 50),
      timeHorizon: actualTimeHorizon,
      careerPath,
      skillsCount: skills.length,
      isPremium, // ✅ 프리미엄 상태 로깅
      primaryConcern: concern, // ✅ 핵심 고민 로깅
      shortTermGoal: shortGoal,
      coreValue: value
    })

    // 기본 분석 수행
    const careerField = estimateCareerField(actualCurrentRole)
    const skillAnalysis = analyzeSkills(skills, careerField, actualCurrentRole)
    const predictions = generateCareerPredictions(actualTimeHorizon, careerPath, careerField, actualCurrentRole)

    // ✅ Cohort Pool 조회 (API 비용 90% 절감)
    const cohortData = extractCareerCohort({
      age: requestData.age,
      birthDate: requestData.birthDate,
      gender: requestData.gender,
      industry: industry,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[Career] Cohort: ${JSON.stringify(cohortData)} -> ${cohortHash.slice(0, 8)}...`)

    const poolResult = await getFromCohortPool(supabase, 'career', cohortHash)
    if (poolResult) {
      console.log('[Career] ✅ Cohort Pool 히트!')
      // 개인화 (이름 치환)
      const personalizedResult = personalize(poolResult, {
        userName: requestData.userName || requestData.name,
        currentRole: actualCurrentRole,
        careerGoal: actualCareerGoal,
      }) as Record<string, unknown>

      // 추가 데이터 병합
      personalizedResult.careerField = careerField
      personalizedResult.skillAnalysis = skillAnalysis
      personalizedResult.predictions = predictions

      // 퍼센타일 추가
      const score = (personalizedResult.score as number) || 75
      const percentileData = await calculatePercentile(supabase, 'career', score)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      return new Response(JSON.stringify({ success: true, data: resultWithPercentile }), {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      })
    }
    console.log('[Career] Cohort Pool miss, LLM 호출 필요')

    // 캐시 확인 (UTF-8 안전한 SHA-256 해시) - ✅ 핵심 고민도 캐시 키에 포함
    const hash = await createHash(`${actualFortuneType}_${actualCurrentRole}_${actualTimeHorizon}_${careerPath}_${skills.join(',')}_${concern}`)
    const cacheKey = `career_fortune_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for career fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      // ✅ 핵심 고민별 프롬프트 섹션 생성
      const concernSection = getConcernPromptSection(concern)
      const concernLabel = concern ? getConcernLabel(concern) : ''

      // OpenAI API 호출을 위한 프롬프트 생성
      const today = new Date()
      const currentYear = today.getFullYear()
      const currentMonth = today.getMonth() + 1
      const dateContext = `${currentYear}년 ${currentMonth}월`

      // ✅ 직업별 맞춤 가이드 생성
      const fieldData = careerFieldsMap[careerField as keyof typeof careerFieldsMap] || careerFieldsMap['일반']
      const fieldGrowthPaths = fieldData.growthPaths.join(', ')

      const prompt = `당신은 커리어 고민 들어주는 든든한 선배예요! 💼✨
뻔한 조언 말고, 진짜 도움 되는 현실 꿀팁을 친구처럼 알려줘요.

## 스타일 가이드 🚀
- 딱딱한 컨설턴트 NO! 회사생활 잘 아는 친한 선배처럼
- "~해봐!", "~거야!" 같은 응원하는 말투
- 현실적이면서도 희망적인 조언
- 업계 인싸만 아는 진짜 꿀팁 공유 느낌

## 톤 예시
❌ "체계적인 경력 개발 계획이 필요합니다"
✅ "지금이 이직 타이밍 좋아! 포트폴리오 정리하고 링크드인 좀 손봐봐 💪"

🚨 [최우선 규칙] 모든 응답은 반드시 한국어로 작성하세요!
- JSON 키: 반드시 한국어 (전반적인전망, 강점평가, 개선영역 등)
- JSON 값: 반드시 한국어 문장
- 영어 키(overallOutlook, strengths 등) 절대 사용 금지
- 영어 문장 절대 사용 금지

⚠️ 중요: 오늘 날짜는 ${dateContext}입니다. 모든 시기 예측은 이 날짜 이후로 작성해주세요.

현재 직무: "${actualCurrentRole}"
커리어 목표: "${actualCareerGoal}"
시간 계획: ${actualTimeHorizon}
희망 경로: ${careerPath}
개발 희망 스킬: ${skills.join(', ')}
분야 추정: ${careerField}
이 분야의 일반적 성장 경로: ${fieldGrowthPaths}

⚠️ 매우 중요 - 직업별 맞춤 응답:
사용자의 현재 직무는 "${actualCurrentRole}"입니다.
반드시 이 직업에 맞는 커리어 패스와 조언을 제공하세요.

예시:
- 약사 → 전문약사, 약국장, 제약사 연구원 등 약학 분야 경로
- 간호사 → 수간호사, 전문간호사, 간호부장 등 의료 분야 경로
- 회계사 → 선임회계사, 파트너, CFO 등 금융/회계 분야 경로
- 교사 → 수석교사, 교감, 교장 등 교육 분야 경로

🚫 금지사항:
절대로 IT/개발 직군 용어(시니어 개발자, CTO, 아키텍트, 테크 리드 등)를
비IT 직업(약사, 간호사, 회계사, 교사 등)에 사용하지 마세요
${concernLabel ? `핵심 고민: ${concernLabel}` : ''}
${shortGoal ? `단기 목표: ${shortGoal}` : ''}
${value ? `중요시하는 가치: ${value}` : ''}
${concernSection}

다음 JSON 형식으로 커리어 운세를 제공해주세요:

## 분량 요구사항 (카드 UI 스크롤 방지)
- 모든 텍스트 필드: **반드시 100자 이내**
- 배열 항목: **각 50자 이내**
- 핵심만 간결하게 작성

\`\`\`json
{
  "전반적인전망": "${actualTimeHorizon} 내 커리어 전망",
  "강점평가": ["강점1", "강점2", "강점3"],
  "개선영역": ["개선점1", "개선점2", "개선점3"],
  "실행계획": {
    "즉시실행": ["행동1", "행동2", "행동3"],
    "단기목표": ["목표1", "목표2", "목표3"],
    "장기목표": ["목표1", "목표2", "목표3"]
  },
  "업계인사이트": "${careerField} 분야 트렌드",
  "네트워킹조언": ["방법1", "방법2", "방법3"],
  "행운의시기": ["시기1 (예: ${currentYear}년 상반기)"],
  "주의시기": ["시기와 이유"],
  "핵심키워드": ["키워드1", "키워드2", "키워드3", "키워드4", "키워드5"],
  "멘토링조언": "멘토 관계 구축 조언"
}
\`\`\`

⚠️ 중요: 절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요.
전문적이고 간결한 조언을 제공해주세요. 반드시 JSON 형식으로만 응답하세요.`

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('career')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 커리어 고민 들어주는 든든한 선배예요! 💼 회사생활 잘 아는 친한 선배처럼, 현실적이고 도움 되는 조언을 친근하게 해줘요!'
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // ✅ LLM 사용량 로깅 (비용/성능 분석용)
      await UsageLogger.log({
        fortuneType: 'career',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          currentRole,
          careerPath,
          timeHorizon,
          isPremium
        }
      })

      // JSON 파싱 — 코드펜스/프롬프트 앞뒤 문장을 허용하는 완화된 파서 + 스키마 통과 검증
      const validation = parseAndValidateLLMResponse(
        response.content,
        v.passthrough<Record<string, unknown>>(),
      )
      if (!validation.ok) {
        console.error('[fortune-career] LLM response validation failed:', validation.error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }
      const parsedResponse = validation.value as any

      // 응답 데이터 구조화 (✅ 표준화된 필드명 사용)
      fortuneData = {
        fortuneType: actualFortuneType,
        // ✅ 표준화된 필드명: score, content, summary, advice
        score: Math.floor(predictions[0]?.probability || 75),
        content: parsedResponse.전반적인전망 || parsedResponse.overallOutlook || '긍정적인 커리어 발전이 예상됩니다.',
        summary: `${actualTimeHorizon} 커리어 전망: ${careerPath}`,
        advice: parsedResponse.멘토링조언 || parsedResponse.mentorshipAdvice || '전문성을 지속적으로 강화하세요',
        currentRole: actualCurrentRole,
        timeHorizon: actualTimeHorizon,
        careerPath,
        predictions: predictions,
        skillAnalysis: skillAnalysis,
        strengthsAssessment: parsedResponse.강점평가 || parsedResponse.strengthsAssessment || ['전문성', '책임감', '학습능력'],
        improvementAreas: parsedResponse.개선영역 || parsedResponse.improvementAreas || ['리더십', '커뮤니케이션', '전략적 사고'],
        actionPlan: {
          immediate: parsedResponse.실행계획?.즉시실행 || parsedResponse.actionPlan?.immediate || ['포트폴리오 업데이트', '네트워킹 이벤트 참여', '스킬 평가'],
          shortTerm: parsedResponse.실행계획?.단기목표 || parsedResponse.actionPlan?.shortTerm || ['전문 교육 수료', '프로젝트 성과 달성', '멘토 관계 구축'],
          longTerm: parsedResponse.실행계획?.장기목표 || parsedResponse.actionPlan?.longTerm || ['승진 또는 이직', '전문성 인정', '업계 네트워크 확장']
        },
        industryInsights: parsedResponse.업계인사이트 || parsedResponse.industryInsights || `${careerField} 분야는 지속적인 성장이 예상되는 유망한 영역입니다.`,
        networkingAdvice: parsedResponse.네트워킹조언 || parsedResponse.networkingAdvice || ['업계 컨퍼런스 참여', 'LinkedIn 활용', '동문 네트워크 활성화'],
        luckyPeriods: parsedResponse.행운의시기 || parsedResponse.luckyPeriods || [`${currentYear}년 상반기`, `${currentYear}년 4분기`],
        cautionPeriods: parsedResponse.주의시기 || parsedResponse.cautionPeriods || ['급변하는 시장 환경', '조직 개편 시기'],
        careerKeywords: parsedResponse.핵심키워드 || parsedResponse.careerKeywords || ['전문성', '리더십', '혁신', '네트워킹', '지속학습'],
        mentorshipAdvice: parsedResponse.멘토링조언 || parsedResponse.mentorshipAdvice || '업계 선배와의 멘토링 관계를 적극적으로 구축하세요.',
        timestamp: new Date().toISOString(),
      }

      // 결과 캐싱
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'career',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })

      // ✅ Cohort Pool에 저장 (fire-and-forget)
      saveToCohortPool(supabase, 'career', cohortHash, cohortData, fortuneData)
        .catch(e => console.error('[Career] Cohort 저장 오류:', e))
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'career', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    // 성공 응답
    const response: CareerFortuneResponse = {
      success: true,
      data: fortuneDataWithPercentile
    }

    return new Response(JSON.stringify(response), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Career Fortune Error:', error)

    const errorResponse: CareerFortuneResponse = {
      success: false,
      data: {} as any,
      error: error instanceof Error ? error.message : '커리어 인사이트 생성 중 오류가 발생했습니다.'
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
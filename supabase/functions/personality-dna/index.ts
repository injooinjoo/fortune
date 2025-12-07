/**
 * 성격 DNA 분석 (Personality DNA) Edge Function
 *
 * @description MBTI, 혈액형, 별자리, 띠를 조합하여 개인의 고유한 성격 DNA를 분석합니다.
 *
 * @endpoint POST /personality-dna
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name: string - 사용자 이름
 * - mbti: string - MBTI 유형 (예: ENFP)
 * - bloodType: string - 혈액형 (A, B, O, AB)
 * - zodiac: string - 별자리
 * - zodiacAnimal: string - 띠
 *
 * @response PersonalityDNAResponse
 * - dnaCode: string - 고유 DNA 코드
 * - title: string - 성격 타이틀
 * - emoji: string - 대표 이모지
 * - todayHighlight: string - 오늘의 하이라이트
 * - loveStyle: object - 연애 스타일
 *   - title: string - 연애 타이틀
 *   - when_dating: string - 연애 중 특징
 *   - after_breakup: string - 이별 후 특징
 * - workStyle: object - 업무 스타일
 *   - as_boss: string - 상사로서 특징
 *   - at_company_dinner: string - 회식 때 특징
 * - dailyMatching: object - 일상 매칭
 *   - cafe_menu: string - 추천 카페 메뉴
 *   - netflix_genre: string - 추천 넷플릭스 장르
 *   - weekend_activity: string - 주말 활동 추천
 * - compatibility: object - 궁합 정보
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "name": "홍길동",
 *   "mbti": "ENFP",
 *   "bloodType": "O",
 *   "zodiac": "쌍둥이자리",
 *   "zodiacAnimal": "토끼"
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PersonalityDNARequest {
  userId: string
  name: string
  mbti: string
  bloodType: string
  zodiac: string
  zodiacAnimal: string
}

interface PersonalityDNAResponse {
  dnaCode: string
  title: string
  emoji: string
  todayHighlight: string
  loveStyle: {
    title: string
    description: string
    when_dating: string
    after_breakup: string
  }
  workStyle: {
    title: string
    as_boss: string
    at_company_dinner: string
    work_habit: string
  }
  dailyMatching: {
    cafe_menu: string
    netflix_genre: string
    weekend_activity: string
  }
  compatibility: {
    friend: { mbti: string, description: string }
    lover: { mbti: string, description: string }
    colleague: { mbti: string, description: string }
  }
  funStats: {
    rarity_rank: string
    celebrity_match: string
    percentage_in_korea: string
  }
  todayAdvice: string
  rarityLevel: string
  socialRanking: number
  dailyFortune: {
    luckyColor: string
    luckyNumber: number
    energyLevel: number
    recommendedActivity: string
    caution: string
    bestMatchToday: string
  }
}

// MBTI별 연애 스타일
const MBTI_LOVE_STYLES = {
  'ENTJ': {
    title: '프로포즈 리더형',
    description: '연애도 전략적으로, 사랑도 계획적으로',
    when_dating: '첫 데이트부터 결혼까지의 로드맵을 머릿속에 그려놓고 있어요',
    after_breakup: '이별 후 1주일 안에 완전히 정리하고 다음 연애 준비 완료'
  },
  'ENTP': {
    title: '썸의 마법사형',
    description: '썸 타는 재미로 사는 사람, 확정은 무서워',
    when_dating: '매일 새로운 데이트 코스를 기획하며 상대방을 깜짝 놀라게 해요',
    after_breakup: '친구로 남자고 하면서 실제로 친구가 되는 신기한 능력 보유'
  },
  'INTJ': {
    title: '연애 마스터플랜형',
    description: '100년 동안 사랑할 계획서를 작성하는 타입',
    when_dating: '상대방의 성향을 분석해서 맞춤형 연애를 진행해요',
    after_breakup: '이별 후 6개월간 자기계발에 몰두한 후 더 업그레이드되어 돌아옴'
  },
  'INTP': {
    title: '연애 연구원형',
    description: '사랑도 하나의 흥미로운 연구 주제',
    when_dating: '상대방을 이해하려고 노력하다가 본인도 모르게 분석하고 있어요',
    after_breakup: '이별의 원인을 논리적으로 분석하고 리포트 작성'
  },
  'ENFJ': {
    title: '연애 멘토형',
    description: '상대방을 더 나은 사람으로 만들어주고 싶은 욕구',
    when_dating: '상대방의 꿈과 목표를 항상 응원하고 지지해줘요',
    after_breakup: '상대방의 행복을 위해 먼저 연락을 끊는 숭고한 희생정신'
  },
  'ENFP': {
    title: '연애 에너자이저형',
    description: '사랑하면 온 세상이 다 내 것 같은 기분',
    when_dating: '매 순간이 영화 같고, 상대방을 세상에서 가장 특별한 사람으로 만들어줘요',
    after_breakup: '3일은 울고, 일주일 후엔 새로운 사랑을 꿈꾸고 있음'
  },
  'INFJ': {
    title: '운명론자형',
    description: '우리 전생에 무슨 인연이었을까 자주 생각',
    when_dating: '깊은 대화를 좋아하고, 상대방의 내면을 이해하려고 노력해요',
    after_breakup: '운명이 아니었나보다 하며 담담하게 받아들이는 척 하지만 속으론 상처'
  },
  'INFP': {
    title: '로맨틱 드리머형',
    description: '사랑하는 사람과의 미래를 매일 상상하며 행복해함',
    when_dating: '작은 기념일도 다 챙기고, 상대방만의 특별한 별명을 만들어줘요',
    after_breakup: '이별 후 한 달간 슬픈 노래만 들으며 감상에 젖어있음'
  },
  'ESTJ': {
    title: '연애 CEO형',
    description: '연애도 효율적으로, 결혼은 더욱 체계적으로',
    when_dating: '계획적인 데이트와 미래에 대한 구체적인 계획을 세워요',
    after_breakup: '이별도 깔끔하게, 정리도 체계적으로 완료'
  },
  'ESFJ': {
    title: '연애 서포터형',
    description: '상대방 주변 사람들과도 잘 지내고 싶어함',
    when_dating: '상대방의 가족, 친구들에게도 인정받으려고 노력해요',
    after_breakup: '공통 친구들 사이에서 어색해질까봐 걱정'
  },
  'ISTJ': {
    title: '연애 신중파형',
    description: '사랑도 차근차근, 결혼도 신중하게',
    when_dating: '전통적인 연애를 좋아하고, 기념일을 소중히 여겨요',
    after_breakup: '이별 후에도 좋은 기억은 소중히 간직함'
  },
  'ISFJ': {
    title: '연애 헌신형',
    description: '사랑하는 사람을 위해서라면 무엇이든',
    when_dating: '상대방의 작은 변화도 알아채고 세심하게 배려해줘요',
    after_breakup: '상대방이 잘 지내고 있는지 계속 걱정됨'
  },
  'ESTP': {
    title: '연애 스프린터형',
    description: '일단 만나보고, 일단 사귀어보고, 일단 해보자',
    when_dating: '즉흥적이고 재미있는 데이트를 즐기며 현재에 충실해요',
    after_breakup: '이별 다음 날 친구들과 클럽에서 스트레스 해소'
  },
  'ESFP': {
    title: '연애 엔터테이너형',
    description: '연애할 때가 가장 빛이 나는 사람',
    when_dating: '상대방을 웃게 만들고, 함께 있을 때 즐거운 시간을 만들어줘요',
    after_breakup: '슬프지만 금세 다른 것에 관심을 돌리며 극복'
  },
  'ISTP': {
    title: '연애 쿨가이형',
    description: '감정 표현은 서툴지만 진심은 깊은',
    when_dating: '말보다는 행동으로 사랑을 표현해요',
    after_breakup: '겉으로는 괜찮은 척 하지만 혼자 있을 때 생각 많음'
  },
  'ISFP': {
    title: '연애 아티스트형',
    description: '사랑도 예술처럼 아름답게',
    when_dating: '감성적이고 로맨틱한 순간들을 만들어주며 따뜻하게 사랑해요',
    after_breakup: '이별의 아픔도 나만의 방식으로 예술로 승화시킴'
  }
}

// MBTI별 직장 생활
const MBTI_WORK_STYLES = {
  'ENTJ': {
    title: '타고난 CEO',
    as_boss: '직원들의 능력을 최대한 끌어내는 카리스마 리더십 발휘',
    at_company_dinner: '회식을 조직 문화 개선의 기회로 활용',
    work_habit: '월요일 아침부터 금요일 저녁까지의 완벽한 플랜 수립'
  },
  'ENTP': {
    title: '아이디어 폭포',
    as_boss: '직원들과 브레인스토밍하며 혁신적인 아이디어 창출',
    at_company_dinner: '분위기 메이커 역할하며 모든 사람과 대화',
    work_habit: '루틴은 싫고, 매일 새로운 도전과 변화를 추구'
  },
  'INTJ': {
    title: '마스터플래너',
    as_boss: '장기적 비전을 제시하고 체계적인 시스템 구축',
    at_company_dinner: '의미 있는 대화만 하고 적당한 시점에 퇴장',
    work_habit: '모든 프로젝트에 대한 완벽한 로드맵과 백업 플랜 보유'
  },
  'INTP': {
    title: '생각하는 기계',
    as_boss: '논리적 사고를 바탕으로 한 창의적 문제 해결',
    at_company_dinner: '흥미로운 주제가 나오면 시간 가는 줄 모르고 토론',
    work_habit: '완벽한 결과물을 위해 계속 수정하고 개선하는 완벽주의'
  },
  'ENFJ': {
    title: '팀의 멘토',
    as_boss: '직원 개개인의 성장을 도와주는 코칭형 리더',
    at_company_dinner: '모든 사람이 소외되지 않도록 세심하게 배려',
    work_habit: '팀워크를 중시하며 동료들의 의견을 적극 수렴'
  },
  'ENFP': {
    title: '에너지 충전소',
    as_boss: '직원들에게 영감을 주고 동기부여하는 열정 리더',
    at_company_dinner: '모든 사람을 하나로 만드는 천재적인 사교 능력',
    work_habit: '창의적인 업무는 최고, 반복 업무는 최악'
  },
  'INFJ': {
    title: '조용한 혁신가',
    as_boss: '직원들의 잠재력을 발견하고 성장시키는 통찰력',
    at_company_dinner: '깊이 있는 대화를 나누며 진심 어린 관심 표현',
    work_habit: '의미 있는 일에 몰입하면 시간 가는 줄 모름'
  },
  'INFP': {
    title: '가치 추구자',
    as_boss: '직원들의 개성을 존중하고 자율성을 보장',
    at_company_dinner: '어색하지만 나름대로 분위기에 맞춰 노력',
    work_habit: '내 가치관과 맞는 일할 때 최고의 퍼포먼스 발휘'
  },
  'ESTJ': {
    title: '효율성 마스터',
    as_boss: '체계적인 시스템으로 팀의 생산성 극대화',
    at_company_dinner: '적절한 선에서 즐기되 다음 날 업무에 지장 없게',
    work_habit: '할 일 목록 작성과 우선순위 정리는 필수'
  },
  'ESFJ': {
    title: '팀의 엄마',
    as_boss: '직원들의 복지와 만족도를 최우선으로 생각',
    at_company_dinner: '모든 사람이 편안하게 즐길 수 있도록 세심하게 챙김',
    work_habit: '동료들과의 좋은 관계 유지가 업무 효율성의 핵심'
  },
  'ISTJ': {
    title: '신뢰의 기둥',
    as_boss: '원칙과 규칙을 바탕으로 한 안정적인 운영',
    at_company_dinner: '적당히 참여하되 과하지 않게 절제된 모습',
    work_habit: '정해진 시간에 정확한 업무 처리, 약속은 반드시 지킴'
  },
  'ISFJ': {
    title: '든든한 서포터',
    as_boss: '직원들을 세심하게 챙기며 안정적인 환경 조성',
    at_company_dinner: '모든 사람이 즐거워하는지 계속 확인하며 배려',
    work_habit: '동료들이 도움 요청하면 자신의 일 제쳐두고도 도와줌'
  },
  'ESTP': {
    title: '현장의 해결사',
    as_boss: '즉석에서 문제를 해결하는 뛰어난 위기 관리 능력',
    at_company_dinner: '분위기를 최고조로 끌어올리는 자타공인 분위기 메이커',
    work_habit: '긴급한 업무 처리와 즉석 대응에 최적화'
  },
  'ESFP': {
    title: '직장의 비타민',
    as_boss: '밝고 긍정적인 에너지로 팀 분위기 활성화',
    at_company_dinner: '모든 사람을 웃게 만드는 타고난 엔터테이너',
    work_habit: '사람들과 함께하는 업무를 좋아하고 혼자 하는 일은 힘들어함'
  },
  'ISTP': {
    title: '기술의 달인',
    as_boss: '실무 능력을 바탕으로 한 실용적이고 효과적인 지시',
    at_company_dinner: '술 한두 잔 하고 적당한 시점에 조용히 퇴장',
    work_habit: '기술적인 문제 해결에 탁월하고 집중력 최고'
  },
  'ISFP': {
    title: '조용한 장인',
    as_boss: '직원들의 개성을 존중하며 자유로운 분위기 조성',
    at_company_dinner: '어색해하지만 분위기 깨지 않게 나름 참여',
    work_habit: '자신만의 페이스로 꾸준히, 완성도 높은 결과물 산출'
  }
}

// 일상 매칭
const MBTI_DAILY_MATCHING = {
  'ENTJ': { cafe_menu: '아메리카노 라지', netflix_genre: '경영 다큐멘터리', weekend_activity: '자기계발 세미나 참석' },
  'ENTP': { cafe_menu: '신메뉴 도전', netflix_genre: 'SF 스릴러', weekend_activity: '새로운 동네 탐험' },
  'INTJ': { cafe_menu: '드립커피', netflix_genre: '심리 스릴러', weekend_activity: '독서와 계획 세우기' },
  'INTP': { cafe_menu: '콜드브루', netflix_genre: '다큐멘터리', weekend_activity: '온라인 강의 수강' },
  'ENFJ': { cafe_menu: '카라멜 마키아또', netflix_genre: '힐링 드라마', weekend_activity: '친구들과 모임' },
  'ENFP': { cafe_menu: '컬러풀한 음료', netflix_genre: '로맨틱 코미디', weekend_activity: '페스티벌 참여' },
  'INFJ': { cafe_menu: '허브티', netflix_genre: '인문학 다큐멘터리', weekend_activity: '조용한 카페에서 독서' },
  'INFP': { cafe_menu: '라벤더 라떼', netflix_genre: '감성 영화', weekend_activity: '혼자만의 취미 시간' },
  'ESTJ': { cafe_menu: '에스프레소', netflix_genre: '법정 드라마', weekend_activity: '운동과 일정 정리' },
  'ESFJ': { cafe_menu: '달콤한 프라푸치노', netflix_genre: '가족 드라마', weekend_activity: '가족이나 친구들과 시간' },
  'ISTJ': { cafe_menu: '정통 원두커피', netflix_genre: '추리 드라마', weekend_activity: '집 정리와 계획 세우기' },
  'ISFJ': { cafe_menu: '따뜻한 차', netflix_genre: '따뜻한 일상 드라마', weekend_activity: '소중한 사람들과 조용한 시간' },
  'ESTP': { cafe_menu: '에너지 드링크', netflix_genre: '액션 영화', weekend_activity: '야외 스포츠 활동' },
  'ESFP': { cafe_menu: '달콤한 시즌 메뉴', netflix_genre: '예능 프로그램', weekend_activity: '친구들과 핫플레이스 탐방' },
  'ISTP': { cafe_menu: '블랙커피', netflix_genre: '다큐멘터리', weekend_activity: '혼자 취미 활동' },
  'ISFP': { cafe_menu: '부드러운 라떼', netflix_genre: '감성 영화', weekend_activity: '자연 속에서 휴식' }
}

// 궁합 매칭
const COMPATIBILITY_MATCHING = {
  'ENTJ': {
    friend: { mbti: 'ENTP', description: '서로의 아이디어를 발전시키는 완벽한 브레인 파트너' },
    lover: { mbti: 'INFP', description: '강한 리더십과 따뜻한 감성의 완벽한 조화' },
    colleague: { mbti: 'ISTJ', description: '계획과 실행의 환상적인 콤비' }
  },
  'ENTP': {
    friend: { mbti: 'ENFP', description: '끝없는 에너지와 창의력의 폭발적 만남' },
    lover: { mbti: 'INFJ', description: '창의력과 깊이의 신비로운 조합' },
    colleague: { mbti: 'INTJ', description: '혁신과 전략의 무적 팀워크' }
  },
  'INTJ': {
    friend: { mbti: 'INTP', description: '깊이 있는 대화와 지적 자극의 완벽한 조합' },
    lover: { mbti: 'ENFP', description: '계획적인 사랑과 자유로운 열정의 만남' },
    colleague: { mbti: 'ENTJ', description: '비전과 실행력의 최강 듀오' }
  },
  'INTP': {
    friend: { mbti: 'INTJ', description: '서로의 사고 과정을 이해하는 지적 동반자' },
    lover: { mbti: 'ENFJ', description: '논리와 감정의 아름다운 균형' },
    colleague: { mbti: 'ENTP', description: '아이디어 개발의 환상적인 시너지' }
  },
  'ENFJ': {
    friend: { mbti: 'ENFP', description: '서로를 격려하고 영감을 주는 에너지 충전소' },
    lover: { mbti: 'INTP', description: '따뜻한 배려와 깊은 사고의 완벽한 만남' },
    colleague: { mbti: 'INFJ', description: '사람 중심의 가치를 공유하는 드림팀' }
  },
  'ENFP': {
    friend: { mbti: 'ESFP', description: '즐거움과 모험을 함께하는 라이프 파트너' },
    lover: { mbti: 'INTJ', description: '자유로운 열정과 깊은 사랑의 조화' },
    colleague: { mbti: 'ENFJ', description: '창의력과 실행력의 완벽한 조합' }
  },
  'INFJ': {
    friend: { mbti: 'INFP', description: '서로의 내면을 이해하는 깊은 우정' },
    lover: { mbti: 'ENTP', description: '깊이와 창의력의 신비로운 케미' },
    colleague: { mbti: 'ENFJ', description: '이상과 현실을 연결하는 완벽한 팀' }
  },
  'INFP': {
    friend: { mbti: 'ISFP', description: '서로의 감성을 공유하는 진실한 친구' },
    lover: { mbti: 'ENTJ', description: '따뜻한 감성과 강한 리더십의 만남' },
    colleague: { mbti: 'INFJ', description: '가치와 비전을 공유하는 이상적 팀' }
  },
  'ESTJ': {
    friend: { mbti: 'ISTJ', description: '신뢰와 안정성을 바탕으로 한 든든한 우정' },
    lover: { mbti: 'ISFP', description: '체계와 자유로움의 흥미로운 조화' },
    colleague: { mbti: 'ESFJ', description: '효율성과 배려의 완벽한 업무 파트너' }
  },
  'ESFJ': {
    friend: { mbti: 'ISFJ', description: '서로를 챙기는 따뜻한 우정' },
    lover: { mbti: 'ISTP', description: '배려와 실용성의 안정적인 만남' },
    colleague: { mbti: 'ESTJ', description: '조직의 화합을 이루는 최고의 듀오' }
  },
  'ISTJ': {
    friend: { mbti: 'ESTJ', description: '믿음직한 관계와 든든한 지원의 우정' },
    lover: { mbti: 'ESFP', description: '안정과 활력의 완벽한 밸런스' },
    colleague: { mbti: 'ISFJ', description: '책임감과 세심함의 최강 콤비' }
  },
  'ISFJ': {
    friend: { mbti: 'ESFJ', description: '서로를 이해하고 지지하는 따뜻한 관계' },
    lover: { mbti: 'ESTP', description: '안정적인 사랑과 활동적 에너지의 조화' },
    colleague: { mbti: 'ISTJ', description: '세심함과 신뢰성의 완벽한 팀워크' }
  },
  'ESTP': {
    friend: { mbti: 'ESFP', description: '모험과 즐거움을 함께하는 최고의 파트너' },
    lover: { mbti: 'ISFJ', description: '역동적 에너지와 안정적 사랑의 만남' },
    colleague: { mbti: 'ISTP', description: '현장 대응력의 무적 조합' }
  },
  'ESFP': {
    friend: { mbti: 'ESTP', description: '언제나 재미있고 활기찬 우정' },
    lover: { mbti: 'ISTJ', description: '자유로운 에너지와 안정적 사랑의 균형' },
    colleague: { mbti: 'ENFP', description: '밝은 에너지와 창의력의 시너지' }
  },
  'ISTP': {
    friend: { mbti: 'ESTP', description: '액션과 모험을 함께하는 쿨한 우정' },
    lover: { mbti: 'ESFJ', description: '실용적 사랑과 따뜻한 배려의 조화' },
    colleague: { mbti: 'ISTJ', description: '실무 능력과 신뢰성의 완벽한 팀' }
  },
  'ISFP': {
    friend: { mbti: 'INFP', description: '서로의 감성을 이해하는 진정한 소울메이트' },
    lover: { mbti: 'ESTJ', description: '자유로운 영혼과 안정적 리더십의 만남' },
    colleague: { mbti: 'ISFJ', description: '조화와 배려를 중시하는 평화로운 팀' }
  }
}

// 재미있는 통계
const FUN_STATS = {
  'ENTJ': { rarity_rank: '전국 상위 2%', celebrity_match: '스티브 잡스', percentage_in_korea: '2.1%' },
  'ENTP': { rarity_rank: '전국 상위 5%', celebrity_match: '로버트 다우니 주니어', percentage_in_korea: '4.8%' },
  'INTJ': { rarity_rank: '전국 상위 1%', celebrity_match: '일론 머스크', percentage_in_korea: '1.2%' },
  'INTP': { rarity_rank: '전국 상위 3%', celebrity_match: '아인슈타인', percentage_in_korea: '2.9%' },
  'ENFJ': { rarity_rank: '전국 상위 8%', celebrity_match: '오프라 윈프리', percentage_in_korea: '7.6%' },
  'ENFP': { rarity_rank: '전국 상위 10%', celebrity_match: '로빈 윌리엄스', percentage_in_korea: '9.8%' },
  'INFJ': { rarity_rank: '전국 상위 1%', celebrity_match: '마틴 루터 킹', percentage_in_korea: '1.1%' },
  'INFP': { rarity_rank: '전국 상위 6%', celebrity_match: '조니 뎁', percentage_in_korea: '5.7%' },
  'ESTJ': { rarity_rank: '전국 상위 15%', celebrity_match: '고든 램지', percentage_in_korea: '14.2%' },
  'ESFJ': { rarity_rank: '전국 상위 18%', celebrity_match: '테일러 스위프트', percentage_in_korea: '17.9%' },
  'ISTJ': { rarity_rank: '전국 상위 20%', celebrity_match: '워런 버핏', percentage_in_korea: '19.8%' },
  'ISFJ': { rarity_rank: '전국 상위 22%', celebrity_match: '비욘세', percentage_in_korea: '21.5%' },
  'ESTP': { rarity_rank: '전국 상위 12%', celebrity_match: '브루스 윌리스', percentage_in_korea: '11.3%' },
  'ESFP': { rarity_rank: '전국 상위 16%', celebrity_match: '윌 스미스', percentage_in_korea: '15.7%' },
  'ISTP': { rarity_rank: '전국 상위 7%', celebrity_match: '클린트 이스트우드', percentage_in_korea: '6.9%' },
  'ISFP': { rarity_rank: '전국 상위 9%', celebrity_match: '마이클 잭슨', percentage_in_korea: '8.4%' }
}

// 희귀도 설정
const RARITY_LEVELS = {
  '1.1': 'legendary', '1.2': 'legendary',
  '2.1': 'epic', '2.9': 'epic',
  '4.8': 'rare', '5.7': 'rare', '6.9': 'rare', '7.6': 'rare',
  '8.4': 'uncommon', '9.8': 'uncommon', '11.3': 'uncommon',
  '14.2': 'common', '15.7': 'common', '17.9': 'common', '19.8': 'common', '21.5': 'common'
}

// 날짜 기반 결정론적 랜덤 함수 (같은 날짜면 같은 값)
function seededRandom(date: Date, seed: string): number {
  const dateStr = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  const combined = dateStr + seed
  let hash = 0
  for (let i = 0; i < combined.length; i++) {
    hash = ((hash << 5) - hash) + combined.charCodeAt(i)
    hash = hash & hash
  }
  return Math.abs(hash) / 2147483647
}

// 날짜 기반 배열 선택
function selectFromArray<T>(arr: T[], date: Date, seed: string): T {
  const random = seededRandom(date, seed)
  const index = Math.floor(random * arr.length)
  return arr[index]
}

// 오늘의 럭키 컬러 생성
function generateLuckyColor(date: Date, mbti: string): string {
  const colors = [
    '로즈 골드', '코랄 핑크', '민트 그린', '라벤더',
    '스카이 블루', '피치', '아이보리', '베이비 핑크',
    '터키 블루', '샴페인 골드', '세이지 그린', '더스티 로즈',
    '파스텔 옐로우', '라이트 퍼플', '소프트 그레이', '크림 화이트'
  ]
  return selectFromArray(colors, date, `color-${mbti}`)
}

// 오늘의 럭키 넘버 생성
function generateLuckyNumber(date: Date, bloodType: string): number {
  const random = seededRandom(date, `number-${bloodType}`)
  return Math.floor(random * 99) + 1
}

// 오늘의 에너지 레벨 생성
function generateEnergyLevel(date: Date, zodiac: string): number {
  const random = seededRandom(date, `energy-${zodiac}`)
  return Math.floor(random * 30) + 70 // 70-100% 범위
}

// 오늘의 추천 활동 생성
function generateRecommendedActivity(date: Date, mbti: string): string {
  const activities = {
    'E': [ // 외향형
      '새로운 사람들과 만남을 가져보세요',
      '친구들과 모임을 주선해보세요',
      '낯선 장소를 탐험해보세요',
      '온라인 커뮤니티에 적극 참여해보세요',
      '팀 프로젝트에 리더십을 발휘해보세요'
    ],
    'I': [ // 내향형
      '좋아하는 책이나 영화에 푹 빠져보세요',
      '혼자만의 산책 시간을 가져보세요',
      '조용한 카페에서 생각을 정리해보세요',
      '온라인 강의로 새로운 지식을 쌓아보세요',
      '일기나 글쓰기로 내면을 탐구해보세요'
    ]
  }

  const type = mbti[0] as 'E' | 'I'
  return selectFromArray(activities[type], date, `activity-${mbti}`)
}

// 오늘의 주의사항 생성
function generateCaution(date: Date, bloodType: string): string {
  const cautions = {
    'A': [
      '오늘은 완벽주의를 조금 내려놓으세요',
      '타인의 시선보다 내 마음을 먼저 챙기세요',
      '과도한 걱정은 금물! 긍정적으로 생각하세요',
      '스트레스 받으면 잠시 멈추고 심호흡을',
      '사소한 일에 예민해지지 않도록 주의하세요'
    ],
    'B': [
      '오늘은 계획적으로 움직여보세요',
      '즉흥적인 결정은 한 번 더 생각하고',
      '다른 사람의 의견도 귀 기울여 들어보세요',
      '감정적인 반응은 잠시 미루고 이성적으로',
      '목표를 정하고 차근차근 실행해보세요'
    ],
    'O': [
      '오늘은 디테일에 신경 써보세요',
      '중요한 약속이나 일정을 다시 확인하세요',
      '낙관적인 것도 좋지만 현실 체크는 필수',
      '편안함에 안주하지 말고 한 걸음 더',
      '주변 사람들과의 관계에 더 신경 써보세요'
    ],
    'AB': [
      '오늘은 일관성 있게 행동해보세요',
      '우유부단함을 극복하고 결단력을 발휘하세요',
      '너무 많은 것을 한꺼번에 하지 마세요',
      '감정 기복을 조절하며 안정감을 유지하세요',
      '복잡한 생각은 잠시 내려놓고 단순하게'
    ]
  }

  return selectFromArray(cautions[bloodType], date, `caution-${bloodType}`)
}

// 오늘의 궁합 MBTI 생성
function generateBestMatchToday(date: Date, animal: string): string {
  const allMbti = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ]
  return selectFromArray(allMbti, date, `match-${animal}`)
}

// 오늘의 조언 생성 (날짜 기반으로 다양화)
function generateTodayAdvice(mbti: string, bloodType: string, date: Date): string {
  const advicePool = [
    '오늘은 계획보다 사람에게 집중해보세요',
    '떠오른 아이디어를 하나라도 실행해보세요',
    '즉흥적인 일을 하나 해보며 유연성을 키워보세요',
    '머리로만 생각하지 말고 직접 행동으로 옮겨보세요',
    '다른 사람보다 나 자신을 먼저 챙기는 하루를',
    '한 가지 일에 끝까지 집중해보는 경험을',
    '혼자만의 시간으로 내면을 들여다보세요',
    '작은 것이라도 실행에 옮겨보는 용기를',
    '계획에 없던 재미있는 일을 끼워넣어보세요',
    '다른 사람 눈치 보지 말고 하고 싶은 것을 해보세요',
    '평소와 다른 방법으로 일해보며 변화를 시도하세요',
    '자신의 의견을 더 당당하게 표현해보세요',
    '잠시 멈춰서 주변을 둘러보는 여유를',
    '깊이 있는 대화로 새로운 관계를 만들어보세요',
    '당신의 재능을 다른 사람과 나눠보세요',
    '평소 하지 않던 새로운 도전을 해보세요'
  ]

  return selectFromArray(advicePool, date, `advice-${mbti}-${bloodType}`)
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestData: any = await req.json()
    const {
      userId = 'anonymous',
      name = 'Guest',
      mbti,
      zodiac,
    } = requestData

    // 필드명 변환 지원 (snake_case, camelCase 모두 지원)
    const bloodType = requestData.bloodType || requestData.blood_type
    let zodiacAnimal = requestData.zodiacAnimal || requestData.animal

    // "양띠" → "양" 변환 (띠 제거)
    if (zodiacAnimal && zodiacAnimal.endsWith('띠')) {
      zodiacAnimal = zodiacAnimal.slice(0, -1)
    }

    // ✅ 날짜 파싱 (요청에서 받거나 현재 날짜)
    const dateParam = requestData.date
    const currentDate = dateParam ? new Date(dateParam) : new Date()

    // DNA 코드 생성
    const dnaCode = `${mbti.slice(0, 2)}-${bloodType}${zodiacAnimal.slice(0, 1)}-${Date.now().toString().slice(-4)}`

    // 기본 데이터 가져오기
    const loveStyle = MBTI_LOVE_STYLES[mbti]
    const workStyle = MBTI_WORK_STYLES[mbti]
    const dailyMatching = MBTI_DAILY_MATCHING[mbti]
    const compatibility = COMPATIBILITY_MATCHING[mbti]
    const funStats = FUN_STATS[mbti]

    // 희귀도 결정
    const percentage = parseFloat(funStats.percentage_in_korea)
    let rarityLevel = 'common'
    if (percentage <= 1.5) rarityLevel = 'legendary'
    else if (percentage <= 3.0) rarityLevel = 'epic'
    else if (percentage <= 7.0) rarityLevel = 'rare'
    else if (percentage <= 12.0) rarityLevel = 'uncommon'

    // 소셜 랭킹 (희귀도 기반)
    const socialRanking = rarityLevel === 'legendary' ? Math.floor(Math.random() * 5) + 1 :
                         rarityLevel === 'epic' ? Math.floor(Math.random() * 10) + 1 :
                         rarityLevel === 'rare' ? Math.floor(Math.random() * 20) + 1 :
                         rarityLevel === 'uncommon' ? Math.floor(Math.random() * 40) + 1 :
                         Math.floor(Math.random() * 60) + 20

    // ✅ 데일리 운세 생성 (날짜 기반)
    const dailyFortune = {
      luckyColor: generateLuckyColor(currentDate, mbti),
      luckyNumber: generateLuckyNumber(currentDate, bloodType),
      energyLevel: generateEnergyLevel(currentDate, zodiac),
      recommendedActivity: generateRecommendedActivity(currentDate, mbti),
      caution: generateCaution(currentDate, bloodType),
      bestMatchToday: generateBestMatchToday(currentDate, zodiacAnimal),
    }

    // ✅ 오늘의 하이라이트 생성 (날짜 기반으로 다양화)
    const highlights = [
      `${name}님은 오늘 ${loveStyle.title}의 매력이 빛나는 날이에요!`,
      `오늘의 ${name}님은 에너지 ${dailyFortune.energyLevel}%! 활기찬 하루를 보내세요!`,
      `${name}님의 럭키 컬러는 ${dailyFortune.luckyColor}! 오늘 꼭 활용해보세요!`,
      `오늘의 럭키 넘버 ${dailyFortune.luckyNumber}! ${name}님께 행운이 가득하길!`,
    ]
    const todayHighlight = selectFromArray(highlights, currentDate, `highlight-${mbti}`)

    // ✅ 오늘의 조언 (날짜 기반)
    const todayAdvice = generateTodayAdvice(mbti, bloodType, currentDate)

    const response: PersonalityDNAResponse = {
      dnaCode,
      title: `${loveStyle.title}`,
      emoji: mbti.includes('E') ? '✨' : '🌙',
      todayHighlight,
      loveStyle,
      workStyle,
      dailyMatching,
      compatibility,
      funStats,
      todayAdvice,
      rarityLevel,
      socialRanking,
      dailyFortune,
    }

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error in personality-dna function:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
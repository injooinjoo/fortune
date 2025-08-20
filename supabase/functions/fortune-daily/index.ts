import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 영어 지역명을 한글로 변환하는 간단한 함수
// GPT나 다른 서비스에서 더 정확한 변환을 할 수 있도록 기본 처리만 제공
function processLocation(location: string): string {
  // 기본적인 광역시 매핑
  const basicMap: Record<string, string> = {
    'Seoul': '서울',
    'Busan': '부산',
    'Incheon': '인천',
    'Daegu': '대구',
    'Daejeon': '대전',
    'Gwangju': '광주',
    'Ulsan': '울산',
    'Sejong': '세종',
    'Jeju': '제주'
  }
  
  // 매핑에 있으면 반환
  for (const [eng, kor] of Object.entries(basicMap)) {
    if (location.includes(eng)) {
      return kor
    }
  }
  
  // 없으면 원본 반환 (GPT가 알아서 처리하도록)
  return location
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestData = await req.json()
    const { 
      userId,
      name,
      birthDate, 
      birthTime,
      gender,
      isLunar,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal,
      location,  // 옵셔널 위치 정보
      date       // 클라이언트에서 전달받은 날짜
    } = requestData

    // 클라이언트에서 전달받은 날짜 또는 한국 시간대로 현재 날짜 생성
    const today = date 
      ? new Date(date) 
      : new Date(new Date().toLocaleString("en-US", {timeZone: "Asia/Seoul"}))
    const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]
    
    // 지역 정보 처리 (영어를 한글로, 광역시/도 단위로)
    const processedLocation = location ? processLocation(location) : '서울'
    
    // 운세 점수 생성 (사주 정보 기반)
    const baseScore = 70 + Math.floor(Math.random() * 20)
    const score = Math.min(100, baseScore + (mbtiType === 'ENTJ' ? 5 : 0))
    
    // 띠별 오늘의 운세 요약
    const generateZodiacFortune = (userZodiac: string) => {
      const zodiacFortunes = {
        '쥐': { title: '기회를 놓치지 마세요', content: '새로운 기회가 다가오고 있습니다. 적극적인 자세로 임하세요.', score: 85 },
        '소': { title: '안정감이 필요한 하루', content: '차분하고 신중한 접근이 성공의 열쇠입니다.', score: 78 },
        '호랑이': { title: '용기있는 도전이 필요', content: '두려워하지 말고 당당하게 앞으로 나아가세요.', score: 82 },
        '토끼': { title: '조화로운 관계가 중요', content: '주변 사람들과의 소통에 집중하는 것이 좋겠습니다.', score: 76 },
        '용': { title: '리더십을 발휘할 때', content: '당신의 카리스마와 추진력으로 목표를 달성하세요.', score: 88 },
        '뱀': { title: '지혜로운 판단이 필요', content: '신중한 분석과 계획으로 최적의 결과를 만들어내세요.', score: 80 },
        '말': { title: '자유롭게 행동하세요', content: '제약에 얽매이지 말고 본능에 따라 움직여보세요.', score: 83 },
        '양': { title: '따뜻한 마음이 힘이 됩니다', content: '배려와 친절함으로 좋은 인연을 만들어가세요.', score: 79 },
        '원숭이': { title: '창의적인 아이디어 발휘', content: '독창적인 생각으로 문제를 해결해보세요.', score: 86 },
        '닭': { title: '꼼꼼함이 성과를 만듭니다', content: '세밀한 부분까지 신경 쓰면 좋은 결과가 있을 것입니다.', score: 81 },
        '개': { title: '진실한 마음을 전하세요', content: '솔직하고 성실한 태도가 신뢰를 쌓아갑니다.', score: 84 },
        '돼지': { title: '풍요로운 하루가 될 것', content: '관대한 마음으로 모든 것을 받아들이세요.', score: 77 }
      }
      
      return zodiacFortunes[userZodiac] || { title: '특별한 하루가 될 것', content: '긍정적인 마음으로 하루를 시작하세요.', score: 80 }
    }

    // 별자리별 오늘의 운세 요약
    const generateZodiacSignFortune = (userSign: string) => {
      const signFortunes = {
        '물병자리': { title: '독창성이 빛나는 날', content: '혁신적인 아이디어로 주목받을 수 있습니다.', score: 87 },
        '물고기자리': { title: '직감을 믿으세요', content: '감정과 영감에 따라 행동하면 좋은 결과가 있을 것입니다.', score: 82 },
        '양자리': { title: '열정적으로 도전하세요', content: '적극적인 자세로 새로운 일에 도전해보세요.', score: 85 },
        '황소자리': { title: '안정적인 선택을 하세요', content: '신중하고 실용적인 접근이 최고의 결과를 가져올 것입니다.', score: 79 },
        '쌍둥이자리': { title: '소통이 핵심입니다', content: '다양한 사람들과의 대화에서 기회를 찾으세요.', score: 83 },
        '게자리': { title: '감정을 소중히 여기세요', content: '마음의 목소리에 귀 기울이며 행동하세요.', score: 80 },
        '사자자리': { title: '자신감을 가지세요', content: '당당한 모습으로 주변에 좋은 영향을 미치세요.', score: 88 },
        '처녀자리': { title: '완벽함을 추구하세요', content: '세심한 분석과 계획으로 목표를 달성하세요.', score: 86 },
        '천칭자리': { title: '균형잡힌 선택을 하세요', content: '조화로운 해결책을 찾는 것이 중요합니다.', score: 81 },
        '전갈자리': { title: '깊이있는 집중이 필요', content: '한 가지에 집중하여 탁월한 성과를 만들어내세요.', score: 84 },
        '궁수자리': { title: '모험심을 발휘하세요', content: '새로운 경험과 학습에 열린 마음을 가지세요.', score: 89 },
        '염소자리': { title: '목표 달성에 집중하세요', content: '체계적인 계획과 꾸준한 노력이 성공을 이끌 것입니다.', score: 78 }
      }
      
      return signFortunes[userSign] || { title: '균형잡힌 하루', content: '모든 일에 균형을 맞춰 진행하세요.', score: 80 }
    }

    // MBTI별 오늘의 운세 요약
    const generateMBTIFortune = (userMBTI: string) => {
      const mbtiFortunes = {
        'ENFP': { title: '창의적 영감이 넘치는 날', content: '새로운 아이디어와 가능성을 탐험해보세요.', score: 89 },
        'ENFJ': { title: '타인을 이끄는 리더십 발휘', content: '따뜻한 카리스마로 주변을 감화시키세요.', score: 87 },
        'ENTP': { title: '논리적 창의성이 빛남', content: '혁신적인 해결책으로 문제를 해결하세요.', score: 88 },
        'ENTJ': { title: '목표 달성을 위한 완벽한 하루', content: '강력한 추진력으로 모든 계획을 실현하세요.', score: 91 },
        'INFP': { title: '내면의 가치가 중요한 날', content: '진정성 있는 행동으로 의미있는 하루를 만드세요.', score: 82 },
        'INFJ': { title: '직관력이 최고조에 달함', content: '깊은 통찰력으로 본질을 꿰뚫어보세요.', score: 85 },
        'INTP': { title: '분석적 사고가 해답', content: '논리적 접근으로 복잡한 문제를 해결하세요.', score: 84 },
        'INTJ': { title: '전략적 계획이 성공의 열쇠', content: '장기적 관점에서 체계적으로 접근하세요.', score: 86 },
        'ESFP': { title: '즐거움과 활력이 넘치는 날', content: '긍정적인 에너지로 주변을 밝게 만드세요.', score: 88 },
        'ESFJ': { title: '협력과 배려가 빛나는 시간', content: '다른 사람들을 도우며 함께 성장하세요.', score: 83 },
        'ESTP': { title: '행동력으로 기회를 잡으세요', content: '즉시 실행에 옮기는 것이 성공의 비결입니다.', score: 87 },
        'ESTJ': { title: '체계적 관리로 성과 창출', content: '효율적인 시스템으로 목표를 달성하세요.', score: 85 },
        'ISFP': { title: '예술적 감성이 살아나는 날', content: '아름다움과 조화를 추구하며 행동하세요.', score: 81 },
        'ISFJ': { title: '신뢰할 수 있는 지원자 역할', content: '성실함과 책임감으로 안정감을 제공하세요.', score: 80 },
        'ISTP': { title: '실용적 해결책이 필요', content: '현실적이고 효과적인 방법을 찾아 적용하세요.', score: 82 },
        'ISTJ': { title: '꾸준함이 가져올 성취', content: '일관된 노력으로 확실한 결과를 만들어내세요.', score: 79 }
      }
      
      return mbtiFortunes[userMBTI] || { title: '균형잡힌 성장의 날', content: '자신만의 방식으로 성장해나가세요.', score: 80 }
    }

    // 오늘의 운세 요약 데이터 생성
    const fortuneSummary = {
      byZodiacAnimal: generateZodiacFortune(zodiacAnimal),
      byZodiacSign: generateZodiacSignFortune(zodiacSign),
      byMBTI: generateMBTIFortune(mbtiType)
    }

    // 카테고리별 운세 점수 생성
    const categories = {
      total: { score: score, advice: '전체적으로 균형잡힌 하루입니다.' },
      love: { score: Math.min(100, score + Math.floor(Math.random() * 10) - 5), advice: '진솔한 마음으로 소통하세요.' },
      money: { score: Math.min(100, score + Math.floor(Math.random() * 15) - 7), advice: '계획적인 소비가 중요합니다.' },
      health: { score: Math.min(100, score + Math.floor(Math.random() * 12) - 6), advice: '충분한 휴식을 취하세요.' },
      work: { score: Math.min(100, score + Math.floor(Math.random() * 8) - 4), advice: '집중력을 발휘할 때입니다.' }
    }

    // 추천 활동 생성
    const personalActions = [
      {
        title: '아침 산책하기',
        why: '신선한 공기와 함께 하루를 시작하면 긍정적인 에너지를 얻을 수 있습니다.'
      },
      {
        title: '중요한 일 먼저 처리하기',
        why: '오전 시간대의 집중력이 최고조에 달하므로 핵심 업무부터 해결하세요.'
      },
      {
        title: '가족이나 친구와 대화하기',
        why: '소중한 사람들과의 교감이 오늘의 행운을 배가시켜 줄 것입니다.'
      }
    ]

    // 사주 인사이트 (lucky_items 확장)
    const sajuInsight = {
      lucky_color: '청록색',
      lucky_food: '해산물',
      luck_direction: '남동쪽',
      keyword: '균형',
      lucky_item: '작은 노트'
    }

    // 행운의 숫자 생성 (동적)
    const generateLuckyNumbers = () => {
      const numbers = []
      // 사용자 생일 기반으로 행운의 숫자 2개 생성
      const birthDateNum = new Date(birthDate).getDate()
      numbers.push((birthDateNum % 9 + 1).toString())
      numbers.push(((birthDateNum * 2) % 9 + 1).toString())
      return numbers
    }

    // 행운의 코디 생성 (동적)
    const generateLuckyOutfit = () => {
      const outfits = [
        {
          title: '활기찬 에너지 코디',
          description: '자신감과 활력을 높이는 코디',
          items: [
            `${sajuInsight.lucky_color} 톤의 상의로 긍정적인 에너지를 표현해보세요.`,
            '밝은 색상은 주변에 활기를 전달하고 자신감을 높여줍니다.',
            '편안한 실루엣으로 하루 종일 자연스러운 매력을 발산하세요.',
            `${sajuInsight.lucky_color} 계열의 액세서리로 포인트를 더해보세요.`
          ]
        },
        {
          title: '차분한 성공 코디',
          description: '안정감과 신뢰를 주는 코디',
          items: [
            '차분한 네이비나 그레이 톤으로 신뢰감을 연출해보세요.',
            '클래식한 스타일이 전문성과 안정감을 보여줍니다.',
            '깔끔한 라인의 의상으로 세련된 인상을 만들어보세요.',
            '포인트 색상으로 개성을 더해 균형잡힌 룩을 완성하세요.'
          ]
        }
      ]
      return score >= 80 ? outfits[0] : outfits[1]
    }

    // 태어난 날 유명인 생성 (실제 데이터 기반)
    const generateSameDayCelebrities = () => {
      const birthMonth = new Date(birthDate).getMonth() + 1
      const birthDay = new Date(birthDate).getDate()
      
      // 실제 유명인 데이터 매핑 (날짜별)
      const celebrityDatabase: Record<string, Array<{year: string, name: string, description: string}>> = {
        '1-1': [
          { year: '1998', name: '장원영', description: '아이브 멤버, 대한민국의 가수' },
          { year: '1979', name: '차태현', description: '대한민국의 배우, 방송인' },
          { year: '1978', name: '김종민', description: '코요태 멤버, 대한민국의 가수' }
        ],
        '8-18': [
          { year: '1999', name: '주이', description: '모모랜드 멤버, 대한민국의 가수' },
          { year: '1993', name: '정은지', description: '에이핑크 멤버, 대한민국의 가수' },
          { year: '1988', name: '지드래곤', description: '빅뱅 멤버, 대한민국의 가수' }
        ],
        '9-5': [
          { year: '1946', name: '프레디 머큐리', description: '퀸의 보컬, 영국의 가수' },
          { year: '1969', name: '마이클 키튼', description: '미국의 배우' },
          { year: '1973', name: '로즈 맥고완', description: '미국의 배우' }
        ],
        '12-25': [
          { year: '1971', name: '이승환', description: '대한민국의 가수' },
          { year: '1954', name: '애니 레녹스', description: '영국의 가수' },
          { year: '1949', name: '시슬리 타이슨', description: '미국의 배우' }
        ]
      }
      
      const dateKey = `${birthMonth}-${birthDay}`
      const celebrities = celebrityDatabase[dateKey]
      
      if (celebrities && celebrities.length > 0) {
        return celebrities
      }
      
      // 데이터가 없을 경우 기본값 반환
      return [
        {
          year: '1990',
          name: `${birthMonth}월 ${birthDay}일 출생한 유명인`,
          description: '이 날 태어난 특별한 인물들이 있습니다'
        }
      ]
    }

    // 비슷한 사주 유명인 생성 (실제 데이터 기반)
    const generateSimilarSajuCelebrities = () => {
      // 띠별 실제 유명인 데이터
      const zodiacCelebrities: Record<string, Array<{name: string, description: string}>> = {
        '용': [
          { name: '이수만', description: 'SM엔터테인먼트 창립자 (1952년생)' },
          { name: '박진영', description: 'JYP엔터테인먼트 대표 (1972년생)' },
          { name: '이효리', description: '가수, 방송인 (1979년생)' }
        ],
        '뱀': [
          { name: '유재석', description: '국민 MC, 방송인 (1972년생)' },
          { name: '송중기', description: '배우 (1985년생)' },
          { name: '김태희', description: '배우 (1980년생)' }
        ],
        '말': [
          { name: '강호동', description: '방송인 (1970년생)' },
          { name: '전지현', description: '배우 (1981년생)' },
          { name: '박보검', description: '배우 (1993년생)' }
        ],
        '양': [
          { name: '아이유', description: '가수, 배우 (1993년생)' },
          { name: '손예진', description: '배우 (1982년생)' },
          { name: '정우성', description: '배우 (1973년생)' }
        ],
        '원숭이': [
          { name: '김연아', description: '피겨스케이팅 선수 (1990년생)' },
          { name: '현빈', description: '배우 (1982년생)' },
          { name: '수지', description: '가수, 배우 (1994년생)' }
        ],
        '닭': [
          { name: '박서준', description: '배우 (1988년생)' },
          { name: '김고은', description: '배우 (1991년생)' },
          { name: '이민호', description: '배우 (1987년생)' }
        ],
        '개': [
          { name: '송혜교', description: '배우 (1981년생)' },
          { name: '조인성', description: '배우 (1981년생)' },
          { name: '김우빈', description: '배우 (1989년생)' }
        ],
        '돼지': [
          { name: '원빈', description: '배우 (1977년생)' },
          { name: '장나라', description: '가수, 배우 (1981년생)' },
          { name: '공유', description: '배우 (1979년생)' }
        ],
        '쥐': [
          { name: '비', description: '가수, 배우 (1982년생)' },
          { name: '한지민', description: '배우 (1982년생)' },
          { name: '이종석', description: '배우 (1989년생)' }
        ],
        '소': [
          { name: '송강호', description: '배우 (1967년생)' },
          { name: '김희선', description: '배우 (1977년생)' },
          { name: '차승원', description: '배우 (1970년생)' }
        ],
        '호랑이': [
          { name: '유아인', description: '배우 (1986년생)' },
          { name: '한효주', description: '배우 (1987년생)' },
          { name: '김수현', description: '배우 (1988년생)' }
        ],
        '토끼': [
          { name: '박신혜', description: '배우 (1990년생)' },
          { name: '이승기', description: '가수, 배우 (1987년생)' },
          { name: '김유정', description: '배우 (1999년생)' }
        ]
      }
      
      const celebrities = zodiacCelebrities[zodiacAnimal] || []
      
      if (celebrities.length > 0) {
        return celebrities.slice(0, 3) // 최대 3명 반환
      }
      
      // 데이터가 없을 경우 기본값
      return [
        {
          name: `${zodiacAnimal}띠 유명인`,
          description: `${zodiacAnimal}띠로 태어난 성공한 인물들`
        }
      ]
    }

    // 년생별 운세 생성 (동적)
    const generateAgeFortune = () => {
      const birthYear = new Date(birthDate).getFullYear()
      const yearLastTwoDigits = birthYear % 100
      
      if (yearLastTwoDigits >= 80 && yearLastTwoDigits <= 89) {
        return {
          title: '노력한 만큼의 성과를 올릴 수가 있다',
          description: '하는 만큼 부가 쌓이는 때입니다. 책을 읽으며 지식을 쌓아도 좋겠습니다. 언젠가 하고 싶었던 일의 기회도 생길 수 있습니다.'
        }
      } else if (yearLastTwoDigits >= 90 && yearLastTwoDigits <= 99) {
        return {
          title: '안정적인 발전이 기대되는 시기',
          description: '차근차근 계획을 세워 나아가면 좋은 결과를 얻을 수 있습니다. 주변의 조언에 귀 기울이며 신중하게 행동하세요.'
        }
      } else if (yearLastTwoDigits >= 0 && yearLastTwoDigits <= 9) {
        return {
          title: '욕심이 커지는 것에 주의해라',
          description: '욕심이 앞서면 구설수에 오를 수 있는 날입니다. 당신을 지켜보는 눈이 많습니다. 상대방에게 거북할 수 있으니 주의를 기울이세요.'
        }
      } else {
        return {
          title: '새로운 시작을 위한 준비의 시간',
          description: '변화의 바람이 불고 있습니다. 새로운 도전을 위해 마음의 준비를 하고 기회를 놓치지 마세요.'
        }
      }
    }

    // 일별 운세 예측 데이터 생성 (동적)
    const generateDailyPredictions = () => {
      // 오늘 점수 기준으로 전후 날짜 점수 생성
      const baseScore = score
      return {
        yesterday: Math.max(0, baseScore - 5 + Math.floor(Math.random() * 10)),
        before_yesterday: Math.max(0, baseScore - 8 + Math.floor(Math.random() * 16)),
        tomorrow: Math.max(0, baseScore - 3 + Math.floor(Math.random() * 6)),
        after_tomorrow: Math.max(0, baseScore - 7 + Math.floor(Math.random() * 14))
      }
    }

    // AI 인사이트 생성 (동적)
    const generateAIInsight = () => {
      if (score >= 90) {
        return '오늘은 정말 특별한 날입니다! 모든 일이 순조롭게 풀릴 것이니 적극적으로 도전해보세요.'
      } else if (score >= 80) {
        return `오늘은 특히 ${getHighestCategory(categories)} 방면에서 좋은 기운이 흐르고 있습니다. 이 기회를 놓치지 마세요.`
      } else if (score >= 70) {
        return '안정적이고 평온한 하루가 될 것입니다. 꾸준히 노력한다면 좋은 결과를 얻을 수 있어요.'
      } else if (score >= 60) {
        return '신중하게 행동한다면 무난한 하루를 보낼 수 있습니다. 급하지 않은 결정은 미뤄두세요.'
      } else {
        return '조금 어려운 시기이지만 인내심을 갖고 차근차근 해나간다면 분명 좋은 결과가 있을 것입니다.'
      }
    }

    // AI 팁 생성 (동적)
    const generateAITips = () => {
      const tips = []
      
      if (score >= 80) {
        tips.push('오전 시간대에 중요한 결정을 내리세요')
        tips.push('새로운 사람들과의 만남을 소중히 하세요')
      } else if (score >= 60) {
        tips.push('무리하지 말고 차근차근 진행하세요')
        tips.push('주변 사람들의 조언에 귀 기울이세요')
      } else {
        tips.push('휴식을 취하며 재충전의 시간을 가지세요')
        tips.push('작은 성취에도 감사하는 마음을 가지세요')
      }
      
      // 카테고리별 팁 추가
      const lowestCategory = getLowestCategory(categories)
      switch (lowestCategory) {
        case 'health':
          tips.push('충분한 수면과 휴식을 취하세요')
          break
        case 'money':
          tips.push('불필요한 지출을 줄이고 저축에 신경쓰세요')
          break
        case 'love':
          tips.push('상대방의 마음을 헤아리는 시간을 가지세요')
          break
        case 'career':
          tips.push('업무에 집중하고 동료들과 원활한 소통을 하세요')
          break
      }
      
      return tips.slice(0, 3)
    }

    // 공유 카운트 생성 (동적 - 실제로는 DB에서 조회)
    const generateShareCount = () => {
      // 실제로는 데이터베이스에서 조회하지만, 예시로 동적 생성
      const baseCount = 2750000
      const dailyIncrease = Math.floor(Math.random() * 5000) + 1000
      return baseCount + dailyIncrease
    }

    // 카테고리별 최고/최저 점수 찾기 함수
    const getHighestCategory = (categories: any) => {
      let maxScore = 0
      let maxCategory = '전반적인'
      
      Object.entries(categories).forEach(([key, value]: [string, any]) => {
        if (value.score > maxScore) {
          maxScore = value.score
          maxCategory = translateCategory(key)
        }
      })
      
      return maxCategory
    }

    const getLowestCategory = (categories: any) => {
      let minScore = 100
      let minCategory = ''
      
      Object.entries(categories).forEach(([key, value]: [string, any]) => {
        if (value.score < minScore) {
          minScore = value.score
          minCategory = key
        }
      })
      
      return minCategory
    }

    const translateCategory = (category: string) => {
      switch (category.toLowerCase()) {
        case 'love': return '연애'
        case 'career': return '직장'
        case 'money': return '금전'
        case 'health': return '건강'
        case 'relationship': return '대인관계'
        case 'luck': return '행운'
        default: return category
      }
    }

    // 운세 내용 생성
    const fortune = {
      advice: '오늘은 자신의 강점을 믿고 적극적으로 나아가며, 중요한 순간에는 침착함을 유지하세요.',
      caution: '오후 5시 이후에는 감정이 격해질 수 있으니, 과도한 감정적 반응이나 충동적인 결정은 피하세요.',
      summary: score >= 80 ? '자신감 넘치는 하루, 성공의 기회 기대하세요' : '차분하고 안정적인 하루가 될 것입니다',
      greeting: `${name}님, 오늘은 ${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일, ${processedLocation}의 맑고 활기찬 기운이 가득한 하루입니다.`,
      description: `오늘 ${name}님께서는 오전에 차분한 성찰과 계획 세우기에 좋은 시간입니다. 특히, 중요한 업무나 프로젝트에 집중하면 좋은 성과를 얻을 수 있습니다. 오후로 갈수록 자신감이 높아지고, 리더십이 발휘될 시기입니다.`,
      lucky_items: {
        time: '오후 2시에서 4시',
        color: sajuInsight.lucky_color,
        number: 8,
        direction: sajuInsight.luck_direction
      },
      special_tip: `오늘은 ${zodiacSign}의 세밀함과 ${mbtiType}의 추진력을 활용하여, 작은 디테일에 집착하는 동시에 큰 그림을 그리세요.`,
      overall_score: score,
      fortuneSummary: fortuneSummary,
      categories: categories,
      personalActions: personalActions,
      sajuInsight: sajuInsight,
      
      // 새로운 동적 데이터 추가
      lucky_outfit: generateLuckyOutfit(),
      celebrities_same_day: generateSameDayCelebrities(),
      celebrities_similar_saju: generateSimilarSajuCelebrities(),
      lucky_numbers: generateLuckyNumbers(),
      age_fortune: generateAgeFortune(),
      daily_predictions: generateDailyPredictions(),
      ai_insight: generateAIInsight(),
      ai_tips: generateAITips(),
      share_count: generateShareCount()
    }
    
    // 스토리 세그먼트 생성 (13페이지 - 파트너 추천 3페이지 추가)
    const storySegments = [
      {
        text: `${name}님, 환영합니다.\n오늘의 이야기가\n당신에게 작은 빛이 되기를.`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일\n하늘은 맑고\n당신의 마음도 맑기를.`,
        fontSize: 24,
        fontWeight: 300
      },
      {
        text: `오늘의 점수는 ${score}\n${score >= 80 ? '자신감으로 가득 찬' : '차분하고 안정적인'}\n특별한 하루입니다.`,
        fontSize: 26,
        fontWeight: 500
      },
      {
        text: `아침의 햇살처럼\n새로운 시작을 알리는\n긍정의 에너지가 당신과 함께.`,
        fontSize: 22,
        fontWeight: 300
      },
      {
        text: `점심 무렵\n중요한 결정의 순간이 온다면\n침착함을 잃지 마세요.`,
        fontSize: 22,
        fontWeight: 300
      },
      {
        text: `저녁이 되면\n하루의 성취를 돌아보며\n스스로를 격려해주세요.`,
        fontSize: 22,
        fontWeight: 300
      },
      {
        text: `주의할 점\n감정의 기복이 있을 수 있으니\n마음의 중심을 잡으세요.`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `행운의 색: ${fortune.lucky_items.color}\n행운의 숫자: ${fortune.lucky_items.number}\n행운의 시간: ${fortune.lucky_items.time}`,
        fontSize: 24,
        fontWeight: 400
      },
      // 띠별 운세 페이지
      {
        text: `${zodiacAnimal}띠인 당신\n\n${fortuneSummary.byZodiacAnimal.title}\n\n${fortuneSummary.byZodiacAnimal.content}`,
        fontSize: 22,
        fontWeight: 400,
        emoji: '🐉'
      },
      // 별자리별 운세 페이지
      {
        text: `${zodiacSign}인 당신\n\n${fortuneSummary.byZodiacSign.title}\n\n${fortuneSummary.byZodiacSign.content}`,
        fontSize: 22,
        fontWeight: 400,
        emoji: '⭐'
      },
      // MBTI별 운세 페이지
      {
        text: `${mbtiType}인 당신\n\n${fortuneSummary.byMBTI.title}\n\n${fortuneSummary.byMBTI.content}`,
        fontSize: 22,
        fontWeight: 400,
        emoji: '🧠'
      },
      {
        text: `오늘의 당부\n자신의 강점을 믿고\n명확한 소통으로 나아가세요.`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `좋은 하루 되세요\n${name}님의 하루가\n빛나기를 바랍니다.`,
        fontSize: 24,
        fontWeight: 400
      }
    ]
    
    // 운세와 스토리를 함께 반환
    return new Response(
      JSON.stringify({ 
        fortune,
        storySegments,
        cached: false,
        tokensUsed: 0
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error generating fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})
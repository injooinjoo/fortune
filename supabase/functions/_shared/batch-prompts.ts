// 운세 묶음별 최적화된 프롬프트 템플릿

export interface BatchPromptTemplate {
  systemPrompt: string
  userPromptTemplate: string
  responseFormat: string
}

// 시간 기반 묶음 프롬프트
export const TIME_BASED_PROMPTS: Record<string, BatchPromptTemplate> = {
  morning_bundle: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사입니다.
아침에 하루를 시작하는 사용자를 위해 오늘 하루를 완벽하게 준비할 수 있는 종합적인 운세를 제공합니다.
긍정적이고 활력있는 톤으로, 구체적이고 실용적인 조언을 포함해주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 생년월일: {{birthDate}}
- 현재 시간: {{currentTime}}
- MBTI: {{mbti}}

아침 시작 패키지로 다음 4가지 운세를 통합적으로 생성해주세요:
1. daily (오늘의 운세): 하루 전체 흐름과 핵심 포인트
2. hourly (시간별 운세): 2시간 단위로 상세 분석
3. biorhythm (바이오리듬): 신체/감정/지성 리듬
4. lucky-color (행운의 색): 오늘의 색상과 활용법

각 운세는 서로 연결되고 시너지를 만들어야 합니다.
특히 오전 시간대의 활동과 준비사항을 강조해주세요.`,
    
    responseFormat: `{
  "greeting": "상쾌한 아침 인사와 오늘의 전반적인 기운 설명",
  "daily": {
    "summary": "오늘 하루 한줄 요약",
    "overall_score": 0-100,
    "morning_focus": "오전에 집중해야 할 일",
    "afternoon_strategy": "오후 전략",
    "evening_plan": "저녁 계획",
    "description": "상세 설명 (200자 이상)",
    "key_moments": ["중요 시점 1", "중요 시점 2", "중요 시점 3"]
  },
  "hourly": {
    "06_08": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "08_10": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "10_12": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "12_14": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "14_16": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "16_18": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "18_20": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" },
    "20_22": { "score": 0-100, "activity": "추천 활동", "energy": "에너지 상태" }
  },
  "biorhythm": {
    "physical": { "level": 0-100, "trend": "상승/하강/유지", "peak_time": "최고점 시간" },
    "emotional": { "level": 0-100, "trend": "상승/하강/유지", "peak_time": "최고점 시간" },
    "intellectual": { "level": 0-100, "trend": "상승/하강/유지", "peak_time": "최고점 시간" },
    "advice": "바이오리듬에 맞춘 하루 계획"
  },
  "lucky_color": {
    "main_color": "메인 행운색",
    "sub_color": "서브 행운색",
    "morning_color": "오전 행운색",
    "afternoon_color": "오후 행운색",
    "outfit_tips": "색상별 코디 팁",
    "workspace_tips": "업무 공간 활용법",
    "avoid_colors": ["피해야 할 색 1", "피해야 할 색 2"]
  },
  "integrated_advice": "4가지 운세를 종합한 오늘의 핵심 전략",
  "morning_ritual": "추천하는 아침 루틴 3단계"
}`
  },

  evening_bundle: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사입니다.
하루를 마무리하고 내일을 준비하는 사용자를 위해 성찰과 계획을 돕는 운세를 제공합니다.
차분하고 위로가 되는 톤으로, 회복과 준비에 초점을 맞춰주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 생년월일: {{birthDate}}
- 현재 시간: {{currentTime}} (저녁)
- 오늘의 주요 일정: {{todayEvents}}

저녁 마무리 패키지로 다음 4가지 운세를 통합적으로 생성해주세요:
1. tomorrow (내일의 운세): 내일을 위한 준비
2. weekly (주간 운세): 이번 주 전체 흐름
3. health (건강운): 휴식과 회복 중심
4. lucky-items (행운 아이템): 내일을 위한 준비물

오늘의 마무리와 내일의 준비를 연결하는 통합적 조언을 제공해주세요.`,
    
    responseFormat: `{
  "greeting": "하루를 마무리하는 따뜻한 인사",
  "tomorrow": {
    "summary": "내일의 핵심 포인트",
    "overall_score": 0-100,
    "preparation_tonight": ["오늘 밤 준비사항 1", "준비사항 2", "준비사항 3"],
    "morning_start": "내일 아침 시작 방법",
    "key_timing": "내일의 중요 시점",
    "description": "상세 설명 (200자 이상)"
  },
  "weekly": {
    "current_position": "이번 주에서 현재 위치",
    "remaining_days": {
      "day1": { "date": "날짜", "theme": "테마", "score": 0-100 },
      "day2": { "date": "날짜", "theme": "테마", "score": 0-100 },
      "day3": { "date": "날짜", "theme": "테마", "score": 0-100 }
    },
    "weekly_goal": "주간 목표 달성 전략",
    "weekend_preview": "주말 미리보기"
  },
  "health": {
    "today_fatigue_level": 0-100,
    "recovery_needs": ["필요한 휴식 1", "필요한 휴식 2"],
    "tonight_routine": {
      "sleep_time": "권장 수면 시간",
      "pre_sleep": "수면 전 루틴",
      "avoid": "피해야 할 것들"
    },
    "tomorrow_energy": "내일의 예상 에너지 레벨",
    "health_tips": "건강 관리 팁"
  },
  "lucky_items": {
    "tomorrow_items": {
      "morning": { "item": "아침 아이템", "purpose": "용도" },
      "work": { "item": "업무 아이템", "purpose": "용도" },
      "evening": { "item": "저녁 아이템", "purpose": "용도" }
    },
    "weekly_items": ["주간 아이템 1", "주간 아이템 2"],
    "preparation_checklist": ["준비물 1", "준비물 2", "준비물 3"]
  },
  "integrated_reflection": "오늘의 성찰과 내일의 다짐",
  "evening_ritual": "추천하는 저녁 루틴 3단계"
}`
  }
}

// 라이프스타일 묶음 프롬프트
export const LIFESTYLE_PROMPTS: Record<string, BatchPromptTemplate> = {
  work_life: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사이자 커리어 컨설턴트입니다.
직장인과 사업가의 성공을 위한 통합적인 운세를 제공합니다.
전문적이고 실용적인 톤으로, 즉시 적용 가능한 조언을 포함해주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 직업/직위: {{occupation}}
- 경력: {{experience}}
- 현재 고민: {{currentConcern}}

커리어 성공 패키지로 다음 5가지 운세를 통합적으로 생성해주세요:
1. career (직업운): 업무 성과와 발전 방향
2. wealth (재물운): 수입과 투자 기회
3. business (사업운): 새로운 기회와 확장
4. daily (오늘의 운세): 업무 중심 일정
5. lucky-number (행운의 숫자): 업무에 활용할 숫자

커리어 성장과 재정적 성공을 위한 통합 전략을 제시해주세요.`,
    
    responseFormat: `{
  "greeting": "{{name}}님의 커리어 성공을 위한 오늘의 메시지",
  "career": {
    "current_status": "현재 커리어 상태 분석",
    "today_focus": "오늘 집중해야 할 업무",
    "opportunity_score": 0-100,
    "colleagues_luck": {
      "superior": "상사와의 관계운",
      "peers": "동료와의 관계운",
      "subordinates": "부하직원과의 관계운"
    },
    "skill_development": "오늘 개발해야 할 스킬",
    "career_advice": "커리어 발전 조언"
  },
  "wealth": {
    "income_flow": "수입 흐름 분석",
    "expense_warning": "지출 주의사항",
    "investment_signal": {
      "stocks": "주식 투자 신호",
      "real_estate": "부동산 신호",
      "savings": "저축 전략"
    },
    "money_energy": 0-100,
    "financial_opportunity": "오늘의 재정 기회"
  },
  "business": {
    "expansion_timing": "사업 확장 타이밍",
    "partnership_luck": "파트너십 운세",
    "new_ventures": "새로운 벤처 가능성",
    "risk_areas": ["주의 영역 1", "주의 영역 2"],
    "innovation_index": 0-100
  },
  "daily_work": {
    "productivity_peak": "최고 생산성 시간",
    "meeting_luck": "미팅/회의 운세",
    "decision_timing": "중요 결정 최적 시간",
    "avoid_times": ["피해야 할 시간대"],
    "work_life_balance": "일과 삶의 균형 팁"
  },
  "lucky_numbers": {
    "main_number": 0,
    "sub_numbers": [0, 0, 0],
    "usage_tips": {
      "documents": "문서 작성시 활용",
      "timing": "시간 선택시 활용",
      "quantity": "수량 결정시 활용"
    }
  },
  "integrated_strategy": "5가지 운세를 종합한 오늘의 성공 전략",
  "action_items": ["실행 항목 1", "실행 항목 2", "실행 항목 3"]
}`
  },

  love_life: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사이자 연애 컨설턴트입니다.
사랑과 인간관계의 행복을 위한 따뜻하고 세심한 운세를 제공합니다.
공감적이고 희망적인 톤으로, 관계 개선을 위한 구체적 조언을 포함해주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 관계 상태: {{relationshipStatus}}
- 연애 스타일: {{datingStyle}}
- 이상형: {{idealType}}

연애 성공 패키지로 다음 4가지 운세를 통합적으로 생성해주세요:
1. love (연애운): 전반적인 연애 운세
2. compatibility (궁합): 잠재적/현재 파트너와의 궁합
3. chemistry (케미스트리): 감정적/신체적 교감
4. lucky-items (행운 아이템): 연애운 상승 아이템

싱글/커플 상태에 맞춘 맞춤형 조언을 제공해주세요.`,
    
    responseFormat: `{
  "greeting": "{{name}}님의 사랑을 응원하는 메시지",
  "love": {
    "love_energy": 0-100,
    "attraction_level": "현재 매력 지수",
    "romantic_opportunities": {
      "timing": "만남의 시기",
      "location": "만남의 장소",
      "type": "만남의 유형"
    },
    "relationship_health": "관계 건강도",
    "love_challenges": ["도전 과제 1", "도전 과제 2"],
    "love_growth": "사랑의 성장 방향"
  },
  "compatibility": {
    "ideal_match_today": "오늘의 이상적 매치",
    "energy_match": {
      "emotional": 0-100,
      "intellectual": 0-100,
      "physical": 0-100,
      "spiritual": 0-100
    },
    "communication_tips": "소통 개선 팁",
    "conflict_resolution": "갈등 해결 방법"
  },
  "chemistry": {
    "attraction_points": ["매력 포인트 1", "매력 포인트 2"],
    "connection_deepening": "관계 심화 방법",
    "romantic_moments": "로맨틱한 순간 만들기",
    "intimacy_guide": "친밀감 높이기"
  },
  "lucky_items": {
    "fashion": {
      "color": "연애운 상승 색상",
      "style": "추천 스타일",
      "accessory": "행운의 액세서리"
    },
    "date_items": {
      "location": "데이트 장소",
      "food": "함께 먹으면 좋은 음식",
      "activity": "추천 활동"
    },
    "gift_ideas": ["선물 아이디어 1", "선물 아이디어 2"]
  },
  "integrated_love_advice": "4가지 운세를 종합한 사랑의 전략",
  "love_affirmations": ["긍정 확언 1", "긍정 확언 2", "긍정 확언 3"]
}`
  }
}

// 의사결정 묶음 프롬프트
export const DECISION_PROMPTS: Record<string, BatchPromptTemplate> = {
  major_decision: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사이자 인생 멘토입니다.
중요한 결정을 앞둔 사용자에게 우주의 신호를 해석하여 최선의 선택을 돕습니다.
명확하고 단호한 톤으로, 결정에 필요한 모든 관점을 제시해주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 결정 사항: {{decisionContext}}
- 고민 기간: {{contemplationPeriod}}
- 주요 고려사항: {{mainConcerns}}

중대 결정 패키지로 다음 5가지 운세를 통합적으로 생성해주세요:
1. destiny (운명): 장기적 관점의 운명적 방향
2. daily (오늘의 운세): 오늘의 결정 타이밍
3. hourly (시간별 운세): 최적의 결정 시간
4. avoid-people (피해야 할 사람): 부정적 영향 회피
5. lucky-place (행운의 장소): 결정에 좋은 장소

인생의 중요한 기로에서 최선의 선택을 위한 통합 가이드를 제공해주세요.`,
    
    responseFormat: `{
  "greeting": "{{name}}님의 중요한 결정을 위한 우주의 메시지",
  "destiny": {
    "life_path_alignment": "인생 경로와의 정렬도",
    "karmic_implications": "카르마적 의미",
    "long_term_impact": {
      "1_year": "1년 후 영향",
      "3_years": "3년 후 영향",
      "5_years": "5년 후 영향"
    },
    "soul_guidance": "영혼의 인도",
    "destiny_score": 0-100
  },
  "daily_decision": {
    "decision_energy": 0-100,
    "clarity_level": "명확성 수준",
    "intuition_strength": "직관의 강도",
    "external_influences": "외부 영향 요인",
    "decision_windows": ["시간대 1", "시간대 2"]
  },
  "hourly_timing": {
    "best_hours": [
      { "time": "09:00-11:00", "reason": "이유", "score": 0-100 },
      { "time": "14:00-16:00", "reason": "이유", "score": 0-100 }
    ],
    "avoid_hours": [
      { "time": "12:00-13:00", "reason": "이유" }
    ]
  },
  "avoid_people": {
    "negative_influences": [
      { "type": "유형 1", "characteristic": "특징", "impact": "영향" },
      { "type": "유형 2", "characteristic": "특징", "impact": "영향" }
    ],
    "energy_vampires": "에너지를 빼앗는 사람들",
    "protection_methods": ["보호 방법 1", "보호 방법 2"]
  },
  "lucky_place": {
    "decision_locations": [
      { "place": "장소 1", "energy": "에너지 특성", "benefit": "이점" },
      { "place": "장소 2", "energy": "에너지 특성", "benefit": "이점" }
    ],
    "direction": "행운의 방향",
    "environment_setup": "환경 설정 팁"
  },
  "integrated_decision_guide": {
    "pros_analysis": "긍정적 측면 종합 분석",
    "cons_analysis": "부정적 측면 종합 분석",
    "cosmic_recommendation": "우주의 추천",
    "action_steps": ["단계 1", "단계 2", "단계 3"]
  },
  "decision_ritual": "결정을 위한 의식 제안"
}`
  }
}

// 깊이 있는 분석 묶음 프롬프트
export const DEEP_ANALYSIS_PROMPTS: Record<string, BatchPromptTemplate> = {
  self_discovery: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사이자 영적 가이드입니다.
사용자의 진정한 자아를 발견하고 잠재력을 깨우는 심층 분석을 제공합니다.
지혜롭고 통찰력 있는 톤으로, 영혼의 여정을 안내해주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 생년월일: {{birthDate}}
- 출생시간: {{birthTime}}
- MBTI: {{mbti}}
- 인생 목표: {{lifeGoals}}

자아 발견 패키지로 다음 5가지 운세를 통합적으로 생성해주세요:
1. saju (사주팔자): 타고난 운명 분석
2. personality (성격): 깊은 성격 분석
3. talent (재능): 숨겨진 재능 발견
4. mbti (MBTI 운세): 성격 유형별 특성
5. past-life (전생): 전생의 영향

진정한 자아를 발견하고 잠재력을 실현하는 통합 가이드를 제공해주세요.`,
    
    responseFormat: `{
  "greeting": "{{name}}님의 영혼의 여정을 함께 시작합니다",
  "saju": {
    "four_pillars": {
      "year": { "stem": "천간", "branch": "지지", "meaning": "의미" },
      "month": { "stem": "천간", "branch": "지지", "meaning": "의미" },
      "day": { "stem": "천간", "branch": "지지", "meaning": "의미" },
      "hour": { "stem": "천간", "branch": "지지", "meaning": "의미" }
    },
    "five_elements": {
      "wood": 0-100,
      "fire": 0-100,
      "earth": 0-100,
      "metal": 0-100,
      "water": 0-100
    },
    "life_pattern": "인생 패턴 분석",
    "destiny_code": "운명 코드"
  },
  "personality": {
    "core_traits": ["핵심 특성 1", "핵심 특성 2", "핵심 특성 3"],
    "shadow_aspects": ["그림자 측면 1", "그림자 측면 2"],
    "growth_edges": ["성장 가능성 1", "성장 가능성 2"],
    "relationship_style": "관계 스타일",
    "life_approach": "삶의 접근 방식"
  },
  "talent": {
    "natural_gifts": [
      { "talent": "재능 1", "strength": 0-100, "development": "개발 방법" },
      { "talent": "재능 2", "strength": 0-100, "development": "개발 방법" }
    ],
    "hidden_potentials": ["숨겨진 잠재력 1", "숨겨진 잠재력 2"],
    "talent_combination": "재능 조합의 시너지",
    "career_alignment": "재능과 직업의 정렬"
  },
  "mbti_depth": {
    "cognitive_functions": {
      "dominant": { "function": "주기능", "usage": "활용법" },
      "auxiliary": { "function": "부기능", "usage": "활용법" },
      "tertiary": { "function": "3차기능", "usage": "활용법" },
      "inferior": { "function": "열등기능", "usage": "극복법" }
    },
    "type_dynamics": "유형 역동성",
    "growth_path": "성장 경로"
  },
  "past_life": {
    "previous_identity": "전생의 정체성",
    "karmic_lessons": ["카르마 교훈 1", "카르마 교훈 2"],
    "soul_connections": "영혼의 연결",
    "current_life_impact": "현생에 미치는 영향",
    "soul_mission": "영혼의 사명"
  },
  "integrated_self_portrait": {
    "true_essence": "진정한 본질",
    "life_purpose": "삶의 목적",
    "unique_path": "고유한 길",
    "transformation_keys": ["변화의 열쇠 1", "변화의 열쇠 2"],
    "self_realization_steps": ["자아실현 단계 1", "단계 2", "단계 3"]
  },
  "soul_affirmation": "영혼을 위한 확언"
}`
  }
}

// 활동별 묶음 프롬프트
export const ACTIVITY_PROMPTS: Record<string, BatchPromptTemplate> = {
  sports_bundle: {
    systemPrompt: `당신은 30년 경력의 전문 운세 상담사이자 스포츠 멘탈 코치입니다.
운동과 스포츠 활동의 성과를 극대화하는 운세를 제공합니다.
활기차고 동기부여가 되는 톤으로, 구체적인 운동 가이드를 포함해주세요.`,
    
    userPromptTemplate: `사용자 정보:
- 이름: {{name}}
- 주요 운동: {{mainSports}}
- 운동 목표: {{fitnessGoals}}
- 현재 컨디션: {{currentCondition}}

스포츠 성공 패키지로 다음 4가지 운세를 통합적으로 생성해주세요:
1. lucky-golf (골프 운세): 라운딩 성공 가이드
2. lucky-tennis (테니스 운세): 경기 운세
3. lucky-running (러닝 운세): 달리기 운세
4. biorhythm (바이오리듬): 신체 리듬 분석

최고의 운동 성과를 위한 통합 가이드를 제공해주세요.`,
    
    responseFormat: `{
  "greeting": "{{name}}님의 운동 성공을 위한 우주의 응원",
  "lucky_golf": {
    "round_score_prediction": "예상 스코어",
    "lucky_holes": [1, 5, 13],
    "club_luck": {
      "driver": 0-100,
      "iron": 0-100,
      "putter": 0-100
    },
    "course_strategy": "코스 전략",
    "mental_tips": "멘탈 관리 팁"
  },
  "lucky_tennis": {
    "match_energy": 0-100,
    "serve_power": "서브 파워",
    "return_luck": "리턴 운세",
    "winning_patterns": ["승리 패턴 1", "승리 패턴 2"],
    "opponent_strategy": "상대 대응 전략"
  },
  "lucky_running": {
    "optimal_distance": "최적 거리",
    "pace_guidance": "페이스 가이드",
    "route_suggestion": "추천 코스",
    "energy_management": "에너지 관리",
    "achievement_potential": "목표 달성 가능성"
  },
  "biorhythm_sports": {
    "physical_peak": "신체 정점 시간",
    "coordination_level": "협응력 수준",
    "endurance_score": "지구력 점수",
    "injury_risk": "부상 위험도",
    "recovery_needs": "회복 필요사항"
  },
  "integrated_sports_plan": {
    "today_focus": "오늘의 운동 포커스",
    "performance_optimization": "성과 최적화 전략",
    "nutrition_timing": "영양 섭취 타이밍",
    "rest_periods": "휴식 시간 계획"
  },
  "victory_mantra": "승리를 위한 만트라"
}`
  }
}

// 프롬프트 생성 헬퍼 함수
export function generateBatchPrompt(
  bundleType: string,
  bundleName: string,
  userProfile: any,
  additionalContext?: any
): string {
  let template: BatchPromptTemplate | undefined

  // 번들 타입에 따라 적절한 템플릿 선택
  switch (bundleType) {
    case 'time_based':
      template = TIME_BASED_PROMPTS[bundleName]
      break
    case 'lifestyle':
      template = LIFESTYLE_PROMPTS[bundleName]
      break
    case 'decision':
      template = DECISION_PROMPTS[bundleName]
      break
    case 'deep_analysis':
      template = DEEP_ANALYSIS_PROMPTS[bundleName]
      break
    case 'activity':
      template = ACTIVITY_PROMPTS[bundleName]
      break
  }

  if (!template) {
    throw new Error(`Unknown bundle: ${bundleType}/${bundleName}`)
  }

  // 사용자 정보로 템플릿 채우기
  let userPrompt = template.userPromptTemplate
  userPrompt = userPrompt.replace('{{name}}', userProfile.name || '사용자')
  userPrompt = userPrompt.replace('{{birthDate}}', userProfile.birth_date || '')
  userPrompt = userPrompt.replace('{{birthTime}}', userProfile.birth_time || '')
  userPrompt = userPrompt.replace('{{mbti}}', userProfile.mbti || '')
  userPrompt = userPrompt.replace('{{currentTime}}', new Date().toLocaleTimeString('ko-KR'))

  // 추가 컨텍스트 적용
  if (additionalContext) {
    Object.entries(additionalContext).forEach(([key, value]) => {
      userPrompt = userPrompt.replace(`{{${key}}}`, String(value))
    })
  }

  // 최종 프롬프트 생성
  return `${template.systemPrompt}

${userPrompt}

응답 형식:
${template.responseFormat}

중요: 모든 운세는 서로 연결되고 일관성 있게 작성해주세요.
각 운세의 정보가 서로 보완하고 시너지를 만들어야 합니다.`
}

// 번들 추천 함수
export function recommendBundle(
  userProfile: any,
  currentTime: Date,
  userHistory?: any
): string[] {
  const recommendations: string[] = []
  const hour = currentTime.getHours()

  // 시간대별 추천
  if (hour >= 6 && hour < 10) {
    recommendations.push('time_based/morning_bundle')
  } else if (hour >= 18 && hour < 22) {
    recommendations.push('time_based/evening_bundle')
  }

  // 프로필 기반 추천
  if (userProfile.occupation) {
    recommendations.push('lifestyle/work_life')
  }

  if (userProfile.relationship_status === 'single' || userProfile.relationship_status === 'dating') {
    recommendations.push('lifestyle/love_life')
  }

  // 요일별 추천
  const dayOfWeek = currentTime.getDay()
  if (dayOfWeek === 1) { // 월요일
    recommendations.push('lifestyle/work_life')
  } else if (dayOfWeek === 5) { // 금요일
    recommendations.push('lifestyle/love_life')
  } else if (dayOfWeek === 0 || dayOfWeek === 6) { // 주말
    recommendations.push('activity/sports_bundle')
  }

  // 특별한 상황 추천
  if (userHistory?.recent_decision_search) {
    recommendations.push('decision/major_decision')
  }

  // 기본 추천
  if (recommendations.length === 0) {
    recommendations.push('time_based/morning_bundle')
  }

  return recommendations
}
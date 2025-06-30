# GPT 운세 추출 JSON 구조 예시

## 목차
1. [시나리오별 개요](#시나리오별-개요)
2. [대표 운세별 GPT 인풋/아웃풋 설계](#운세별-인풋아웃풋-설계)
3. [JSON 응답 구조 표준](#JSON-응답-구조-표준)

## 시나리오별 개요

GPT 운세 추출은 다음 3가지 시나리오로 구성됩니다:

1. **온보딩 완료 후 초기 운세 생성** - 평생 운세 패키지 (1년 캐시)
2. **새로운 하루 시작 시 일일 운세 생성** - 종합 일일 운세 (24시간 캐시)  
3. **사용자 직접 요청 시 특정 운세 생성** - 개별 운세 (1시간 캐시)

---

## 운세별 인풋/아웃풋 설계

### 🎯 **묶음 요청 전략 (토큰 효율성)**

#### 1. **전통·사주 패키지** (한 번에 요청)
- `saju` + `traditional-saju` + `tojeong` + `salpuli` + `past-life`
- **이유**: 모두 생년월일/시간 기반 분석, 상호 연관성 높음
- **토큰 절약**: 5번 → 1번 요청 (약 80% 절약)

#### 2. **일일 종합 패키지** (한 번에 요청)  
- `daily` + `hourly` + `today` + `tomorrow`
- **이유**: 모두 동일 날짜 기반, 중복 분석 요소 많음
- **토큰 절약**: 4번 → 1번 요청 (약 75% 절약)

#### 3. **연애·인연 패키지** (조건부 묶음)
- **솔로**: `love` + `destiny` + `blind-date` + `celebrity-match`
- **연애중**: `love` + `couple-match` + `chemistry` + `marriage`
- **이유**: 관계 상태별 맞춤 조합, 컨텍스트 공유
- **토큰 절약**: 4번 → 1번 요청 (약 70% 절약)

#### 4. **취업·재물 패키지** (한 번에 요청)
- `career` + `wealth` + `business` + `lucky-investment`
- **이유**: 경제활동 관련, 상호보완적 분석
- **토큰 절약**: 4번 → 1번 요청 (약 65% 절약)

#### 5. **행운 아이템 패키지** (한 번에 요청)
- `lucky-color` + `lucky-number` + `lucky-items` + `lucky-outfit` + `lucky-food`
- **이유**: 모두 단순 추천 형태, 공통 사용자 프로필 활용
- **토큰 절약**: 5번 → 1번 요청 (약 85% 절약)

---

### 📜 **전통·사주 패키지 (5개 묶음)**

**GPT 인풋:**
```json
{
  "request_type": "traditional_package",
  "fortune_types": ["saju", "traditional-saju", "tojeong", "salpuli", "past-life"],
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "birth_time": "인시 (03:30-05:29)",
    "gender": "남성",
    "mbti": "ENTJ",
    "zodiac_sign": "처녀자리"
  },
  "analysis_depth": "comprehensive",
  "context": "생년월일시 기반 전통 운명학 종합 분석 - 사주, 전통사주, 토정비결, 살풀이, 전생 운명 한번에 해석"
}
```

**GPT 아웃풋:**
```json
{
  "request_type": "traditional_package",
  "analysis_results": {
    "saju": {
      "birth_chart": {
        "year_pillar": { "heavenly": "무", "earthly": "진", "element": "토" },
        "month_pillar": { "heavenly": "신", "earthly": "유", "element": "금" },
        "day_pillar": { "heavenly": "정", "earthly": "사", "element": "화" },
        "time_pillar": { "heavenly": "임", "earthly": "인", "element": "목" }
      },
      "five_elements": {
        "wood": { "score": 2, "percentage": 20, "strength": "약함" },
        "fire": { "score": 2, "percentage": 20, "strength": "약함" },
        "earth": { "score": 3, "percentage": 30, "strength": "보통" },
        "metal": { "score": 2, "percentage": 20, "strength": "약함" },
        "water": { "score": 1, "percentage": 10, "strength": "매우약함" }
      },
      "fortune_summary": {
        "overall_score": 78,
        "career_fortune": 85,
        "wealth_fortune": 72,
        "love_fortune": 68,
        "health_fortune": 75
      }
    },
    "traditional_saju": {
      "major_life_phases": [
        { "age_range": "20-30세", "description": "학업과 기초 쌓기", "fortune_level": 6 },
        { "age_range": "30-40세", "description": "사업 성공과 재물 축적", "fortune_level": 9 },
        { "age_range": "40-50세", "description": "안정과 명예 획득", "fortune_level": 8 }
      ],
      "ten_gods_analysis": {
        "dominant_god": "정관",
        "support_gods": ["편인", "식신"],
        "caution_gods": ["칠살", "겁재"]
      }
    },
    "tojeong": {
      "new_year_fortune": {
        "overall_hexagram": "44괘 천풍구",
        "interpretation": "새로운 기회가 찾아오나 신중함 필요",
        "monthly_fortune": [
          { "month": 1, "score": 82, "advice": "적극적 행동" },
          { "month": 2, "score": 68, "advice": "인내와 대기" }
        ]
      }
    },
    "salpuli": {
      "harmful_influences": [
        { "name": "백호살", "description": "금전 손실 주의", "solution": "동쪽 방향 피하기" },
        { "name": "역마살", "description": "잦은 이동, 불안정", "solution": "안정적 생활 패턴 유지" }
      ],
      "protection_methods": ["관음보살 진언", "청색 옷 착용", "북쪽 방향 선호"]
    },
    "past_life": {
      "previous_occupation": "학자 또는 관리",
      "karma_lessons": ["권력 남용 금지", "타인에 대한 배려", "겸손함 유지"],
      "talents_carried": ["분석력", "리더십", "학습능력"],
      "relationships": "스승과 제자 관계에서의 인연이 현생에 이어짐"
    }
  },
  "package_summary": {
    "core_destiny": "타고난 리더로서 조직을 이끌며 사회에 기여하는 운명",
    "life_mission": "공정하고 올바른 리더십으로 많은 사람을 도움",
    "major_challenges": ["독선 방지", "소통 능력 향상", "감정 표현"],
    "success_timing": "30대 후반부터 본격적 성공 시작"
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "365d"
}
```

### 🗓️ **일일 종합 패키지 (4개 묶음)**

**GPT 인풋:**
```json
{
  "request_type": "daily_package",
  "fortune_types": ["daily", "hourly", "today", "tomorrow"],
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "birth_time": "인시",
    "gender": "남성",
    "mbti": "ENTJ"
  },
  "target_date": "2025-01-01",
  "context": "신정 연휴 첫날의 종합 일일운세 - 오늘/내일/시간별 흐름 통합 분석"
}
```

**GPT 아웃풋:**
```json
{
  "request_type": "daily_package",
  "target_date": "2025-01-01",
  "analysis_results": {
    "daily": {
      "overall_fortune": {
        "score": 82,
        "level": "좋음",
        "summary": "새해 첫날답게 활기찬 에너지가 넘치는 하루"
      },
      "detailed_fortune": {
        "love": { "score": 75, "advice": "새로운 만남의 기회" },
        "wealth": { "score": 68, "advice": "저축 위주로" },
        "career": { "score": 88, "advice": "중요한 결정하기 좋은 날" },
        "health": { "score": 72, "advice": "소화기 주의" }
      }
    },
    "today": {
      "theme": "새로운 시작",
      "key_energy": "적극성",
      "best_activity": "목표 설정 및 계획 수립",
      "avoid_activity": "큰 지출이나 투자"
    },
    "tomorrow": {
      "forecast": {
        "score": 76,
        "trend": "오늘보다 약간 하락하나 여전히 양호",
        "focus": "오늘 세운 계획의 첫 실행"
      },
      "preparation": "충분한 휴식으로 컨디션 조절"
    },
    "hourly": [
      { "time": "06:00-08:00", "score": 8, "activity": "명상, 운동" },
      { "time": "09:00-11:00", "score": 9, "activity": "중요 업무, 회의" },
      { "time": "12:00-14:00", "score": 7, "activity": "가벼운 식사" },
      { "time": "15:00-17:00", "score": 6, "activity": "휴식 필요" },
      { "time": "18:00-20:00", "score": 8, "activity": "사교 활동" },
      { "time": "21:00-23:00", "score": 7, "activity": "여유로운 시간" }
    ]
  },
  "unified_recommendations": {
    "best_time_slot": "09:00-11:00 (최고 운세 시간)",
    "caution_period": "15:00-17:00 (에너지 하락)",
    "lucky_elements": {
      "color": "#4F46E5",
      "number": [1, 8, 21],
      "direction": "동쪽"
    }
  },
  "generated_at": "2025-01-01T06:00:00Z",
  "cache_duration": "24h"
}
```

### 💕 **연애·인연 패키지 (솔로용 4개 묶음)**

**GPT 인풋:**
```json
{
  "request_type": "love_package_single",
  "fortune_types": ["love", "destiny", "blind-date", "celebrity-match"],
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "gender": "남성",
    "relationship_status": "솔로",
    "mbti": "ENTJ",
    "celebrity_interest": "아이유"
  },
  "analysis_period": "3개월",
  "context": "솔로 남성을 위한 종합 연애운 패키지 - 전반적 연애운, 인연운, 소개팅운, 연예인 궁합 통합 분석"
}
```

**GPT 아웃풋:**
```json
{
  "request_type": "love_package_single",
  "analysis_results": {
    "love": {
      "current_energy": {
        "phase": "상승기",
        "score": 74,
        "description": "새로운 만남에 대한 준비가 완료된 상태"
      },
      "meeting_forecast": {
        "next_3_months": [
          { "month": 1, "probability": 65, "venue": "직장 관련 모임" },
          { "month": 2, "probability": 78, "venue": "친구 소개" },
          { "month": 3, "probability": 55, "venue": "취미 활동" }
        ]
      },
      "ideal_type_analysis": {
        "compatible_mbti": ["ISFJ", "INFP", "ESFJ"],
        "preferred_personality": "차분하고 배려심 있는 성격",
        "age_range": "29-35세",
        "profession_match": ["교육계", "의료계", "디자인 분야"]
      }
    },
    "destiny": {
      "soulmate_timing": {
        "peak_period": "2025년 2월-4월",
        "secondary_period": "2025년 8월-10월",
        "signs": ["우연한 재회", "공통 관심사 발견", "운명적 느낌"]
      },
      "relationship_pattern": "천천히 신뢰를 쌓아가는 타입",
      "past_life_connection": "같은 직업군에서 만날 가능성 높음"
    },
    "blind_date": {
      "success_probability": 72,
      "best_timing": "2025년 2월 둘째주",
      "recommended_venues": ["조용한 카페", "갤러리", "문화센터"],
      "conversation_tips": [
        "상대방 이야기에 집중하기",
        "본인의 성취보다는 취미나 관심사 위주로",
        "유머 감각 자연스럽게 보여주기"
      ],
      "outfit_suggestions": {
        "style": "세미 캐주얼",
        "colors": ["네이비", "그레이", "화이트"],
        "avoid": "너무 격식 차린 정장"
      }
    },
    "celebrity_match": {
      "target_celebrity": "아이유",
      "compatibility_score": 68,
      "matching_points": [
        "창의적 사고방식",
        "섬세한 감수성",
        "성실한 업무 태도"
      ],
      "challenge_points": [
        "표현 방식의 차이",
        "라이프스타일 차이",
        "관심사 다양성"
      ],
      "if_dating_scenario": {
        "relationship_style": "서로의 개성을 존중하는 관계",
        "ideal_date": "조용한 책방이나 소규모 콘서트",
        "long_term_potential": "상호 성장을 도모하는 좋은 파트너십"
      }
    }
  },
  "unified_love_strategy": {
    "action_plan": [
      "2월 소개팅 적극 수락",
      "직장 내 네트워킹 활발히",
      "새로운 취미 활동 시작"
    ],
    "self_improvement": ["경청 능력 향상", "감정 표현 연습", "패션 센스 업그레이드"],
    "timing_calendar": {
      "best_dates": ["2025-02-14", "2025-02-22", "2025-03-08"],
      "avoid_dates": ["2025-01-15", "2025-03-25"]
    }
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "72h"
}
```

### 💼 **취업·재물 패키지 (4개 묶음)**

**GPT 인풋:**
```json
{
  "request_type": "career_wealth_package",
  "fortune_types": ["career", "wealth", "business", "lucky-investment"],
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "current_job": "중간관리자",
    "industry": "IT",
    "investment_interest": "주식, 부동산",
    "mbti": "ENTJ"
  },
  "analysis_period": "2025년 전체",
  "context": "커리어 성장과 재물 축적을 위한 종합 전략 - 승진, 재물운, 창업 가능성, 투자운 통합 분석"
}
```

**GPT 아웃풋:**
```json
{
  "request_type": "career_wealth_package",
  "analysis_results": {
    "career": {
      "promotion_forecast": {
        "probability": 78,
        "target_timing": "2025년 3월-6월",
        "required_skills": ["팀 관리", "프로젝트 리딩", "전략 기획"],
        "networking_strategy": "상급자와의 소통 강화"
      },
      "job_change_analysis": {
        "recommended": false,
        "reason": "현재 포지션에서 성장 가능성 높음",
        "if_considering": "2025년 하반기 이후 검토"
      }
    },
    "wealth": {
      "income_growth": {
        "salary_increase": "15-20% 예상",
        "bonus_opportunity": "상반기 성과에 따라 결정",
        "additional_income": "사이드 프로젝트 추천"
      },
      "saving_strategy": {
        "monthly_target": "30% 저축률 유지",
        "emergency_fund": "6개월치 생활비 확보",
        "long_term_goal": "주택 구매 자금 마련"
      }
    },
    "business": {
      "startup_potential": 65,
      "best_timing": "2026년 이후",
      "recommended_field": "교육 플랫폼, 컨설팅",
      "current_preparation": [
        "업계 네트워크 구축",
        "자금 확보",
        "시장 조사"
      ]
    },
    "lucky_investment": {
      "stock_forecast": {
        "tech_stocks": "상반기 유리",
        "blue_chips": "하반기 추천",
        "avoid_sectors": "바이오, 화학"
      },
      "real_estate": {
        "timing": "2025년 말-2026년 초",
        "location": "수도권 신도시",
        "investment_type": "실거주 목적 우선"
      },
      "lucky_numbers": [3, 7, 21, 28],
      "caution_period": "4월-5월 (변동성 높음)"
    }
  },
  "integrated_wealth_plan": {
    "short_term_goals": [
      "승진을 통한 연봉 상승",
      "투자 포트폴리오 다양화",
      "비상 자금 확충"
    ],
    "long_term_vision": "2030년까지 독립적 사업가로 전환",
    "monthly_action_items": [
      "주식 투자 (월 100만원)",
      "부동산 시장 모니터링",
      "창업 아이템 리서치"
    ]
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "168h"
}
```

### 🍀 **행운 아이템 패키지 (5개 묶음)**

**GPT 인풋:**
```json
{
  "request_type": "lucky_items_package",
  "fortune_types": ["lucky-color", "lucky-number", "lucky-items", "lucky-outfit", "lucky-food"],
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "mbti": "ENTJ",
    "season": "겨울",
    "goal": "업무 성과 향상"
  },
  "target_period": "2025년 1월",
  "context": "새해 운세 상승을 위한 행운 아이템 패키지 - 색깔, 숫자, 아이템, 의상, 음식 통합 추천"
}
```

**GPT 아웃풋:**
```json
{
  "request_type": "lucky_items_package",
  "analysis_results": {
    "lucky_color": {
      "primary": { "color": "#2563EB", "name": "딥 블루", "effect": "집중력 향상" },
      "secondary": { "color": "#059669", "name": "에메랄드 그린", "effect": "성장과 안정" },
      "accent": { "color": "#DC2626", "name": "크림슨 레드", "effect": "열정과 에너지" },
      "avoid": ["#6B7280", "#374151"]
    },
    "lucky_number": {
      "primary": [3, 21, 28],
      "secondary": [7, 14, 35],
      "meaning": {
        "3": "창의와 소통",
        "21": "성공과 달성",
        "28": "물질적 풍요"
      },
      "usage_tips": "중요 결정일, 복권 번호, 회의실 번호 등에 활용"
    },
    "lucky_items": {
      "accessories": [
        { "item": "청금석 팔찌", "effect": "의사소통 능력 향상" },
        { "item": "가죽 지갑 (검정)", "effect": "재물 보호" }
      ],
      "office": [
        { "item": "선인장 (책상 우측)", "effect": "악운 차단" },
        { "item": "크리스탈 펜", "effect": "아이디어 창출" }
      ],
      "home": [
        { "item": "거울 (현관 좌측)", "effect": "긍정 에너지 증폭" },
        { "item": "향초 (라벤더)", "effect": "스트레스 해소" }
      ]
    },
    "lucky_outfit": {
      "business": {
        "suit": "네이비 또는 차콜 그레이",
        "shirt": "화이트, 라이트 블루",
        "tie": "실버 스트라이프",
        "shoes": "블랙 레더"
      },
      "casual": {
        "top": "딥 블루 니트",
        "bottom": "다크 데님",
        "outerwear": "네이비 코트",
        "accessories": "실버 시계"
      },
      "special_occasion": "에메랄드 그린 포인트 아이템 추가"
    },
    "lucky_food": {
      "daily": [
        { "food": "호두", "time": "오전", "effect": "두뇌 활동 증진" },
        { "food": "연어", "time": "점심", "effect": "오메가3로 집중력 향상" },
        { "food": "다크 초콜릿", "time": "오후", "effect": "스트레스 완화" }
      ],
      "weekly_special": [
        { "day": "월요일", "food": "삼계탕", "effect": "한 주 시작 에너지" },
        { "day": "금요일", "food": "스시", "effect": "성공 에너지 충전" }
      ],
      "avoid": ["매운 음식 (소화기 부담)", "과도한 카페인"]
    }
  },
  "daily_combination_guide": {
    "morning_ritual": "딥 블루 셔츠 + 청금석 팔찌 + 호두 3개",
    "work_setup": "크리스탈 펜 + 선인장 배치 + 라벤더 향초",
    "evening_routine": "에메랄드 그린 포인트 + 다크 초콜릿 + 명상",
    "weekly_reset": "모든 아이템 정리 및 새로운 의도 설정"
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "720h"
}
```

---

## 💰 **토큰 절약 효과 분석**

### 📊 **묶음 요청 시 토큰 절약량**

| 패키지 | 개별 요청 | 묶음 요청 | 절약률 | 절약 토큰 |
|--------|-----------|-----------|---------|-----------|
| **전통·사주** (5개) | ~15,000 토큰 | ~3,000 토큰 | **80%** | ~12,000 토큰 |
| **일일 종합** (4개) | ~8,000 토큰 | ~2,000 토큰 | **75%** | ~6,000 토큰 |
| **연애·인연** (4개) | ~10,000 토큰 | ~3,000 토큰 | **70%** | ~7,000 토큰 |
| **취업·재물** (4개) | ~12,000 토큰 | ~4,200 토큰 | **65%** | ~7,800 토큰 |
| **행운 아이템** (5개) | ~6,000 토큰 | ~900 토큰 | **85%** | ~5,100 토큰 |

### 💡 **토큰 절약 원리**
1. **공통 프로필 중복 제거**: 사용자 정보를 한 번만 전송
2. **컨텍스트 공유**: 관련된 운세들의 분석 컨텍스트 통합
3. **응답 구조 최적화**: 중복되는 설명이나 분석 요소 통합
4. **일괄 처리**: GPT의 컨텍스트 윈도우 효율적 활용

### 🎯 **사용 권장 시나리오**
- **온보딩 시**: 전통·사주 패키지로 기본 운명 정보 생성
- **새로운 하루**: 일일 종합 패키지로 하루 운세 통합
- **연애 고민**: 솔로용/연애중용 패키지로 종합 연애운
- **중요 결정**: 취업·재물 패키지로 경제활동 종합 분석
- **일상 운**: 행운 아이템 패키지로 실용적 가이드

---

#### 1. saju (사주팔자) - 정통 사주 분석

**GPT 인풋:**
```json
{
  "fortune_type": "saju",
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "birth_time": "인시 (03:30-05:29)",
    "gender": "남성",
    "mbti": "ENTJ",
    "zodiac_sign": "처녀자리"
  },
  "analysis_depth": "comprehensive",
  "focus_areas": ["천간지지", "오행분석", "십신분석", "대운흐름", "연월일시주"],
  "context": "정통 사주팔자로 인생 전반의 운명과 성격, 재능을 상세 분석"
}
```

**GPT 아웃풋:**
```json
{
  "fortune_type": "saju",
  "analysis_result": {
    "birth_chart": {
      "year_pillar": { "heavenly": "무", "earthly": "진", "element": "토" },
      "month_pillar": { "heavenly": "신", "earthly": "유", "element": "금" },
      "day_pillar": { "heavenly": "정", "earthly": "사", "element": "화" },
      "time_pillar": { "heavenly": "임", "earthly": "인", "element": "목" }
    },
    "five_elements": {
      "wood": { "score": 2, "percentage": 20, "strength": "약함" },
      "fire": { "score": 2, "percentage": 20, "strength": "약함" },
      "earth": { "score": 3, "percentage": 30, "strength": "보통" },
      "metal": { "score": 2, "percentage": 20, "strength": "약함" },
      "water": { "score": 1, "percentage": 10, "strength": "매우약함" }
    },
    "personality_analysis": {
      "core_traits": ["리더십", "책임감", "완벽주의", "추진력"],
      "strengths": ["조직력", "판단력", "결단력", "의지력"],
      "weaknesses": ["고집", "급성", "독선", "스트레스"],
      "suitable_roles": ["경영자", "관리직", "전문직", "공무원"]
    },
    "life_periods": {
      "youth": "학업에 집중하되 인간관계 확장 필요",
      "middle_age": "사업 성공 가능성 높음, 재물운 상승",
      "old_age": "안정적 노후, 자녀복 좋음"
    },
    "fortune_summary": {
      "overall_score": 78,
      "career_fortune": 85,
      "wealth_fortune": 72,
      "love_fortune": 68,
      "health_fortune": 75
    },
    "advice": {
      "general": "타고난 리더십을 발휘하되 독단적이지 않도록 주의",
      "career": "30대 후반부터 큰 성공 가능, 조직 운영 관련 업무 적합",
      "relationships": "소수 정예의 깊은 관계 유지가 유리",
      "health": "스트레스 관리와 규칙적인 운동 필요"
    }
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "365d"
}
```

#### 2. daily (오늘의 운세) - 종합 일일 운세

**GPT 인풋:**
```json
{
  "fortune_type": "daily",
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "birth_time": "인시",
    "gender": "남성",
    "mbti": "ENTJ"
  },
  "current_date": "2025-01-01",
  "analysis_scope": ["총운", "애정운", "재물운", "건강운", "직장운"],
  "context": "오늘 하루의 종합적인 운세 분석"
}
```

**GPT 아웃풋:**
```json
{
  "fortune_type": "daily",
  "date": "2025-01-01",
  "analysis_result": {
    "overall_fortune": {
      "score": 82,
      "level": "좋음",
      "summary": "새해 첫날답게 활기찬 에너지가 넘치는 하루",
      "lucky_time": "09:00-11:00",
      "caution_time": "15:00-17:00"
    },
    "detailed_fortune": {
      "love": {
        "score": 75,
        "description": "새로운 만남의 기회가 있을 수 있는 날",
        "advice": "적극적인 자세로 사교 활동에 참여하세요"
      },
      "wealth": {
        "score": 68,
        "description": "큰 지출보다는 저축을 권하는 날",
        "advice": "신중한 소비 패턴 유지, 투자는 보류"
      },
      "career": {
        "score": 88,
        "description": "업무 효율성이 높아지는 날",
        "advice": "중요한 결정이나 발표를 하기 좋은 시기"
      },
      "health": {
        "score": 72,
        "description": "전반적으로 컨디션 양호, 소화기 주의",
        "advice": "과식 피하고 충분한 수분 섭취 권장"
      }
    },
    "daily_recommendations": {
      "lucky_color": "#4F46E5",
      "lucky_number": [3, 7, 21],
      "lucky_direction": "동쪽",
      "recommended_activities": ["독서", "운동", "친구 만남"],
      "foods_to_avoid": ["기름진 음식", "매운 음식"]
    }
  },
  "generated_at": "2025-01-01T06:00:00Z",
  "cache_duration": "24h"
}
```

#### 3. love (연애운) - 사랑과 인연 분석

**GPT 인풋:**
```json
{
  "fortune_type": "love",
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "gender": "남성",
    "relationship_status": "솔로",
    "mbti": "ENTJ"
  },
  "analysis_period": "3개월",
  "focus_areas": ["새로운만남", "연애가능성", "이상형", "연애스타일"],
  "context": "연애운과 인연의 흐름 분석"
}
```

**GPT 아웃풋:**
```json
{
  "fortune_type": "love",
  "analysis_result": {
    "current_love_phase": {
      "status": "상승기",
      "score": 78,
      "description": "새로운 인연을 만날 가능성이 높은 시기",
      "peak_period": "2025년 2월 중순"
    },
    "meeting_forecast": {
      "probability": 82,
      "best_places": ["직장", "취미모임", "지인소개"],
      "ideal_timing": ["평일 저녁", "주말 오후"],
      "warning_periods": ["1월 말", "3월 초"]
    },
    "ideal_partner": {
      "personality": ["차분함", "배려심", "지적호기심", "안정성"],
      "compatible_mbti": ["INFJ", "ISFJ", "ENFP"],
      "recommended_age_gap": "+/- 3세",
      "occupation_match": ["교육직", "의료진", "예술가"]
    },
    "relationship_advice": {
      "dating_style": "진지하고 목표지향적인 접근",
      "communication_tips": "경청하는 자세 중요, 급하게 밀어붙이지 말 것",
      "growth_areas": ["감정표현", "여유로움", "상대방 배려"]
    }
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "1h"
}
```

#### 4. career (취업운) - 커리어 성공 분석

**GPT 인풋:**
```json
{
  "fortune_type": "career",
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "education": "대졸",
    "current_status": "재직중",
    "career_goal": "관리직 승진"
  },
  "analysis_scope": ["승진운", "이직운", "사업운", "인맥운"],
  "time_horizon": "1년",
  "context": "커리어 발전과 성공 가능성 분석"
}
```

**GPT 아웃풋:**
```json
{
  "fortune_type": "career",
  "analysis_result": {
    "career_trajectory": {
      "current_phase": "성장기",
      "success_probability": 85,
      "breakthrough_timing": "2025년 상반기",
      "key_challenges": ["팀워크", "소통능력", "스트레스관리"]
    },
    "promotion_forecast": {
      "likelihood": 78,
      "optimal_timing": "6-9월",
      "preparation_areas": ["리더십스킬", "전문성강화", "네트워킹"],
      "success_factors": ["결과중심사고", "책임감", "추진력"]
    },
    "job_change_analysis": {
      "recommendation": "현재 직장에서 성장 우선",
      "if_changing": {
        "best_timing": "하반기",
        "suitable_industries": ["IT", "금융", "컨설팅"],
        "avoid_periods": ["3-4월", "11-12월"]
      }
    },
    "networking_strategy": {
      "focus_groups": ["동업계 선배", "타부서 동료", "외부 전문가"],
      "key_events": ["세미나", "워크샵", "업계모임"],
      "relationship_building": "진정성 있는 장기적 관계 구축"
    }
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "1h"
}
```

#### 5. lucky-color (행운의 색깔) - 개인 맞춤 컬러

**GPT 인풋:**
```json
{
  "fortune_type": "lucky-color",
  "user_profile": {
    "name": "김인주",
    "birth_date": "1988-09-05",
    "current_mood": "스트레스",
    "desired_effect": "안정감"
  },
  "context": "심리적 안정과 행운을 위한 개인 맞춤 색깔 추천",
  "application_areas": ["의상", "소품", "인테리어", "디지털기기"]
}
```

**GPT 아웃풋:**
```json
{
  "fortune_type": "lucky-color",
  "analysis_result": {
    "primary_color": {
      "name": "딥네이비",
      "hex": "#1e3a8a",
      "effect": "안정감과 신뢰감 증진",
      "psychological_impact": "스트레스 완화, 집중력 향상"
    },
    "secondary_colors": [
      {
        "name": "포레스트그린",
        "hex": "#065f46",
        "usage": "작업환경, 액세서리",
        "benefit": "자연의 평온함, 성장에너지"
      },
      {
        "name": "웜그레이",
        "hex": "#6b7280", 
        "usage": "일상복, 배경색",
        "benefit": "중립적 안정감, 조화로움"
      }
    ],
    "application_guide": {
      "clothing": "메인 아이템에 딥네이비, 포인트로 그린 활용",
      "workspace": "문구류나 마우스패드 등에 적용",
      "home": "쿠션이나 소품으로 자연스럽게 배치",
      "digital": "폰케이스, 배경화면 등에 활용"
    },
    "avoid_colors": ["빨강", "형광색", "너무 밝은 노랑"],
    "duration": "2-3주간 지속적 사용 권장"
  },
  "generated_at": "2025-01-01T00:00:00Z",
  "cache_duration": "1h"
}
```

---

## JSON 응답 구조 표준

### 공통 필드
모든 운세 응답은 다음 공통 구조를 따릅니다:

```json
{
  "fortune_type": "운세타입",
  "analysis_result": {
    // 운세별 특화 결과
  },
  "generated_at": "ISO 8601 타임스탬프",
  "cache_duration": "캐시 유지 기간",
  "confidence_score": 85, // 0-100, 분석 신뢰도
  "related_fortunes": ["추천운세1", "추천운세2"] // 관련 운세 추천
}
```

### 난이도별 응답 깊이
- **쉬움**: 핵심 결과 + 간단한 조언
- **보통**: 상세 분석 + 구체적 가이드
- **어려움**: 종합 분석 + 단계별 실행방안

### 캐시 정책
- **평생 운세** (saju, traditional-saju): 365일
- **일일 운세** (daily, today): 24시간  
- **개별 운세** (love, career 등): 1시간
```

## 1. 온보딩 완료 후 초기 운세 생성

### 요청 JSON

```json
{
  "request_type": "onboarding_complete",
  "user_profile": {
    "id": "user_12345",
    "name": "김인주",
    "birth_date": "1988-09-05",
    "birth_time": "인시",
    "gender": "남성",
    "mbti": "ENTJ",
    "zodiac_sign": "처녀자리",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
  },
  "requested_categories": [
    "saju",
    "traditional-saju", 
    "personality",
    "talent",
    "destiny",
    "past-life",
    "five-blessings",
    "tojeong",
    "salpuli"
  ],
  "generation_context": {
    "is_initial_setup": true,
    "include_comprehensive_analysis": true,
    "cache_duration_hours": 8760
  }
}
```

### 응답 JSON

```json
{
  "request_id": "onboarding_complete_user_12345_1735689600000_abc123",
  "user_id": "user_12345",
  "generated_at": "2025-01-01T12:00:00Z",
  "life_profile_data": {
    "saju": {
      "basic_info": {
        "birth_year": "1988년",
        "birth_month": "9월",
        "birth_day": "5일",
        "birth_time": "인시"
      },
      "four_pillars": {
        "year_pillar": { "heavenly": "무", "earthly": "진" },
        "month_pillar": { "heavenly": "신", "earthly": "유" },
        "day_pillar": { "heavenly": "경", "earthly": "술" },
        "time_pillar": { "heavenly": "무", "earthly": "인" }
      },
      "ten_gods": ["정관", "편재", "식신", "상관"],
      "five_elements": {
        "wood": 2,
        "fire": 1,
        "earth": 4,
        "metal": 3,
        "water": 0
      },
      "personality_analysis": "당신은 강력한 토(土)의 기운을 가진 안정적이고 실용적인 성격입니다. ENTJ 성향과 맞물려 리더십이 뛰어나며, 체계적인 계획과 실행력이 특출합니다.",
      "life_fortune": "중년 이후 큰 성취를 이루는 대기만성형입니다. 특히 40대 후반부터 인생의 정점기를 맞이하게 됩니다.",
      "career_fortune": "관리직이나 경영직에 적합하며, 조직을 이끄는 위치에서 뛰어난 성과를 거둘 것입니다.",
      "wealth_fortune": "안정적인 재물 축적이 가능하며, 부동산 투자에 특히 좋은 운을 가지고 있습니다.",
      "love_fortune": "진실하고 깊이 있는 사랑을 추구하며, 결혼 후 가정을 중시하는 모범적인 배우자가 될 것입니다.",
      "health_fortune": "소화기계와 피부에 주의가 필요하며, 규칙적인 생활 패턴 유지가 중요합니다."
    },
    "traditional_saju": {
      "lucky_gods": ["천을귀인", "태극귀인", "금여"],
      "unlucky_gods": ["양인", "겁살"],
      "life_phases": [
        {
          "age_range": "20-35세",
          "description": "기반 다지기 시기, 꾸준한 노력과 학습이 필요",
          "fortune_level": 65
        },
        {
          "age_range": "36-50세",
          "description": "상승기, 사회적 지위 확립과 재물 축적",
          "fortune_level": 85
        },
        {
          "age_range": "51-65세",
          "description": "전성기, 최고의 성취와 명예를 얻는 시기",
          "fortune_level": 95
        }
      ],
      "major_events": [
        {
          "age": 32,
          "event_type": "career",
          "description": "중요한 승진이나 전직 기회"
        },
        {
          "age": 38,
          "event_type": "wealth",
          "description": "부동산 투자로 인한 큰 수익"
        },
        {
          "age": 45,
          "event_type": "recognition",
          "description": "사회적 명예와 인정을 받는 시기"
        }
      ]
    },
    "personality": {
      "core_traits": ["리더십", "책임감", "실용성", "안정추구"],
      "strengths": ["강한 추진력", "체계적 사고", "신뢰성", "결단력"],
      "weaknesses": ["완벽주의", "고집", "감정표현 부족"],
      "communication_style": "직설적이고 명확한 의사소통을 선호하며, 논리적 근거를 중시합니다.",
      "decision_making": "신중하게 정보를 수집한 후 빠르고 결단력 있게 결정을 내립니다.",
      "stress_response": "스트레스 상황에서도 침착함을 유지하며, 문제 해결에 집중합니다.",
      "ideal_career": ["경영진", "프로젝트 매니저", "컨설턴트", "공무원"],
      "relationship_style": "진실되고 안정적인 관계를 추구하며, 상대방에 대한 책임감이 강합니다."
    },
    "destiny": {
      "soul_mission": "조직과 사회에 안정과 질서를 가져다주는 리더 역할",
      "karmic_lessons": ["겸손함 배우기", "타인의 감정 이해하기", "완벽주의 극복하기"],
      "life_purpose": "실용적인 해결책을 통해 많은 사람들에게 도움을 주는 것",
      "spiritual_path": "봉사와 헌신을 통한 영적 성장",
      "challenges": ["감정적 둔감함", "과도한 책임감", "변화에 대한 저항"],
      "opportunities": ["리더십 발휘", "안정적 기반 구축", "장기적 성공"]
    },
    "talent": {
      "natural_talents": ["조직 관리", "전략 기획", "문제 해결", "시스템 구축"],
      "hidden_abilities": ["교육자적 재능", "예술적 감성", "치유 능력"],
      "development_areas": ["창의성", "유연성", "감정지능"],
      "career_recommendations": ["CEO/임원", "컨설팅", "교육 관리자", "부동산 전문가"],
      "skill_enhancement_tips": ["감성 리더십 개발", "창의적 사고 훈련", "커뮤니케이션 스킬 향상"]
    }
  },
  "cache_info": {
    "expires_at": "2026-01-01T12:00:00Z",
    "cache_key": "onboarding_complete:user_12345"
  }
}
```

## 2. 새로운 하루 시작 시 일일 운세 생성

### 요청 JSON

```json
{
  "request_type": "daily_refresh",
  "user_profile": {
    "id": "user_12345",
    "name": "김인주", 
    "birth_date": "1988-09-05",
    "birth_time": "인시",
    "gender": "남성",
    "mbti": "ENTJ",
    "zodiac_sign": "처녀자리",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
  },
  "target_date": "2025-01-02",
  "requested_categories": [
    "daily",
    "hourly", 
    "wealth",
    "love",
    "career",
    "health",
    "biorhythm"
  ],
  "generation_context": {
    "is_daily_auto_generation": true,
    "previous_day_context": {
      "overall_score": 78,
      "major_events": ["중요한 회의", "새로운 프로젝트 시작"]
    },
    "cache_duration_hours": 24
  }
}
```

### 응답 JSON

```json
{
  "request_id": "daily_refresh_user_12345_1735689600000_def456",
  "user_id": "user_12345",
  "target_date": "2025-01-02",
  "generated_at": "2025-01-02T06:00:00Z",
  "daily_comprehensive_data": {
    "overall_fortune": {
      "score": 82,
      "summary": "안정적이고 생산적인 하루가 될 것입니다. 특히 업무 관련해서 좋은 성과를 거둘 수 있습니다.",
      "key_points": [
        "오전 중 중요한 결정을 내리기 좋은 시간",
        "동료들과의 협력이 성공의 열쇠",
        "저녁 시간 개인적인 시간 확보 필요"
      ],
      "energy_level": 8,
      "mood_forecast": "차분하고 집중력이 높은 상태"
    },
    "detailed_fortunes": {
      "wealth": {
        "score": 75,
        "description": "투자나 재정 관리에 좋은 날입니다. 신중한 판단으로 작은 수익을 얻을 수 있습니다.",
        "investment_advice": "안전한 투자 상품에 관심을 가져보세요. 부동산 관련 정보 수집이 도움이 됩니다.",
        "spending_caution": ["충동구매 자제", "고액 지출 결정은 하루 더 고민"]
      },
      "love": {
        "score": 68,
        "description": "연인이나 배우자와 깊이 있는 대화를 나눌 수 있는 날입니다.",
        "single_advice": "새로운 만남보다는 기존 인연을 다시 살펴보세요.",
        "couple_advice": "상대방의 이야기에 귀 기울이고 공감하는 시간을 가지세요.",
        "meeting_probability": 25
      },
      "career": {
        "score": 88,
        "description": "업무에서 탁월한 성과를 낼 수 있는 날입니다. 리더십을 발휘할 기회가 주어집니다.",
        "work_focus": ["프로젝트 기획", "팀 협업", "전략 수립"],
        "meeting_luck": "오전 10시~12시 사이 중요한 미팅에서 좋은 결과",
        "decision_timing": "점심시간 이후가 중요한 결정을 내리기 좋은 시간"
      },
      "health": {
        "score": 72,
        "description": "전반적으로 건강한 상태이나 목과 어깨 부분에 약간의 피로감이 있을 수 있습니다.",
        "body_care": ["목과 어깨 스트레칭", "충분한 수분 섭취", "눈의 피로 관리"],
        "mental_care": ["명상이나 깊은 호흡", "자연 소리 듣기", "긍정적 사고"],
        "exercise_recommendation": "가벼운 산책이나 요가가 적합합니다."
      }
    },
    "lucky_elements": {
      "numbers": [7, 15, 23],
      "colors": ["진한 파란색", "회색", "흰색"],
      "foods": ["견과류", "등푸른 생선", "녹차"],
      "items": ["펜", "노트북", "시계"],
      "directions": ["동쪽", "북동쪽"],
      "times": ["10:00-12:00", "15:00-17:00"]
    },
    "hourly_fortune": [
      {
        "hour": "06:00",
        "fortune_level": 6,
        "activity_recommendation": "명상이나 계획 세우기"
      },
      {
        "hour": "09:00", 
        "fortune_level": 8,
        "activity_recommendation": "중요한 업무 처리"
      },
      {
        "hour": "12:00",
        "fortune_level": 9,
        "activity_recommendation": "동료와 점심 식사하며 네트워킹"
      },
      {
        "hour": "15:00",
        "fortune_level": 7,
        "activity_recommendation": "창의적 작업이나 기획"
      },
      {
        "hour": "18:00",
        "fortune_level": 5,
        "activity_recommendation": "개인 시간 확보, 휴식"
      },
      {
        "hour": "21:00",
        "fortune_level": 6,
        "activity_recommendation": "가족 시간이나 취미 활동"
      }
    ],
    "biorhythm": {
      "physical": 75,
      "emotional": 65,
      "intellectual": 85,
      "intuitive": 70
    }
  },
  "cache_info": {
    "expires_at": "2025-01-03T06:00:00Z",
    "cache_key": "daily_refresh:user_12345:2025-01-02"
  }
}
```

## 3. 사용자 직접 요청 시 특정 운세 생성

### 요청 JSON (연애운 예시)

```json
{
  "request_type": "user_direct_request",
  "user_profile": {
    "id": "user_12345",
    "name": "김인주",
    "birth_date": "1988-09-05", 
    "birth_time": "인시",
    "gender": "남성",
    "mbti": "ENTJ",
    "zodiac_sign": "처녀자리",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
  },
  "requested_category": "love",
  "additional_input": {
    "relationship_status": "single",
    "interest_type": "serious_relationship"
  },
  "generation_context": {
    "is_user_initiated": true,
    "request_source": "web",
    "session_id": "session_789",
    "previous_related_fortunes": [
      {
        "category": "daily",
        "generated_at": "2025-01-02T06:00:00Z",
        "score": 68
      }
    ],
    "cache_duration_hours": 1
  }
}
```

### 응답 JSON

```json
{
  "request_id": "user_direct_request_user_12345_1735689600000_ghi789",
  "user_id": "user_12345",
  "category": "love",
  "generated_at": "2025-01-02T14:30:00Z",
  "fortune_data": {
    "user_info": {
      "name": "김인주",
      "birth_date": "1988-09-05"
    },
    "fortune_scores": {
      "overall_love_luck": 73,
      "meeting_luck": 65,
      "relationship_development": 78,
      "marriage_luck": 80,
      "charm_index": 70
    },
    "insights": {
      "current_phase": "당신은 진정한 사랑을 찾기 위한 준비가 되어있는 시기입니다. 내면의 성숙함이 매력적인 상대를 끌어들일 것입니다.",
      "love_style": "안정적이고 진실한 관계를 추구하는 당신은 깊이 있는 정신적 교감을 중시합니다.",
      "ideal_partner": "지적이고 독립적이면서도 따뜻한 감성을 가진 상대방이 당신과 잘 맞을 것입니다."
    },
    "recommendations": [
      "독서 모임이나 문화 행사에 참여해보세요",
      "기존 지인들과의 만남을 늘려보세요",
      "자신의 취미나 관심사를 확장해보세요",
      "너무 완벽한 상대를 찾으려 하지 마세요"
    ],
    "warnings": [
      "첫 만남에서 너무 진지하게 접근하지 마세요",
      "상대방의 외모나 조건에만 집중하지 마세요"
    ],
    "lucky_items": {
      "colors": ["네이비", "베이지", "화이트"],
      "items": ["시계", "책", "향수"],
      "times": ["저녁 6-8시", "주말 오후"],
      "directions": ["남동쪽", "서쪽"]
    },
    "specialized_data": {
      "meeting_period": "앞으로 3-6개월 내",
      "meeting_place": "직장 관련 모임이나 전문적인 행사",
      "partner_characteristics": [
        "나이는 비슷하거나 2-3세 연상",
        "안정적인 직업을 가진 사람",
        "독립적이고 자신만의 가치관이 뚜렷한 사람"
      ],
      "relationship_timeline": {
        "first_meeting": "자연스럽고 편안한 분위기에서 만나게 됩니다",
        "development": "천천히 서로를 알아가며 신뢰를 쌓아갈 것입니다",
        "commitment": "1년 내에 진지한 관계로 발전할 가능성이 높습니다"
      }
    },
    "metadata": {
      "compatibility_with_mbti": {
        "INFJ": 95,
        "INTJ": 90,
        "ENFJ": 85,
        "ISFJ": 80
      },
      "best_date_ideas": [
        "박물관이나 전시회",
        "조용한 카페에서 책 읽기",
        "요리 클래스",
        "등산이나 자연 산책"
      ]
    }
  },
  "related_suggestions": [
    {
      "category": "marriage",
      "title": "결혼운",
      "reason": "연애운과 밀접한 관련이 있어 함께 보면 더 정확한 인사이트를 얻을 수 있습니다"
    },
    {
      "category": "compatibility",
      "title": "궁합",
      "reason": "이상형과의 궁합을 미리 확인해보세요"
    },
    {
      "category": "lucky-color",
      "title": "행운의 색깔",
      "reason": "연애에 도움이 되는 색깔로 매력을 한층 업그레이드하세요"
    }
  ],
  "cache_info": {
    "expires_at": "2025-01-02T15:30:00Z",
    "cache_key": "user_direct_request:user_12345:love"
  }
}
```

## 요약

### 캐시 전략
- **온보딩**: 1년 캐시 (평생 운세는 변하지 않음)
- **일일 운세**: 24시간 캐시 (하루에 한 번만 생성)
- **직접 요청**: 1시간 캐시 (빠른 재생성 허용)

### 데이터 구조 특징
- **온보딩**: 종합적이고 상세한 평생 운세 패키지
- **일일**: 하루 단위의 실용적인 운세 정보 + 시간별 세분화
- **직접**: 특정 카테고리에 특화된 깊이 있는 분석 + 연관 추천

### API 엔드포인트 활용
```
POST /api/fortune/gpt-generate
{
  "request_type": "onboarding_complete" | "daily_refresh" | "user_direct_request",
  ...
}
``` 
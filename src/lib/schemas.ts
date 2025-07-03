import { z } from "zod";
import { FORTUNE_TYPES, GENDERS, BIRTH_TIMES, MBTI_TYPES } from "./fortune-data";

const mbtiRegex = /^[EI][NS][TF][JP]$/i;

const genderValues = GENDERS.map(g => g.value) as [string, ...string[]];

export const ProfileFormSchema = z.object({
  name: z.string()
    .min(1, "이름을 입력해주세요.")
    .max(6, "이름은 1~6자 한글만 가능합니다.")
    .regex(/^[가-힣]{1,6}$/, "이름은 1~6자 한글로 입력해주세요."),
  birthdate: z.date({
    required_error: "생년월일을 선택해주세요.",
    invalid_type_error: "올바른 날짜 형식이 아닙니다.",
  }),
  mbti: z.string()
    .refine(value => value === "모름" || mbtiRegex.test(value), {
      message: "올바른 MBTI 형식이 아니거나 '모름'을 선택해야 합니다. (예: INFJ 또는 모름)",
    })
    .default("모름"),
  gender: z.enum(genderValues, {
    required_error: "성별을 선택해주세요.",
  }),
  birthTime: z.string({
    required_error: "태어난 시를 선택해주세요.",
  }),
  // fortuneTypes는 프로필 설정 단계에서는 제거합니다.
});

export type ProfileFormValues = z.infer<typeof ProfileFormSchema>;


// 이 스키마는 실제 운세 요청 시 사용될 수 있습니다. (향후 다른 페이지에서 사용)
export const FortuneRequestSchema = z.object({
  // 여기에 name, birthdate 등 프로필 정보가 포함될 수 있고,
  // 사용자가 선택한 운세 종류만 받을 수도 있습니다.
  // 지금은 ProfileFormSchema의 필드를 그대로 가져오고 fortuneTypes만 추가합니다.
  name: z.string().min(1).max(6).regex(/^[가-힣]{1,6}$/),
  birthdate: z.date(),
  mbti: z.string().refine(value => value === "모름" || mbtiRegex.test(value)),
  gender: z.enum(genderValues),
  birthTime: z.string(),
  fortuneTypes: z.array(z.enum(FORTUNE_TYPES))
    .min(1, "하나 이상의 운세 종류를 선택해주세요."),
});
export type FortuneRequestFormValues = z.infer<typeof FortuneRequestSchema>;

// 데일리 운세 저장을 위한 스키마
export const DailyFortuneSchema = z.object({
  id: z.string().optional(),
  user_id: z.string(),
  fortune_type: z.string(), // 운세 타입 (daily, saju, mbti, etc.)
  fortune_data: z.record(z.any()), // 운세 결과 데이터 (JSON)
  created_date: z.string(), // YYYY-MM-DD 형식
  created_at: z.string().optional(),
  updated_at: z.string().optional()
});

export type DailyFortuneData = z.infer<typeof DailyFortuneSchema>;

// 공통 사용자 정보 스키마
export const UserInfoSchema = z.object({
  name: z.string(),
  birth_date: z.string(),
  mbti: z.string().optional(),
  gender: z.string().optional(),
  birth_time: z.string().optional(),
});

// 기본 운세 점수 스키마
export const FortuneScoresSchema = z.object({
  overall_luck: z.number().min(0).max(100).optional(),
  love_luck: z.number().min(0).max(100).optional(),
  career_luck: z.number().min(0).max(100).optional(),
  wealth_luck: z.number().min(0).max(100).optional(),
  health_luck: z.number().min(0).max(100).optional(),
}).passthrough(); // 추가 점수 필드 허용

// 행운 아이템 스키마
export const LuckyItemsSchema = z.object({
  color: z.string().optional(),
  number: z.number().optional(),
  direction: z.string().optional(),
  time: z.string().optional(),
  item: z.string().optional(),
}).passthrough(); // 추가 아이템 필드 허용

// 운세 결과를 위한 공통 스키마
export const FortuneResultSchema = z.object({
  user_info: UserInfoSchema,
  fortune_scores: FortuneScoresSchema.optional(),
  insights: z.record(z.string()).optional(), // 텍스트 기반 인사이트들
  recommendations: z.array(z.string()).optional(), // 추천사항들
  warnings: z.array(z.string()).optional(), // 주의사항들
  lucky_items: LuckyItemsSchema.optional(),
  metadata: z.record(z.any()).optional() // 기타 메타데이터
});

export type FortuneResult = z.infer<typeof FortuneResultSchema>;

// =============================================================================
// 각 운세 타입별 특화 스키마
// =============================================================================

// 케미 운세 스키마
export const ChemistryResultSchema = FortuneResultSchema.extend({
    overall_chemistry: z.number(),
    physical_attraction: z.number(),
    emotional_connection: z.number(),
    passion_intensity: z.number(),
    compatibility_level: z.number(),
    intimacy_potential: z.number(),
    insights: z.object({
        strengths: z.string(),
        challenges: z.string(),
        enhancement_tips: z.string(),
    }),
    detailed_analysis: z.object({
        physical_chemistry: z.string(),
        emotional_bond: z.string(),
        passion_dynamics: z.string(),
        intimacy_forecast: z.string(),
    }),
    recommendations: z.object({
        enhancement_activities: z.array(z.string()),
        communication_tips: z.array(z.string()),
        intimacy_advice: z.array(z.string()),
    }),
    warnings: z.array(z.string()),
    compatibility_percentage: z.number(),
});

// 커플 매칭 운세 스키마
export const CoupleMatchResultSchema = FortuneResultSchema.extend({
    currentFlow: z.number(),
    futurePotential: z.number(),
    advice1: z.string(),
    advice2: z.string(),
    tips: z.array(z.string()),
});

// 전 연인 운세 스키마
export const ExLoverResultSchema = FortuneResultSchema.extend({
    closure_score: z.number(),
    reconciliation_chance: z.number(),
    emotional_healing: z.number(),
    future_relationship_impact: z.number(),
    insights: z.object({
        current_status: z.string(),
        emotional_state: z.string(),
        advice: z.string(),
    }),
    closure_activities: z.array(z.string()),
    warning_signs: z.array(z.string()),
    positive_aspects: z.array(z.string()),
    timeline: z.object({
        healing_phase: z.string(),
        duration: z.string(),
        next_steps: z.string(),
    }),
});

// 소개팅 운세 스키마
export const BlindDateResultSchema = FortuneResultSchema.extend({
    success_rate: z.number(),
    chemistry_score: z.number(),
    conversation_score: z.number(),
    impression_score: z.number(),
    insights: z.object({
        personality_analysis: z.string(),
        strengths: z.string(),
        areas_to_improve: z.string(),
    }),
    recommendations: z.object({
        ideal_venues: z.array(z.string()),
        conversation_topics: z.array(z.string()),
        style_tips: z.array(z.string()),
        behavior_tips: z.array(z.string()),
    }),
    timeline: z.object({
        best_timing: z.string(),
        preparation_period: z.string(),
        success_indicators: z.array(z.string()),
    }),
    warnings: z.array(z.string()),
});

// 연예인 궁합 운세 스키마
export const CelebrityMatchResultSchema = FortuneResultSchema.extend({
    score: z.number(),
    comment: z.string(),
    luckyColor: z.string(),
    luckyItem: z.string(),
});

// 사주팔자 특화 스키마
export const SajuResultSchema = FortuneResultSchema.extend({
  summary: z.string(),
  totalFortune: z.string().optional(),
  manse: z.object({
    solar: z.string(),
    lunar: z.string(),
    ganji: z.string(),
  }).optional(),
  saju: z.object({
    heaven: z.array(z.string()),
    earth: z.array(z.string()),
  }).optional(),
  elements: z.array(z.object({
    subject: z.string(),
    value: z.number(),
  })).optional(),
  life_cycles: z.object({
    youth: z.string(),
    middle: z.string(),
    old: z.string(),
  }).optional(),
  ten_stars: z.array(z.object({
    name: z.string(),
    meaning: z.string(),
  })).optional(),
  twelve_fortunes: z.array(z.object({
    name: z.string(),
    description: z.string(),
  })).optional(),
  ten_gods: z.record(z.string()).optional(),
  blessings: z.array(z.object({
    name: z.string(),
    description: z.string(),
  })).optional(),
  curses: z.array(z.object({
    name: z.string(),
    description: z.string(),
  })).optional(),
});

export type SajuResult = z.infer<typeof SajuResultSchema>;

// MBTI 운세 특화 스키마
export const MBTIResultSchema = FortuneResultSchema.extend({
  mbti_analysis: z.object({
    type: z.string(),
    name: z.string(),
    emoji: z.string().optional(),
    characteristics: z.array(z.string()),
    compatibility: z.object({
      best_match: z.array(z.string()),
      good_match: z.array(z.string()),
      challenging: z.array(z.string()),
    }).optional(),
  }),
  weekly_fortune: z.object({
    overall: z.number().min(0).max(100),
    love: z.number().min(0).max(100),
    career: z.number().min(0).max(100),
    wealth: z.number().min(0).max(100),
    summary: z.string(),
    keywords: z.array(z.string()),
    advice: z.string(),
  }).optional(),
  career_suggestions: z.array(z.string()).optional(),
  relationship_advice: z.string().optional(),
});

export type MBTIResult = z.infer<typeof MBTIResultSchema>;



// 관상 분석 특화 스키마
export const FaceAnalysisSchema = z.object({
  shape: z.string(),
  meaning: z.string(),
  fortune: z.string(),
});

export const PhysiognomyResultSchema = FortuneResultSchema.extend({
  face_analysis: z.object({
    face_shape: z.string(),
    eye_analysis: FaceAnalysisSchema,
    nose_analysis: FaceAnalysisSchema,
    mouth_analysis: FaceAnalysisSchema,
  }),
  personality_traits: z.array(z.string()),
  life_fortune: z.object({
    wealth: z.number().min(0).max(100),
    love: z.number().min(0).max(100),
    career: z.number().min(0).max(100),
    health: z.number().min(0).max(100),
  }),
});

export type PhysiognomyResult = z.infer<typeof PhysiognomyResultSchema>;

// 운동 관련 운세 (등산, 자전거 등) 공통 스키마
export const ActivityFortuneResultSchema = FortuneResultSchema.extend({
  activity_scores: z.record(z.number().min(0).max(100)), // 활동별 점수
  activity_items: z.record(z.string()), // 활동 관련 행운 아이템
  safety_advice: z.array(z.string()).optional(),
  performance_tips: z.array(z.string()).optional(),
});

export type ActivityFortuneResult = z.infer<typeof ActivityFortuneResultSchema>;

// 행운의 등산 특화 스키마
export const HikingFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
    summit_luck: z.number().min(0).max(100),
    weather_luck: z.number().min(0).max(100),
    safety_luck: z.number().min(0).max(100),
    endurance_luck: z.number().min(0).max(100),
  }),
  lucky_items: z.object({
    lucky_trail: z.string(),
    lucky_mountain: z.string(),
    lucky_hiking_time: z.string(),
    lucky_weather: z.string(),
  }).optional(),
  metadata: z.object({
    hiking_level: z.string(),
    current_goal: z.string().optional(),
  }).optional(),
});

export type HikingFortuneResult = z.infer<typeof HikingFortuneResultSchema>;

// 스포츠 운세 공통 스키마 (테니스, 골프, 야구 등)
export const SportsFortuneResultSchema = FortuneResultSchema.extend({
  analysis: z.object({
    strength: z.string(),
    weakness: z.string(),
    opportunity: z.string(),
    challenge: z.string().optional(),
    threat: z.string().optional(),
  }),
  sport_recommendations: z.object({
    training_tips: z.array(z.string()),
    game_strategies: z.array(z.string()).optional(),
    equipment_advice: z.array(z.string()).optional(),
    mental_preparation: z.array(z.string()).optional(),
  }),
  future_predictions: z.object({
    this_week: z.string(),
    this_month: z.string(),
    this_season: z.string().optional(),
  }),
  compatibility: z.object({
    best_teammate_type: z.string().optional(),
    ideal_coach_style: z.string().optional(),
    perfect_opponent: z.string().optional(),
  }).optional(),
});

export type SportsFortuneResult = z.infer<typeof SportsFortuneResultSchema>;

// 투자/부동산 운세 스키마
export const InvestmentFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
    investment_luck: z.number().min(0).max(100).optional(),
    trading_luck: z.number().min(0).max(100).optional(),
    profit_luck: z.number().min(0).max(100).optional(),
    timing_luck: z.number().min(0).max(100).optional(),
    buying_luck: z.number().min(0).max(100).optional(),
    selling_luck: z.number().min(0).max(100).optional(),
    rental_luck: z.number().min(0).max(100).optional(),
    location_luck: z.number().min(0).max(100).optional(),
  }),
  analysis: z.object({
    strength: z.string(),
    weakness: z.string(),
    opportunity: z.string(),
    risk: z.string(),
  }),
  lucky_elements: z.object({
    assets: z.array(z.string()).optional(),
    areas: z.array(z.string()).optional(),
    property_types: z.array(z.string()).optional(),
    timing: z.string().optional(),
    direction: z.string().optional(),
    floor_preference: z.string().optional(),
  }).optional(),
  lucky_timing: z.object({
    best_months: z.array(z.string()).optional(),
    best_days: z.array(z.string()).optional(),
    best_time: z.string().optional(),
  }).optional(),
  investment_recommendations: z.object({
    investment_tips: z.array(z.string()),
    risk_management: z.array(z.string()),
    timing_strategies: z.array(z.string()),
    portfolio_advice: z.array(z.string()).optional(),
    location_advice: z.array(z.string()).optional(),
  }),
  future_predictions: z.object({
    this_month: z.string(),
    next_quarter: z.string(),
    this_year: z.string(),
  }),
  lucky_numbers: z.array(z.number()).optional(),
  warning_signs: z.array(z.string()).optional(),
});

export type InvestmentFortuneResult = z.infer<typeof InvestmentFortuneResultSchema>;

// 띠별/별자리 운세 스키마
export const ZodiacAnimalResultSchema = FortuneResultSchema.extend({
  zodiac_info: z.object({
    animal: z.string(),
    year: z.number(),
    element: z.string().optional(),
    characteristics: z.array(z.string()),
  }),
  monthly_fortune: z.object({
    overall: z.number().min(0).max(100),
    love: z.number().min(0).max(100),
    career: z.number().min(0).max(100),
    wealth: z.number().min(0).max(100),
    health: z.number().min(0).max(100),
  }),
  compatibility: z.object({
    best_match: z.array(z.string()),
    good_match: z.array(z.string()),
    avoid: z.array(z.string()),
  }),
});

export type ZodiacAnimalResult = z.infer<typeof ZodiacAnimalResultSchema>;

// 별자리 운세 스키마
export const ZodiacResultSchema = FortuneResultSchema.extend({
  zodiac_info: z.object({
    sign: z.string(),
    element: z.string(),
    ruling_planet: z.string(),
    characteristics: z.array(z.string()),
  }),
  daily_fortune: z.object({
    overall: z.number().min(0).max(100),
    love: z.number().min(0).max(100),
    career: z.number().min(0).max(100),
    wealth: z.number().min(0).max(100),
    health: z.number().min(0).max(100),
  }),
});

export type ZodiacResult = z.infer<typeof ZodiacResultSchema>;

// 궁합 분석 스키마
export const CompatibilityResultSchema = FortuneResultSchema.extend({
  compatibility_scores: z.object({
    overall_score: z.number().min(0).max(100),
    love_score: z.number().min(0).max(100),
    marriage_score: z.number().min(0).max(100),
    career_score: z.number().min(0).max(100),
    daily_life_score: z.number().min(0).max(100),
  }),
  personality_analysis: z.object({
    person1: z.string(),
    person2: z.string(),
  }),
  strengths: z.array(z.string()),
  challenges: z.array(z.string()),
  advice: z.string(),
  lucky_elements: z.object({
    color: z.string(),
    number: z.number(),
    direction: z.string(),
    date: z.string(),
  }),
});

export type CompatibilityResult = z.infer<typeof CompatibilityResultSchema>;

// 행운의 색깔/숫자 스키마
export const LuckyColorResultSchema = FortuneResultSchema.extend({
  main_color: z.object({
    name: z.string(),
    hex: z.string(),
    meaning: z.string(),
    effects: z.array(z.string()),
  }),
  secondary_colors: z.array(z.object({
    name: z.string(),
    hex: z.string(),
    meaning: z.string(),
  })),
  avoid_colors: z.array(z.string()).optional(),
  usage_tips: z.array(z.string()),
});

export type LuckyColorResult = z.infer<typeof LuckyColorResultSchema>;

export const LuckyNumberResultSchema = FortuneResultSchema.extend({
  main_number: z.object({
    number: z.number(),
    meaning: z.string(),
    effects: z.array(z.string()),
  }),
  secondary_numbers: z.array(z.number()),
  avoid_numbers: z.array(z.number()).optional(),
  usage_tips: z.array(z.string()),
});

export type LuckyNumberResult = z.infer<typeof LuckyNumberResultSchema>;

// 음식 운세 스키마
export const FoodFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
    health_luck: z.number().min(0).max(100),
    wealth_luck: z.number().min(0).max(100),
    love_luck: z.number().min(0).max(100),
    career_luck: z.number().min(0).max(100),
  }),
  lucky_foods: z.object({
    main_dish: z.string(),
    side_dish: z.string(),
    beverage: z.string(),
    dessert: z.string(),
    snack: z.string(),
  }),
  lucky_ingredients: z.array(z.string()),
  lucky_cooking_methods: z.array(z.string()),
  meal_timing_guide: z.object({
    breakfast: z.string(),
    lunch: z.string(),
    dinner: z.string(),
    snack_time: z.string(),
  }),
  weekly_menu: z.record(z.object({
    breakfast: z.string(),
    lunch: z.string(),
    dinner: z.string(),
    special_note: z.string(),
  })).optional(),
  food_rituals: z.array(z.string()).optional(),
  health_benefits: z.array(z.string()).optional(),
  wealth_foods: z.array(z.string()).optional(),
  love_foods: z.array(z.string()).optional(),
  avoid_foods: z.array(z.string()).optional(),
});

export type FoodFortuneResult = z.infer<typeof FoodFortuneResultSchema>;

// 비즈니스/창업 운세 스키마
export const BusinessFortuneResultSchema = FortuneResultSchema.extend({
  business_score: z.number().min(0).max(100),
  best_industries: z.array(z.string()),
  best_start_time: z.string(),
  ideal_partners: z.array(z.string()),
  success_tips: z.array(z.string()),
  cautions: z.array(z.string()),
  funding_advice: z.object({
    best_timing: z.string(),
    recommended_sources: z.array(z.string()),
    amount_guidance: z.string(),
  }).optional(),
  market_analysis: z.object({
    opportunities: z.array(z.string()),
    threats: z.array(z.string()),
    trends: z.array(z.string()),
  }).optional(),
});

export type BusinessFortuneResult = z.infer<typeof BusinessFortuneResultSchema>;

// 연애/결혼 운세 특화 스키마
export const LoveFortuneResultSchema = FortuneResultSchema.extend({
  love_scores: z.object({
    today_score: z.number().min(0).max(100),
    weekly_score: z.number().min(0).max(100),
    monthly_score: z.number().min(0).max(100),
    yearly_score: z.number().min(0).max(100).optional(),
  }),
  summary: z.string(),
  advice: z.string(),
  lucky_time: z.string(),
  lucky_place: z.string(),
  lucky_color: z.string(),
  best_marriage_months: z.array(z.string()).optional(),
  compatibility: z.object({
    best_age: z.string().optional(),
    good_seasons: z.array(z.string()).optional(),
    ideal_partner: z.array(z.string()),
    avoid: z.array(z.string()),
  }),
  timeline: z.object({
    engagement: z.string().optional(),
    wedding: z.string().optional(),
    honeymoon: z.string().optional(),
    new_home: z.string().optional(),
  }).optional(),
  predictions: z.object({
    today: z.string(),
    this_week: z.string(),
    this_month: z.string(),
    this_year: z.string().optional(),
  }),
  preparation: z.object({
    emotional: z.array(z.string()).optional(),
    practical: z.array(z.string()).optional(),
    financial: z.array(z.string()).optional(),
  }).optional(),
  action_items: z.array(z.string()),
});

export type LoveFortuneResult = z.infer<typeof LoveFortuneResultSchema>;

// 운명/인연 운세 스키마  
export const DestinyFortuneResultSchema = FortuneResultSchema.extend({
  destiny_score: z.number().min(0).max(100),
  summary: z.string(),
  advice: z.string(),
  meeting_period: z.string(),
  meeting_place: z.string(),
  partner_traits: z.array(z.string()),
  development_chance: z.string(),
  predictions: z.object({
    first_meeting: z.string(),
    relationship: z.string(),
    long_term: z.string(),
  }),
  action_items: z.array(z.string()),
});

export type DestinyFortuneResult = z.infer<typeof DestinyFortuneResultSchema>;

// 전생/과거생 분석 스키마
export const PastLifeResultSchema = FortuneResultSchema.extend({
  summary: z.string(),
  profession: z.string(),
  personality: z.string(),
  influence: z.string(),
  advice: z.array(z.string()),
  connections: z.object({
    current_relationships: z.array(z.string()).optional(),
    karmic_lessons: z.array(z.string()).optional(),
    talents_carried_over: z.array(z.string()).optional(),
  }).optional(),
});

export type PastLifeResult = z.infer<typeof PastLifeResultSchema>;

// 관상 분석 특화 스키마
export const FaceReadingFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
    life_fortune: z.object({
      wealth: z.number().min(0).max(100),
      love: z.number().min(0).max(100),
      career: z.number().min(0).max(100),
      health: z.number().min(0).max(100),
    }),
  }),
  insights: z.object({
    face_shape: z.string(),
    eye_analysis: z.object({ shape: z.string(), meaning: z.string(), fortune: z.string() }),
    nose_analysis: z.object({ shape: z.string(), meaning: z.string(), fortune: z.string() }),
    mouth_analysis: z.object({ shape: z.string(), meaning: z.string(), fortune: z.string() }),
    personality_traits: z.array(z.string()),
    lucky_advice: z.string(),
  }),
  metadata: z.object({
    gender: z.string(),
    image_url: z.string(),
  }).optional(),
});

export type FaceReadingFortuneResult = z.infer<typeof FaceReadingFortuneResultSchema>;

// 혈액형 운세 특화 스키마
export const BloodTypeFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
    personality_match: z.number().min(0).max(100),
    love_match: z.number().min(0).max(100),
    career_match: z.number().min(0).max(100),
    health_match: z.number().min(0).max(100),
  }),
  insights: z.object({
    blood_type_traits: z.string(),
    lucky_advice: z.string(),
  }),
  lucky_items: z.object({
    compatible_blood_types: z.array(z.string()),
  }),
  metadata: z.object({
    blood_type: z.string(),
  }).optional(),
});

export type BloodTypeFortuneResult = z.infer<typeof BloodTypeFortuneResultSchema>;

// 심리 테스트 운세 특화 스키마
export const PsychologyTestFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
  }),
  insights: z.object({
    test_result_type: z.string(),
    result_summary: z.string(),
    result_details: z.string(),
    advice: z.string(),
  }),
  lucky_items: z.object({
    lucky_elements: z.array(z.string()),
  }),
  metadata: z.object({
    answers: z.record(z.string()),
  }).optional(),
});

export type PsychologyTestFortuneResult = z.infer<typeof PsychologyTestFortuneResultSchema>;

// 고민 구슬 운세 특화 스키마
export const WorryBeadFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
    peace_score: z.number().min(0).max(100),
  }),
  insights: z.object({
    worry_analysis: z.string(),
    solution_advice: z.string(),
  }),
  lucky_items: z.object({
    lucky_elements: z.array(z.string()),
  }),
  metadata: z.object({
    worry_content: z.string(),
  }).optional(),
});

export type WorryBeadFortuneResult = z.infer<typeof WorryBeadFortuneResultSchema>;

// 태몽 운세 특화 스키마
export const TaemongFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
  }),
  insights: z.object({
    taemong_summary: z.string(),
    taemong_interpretation: z.string(),
    child_gender_prediction: z.string(),
    child_characteristics: z.array(z.string()),
    lucky_advice: z.string(),
  }),
  metadata: z.object({
    taemong_content: z.string(),
  }).optional(),
});

export type TaemongFortuneResult = z.infer<typeof TaemongFortuneResultSchema>;

// 포춘 쿠키 운세 특화 스키마
export const FortuneCookieFortuneResultSchema = FortuneResultSchema.extend({
  fortune_scores: z.object({
    overall_luck: z.number().min(0).max(100),
  }),
  insights: z.object({
    fortune_message: z.string(),
    advice: z.string(),
  }),
  lucky_items: z.object({
    lucky_numbers: z.array(z.number()),
    lucky_color: z.string(),
  }),
});

export type FortuneCookieFortuneResult = z.infer<typeof FortuneCookieFortuneResultSchema>;

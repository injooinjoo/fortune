/**
 * GPT 운세 추출을 위한 3가지 시나리오별 JSON 구조 정의
 * 
 * 1. 온보딩 완료 후 초기 운세 생성 (일회성 평생 운세)
 * 2. 새로운 하루 시작 시 일일 운세 생성
 * 3. 사용자 직접 요청 시 특정 운세 생성
 */

import { z } from 'zod';

// =============================================================================
// 공통 사용자 정보 스키마
// =============================================================================

export const BaseUserProfileSchema = z.object({
  id: z.string(),
  name: z.string(),
  birth_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/), // YYYY-MM-DD
  birth_time: z.string().optional(), // 인시, 자시 등 또는 '모름'
  gender: z.enum(['남성', '여성', '선택 안함']),
  mbti: z.string().optional(),
  zodiac_sign: z.string().optional(), // 처녀자리, 물병자리 등
  created_at: z.string(),
  updated_at: z.string()
});

export type BaseUserProfile = z.infer<typeof BaseUserProfileSchema>;

// =============================================================================
// 📦 묶음 요청 스키마 (토큰 효율성 최적화)
// =============================================================================

// 전통·사주 패키지 (5개 묶음) - 365일 캐시
export const TraditionalPackageInputSchema = z.object({
  request_type: z.literal('traditional_package'),
  fortune_types: z.array(z.enum(['saju', 'traditional-saju', 'tojeong', 'salpuli', 'past-life'])),
  user_profile: BaseUserProfileSchema,
  analysis_depth: z.enum(['basic', 'detailed', 'comprehensive']).default('comprehensive'),
  context: z.string(),
});

export const TraditionalPackageOutputSchema = z.object({
  request_type: z.literal('traditional_package'),
  analysis_results: z.object({
    saju: z.object({
      birth_chart: z.object({
        year_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
        month_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
        day_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
        time_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
      }),
      five_elements: z.record(z.object({
        score: z.number(),
        percentage: z.number(),
        strength: z.string(),
      })),
      fortune_summary: z.object({
        overall_score: z.number(),
        career_fortune: z.number(),
        wealth_fortune: z.number(),
        love_fortune: z.number(),
        health_fortune: z.number(),
      }),
    }),
    traditional_saju: z.object({
      major_life_phases: z.array(z.object({
        age_range: z.string(),
        description: z.string(),
        fortune_level: z.number(),
      })),
      ten_gods_analysis: z.object({
        dominant_god: z.string(),
        support_gods: z.array(z.string()),
        caution_gods: z.array(z.string()),
      }),
    }),
    tojeong: z.object({
      new_year_fortune: z.object({
        overall_hexagram: z.string(),
        interpretation: z.string(),
        monthly_fortune: z.array(z.object({
          month: z.number(),
          score: z.number(),
          advice: z.string(),
        })),
      }),
    }),
    salpuli: z.object({
      harmful_influences: z.array(z.object({
        name: z.string(),
        description: z.string(),
        solution: z.string(),
      })),
      protection_methods: z.array(z.string()),
    }),
    past_life: z.object({
      previous_occupation: z.string(),
      karma_lessons: z.array(z.string()),
      talents_carried: z.array(z.string()),
      relationships: z.string(),
    }),
  }),
  package_summary: z.object({
    core_destiny: z.string(),
    life_mission: z.string(),
    major_challenges: z.array(z.string()),
    success_timing: z.string(),
  }),
  generated_at: z.string(),
  cache_duration: z.string().default('365d'),
});

// 일일 종합 패키지 (4개 묶음) - 24시간 캐시
export const DailyPackageInputSchema = z.object({
  request_type: z.literal('daily_package'),
  fortune_types: z.array(z.enum(['daily', 'hourly', 'today', 'tomorrow'])),
  user_profile: BaseUserProfileSchema,
  target_date: z.string(),
  context: z.string(),
});

export const DailyPackageOutputSchema = z.object({
  request_type: z.literal('daily_package'),
  target_date: z.string(),
  analysis_results: z.object({
    daily: z.object({
      overall_fortune: z.object({
        score: z.number(),
        level: z.string(),
        summary: z.string(),
      }),
      detailed_fortune: z.object({
        love: z.object({ score: z.number(), advice: z.string() }),
        wealth: z.object({ score: z.number(), advice: z.string() }),
        career: z.object({ score: z.number(), advice: z.string() }),
        health: z.object({ score: z.number(), advice: z.string() }),
      }),
    }),
    today: z.object({
      theme: z.string(),
      key_energy: z.string(),
      best_activity: z.string(),
      avoid_activity: z.string(),
    }),
    tomorrow: z.object({
      forecast: z.object({
        score: z.number(),
        trend: z.string(),
        focus: z.string(),
      }),
      preparation: z.string(),
    }),
    hourly: z.array(z.object({
      time: z.string(),
      score: z.number(),
      activity: z.string(),
    })),
  }),
  unified_recommendations: z.object({
    best_time_slot: z.string(),
    caution_period: z.string(),
    lucky_elements: z.object({
      color: z.string(),
      number: z.array(z.number()),
      direction: z.string(),
    }),
  }),
  generated_at: z.string(),
  cache_duration: z.string().default('24h'),
});

// 연애·인연 패키지 (솔로용 4개 묶음) - 72시간 캐시
export const LovePackageSingleInputSchema = z.object({
  request_type: z.literal('love_package_single'),
  fortune_types: z.array(z.enum(['love', 'destiny', 'blind-date', 'celebrity-match'])),
  user_profile: BaseUserProfileSchema.extend({
    relationship_status: z.literal('솔로'),
    celebrity_interest: z.string().optional(),
  }),
  analysis_period: z.string(),
  context: z.string(),
});

export const LovePackageSingleOutputSchema = z.object({
  request_type: z.literal('love_package_single'),
  analysis_results: z.object({
    love: z.object({
      current_energy: z.object({
        phase: z.string(),
        score: z.number(),
        description: z.string(),
      }),
      meeting_forecast: z.object({
        next_3_months: z.array(z.object({
          month: z.number(),
          probability: z.number(),
          venue: z.string(),
        })),
      }),
      ideal_type_analysis: z.object({
        compatible_mbti: z.array(z.string()),
        preferred_personality: z.string(),
        age_range: z.string(),
        profession_match: z.array(z.string()),
      }),
    }),
    destiny: z.object({
      soulmate_timing: z.object({
        peak_period: z.string(),
        secondary_period: z.string(),
        signs: z.array(z.string()),
      }),
      relationship_pattern: z.string(),
      past_life_connection: z.string(),
    }),
    blind_date: z.object({
      success_probability: z.number(),
      best_timing: z.string(),
      recommended_venues: z.array(z.string()),
      conversation_tips: z.array(z.string()),
      outfit_suggestions: z.object({
        style: z.string(),
        colors: z.array(z.string()),
        avoid: z.string(),
      }),
    }),
    celebrity_match: z.object({
      target_celebrity: z.string(),
      compatibility_score: z.number(),
      matching_points: z.array(z.string()),
      challenge_points: z.array(z.string()),
      if_dating_scenario: z.object({
        relationship_style: z.string(),
        ideal_date: z.string(),
        long_term_potential: z.string(),
      }),
    }),
  }),
  unified_love_strategy: z.object({
    action_plan: z.array(z.string()),
    self_improvement: z.array(z.string()),
    timing_calendar: z.object({
      best_dates: z.array(z.string()),
      avoid_dates: z.array(z.string()),
    }),
  }),
  generated_at: z.string(),
  cache_duration: z.string().default('72h'),
});

// 취업·재물 패키지 (4개 묶음) - 168시간 캐시
export const CareerWealthPackageInputSchema = z.object({
  request_type: z.literal('career_wealth_package'),
  fortune_types: z.array(z.enum(['career', 'wealth', 'business', 'lucky-investment'])),
  user_profile: BaseUserProfileSchema.extend({
    current_job: z.string().optional(),
    industry: z.string().optional(),
    investment_interest: z.string().optional(),
  }),
  analysis_period: z.string(),
  context: z.string(),
});

export const CareerWealthPackageOutputSchema = z.object({
  request_type: z.literal('career_wealth_package'),
  analysis_results: z.object({
    career: z.object({
      promotion_forecast: z.object({
        probability: z.number(),
        target_timing: z.string(),
        required_skills: z.array(z.string()),
        networking_strategy: z.string(),
      }),
      job_change_analysis: z.object({
        recommended: z.boolean(),
        reason: z.string(),
        if_considering: z.string(),
      }),
    }),
    wealth: z.object({
      income_growth: z.object({
        salary_increase: z.string(),
        bonus_opportunity: z.string(),
        additional_income: z.string(),
      }),
      saving_strategy: z.object({
        monthly_target: z.string(),
        emergency_fund: z.string(),
        long_term_goal: z.string(),
      }),
    }),
    business: z.object({
      startup_potential: z.number(),
      best_timing: z.string(),
      recommended_field: z.string(),
      current_preparation: z.array(z.string()),
    }),
    lucky_investment: z.object({
      stock_forecast: z.record(z.string()),
      real_estate: z.object({
        timing: z.string(),
        location: z.string(),
        investment_type: z.string(),
      }),
      lucky_numbers: z.array(z.number()),
      caution_period: z.string(),
    }),
  }),
  integrated_wealth_plan: z.object({
    short_term_goals: z.array(z.string()),
    long_term_vision: z.string(),
    monthly_action_items: z.array(z.string()),
  }),
  generated_at: z.string(),
  cache_duration: z.string().default('168h'),
});

// 행운 아이템 패키지 (5개 묶음) - 720시간 캐시  
export const LuckyItemsPackageInputSchema = z.object({
  request_type: z.literal('lucky_items_package'),
  fortune_types: z.array(z.enum(['lucky-color', 'lucky-number', 'lucky-items', 'lucky-outfit', 'lucky-food'])),
  user_profile: BaseUserProfileSchema.extend({
    season: z.string().optional(),
    goal: z.string().optional(),
  }),
  target_period: z.string(),
  context: z.string(),
});

export const LuckyItemsPackageOutputSchema = z.object({
  request_type: z.literal('lucky_items_package'),
  analysis_results: z.object({
    lucky_color: z.object({
      primary: z.object({ color: z.string(), name: z.string(), effect: z.string() }),
      secondary: z.object({ color: z.string(), name: z.string(), effect: z.string() }),
      accent: z.object({ color: z.string(), name: z.string(), effect: z.string() }),
      avoid: z.array(z.string()),
    }),
    lucky_number: z.object({
      primary: z.array(z.number()),
      secondary: z.array(z.number()),
      meaning: z.record(z.string()),
      usage_tips: z.string(),
    }),
    lucky_items: z.object({
      accessories: z.array(z.object({ item: z.string(), effect: z.string() })),
      office: z.array(z.object({ item: z.string(), effect: z.string() })),
      home: z.array(z.object({ item: z.string(), effect: z.string() })),
    }),
    lucky_outfit: z.object({
      business: z.record(z.string()),
      casual: z.record(z.string()),
      special_occasion: z.string(),
    }),
    lucky_food: z.object({
      daily: z.array(z.object({ food: z.string(), time: z.string(), effect: z.string() })),
      weekly_special: z.array(z.object({ day: z.string(), food: z.string(), effect: z.string() })),
      avoid: z.array(z.string()),
    }),
  }),
  daily_combination_guide: z.object({
    morning_ritual: z.string(),
    work_setup: z.string(),
    evening_routine: z.string(),
    weekly_reset: z.string(),
  }),
  generated_at: z.string(),
  cache_duration: z.string().default('720h'),
});

// =============================================================================
// 개별 운세별 상세 인풋/아웃풋 스키마 (GPT 직접 호출용)
// =============================================================================

// 사주팔자 요청/응답
export const SajuFortuneInputSchema = z.object({
  fortune_type: z.literal('saju'),
  user_profile: z.object({
    name: z.string(),
    birth_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    birth_time: z.string(),
    gender: z.enum(['남성', '여성']),
    mbti: z.string().optional(),
    zodiac_sign: z.string().optional()
  }),
  analysis_depth: z.enum(['basic', 'comprehensive', 'expert']).default('comprehensive'),
  focus_areas: z.array(z.string()).default(['천간지지', '오행분석', '십신분석', '대운흐름', '연월일시주']),
  context: z.string()
});

export const SajuFortuneOutputSchema = z.object({
  fortune_type: z.literal('saju'),
  analysis_result: z.object({
    birth_chart: z.object({
      year_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
      month_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
      day_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() }),
      time_pillar: z.object({ heavenly: z.string(), earthly: z.string(), element: z.string() })
    }),
    five_elements: z.record(z.object({
      score: z.number(),
      percentage: z.number(),
      strength: z.string()
    })),
    personality_analysis: z.object({
      core_traits: z.array(z.string()),
      strengths: z.array(z.string()),
      weaknesses: z.array(z.string()),
      suitable_roles: z.array(z.string())
    }),
    life_periods: z.object({
      youth: z.string(),
      middle_age: z.string(),
      old_age: z.string()
    }),
    fortune_summary: z.object({
      overall_score: z.number(),
      career_fortune: z.number(),
      wealth_fortune: z.number(),
      love_fortune: z.number(),
      health_fortune: z.number()
    }),
    advice: z.object({
      general: z.string(),
      career: z.string(),
      relationships: z.string(),
      health: z.string()
    })
  }),
  generated_at: z.string(),
  cache_duration: z.string(),
  confidence_score: z.number().optional(),
  related_fortunes: z.array(z.string()).optional()
});

// 일일 운세 요청/응답
export const DailyFortuneInputSchema = z.object({
  fortune_type: z.literal('daily'),
  user_profile: z.object({
    name: z.string(),
    birth_date: z.string(),
    birth_time: z.string().optional(),
    gender: z.enum(['남성', '여성']),
    mbti: z.string().optional()
  }),
  current_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  analysis_scope: z.array(z.string()).default(['총운', '애정운', '재물운', '건강운', '직장운']),
  context: z.string()
});

export const DailyFortuneOutputSchema = z.object({
  fortune_type: z.literal('daily'),
  date: z.string(),
  analysis_result: z.object({
    overall_fortune: z.object({
      score: z.number(),
      level: z.string(),
      summary: z.string(),
      lucky_time: z.string(),
      caution_time: z.string()
    }),
    detailed_fortune: z.record(z.object({
      score: z.number(),
      description: z.string(),
      advice: z.string()
    })),
    daily_recommendations: z.object({
      lucky_color: z.string(),
      lucky_number: z.array(z.number()),
      lucky_direction: z.string(),
      recommended_activities: z.array(z.string()),
      foods_to_avoid: z.array(z.string())
    })
  }),
  generated_at: z.string(),
  cache_duration: z.string()
});

// 연애운 요청/응답
export const LoveFortuneInputSchema = z.object({
  fortune_type: z.literal('love'),
  user_profile: z.object({
    name: z.string(),
    birth_date: z.string(),
    gender: z.enum(['남성', '여성']),
    relationship_status: z.enum(['솔로', '연애중', '결혼', '이혼']),
    mbti: z.string().optional()
  }),
  analysis_period: z.string().default('3개월'),
  focus_areas: z.array(z.string()).default(['새로운만남', '연애가능성', '이상형', '연애스타일']),
  context: z.string()
});

export const LoveFortuneOutputSchema = z.object({
  fortune_type: z.literal('love'),
  analysis_result: z.object({
    current_love_phase: z.object({
      status: z.string(),
      score: z.number(),
      description: z.string(),
      peak_period: z.string()
    }),
    meeting_forecast: z.object({
      probability: z.number(),
      best_places: z.array(z.string()),
      ideal_timing: z.array(z.string()),
      warning_periods: z.array(z.string())
    }),
    ideal_partner: z.object({
      personality: z.array(z.string()),
      compatible_mbti: z.array(z.string()),
      recommended_age_gap: z.string(),
      occupation_match: z.array(z.string())
    }),
    relationship_advice: z.object({
      dating_style: z.string(),
      communication_tips: z.string(),
      growth_areas: z.array(z.string())
    })
  }),
  generated_at: z.string(),
  cache_duration: z.string()
});

// 커리어 운세 요청/응답
export const CareerFortuneInputSchema = z.object({
  fortune_type: z.literal('career'),
  user_profile: z.object({
    name: z.string(),
    birth_date: z.string(),
    education: z.string().optional(),
    current_status: z.enum(['재직중', '구직중', '학생', '자영업']),
    career_goal: z.string().optional()
  }),
  analysis_scope: z.array(z.string()).default(['승진운', '이직운', '사업운', '인맥운']),
  time_horizon: z.string().default('1년'),
  context: z.string()
});

export const CareerFortuneOutputSchema = z.object({
  fortune_type: z.literal('career'),
  analysis_result: z.object({
    career_trajectory: z.object({
      current_phase: z.string(),
      success_probability: z.number(),
      breakthrough_timing: z.string(),
      key_challenges: z.array(z.string())
    }),
    promotion_forecast: z.object({
      likelihood: z.number(),
      optimal_timing: z.string(),
      preparation_areas: z.array(z.string()),
      success_factors: z.array(z.string())
    }),
    job_change_analysis: z.object({
      recommendation: z.string(),
      if_changing: z.object({
        best_timing: z.string(),
        suitable_industries: z.array(z.string()),
        avoid_periods: z.array(z.string())
      })
    }),
    networking_strategy: z.object({
      focus_groups: z.array(z.string()),
      key_events: z.array(z.string()),
      relationship_building: z.string()
    })
  }),
  generated_at: z.string(),
  cache_duration: z.string()
});

// 행운의 색깔 요청/응답
export const LuckyColorInputSchema = z.object({
  fortune_type: z.literal('lucky-color'),
  user_profile: z.object({
    name: z.string(),
    birth_date: z.string(),
    current_mood: z.string().optional(),
    desired_effect: z.string().optional()
  }),
  context: z.string(),
  application_areas: z.array(z.string()).default(['의상', '소품', '인테리어', '디지털기기'])
});

export const LuckyColorOutputSchema = z.object({
  fortune_type: z.literal('lucky-color'),
  analysis_result: z.object({
    primary_color: z.object({
      name: z.string(),
      hex: z.string(),
      effect: z.string(),
      psychological_impact: z.string()
    }),
    secondary_colors: z.array(z.object({
      name: z.string(),
      hex: z.string(),
      usage: z.string(),
      benefit: z.string()
    })),
    application_guide: z.object({
      clothing: z.string(),
      workspace: z.string(),
      home: z.string(),
      digital: z.string()
    }),
    avoid_colors: z.array(z.string()),
    duration: z.string()
  }),
  generated_at: z.string(),
  cache_duration: z.string()
});

// 묶음 요청 타입 정의 (토큰 효율성)
export type TraditionalPackageInput = z.infer<typeof TraditionalPackageInputSchema>;
export type TraditionalPackageOutput = z.infer<typeof TraditionalPackageOutputSchema>;
export type DailyPackageInput = z.infer<typeof DailyPackageInputSchema>;
export type DailyPackageOutput = z.infer<typeof DailyPackageOutputSchema>;
export type LovePackageSingleInput = z.infer<typeof LovePackageSingleInputSchema>;
export type LovePackageSingleOutput = z.infer<typeof LovePackageSingleOutputSchema>;
export type CareerWealthPackageInput = z.infer<typeof CareerWealthPackageInputSchema>;
export type CareerWealthPackageOutput = z.infer<typeof CareerWealthPackageOutputSchema>;
export type LuckyItemsPackageInput = z.infer<typeof LuckyItemsPackageInputSchema>;
export type LuckyItemsPackageOutput = z.infer<typeof LuckyItemsPackageOutputSchema>;

// 개별 운세 타입 정의
export type SajuFortuneInput = z.infer<typeof SajuFortuneInputSchema>;
export type SajuFortuneOutput = z.infer<typeof SajuFortuneOutputSchema>;
export type DailyFortuneInput = z.infer<typeof DailyFortuneInputSchema>;
export type DailyFortuneOutput = z.infer<typeof DailyFortuneOutputSchema>;
export type LoveFortuneInput = z.infer<typeof LoveFortuneInputSchema>;
export type LoveFortuneOutput = z.infer<typeof LoveFortuneOutputSchema>;
export type CareerFortuneInput = z.infer<typeof CareerFortuneInputSchema>;
export type CareerFortuneOutput = z.infer<typeof CareerFortuneOutputSchema>;
export type LuckyColorInput = z.infer<typeof LuckyColorInputSchema>;
export type LuckyColorOutput = z.infer<typeof LuckyColorOutputSchema>;

// =============================================================================
// 1. 온보딩 완료 후 초기 운세 생성 (평생 운세 패키지)
// =============================================================================

export const OnboardingFortuneRequestSchema = z.object({
  request_type: z.literal('onboarding_complete'),
  user_profile: BaseUserProfileSchema,
  requested_categories: z.array(z.string()).default([
    'saju',           // 사주팔자 (필수)
    'traditional-saju', // 전통 사주
    'personality',    // 성격 분석
    'talent',        // 재능 분석
    'destiny',       // 운명 분석
    'past-life',     // 전생 분석
    'five-blessings', // 오복 분석
    'tojeong',       // 토정비결
    'salpuli'        // 살풀이
  ]),
  generation_context: z.object({
    is_initial_setup: z.literal(true),
    include_comprehensive_analysis: z.literal(true),
    cache_duration_hours: z.number().default(8760) // 1년간 캐시
  })
});

export const OnboardingFortuneResponseSchema = z.object({
  request_id: z.string(),
  user_id: z.string(),
  generated_at: z.string(),
  life_profile_data: z.object({
    saju: z.object({
      basic_info: z.object({
        birth_year: z.string(),
        birth_month: z.string(),
        birth_day: z.string(),
        birth_time: z.string().optional()
      }),
      four_pillars: z.object({
        year_pillar: z.object({ heavenly: z.string(), earthly: z.string() }),
        month_pillar: z.object({ heavenly: z.string(), earthly: z.string() }),
        day_pillar: z.object({ heavenly: z.string(), earthly: z.string() }),
        time_pillar: z.object({ heavenly: z.string(), earthly: z.string() }).optional()
      }),
      ten_gods: z.array(z.string()),
      five_elements: z.object({
        wood: z.number(),
        fire: z.number(),
        earth: z.number(),
        metal: z.number(),
        water: z.number()
      }),
      personality_analysis: z.string(),
      life_fortune: z.string(),
      career_fortune: z.string(),
      wealth_fortune: z.string(),
      love_fortune: z.string(),
      health_fortune: z.string()
    }),
    traditional_saju: z.object({
      lucky_gods: z.array(z.string()),
      unlucky_gods: z.array(z.string()),
      life_phases: z.array(z.object({
        age_range: z.string(),
        description: z.string(),
        fortune_level: z.number()
      })),
      major_events: z.array(z.object({
        age: z.number(),
        event_type: z.string(),
        description: z.string()
      }))
    }),
    personality: z.object({
      core_traits: z.array(z.string()),
      strengths: z.array(z.string()),
      weaknesses: z.array(z.string()),
      communication_style: z.string(),
      decision_making: z.string(),
      stress_response: z.string(),
      ideal_career: z.array(z.string()),
      relationship_style: z.string()
    }),
    destiny: z.object({
      soul_mission: z.string(),
      karmic_lessons: z.array(z.string()),
      life_purpose: z.string(),
      spiritual_path: z.string(),
      challenges: z.array(z.string()),
      opportunities: z.array(z.string())
    }),
    talent: z.object({
      natural_talents: z.array(z.string()),
      hidden_abilities: z.array(z.string()),
      development_areas: z.array(z.string()),
      career_recommendations: z.array(z.string()),
      skill_enhancement_tips: z.array(z.string())
    })
  }),
  cache_info: z.object({
    expires_at: z.string(),
    cache_key: z.string()
  })
});

export type OnboardingFortuneRequest = z.infer<typeof OnboardingFortuneRequestSchema>;
export type OnboardingFortuneResponse = z.infer<typeof OnboardingFortuneResponseSchema>;

// =============================================================================
// 2. 새로운 하루 시작 시 일일 운세 생성
// =============================================================================

export const DailyFortuneRequestSchema = z.object({
  request_type: z.literal('daily_refresh'),
  user_profile: BaseUserProfileSchema,
  target_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/), // YYYY-MM-DD
  requested_categories: z.array(z.string()).default([
    'daily',         // 오늘의 종합 운세
    'hourly',        // 시간별 운세
    'wealth',        // 금전운
    'love',          // 연애운
    'career',        // 직장운
    'health',        // 건강운
    'biorhythm'      // 바이오리듬
  ]),
  generation_context: z.object({
    is_daily_auto_generation: z.literal(true),
    previous_day_context: z.object({
      overall_score: z.number().optional(),
      major_events: z.array(z.string()).optional()
    }).optional(),
    cache_duration_hours: z.number().default(24) // 24시간 캐시
  })
});

export const DailyFortuneResponseSchema = z.object({
  request_id: z.string(),
  user_id: z.string(),
  target_date: z.string(),
  generated_at: z.string(),
  daily_comprehensive_data: z.object({
    overall_fortune: z.object({
      score: z.number().min(1).max(100),
      summary: z.string(),
      key_points: z.array(z.string()),
      energy_level: z.number().min(1).max(10),
      mood_forecast: z.string()
    }),
    detailed_fortunes: z.object({
      wealth: z.object({
        score: z.number().min(1).max(100),
        description: z.string(),
        investment_advice: z.string(),
        spending_caution: z.array(z.string())
      }),
      love: z.object({
        score: z.number().min(1).max(100),
        description: z.string(),
        single_advice: z.string(),
        couple_advice: z.string(),
        meeting_probability: z.number().min(0).max(100)
      }),
      career: z.object({
        score: z.number().min(1).max(100),
        description: z.string(),
        work_focus: z.array(z.string()),
        meeting_luck: z.string(),
        decision_timing: z.string()
      }),
      health: z.object({
        score: z.number().min(1).max(100),
        description: z.string(),
        body_care: z.array(z.string()),
        mental_care: z.array(z.string()),
        exercise_recommendation: z.string()
      })
    }),
    lucky_elements: z.object({
      numbers: z.array(z.number()),
      colors: z.array(z.string()),
      foods: z.array(z.string()),
      items: z.array(z.string()),
      directions: z.array(z.string()),
      times: z.array(z.string())
    }),
    hourly_fortune: z.array(z.object({
      hour: z.string(), // "09:00"
      fortune_level: z.number().min(1).max(10),
      activity_recommendation: z.string()
    })),
    biorhythm: z.object({
      physical: z.number().min(-100).max(100),
      emotional: z.number().min(-100).max(100),
      intellectual: z.number().min(-100).max(100),
      intuitive: z.number().min(-100).max(100)
    })
  }),
  cache_info: z.object({
    expires_at: z.string(),
    cache_key: z.string()
  })
});

export type DailyFortuneRequest = z.infer<typeof DailyFortuneRequestSchema>;
export type DailyFortuneResponse = z.infer<typeof DailyFortuneResponseSchema>;

// =============================================================================
// 3. 사용자 직접 요청 시 특정 운세 생성
// =============================================================================

export const DirectFortuneRequestSchema = z.object({
  request_type: z.literal('user_direct_request'),
  user_profile: BaseUserProfileSchema,
  requested_category: z.string(), // 단일 카테고리
  additional_input: z.record(z.any()).optional(), // 추가 입력 데이터 (궁합 상대방 정보 등)
  generation_context: z.object({
    is_user_initiated: z.literal(true),
    request_source: z.enum(['web', 'mobile', 'api']),
    session_id: z.string().optional(),
    previous_related_fortunes: z.array(z.object({
      category: z.string(),
      generated_at: z.string(),
      score: z.number().optional()
    })).optional(),
    cache_duration_hours: z.number().default(1) // 1시간 캐시 (빠른 재생성 허용)
  })
});

export const DirectFortuneResponseSchema = z.object({
  request_id: z.string(),
  user_id: z.string(),
  category: z.string(),
  generated_at: z.string(),
  fortune_data: z.object({
    user_info: z.object({
      name: z.string(),
      birth_date: z.string()
    }),
    fortune_scores: z.record(z.number()).optional(), // 동적 점수 필드들
    insights: z.record(z.string()).optional(), // 텍스트 기반 통찰들
    recommendations: z.array(z.string()).optional(),
    warnings: z.array(z.string()).optional(),
    lucky_items: z.object({
      colors: z.array(z.string()).optional(),
      numbers: z.array(z.number()).optional(),
      items: z.array(z.string()).optional(),
      times: z.array(z.string()).optional(),
      directions: z.array(z.string()).optional()
    }).optional(),
    specialized_data: z.record(z.any()).optional(), // 특화된 운세별 추가 데이터
    metadata: z.record(z.any()).optional()
  }),
  related_suggestions: z.array(z.object({
    category: z.string(),
    title: z.string(),
    reason: z.string()
  })).optional(), // 연관 운세 추천
  cache_info: z.object({
    expires_at: z.string(),
    cache_key: z.string()
  })
});

export type DirectFortuneRequest = z.infer<typeof DirectFortuneRequestSchema>;
export type DirectFortuneResponse = z.infer<typeof DirectFortuneResponseSchema>;

// =============================================================================
// 통합 요청/응답 타입 (Union)
// =============================================================================

export const GPTFortuneRequestSchema = z.union([
  // 기존 3가지 시나리오
  OnboardingFortuneRequestSchema,
  DailyFortuneRequestSchema,
  DirectFortuneRequestSchema,
  // 묶음 요청 (토큰 효율성)
  TraditionalPackageInputSchema,
  DailyPackageInputSchema,
  LovePackageSingleInputSchema,
  CareerWealthPackageInputSchema,
  LuckyItemsPackageInputSchema
]);

export const GPTFortuneResponseSchema = z.union([
  // 기존 3가지 시나리오
  OnboardingFortuneResponseSchema,
  DailyFortuneResponseSchema,
  DirectFortuneResponseSchema,
  // 묶음 요청 (토큰 효율성)
  TraditionalPackageOutputSchema,
  DailyPackageOutputSchema,
  LovePackageSingleOutputSchema,
  CareerWealthPackageOutputSchema,
  LuckyItemsPackageOutputSchema
]);

export type GPTFortuneRequest = z.infer<typeof GPTFortuneRequestSchema>;
export type GPTFortuneResponse = z.infer<typeof GPTFortuneResponseSchema>;

// =============================================================================
// 헬퍼 함수들
// =============================================================================

/**
 * 요청 타입에 따른 적절한 스키마 반환
 */
export function getRequestSchema(requestType: string) {
  switch (requestType) {
    // 기존 3가지 시나리오
    case 'onboarding_complete':
      return OnboardingFortuneRequestSchema;
    case 'daily_refresh':
      return DailyFortuneRequestSchema;
    case 'user_direct_request':
      return DirectFortuneRequestSchema;
    
    // 묶음 요청 (토큰 효율성)
    case 'traditional_package':
      return TraditionalPackageInputSchema;
    case 'daily_package':
      return DailyPackageInputSchema;
    case 'love_package_single':
      return LovePackageSingleInputSchema;
    case 'career_wealth_package':
      return CareerWealthPackageInputSchema;
    case 'lucky_items_package':
      return LuckyItemsPackageInputSchema;
    
    default:
      throw new Error(`지원하지 않는 요청 타입: ${requestType}`);
  }
}

/**
 * 요청 ID 생성
 */
export function generateRequestId(requestType: string, userId: string): string {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 8);
  return `${requestType}_${userId}_${timestamp}_${random}`;
}

/**
 * 캐시 키 생성
 */
export function generateCacheKey(
  requestType: string,
  userId: string,
  targetDate?: string,
  category?: string
): string {
  const parts = [requestType, userId];
  if (targetDate) parts.push(targetDate);
  if (category) parts.push(category);
  return parts.join(':');
} 
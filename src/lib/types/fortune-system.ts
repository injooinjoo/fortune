// 운세 시스템 타입 정의
// 작성일: 2024-12-19

export type FortuneGroupType = 
  | 'LIFE_PROFILE'        // 그룹 1: 평생 고정 정보
  | 'DAILY_COMPREHENSIVE' // 그룹 2: 일일 정보
  | 'INTERACTIVE'         // 그룹 3: 실시간 상호작용
  | 'CLIENT_BASED';       // 그룹 4: 클라이언트 기반

export type FortuneCategory = 
  // 그룹 1: 평생 고정 정보
  | 'saju' | 'traditional-saju' | 'tojeong' | 'past-life' 
  | 'personality' | 'destiny' | 'salpuli' | 'five-blessings' | 'talent'
  // 그룹 2: 일일 정보
  | 'daily' | 'tomorrow' | 'hourly' | 'wealth' | 'love' | 'career'
  | 'lucky-number' | 'lucky-color' | 'lucky-food' | 'biorhythm'
  | 'zodiac-animal' | 'mbti'
  // 그룹 3: 실시간 상호작용
  | 'dream-interpretation' | 'tarot' | 'compatibility' | 'worry-bead';

export interface UserProfile {
  id: string;
  name?: string;
  birth_date: string; // YYYY-MM-DD 형식
  birth_time?: string; // '자시', '축시' 등
  gender?: '남성' | '여성' | '선택 안함';
  mbti?: string; // 'ENFP', 'INTJ' 등
  zodiac_sign?: string; // '양자리', '황소자리' 등
  created_at: string;
  updated_at: string;
}

export interface FortuneData {
  id: string;
  user_id: string;
  fortune_type: FortuneGroupType;
  fortune_category: FortuneCategory;
  data: Record<string, any>; // JSONB 데이터
  input_hash?: string; // 그룹 3용 입력값 해시
  expires_at?: string; // ISO 8601 형식
  created_at: string;
  updated_at: string;
}

export interface FortuneHistory {
  id: string;
  user_id: string;
  fortune_type: FortuneGroupType;
  fortune_category: FortuneCategory;
  viewed_at: string;
  data_snapshot: Record<string, any>;
}

// 그룹 1: 평생 운세 데이터 구조
export interface LifeProfileData {
  saju: {
    basic_info: {
      birth_year: string;
      birth_month: string;
      birth_day: string;
      birth_time?: string;
    };
    four_pillars: {
      year_pillar: { heavenly: string; earthly: string };
      month_pillar: { heavenly: string; earthly: string };
      day_pillar: { heavenly: string; earthly: string };
      time_pillar?: { heavenly: string; earthly: string };
    };
    ten_gods: string[];
    five_elements: {
      wood: number;
      fire: number;
      earth: number;
      metal: number;
      water: number;
    };
    personality_analysis: string;
    life_fortune: string;
    career_fortune: string;
    wealth_fortune: string;
    love_fortune: string;
    health_fortune: string;
  };
  traditionalSaju: {
    lucky_gods: string[];
    unlucky_gods: string[];
    life_phases: Array<{
      age_range: string;
      description: string;
      fortune_level: number;
    }>;
    major_events: Array<{
      age: number;
      event_type: string;
      description: string;
    }>;
  };
  tojeong: {
    yearly_fortune: string;
    monthly_fortunes: Array<{
      month: number;
      fortune: string;
      advice: string;
    }>;
    major_cautions: string[];
    opportunities: string[];
  };
  pastLife: {
    past_identity: string;
    past_location: string;
    past_era: string;
    karmic_lessons: string[];
    soul_mission: string;
    past_relationships: string[];
  };
  personality: {
    core_traits: string[];
    strengths: string[];
    weaknesses: string[];
    communication_style: string;
    decision_making: string;
    stress_response: string;
    ideal_career: string[];
    relationship_style: string;
  };
  destiny: {
    life_purpose: string;
    major_challenges: string[];
    key_opportunities: string[];
    spiritual_growth: string;
    material_success: string;
    relationship_destiny: string;
  };
  salpuli: {
    detected_sal: string[];
    sal_effects: Array<{
      sal_name: string;
      description: string;
      severity: number;
      remedy: string;
    }>;
    purification_methods: string[];
    protection_advice: string[];
  };
  fiveBlessings: {
    longevity: { score: number; description: string };
    wealth: { score: number; description: string };
    health: { score: number; description: string };
    virtue: { score: number; description: string };
    peaceful_death: { score: number; description: string };
    overall_blessing: string;
  };
  talent: {
    innate_talents: string[];
    hidden_abilities: string[];
    development_potential: Array<{
      skill: string;
      potential_level: number;
      development_advice: string;
    }>;
    career_recommendations: string[];
    learning_style: string;
  };
}

// 그룹 2: 일일 운세 데이터 구조
export interface DailyComprehensiveData {
  date: string; // YYYY-MM-DD
  overall_fortune: {
    score: number; // 1-100
    summary: string;
    key_points: string[];
    energy_level: number;
    mood_forecast: string;
  };
  detailed_fortunes: {
    wealth: {
      score: number;
      description: string;
      investment_advice: string;
      spending_caution: string[];
    };
    love: {
      score: number;
      description: string;
      single_advice: string;
      couple_advice: string;
      meeting_probability: number;
    };
    career: {
      score: number;
      description: string;
      work_focus: string[];
      meeting_luck: string;
      decision_timing: string;
    };
    health: {
      score: number;
      description: string;
      body_care: string[];
      mental_care: string[];
      exercise_recommendation: string;
    };
  };
  lucky_elements: {
    numbers: number[];
    colors: string[];
    foods: string[];
    items: string[];
    directions: string[];
    times: string[];
  };
  hourly_fortune: Array<{
    hour: string;
    fortune_level: number;
    activity_recommendation: string;
  }>;
  biorhythm: {
    physical: number;
    emotional: number;
    intellectual: number;
    intuitive: number;
  };
  zodiac_compatibility: {
    best_matches: string[];
    avoid_signs: string[];
    daily_interaction: string;
  };
  mbti_daily: {
    energy_focus: string;
    decision_style: string;
    social_recommendation: string;
    productivity_tip: string;
  };
}

// 그룹 3: 실시간 상호작용 입력/출력 구조
export interface InteractiveInput {
  type: 'dream' | 'tarot' | 'compatibility' | 'worry';
  data: Record<string, any>;
  user_profile: UserProfile;
}

export interface DreamInterpretationInput {
  dream_content: string;
  dream_date?: string;
  emotions_felt: string[];
  recurring_dream: boolean;
}

export interface TarotInput {
  question: string;
  question_category: 'love' | 'career' | 'health' | 'general';
  spread_type: 'single' | 'three_card' | 'celtic_cross';
}

export interface CompatibilityInput {
  partner_birth_date: string;
  partner_birth_time?: string;
  partner_gender?: string;
  relationship_type: 'romantic' | 'friendship' | 'business';
}

export interface WorryBeadInput {
  worry_content: string;
  worry_category: 'relationship' | 'career' | 'health' | 'money' | 'family' | 'other';
  urgency_level: number; // 1-10
}

// API 응답 타입
export interface FortuneResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  cached: boolean;
  cache_source?: 'redis' | 'database' | 'fresh';
  generated_at: string;
}

// 캐시 관련 타입
export interface CacheMetadata {
  key: string;
  expires_at?: Date;
  group_type: FortuneGroupType;
  last_accessed: Date;
  access_count: number;
}

// 배치 처리 관련 타입
export interface BatchProcessingStatus {
  user_id: string;
  processing_date: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  started_at?: string;
  completed_at?: string;
  error_message?: string;
}

export interface FortuneCategoryGroup {
  category: FortuneCategory;
  group_type: FortuneGroupType;
  description: string;
  expires_hours?: number;
} 
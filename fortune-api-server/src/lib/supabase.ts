import { createClient } from '@supabase/supabase-js';
import logger from '../utils/logger';

// 환경변수 확인
const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error('Missing Supabase environment variables. Please check SUPABASE_URL and SUPABASE_SERVICE_KEY');
}

// Service client - 관리자 권한으로 모든 작업 수행 가능
export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

// Anon client - 일반 사용자 권한으로 RLS 정책 적용
export const supabaseClient = createClient(supabaseUrl, supabaseAnonKey || supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

// 사용자 검증 헬퍼 함수
export async function verifyUser(token: string) {
  try {
    const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
    
    if (error || !user) {
      return null;
    }
    
    return user;
  } catch (error) {
    logger.error('Error verifying user:', error);
    return null;
  }
}

// 타입 정의
export interface UserProfile {
  id: string;
  email?: string;
  name: string;
  avatar_url?: string;
  birth_date?: string;
  birth_time?: string;
  gender?: 'male' | 'female' | 'other';
  mbti?: string;
  blood_type?: 'A' | 'B' | 'AB' | 'O';
  zodiac_sign?: string;
  chinese_zodiac?: string;
  job?: string;
  location?: string;
  subscription_status?: 'free' | 'premium' | 'enterprise';
  fortune_count?: number;
  favorite_fortune_types?: string[];
  onboarding_completed?: boolean;
  privacy_settings?: any;
  created_at?: string;
  updated_at?: string;
}

export interface FortuneCompletion {
  id?: string;
  user_id: string;
  fortune_type: string;
  started_at: string;
  completed_at?: string;
  duration_seconds?: number;
  user_satisfaction?: number;
  feedback?: string;
  created_date?: string;
  created_at?: string;
  updated_at?: string;
}

export interface TokenBalance {
  id?: string;
  user_id: string;
  balance: number;
  total_earned: number;
  total_spent: number;
  last_free_tokens_date?: string;
  created_at?: string;
  updated_at?: string;
}

export interface TokenTransaction {
  id?: string;
  user_id: string;
  amount: number;
  type: 'earned' | 'spent' | 'purchased' | 'refunded';
  description: string;
  fortune_type?: string;
  reference_id?: string;
  balance_after: number;
  created_at?: string;
}

logger.info('Supabase clients initialized successfully');
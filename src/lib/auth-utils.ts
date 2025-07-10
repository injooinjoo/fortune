/**
 * 인증 관련 유틸리티 함수
 */

import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';

/**
 * 현재 로그인된 사용자 정보 가져오기
 */
export async function getCurrentUser() {
  try {
    const { data: { user }, error } = await supabase.auth.getUser();
    
    if (error || !user) {
      return null;
    }
    
    return user;
  } catch (error) {
    logger.error('Failed to get current user:', error);
    return null;
  }
}

/**
 * 사용자가 로그인 되어있는지 확인
 */
export async function isAuthenticated() {
  const user = await getCurrentUser();
  return !!user;
}

/**
 * 사용자 로그아웃
 */
export async function signOut() {
  try {
    const { error } = await supabase.auth.signOut();
    
    if (error) {
      logger.error('Failed to sign out:', error);
      return false;
    }
    
    return true;
  } catch (error) {
    logger.error('Sign out error:', error);
    return false;
  }
}

/**
 * 현재 세션의 액세스 토큰 가져오기
 */
export async function getAuthToken() {
  try {
    const { data: { session }, error } = await supabase.auth.getSession();
    
    if (error || !session) {
      return null;
    }
    
    return session.access_token;
  } catch (error) {
    logger.error('Failed to get auth token:', error);
    return null;
  }
}

/**
 * 사용자 세션 갱신
 */
export async function refreshSession() {
  const supabase = createClient();
  
  try {
    const { data: { session }, error } = await supabase.auth.refreshSession();
    
    if (error || !session) {
      return null;
    }
    
    return session;
  } catch (error) {
    logger.error('Failed to refresh session:', error);
    return null;
  }
}

/**
 * 사용자 프로필 가져오기
 */
export async function getUserProfile(userId: string) {
  const supabase = createClient();
  
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();
      
    if (error || !data) {
      return null;
    }
    
    return data;
  } catch (error) {
    logger.error('Failed to get user profile:', error);
    return null;
  }
}
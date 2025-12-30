import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger.dart';

/// Supabase 데이터베이스 작업을 위한 헬퍼 클래스
class SupabaseHelper {
  static final _client = Supabase.instance.client;
  
  /// user_profiles 테이블에서 사용자 프로필을 안전하게 조회
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
          
      return response;
    } on PostgrestException catch (e) {
      if (e.code == '406') {
        Logger.error('Error: Check RLS policies for user_profiles table', e);
        
        // 406 에러 시 rpc 함수를 통해 조회 시도
        try {
          final rpcResponse = await _client.rpc(
            'get_user_profile',
            params: {'p_id': userId}).maybeSingle();
          
          return rpcResponse;
        } catch (rpcError) {
          Logger.error('RPC fallback failed', rpcError);
          return null;
        }
      }
      
      Logger.error('Failed to get user profile', e);
      return null;
    } catch (e) {
      Logger.error('Unexpected error getting user profile', e);
      return null;
    }
  }
  
  /// user_profiles 테이블에 새 프로필 생성
  static Future<Map<String, dynamic>?> createUserProfile({
    required String userId,
    String? email,
    String? name,
    String? profileImageUrl,
    int tokenBalance = 100}) async {
    try {
      final profile = {
        'id': userId,
        'email': email ?? 'unknown@example.com',
        'name': name,
        'profile_image_url': profileImageUrl,
        'token_balance': tokenBalance,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': null};
      
      final response = await _client
          .from('user_profiles')
          .insert(profile)
          .select()
          .single();
          
      return response;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST301') {
        Logger.error('Profile already exists for user $userId', e);
      } else {
        Logger.error('Failed to create user profile', e);
      }
      return null;
    } catch (e) {
      Logger.error('Unexpected error creating user profile', e);
      return null;
    }
  }
  
  /// 프로필이 없으면 생성, 있으면 조회 (소셜 로그인 시 프로필 이미지 업데이트)
  static Future<Map<String, dynamic>?> ensureUserProfile({
    required String userId,
    String? email,
    String? name,
    String? profileImageUrl}) async {
    // 먼저 프로필 조회 시도
    var profile = await getUserProfile(userId);

    // 프로필이 없으면 생성
    if (profile == null) {
      Logger.info('Creating new user profile for $userId');
      profile = await createUserProfile(
        userId: userId,
        email: email,
        name: name,
        profileImageUrl: profileImageUrl);
    } else {
      // 프로필이 있지만 소셜 로그인 이미지가 제공되었으면 업데이트
      final existingImageUrl = profile['profile_image_url'] as String?;
      if (profileImageUrl != null &&
          profileImageUrl.isNotEmpty &&
          existingImageUrl != profileImageUrl) {
        Logger.info('Updating profile image from social login');
        profile = await updateUserProfile(
          userId: userId,
          updates: {'profile_image_url': profileImageUrl},
        ) ?? profile;
      }
    }

    return profile;
  }
  
  /// user_profiles 테이블 업데이트
  static Future<Map<String, dynamic>?> updateUserProfile({
    required String userId,
    Map<String, dynamic>? updates}) async {
    if (updates == null || updates.isEmpty) {
      Logger.warning('No updates provided for user profile');
      return null;
    }
    
    // Add updated_at timestamp
    final updateData = {
      ...updates,
      'updated_at': null};
    
    try {
      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();
          
      Logger.info('User profile updated successfully');
      return response;
    } on PostgrestException catch (e) {
      Logger.error('Failed to update user profile', e);
      
      // Try RPC function as fallback
      if (e.code == '406') {
        try {
          final rpcResponse = await _client.rpc(
            'update_user_profile',
            params: {
              'p_id': userId,
              'p_updates': null}).single();
          
          return rpcResponse;
        } catch (rpcError) {
          Logger.error('RPC update fallback failed', rpcError);
        }
      }
      
      return null;
    } catch (e) {
      Logger.error('Unexpected error updating user profile', e);
      return null;
    }
  }
}

// SQL 함수를 생성하는 스크립트 (Supabase SQL 에디터에서 실행)
const createRpcFunctionSQL = r'''
-- RPC function to get user profile (bypasses RLS issues)
CREATE OR REPLACE FUNCTION get_user_profile(p_id UUID);
RETURNS TABLE (
  id UUID,
  email TEXT,
  name TEXT,
  phone_number TEXT,
  birth_date DATE,
  gender TEXT,
  mbti_type TEXT,
  zodiac_sign TEXT,
  profile_image_url TEXT,
  preferences JSONB,
  token_balance INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only allow users to get their own profile
  IF p_id != auth.uid() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  
  RETURN QUERY
  SELECT 
    up.id,
    up.email,
    up.name,
    up.phone_number,
    up.birth_date,
    up.gender,
    up.mbti_type,
    up.zodiac_sign,
    up.profile_image_url,
    up.preferences,
    up.token_balance,
    up.created_at,
    up.updated_at
  FROM public.user_profiles up
  WHERE up.id = p_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_profile(UUID) TO authenticated;
''';
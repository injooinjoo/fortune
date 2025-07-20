# 🔐 사용자 프로필 및 인증 문제 해결 종합 가이드

> **최종 업데이트**: 2025년 7월 15일  
> **대상**: Supabase Auth + PostgreSQL RLS

## 📋 개요

Fortune 앱에서 발생할 수 있는 사용자 프로필 및 인증 관련 문제들과 해결 방법을 종합적으로 정리한 가이드입니다.

---

## 🚨 주요 문제 및 해결 방법

### 1. 프로필 생성 실패 문제

#### 증상
- 회원가입 후 user_profiles 테이블에 프로필이 생성되지 않음
- "프로필을 찾을 수 없습니다" 에러 발생
- 로그인은 되지만 앱 기능 사용 불가

#### 원인
- RLS(Row Level Security) 정책 문제
- 트리거 함수 권한 부족
- auth.users와 user_profiles 동기화 실패

#### 해결 방법

**Step 1: RLS 정책 수정**
```sql
-- 기존 정책 삭제
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;

-- 새로운 정책 생성
CREATE POLICY "Enable read access for users" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Enable insert for users" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Enable update for users" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- 서비스 역할 정책 (트리거용)
CREATE POLICY "Service role full access" ON user_profiles
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');
```

**Step 2: 트리거 함수 수정**
```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.user_profiles (
        id,
        email,
        username,
        avatar_url,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'username', NEW.email),
        NEW.raw_user_meta_data->>'avatar_url',
        NOW(),
        NOW()
    );
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Step 3: 기존 사용자 프로필 복구**
```sql
-- auth.users에는 있지만 user_profiles에 없는 사용자 찾기
INSERT INTO public.user_profiles (id, email, username, created_at, updated_at)
SELECT 
    au.id,
    au.email,
    COALESCE(au.raw_user_meta_data->>'username', au.email),
    au.created_at,
    NOW()
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE up.id IS NULL;
```

---

### 2. Google OAuth 로그인 프로필 문제

#### 증상
- Google 로그인 성공 후 프로필 조회 실패
- 403 Forbidden 에러
- 소셜 계정 정보가 저장되지 않음

#### 원인
- OAuth 메타데이터 처리 문제
- 소셜 계정 연결 테이블 누락
- 프로필 생성 타이밍 이슈

#### 해결 방법

**Step 1: OAuth 프로필 처리 개선**
```sql
-- OAuth 사용자를 위한 향상된 트리거
CREATE OR REPLACE FUNCTION handle_auth_user_created()
RETURNS trigger AS $$
DECLARE
    provider_value text;
    full_name_value text;
    avatar_url_value text;
    username_value text;
BEGIN
    -- OAuth 제공자 정보 추출
    provider_value := NEW.raw_app_meta_data->>'provider';
    
    -- 사용자 정보 추출
    IF provider_value = 'google' THEN
        full_name_value := NEW.raw_user_meta_data->>'full_name';
        avatar_url_value := NEW.raw_user_meta_data->>'avatar_url';
        username_value := COALESCE(
            NEW.raw_user_meta_data->>'name',
            split_part(NEW.email, '@', 1)
        );
    ELSE
        full_name_value := NEW.raw_user_meta_data->>'full_name';
        avatar_url_value := NEW.raw_user_meta_data->>'avatar_url';
        username_value := COALESCE(
            NEW.raw_user_meta_data->>'username',
            split_part(NEW.email, '@', 1)
        );
    END IF;
    
    -- 프로필 생성
    INSERT INTO public.user_profiles (
        id,
        email,
        username,
        full_name,
        avatar_url,
        provider,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        NEW.email,
        username_value,
        full_name_value,
        avatar_url_value,
        provider_value,
        NOW(),
        NOW()
    ) ON CONFLICT (id) DO UPDATE SET
        provider = EXCLUDED.provider,
        avatar_url = COALESCE(EXCLUDED.avatar_url, user_profiles.avatar_url),
        full_name = COALESCE(EXCLUDED.full_name, user_profiles.full_name),
        updated_at = NOW();
    
    -- 소셜 계정 연결 정보 저장
    IF provider_value IN ('google', 'apple', 'facebook') THEN
        INSERT INTO public.user_social_accounts (
            user_id,
            provider,
            provider_user_id,
            provider_email,
            connected_at
        ) VALUES (
            NEW.id,
            provider_value,
            NEW.raw_user_meta_data->>'provider_id',
            NEW.email,
            NOW()
        ) ON CONFLICT (user_id, provider) DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Step 2: Flutter 클라이언트 수정**
```dart
class AuthService {
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Supabase 인증
      final response = await _supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (response.user == null) {
        throw Exception('로그인 실패');
      }
      
      // 프로필 생성 대기 (최대 3초)
      UserProfile? profile;
      for (int i = 0; i < 6; i++) {
        await Future.delayed(Duration(milliseconds: 500));
        profile = await getUserProfile(response.user!.id);
        if (profile != null) break;
      }
      
      if (profile == null) {
        // 수동으로 프로필 생성 시도
        profile = await createProfileManually(response.user!);
      }
      
      return profile;
    } catch (e) {
      print('Google 로그인 에러: $e');
      rethrow;
    }
  }
  
  Future<UserProfile> createProfileManually(User user) async {
    final profile = UserProfile(
      id: user.id,
      email: user.email!,
      username: user.userMetadata?['name'] ?? user.email!.split('@')[0],
      avatarUrl: user.userMetadata?['avatar_url'],
      provider: 'google',
    );
    
    await _supabase.from('user_profiles').insert(profile.toJson());
    return profile;
  }
}
```

---

### 3. Row Level Security (RLS) 권한 문제

#### 증상
- 자신의 프로필도 조회할 수 없음
- UPDATE/DELETE 작업 실패
- "new row violates row-level security policy" 에러

#### 원인
- RLS 정책이 너무 제한적
- JWT 토큰 검증 문제
- auth.uid() 함수 오작동

#### 해결 방법

**Step 1: RLS 디버깅**
```sql
-- RLS 정책 테스트
SELECT * FROM user_profiles WHERE id = auth.uid();

-- 현재 사용자 ID 확인
SELECT auth.uid();

-- JWT 토큰 정보 확인
SELECT current_setting('request.jwt.claims', true)::json;

-- RLS 우회하여 데이터 확인 (관리자용)
SET LOCAL row_level_security = OFF;
SELECT * FROM user_profiles;
RESET row_level_security;
```

**Step 2: 포괄적인 RLS 정책 설정**
```sql
-- 모든 기존 정책 제거
DROP POLICY IF EXISTS ALL ON user_profiles;

-- 읽기 정책 (자신의 프로필 + 공개 정보)
CREATE POLICY "users_read_own_profile" ON user_profiles
    FOR SELECT USING (
        auth.uid() = id 
        OR 
        is_public = true
    );

-- 생성 정책
CREATE POLICY "users_create_own_profile" ON user_profiles
    FOR INSERT WITH CHECK (
        auth.uid() = id
    );

-- 수정 정책
CREATE POLICY "users_update_own_profile" ON user_profiles
    FOR UPDATE USING (
        auth.uid() = id
    ) WITH CHECK (
        auth.uid() = id
    );

-- 삭제 정책 (선택적)
CREATE POLICY "users_delete_own_profile" ON user_profiles
    FOR DELETE USING (
        auth.uid() = id
    );

-- 익명 사용자를 위한 읽기 전용 정책
CREATE POLICY "anon_read_public_profiles" ON user_profiles
    FOR SELECT USING (
        is_public = true 
        AND 
        auth.role() = 'anon'
    );
```

---

### 4. 프로필 조회 성능 문제

#### 증상
- 프로필 로딩 시간이 긴 경우
- 타임아웃 에러
- 불필요한 다중 쿼리

#### 해결 방법

**Step 1: 인덱스 추가**
```sql
-- 자주 사용되는 컬럼에 인덱스 추가
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_profiles_created_at ON user_profiles(created_at DESC);

-- 복합 인덱스 (provider + created_at)
CREATE INDEX idx_user_profiles_provider_created 
    ON user_profiles(provider, created_at DESC);
```

**Step 2: 최적화된 쿼리**
```dart
// Flutter에서 최적화된 프로필 조회
Future<UserProfile?> getOptimizedProfile(String userId) async {
  try {
    // 필요한 필드만 선택
    final response = await supabase
        .from('user_profiles')
        .select('id, email, username, avatar_url, tokens, created_at')
        .eq('id', userId)
        .single();
    
    return UserProfile.fromJson(response);
  } catch (e) {
    // 캐시에서 조회
    return getCachedProfile(userId);
  }
}

// 프로필 캐싱
class ProfileCache {
  static final _cache = <String, UserProfile>{};
  static final _cacheTime = <String, DateTime>{};
  static const _cacheValid = Duration(minutes: 5);
  
  static void set(String userId, UserProfile profile) {
    _cache[userId] = profile;
    _cacheTime[userId] = DateTime.now();
  }
  
  static UserProfile? get(String userId) {
    final cached = _cache[userId];
    final cachedTime = _cacheTime[userId];
    
    if (cached != null && cachedTime != null) {
      if (DateTime.now().difference(cachedTime) < _cacheValid) {
        return cached;
      }
    }
    return null;
  }
}
```

---

## 🛠️ 문제 예방 체크리스트

### 데이터베이스 설정
- [ ] user_profiles 테이블에 RLS 활성화
- [ ] 모든 필요한 RLS 정책 생성
- [ ] 트리거 함수 SECURITY DEFINER 설정
- [ ] 인덱스 최적화

### 인증 설정
- [ ] OAuth 리디렉션 URL 설정
- [ ] 소셜 로그인 제공자 활성화
- [ ] 메타데이터 매핑 확인

### Flutter 앱
- [ ] 에러 핸들링 구현
- [ ] 프로필 캐싱 구현
- [ ] 재시도 로직 추가
- [ ] 오프라인 지원

### 모니터링
- [ ] 프로필 생성 실패 로그
- [ ] RLS 정책 위반 추적
- [ ] 성능 메트릭 수집

---

## 📊 디버깅 SQL 쿼리

```sql
-- 프로필 상태 확인
SELECT 
    au.id,
    au.email,
    au.created_at as auth_created,
    up.id as profile_id,
    up.created_at as profile_created,
    au.raw_app_meta_data->>'provider' as provider
FROM auth.users au
LEFT JOIN user_profiles up ON au.id = up.id
ORDER BY au.created_at DESC;

-- RLS 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- 트리거 상태 확인
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth';
```

---

## 🚀 빠른 수정 스크립트

전체 시스템을 한 번에 수정하는 스크립트:

```bash
#!/bin/bash
# fix_user_profiles.sh

echo "🔧 사용자 프로필 시스템 수정 시작..."

# SQL 파일 생성
cat > fix_profiles.sql << 'EOF'
-- 1. RLS 정책 재설정
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ALL ON user_profiles;

CREATE POLICY "Enable all access for users" ON user_profiles
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Service role bypass" ON user_profiles
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- 2. 트리거 함수 수정
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, username, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        NOW(),
        NOW()
    ) ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. 누락된 프로필 생성
INSERT INTO user_profiles (id, email, username, created_at, updated_at)
SELECT 
    id,
    email,
    split_part(email, '@', 1),
    created_at,
    NOW()
FROM auth.users
WHERE id NOT IN (SELECT id FROM user_profiles);

-- 4. 인덱스 최적화
CREATE INDEX IF NOT EXISTS idx_profiles_email ON user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_created ON user_profiles(created_at DESC);

ANALYZE user_profiles;
EOF

# Supabase CLI로 실행
supabase db push < fix_profiles.sql

echo "✅ 수정 완료!"
```

---

*이 가이드는 Fortune 앱의 사용자 프로필 및 인증 문제 해결을 위한 종합 가이드입니다.*
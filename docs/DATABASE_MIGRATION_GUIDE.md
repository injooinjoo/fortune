# Supabase 데이터베이스 마이그레이션 가이드

> Flutter 마이그레이션을 위한 데이터베이스 스키마 및 RLS 정책 문서
> 작성일: 2025년 1월 8일

## 📑 목차
1. [개요](#개요)
2. [데이터베이스 스키마](#데이터베이스-스키마)
3. [RLS 정책](#rls-정책)
4. [데이터 마이그레이션 전략](#데이터-마이그레이션-전략)
5. [Flutter 통합 가이드](#flutter-통합-가이드)

---

## 개요

Fortune 앱은 Supabase를 백엔드로 사용하며, PostgreSQL 데이터베이스와 Row Level Security(RLS)를 통해 데이터를 관리합니다.

### 주요 특징
- **인증**: Supabase Auth (Google OAuth)
- **데이터베이스**: PostgreSQL with RLS
- **실시간**: Realtime subscriptions
- **스토리지**: Supabase Storage
- **보안**: Service Role Key for admin operations

---

## 데이터베이스 스키마

### 1. 사용자 관리 테이블

#### `user_profiles`
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  name TEXT,
  nickname TEXT,
  birth_date DATE,
  birth_time TIME,
  is_lunar_calendar BOOLEAN DEFAULT false,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  mbti TEXT,
  blood_type TEXT CHECK (blood_type IN ('A', 'B', 'O', 'AB')),
  profile_image_url TEXT,
  phone_number TEXT,
  
  -- 구독 정보
  subscription_status TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  monthly_token_quota INTEGER DEFAULT 0,
  monthly_tokens_used INTEGER DEFAULT 0,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  last_login_at TIMESTAMP WITH TIME ZONE,
  is_profile_complete BOOLEAN DEFAULT false,
  
  UNIQUE(user_id),
  UNIQUE(email)
);

-- 인덱스
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
```

### 2. 운세 데이터 테이블

#### `daily_fortunes`
```sql
CREATE TABLE daily_fortunes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  fortune_type TEXT NOT NULL,
  fortune_date DATE NOT NULL,
  fortune_data JSONB NOT NULL,
  
  -- 캐싱 정보
  cache_key TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  
  -- AI 생성 정보
  model_used TEXT,
  prompt_tokens INTEGER,
  completion_tokens INTEGER,
  total_tokens INTEGER,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  is_batch_generated BOOLEAN DEFAULT false,
  
  -- 복합 유니크 키 (한 사용자는 하루에 같은 타입의 운세를 하나만)
  UNIQUE(user_id, fortune_type, fortune_date)
);

-- 인덱스
CREATE INDEX idx_daily_fortunes_user_date ON daily_fortunes(user_id, fortune_date);
CREATE INDEX idx_daily_fortunes_type ON daily_fortunes(fortune_type);
CREATE INDEX idx_daily_fortunes_expires ON daily_fortunes(expires_at);
```

#### `fortune_history`
```sql
CREATE TABLE fortune_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  fortune_type TEXT NOT NULL,
  fortune_category TEXT NOT NULL,
  token_cost INTEGER NOT NULL DEFAULT 1,
  
  -- 운세 내용
  title TEXT,
  summary TEXT,
  full_content JSONB,
  
  -- 사용자 피드백
  is_favorite BOOLEAN DEFAULT false,
  satisfaction_rating INTEGER CHECK (satisfaction_rating >= 1 AND satisfaction_rating <= 5),
  user_feedback TEXT,
  
  -- 공유 정보
  share_count INTEGER DEFAULT 0,
  share_id TEXT UNIQUE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 인덱스
CREATE INDEX idx_fortune_history_user_id ON fortune_history(user_id);
CREATE INDEX idx_fortune_history_created_at ON fortune_history(created_at DESC);
```

### 3. 토큰 및 결제 테이블

#### `user_tokens`
```sql
CREATE TABLE user_tokens (
  user_id UUID PRIMARY KEY REFERENCES user_profiles(user_id),
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
  total_purchased INTEGER DEFAULT 0,
  total_used INTEGER DEFAULT 0,
  total_bonus INTEGER DEFAULT 0,
  
  -- 구독 관련
  subscription_tokens_remaining INTEGER DEFAULT 0,
  subscription_reset_date DATE,
  
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

#### `token_transactions`
```sql
CREATE TABLE token_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'usage', 'bonus', 'refund', 'subscription')),
  amount INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  
  -- 관련 정보
  fortune_type TEXT,
  payment_id TEXT,
  description TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 인덱스
CREATE INDEX idx_token_transactions_user_id ON token_transactions(user_id);
CREATE INDEX idx_token_transactions_created_at ON token_transactions(created_at DESC);
```

#### `payment_transactions`
```sql
CREATE TABLE payment_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(user_id),
  
  -- 결제 정보
  payment_provider TEXT NOT NULL CHECK (payment_provider IN ('stripe', 'toss', 'naver')),
  payment_id TEXT NOT NULL,
  payment_method TEXT,
  
  -- 금액 정보
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'KRW',
  
  -- 상품 정보
  product_type TEXT NOT NULL CHECK (product_type IN ('tokens', 'subscription')),
  product_details JSONB,
  tokens_purchased INTEGER,
  
  -- 상태
  status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  
  -- 시간 정보
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  completed_at TIMESTAMP WITH TIME ZONE,
  
  -- Webhook 정보
  webhook_received_at TIMESTAMP WITH TIME ZONE,
  webhook_event_id TEXT,
  
  UNIQUE(payment_provider, payment_id)
);
```

### 4. 구독 관리 테이블

#### `subscription_status`
```sql
CREATE TABLE subscription_status (
  user_id UUID PRIMARY KEY REFERENCES user_profiles(user_id),
  
  -- 구독 정보
  plan_type TEXT NOT NULL CHECK (plan_type IN ('free', 'basic', 'premium', 'enterprise')),
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'expired', 'trial')),
  
  -- Stripe 정보
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  stripe_price_id TEXT,
  
  -- 기간 정보
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  trial_end TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  
  -- 혜택
  monthly_token_quota INTEGER,
  features JSONB DEFAULT '{}',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### 5. 배치 작업 테이블

#### `fortune_batches`
```sql
CREATE TABLE fortune_batches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  batch_date DATE NOT NULL,
  fortune_types TEXT[] NOT NULL,
  
  -- 작업 상태
  status TEXT CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  
  -- 통계
  total_users INTEGER,
  processed_users INTEGER DEFAULT 0,
  failed_users INTEGER DEFAULT 0,
  
  -- 비용
  total_tokens_used INTEGER DEFAULT 0,
  estimated_cost DECIMAL(10, 4),
  
  error_log JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

---

## RLS 정책

### 1. 사용자 프로필 정책

```sql
-- 사용자는 자신의 프로필만 조회 가능
CREATE POLICY "Users can view own profile" 
  ON user_profiles FOR SELECT 
  USING (auth.uid() = user_id);

-- 사용자는 자신의 프로필만 수정 가능
CREATE POLICY "Users can update own profile" 
  ON user_profiles FOR UPDATE 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 신규 사용자는 프로필 생성 가능
CREATE POLICY "Users can insert own profile" 
  ON user_profiles FOR INSERT 
  WITH CHECK (auth.uid() = user_id);
```

### 2. 운세 데이터 정책

```sql
-- 사용자는 자신의 운세만 조회 가능
CREATE POLICY "Users can view own fortunes" 
  ON daily_fortunes FOR SELECT 
  USING (
    user_id IN (
      SELECT id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

-- 시스템만 운세 생성 가능 (Service Role Key 필요)
CREATE POLICY "System can insert fortunes" 
  ON daily_fortunes FOR INSERT 
  WITH CHECK (false);

-- 사용자는 자신의 운세 기록만 조회 가능
CREATE POLICY "Users can view own history" 
  ON fortune_history FOR SELECT 
  USING (
    user_id IN (
      SELECT user_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );
```

### 3. 토큰 및 결제 정책

```sql
-- 사용자는 자신의 토큰 잔액만 조회 가능
CREATE POLICY "Users can view own balance" 
  ON user_tokens FOR SELECT 
  USING (auth.uid() = user_id);

-- 토큰 수정은 시스템만 가능
CREATE POLICY "System can update tokens" 
  ON user_tokens FOR ALL 
  USING (false) 
  WITH CHECK (false);

-- 사용자는 자신의 거래 내역만 조회 가능
CREATE POLICY "Users can view own transactions" 
  ON token_transactions FOR SELECT 
  USING (
    user_id IN (
      SELECT user_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

-- 결제 내역도 본인 것만 조회 가능
CREATE POLICY "Users can view own payments" 
  ON payment_transactions FOR SELECT 
  USING (
    user_id IN (
      SELECT user_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );
```

### 4. 구독 정책

```sql
-- 사용자는 자신의 구독 상태만 조회 가능
CREATE POLICY "Users can view own subscription" 
  ON subscription_status FOR SELECT 
  USING (auth.uid() = user_id);

-- 구독 수정은 시스템만 가능
CREATE POLICY "System can manage subscriptions" 
  ON subscription_status FOR ALL 
  USING (false) 
  WITH CHECK (false);
```

---

## 데이터 마이그레이션 전략

### 1. 스키마 Export

```bash
# Supabase CLI로 스키마 내보내기
supabase db dump -f schema.sql

# 특정 테이블만 내보내기
supabase db dump -f user_profiles.sql --data-only -t user_profiles
```

### 2. RLS 정책 Export

```sql
-- 모든 RLS 정책 조회
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public';
```

### 3. 함수 및 트리거

```sql
-- 업데이트 시간 자동 갱신 함수
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 각 테이블에 트리거 적용
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### 4. 초기 데이터

```sql
-- 신규 사용자에게 100 토큰 지급
CREATE OR REPLACE FUNCTION grant_initial_tokens()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_tokens (user_id, balance, total_bonus)
  VALUES (NEW.user_id, 100, 100);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grant_tokens_on_profile_create
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION grant_initial_tokens();
```

---

## Flutter 통합 가이드

### 1. Supabase Flutter 설정

```dart
// pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
  
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authCallbackUrlHostname: 'login-callback',
  );
  
  runApp(MyApp());
}
```

### 2. 데이터 모델 정의

```dart
// models/user_profile.dart
class UserProfile {
  final String id;
  final String userId;
  final String? name;
  final DateTime? birthDate;
  final String? mbti;
  final String? gender;
  final String subscriptionStatus;
  final int tokenBalance;
  
  UserProfile.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### 3. Repository 패턴

```dart
// repositories/user_repository.dart
class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  Future<UserProfile?> getUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    
    final response = await _client
      .from('user_profiles')
      .select('*, user_tokens(balance)')
      .eq('user_id', userId)
      .single();
      
    return UserProfile.fromJson(response);
  }
  
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    
    await _client
      .from('user_profiles')
      .update(updates)
      .eq('user_id', userId);
  }
}
```

### 4. 실시간 구독

```dart
// 토큰 잔액 실시간 업데이트
final subscription = _client
  .from('user_tokens')
  .stream(primaryKey: ['user_id'])
  .eq('user_id', userId)
  .listen((List<Map<String, dynamic>> data) {
    if (data.isNotEmpty) {
      final balance = data.first['balance'];
      // 상태 업데이트
    }
  });
```

### 5. 오프라인 지원

```dart
// Local database for offline support
import 'package:sqflite/sqflite.dart';

class LocalFortuneCache {
  static const String _dbName = 'fortune_cache.db';
  
  Future<void> cacheFortuneResult(Fortune fortune) async {
    final db = await openDatabase(_dbName);
    await db.insert('cached_fortunes', fortune.toJson());
  }
  
  Future<List<Fortune>> getCachedFortunes() async {
    final db = await openDatabase(_dbName);
    final results = await db.query('cached_fortunes');
    return results.map((r) => Fortune.fromJson(r)).toList();
  }
}
```

### 6. 보안 고려사항

1. **Service Role Key**: 절대 클라이언트에 포함하지 않음
2. **토큰 작업**: 서버 API를 통해서만 수행
3. **민감한 데이터**: 로컬 암호화 저장
4. **네트워크 보안**: Certificate Pinning 적용

---

## 마이그레이션 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] 스키마 import 및 검증
- [ ] RLS 정책 적용
- [ ] Service Role Key 보안 설정
- [ ] Flutter SDK 통합
- [ ] 데이터 모델 생성
- [ ] Repository 구현
- [ ] 오프라인 캐싱 구현
- [ ] 실시간 구독 테스트
- [ ] 성능 최적화

---

이 가이드는 Fortune 앱의 데이터베이스를 Flutter로 안전하고 효율적으로 마이그레이션하기 위한 완전한 참조 문서입니다.
# 🛠️ Fortune 앱 개발자 레퍼런스 가이드

> **최종 업데이트**: 2025년 7월 15일

## 📚 목차
1. [아키텍처 개요](#아키텍처-개요)
2. [운세 타입 추가 가이드](#운세-타입-추가-가이드)
3. [API 엔드포인트 규칙](#api-엔드포인트-규칙)
4. [토큰 비용 구조](#토큰-비용-구조)
5. [캐싱 전략](#캐싱-전략)
6. [성능 최적화](#성능-최적화)
7. [보안 고려사항](#보안-고려사항)
8. [배포 프로세스](#배포-프로세스)

---

## 🏗️ 아키텍처 개요

### 시스템 구성도
```
┌─────────────────────────────────────────────┐
│                Flutter App                   │
│  ┌─────────┬──────────┬─────────────────┐  │
│  │   UI    │  State   │   Services      │  │
│  │ Screens │ Riverpod │ API/Storage     │  │
│  └─────────┴──────────┴─────────────────┘  │
└─────────────────────┬───────────────────────┘
                      │ HTTPS
┌─────────────────────┴───────────────────────┐
│             Supabase Backend                 │
│  ┌─────────┬──────────┬─────────────────┐  │
│  │Database │   Auth   │ Edge Functions  │  │
│  │PostgreSQL│  OAuth  │  TypeScript     │  │
│  └─────────┴──────────┴─────────────────┘  │
└─────────────────────┬───────────────────────┘
                      │ API
┌─────────────────────┴───────────────────────┐
│          External Services                   │
│  ┌─────────┬──────────┬─────────────────┐  │
│  │ OpenAI  │ Weather  │    Other        │  │
│  │   API   │   API    │   Services      │  │
│  └─────────┴──────────┴─────────────────┘  │
└─────────────────────────────────────────────┘
```

### 기술 스택
```yaml
Frontend:
  - Framework: Flutter 3.16+
  - State Management: Riverpod 2.4+
  - UI: Material Design 3
  - Local Storage: SharedPreferences

Backend:
  - Platform: Supabase
  - Database: PostgreSQL 15
  - Serverless: Edge Functions (Deno)
  - Auth: Supabase Auth + OAuth

External:
  - AI: OpenAI GPT-4
  - Analytics: Google Analytics
```

---

## 🎯 운세 타입 추가 가이드

### 1. 운세 타입 정의

**파일**: `/fortune_flutter/lib/core/constants/fortune_type_names.dart`

```dart
// 1. fortune_type_names.dart에 추가
static const Map<String, String> names = {
  // 기존 운세들...
  'new-fortune': '새로운 운세',  // 추가
};

// 2. 카테고리 분류 로직 업데이트
static String getCategory(String fortuneType) {
  if (fortuneType == 'new-fortune') {
    return '특별 운세';
  }
  // 기존 로직...
}
```

### 2. API 엔드포인트 추가

**파일**: `/supabase/functions/fortune-new/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from '@supabase/supabase-js'
import { generateFortune } from '../_shared/openai.ts'
import { validateRequest } from '../_shared/validation.ts'
import { rateLimiter } from '../_shared/rate-limit.ts'

serve(async (req) => {
  try {
    // 1. 요청 검증
    const { userId, params } = await validateRequest(req)
    
    // 2. Rate Limiting
    await rateLimiter.check(userId)
    
    // 3. 파라미터 검증
    const { birthDate, specificParam } = params
    if (!birthDate || !specificParam) {
      throw new Error('Missing required parameters')
    }
    
    // 4. 운세 생성
    const fortune = await generateFortune({
      type: 'new-fortune',
      birthDate,
      specificParam,
      prompt: `Generate a fortune for...`
    })
    
    // 5. 데이터베이스 저장
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    await supabase.from('fortunes').insert({
      user_id: userId,
      type: 'new-fortune',
      content: fortune,
      tokens_used: fortune.tokensUsed
    })
    
    // 6. 응답
    return new Response(JSON.stringify({
      fortune,
      tokensUsed: fortune.tokensUsed
    }), {
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
```

### 3. Flutter 서비스 추가

**파일**: `/fortune_flutter/lib/services/fortune_service.dart`

```dart
class FortuneService {
  // 기존 메서드들...
  
  Future<FortuneResult> getNewFortune({
    required String userId,
    required DateTime birthDate,
    required String specificParam,
  }) async {
    try {
      // 1. 캐시 확인
      final cached = await _cache.get('new-fortune-$userId');
      if (cached != null && !_isExpired(cached)) {
        return FortuneResult.fromCache(cached);
      }
      
      // 2. API 호출
      final response = await _supabase.functions.invoke(
        'fortune-new',
        body: {
          'userId': userId,
          'birthDate': birthDate.toIso8601String(),
          'specificParam': specificParam,
        },
      );
      
      // 3. 응답 처리
      if (response.status != 200) {
        throw FortuneException('Error: ${response.data}');
      }
      
      final result = FortuneResult.fromJson(response.data);
      
      // 4. 캐시 저장
      await _cache.set(
        'new-fortune-$userId',
        result.toJson(),
        duration: Duration(hours: 24),
      );
      
      // 5. 토큰 차감
      await _tokenService.deduct(result.tokensUsed);
      
      return result;
      
    } catch (e) {
      throw FortuneException('운세 조회 실패: ${e.toString()}');
    }
  }
}
```

### 4. UI 페이지 추가

**파일**: `/fortune_flutter/lib/features/fortune/presentation/pages/new_fortune_page.dart`

```dart
class NewFortunePage extends ConsumerStatefulWidget {
  const NewFortunePage({Key? key}) : super(key: key);

  @override
  ConsumerState<NewFortunePage> createState() => _NewFortunePageState();
}

class _NewFortunePageState extends ConsumerState<NewFortunePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  String _specificParam = '';
  
  @override
  Widget build(BuildContext context) {
    final fortuneAsync = ref.watch(newFortuneProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(FortuneTypeNames.getName('new-fortune')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // 운세 설명 카드
            FortuneExplanationCard(
              fortuneType: 'new-fortune',
            ),
            
            SizedBox(height: 16),
            
            // 입력 폼
            DatePickerField(
              label: '생년월일',
              onChanged: (date) => _birthDate = date,
            ),
            
            SizedBox(height: 16),
            
            TextFormField(
              decoration: InputDecoration(
                labelText: '특별 파라미터',
                hintText: '입력해주세요',
              ),
              onChanged: (value) => _specificParam = value,
              validator: (value) =>
                  value?.isEmpty ?? true ? '필수 입력 항목입니다' : null,
            ),
            
            SizedBox(height: 24),
            
            // 운세 보기 버튼
            ElevatedButton(
              onPressed: _getFortune,
              child: Text('운세 보기 (30 토큰)'),
            ),
            
            SizedBox(height: 24),
            
            // 결과 표시
            fortuneAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorWidget(error.toString()),
              data: (fortune) => fortune != null
                  ? FortuneResultCard(fortune: fortune)
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _getFortune() {
    if (_formKey.currentState!.validate() && _birthDate != null) {
      ref.read(newFortuneProvider.notifier).getFortune(
        birthDate: _birthDate!,
        specificParam: _specificParam,
      );
    }
  }
}
```

---

## 🔌 API 엔드포인트 규칙

### 명명 규칙
```
/fortune-{type}
/fortune-{type}-{subtype}
/fortune-batch
/fortune-system
```

### 요청/응답 형식

#### 기본 요청 구조
```json
{
  "userId": "string",
  "birthDate": "ISO 8601 date string",
  "birthTime": "HH:MM (optional)",
  "gender": "male|female (optional)",
  "isLunar": false,
  "additionalParams": {
    // 운세별 추가 파라미터
  }
}
```

#### 기본 응답 구조
```json
{
  "success": true,
  "data": {
    "fortune": {
      "type": "string",
      "content": "string",
      "score": 0-100,
      "details": {},
      "luckyItems": {},
      "advice": []
    },
    "tokensUsed": 30,
    "generatedAt": "ISO 8601 timestamp",
    "expiresAt": "ISO 8601 timestamp"
  },
  "error": null
}
```

#### 에러 응답
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {}
  }
}
```

### HTTP 상태 코드
- `200 OK`: 성공
- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `403 Forbidden`: 권한 없음 (토큰 부족 등)
- `429 Too Many Requests`: Rate Limit 초과
- `500 Internal Server Error`: 서버 오류

---

## 💰 토큰 비용 구조

### 운세별 토큰 비용
```typescript
export const TOKEN_COSTS = {
  // 시간별 운세
  'daily': 20,
  'today': 20,
  'tomorrow': 20,
  'hourly': 15,
  'weekly': 30,
  'monthly': 40,
  'yearly': 50,
  
  // 전통 운세
  'saju': 100,
  'traditional-saju': 80,
  'saju-psychology': 90,
  'tojeong': 60,
  'palmistry': 40,
  'physiognomy': 50,
  
  // 성격/캐릭터
  'mbti': 30,
  'personality': 35,
  'blood-type': 20,
  'zodiac': 25,
  'zodiac-animal': 25,
  
  // 연애/인연
  'love': 40,
  'marriage': 50,
  'compatibility': 60,
  'chemistry': 45,
  
  // 직업/사업
  'career': 40,
  'business': 50,
  'employment': 35,
  'startup': 45,
  
  // 재물/투자
  'wealth': 40,
  'lucky-investment': 50,
  'lucky-stock': 45,
  'lucky-crypto': 45,
  'lucky-lottery': 30,
} as const;
```

### 패키지 할인율
```typescript
export const PACKAGE_DISCOUNTS = {
  'weekly': 0.30,    // 30% 할인
  'monthly': 0.50,   // 50% 할인
  'yearly': 0.70,    // 70% 할인
  'batch-small': 0.20,  // 20% 할인 (3-5개)
  'batch-medium': 0.35, // 35% 할인 (6-10개)
  'batch-large': 0.50,  // 50% 할인 (11개 이상)
};
```

### 토큰 계산 로직
```typescript
function calculateTokenCost(
  fortuneTypes: string[],
  packageType?: string
): number {
  // 기본 비용 계산
  const baseCost = fortuneTypes.reduce(
    (sum, type) => sum + (TOKEN_COSTS[type] || 50),
    0
  );
  
  // 패키지 할인 적용
  if (packageType && PACKAGE_DISCOUNTS[packageType]) {
    return Math.floor(baseCost * (1 - PACKAGE_DISCOUNTS[packageType]));
  }
  
  // 배치 할인 적용
  const count = fortuneTypes.length;
  if (count >= 11) {
    return Math.floor(baseCost * (1 - PACKAGE_DISCOUNTS['batch-large']));
  } else if (count >= 6) {
    return Math.floor(baseCost * (1 - PACKAGE_DISCOUNTS['batch-medium']));
  } else if (count >= 3) {
    return Math.floor(baseCost * (1 - PACKAGE_DISCOUNTS['batch-small']));
  }
  
  return baseCost;
}
```

---

## 🚀 캐싱 전략

### 캐시 레벨
```
┌─────────────────────────────────┐
│      Client Cache (Flutter)      │
│  - SharedPreferences            │
│  - 24시간 TTL                   │
└────────────────┬────────────────┘
                 │
┌────────────────┴────────────────┐
│      CDN Cache (CloudFlare)     │
│  - 정적 자산 캐싱               │
│  - 1주일 TTL                    │
└────────────────┬────────────────┘
                 │
┌────────────────┴────────────────┐
│    Database Cache (PostgreSQL)   │
│  - 운세 결과 캐싱               │
│  - 유저별 캐싱                  │
└─────────────────────────────────┘
```

### Flutter 캐싱 구현
```dart
class FortuneCache {
  static const String _prefix = 'fortune_cache_';
  final SharedPreferences _prefs;
  
  // 캐시 키 생성
  String _getCacheKey(String fortuneType, String userId) {
    final date = DateTime.now().toIso8601String().split('T')[0];
    return '$_prefix${fortuneType}_${userId}_$date';
  }
  
  // 캐시 저장
  Future<void> set(String key, Map<String, dynamic> data) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': Duration(hours: 24).inMilliseconds,
    };
    await _prefs.setString(key, jsonEncode(cacheData));
  }
  
  // 캐시 조회
  Future<Map<String, dynamic>?> get(String key) async {
    final cached = _prefs.getString(key);
    if (cached == null) return null;
    
    final cacheData = jsonDecode(cached);
    final timestamp = cacheData['timestamp'] as int;
    final ttl = cacheData['ttl'] as int;
    
    // TTL 체크
    if (DateTime.now().millisecondsSinceEpoch - timestamp > ttl) {
      await _prefs.remove(key);
      return null;
    }
    
    return cacheData['data'] as Map<String, dynamic>;
  }
  
  // 캐시 무효화
  Future<void> invalidate(String pattern) async {
    final keys = _prefs.getKeys()
        .where((key) => key.startsWith(_prefix) && key.contains(pattern));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
```

### Supabase 캐싱 테이블
```sql
-- 운세 캐시 테이블
CREATE TABLE fortune_cache (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  fortune_type VARCHAR(50) NOT NULL,
  cache_key VARCHAR(255) UNIQUE NOT NULL,
  content JSONB NOT NULL,
  tokens_used INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  
  INDEX idx_cache_key (cache_key),
  INDEX idx_expires_at (expires_at)
);

-- 만료된 캐시 자동 삭제 함수
CREATE OR REPLACE FUNCTION delete_expired_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM fortune_cache
  WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- 매일 실행되는 크론 작업
SELECT cron.schedule(
  'delete-expired-cache',
  '0 2 * * *',  -- 매일 새벽 2시
  'SELECT delete_expired_cache();'
);
```

---

## ⚡ 성능 최적화

### 1. 데이터베이스 최적화
```sql
-- 인덱스 생성
CREATE INDEX idx_fortunes_user_type ON fortunes(user_id, type);
CREATE INDEX idx_fortunes_created_at ON fortunes(created_at DESC);
CREATE INDEX idx_user_tokens_user_id ON user_tokens(user_id);

-- 파티셔닝 (월별)
CREATE TABLE fortunes_2025_01 PARTITION OF fortunes
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### 2. API 응답 최적화
```typescript
// 병렬 처리
async function getBatchFortunes(types: string[], userId: string) {
  const promises = types.map(type => 
    generateFortune({ type, userId })
  );
  
  // 동시 실행
  const results = await Promise.allSettled(promises);
  
  return results.map((result, index) => ({
    type: types[index],
    success: result.status === 'fulfilled',
    data: result.status === 'fulfilled' ? result.value : null,
    error: result.status === 'rejected' ? result.reason : null,
  }));
}

// 스트리밍 응답
export async function streamFortune(req: Request) {
  const stream = new TransformStream();
  const writer = stream.writable.getWriter();
  
  // 청크 단위로 전송
  for await (const chunk of generateFortuneStream(req)) {
    await writer.write(
      new TextEncoder().encode(JSON.stringify(chunk) + '\n')
    );
  }
  
  await writer.close();
  
  return new Response(stream.readable, {
    headers: {
      'Content-Type': 'application/x-ndjson',
      'Transfer-Encoding': 'chunked',
    },
  });
}
```

### 3. Flutter 최적화
```dart
// 이미지 레이지 로딩
class OptimizedFortuneImage extends StatelessWidget {
  final String imageUrl;
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: 200,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      cacheManager: DefaultCacheManager(),
      maxHeightDiskCache: 400,
      memCacheHeight: 200,
    );
  }
}

// 리스트 가상화
class FortuneListView extends StatelessWidget {
  final List<Fortune> fortunes;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fortunes.length,
      itemExtent: 120,  // 고정 높이로 성능 향상
      cacheExtent: 500,  // 캐시 범위 설정
      itemBuilder: (context, index) {
        return FortuneListItem(fortune: fortunes[index]);
      },
    );
  }
}
```

---

## 🔒 보안 고려사항

### 1. API 보안
```typescript
// Rate Limiting
export class RateLimiter {
  private attempts = new Map<string, number[]>();
  
  async check(userId: string, limit = 100, window = 3600000) {
    const now = Date.now();
    const userAttempts = this.attempts.get(userId) || [];
    
    // 시간 윈도우 내의 요청만 필터링
    const recentAttempts = userAttempts.filter(
      time => now - time < window
    );
    
    if (recentAttempts.length >= limit) {
      throw new Error('Rate limit exceeded');
    }
    
    recentAttempts.push(now);
    this.attempts.set(userId, recentAttempts);
  }
}

// 입력 검증
export function validateFortuneRequest(params: any) {
  const schema = z.object({
    userId: z.string().uuid(),
    birthDate: z.string().datetime(),
    fortuneType: z.enum(FORTUNE_TYPES),
    additionalParams: z.record(z.any()).optional(),
  });
  
  return schema.parse(params);
}
```

### 2. 데이터 보안
```sql
-- Row Level Security
ALTER TABLE fortunes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own fortunes"
ON fortunes FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own fortunes"
ON fortunes FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 민감 정보 암호화
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE user_sensitive_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  encrypted_data TEXT,  -- pgp_sym_encrypt로 암호화
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3. Flutter 보안
```dart
// 안전한 저장소 사용
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}

// 인증서 고정 (Certificate Pinning)
class SecureHttpClient {
  static final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) {
      final SHA256 sha256 = SHA256();
      final digest = sha256.convert(cert.der);
      return PINNED_CERTIFICATES.contains(digest.toString());
    };
}
```

---

## 🚀 배포 프로세스

### 1. 환경별 설정
```yaml
# development
development:
  supabase_url: https://dev.supabase.co
  openai_api_key: ${DEV_OPENAI_KEY}
  log_level: debug
  cache_ttl: 300  # 5분

# staging
staging:
  supabase_url: https://staging.supabase.co
  openai_api_key: ${STAGING_OPENAI_KEY}
  log_level: info
  cache_ttl: 3600  # 1시간

# production
production:
  supabase_url: https://prod.supabase.co
  openai_api_key: ${PROD_OPENAI_KEY}
  log_level: error
  cache_ttl: 86400  # 24시간
```

### 2. CI/CD 파이프라인
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test
      
  deploy-functions:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: supabase/setup-cli@v1
      - run: supabase functions deploy
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          
  deploy-app:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build appbundle
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: com.fortune.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
```

### 3. 배포 체크리스트
- [ ] 모든 테스트 통과 확인
- [ ] 환경 변수 설정 확인
- [ ] 데이터베이스 마이그레이션 실행
- [ ] API 버전 호환성 확인
- [ ] 캐시 무효화 실행
- [ ] 모니터링 대시보드 확인
- [ ] 롤백 계획 준비

---

## 📊 모니터링

### 주요 메트릭
```typescript
// 모니터링할 메트릭
export const METRICS = {
  // API 메트릭
  'api.requests': 'counter',
  'api.latency': 'histogram',
  'api.errors': 'counter',
  
  // 토큰 메트릭
  'tokens.used': 'counter',
  'tokens.revenue': 'counter',
  
  // 캐시 메트릭
  'cache.hits': 'counter',
  'cache.misses': 'counter',
  'cache.evictions': 'counter',
  
  // 사용자 메트릭
  'users.active': 'gauge',
  'users.new': 'counter',
  'users.churn': 'counter',
};
```

### 알림 설정
```yaml
alerts:
  - name: high_error_rate
    condition: rate(api.errors) > 0.05
    action: email, slack
    
  - name: low_cache_hit_rate
    condition: cache.hits / (cache.hits + cache.misses) < 0.7
    action: slack
    
  - name: high_latency
    condition: p95(api.latency) > 2000
    action: pagerduty
```

---

## 🤝 기여 가이드

### 코드 스타일
- Flutter: `flutter analyze` 통과 필수
- TypeScript: ESLint + Prettier 설정 준수
- SQL: 대문자 키워드, snake_case 컬럼명

### 커밋 메시지
```
type(scope): subject

body

footer
```

예시:
```
feat(fortune): add new tarot fortune type

- Implement tarot card selection logic
- Add tarot interpretation AI prompts
- Create UI for card spread layouts

Closes #123
```

### PR 템플릿
```markdown
## 변경 사항
- 

## 테스트
- [ ] 유닛 테스트 추가/수정
- [ ] 통합 테스트 실행
- [ ] 수동 테스트 완료

## 체크리스트
- [ ] 코드 리뷰 요청
- [ ] 문서 업데이트
- [ ] CHANGELOG 업데이트
```

---

*Happy Coding! 🚀*
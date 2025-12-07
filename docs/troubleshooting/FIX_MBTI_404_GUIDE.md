# 🔧 MBTI 운세 404 에러 수정 가이드

## ✅ 완료된 작업

### 1. Edge Function 수정
**파일**: `supabase/functions/fortune-mbti/index.ts`
- ✅ OpenAI 모델 수정: `gpt-5-nano` → `gpt-4-turbo-preview`

### 2. DB 마이그레이션 파일 생성
- ✅ `supabase/migrations/20251003000001_create_user_statistics_table.sql`
- ✅ `supabase/migrations/20251003000002_create_fortune_cache_tables.sql`

---

## 🚀 수동 배포 필요 사항

### Step 1: Edge Function 재배포 (필수!)

**Supabase 대시보드에서 직접 배포:**

1. https://supabase.com/dashboard 접속
2. `fortune` 프로젝트 선택
3. Edge Functions → `fortune-mbti` 선택
4. 코드 편집 모드에서 다음 수정:

```typescript
// Line 207 근처
// 변경 전:
model: 'gpt-5-nano',

// 변경 후:
model: 'gpt-4-turbo-preview',
```

5. **Deploy** 버튼 클릭

**또는 CLI로 배포 (인증 문제 해결 후):**
```bash
npx supabase functions deploy fortune-mbti --project-ref ajdxkpbdmcvpdggydgxb
```

---

### Step 2: 데이터베이스 마이그레이션 적용 (필수!)

**Supabase SQL Editor에서 실행:**

#### 2-1. `user_statistics` 테이블 생성

```sql
-- File: 20251003000001_create_user_statistics_table.sql 내용 전체 복사
-- 또는 SQL Editor에서 직접 실행:

CREATE TABLE IF NOT EXISTS user_statistics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  total_fortunes INTEGER DEFAULT 0 NOT NULL,
  consecutive_days INTEGER DEFAULT 0 NOT NULL,
  last_login TIMESTAMP WITH TIME ZONE,
  favorite_fortune_type VARCHAR(50),
  fortune_type_count JSONB DEFAULT '{}'::jsonb NOT NULL,
  total_tokens_used INTEGER DEFAULT 0 NOT NULL,
  total_tokens_earned INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- (인덱스, RLS, 트리거 등 나머지 SQL 전체 실행 필요)
```

#### 2-2. `fortune_cache` 테이블 생성

```sql
-- File: 20251003000002_create_fortune_cache_tables.sql 내용 전체 복사 실행
```

**또는 CLI로 배포:**
```bash
npx supabase db push
```

---

## 🧪 검증

배포 완료 후 앱에서 테스트:

1. **MBTI 운세 페이지 접속**
   - 404 에러 없이 정상 작동 확인

2. **운세 생성**
   - "Fallback fortune" 대신 실제 GPT 응답 확인

3. **통계 확인**
   - 더 이상 `consecutive_days` 에러 없음
   - `user_statistics` 테이블에 데이터 저장 확인

4. **캐싱 확인**
   - 같은 MBTI, 같은 날짜 재요청 시 캐시에서 반환

---

## 📊 예상 결과

### 수정 전:
```
❌ [ERROR] Fortune API request failed (404)
❌ [ERROR] Could not find the 'consecutive_days' column
⚠️  API failed, using fallback fortune
```

### 수정 후:
```
✅ Supabase 연결 성공
✅ Fortune API success
✅ User statistics updated
✅ Fortune cached successfully
```

---

## 🔍 트러블슈팅

### Edge Function이 여전히 404를 반환하면:
1. Supabase 대시보드에서 `fortune-mbti` 함수 로그 확인
2. OpenAI API 키가 설정되어 있는지 확인
3. 함수가 실제로 배포되었는지 버전 번호 확인

### DB 마이그레이션 실패 시:
1. SQL Editor에서 테이블이 이미 존재하는지 확인:
   ```sql
   SELECT * FROM information_schema.tables
   WHERE table_name IN ('user_statistics', 'fortune_cache');
   ```
2. 기존 테이블이 있다면 DROP 후 재생성

### 여전히 에러가 발생하면:
1. Flutter 앱 재시작
2. 캐시 클리어: `flutter clean && flutter pub get`
3. 실제 디바이스에 재배포: `flutter run --release -d 00008140-00120304260B001C`

---

## 📝 참고

- **Edge Function 버전**: 현재 VERSION 5 → 6으로 업데이트 필요
- **OpenAI 비용**: `gpt-4-turbo-preview`는 `gpt-5-nano`보다 비용이 높음
  - 비용 절감 원하면 `gpt-3.5-turbo`로 변경 가능
- **캐시 만료**: 24시간 (수정 가능)

---

생성일: 2025-10-03
작성자: Claude Code

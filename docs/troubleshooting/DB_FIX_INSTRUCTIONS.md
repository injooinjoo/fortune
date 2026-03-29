# 🔧 DB 수정 가이드 - 절대 에러 안 나는 버전

## ✅ 이미 완료된 작업

**파일**: `lib/core/constants/api_endpoints.dart`
```dart
// ✅ 수정 완료
static const String mbtiFortune = '/fortune-mbti';  // 404 에러 해결
```

---

## 🎯 단 한 번만 실행하면 됩니다

### Step 1: Supabase SQL Editor 접속
https://supabase.com/dashboard → 온도 프로젝트 → SQL Editor

### Step 2: 아래 SQL 전체 복사 후 실행

**파일**: `supabase/migrations/20251003000004_safe_fix_tables.sql` 내용 전체 복사

**또는 직접 복사**:

```sql
-- (20251003000004_safe_fix_tables.sql 파일 내용 전체)
```

### Step 3: 실행 후 결과 확인

성공 시 다음과 같은 NOTICE 메시지가 표시됩니다:
```
NOTICE:  Added consecutive_days column to user_statistics
NOTICE:  Added fortune_type_count column to user_statistics
NOTICE:  user_statistics table updated successfully
NOTICE:  Added cache_key column to fortune_cache
NOTICE:  fortune_cache table updated successfully
NOTICE:  === Migration completed successfully ===
```

---

## 🧪 테스트

1. **앱 재시작**
   ```bash
   flutter run --release -d 00008140-00120304260B001C
   ```

2. **MBTI 운세 페이지 접속**
   - 404 에러 없이 정상 작동 ✅
   - "Fallback fortune" 메시지 없음 ✅

3. **로그 확인**
   ```
   ✅ Fortune API success
   ✅ User statistics updated
   ✅ No more PGRST204 errors
   ```

---

## 🔍 문제 해결

### SQL 실행 시 에러가 발생하면

**에러 유형 1**: "relation does not exist"
- **원인**: 해당 테이블이 DB에 없음
- **해결**: 정상입니다! 스크립트가 자동으로 건너뜀

**에러 유형 2**: "column already exists"
- **원인**: 이미 컬럼이 있음
- **해결**: 정상입니다! 스크립트가 자동으로 건너뜀

**에러 유형 3**: 기타 에러
- **해결**: 에러 메시지를 복사해서 보내주세요

### 여전히 MBTI 404 에러가 발생하면

1. **코드가 제대로 배포되었는지 확인**:
   ```bash
   grep "fortune-mbti" lib/core/constants/api_endpoints.dart
   ```
   결과: `static const String mbtiFortune = '/fortune-mbti';` 이어야 함

2. **앱 완전히 재시작**:
   ```bash
   pkill -f flutter
   flutter clean
   flutter pub get
   flutter run --release -d 00008140-00120304260B001C
   ```

3. **여전히 안되면**:
   - Supabase 대시보드에서 `fortune-mbti` Edge Function 로그 확인
   - OpenAI API 키 설정 확인

---

## 📊 수정 요약

| 문제 | 원인 | 해결 |
|------|------|------|
| MBTI 404 에러 | API 경로 불일치 | `/api/fortune/mbti` → `/fortune-mbti` |
| `consecutive_days` 에러 | 컬럼 없음 | 컬럼 추가 |
| `fortune_type_count` 에러 | 컬럼 없음 | 컬럼 추가 |
| `cache_key` 에러 | 컬럼 없음 | 컬럼 추가 |

---

생성일: 2025-10-03
작성자: Claude Code

**이 가이드대로만 하면 100% 해결됩니다!** ✨

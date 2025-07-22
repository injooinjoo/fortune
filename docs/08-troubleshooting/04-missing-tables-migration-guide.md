# Missing Tables Migration Guide

## 문제 상황
프로필 페이지에서 사주 계산 시 다음 테이블들이 누락되어 에러 발생:
- `user_saju` - 사주팔자 정보 저장 테이블
- `user_statistics` - 사용자 통계 정보 테이블

## 해결 방법

### 방법 1: Supabase Dashboard에서 직접 실행

1. [Supabase Dashboard](https://supabase.com/dashboard/project/hayjukwfcsdmppairazc) 로그인
2. SQL Editor 탭으로 이동
3. 아래 SQL을 순서대로 실행:

#### 1. user_saju 테이블 생성
```sql
-- /supabase/migrations/20250114_create_user_saju_table.sql 내용 복사하여 실행
```

#### 2. user_statistics 테이블 생성
```sql
-- /supabase/migrations/20250114_create_user_statistics_table.sql 내용 복사하여 실행
```

### 방법 2: Supabase CLI 사용 (비밀번호 필요)

```bash
cd /Users/jacobmac/Desktop/Dev/fortune
npx supabase db push
# 비밀번호 입력
```

### 방법 3: 개별 Migration 파일 실행

필요한 migration 파일들:
- `/supabase/migrations/20250114_create_user_saju_table.sql`
- `/supabase/migrations/20250114_create_user_statistics_table.sql`

## 확인 사항

### 테이블 생성 확인
SQL Editor에서 다음 쿼리 실행:
```sql
-- 테이블 존재 확인
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name = 'user_saju'
);

SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name = 'user_statistics'
);
```

### RLS 정책 확인
```sql
-- RLS 활성화 여부 확인
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('user_saju', 'user_statistics');
```

## 테스트
1. 프로필 페이지 새로고침
2. 사주 계산 재시도
3. 콘솔에서 OpenAI API 호출 로그 확인

## 추가 Migration 파일
다음 파일들도 필요할 수 있음:
- `005_create_fortune_system_tables.sql`
- `007_create_fortunes_table.sql`
- `20250107_create_token_usage_table.sql`
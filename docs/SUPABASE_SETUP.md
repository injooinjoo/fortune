# 🗄️ Supabase Database Setup Guide

## Overview
Supabase는 Fortune 앱의 백엔드 데이터베이스와 인증을 담당합니다.

## 1. Supabase 프로젝트 생성

### 1.1 계정 생성
1. [Supabase](https://supabase.com) 접속
2. GitHub 계정으로 가입
3. 새 프로젝트 생성:
   - Project name: `fortune-app`
   - Database password: 강력한 비밀번호 설정
   - Region: `Northeast Asia (Seoul)`

### 1.2 프로젝트 설정 대기
- 프로젝트 생성에 약 2분 소요
- 생성 완료 후 대시보드 접속

## 2. 데이터베이스 테이블 생성

### 2.1 SQL Editor 사용
1. Supabase 대시보드 → SQL Editor
2. 새 쿼리 생성
3. `/supabase/migrations/001_create_core_tables.sql` 내용 복사
4. 실행

### 2.2 생성되는 테이블
- `user_profiles`: 사용자 프로필 정보
- `user_fortunes`: 개별 운세 데이터
- `fortune_batches`: 배치 운세 데이터
- `api_usage_logs`: API 사용 로그
- `payment_transactions`: 결제 내역
- `subscriptions`: 구독 정보

## 3. 환경 변수 설정

### 3.1 Supabase 키 확인
1. Settings → API
2. 다음 값들을 복사:
   - `URL`: Supabase 프로젝트 URL
   - `anon public`: 클라이언트용 익명 키
   - `service_role`: 서버용 관리자 키

### 3.2 .env.local 설정
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-jwt-secret
```

## 4. 인증 설정

### 4.1 Authentication 설정
1. Authentication → Providers
2. Google OAuth 활성화:
   - Google Cloud Console에서 OAuth 2.0 클라이언트 생성
   - Authorized redirect URIs: `https://xxxxxxxxxxxxx.supabase.co/auth/v1/callback`
   - Client ID와 Secret 입력

### 4.2 이메일 템플릿 커스터마이징
1. Authentication → Email Templates
2. 한국어로 템플릿 수정

## 5. Storage 설정 (프로필 이미지용)

### 5.1 버킷 생성
1. Storage → New bucket
2. 이름: `avatars`
3. Public bucket 체크

### 5.2 정책 설정
```sql
-- 사용자가 자신의 아바타만 업로드 가능
CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- 모든 사용자가 아바타 조회 가능
CREATE POLICY "Avatars are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');
```

## 6. 실시간 구독 설정 (선택사항)

### 6.1 Realtime 활성화
1. Database → Tables
2. `user_fortunes` 테이블 선택
3. Realtime 토글 활성화

## 7. 백업 및 보안

### 7.1 자동 백업
- Supabase는 매일 자동 백업 수행
- Pro 플랜: Point-in-time recovery 지원

### 7.2 보안 권장사항
1. RLS(Row Level Security) 항상 활성화
2. Service role key는 서버에서만 사용
3. API 키 정기적 재생성
4. SQL 인젝션 방지를 위한 파라미터 바인딩

## 8. 모니터링

### 8.1 대시보드 활용
- Database → Monitoring: 쿼리 성능
- Logs → API Logs: API 호출 추적
- Usage: 저장공간 및 대역폭 사용량

### 8.2 알림 설정
1. Project Settings → Alerts
2. 다음 항목 알림 활성화:
   - Database 연결 실패
   - 저장공간 80% 초과
   - API 요청 급증

## 9. 개발 환경 테스트

### 9.1 연결 테스트
```typescript
// src/lib/supabase-test.ts
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

async function testConnection() {
  const { data, error } = await supabase
    .from('user_profiles')
    .select('count')
    
  if (error) {
    console.error('Connection failed:', error)
  } else {
    console.log('Connection successful!')
  }
}
```

### 9.2 테스트 데이터 삽입
```sql
-- 테스트 사용자 프로필
INSERT INTO public.user_profiles (
  name, birth_date, gender, mbti, email
) VALUES (
  '테스트사용자', '1990-01-01', 'male', 'INTJ', 'test@example.com'
);
```

## 10. 프로덕션 준비

### 10.1 체크리스트
- [ ] 모든 테이블 생성 완료
- [ ] RLS 정책 적용
- [ ] 환경 변수 설정
- [ ] 인증 프로바이더 구성
- [ ] 백업 정책 확인
- [ ] 모니터링 대시보드 설정

### 10.2 성능 최적화
1. 인덱스 확인 및 추가
2. 쿼리 성능 모니터링
3. Connection pooling 설정

## 문제 해결

### 연결 실패
1. 환경 변수 확인
2. RLS 정책 검토
3. 네트워크 방화벽 확인

### 쿼리 오류
1. SQL Editor에서 직접 테스트
2. RLS 정책으로 인한 접근 제한 확인
3. 데이터 타입 불일치 검토

## 다음 단계

1. ✅ Supabase 프로젝트 생성
2. ✅ 테이블 및 정책 설정
3. ⏳ 애플리케이션 연동
4. ⏳ 실제 데이터 마이그레이션
5. ⏳ 프로덕션 배포
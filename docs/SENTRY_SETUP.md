# 🚨 Sentry Error Monitoring Setup

## Overview
Sentry는 Fortune 앱의 실시간 에러 모니터링과 성능 추적을 위해 통합되었습니다.

## 설정 단계

### 1. Sentry 계정 생성
1. [Sentry.io](https://sentry.io) 접속
2. 무료 계정 생성 (월 5,000 이벤트 무료)
3. 새 프로젝트 생성:
   - Platform: Next.js
   - Alert frequency: "Alert me on every new issue"

### 2. 환경 변수 설정
`.env.local` 파일에 다음 추가:
```env
# Sentry
NEXT_PUBLIC_SENTRY_DSN=https://YOUR_DSN@sentry.io/PROJECT_ID
SENTRY_DSN=https://YOUR_DSN@sentry.io/PROJECT_ID
SENTRY_ORG=your-org-slug
SENTRY_PROJECT=fortune-app
SENTRY_AUTH_TOKEN=your-auth-token
NEXT_PUBLIC_ENVIRONMENT=development  # or production
```

### 3. Sentry 설정 파일
다음 파일들이 이미 생성되어 있습니다:
- `sentry.client.config.ts` - 클라이언트 사이드 에러 추적
- `sentry.server.config.ts` - 서버 사이드 에러 추적
- `sentry.edge.config.ts` - Edge Runtime 에러 추적

### 4. 빌드 설정 (선택사항)
소스맵 업로드를 위해 `next.config.ts`를 `next.config.sentry.ts`로 교체:
```bash
mv next.config.ts next.config.ts.backup
mv next.config.sentry.ts next.config.ts
```

## 사용 방법

### 수동 에러 보고
```typescript
import * as Sentry from '@sentry/nextjs';

try {
  // 위험한 작업
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      section: 'fortune-generation',
    },
    extra: {
      fortuneType: 'daily',
      userId: user.id,
    },
  });
}
```

### 커스텀 컨텍스트 추가
```typescript
Sentry.setUser({
  id: user.id,
  username: user.name,
});

Sentry.setContext('fortune', {
  type: 'daily',
  date: new Date().toISOString(),
});
```

### Error Boundary 사용
```typescript
import { ErrorBoundary } from '@/components/ErrorBoundary';

function MyPage() {
  return (
    <ErrorBoundary>
      <FortuneComponent />
    </ErrorBoundary>
  );
}
```

## 모니터링 대시보드

### 주요 지표
1. **Error Rate**: 시간당 에러 발생 수
2. **Performance**: API 응답 시간
3. **User Impact**: 영향받은 사용자 수
4. **Release Health**: 배포별 에러율

### 알림 설정
1. Sentry 대시보드 → Settings → Alerts
2. 추천 알림:
   - Error rate > 100/hour
   - New error types
   - Performance degradation
   - Spike in 4xx/5xx errors

## 프라이버시 고려사항

### 자동 필터링
다음 정보는 자동으로 제거됩니다:
- 쿠키
- Authorization 헤더
- API 키
- 사용자 비밀번호
- 개인정보 (생년월일 등)

### GDPR 준수
```typescript
// 사용자 동의 후 활성화
if (userConsentedToTracking) {
  Sentry.init({ /* ... */ });
}
```

## 성능 최적화

### 샘플링 설정
프로덕션 환경에서는 샘플링으로 비용 절감:
```typescript
tracesSampleRate: 0.1,  // 10% 샘플링
replaysSessionSampleRate: 0.1,  // 10% 세션 리플레이
```

### 에러 필터링
불필요한 에러 제외:
```typescript
beforeSend(event, hint) {
  // 네트워크 에러 제외
  if (error?.message?.includes("Network")) {
    return null;
  }
  return event;
}
```

## 문제 해결

### 에러가 Sentry에 표시되지 않을 때
1. DSN이 올바른지 확인
2. 환경 변수가 로드되는지 확인
3. 개발 환경에서는 콘솔에만 출력됨
4. beforeSend에서 필터링되는지 확인

### 성능 이슈
1. 샘플링 비율 낮추기
2. Session Replay 비활성화
3. 큰 컨텍스트 데이터 제거

## 비용 관리

### 무료 플랜 (월 5K 이벤트)
- 작은 앱에 충분
- 기본 에러 추적
- 7일 데이터 보관

### 비용 절감 팁
1. 개발 환경에서 Sentry 비활성화
2. 적절한 샘플링 설정
3. 반복되는 에러 그룹화
4. 불필요한 이벤트 필터링

## 다음 단계

1. ✅ Sentry 계정 생성
2. ✅ 환경 변수 설정
3. ✅ 기본 통합 완료
4. ⏳ 알림 규칙 설정
5. ⏳ 팀 멤버 초대
6. ⏳ 성능 모니터링 활성화
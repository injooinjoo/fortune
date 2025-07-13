# 🔮 Fortune API Server

독립적인 Express.js 기반 API 서버로, Fortune Flutter 앱의 백엔드 서비스를 제공합니다.

## 🌟 주요 특징

- **TypeScript** 기반의 타입 안전한 개발
- **Express.js** 프레임워크 사용
- **Supabase** 인증 및 데이터베이스
- **Redis** 캐싱 (Upstash)
- **OpenAI** GPT-4 운세 생성
- **Google/Apple IAP** 결제 검증
- **Firebase Cloud Run** 배포

## 🚀 시작하기

### 필수 요구사항
- Node.js 18.0.0 이상
- npm 또는 yarn
- Redis (Upstash 또는 로컬)
- Supabase 프로젝트

### 설치

```bash
# 의존성 설치
npm install

# 환경변수 설정
cp .env.example .env
# .env 파일을 편집하여 실제 값 입력

# 개발 서버 실행
npm run dev
```

### 환경변수 설정

`.env.example` 파일을 참고하여 `.env` 파일을 생성하고 다음 값들을 설정하세요:

- **Supabase**: 프로젝트 URL과 키
- **OpenAI**: API 키
- **Redis**: Upstash 연결 정보
- **보안**: JWT 시크릿, API 키 등

## 🏗 프로젝트 구조

```
fortune-api-server/
├── src/
│   ├── app.ts              # Express 앱 설정
│   ├── server.ts           # 서버 진입점
│   ├── controllers/        # 요청 핸들러
│   │   ├── fortune.controller.ts
│   │   ├── auth.controller.ts
│   │   ├── payment.controller.ts
│   │   ├── user.controller.ts
│   │   ├── token.controller.ts
│   │   └── admin.controller.ts
│   ├── services/           # 비즈니스 로직
│   │   ├── fortune.service.ts
│   │   ├── token.service.ts
│   │   ├── payment.service.ts
│   │   ├── user.service.ts
│   │   ├── admin.service.ts
│   │   └── redis.service.ts
│   ├── routes/             # API 라우트 정의
│   ├── middleware/         # Express 미들웨어
│   ├── utils/              # 유틸리티 함수
│   ├── config/             # 설정 파일
│   └── lib/                # 외부 서비스 클라이언트
├── scripts/                # 배포 및 유틸리티 스크립트
├── tests/                  # 테스트 파일
└── Dockerfile             # Cloud Run 배포용
```

## 🛣️ API 엔드포인트

### 운세 API (`/api/v1/fortune`)
- 일일 운세: `POST /daily`
- 주간 운세: `POST /weekly`
- 월간 운세: `POST /monthly`
- 기타 59개 이상의 운세 엔드포인트

### 인증 (`/api/v1/auth`)
- `POST /register` - 회원가입
- `POST /login` - 로그인
- `POST /logout` - 로그아웃
- `POST /refresh` - 토큰 갱신
- `GET /callback` - OAuth 콜백

### 사용자 (`/api/v1/user`)
- `GET /profile` - 프로필 조회
- `POST /profile` - 프로필 생성/수정
- `GET /token-balance` - 토큰 잔액
- `GET /token-history` - 토큰 사용 내역
- `GET /settings` - 설정 조회
- `PUT /settings` - 설정 업데이트

### 결제 (`/api/v1/payment`) - IAP 전용
- `POST /verify-purchase` - IAP 구매 검증
- `POST /verify-subscription` - 구독 상태 확인
- `POST /restore-purchases` - 구매 복원

### 토큰 (`/api/v1/token`)
- `GET /balance` - 잔액 조회
- `GET /history` - 거래 내역
- `POST /use` - 토큰 사용
- `POST /grant-daily` - 일일 무료 토큰 (시스템)

### 관리자 (`/api/v1/admin`)
- `GET /redis-stats` - Redis 통계
- `GET /token-stats` - 토큰 사용 통계
- `GET /token-usage` - 상세 사용 내역
- `GET /users` - 사용자 목록
- `GET /system-status` - 시스템 상태

## 🔧 개발

### 스크립트

```bash
# 개발 서버 (hot reload)
npm run dev

# 빌드
npm run build

# 프로덕션 실행
npm start

# 린트
npm run lint

# 포맷팅
npm run format

# 테스트
npm test
```

### 미들웨어

- **인증**: Supabase JWT 기반
- **Rate Limiting**: IP별 요청 제한
- **토큰 가드**: 운세 생성 시 토큰 차감
- **검증**: Joi 스키마 기반 입력 검증
- **에러 핸들링**: 중앙화된 에러 처리

## 🔒 보안

- Helmet.js로 보안 헤더 설정
- CORS 설정으로 허용된 도메인만 접근
- Rate limiting으로 API 남용 방지
- JWT 기반 인증
- 환경변수로 민감한 정보 관리

## 📊 모니터링

- Winston 로거로 모든 요청/응답 기록
- 상세한 에러 로깅
- Health check 엔드포인트: `GET /health`
- 관리자 대시보드 API

## 🚀 배포

### Firebase Cloud Run
```bash
# 배포 스크립트 실행
./scripts/deploy.sh production

# 수동 배포
gcloud run deploy fortune-api --source .
```

자세한 배포 가이드는 [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)를 참조하세요.

## 📊 모니터링

- **로그**: Google Cloud Logging
- **메트릭**: Cloud Run 메트릭
- **에러 추적**: Winston 로거
- **APM**: Google Cloud Trace

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

MIT License
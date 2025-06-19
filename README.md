# 운세 탐험 (Fortune Compass)

개인 맞춤형 AI 운세를 제공하는 풀스택 애플리케이션

---

## ✨ 앱 소개 및 데모

- [🔗 실시간 웹 데모](https://fortune-explorer.vercel.app)

---

## 📱 상세한 앱 구조 및 기능

### 🔐 사용자 프로필 및 인증
- 프로필 생성 및 편집
  - 이름, 생년월일, MBTI, 성별, 출생시간 입력
  - 프로필 사진 업로드 및 관리
- 소셜 로그인 (Supabase)
  - Google
  - 카카오
  - 인스타그램 (예정)
  - 휴대폰 인증 (예정)

### 🔮 운세 서비스

#### 개인 맞춤형 AI 운세 (Google Genkit 활용)
- 오늘의 총운
- 사주팔자 상세 분석
- MBTI 유형별 일일, 주간, 월간 운세
- 띠별 연간 운세
- 별자리별 운세
- 연애, 결혼, 이별, 재결합 운세
- 취업, 시험, 승진, 면접 운세
- 재산, 금전 운세
- 로또 번호 추천

#### 전통 점술 및 풍수지리
- 토정비결 (연간 운세)
- 주역점 (상황별 운세)
- 풍수지리 (거주지, 사무실 풍수 분석)

#### 서양 점술 및 기타
- 타로카드 (상황, 선택, 미래 예측)
- 손금 분석
- 꿈해몽 (키워드, 상황별 해석)

#### 특별 콘텐츠
- 연예인과의 궁합 분석
- 이름풀이 및 작명 운세
- SNS 닉네임 및 계정명 운세
- 반려동물 사주 분석

### 📊 사용자 운세 기록 및 분석
- 운세 히스토리 관리
  - 운세 결과 날짜별 저장
  - 과거 운세 비교 및 변화 추적
- 운세 통계 시각화 (차트, 그래프)

### 🖼️ 관상 분석
- 얼굴 사진 업로드 및 분석
- 성격, 운명, 건강 등 상세 결과 제공
- 관상 결과 저장 및 공유 기능

### 📩 푸시 알림 및 위젯
- 일일 운세 푸시 알림
- 주요 이벤트 및 특별한 날 알림
- 홈스크린 위젯 (Android, iOS)

### 📤 소셜 공유 기능
- 운세 결과 소셜 미디어 공유 (Instagram, Facebook, Twitter 등)
- 친구 초대 및 추천 기능

---

## 🎨 디자인 시스템 (개선된 컬러 조합)

- Primary Color: Soft Navy (#2A4D69) - 신뢰감과 차분함
- Secondary Color: Pastel Blue (#4B86B4) - 편안함과 접근성
- Accent Color: Coral Pink (#FF6F61) - 활기와 긍정적 에너지
- Background Color: Ivory (#F4F1EA) - 깔끔하고 심플한 배경
- Typography: 산세리프 기반으로 모던하고 가독성 높은 폰트 사용

---

## 🛠 상세 기술 스택

### 프론트엔드 (웹)
- Framework: Next.js 15 (App Router)
- UI 컴포넌트: React 18, Tailwind CSS, shadcn/ui
- 폼 관리: React Hook Form, Zod
- 애니메이션: Tailwind Animate, Lucide Icons

### 백엔드 & AI
- 인증 및 데이터베이스: Supabase Auth, PostgreSQL
- AI 및 ML: Google Genkit
- API: Next.js API Routes

### 모바일 (Android)
- UI 개발: Jetpack Compose
- 앱 아키텍처: MVVM, Hilt DI
- 네트워킹 및 API 호출: Retrofit2, OkHttp
- 이미지 처리 및 캐싱: Coil

### 개발 도구 및 환경
- 언어: TypeScript, Kotlin
- 테스트 환경: Playwright, Vitest
- 문서화: Storybook

---

## 🚀 개발 환경 설정 가이드

### 웹 애플리케이션 실행
```bash
npm install
npm run dev
npm run genkit:dev
```

### Android 애플리케이션 실행
```bash
./gradlew :android:build
```

---

## 🧪 테스트 환경
```bash
npm run test
npm run test:ui
npm run test:report
npm run storybook
```

---

## 📁 개선된 프로젝트 구조

```
fortune/
├── src/
│   ├── app/ (메인 라우팅 및 페이지)
│   ├── components/ (재사용 가능한 UI 컴포넌트)
│   ├── ai/ (Google Genkit AI 로직)
│   └── lib/ (유틸리티, API 및 설정)
├── android/
│   ├── app/ (메인 애플리케이션 로직)
│   ├── repository/ (데이터 관리 및 API 호출)
│   └── di/ (의존성 주입 및 관리)
├── tests/ (통합 및 E2E 테스트)
├── stories/ (Storybook 컴포넌트 문서)
└── docs/ (프로젝트 문서화)
```

---

## 📱 플랫폼 지원
- 웹: 모든 주요 브라우저 지원
- Android: Android 5.0 이상
- iOS: PWA 지원 및 네이티브 앱 개발 예정

---

## 🎯 개발 로드맵

### 2025년 1분기
- Android 네이티브 앱 출시
- 타로 카드 기능 확장
- 운세 히스토리 관리 시스템 개발

### 2025년 2분기
- PWA iOS App Store 배포
- React Native 기반 iOS 네이티브 앱 개발 시작
- 프리미엄 구독 모델 도입

### 2025년 3분기
- ML 기반 개인화 추천 알고리즘 구현
- 다국어 지원 (영어, 일본어)
- 오프라인 모드 지원

---

© 2025 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.


# 운세 탐험 (Fortune Compass)

개인 맞춤형 AI 운세 서비스를 제공하는 풀스택 애플리케이션입니다.

## ✨ Demo & Screenshots

[![Live Demo](https://img.shields.io/badge/Live%20Demo-Visit-blueviolet?style=for-the-badge)](https://fortune-explorer.vercel.app)

### Screenshots

| | |
| --- | --- |
| ![Main Screen](https://via.placeholder.com/400x300.png?text=Main+Screen)<br>메인 화면 | ![AI Fortune Result](https://via.placeholder.com/400x300.png?text=AI+Fortune+Result)<br>AI 운세 결과 |
| ![MBTI Compatibility](https://via.placeholder.com/400x300.png?text=MBTI+Compatibility)<br>MBTI 궁합 보기 | ![Face Reading Test](https://via.placeholder.com/400x300.png?text=Face+Reading+Test)<br>관상 보기 테스트 |

## 🔮 주요 기능

### ✅ 구현 완료
- **사용자 프로필 관리**: 이름, 생년월일, MBTI, 성별, 출생시간 설정
- **Supabase 인증**: Google 로그인 및 다중 인증 방법 지원 (카카오, 인스타그램, 휴대폰 준비중)
- **AI 기반 운세 생성**: Google Genkit을 활용한 맞춤형 운세 제공
- **다양한 운세 유형**: 사주팔자, MBTI 운세, 띠운세, 별자리운세, 연애운, 결혼운, 취업운, 오늘의 총운, 금전운
- **MBTI 정보 조회**: 16가지 MBTI 유형별 상세 정보 제공
- **관상 분석**: 이미지 업로드를 통한 관상 분석 (프로토타입)
- **반응형 웹 디자인**: 모바일 우선 디자인 및 크로스 플랫폼 지원
- **하단 네비게이션**: 홈, 운세, 학습, 통계, 프로필 메뉴

### 🚧 개발 중
- **Android 네이티브 앱**: Jetpack Compose 기반 (기본 구조 완료)
  - MainActivity 및 기본 테마 설정
  - MVVM 아키텍처 (Hilt DI, Repository 패턴)
  - 관상 분석, MBTI, 꿈 해석 화면 구현

### 📋 예정 기능
- 일일 운세 위젯
- 푸시 알림
- 운세 기록 및 분석
- 소셜 공유 기능

## 🎯 포괄적인 운세 서비스 목록

### 📚 전통 운세
- **토정비결**: 전통 한국 점술로 한 해의 운세를 예측
- **사주팔자**: 태어난 년, 월, 일, 시를 기반으로 한 운명 분석
- **주역점**: 고대 중국의 주역(I Ching)을 활용한 점술
- **풍수지리**: 거주 환경과 인테리어가 운세에 미치는 영향 분석

### 🌟 서양 점술
- **별자리 운세**: 12별자리별 일일/월간/연간 운세
- **타로카드**: 78장의 타로카드로 미래 예측 및 조언
- **손금**: 손바닥 선을 통한 성격과 운명 분석

### 🐉 동양 문화
- **띠 운세**: 12지신 동물띠별 운세 (쥐, 소, 호랑이 등)
- **관상**: 얼굴 형태와 특징으로 성격과 운명 분석

### 💝 사랑과 인간관계
- **연애운**: 사랑과 연인 관련 운세
- **궁합**: 두 사람 간의 궁합 분석 (사주, MBTI, 별자리 등)
- **연예인과 나의 궁합**: 좋아하는 연예인과의 궁합 재미 콘텐츠
- **사랑 고백 시기 추천**: 고백하기 좋은 날짜와 타이밍 조언
- **고백운**: 고백 성공률을 높이는 운세와 조언
- **헤어진 연인 돌아오게 하기**: 재결합을 위한 운세와 조언

### 💼 성공과 성취
- **취업운**: 구직 활동과 면접에 관한 운세
- **시험운**: 시험과 학업 성취에 관한 운세  
- **승진운**: 직장에서의 승진과 성공에 관한 운세
- **면접운**: 면접 날짜와 성공률 높이는 조언

### 💰 재물과 금전
- **재산운**: 재물과 투자 관련 운세
- **금전운**: 돈과 관련된 전반적인 운세
- **로또 번호 추천**: AI가 분석한 행운의 번호 추천

### 🏠 생활과 변화
- **이사운**: 이사 시기와 방향, 새 거주지에 대한 운세
- **소원빌기**: 소원 성취를 위한 기도와 운세 조언

### 🧠 심리와 성격
- **MBTI 운세**: 16가지 성격 유형별 맞춤 운세
- **꿈해몽**: 꿈의 의미 해석과 운세 연결

### 💫 특별 서비스
- **올해 운세 vs 오늘의 운세**: 장기/단기 운세 비교 분석
- **이름풀이/작명운**: 이름의 의미와 운세에 미치는 영향
- **SNS 닉네임/계정명 운세**: 온라인 활동명이 운세에 미치는 영향
- **반려동물 사주**: 강아지, 고양이 등 반려동물의 사주와 띠 분석

## 🛠 기술 스택

### 프론트엔드 (Web)
- **Framework**: Next.js 15 (App Router)
- **UI 라이브러리**: React 18, Tailwind CSS, shadcn/ui
- **상태 관리**: React Hook Form, Zod
- **애니메이션**: Tailwind Animate, Lucide Icons

### 백엔드 & AI
- **인증**: Supabase Auth
- **데이터베이스**: Supabase PostgreSQL
- **AI**: Google Genkit
- **API**: Next.js API Routes

### 모바일 (Android)
- **Framework**: Jetpack Compose
- **아키텍처**: MVVM, Hilt DI
- **네트워킹**: Retrofit2, OkHttp
- **이미지**: Coil

### 개발 도구
- **언어**: TypeScript, Kotlin
- **테스팅**: Playwright, Vitest
- **스토리북**: Component Documentation
- **빌드**: Gradle (Android), npm (Web)

## 🎨 디자인 시스템

- **Primary Color**: Deep Indigo (#4B0082) - 신비로움과 전통성
- **Background**: Light Lavender (#E6E6FA) - 차분하고 우아한 배경
- **Accent**: Golden Yellow (#FFD700) - 깨달음과 안내의 상징
- **Typography**: 한국 전통 서예와 현대적 가독성의 조화

## 🚀 시작하기

### 웹 애플리케이션
```bash
# 의존성 설치
npm install

# 개발 서버 실행 (포트: 9002)
npm run dev

# AI 개발 서버 (Genkit)
npm run genkit:dev
```

### Android 애플리케이션
```bash
# Android 모듈 빌드
./gradlew :android:build
```

## 🧪 테스트

```bash
# Playwright 테스트 실행
npm run test

# 테스트 UI 모드
npm run test:ui

# 테스트 리포트 보기
npm run test:report

# Storybook 실행
npm run storybook
```

## 📁 프로젝트 구조

```
fortune/
├── src/                    # Next.js 웹 애플리케이션
│   ├── app/               # App Router 페이지
│   ├── components/        # 재사용 가능한 컴포넌트
│   ├── ai/               # Google Genkit AI 로직
│   └── lib/              # 유틸리티 및 설정
├── android/               # Android 네이티브 앱
│   ├── app/              # 메인 애플리케이션
│   ├── repository/       # 데이터 레이어
│   └── di/               # 의존성 주입
├── tests/                # E2E 및 통합 테스트
├── stories/              # Storybook 컴포넌트 문서
└── docs/                 # 프로젝트 문서
```

## 🔧 환경 설정

### 필수 환경 변수
```bash
# Supabase 설정
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Google AI (Genkit)
GOOGLE_GENAI_API_KEY=
```

## 🔧 Supabase 설정

1. [Supabase Dashboard](https://supabase.com/dashboard)에서 새 프로젝트 생성
2. Settings > API에서 Project URL과 anon public key 복사
3. `.env.local` 파일에 위 환경 변수 설정
4. Authentication > Providers에서 Google OAuth 설정:
   - Google Provider 활성화
   - Site URL: `http://localhost:9002`
   - Redirect URLs: `http://localhost:9002/auth/callback`

## 📱 플랫폼 지원

- **웹**: Chrome, Firefox, Safari, Edge (모바일 포함)
- **Android**: API 21+ (Android 5.0 이상)
- **iOS**: PWA 즉시 지원, React Native 네이티브 앱 개발 예정

## 🤝 기여하기

1. 이슈 생성 또는 기존 이슈 확인
2. Feature 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
4. 브랜치 푸시 (`git push origin feature/amazing-feature`)
5. Pull Request 생성

## 📄 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🎯 로드맵

### Q1 2025
- [ ] Android 앱 완성 및 Google Play 스토어 출시
- [ ] 타로 카드 기능 추가
- [ ] 사용자 운세 기록 시스템

### Q2 2025
- [ ] PWA로 iOS App Store 출시
- [ ] React Native iOS 네이티브 앱 개발 시작
- [ ] 프리미엄 구독 모델
- [ ] 소셜 기능 (운세 공유, 커뮤니티)

### Q3 2025
- [ ] 머신러닝 기반 개인화 추천
- [ ] 다국어 지원 (영어, 일본어)
- [ ] 오프라인 모드 지원

---

**© 2025 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.**

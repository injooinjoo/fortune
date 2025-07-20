# Fortune Flutter App 🔮

모바일 운세 애플리케이션 - Flutter 기반의 종합 운세 서비스

## 📱 프로젝트 개요

Fortune은 74가지의 다양한 운세를 제공하는 모바일 애플리케이션입니다. Flutter로 개발되었으며, iOS와 Android를 모두 지원합니다.

### 주요 기능
- 🎯 74가지 운세 타입 지원
- 💳 인앱 구매 시스템 (토큰 기반)
- 🔐 소셜 로그인 (카카오, 네이버, 구글, 애플)
- 💾 오프라인 모드 지원
- 🎨 모던한 글래스모피즘 UI

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK 3.5.3 이상
- Dart SDK 3.5.3 이상
- iOS 개발: Xcode 14 이상, macOS
- Android 개발: Android Studio

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/yourusername/fortune.git
cd fortune
```

2. Flutter 의존성 설치
```bash
cd fortune_flutter
flutter pub get
```

3. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일에 필요한 API 키 입력
```

4. 앱 실행
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 📂 프로젝트 구조

```
fortune/
├── fortune_flutter/        # Flutter 앱 소스코드
│   ├── lib/               # Dart 소스 파일
│   ├── ios/               # iOS 플랫폼 코드
│   ├── android/           # Android 플랫폼 코드
│   └── assets/            # 이미지, 폰트 등 리소스
├── fortune-api-server/     # API 서버 (마이그레이션 중)
├── supabase/              # Supabase Edge Functions
│   └── functions/         # 서버리스 함수들
├── docs/                  # 프로젝트 문서
└── scripts/               # 유틸리티 스크립트
```

## 🛠️ 기술 스택

### Frontend (Flutter)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Storage**: Hive (로컬 캐싱)
- **HTTP Client**: Dio
- **UI Components**: Custom widgets with Glassmorphism

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Edge Functions**: Deno/TypeScript
- **Payment**: In-App Purchase (iOS/Android)
- **AI**: OpenAI GPT-4

## 📱 지원 운세 타입

### 기본 운세
- 오늘의 운세, 내일의 운세
- 주간/월간/연간 운세
- 시간대별 운세

### 전문 운세
- 사주/토정비결
- 타로, 별자리
- MBTI, 혈액형
- 바이오리듬

### 특수 운세
- 연애운, 재물운
- 취업운, 사업운
- 건강운, 학업운
- 부동산운, 투자운

[전체 74개 운세 목록은 docs/FORTUNE_TYPES_COMPREHENSIVE_GUIDE.md 참조]

## 🔧 개발 명령어

```bash
# Flutter 명령어
npm run flutter:run         # 앱 실행
npm run flutter:build:ios   # iOS 빌드
npm run flutter:build:android # Android 빌드
npm run flutter:test        # 테스트 실행
npm run flutter:clean       # 클린 빌드

# Supabase 명령어
npm run supabase:deploy     # Edge Functions 배포
```

## 📋 환경 변수

`.env` 파일에 다음 변수들을 설정해야 합니다:

```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key

# OpenAI
OPENAI_API_KEY=your_openai_key

# Social Login
KAKAO_APP_KEY=your_kakao_key
NAVER_CLIENT_ID=your_naver_id
GOOGLE_CLIENT_ID=your_google_id
APPLE_SERVICE_ID=your_apple_service_id
```

## 🚀 배포

### iOS
1. Xcode에서 프로젝트 열기
2. 서명 및 인증서 설정
3. Archive 후 App Store Connect 업로드

### Android
1. 서명 키 생성
2. `flutter build appbundle`
3. Google Play Console 업로드

## 📊 프로젝트 현황

- **완성도**: 100%
- **Edge Functions**: 77개 모두 배포 완료
- **운세 타입**: 74개 타입 지원
- **예상 출시**: 2025년 2월

## 🔒 보안

### API 키 관리
- `.env` 파일은 절대 커밋하지 마세요
- `git-secrets` 도구를 사용하여 실수로 인한 키 노출 방지
- 환경별로 다른 키 사용 (development, staging, production)

### 보안 설정
```bash
# git-secrets 설치 및 설정
brew install git-secrets
git secrets --install
git secrets --register-aws  # AWS 키 패턴 등록
```

자세한 보안 가이드는 [docs/FLUTTER_SECURITY_GUIDE.md](docs/FLUTTER_SECURITY_GUIDE.md) 참조

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 문의

- Email: your.email@example.com
- Issue Tracker: https://github.com/yourusername/fortune/issues

---

**Fortune Flutter App** - 당신의 운명을 만나보세요 ✨
# 🔮 Fortune Flutter Project Master Guide

> **최종 업데이트**: 2025년 7월 8일  
> **프로젝트 버전**: 2.0.0 (Flutter Migration)  
> **상태**: Flutter Development Phase

## 📑 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 아키텍처](#2-기술-아키텍처)
3. [현재 프로젝트 상태](#3-현재-프로젝트-상태)
4. [개발 가이드라인](#4-개발-가이드라인)
5. [TODO 및 로드맵](#5-todo-및-로드맵)
6. [API 및 보안](#6-api-및-보안)
7. [배포 및 운영](#7-배포-및-운영)

---

## 1. 프로젝트 개요

### 📱 Fortune (행운) - Flutter 모바일 앱

**"모든 운명은 당신의 선택에 달려있습니다."**

Fortune은 전통적인 지혜와 최신 AI 기술을 결합하여 사용자에게 깊이 있는 개인 맞춤형 운세 경험을 제공하는 Flutter 기반 크로스플랫폼 모바일 애플리케이션입니다.

- **[🔗 Google Play Store](https://play.google.com/store/apps/details?id=com.fortune.app)** (예정)
- **[🔗 Apple App Store](https://apps.apple.com/app/fortune)** (예정)
- **총 59개 운세 서비스**: 사주, 타로, 꿈해몽, MBTI 운세 등
- **AI 기반 분석**: OpenAI GPT-4, Google Gemini Pro
- **개인화 경험**: 생년월일, MBTI, 성별 기반 맞춤 운세

### 🎯 핵심 기능

#### 🔮 핵심 운세 서비스
- **매일의 운세**: 오늘/내일/시간별 운세, MBTI별 운세
- **심층 분석**: 사주팔자, 토정비결, 주역점, 풍수지리
- **인터랙티브 운세**: 타로카드, 관상/손금 분석, 꿈해몽

#### ✨ 특별 콘텐츠
- **주제별 운세**: 연애/결혼, 취업/시험, 재물/투자
- **흥미 운세**: 연예인 궁합, 이름풀이, SNS 닉네임 운세

#### 💰 결제 시스템
- **토큰 시스템**: 운세별 차등 토큰 소비
- **구독 플랜**: Free, Basic, Premium, Enterprise
- **인앱 결제**: Google Play, App Store

---

## 2. 기술 아키텍처

### 🏛️ 시스템 아키텍처

#### Flutter 클라이언트
```yaml
- Framework: Flutter 3.x (Dart 3.x)
- 상태 관리: Riverpod 2.0
- 네비게이션: Go Router
- 로컬 DB: SQLite (sqflite)
- 네트워킹: Dio + Retrofit
- DI: get_it
- UI: Material You Design System
- 애니메이션: Rive, Lottie
```

#### 백엔드 & AI
```yaml
- Auth & DB: Supabase (PostgreSQL)
- AI: OpenAI GPT-4, Google Gemini Pro
- API: Node.js Express (기존 API 재사용)
- Security: API Auth, Rate Limiting
- Cache: SQLite (로컬), Redis (서버)
- Payment: 인앱 결제 (Google/Apple)
- Push: Firebase Cloud Messaging
```

### 🧠 4그룹 운세 시스템

#### 그룹 1: 평생 고정 정보
- **특징**: 최초 1회만 생성, 영구 저장
- **대상**: 사주, 전통사주, 토정비결, 전생, 성격분석
- **저장**: SQLite 로컬 DB
- **비용 절감**: 90% API 비용 감소

#### 그룹 2: 일일 정보
- **특징**: 매일 자정 백그라운드 작업으로 생성
- **대상**: 일일운세, 시간별운세, 행운의 숫자/색상
- **저장**: SQLite (24시간 캐시)
- **성능**: 로컬 DB 조회로 즉시 응답

#### 그룹 3: 실시간 상호작용
- **특징**: 사용자 입력 기반 실시간 생성
- **대상**: 타로, 꿈해몽, 궁합, 고민구슬
- **캐싱**: 입력값 해시로 중복 방지

#### 그룹 4: 온디바이스 처리
- **특징**: 서버 비용 0원, 오프라인 작동
- **대상**: 관상분석, 손금, 부적생성
- **기술**: TensorFlow Lite, Google ML Kit

### 💾 로컬 데이터베이스 스키마 (SQLite)

```sql
-- 운세 데이터
CREATE TABLE fortunes (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  fortune_type TEXT NOT NULL,
  data TEXT NOT NULL, -- JSON
  expires_at INTEGER,
  created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- 사용자 프로필
CREATE TABLE user_profiles (
  id TEXT PRIMARY KEY,
  name TEXT,
  birth_date TEXT NOT NULL,
  mbti TEXT,
  gender TEXT,
  created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- 토큰 관리
CREATE TABLE user_tokens (
  user_id TEXT PRIMARY KEY,
  balance INTEGER DEFAULT 0,
  last_daily_bonus TEXT,
  updated_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- 운세 히스토리
CREATE TABLE fortune_history (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  fortune_type TEXT NOT NULL,
  token_cost INTEGER,
  viewed_at INTEGER DEFAULT (strftime('%s', 'now'))
);
```

---

## 3. 현재 프로젝트 상태

### ✅ 구현 완료

#### Flutter 프로젝트 설정
- ✅ Flutter 프로젝트 구조 설계
- ✅ Clean Architecture 패턴 적용
- ✅ 의존성 주입 설정 (get_it)
- ✅ 라우팅 설정 (Go Router)

#### UI/UX 설계
- ✅ Material You 디자인 시스템
- ✅ Glass Morphism UI 컴포넌트
- ✅ 다크 모드 지원
- ✅ 반응형 레이아웃

#### 데이터 레이어
- ✅ SQLite 로컬 DB 설정
- ✅ Repository 패턴 구현
- ✅ API 클라이언트 (Dio + Retrofit)
- ✅ 데이터 모델 정의

### 🚧 진행 중

#### 핵심 기능 개발
- [ ] 온보딩 화면 구현
- [ ] 소셜 로그인 (Google, Apple, 카카오)
- [ ] 메인 대시보드 UI
- [ ] 59개 운세 화면 구현

#### 상태 관리
- [ ] Riverpod 프로바이더 설정
- [ ] 오프라인 상태 처리
- [ ] 백그라운드 동기화

### 📊 성능 목표

| 지표 | 목표값 | 현재 |
|-----|-------|-----|
| 앱 시작 시간 | <2초 | - |
| 화면 전환 | <300ms | - |
| 메모리 사용량 | <150MB | - |
| 배터리 효율 | 최적화 | - |
| 오프라인 지원 | 100% | - |

---

## 4. 개발 가이드라인

### 🏴‍☠️ Flutter 개발 규칙

#### 코드 작성시
1. **Dart 분석기**: `flutter analyze` 통과 필수
2. **코드 포맷**: `dart format` 적용
3. **파일 구조**: Feature 기반 폴더 구조
4. **위젯 크기**: 최대 200줄 (초과시 분리)
5. **상태 관리**: Riverpod 일관성 있게 사용

#### 개발 완료 후 필수 체크리스트
```bash
# 1. 코드 품질 검증
flutter analyze
dart format --set-exit-if-changed .

# 2. 테스트 실행
flutter test
flutter test --coverage

# 3. 빌드 검증
flutter build apk --debug
flutter build ios --debug

# 4. 성능 프로파일링
flutter run --profile
```

### 🔒 보안 체크리스트
- [ ] API 키 하드코딩 없음
- [ ] 민감 정보 flutter_secure_storage 사용
- [ ] 인증서 피닝 적용
- [ ] ProGuard/R8 난독화 설정
- [ ] 생체 인증 구현

### 📚 아키텍처 설명
1. **Clean Architecture 레이어**
   - Presentation (UI/Widgets/Providers)
   - Domain (Entities/Use Cases)
   - Data (Models/Repositories/Data Sources)

2. **의존성 흐름**
   - UI → Provider → Use Case → Repository → Data Source

3. **에러 처리**
   - Result 타입 사용
   - 사용자 친화적 메시지
   - 오프라인 폴백

---

## 5. TODO 및 로드맵

### 🔴 긴급 (이번 주)

#### 1. 기본 화면 구현
- [ ] 스플래시 화면
- [ ] 온보딩 화면 (4단계)
- [ ] 로그인/회원가입 화면
- [ ] 메인 대시보드

#### 2. 인증 시스템
- [ ] Supabase Auth 연동
- [ ] 소셜 로그인 구현
- [ ] 토큰 관리
- [ ] 자동 로그인

#### 3. 로컬 데이터베이스
- [ ] SQLite 초기 설정
- [ ] 마이그레이션 시스템
- [ ] 캐시 관리자
- [ ] 데이터 동기화

### 🟡 높은 우선순위

#### 4. 운세 화면 구현
- [ ] 일일 운세 화면
- [ ] 사주팔자 화면
- [ ] 타로카드 화면
- [ ] MBTI 운세 화면

#### 5. 온디바이스 ML
- [ ] TensorFlow Lite 통합
- [ ] 관상 분석 모델
- [ ] 손금 분석 모델
- [ ] 오프라인 처리

### 🟢 중간 우선순위

#### 6. 고급 기능
- [ ] 푸시 알림 (FCM)
- [ ] 홈스크린 위젯
- [ ] 백그라운드 작업
- [ ] 딥링킹

#### 7. 최적화
- [ ] 이미지 최적화
- [ ] 앱 크기 감소
- [ ] 메모리 최적화
- [ ] 배터리 효율

### 📅 장기 로드맵

#### Q1 2025 (현재)
- ✅ Flutter 프로젝트 설정
- [ ] 핵심 화면 구현
- [ ] 기본 기능 완성
- [ ] 알파 테스트

#### Q2 2025
- [ ] 전체 운세 화면 구현
- [ ] 인앱 결제 시스템
- [ ] 베타 테스트
- [ ] 성능 최적화

#### Q3 2025
- [ ] 앱 스토어 출시
- [ ] 마케팅 캠페인
- [ ] 사용자 피드백 반영
- [ ] 다국어 지원

---

## 6. API 및 보안

### 🔐 Flutter 앱 보안

#### API 통신
```dart
// Dio 인터셉터로 인증 처리
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(authTokenProvider);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
```

#### 안전한 저장소
```dart
// 민감 정보는 flutter_secure_storage 사용
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
await storage.write(key: 'user_credentials', value: credentials);
```

#### 인증서 피닝
```dart
// SSL 인증서 검증
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (cert, host, port) {
    return cert.fingerprint == 'AA:BB:CC:DD:EE:FF...';
  };
  return client;
};
```

### 💳 토큰 시스템

#### 토큰 관리
```dart
class TokenService {
  // 토큰 차감
  Future<bool> deductTokens(String fortuneType) async {
    final cost = TOKEN_COSTS[fortuneType] ?? 1;
    final balance = await getBalance();
    
    if (balance < cost) {
      throw InsufficientTokensException();
    }
    
    // 로컬 DB 업데이트
    await localDb.updateTokenBalance(balance - cost);
    
    // 서버 동기화 (백그라운드)
    syncTokensInBackground();
    
    return true;
  }
  
  // 일일 보너스
  Future<void> claimDailyBonus() async {
    final lastClaim = await getLastDailyBonus();
    if (canClaimToday(lastClaim)) {
      await addTokens(DAILY_BONUS_AMOUNT);
      await updateLastClaimDate();
    }
  }
}
```

#### 토큰 비용
```dart
const TOKEN_COSTS = {
  'daily': 1,        // 일일 운세
  'tarot': 3,        // 타로카드
  'saju': 5,         // 사주팔자
  'dream': 2,        // 꿈해몽
  'compatibility': 4  // 궁합
};
```

---

## 7. 배포 및 운영

### 🚀 배포 체크리스트

#### Android
```bash
# 키스토어 생성
keytool -genkey -v -keystore fortune.keystore -alias fortune -keyalg RSA -keysize 2048 -validity 10000

# ProGuard 설정
# android/app/proguard-rules.pro

# App Bundle 빌드
flutter build appbundle --release
```

#### iOS
```bash
# 인증서 설정
# Xcode에서 Signing & Capabilities 설정

# 빌드
flutter build ios --release

# 아카이브 및 업로드
# Xcode → Product → Archive
```

#### 환경 변수
```dart
// 빌드 타입별 설정
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.fortune.app \
  --dart-define=ENVIRONMENT=production
```

### 📊 모니터링

#### Firebase 설정
- Crashlytics: 크래시 리포트
- Analytics: 사용자 행동 분석
- Performance: 성능 모니터링
- Remote Config: 동적 설정

#### 앱 스토어 최적화 (ASO)
- 키워드 최적화
- 스크린샷 A/B 테스트
- 리뷰 관리
- 업데이트 노트

### 🔧 유지보수

#### 버전 관리
```yaml
# pubspec.yaml
version: 1.0.0+1  # major.minor.patch+buildNumber
```

#### 업데이트 전략
- 강제 업데이트: 중요 보안 패치
- 선택 업데이트: 새 기능
- 단계적 배포: 10% → 50% → 100%

---

## 📚 참고 문서

### Flutter 관련 문서
- [Flutter 개발 환경 가이드](./docs/FLUTTER_DEVELOPMENT_ENVIRONMENT.md)
- [Flutter 프로젝트 구조](./docs/FLUTTER_PROJECT_STRUCTURE.md)
- [Flutter 패키지 의존성](./docs/FLUTTER_PACKAGE_DEPENDENCIES.md)
- [Flutter 마이그레이션 블루프린트](./docs/FLUTTER_MIGRATION_BLUEPRINT.md)

### 기존 문서
- [UI/UX 스크린샷 가이드](./docs/UI_UX_SCREENSHOTS_GUIDE.md)
- [데이터베이스 마이그레이션 가이드](./docs/DATABASE_MIGRATION_GUIDE.md)
- [외부 서비스 설정 가이드](./docs/EXTERNAL_SERVICES_SETUP_GUIDE.md)

### 외부 링크
- [Flutter 공식 문서](https://docs.flutter.dev)
- [Riverpod 문서](https://riverpod.dev)
- [Material You 가이드](https://m3.material.io)

---

**Note**: 이 문서는 Fortune Flutter 프로젝트의 단일 진실 공급원(Single Source of Truth)입니다. 모든 개발자는 이 문서를 기준으로 개발하고, 변경사항이 있으면 즉시 업데이트해야 합니다.

*마지막 업데이트: 2025년 7월 8일*  
*다음 검토: 2025년 7월 15일*

## 🎆 최근 업데이트

### 2025년 7월 8일 (v2.0.0)
- ✅ Flutter 프로젝트로 전면 전환
- ✅ 모바일 우선 아키텍처 설계
- ✅ 온디바이스 ML 계획 수립
- ✅ 크로스플랫폼 개발 환경 구축

### 이전 업데이트 (웹 버전)
- 웹 버전 개발 완료 (v1.4.1)
- 59개 운세 서비스 구현
- 결제 시스템 통합
- AI 최적화 완료
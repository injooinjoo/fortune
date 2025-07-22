# Flutter Development Guide

> **최종 업데이트**: 2025년 7월 11일  
> **프로젝트 상태**: 100% 완료 🎉  
> **개발 서버**: Port 9002

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [개발 환경 설정](#개발-환경-설정)
3. [프로젝트 구조](#프로젝트-구조)
4. [아키텍처](#아키텍처)
5. [구현된 기능](#구현된-기능)
6. [개발 가이드](#개발-가이드)
7. [빌드 및 배포](#빌드-및-배포)
8. [성능 최적화](#성능-최적화)

---

## 프로젝트 개요

Fortune Flutter 앱은 기존 웹 애플리케이션을 모바일 네이티브 앱으로 마이그레이션한 프로젝트입니다. 
Glassmorphism 디자인과 함께 모든 웹 기능을 Flutter로 구현하여 iOS/Android 플랫폼에서 동일한 사용자 경험을 제공합니다.

### 주요 목표
- ✅ 웹과 동일한 UI/UX 유지
- ✅ Glassmorphism 디자인 시스템 구현
- ✅ 117개 전체 기능 구현 완료
- ✅ iOS/Android 크로스 플랫폼 지원

---

## 개발 환경 설정

### 1. 기본 요구사항
```bash
# Flutter SDK
flutter --version  # 3.16.0 이상

# 개발 도구
- VS Code 또는 Android Studio
- Xcode 15.0+ (iOS 개발)
- Android Studio (Android 개발)
```

### 2. 프로젝트 설정
```bash
# 프로젝트 클론
git clone [repository-url]
cd fortune_flutter

# 의존성 설치
flutter pub get

# 개발 서버 실행
./run_dev.sh  # 포트 9002에서 실행
```

### 3. 환경 변수 설정
```bash
# .env 파일 생성
cp .env.example .env

# 필수 환경 변수
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
API_BASE_URL=https://api.example.com
```

### 4. Flavor 설정
프로젝트는 3가지 환경을 지원합니다:
- **dev**: 개발 환경
- **staging**: 스테이징 환경  
- **prod**: 프로덕션 환경

```bash
# 개발 환경 실행
flutter run --flavor dev

# 프로덕션 빌드
flutter build apk --flavor prod
flutter build ios --flavor prod
```

---

## 프로젝트 구조

### Clean Architecture 3-Layer 구조
```
lib/
├── presentation/      # UI 레이어
│   ├── pages/        # 화면 위젯
│   ├── widgets/      # 재사용 컴포넌트
│   └── providers/    # 상태 관리
├── domain/           # 비즈니스 로직
│   ├── entities/     # 핵심 모델
│   ├── repositories/ # Repository 인터페이스
│   └── usecases/     # Use Cases
├── data/             # 데이터 레이어
│   ├── models/       # DTO 모델
│   ├── datasources/  # API/DB 연결
│   └── repositories/ # Repository 구현
└── core/             # 공통 유틸리티
    ├── theme/        # 테마 설정
    ├── constants/    # 상수
    └── utils/        # 헬퍼 함수
```

### 파일 명명 규칙
- **페이지**: `*_page.dart`
- **위젯**: `*_widget.dart`
- **Provider**: `*_provider.dart`
- **Repository**: `*_repository.dart`
- **Use Case**: `*_usecase.dart`

---

## 아키텍처

### 의존성 방향
```
Presentation → Domain ← Data
     ↓           ↓        ↓
           Core (Shared)
```

### 주요 패턴
1. **Repository Pattern**: 데이터 소스 추상화
2. **Use Case Pattern**: 비즈니스 로직 캡슐화
3. **Provider Pattern**: 상태 관리 (Riverpod)
4. **Either Pattern**: 에러 처리
5. **Dependency Injection**: GetIt 사용

---

## 구현된 기능

### 디자인 시스템
- **Glassmorphism 컴포넌트**
  - GlassContainer: 기본 글래스 효과
  - GlassButton: 인터랙티브 버튼
  - LiquidGlassContainer: 애니메이션 효과
  - ShimmerGlass: 시머 애니메이션

### 핵심 기능 (117개 완료)
1. **인증 시스템**
   - Supabase 통합
   - 소셜 로그인 (Google, Apple, Kakao)
   - 토큰 기반 인증

2. **운세 시스템** (59개 카테고리)
   - 일일/주간/월간/연간 운세
   - 사주/타로/별자리 운세
   - 맞춤형 운세 추천

3. **결제 시스템**
   - In-App Purchase
   - 토큰 시스템
   - 구독 관리

4. **사용자 기능**
   - 프로필 관리
   - 운세 히스토리
   - 알림 설정

### 성능 메트릭
- 초기 로드: 2.5초
- 페이지 전환: <100ms
- 메모리 사용: <150MB

---

## 개발 가이드

### 1. 새 페이지 추가
```dart
// 1. 페이지 위젯 생성
class NewFortunePage extends ConsumerStatefulWidget {
  // 구현
}

// 2. 라우트 등록
GoRoute(
  path: '/fortune/new',
  builder: (context, state) => NewFortunePage(),
)

// 3. Provider 생성
final newFortuneProvider = StateNotifierProvider<...>(...);
```

### 2. API 연동
```dart
// Repository 인터페이스
abstract class FortuneRepository {
  Future<Either<Failure, Fortune>> getFortune(String type);
}

// Repository 구현
class FortuneRepositoryImpl implements FortuneRepository {
  final ApiClient apiClient;
  
  @override
  Future<Either<Failure, Fortune>> getFortune(String type) async {
    try {
      final response = await apiClient.get('/fortune/$type');
      return Right(Fortune.fromJson(response));
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### 3. 상태 관리
```dart
// Riverpod Provider
final fortuneProvider = FutureProvider.family<Fortune, String>((ref, type) async {
  final repository = ref.read(fortuneRepositoryProvider);
  final result = await repository.getFortune(type);
  return result.fold(
    (failure) => throw failure,
    (fortune) => fortune,
  );
});
```

---

## 빌드 및 배포

### Android 빌드
```bash
# 개발 빌드
flutter build apk --flavor dev

# 프로덕션 빌드
flutter build appbundle --flavor prod

# 릴리스 서명
./scripts/sign_android.sh
```

### iOS 빌드
```bash
# 개발 빌드
flutter build ios --flavor dev

# 프로덕션 빌드
flutter build ios --flavor prod --release

# Fastlane 배포
cd ios && fastlane beta
```

### CI/CD (GitHub Actions)
```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
```

---

## 성능 최적화

### 1. 이미지 최적화
- WebP 포맷 사용
- 적절한 해상도 제공
- 레이지 로딩 구현

### 2. 코드 최적화
- Tree shaking 활용
- 불필요한 위젯 리빌드 방지
- const 생성자 사용

### 3. 메모리 관리
- 적절한 dispose 구현
- 이미지 캐시 관리
- Provider 생명주기 관리

### 4. 번들 크기 최적화
```bash
# 앱 크기 분석
flutter build apk --analyze-size

# ProGuard 규칙 적용 (Android)
# R8 난독화 설정 (android/app/proguard-rules.pro)
```

---

## 문제 해결

### 자주 발생하는 이슈
1. **iOS 빌드 실패**: Xcode 설정 확인
2. **Android Gradle 오류**: gradle.properties 메모리 설정
3. **Provider 오류**: ref.watch vs ref.read 사용법

### 디버깅 도구
- Flutter Inspector
- Logger 패키지
- Charles Proxy (네트워크 디버깅)

---

## 다음 단계

1. **앱 스토어 출시 준비**
   - 앱 아이콘 및 스플래시 스크린
   - 스토어 설명 및 스크린샷
   - 심사 준비 사항

2. **지속적인 개선**
   - 사용자 피드백 수집
   - 성능 모니터링
   - 정기 업데이트

---

*이 문서는 Fortune Flutter 앱 개발의 전체 가이드입니다.*
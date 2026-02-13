# Clean Architecture 가이드

> 최종 업데이트: 2025.01.03

## 아키텍처 통계

| 항목 | 수치 |
|------|------|
| Features | 19개 |
| Edge Functions | 61개 (fortune 39 + utility 22) |
| StateNotifier 클래스 | 52개 |
| 서비스 파일 | 50+ 개 |

## 아키텍처 목표

**Clean Architecture + Feature Slice Design**

### 참고 아키텍처
- Airbnb's Component Library (Atoms → Molecules → Organisms)
- Stripe's Feature-First 구조 (Vertical Slicing)
- Notion's Clean Architecture (Domain → Data → Presentation)
- Uber's DDD (Domain-Driven Design)

---

## 프로젝트 구조

```
lib/
├── core/                       # 공유 인프라
│   ├── cache/                  # Hive 캐싱
│   ├── components/             # 기본 UI Atoms (TossCard, TossInput 등)
│   ├── config/                 # 환경설정, Feature Flags
│   ├── constants/              # 상수 (타로 메타데이터, 운세 데이터 등)
│   ├── design_system/          # 디자인 시스템 (NEW)
│   │   ├── tokens/             # DSColors, DSSpacing, DSRadius, DSTypography
│   │   ├── theme/              # DSTheme, DSExtensions
│   │   ├── components/         # 전통 컴포넌트 (HanjiCard, SealStamp 등)
│   │   └── utils/              # DSHaptics
│   ├── models/                 # 공유 도메인 모델 (Freezed)
│   ├── network/                # HTTP 클라이언트, 인터셉터
│   ├── providers/              # 전역 상태 (user_settings_provider 등)
│   ├── services/               # 비즈니스 로직 서비스 (50+ 파일)
│   ├── theme/                  # 테마 (DSColors, ChatGPT 스타일)
│   ├── utils/                  # 유틸리티 (날짜, 로거 등)
│   └── widgets/                # 재사용 위젯 (UnifiedFortuneBaseWidget 등)
├── features/                   # Feature Slice 모듈 (19개)
│   ├── about/                  # 앱 정보
│   ├── admin/                  # 관리자 기능
│   ├── chat/                   # 채팅 중심 진입점 (Chat-First)
│   ├── face_ai/                # 관상 AI (Face Reading)
│   ├── fortune/                # 운세 기능
│   ├── health/                 # 건강 기능
│   ├── history/                # 히스토리
│   ├── interactive/            # 타로, 심리테스트
│   ├── misc/                   # 기타
│   ├── notification/           # 알림
│   ├── payment/                # 결제
│   ├── policy/                 # 정책
│   ├── profile/                # 프로필 관리
│   ├── settings/               # 설정
│   ├── sports/                 # 스포츠
│   ├── support/                # 고객지원
│   ├── talisman/               # 부적 기능
│   ├── trend/                  # 트렌드
│   └── wellness/               # 웰니스
├── screens/                    # 페이지 레벨 스크린
├── routes/                     # GoRouter 네비게이션
├── providers/                  # 최상위 Provider
└── main.dart                   # 앱 진입점
```

---

## Feature Slice 구조

각 Feature는 독립적인 Clean Architecture 구조를 가집니다:

```
lib/features/{feature}/
├── data/
│   ├── models/                 # API 응답 모델 (DTO)
│   ├── services/               # API 호출 서비스
│   └── repositories/           # Repository 구현체
├── domain/
│   ├── models/                 # 도메인 모델 (Freezed)
│   ├── use_cases/              # 비즈니스 로직 Use Case
│   └── repositories/           # Repository 인터페이스
└── presentation/
    ├── pages/                  # 화면 위젯
    ├── providers/              # Feature별 상태 관리
    ├── widgets/                # Feature 전용 위젯
    └── utils/                  # Feature 전용 유틸
```

---

## 레이어 규칙

### Domain Layer (핵심)
- **순수 Dart 코드만** (Flutter 의존성 없음)
- 비즈니스 로직과 규칙 정의
- Entity, Use Case, Repository 인터페이스

```dart
// lib/features/fortune/domain/models/fortune_result.dart
@freezed
class FortuneResult with _$FortuneResult {
  const factory FortuneResult({
    required String id,
    required int score,
    required String message,
  }) = _FortuneResult;
}
```

### Data Layer
- Domain 레이어 구현
- API 호출, 캐싱, 로컬 저장소
- DTO → Entity 변환

```dart
// lib/features/fortune/data/repositories/fortune_repository_impl.dart
class FortuneRepositoryImpl implements FortuneRepository {
  final FortuneRemoteSource _remoteSource;

  @override
  Future<FortuneResult> getFortune(FortuneConditions conditions) async {
    final response = await _remoteSource.fetchFortune(conditions);
    return response.toDomain();
  }
}
```

### Presentation Layer
- UI 위젯과 상태 관리
- Domain 레이어만 참조 (Data 직접 참조 금지)
- StateNotifier + Riverpod 패턴

```dart
// lib/features/fortune/presentation/providers/fortune_provider.dart
class FortuneNotifier extends StateNotifier<FortuneState> {
  final FortuneRepository _repository;

  Future<void> loadFortune(FortuneConditions conditions) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getFortune(conditions);
    state = state.copyWith(isLoading: false, result: result);
  }
}
```

---

## 의존성 규칙

```
Presentation → Domain ← Data
     ↓           ↑        ↓
   Widget      Entity   Service
                 ↑        ↓
            Repository  API
```

### 허용되는 의존성
- `presentation` → `domain` (Use Case, Entity 사용)
- `data` → `domain` (Repository 구현, Entity 사용)
- `core` → 모든 레이어에서 사용 가능

### 금지되는 의존성
- `presentation` → `data` (직접 참조 금지)
- `domain` → `presentation` (역방향 참조 금지)
- `domain` → `data` (역방향 참조 금지)
- `feature A` → `feature B` (크로스 Feature 참조 금지, core 통해서만)

---

## Chat-First 아키텍처

### 개요

앱의 핵심 진입점을 채팅 인터페이스로 전환하는 아키텍처. 모든 운세 기능을 대화형으로 접근.

**네비게이션 (5탭)**:
```
Home(채팅) | 인사이트 | 탐구 | 트렌드 | 프로필
```

### Chat Feature 구조

```
lib/features/chat/
├── domain/
│   └── models/
│       ├── chat_message.dart           # ChatMessage, ChatMessageType
│       ├── chat_state.dart             # ChatState
│       └── recommendation_chip.dart    # 추천 칩 모델
├── presentation/
│   ├── providers/
│   │   ├── chat_messages_provider.dart # ChatMessagesNotifier
│   │   └── chat_recommendations_provider.dart
│   ├── pages/
│   │   └── chat_home_page.dart         # 메인 채팅 페이지
│   └── widgets/
│       ├── chat_message_bubble.dart    # 메시지 버블
│       ├── fortune_chip_grid.dart      # 추천 칩 그리드
│       ├── chat_fortune_section.dart   # 운세 결과 in 채팅
│       └── chat_welcome_view.dart      # 환영 화면
```

### 핵심 흐름

```
사용자 입력/칩 탭
       ↓
ChatMessagesNotifier
       ↓
1. addUserMessage()
2. showTypingIndicator()
3. FortuneApiService 호출
       ↓
FortuneResult
       ↓
FortuneResultConverter.convert()
       ↓
List<ChatMessage> (섹션별 분리)
       ↓
순차적 채팅 UI 표시
```

### 상세 문서

→ [18-chat-first-architecture.md](18-chat-first-architecture.md)

---

## 현재 마이그레이션 상태

### Phase 1: Foundation Layer (진행 중)

#### 완료된 항목
1. **UnifiedFortuneBaseWidget** (`lib/core/widgets/unified_fortune_base_widget.dart`)
   - 표준 운세 컨테이너
   - 로딩/에러/결과 상태 자동 관리
   - UnifiedFortuneService 자동 호출

2. **FortuneInputWidgets** (`lib/core/widgets/fortune_input_widgets.dart`)
   - 날짜 선택기 (`buildDatePicker`)
   - 시간 선택기 (`buildTimePicker`)
   - 단일 선택 (`buildSingleSelect`)
   - 텍스트 입력 (`buildTextField`)
   - 제출 버튼 (`buildSubmitButton`)

#### 다음 작업
3. **FortuneResultWidgets** (`lib/core/widgets/fortune_result_widgets.dart`)
   - 공통 결과 표시 위젯 라이브러리
   - 운세 카드 레이아웃
   - 점수 표시 (별점, 퍼센트)
   - 공유 버튼

4. **Clean Architecture 구조 생성**
   - `domain/use_cases/get_fortune_use_case.dart` (비즈니스 로직)
   - `data/repositories/fortune_repository_impl.dart` (구현체)
   - `data/sources/fortune_remote_source.dart` (API 호출)

5. **Dependency Injection 설정**
   - `core/di/injection_container.dart` (GetIt + Riverpod)
   - Provider 생성

### Phase 2: Feature Slice Migration (대기 중)
- BaseFortunePage 제거
- 19개 페이지 → UnifiedFortuneService 전환
- Feature별 독립 구조 (fortune_mbti, fortune_tarot, ...)

### Phase 3: Cleanup (대기 중)
- BaseFortunePage 파일 삭제
- 문서화 완료

---

## 아키텍처 검증 체크리스트

### 새 Feature 추가 시
- [ ] `lib/features/{feature}/` 구조 생성
- [ ] Domain 모델 @freezed 적용
- [ ] Repository 인터페이스 정의
- [ ] StateNotifier 패턴 사용
- [ ] 레이어 간 의존성 규칙 준수

### 코드 리뷰 시
- [ ] Presentation → Data 직접 참조 없음
- [ ] Feature 간 직접 참조 없음
- [ ] core/ 외부에서 Flutter 의존성 없는 Domain 모델
- [ ] 모든 모델 @freezed 사용

---

## 파일 네이밍 규칙

### 금지된 접미사 (CRITICAL)

| 접미사 | 예시 (WRONG) | 올바른 접근 |
|--------|-------------|------------|
| `_v2`, `_v3` | `payment_service_v2.dart` | 원본 파일 교체 |
| `_new` | `auth_service_new.dart` | 기존 삭제, 원본명 사용 |
| `_old` | `cache_service_old.dart` | 삭제 또는 git 브랜치 |
| `_enhanced` | `login_page_enhanced.dart` | 원본 수정 |
| `_renewed` | `tarot_renewed_page.dart` | 목적 설명하는 이름 |

**예외**: `typography_unified.dart`는 허용 ("unified"가 클래스명에 포함)

### 표준 네이밍 패턴

| 유형 | 패턴 | 예시 |
|------|------|------|
| Pages | `{feature}_{subtype}_page.dart` | `fortune_daily_page.dart` |
| Services | `{domain}_service.dart` | `celebrity_service.dart` |
| Widgets | `{name}_widget.dart` | `fortune_card_widget.dart` |
| Providers | `{domain}_provider.dart` | `auth_provider.dart` |

### 서비스 위치 규칙

```
여러 Feature에서 사용? → lib/services/
├── YES → lib/services/{name}_service.dart
└── NO → lib/features/{feature}/data/services/
```

---

## 관련 문서

- [04-state-management.md](04-state-management.md) - Riverpod StateNotifier 패턴
- [08-agents-skills.md](08-agents-skills.md) - `/sc:validate-arch` 커맨드

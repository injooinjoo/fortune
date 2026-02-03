# Fortune Flutter App - 아키텍처 문서

> 버전: 1.0.0+48 | Flutter 3.5.3+ | 최종 업데이트: 2025.01.20

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택](#2-기술-스택)
3. [디렉토리 구조](#3-디렉토리-구조)
4. [아키텍처 패턴](#4-아키텍처-패턴)
5. [핵심 Feature 분석](#5-핵심-feature-분석)
6. [디자인 시스템](#6-디자인-시스템)
7. [상태 관리](#7-상태-관리)
8. [백엔드 통합](#8-백엔드-통합)
9. [라우팅 구조](#9-라우팅-구조)
10. [개발 가이드라인](#10-개발-가이드라인)

---

## 1. 프로젝트 개요

### 1.1 앱 소개

Fortune은 **Chat-First 아키텍처**를 기반으로 한 종합 운세/웰니스 플랫폼입니다. 전통 동양 철학(사주, 오행, 명리학)과 현대 AI 기술을 결합하여 개인화된 인사이트를 제공합니다.

### 1.2 핵심 특징

| 특징 | 설명 |
|------|------|
| **Chat-First UX** | 모든 기능이 채팅 인터페이스로 통합 |
| **40+ 인사이트** | 일일/연간/사주/타로/궁합/건강 등 다양한 운세 |
| **AI 얼굴 분석** | MediaPipe Face Mesh 468 랜드마크 기반 관상 분석 |
| **프리미엄 블러** | 비구독자용 콘텐츠 블러 처리 시스템 |
| **동양 미학** | 오방색, 한지 질감, 먹 번짐 효과의 디자인 시스템 |

### 1.3 주요 수치

- **58개** Supabase Edge Functions
- **15개** Feature 모듈
- **40+** 서비스 클래스
- **200+** Dart 파일

---

## 2. 기술 스택

### 2.1 프론트엔드

| 카테고리 | 기술 | 버전 |
|----------|------|------|
| **프레임워크** | Flutter | 3.5.3+ |
| **상태관리** | Riverpod (StateNotifier) | ^2.6.1 |
| **라우팅** | GoRouter | ^15.1.2 |
| **HTTP 클라이언트** | Dio | ^5.7.0 |
| **로컬 저장소** | SharedPreferences, SecureStorage | - |
| **애니메이션** | flutter_animate | ^4.5.0 |
| **차트** | fl_chart | ^0.69.0 |

### 2.2 백엔드

| 카테고리 | 기술 |
|----------|------|
| **BaaS** | Supabase (PostgreSQL, Edge Functions, Auth) |
| **푸시 알림** | Firebase Cloud Messaging (FCM) |
| **분석** | Firebase Analytics |
| **결제** | In-App Purchase, Stripe |
| **LLM** | OpenAI GPT-4o, Claude (Edge Functions 통해) |

### 2.3 AI/ML

| 기능 | 기술 |
|------|------|
| **얼굴 분석** | MediaPipe Face Mesh (468 랜드마크) |
| **운세 생성** | LLM (GPT-4o, Claude) via Edge Functions |
| **성격 분석** | Personality DNA 알고리즘 |

---

## 3. 디렉토리 구조

```
fortune/
├── lib/
│   ├── main.dart                    # 앱 진입점
│   │
│   ├── core/                        # 핵심 기능 (앱 전체 공유)
│   │   ├── cache/                   # 캐싱 시스템
│   │   ├── config/                  # 설정 파일
│   │   ├── constants/               # 상수
│   │   ├── design_system/           # 디자인 시스템 ⭐
│   │   │   ├── components/          # DS 컴포넌트
│   │   │   ├── tokens/              # 디자인 토큰
│   │   │   └── theme/               # 테마
│   │   ├── errors/                  # 에러 처리
│   │   ├── models/                  # 핵심 모델
│   │   ├── network/                 # 네트워크 (Dio, Interceptors)
│   │   ├── providers/               # 전역 Provider
│   │   ├── services/                # 핵심 서비스 (40+)
│   │   ├── theme/                   # 테마 시스템
│   │   ├── usecases/                # 비즈니스 로직
│   │   ├── utils/                   # 유틸리티
│   │   └── widgets/                 # 공용 위젯
│   │
│   ├── data/                        # 데이터 레이어
│   │   ├── constants/               # 데이터 상수
│   │   ├── datasources/             # 데이터소스
│   │   ├── models/                  # 데이터 모델
│   │   ├── repositories/            # 저장소
│   │   └── services/                # 데이터 서비스
│   │
│   ├── domain/                      # 도메인 레이어
│   │   ├── entities/                # 도메인 엔티티
│   │   ├── models/                  # 도메인 모델
│   │   └── services/                # 도메인 서비스
│   │
│   ├── features/                    # Feature 모듈 (15개)
│   │   ├── chat/                    # 채팅 시스템 ⭐
│   │   ├── fortune/                 # 운세 핵심 ⭐
│   │   ├── interactive/             # 인터랙티브 (타로, 꿈)
│   │   ├── face_ai/                 # AI 얼굴 분석
│   │   ├── health/                  # 건강 운세
│   │   ├── trend/                   # 트렌드 콘텐츠
│   │   ├── history/                 # 운세 히스토리
│   │   ├── payment/                 # 결제
│   │   ├── settings/                # 설정
│   │   └── ...                      # 기타 features
│   │
│   ├── models/                      # 글로벌 모델
│   ├── presentation/                # 프레젠테이션 위젯
│   ├── providers/                   # 글로벌 Provider
│   ├── routes/                      # 라우팅 ⭐
│   ├── screens/                     # 화면/페이지
│   ├── services/                    # 글로벌 서비스
│   ├── shared/                      # 공유 레이아웃
│   ├── utils/                       # 유틸리티
│   └── widgets/                     # 글로벌 위젯
│
├── supabase/
│   ├── functions/                   # Edge Functions (58개)
│   └── migrations/                  # DB 마이그레이션
│
├── .claude/                         # Claude Code 설정
│   ├── agents/                      # AI 에이전트
│   ├── skills/                      # 스킬
│   └── docs/                        # 상세 문서
│
└── [설정 파일들]
    ├── pubspec.yaml                 # 의존성
    ├── .env.development             # 환경변수 (개발)
    ├── .env.production              # 환경변수 (운영)
    └── firebase.json                # Firebase 설정
```

---

## 4. 아키텍처 패턴

### 4.1 클린 아키텍처 (Feature별)

주요 Feature들은 **클린 아키텍처** 3계층을 따릅니다:

```
Feature/
├── data/                    # 데이터 레이어
│   ├── datasources/         # 로컬/원격 데이터소스
│   ├── models/              # 데이터 모델 (DTO)
│   ├── repositories/        # 저장소 구현
│   └── services/            # 데이터 서비스
│
├── domain/                  # 도메인 레이어
│   ├── entities/            # 도메인 엔티티
│   ├── models/              # 도메인 모델
│   └── services/            # 도메인 로직
│
└── presentation/            # 프레젠테이션 레이어
    ├── pages/               # 페이지/화면
    ├── providers/           # Riverpod 상태
    ├── widgets/             # UI 컴포넌트
    └── utils/               # 프레젠테이션 유틸
```

### 4.2 데이터 흐름

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │   Pages     │ -> │  Providers  │ <- │   Widgets  │  │
│  └─────────────┘    └─────────────┘    └────────────┘  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                      Domain                             │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │  Entities   │    │   Models    │    │  Services  │  │
│  └─────────────┘    └─────────────┘    └────────────┘  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                       Data                              │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │ Datasources │ -> │Repositories │ <- │  Services  │  │
│  └─────────────┘    └─────────────┘    └────────────┘  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                  External Services                      │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │  Supabase   │    │  Firebase   │    │   LLM API  │  │
│  └─────────────┘    └─────────────┘    └────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 5. 핵심 Feature 분석

### 5.1 Chat Feature (Chat-First 아키텍처)

**위치**: `lib/features/chat/`

앱의 **메인 진입점**으로, 모든 기능이 채팅 인터페이스로 통합됩니다.

#### 구조

```
chat/
├── constants/               # 채팅 상수
├── data/                    # 채팅 데이터
├── domain/                  # 채팅 도메인
├── presentation/
│   ├── pages/
│   │   └── chat_home_page.dart    # 메인 홈 ⭐
│   ├── providers/
│   │   ├── chat_messages_provider.dart
│   │   ├── chat_provider.dart
│   │   └── onboarding_chat_provider.dart
│   └── widgets/
│       ├── chat_message_list.dart
│       ├── chat_saju_result_card.dart
│       ├── chat_tarot_result_card.dart
│       └── ... (40+ 위젯)
└── services/
    └── chat_scroll_service.dart
```

#### ChatMessage 타입 (13가지)

```dart
enum ChatMessageType {
  user,                    // 사용자 입력
  ai,                      // AI 텍스트 응답
  fortuneResult,           // 운세 결과
  sajuResult,              // 사주 분석 결과
  personalityDnaResult,    // 성격 DNA 결과
  talismanResult,          // 부적 결과
  gratitudeResult,         // 감사일기 결과
  loading,                 // 로딩 표시
  system,                  // 시스템 메시지 (추천 칩)
  onboardingInput,         // 온보딩 입력 요청
  // ...
}
```

### 5.2 Fortune Feature (운세 핵심)

**위치**: `lib/features/fortune/`

40+ 운세 카테고리를 관리하는 핵심 기능입니다.

#### 카테고리 분류

| 그룹 | 카테고리 예시 |
|------|-------------|
| **시간 기반** | 오늘, 내일, 주간, 월간, 연간 |
| **전통 분석** | 전통사주, 타로, 꿈해몽, 관상 |
| **개성 분석** | 성격DNA, MBTI, 바이오리듬 |
| **관계** | 연애, 궁합, 경계대상, 재회, 소개팅 |
| **직업/경제** | 커리어, 시험, 재물, 투자, 로또 |
| **생활** | 행운아이템, 재능, 소원, 이사 |
| **건강** | 건강, 운동, 스포츠 |
| **기타** | 포춘쿠키, 유명인 사주, 펫궁합 |

#### 핵심 모델

```dart
// fortune_response_model.dart (1,200+ 라인)
// 모든 운세 API 응답을 통합 처리

class FortuneResponseModel {
  final String? dailyFortune;
  final SajuResult? sajuResult;
  final TarotResult? tarotResult;
  final CompatibilityResult? compatibilityResult;
  final bool isBlurred;           // 프리미엄 블러 처리
  final List<String>? blurredSections;
  // ... 20+ 운세 타입 매핑
}
```

### 5.3 Interactive Feature (인터랙티브)

**위치**: `lib/features/interactive/`

대화형/게임형 운세 기능들입니다.

| 페이지 | 기능 |
|--------|------|
| `dream_interpretation_page.dart` | 꿈해몽 AI 분석 |
| `tarot_animated_flow_page.dart` | 타로 카드 애니메이션 |
| `tarot_chat_page.dart` | 타로 채팅 인터페이스 |
| `worry_bead_page.dart` | 걱정 염주 (위로 서비스) |
| `psychology_test_page.dart` | 심리 테스트 |

### 5.4 Face AI Feature (얼굴 분석)

**위치**: `lib/features/face_ai/`

MediaPipe Face Mesh 기반 AI 관상 분석입니다.

```
face_ai/
├── data/
│   └── face_detector_service.dart    # MediaPipe 연동
├── domain/
│   └── face_reading_result_v2.dart   # 결과 모델
└── presentation/
    ├── pages/
    │   ├── face_ai_camera_page.dart  # 카메라 (468 랜드마크)
    │   └── face_ai_home_screen.dart  # 홈 화면
    └── widgets/
        ├── interactive_face_map.dart  # 인터랙티브 얼굴 지도
        └── face_zone_detail_card.dart # 부위별 분석 카드
```

---

## 6. 디자인 시스템

### 6.1 철학

**"여백의 미" (Beauty of Emptiness) × "한지 위의 먹" (Ink on Hanji)**

한국 전통 미학을 현대적으로 구현한 **Saaju Design System**입니다.

### 6.2 색상 시스템 (오방색)

**파일**: `lib/core/design_system/tokens/ds_colors.dart`

```dart
// 라이트 모드 (한지 종이 색감)
accent: #2C3E50           // 쪽빛 (Deep Indigo) - 주색
accentSecondary: #C0392B  // 다홍색 (Vermilion Red) - 인장
background: #F2F0E9       // 한지색 (Hanji Paper)
surface: #FDFEFE          // 소색 (Off-white)
textPrimary: #1A1A1A      // 먹색 (Ink Black)

// 다크 모드 (야경 스튜디오)
backgroundDark: #1A1A1A   // 벼루 (Ink Stone)
surfaceDark: #252525      // 어두운 종이
```

### 6.3 타이포그래피

**권장 파일**: `lib/core/theme/typography_unified.dart` ⭐

```dart
// 캘리그래피 스타일 (전통 느낌)
calligraphyDisplay    // 32pt, 나눔명조
calligraphyTitle      // 24pt
calligraphyBody       // 17pt

// 헤딩 스타일
heading1              // 24pt, Medium
heading2              // 20pt, Medium
heading3              // 18pt, Medium

// 바디 스타일
bodyLarge             // 16pt, Regular
bodyMedium            // 14pt, Regular
bodySmall             // 13pt, Regular

// 사용법
Text('제목', style: context.typo.heading1)  // ✅ 권장
Text('제목', style: TypographyUnified.heading1)
```

### 6.4 핵심 컴포넌트

| 컴포넌트 | 파일 | 특징 |
|----------|------|------|
| **DSButton** | `ds_button.dart` | 5가지 스타일, 인장 디자인 |
| **DSCard** | `ds_card.dart` | 5가지 스타일, 먹 번짐 효과 |
| **UnifiedButton** | `unified_button.dart` | Floating, Progress 지원 |
| **ChatBubble** | `chat_bubble.dart` | 글래스모피즘 효과 |
| **DSChip** | `ds_chip.dart` | 태그/선택 칩 |

```dart
// 버튼 사용 예시
DSButton.primary(
  text: '운세 보기',
  onPressed: () {},
  enableHaptic: true,
)

// 카드 사용 예시
DSCard.hanji(
  child: Text('한지 스타일'),
)
```

### 6.5 간격 & 라디우스

```dart
// 간격 (4px 배수)
DSSpacing.xs   // 4px
DSSpacing.sm   // 8px
DSSpacing.md   // 16px (기본)
DSSpacing.lg   // 24px
DSSpacing.xl   // 32px

// 라디우스
DSRadius.sm    // 4px (인장 버튼)
DSRadius.md    // 8px (기본)
DSRadius.lg    // 16px (카드)
DSRadius.xl    // 24px (모달)
```

---

## 7. 상태 관리

### 7.1 Riverpod (StateNotifier)

앱 전체에서 **StateNotifier 패턴**을 사용합니다. (`@riverpod` 어노테이션 금지)

```dart
// ✅ 올바른 패턴
class FortuneNotifier extends StateNotifier<FortuneState> {
  FortuneNotifier() : super(FortuneState.initial());

  Future<void> loadFortune() async {
    state = state.copyWith(isLoading: true);
    // ...
  }
}

final fortuneProvider = StateNotifierProvider<FortuneNotifier, FortuneState>(
  (ref) => FortuneNotifier(),
);

// ❌ 금지 패턴
@riverpod
class Fortune extends _$Fortune { ... }
```

### 7.2 Provider 구조

```
lib/core/providers/
├── user_settings_provider.dart    # 사용자 설정

lib/providers/
├── cache_provider.dart            # 캐시 상태
└── pet_provider.dart              # 펫 데이터

lib/features/[feature]/presentation/providers/
├── chat_messages_provider.dart    # 채팅 메시지
├── fortune_provider.dart          # 운세 상태
└── ...
```

---

## 8. 백엔드 통합

### 8.1 Supabase Edge Functions (58개)

**위치**: `supabase/functions/`

#### 운세 생성 함수 (33개)

```
fortune-daily          # 일일 운세
fortune-yearly         # 연간 운세
fortune-tarot          # 타로
fortune-love           # 연애
fortune-career         # 직업
fortune-wealth         # 재물
fortune-health         # 건강
fortune-compatibility  # 궁합
fortune-celebrity      # 유명인 사주
fortune-pet-compatibility # 펫 궁합
fortune-dream          # 꿈해몽
fortune-past-life      # 전생탐험
fortune-face-reading   # AI 관상
... (20+ 더 있음)
```

#### 사용자/인증 함수

```
kakao-oauth            # 카카오 로그인
naver-oauth            # 네이버 로그인
delete-account         # 계정 삭제
subscription-activate  # 구독 활성화
payment-verify-purchase # 결제 검증
```

### 8.2 API 서비스 구조

```dart
// lib/data/services/fortune_api_service_edge_functions.dart

class FortuneApiServiceWithEdgeFunctions extends FortuneApiService {
  // 복잡한 운세 (8초 이상 타임아웃)
  static const _complexFortuneTypes = [
    'talent', 'blind-date', 'career', 'investment',
    'celebrity', 'face-reading', 'past-life'
  ];

  @override
  Future<FortuneResponse> getFortune(String type, UserData user) async {
    final timeout = _complexFortuneTypes.contains(type) ? 30.seconds : 8.seconds;
    return await _callEdgeFunction('fortune-$type', user, timeout);
  }
}
```

### 8.3 LLM 통합 (LLMFactory)

Edge Function 내에서 LLM을 사용할 때는 **LLMFactory**를 통해 접근합니다:

```typescript
// supabase/functions/fortune-daily/index.ts
import { LLMFactory } from '../_shared/llm-factory.ts';

const llm = LLMFactory.createFromConfig('fortune-daily');
const response = await llm.generate(prompt);
```

---

## 9. 라우팅 구조

### 9.1 GoRouter 설정

**파일**: `lib/routes/route_config.dart`

### 9.2 네비게이션 구조 (Chat-First)

```
/
├── Auth Routes (외부)
│   ├── /splash
│   ├── /login
│   └── /register
│
├── Shell Route (메인 탭바)
│   │
│   ├── /chat ⭐ (Chat-First 메인 홈)
│   │   └── ChatHomePage
│   │
│   ├── /home (인사이트 대시보드)
│   │   └── HomeScreen
│   │
│   ├── /profile (프로필)
│   │   ├── /edit
│   │   ├── /saju
│   │   ├── /history
│   │   └── ...
│   │
│   ├── /premium (프리미엄)
│   │
│   └── /trend (트렌드)
│
├── Interactive Routes
│   ├── /fortune/tarot
│   ├── /fortune/dream
│   └── /fortune/worry-bead
│
├── Face AI Routes
│   ├── /face-ai/camera
│   └── /fortune/face-ai
│
└── 기타
    ├── /onboarding
    ├── /subscription
    └── /admin
```

### 9.3 탭 구조

| 탭 | 경로 | 역할 |
|----|------|------|
| **Home** | `/chat` | 통합 채팅 진입점 |
| **인사이트** | `/home` | 일일 인사이트 대시보드 |
| **탐구** | `/fortune` | 카테고리 + Face AI |
| **트렌드** | `/trend` | 트렌드 콘텐츠 |
| **프로필** | `/profile` | 설정 + Premium |

---

## 10. 개발 가이드라인

### 10.1 절대 금지 사항

| 금지 | 이유 | 대안 |
|------|------|------|
| `@riverpod` 어노테이션 | 프로젝트 패턴 위반 | StateNotifier 사용 |
| 하드코딩 색상/폰트 | 디자인 시스템 위반 | `context.colors`, `context.typo` |
| `flutter run` 직접 실행 | 로그 확인 불가 | 사용자에게 실행 요청 |
| 일괄 수정 (sed -i) | 프로젝트 손상 위험 | 파일별 Edit |

### 10.2 필수 패턴

#### 타이포그래피

```dart
// ✅ 올바른 사용
Text('제목', style: context.typo.heading1)

// ❌ 금지
Text('제목', style: TextStyle(fontSize: 24))
```

#### 블러 처리

```dart
// ✅ 올바른 사용
UnifiedBlurWrapper(
  isBlurred: result.isBlurred,
  child: content,
)

// ❌ 금지
ImageFilter.blur(...)
```

#### 채팅 상태

```dart
// ✅ ChatMessagesNotifier 사용
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  void addMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }
}

// ❌ 직접 setState 금지
```

### 10.3 Hard Block 시스템

모든 개발 작업은 다음 검증을 통과해야 합니다:

1. **Block 1 (RCA)**: 에러/버그 수정 전 근본 원인 분석 필수
2. **Block 2 (Discovery)**: 새 코드 작성 전 기존 코드 탐색 필수
3. **Block 3 (Verify)**: 수정 완료 전 `flutter analyze` 통과 필수

### 10.4 파일 참조

| 용도 | 파일 |
|------|------|
| 색상 | `lib/core/design_system/tokens/ds_colors.dart` |
| 타이포 | `lib/core/theme/typography_unified.dart` |
| 간격 | `lib/core/design_system/tokens/ds_spacing.dart` |
| 버튼 | `lib/core/widgets/unified_button.dart` |
| 카드 | `lib/core/design_system/components/ds_card.dart` |
| 채팅 | `lib/features/chat/presentation/` |
| 운세 | `lib/features/fortune/` |
| Edge Functions | `supabase/functions/` |

---

## 부록: 파일 구조 요약

```
총 파일 수: 200+

├── Core: 80+ 파일 (디자인 시스템, 서비스, 유틸)
├── Features: 15개 모듈
│   ├── Chat: 60+ 파일
│   ├── Fortune: 80+ 파일
│   ├── Interactive: 15+ 파일
│   └── 기타: 각 10-20 파일
├── Data/Domain: 30+ 파일
├── Presentation: 40+ 위젯
├── Routes: 10+ 파일
└── Supabase Edge Functions: 58개
```

---

**문서 작성**: Claude Code
**최종 업데이트**: 2025.01.20

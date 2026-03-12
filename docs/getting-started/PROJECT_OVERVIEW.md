# ZPZG 프로젝트 개요

현재 구현 기준 Fortune은 `AI 채팅 앱 + 2개 핵심 경험` 구조로 이해하는 것이 가장 정확합니다.

- `일반 채팅`: 세계관과 테마가 다른 일반 캐릭터와 DM처럼 대화
- `호기심`: 운세 전문가 캐릭터와 설문 기반 대화를 진행하고 결과를 채팅형으로 확인

current-state 라우트와 표면 설명은 [APP_SURFACES_AND_ROUTES.md](./APP_SURFACES_AND_ROUTES.md)를 source of truth로 사용합니다.

## 현재 제품 구조

### 메인 표면
- `/chat` 하나가 현재 앱의 메인 진입점입니다.
- `SwipeHomeShell` 안에서 일반 채팅과 호기심 경험을 전환합니다.
- 문서상 `story` / `fortune` 분류는 각각 `일반 채팅` / `호기심`으로 번역합니다.

### 보조 표면
- `/character/:id`: 캐릭터 상세 및 채팅 진입 보조 페이지
- `/onboarding`, `/onboarding/toss-style`: 온보딩
- `/premium`: 프리미엄
- `/privacy-policy`, `/terms-of-service`, `/account-deletion`: 정책/계정 관리
- `/signup`, `/auth/callback`, `/splash`: 인증 및 앱 초기 진입

### redirect-only
- `/` -> `/chat`
- `/home` -> `/chat`

## 핵심 사용자 경험

### 1. 일반 채팅
- 일반 캐릭터 목록을 탐색합니다.
- 캐릭터 상세로 이동하거나 바로 대화를 시작합니다.
- 대화는 DM처럼 유지되며, 관계와 세계관 중심으로 진행됩니다.

### 2. 호기심
- 운세 전문가 캐릭터와 대화를 시작합니다.
- 설문 단계가 필요한 경우 채팅 안에서 질문이 이어집니다.
- 결과는 별도 독립 페이지보다 채팅 안에서 카드/메시지 형태로 표시됩니다.

### 3. 보조 작업
- 온보딩에서 프로필과 기본 설정을 수집합니다.
- 프리미엄, 정책, 회원 탈퇴는 별도 페이지로 분리돼 있습니다.

## 기술 스택

- Flutter 3.5.3+
- Riverpod 2.x
- GoRouter 15.x
- Supabase Auth / Database / Edge Functions
- Firebase Cloud Messaging

## 주요 모듈

```text
lib/
├── core/                          # 디자인 시스템, 공통 서비스, 유틸
├── routes/                        # 실제 라우트 정의
├── features/
│   ├── character/                 # 현재 /chat 메인 표면, 캐릭터 목록/대화/상세
│   ├── chat/                      # 설문, 입력, 결과 위젯과 모델
│   ├── fortune/                   # 호기심 카테고리, 타입, 결과 도메인
│   ├── notification/              # 알림 설정
│   └── policy/                    # 정책 페이지
├── screens/                       # 인증, 온보딩, 프리미엄, 계정 탈퇴
└── services/                      # 딥링크, 저장소, 알림, 외부 연동
```

## 라우팅 이해

실제 current-state 라우트는 다음 코드가 기준입니다.

- `lib/routes/route_config.dart`
- `lib/routes/routes/auth_routes.dart`
- `lib/routes/character_routes.dart`

문서가 코드와 다르면 위 세 파일을 우선합니다.

## 개발 환경

### 필수 도구
- Flutter SDK 3.5.3+
- Xcode 14+
- Android Studio

### 기본 실행
```bash
flutter pub get
cd ios
pod install
cd ..
flutter run --dart-define-from-file=.env.development
```

## 검증 기본값

```bash
flutter analyze
flutter test
```

## 함께 보면 좋은 문서

- [현재 페이지/라우트 기준 문서](./APP_SURFACES_AND_ROUTES.md)
- [아키텍처 문서](../APP_ARCHITECTURE.md)
- [설정 가이드](./SETUP_GUIDE.md)
- [문서 인덱스](../README.md)

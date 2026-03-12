# Fortune

AI 캐릭터와 대화하는 Flutter 앱입니다. 현재 구현 기준 제품 표면은 `/chat` 하나를 중심으로 구성되며, 사용자는 `일반 채팅`과 `호기심` 두 경험을 오갑니다.

현재 제품 표면과 라우트 설명의 source of truth는 [docs/getting-started/APP_SURFACES_AND_ROUTES.md](docs/getting-started/APP_SURFACES_AND_ROUTES.md)입니다.

## 제품 모델

### 일반 채팅
- 세계관과 테마가 다른 일반 캐릭터와 DM처럼 대화합니다.
- 현재 구현상 `story` 캐릭터 분류가 여기에 해당합니다.

### 호기심
- 운세 전문가 캐릭터와 설문 기반 대화를 진행하고 결과를 채팅형으로 받습니다.
- 현재 구현상 `fortune` 캐릭터 분류가 여기에 해당합니다.

### 보조 표면
- 온보딩
- 캐릭터 상세
- 프리미엄
- 법률/계정 관리 페이지

## 현재 라우트

### 활성 메인 라우트
- `/chat`

### 보조 라우트
- `/`
- `/splash`
- `/signup`
- `/auth/callback`
- `/onboarding`
- `/onboarding/toss-style`
- `/character/:id`
- `/premium`
- `/privacy-policy`
- `/terms-of-service`
- `/account-deletion`

### redirect-only
- `/` -> `/chat`
- `/home` -> `/chat`

### current-state 기준 비활성 상위 라우트
- `/fortune`
- `/trend`
- `/profile`

위 경로들은 current-state active route로 문서화하지 않습니다.

## 코드 맵

```text
lib/
├── core/                          # 공통 인프라, 디자인 시스템, 유틸
├── routes/                        # GoRouter source of truth
├── features/
│   ├── character/                 # 현재 /chat 메인 표면과 캐릭터 대화
│   ├── chat/                      # 설문/입력/결과용 채팅 위젯과 모델
│   ├── fortune/                   # 호기심 카테고리, 타입, 결과 도메인
│   ├── notification/              # 알림 설정
│   └── policy/                    # 개인정보처리방침, 이용약관
├── screens/                       # 온보딩, 인증, 프리미엄, 계정 탈퇴
└── services/                      # 딥링크, 저장소, 알림 등
```

## 기술 스택

- Flutter 3.5.3+
- Riverpod 2.x
- GoRouter 15.x
- Supabase Auth / Database / Edge Functions
- Firebase Cloud Messaging

## 시작하기

### 필수 요구사항
- Flutter SDK 3.5.3 이상
- Dart SDK 3.5.3 이상
- Xcode 14+
- Android Studio

### 설치
```bash
flutter pub get
cd ios
pod install
cd ..
```

### 실행
```bash
flutter run --dart-define-from-file=.env.development
```

### 빌드
```bash
flutter build ios --dart-define-from-file=.env.production --release
flutter build appbundle --dart-define-from-file=.env.production --release
```

## 검증

```bash
flutter analyze
flutter test
```

## 문서 가이드

- [현재 페이지/라우트 기준 문서](docs/getting-started/APP_SURFACES_AND_ROUTES.md)
- [프로젝트 개요](docs/getting-started/PROJECT_OVERVIEW.md)
- [아키텍처 문서](docs/APP_ARCHITECTURE.md)
- [문서 인덱스](docs/README.md)

## 보안

- 모든 API 키는 환경 변수로 관리합니다.
- 민감한 값은 저장소에 커밋하지 않습니다.
- Supabase RLS와 인증 경계를 유지합니다.

## 기여

문서와 코드가 충돌하면 먼저 `lib/routes/`와 current-state 문서를 기준으로 판단합니다.

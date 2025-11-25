GoRouter 라우트를 추가합니다.

## 입력 정보

- **라우트 경로**: $ARGUMENTS 또는 사용자에게 질문 (예: /fortune/daily)
- **페이지 클래스**: 라우트에 연결할 페이지 위젯
- **파라미터**: 경로 파라미터 또는 쿼리 파라미터

## 수정 파일

```
lib/routes/route_config.dart
```

## 라우트 추가 패턴

### 기본 라우트

```dart
GoRoute(
  path: '/fortune/daily',
  name: 'daily-fortune',
  builder: (context, state) => const DailyFortunePage(),
),
```

### 경로 파라미터가 있는 라우트

```dart
GoRoute(
  path: '/fortune/:type',
  name: 'fortune-detail',
  builder: (context, state) {
    final type = state.pathParameters['type']!;
    return FortuneDetailPage(type: type);
  },
),
```

### 쿼리 파라미터가 있는 라우트

```dart
GoRoute(
  path: '/fortune/result',
  name: 'fortune-result',
  builder: (context, state) {
    final id = state.uri.queryParameters['id'];
    return FortuneResultPage(resultId: id);
  },
),
```

### 중첩 라우트

```dart
GoRoute(
  path: '/fortune',
  name: 'fortune',
  builder: (context, state) => const FortuneHomePage(),
  routes: [
    GoRoute(
      path: 'daily',
      name: 'fortune-daily',
      builder: (context, state) => const DailyFortunePage(),
    ),
    GoRoute(
      path: 'tarot',
      name: 'fortune-tarot',
      builder: (context, state) => const TarotFortunePage(),
    ),
  ],
),
```

### 리다이렉트가 있는 라우트

```dart
GoRoute(
  path: '/old-path',
  redirect: (context, state) => '/new-path',
),
```

## 네비게이션 사용법

```dart
// 경로로 이동
context.go('/fortune/daily');

// 이름으로 이동
context.goNamed('daily-fortune');

// 파라미터와 함께 이동
context.goNamed(
  'fortune-detail',
  pathParameters: {'type': 'tarot'},
);

// 쿼리 파라미터와 함께 이동
context.goNamed(
  'fortune-result',
  queryParameters: {'id': 'abc123'},
);

// 뒤로 가기
context.pop();
```

## 체크리스트

- [ ] 경로 이름 중복 확인
- [ ] 필수 파라미터 ! 연산자 사용
- [ ] 선택적 파라미터 null 처리
- [ ] import 문 추가

## route_config.dart 구조

```dart
final routerConfig = GoRouter(
  initialLocation: '/',
  routes: [
    // Home
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    // Fortune 관련 라우트
    GoRoute(
      path: '/fortune',
      routes: [
        // 여기에 새 라우트 추가
      ],
    ),

    // Profile 관련 라우트
    GoRoute(
      path: '/profile',
      routes: [...],
    ),
  ],
);
```

## 관련 Agent

- flutter-architect


# Flutter 기여 가이드

## 환영 인사
Fortune Flutter 프로젝트에 관심을 가져주셔서 감사합니다. 여러분의 기여는 더 나은 운세 앱을 만드는 데 큰 힘이 됩니다.

## 시작하기

### 1. 개발 환경 설정
```bash
# 1. 저장소 Fork 및 Clone
git clone https://github.com/your-username/fortune-flutter.git
cd fortune-flutter

# 2. Flutter 환경 확인
flutter doctor

# 3. 의존성 설치
flutter pub get

# 4. 코드 생성 (필요시)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. 개발 실행
flutter run
```

### 2. 필수 도구
- Flutter SDK 3.x 이상
- Dart SDK 3.x 이상
- Android Studio / Xcode
- VS Code 또는 IntelliJ IDEA
- Git

## 코딩 표준

### Dart 스타일 가이드
```dart
// ✅ 좋은 예
class FortuneService {
  final ApiClient _apiClient;
  
  FortuneService(this._apiClient);
  
  Future<Fortune> getDailyFortune({required String userId}) async {
    try {
      final response = await _apiClient.get('/fortune/daily/$userId');
      return Fortune.fromJson(response.data);
    } catch (e) {
      throw FortuneException('Failed to fetch daily fortune');
    }
  }
}

// ❌ 나쁜 예
class fortune_service {
  var api;
  
  getDailyFortune(userid) {
    // 타입 명시 없음, 네이밍 컨벤션 위반
  }
}
```

### 파일 구조
```
lib/
├── core/           # 핵심 기능 (상수, 유틸, 에러)
├── data/           # 데이터 레이어
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/         # 도메인 레이어
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/   # UI 레이어
    ├── screens/
    ├── widgets/
    └── providers/
```

## 기여 프로세스

### 1. 이슈 생성
새로운 기능이나 버그 수정을 시작하기 전에 이슈를 생성해주세요:
- **버그 리포트**: 재현 단계, 예상/실제 결과, 스크린샷
- **기능 제안**: 목적, 사용 사례, 예상 효과
- **개선 사항**: 현재 문제점, 제안하는 해결책

### 2. 브랜치 규칙
```bash
# 기능 추가
git checkout -b feature/add-tarot-screen

# 버그 수정
git checkout -b fix/daily-fortune-crash

# 문서 업데이트
git checkout -b docs/update-readme

# 리팩토링
git checkout -b refactor/fortune-service
```

### 3. 커밋 메시지
```bash
# 형식: <type>(<scope>): <subject>

# 예시
feat(fortune): add tarot card reading screen
fix(auth): resolve login crash on Android 12
docs(readme): update Flutter setup instructions
refactor(api): improve error handling in repository

# 타입
# feat: 새로운 기능
# fix: 버그 수정
# docs: 문서 변경
# style: 코드 포맷팅
# refactor: 코드 리팩토링
# test: 테스트 추가/수정
# chore: 빌드 프로세스 등 기타 변경
```

## 테스트 작성

### 단위 테스트
```dart
// test/data/repositories/fortune_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('FortuneRepository', () {
    late FortuneRepository repository;
    late MockApiService mockApiService;
    
    setUp(() {
      mockApiService = MockApiService();
      repository = FortuneRepositoryImpl(mockApiService);
    });
    
    test('should return daily fortune when API call succeeds', () async {
      // Given
      when(() => mockApiService.getDailyFortune(any()))
          .thenAnswer((_) async => testFortuneResponse);
      
      // When
      final result = await repository.getDailyFortune('user123');
      
      // Then
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (fortune) => expect(fortune.type, 'daily'),
      );
    });
  });
}
```

### 위젯 테스트
```dart
// test/presentation/widgets/fortune_card_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FortuneCard displays fortune content', (tester) async {
    // Given
    const testFortune = Fortune(
      type: 'daily',
      content: '오늘은 좋은 일이 생길 예정입니다',
      score: 85,
    );
    
    // When
    await tester.pumpWidget(
      MaterialApp(
        home: FortuneCard(fortune: testFortune),
      ),
    );
    
    // Then
    expect(find.text('오늘은 좋은 일이 생길 예정입니다'), findsOneWidget);
    expect(find.text('85'), findsOneWidget);
  });
}
```

## Pull Request 체크리스트

제출 전 확인사항:
- [ ] 코드가 `flutter analyze` 통과
- [ ] 모든 테스트 통과 (`flutter test`)
- [ ] 코드 포맷팅 완료 (`dart format .`)
- [ ] 새로운 기능에 대한 테스트 추가
- [ ] 문서 업데이트 (필요시)
- [ ] 커밋 메시지 규칙 준수
- [ ] PR 설명 작성 완료

### PR 템플릿
```markdown
## 개요
이 PR이 해결하는 문제나 추가하는 기능을 간단히 설명

## 변경 사항
- 주요 변경 사항 1
- 주요 변경 사항 2

## 테스트
- [ ] 단위 테스트 추가/수정
- [ ] 위젯 테스트 추가/수정
- [ ] 수동 테스트 완료

## 스크린샷 (UI 변경시)
변경 전 | 변경 후
--- | ---
![before](url) | ![after](url)

## 관련 이슈
Closes #123
```

## 코드 리뷰 가이드라인

### 리뷰어를 위한 가이드
- 건설적이고 구체적인 피드백 제공
- 코드 스타일보다는 로직과 아키텍처에 집중
- 좋은 점도 언급하여 긍정적인 분위기 조성

### 작성자를 위한 가이드
- 리뷰 코멘트에 신속히 응답
- 의견 차이가 있을 때는 근거를 제시
- 필요시 오프라인 논의 제안

## 보안 고려사항

- API 키나 비밀 정보를 코드에 포함하지 마세요
- 사용자 데이터는 항상 암호화하여 저장
- 입력값 검증을 철저히 수행
- 민감한 정보는 로그에 출력하지 않음

## 성능 가이드라인

- 불필요한 rebuild 방지 (`const` 위젯 사용)
- 큰 리스트는 `ListView.builder` 사용
- 이미지는 적절한 크기로 최적화
- 메모리 누수 주의 (dispose 메서드 구현)

## 문서화

### 코드 문서화
```dart
/// 사용자의 일일 운세를 가져옵니다.
/// 
/// [userId]로 사용자를 식별하며, 캐시된 데이터가 있으면
/// 네트워크 호출 없이 즉시 반환합니다.
/// 
/// 실패시 [FortuneException]을 throw합니다.
Future<Fortune> getDailyFortune({required String userId}) async {
  // 구현
}
```

### README 업데이트
새로운 기능이나 설정 변경시 README.md를 업데이트해주세요.

## 커뮤니티

- **Discord**: [Fortune Dev Community](https://discord.gg/fortune)
- **이슈 트래커**: [GitHub Issues](https://github.com/fortune/flutter/issues)
- **위키**: [프로젝트 위키](https://github.com/fortune/flutter/wiki)

## 행동 강령

모든 기여자는 상호 존중과 포용적인 환경을 만들기 위해 노력해야 합니다:
- 다양성을 존중하고 차별적인 언행 금지
- 건설적이고 전문적인 커뮤니케이션
- 다른 의견에 대한 열린 자세

---

**감사합니다!** 여러분의 기여가 Fortune 앱을 더 좋게 만듭니다. 🚀
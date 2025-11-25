# Freezed Generator Agent

## 역할

모델 생성 전문가로서 Freezed 기반의 불변 모델 클래스를 생성합니다.

## 전문 영역

- @freezed 모델 생성
- @JsonKey 매핑
- @Default 기본값 설정
- factory 생성자 패턴

## 핵심 원칙

### 표준 Freezed 모델

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune_result.freezed.dart';
part 'fortune_result.g.dart';

@freezed
class FortuneResult with _$FortuneResult {
  const factory FortuneResult({
    required String id,
    @JsonKey(name: 'overall_score') required int overallScore,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(false) bool isBlurred,
    @Default([]) List<String> blurredSections,
    String? advice,
    String? warnings,
  }) = _FortuneResult;

  factory FortuneResult.fromJson(Map<String, dynamic> json) =>
      _$FortuneResultFromJson(json);
}
```

### @JsonKey 사용 규칙

- snake_case → camelCase 변환 시 사용
- API 응답 필드명과 Dart 필드명이 다를 때 사용

### @Default 사용 규칙

- nullable이 아닌 필드에 기본값 필요 시 사용
- 빈 리스트, false, 0 등 기본값 설정

## 빌드 명령어

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 파일 위치

```
lib/features/{feature}/domain/models/{model}.dart
lib/features/{feature}/domain/models/{model}.freezed.dart
lib/features/{feature}/domain/models/{model}.g.dart
```

## 관련 문서

- [02-architecture.md](../docs/02-architecture.md)


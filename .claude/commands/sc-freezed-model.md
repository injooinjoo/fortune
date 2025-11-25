Freezed 모델을 생성합니다.

## 입력 정보

- **모델 이름**: $ARGUMENTS 또는 사용자에게 질문
- **Feature 이름**: 모델이 속한 Feature (예: fortune, profile)
- **필드 정의**: 각 필드의 이름, 타입, nullable 여부

## 생성 위치

```
lib/features/{feature}/domain/models/{model_name}.dart
```

## 생성 템플릿

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{model_name}.freezed.dart';
part '{model_name}.g.dart';

@freezed
class {ModelName} with _${ModelName} {
  const factory {ModelName}({
    required String id,
    // API 필드명이 snake_case인 경우
    @JsonKey(name: 'api_field_name') required String fieldName,
    // 기본값이 필요한 경우
    @Default(false) bool isActive,
    // nullable 필드
    String? optionalField,
  }) = _{ModelName};

  factory {ModelName}.fromJson(Map<String, dynamic> json) =>
      _${ModelName}FromJson(json);
}
```

## 실행 후 필수 작업

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 체크리스트

- [ ] @JsonKey: API 필드명과 Dart 필드명이 다른 경우
- [ ] @Default: nullable이 아닌 필드에 기본값 필요 시
- [ ] required: 필수 필드에 명시
- [ ] part 파일 선언 확인

## 관련 Agent

- freezed-generator


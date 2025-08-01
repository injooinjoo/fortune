# Flutter Switch 완전성 및 타입 에러 수정

## 🎯 수정 목표
Switch 문의 누락된 case와 타입 시스템 에러를 수정합니다.

## 📁 수정 대상 파일 (2개)

### 1. `lib/services/in_app_purchase_service.dart`
```dart
// 에러 위치: 라인 120
Error: The type 'PurchaseStatus' is not exhaustively matched by the switch cases 
since it doesn't match 'PurchaseStatus.restored'.
```

**수정 방법**:
```dart
// Before
switch (purchaseDetails.status) {
  case PurchaseStatus.pending:
    // ...
  case PurchaseStatus.purchased:
    // ...
  case PurchaseStatus.error:
    // ...
  case PurchaseStatus.canceled:
    // ...
}

// After
switch (purchaseDetails.status) {
  case PurchaseStatus.pending:
    // ...
  case PurchaseStatus.purchased:
    // ...
  case PurchaseStatus.error:
    // ...
  case PurchaseStatus.canceled:
    // ...
  case PurchaseStatus.restored:
    // Handle restored purchases
    _handleRestoredPurchase(purchaseDetails);
    break;
}
```

### 2. `lib/services/screenshot_detection_service.dart`
```dart
// 에러: Unsupported invalid type InvalidType
// 문제: FunctionType(<invalid> Function(BuildContext))
```

**수정 방법**:
이 파일에서 BuildContext를 파라미터로 받는 함수 타입 정의를 찾아서 수정하세요.

예시:
```dart
// Before
Function(BuildContext) myFunction;

// After
void Function(BuildContext) myFunction;
// 또는
typedef MyCallback = void Function(BuildContext context);
MyCallback myFunction;
```

## 🔧 주의사항
- Switch 문에 restored case를 추가할 때 적절한 처리 로직 구현
- 타입 정의를 명확하게 지정
- 기존 로직은 최대한 유지
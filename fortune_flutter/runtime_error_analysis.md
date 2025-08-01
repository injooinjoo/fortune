# Flutter 런타임 에러 분석

## 에러 타입 분류

### 1. Final 필드 초기화 에러 (17개)
- **에러**: "Final field 'xxx' is not initialized"
- **원인**: 생성자에서 final 필드를 초기화하지 않음
- **해결**: 생성자에 required 파라미터 추가

### 2. 상수 표현식 에러 (6개)
- **에러**: "Non-constant list literal is not a constant expression"
- **에러**: "Extension operations can't be used in constant expressions"
- **원인**: const 위젯에서 non-const 값 사용
- **해결**: const 제거 또는 값을 상수로 변경

### 3. Switch 문 완전성 에러 (1개)
- **에러**: "The type 'PurchaseStatus' is not exhaustively matched"
- **원인**: Switch 문에서 모든 case를 처리하지 않음
- **해결**: 누락된 case 추가 (PurchaseStatus.restored)

### 4. 컴파일러 충돌 에러 (1개)
- **에러**: "Unsupported invalid type InvalidType"
- **파일**: screenshot_detection_service.dart
- **원인**: 타입 시스템 오류
- **해결**: 해당 파일의 타입 정의 수정

## 영향받는 파일들

### 그룹 1: Final 필드 초기화
- fortune_explanation_bottom_sheet.dart
- soul_earn_animation.dart
- ad_loading_screen.dart
- birth_date_edit_dialog.dart
- birth_time_edit_dialog.dart
- blood_type_edit_dialog.dart
- mbti_edit_dialog.dart

### 그룹 2: 상수 표현식
- same_birthday_celebrity_fortune_page.dart
- tarot_enhanced_page.dart
- five_elements_widget.dart
- name_step.dart

### 그룹 3: Switch 완전성
- in_app_purchase_service.dart

### 그룹 4: 타입 시스템
- screenshot_detection_service.dart